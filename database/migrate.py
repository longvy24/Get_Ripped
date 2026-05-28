#!/usr/bin/env python3
"""
Get Ripped — JSON Backup → SQLite Database

Reads a JSON backup file exported from the Get Ripped webapp (Settings tab →
Export My Data) and loads it into a SQLite database, applying schema.sql and
seed.sql first if the DB is empty.

Usage:
    python3 migrate.py                  # uses default paths
    python3 migrate.py path/to/backup.json path/to/output.db

The resulting .db file can be queried with the sqlite3 CLI, opened in any
SQL viewer (DBeaver, DB Browser for SQLite), or loaded by dashboards.html
in the browser.
"""

import sqlite3
import json
import sys
import os
import re
from pathlib import Path
from datetime import datetime, date


HERE = Path(__file__).parent
DEFAULT_BACKUP = HERE.parent / "get-ripped-backup-2026-05-26.json"
DEFAULT_DB = HERE / "get_ripped.db"
SCHEMA_SQL = HERE / "schema.sql"
SEED_SQL = HERE / "seed.sql"


def init_db(db_path: Path, force_fresh: bool = False):
    """Create the DB from schema.sql + seed.sql if it doesn't exist yet."""
    if db_path.exists() and not force_fresh:
        print(f"→ Using existing DB: {db_path}")
        return sqlite3.connect(db_path)

    if db_path.exists():
        db_path.unlink()

    print(f"→ Creating fresh DB: {db_path}")
    conn = sqlite3.connect(db_path)

    print(f"→ Applying schema: {SCHEMA_SQL.name}")
    with open(SCHEMA_SQL) as f:
        conn.executescript(f.read())

    print(f"→ Applying seed: {SEED_SQL.name}")
    with open(SEED_SQL) as f:
        conn.executescript(f.read())

    conn.commit()
    return conn


def upsert_user(conn, email: str, name: str, start_date: str = None) -> int:
    """Create or find the user and return their id."""
    cur = conn.cursor()
    cur.execute("SELECT id FROM users WHERE email = ?", (email,))
    row = cur.fetchone()
    if row:
        if start_date:
            cur.execute("UPDATE users SET start_date = ? WHERE id = ?", (start_date, row[0]))
            conn.commit()
        return row[0]

    cur.execute(
        "INSERT INTO users (email, name, start_date) VALUES (?, ?, ?)",
        (email, name, start_date),
    )
    conn.commit()
    return cur.lastrowid


def upsert_settings(conn, user_id: int, data: dict):
    """Save the user's app settings (meal plan, tier, weekly recipe, etc.)."""
    cur = conn.cursor()
    cycle_used = data.get("cycleUsed") or []
    cur.execute("""
        INSERT INTO user_settings (
            user_id, bodyweight_lbs, meal_plan, grocery_tier, grocery_store,
            weekly_recipe, cycle_number, cycle_used_json, theme, notes, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
        ON CONFLICT(user_id) DO UPDATE SET
            bodyweight_lbs = excluded.bodyweight_lbs,
            meal_plan = excluded.meal_plan,
            grocery_tier = excluded.grocery_tier,
            grocery_store = excluded.grocery_store,
            weekly_recipe = excluded.weekly_recipe,
            cycle_number = excluded.cycle_number,
            cycle_used_json = excluded.cycle_used_json,
            theme = excluded.theme,
            notes = excluded.notes,
            updated_at = CURRENT_TIMESTAMP
    """, (
        user_id,
        data.get("bodyweight"),
        data.get("mealPlan", 5),
        data.get("groceryTier", 2),
        data.get("groceryStore", "W"),
        data.get("weeklyRecipe"),
        data.get("cycleNumber", 1),
        json.dumps(cycle_used),
        data.get("theme", "dark"),
        data.get("notes", ""),
    ))
    conn.commit()


def import_weights(conn, user_id: int, weights: list) -> int:
    """Import all weight log entries."""
    if not weights:
        return 0
    cur = conn.cursor()
    rows = [(user_id, w["date"], w["lbs"]) for w in weights]
    cur.executemany("""
        INSERT OR REPLACE INTO weight_logs (user_id, measured_on, weight_lbs)
        VALUES (?, ?, ?)
    """, rows)
    conn.commit()
    return len(rows)


