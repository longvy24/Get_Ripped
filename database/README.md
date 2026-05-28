# Get Ripped — SQL Database & Dashboards

A SQLite database that captures every data input from the Get Ripped 120-day plan webapp, plus an interactive HTML dashboard that visualizes your progress.

🌐 **Live dashboard (once deployed to Pages):** https://longvy24.github.io/Get_Ripped/database/dashboards.html

## Files

| File | What it is |
|---|---|
| `schema.sql` | Database structure — 19 tables + 8 dashboard views |
| `seed.sql` | Reference data: phases, recipes, exercises, supplements, grocery items |
| `migrate.py` | Python script: reads your JSON backup → populates SQLite DB |
| `dashboards.html` | Browser dashboard (Chart.js + sql.js) — works without a server |
| `README.md` | This file |

## What's tracked

The schema captures **every input** from the main webapp:

- **Weight log** — every weigh-in with date
- **Body measurements** — waist, chest, hips, arms, thighs, neck
- **Workout completions** — every exercise check-mark + sets×reps logged
- **Recipe cycle history** — which week you picked which recipe
- **Shopping lists** — historical grocery cost over time
- **Supplement logs** — daily adherence per supplement
- **Free-form notes** — journal entries by section

Plus reference data for the program itself:
- 4 phases (Ramp-Up / Build / Push / Peak)
- 5 recipes (Spaghetti, Pad Kra Pao, Dakgangjeong, Soy Glaze, Bun Thit Nuong)
- 59 exercises (24 main lifts tagged for progression tracking)
- 24 base grocery items
- 6 supplements

## Quick start — three paths

### Path A: Just see your dashboards (easiest)

1. Open the webapp → Settings tab → **Export My Data** (downloads a `.json` file)
2. Open **dashboards.html** in any browser
3. Click "📁 JSON backup" and pick the file you just downloaded
4. Dashboard renders. No setup, no servers.

### Path B: Build a persistent SQLite database

```bash
cd database
python3 migrate.py
```

That reads your JSON backup, applies `schema.sql` + `seed.sql`, and writes `get_ripped.db`. Then either:

- Open `dashboards.html` → upload the `.db` file → see your charts
- Query directly: `sqlite3 get_ripped.db` then `SELECT * FROM v_progress_summary;`
- Open in **DB Browser for SQLite** or **DBeaver** for a GUI

To pass a custom backup path:
```bash
python3 migrate.py /path/to/backup.json /path/to/output.db
```

To start fresh and rebuild:
```bash
python3 migrate.py --fresh
```

### Path C: Just the schema (for your own use)

Run `schema.sql` against any SQL database (SQLite, PostgreSQL, MySQL with minor tweaks):

```bash
sqlite3 mydb.db < schema.sql
sqlite3 mydb.db < seed.sql
```

## Dashboard views (the queries powering the charts)

| View | Shows |
|---|---|
| `v_weight_trend` | Weight + weekly change + total change + days into program |
| `v_measurements_trend` | Waist/chest/arms/thighs with deltas |
| `v_workout_completion` | Exercises done per day, main lifts per day |
| `v_lift_progression` | Estimated 1RM (Epley formula) per main lift over time |
| `v_recipe_cycle_summary` | Each cycle's recipes used + costs + ratings |
| `v_weekly_spend` | Grocery cost over time + rolling 4-week average |
| `v_supplement_adherence` | % of days each supplement was logged |
| `v_progress_summary` | One-row everything: start weight, current, change, days in, cycle number |

## Example dashboard queries

```sql
-- Am I losing weight at the right pace?
SELECT * FROM v_weight_trend ORDER BY measured_on DESC LIMIT 10;

-- Which lifts are progressing?
SELECT exercise, MAX(estimated_1rm) AS best_e1rm, MIN(completed_on) AS first_logged
FROM v_lift_progression
GROUP BY exercise ORDER BY best_e1rm DESC;

-- Which recipes have I picked across cycles?
SELECT r.name, COUNT(*) AS times_picked, AVG(rh.cost_estimate) AS avg_cost
FROM recipe_history rh
JOIN recipes r ON r.id = rh.recipe_id
GROUP BY r.name ORDER BY times_picked DESC;

-- Workout streak — longest consecutive days trained
WITH days AS (
  SELECT DISTINCT completed_on FROM workout_completions ORDER BY completed_on
)
SELECT * FROM days;
```

## Deploying to GitHub Pages

The dashboard works as a static page — push the `database/` folder to your repo and it's live at:

```
https://longvy24.github.io/Get_Ripped/database/dashboards.html
```

Just `git push` (use the `deploy.command` from the parent folder) and the dashboard is online with everything else.

## Schema overview

```
users ────────┬──── user_settings
              │
              ├──── weight_logs       (every weigh-in)
              ├──── body_measurements (waist/chest/etc.)
              ├──── workout_completions ─── workout_exercises ─── exercises
              │                                                  └── workouts ─── phases
              ├──── recipe_history ─── recipes ─── recipe_ingredients
              │                                 └── recipe_steps
              ├──── shopping_lists ─── shopping_list_items ─── grocery_items
              ├──── supplement_logs ─── supplements
              └──── user_notes
```

## Limitations & roadmap

**Current:**
- The webapp's workout check-marks use opaque keys like `2-0-3-1` (phase-week-session-exerciseIdx). Without a mapping table, the migration script stores these as raw notes. Lift progression charts work when you log weight×reps strings (e.g., `135x8`); they're parsed for top-set estimation.

**To extend:**
- Wire the webapp to also export the exercise NAME alongside the key (one-line change in the JS) — then lift progression becomes per-exercise automatically
- Add a script that scrapes the program data from the HTML and populates `workouts` + `workout_exercises` tables fully
- Add a weekly auto-export cron that snapshots the localStorage data into the DB

## How to update data

The webapp continues to be the source of truth for daily logging. The DB is downstream:

1. Use the webapp day-to-day (workouts, weights, etc.)
2. **Every Sunday** (or weekly): Settings → Export My Data → save the JSON
3. Run `python3 migrate.py path/to/latest-backup.json` to rebuild the DB
4. Open `dashboards.html` → see updated charts

Or just upload the JSON directly to `dashboards.html` each time — skip the SQLite step entirely.