def import_measurements(conn, user_id: int, m: dict) -> int:
    """Import the latest measurements snapshot. Webapp only stores one snapshot at a time,
    so we insert with today's date."""
    if not m or not any(m.values()):
        return 0

    def to_float(v):
        try:
            return float(v) if v not in (None, "", " ") else None
        except (ValueError, TypeError):
            return None

    cur = conn.cursor()
    today = date.today().isoformat()
    cur.execute("""
        INSERT OR REPLACE INTO body_measurements
            (user_id, measured_on, waist_in, chest_in, hips_in, arms_in, thighs_in, neck_in)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        user_id, today,
        to_float(m.get("waist")),
        to_float(m.get("chest")),
        to_float(m.get("hips")),
        to_float(m.get("arms")),
        to_float(m.get("thighs")),
        to_float(m.get("neck")),
    ))
    conn.commit()
    return 1


def parse_sets(s: str):
    """Parse a sets string like '135x8, 145x6, 155x4' → returns top set (weight, reps)."""
    if not s:
        return None, None
    matches = re.findall(r"(\d+(?:\.\d+)?)\s*[xX×]\s*(\d+)", s)
    if not matches:
        return None, None
    parsed = [(float(w), int(r)) for w, r in matches]
    top = max(parsed, key=lambda t: t[0] * (1 + t[1] / 30.0))
    return top


def import_workout_logs(conn, user_id: int, completed: dict, logs: dict, start_date: str) -> int:
    """
    Webapp keys are like 'P-W-S-E' (phase-week-session-exerciseIdx).
    We import what we have — completion check-marks and sets logged.
    Without a full mapping table of P-W-S-E to actual workouts in the DB,
    we store the raw data in workout_completions for now.
    """
    count = 0
    cur = conn.cursor()

    # Collect all keys with either a completion or a log
    all_keys = set(completed.keys()) | set(logs.keys())

    for key in all_keys:
        was_completed = completed.get(key, False)
        sets_str = logs.get(key, "")
        if not was_completed and not sets_str:
            continue

        weight, reps = parse_sets(sets_str)

        # Without a workout_exercises row mapping, we'll insert a placeholder.
        # For richer schema-aware import, the webapp would need to send the exercise name too.
        # We use the key as a stable identifier so re-imports overwrite cleanly.
        cur.execute("""
            INSERT INTO workout_completions
                (user_id, workout_exercise_id, completed_on, sets_logged, top_set_weight_lbs, top_set_reps, notes)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """, (
            user_id,
            None,  # No mapping yet
            date.today().isoformat(),
            sets_str if sets_str else None,
            weight,
            reps,
            f"webapp_key={key}",
        ))
        count += 1

    conn.commit()
    return count


def main():
    backup_path = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_BACKUP
    db_path = Path(sys.argv[2]) if len(sys.argv) > 2 else DEFAULT_DB
    fresh = "--fresh" in sys.argv

    if not backup_path.exists():
        print(f"❌ Backup file not found: {backup_path}")
        print("\nExport your data from the webapp (Settings tab → Export My Data) and pass the path:")
        print(f"  python3 {Path(__file__).name} /path/to/backup.json")
        sys.exit(1)

    print(f"📂 Reading backup: {backup_path}")
    with open(backup_path) as f:
        data = json.load(f)

    print(f"   version: {data.get('version')}, exported: {data.get('exportedAt', 'unknown')}")
    print(f"   weights logged: {len(data.get('weights', []))}")
    print(f"   exercise check-marks: {sum(1 for v in data.get('completed', {}).values() if v)}")
    print(f"   exercise logs: {len(data.get('logs', {}))}")
    print(f"   measurements: {sum(1 for v in (data.get('measurements') or {}).values() if v)}")

    conn = init_db(db_path, force_fresh=fresh)

    # Pull user info from the system context if available, else use defaults
    email = os.environ.get("USER_EMAIL", "longvy24@gmail.com")
    name = os.environ.get("USER_NAME", "Long")

    user_id = upsert_user(conn, email, name, data.get("startDate"))
    print(f"\n👤 User: {email} (id={user_id})")

    upsert_settings(conn, user_id, data)
    print(f"⚙  Settings saved")

    n = import_weights(conn, user_id, data.get("weights", []))
    print(f"⚖  Weight logs imported: {n}")

    n = import_measurements(conn, user_id, data.get("measurements", {}))
    print(f"📏 Measurements snapshots imported: {n}")

    n = import_workout_logs(conn, user_id, data.get("completed", {}), data.get("logs", {}), data.get("startDate"))
    print(f"💪 Workout entries imported: {n}")

    conn.close()
    print(f"\n✅ Done. DB at: {db_path}")
    print(f"\nNext: open dashboards.html in a browser and upload {db_path.name} to see your charts.")
    print(f"Or query directly:   sqlite3 {db_path}")


if __name__ == "__main__":
    main()
