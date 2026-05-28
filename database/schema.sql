-- ============================================================
-- GET RIPPED — Database Schema (SQLite)
-- ============================================================
-- Captures every data input from the Get Ripped 120-day plan webapp:
-- user profile, weight log, body measurements, workout completions,
-- exercise logs, recipe cycle history, shopping lists, supplement logs.
--
-- Designed for SQLite (works in browser via sql.js for live dashboards).
-- Can be ported to PostgreSQL with minimal changes.
-- ============================================================

-- ============================================================
-- USERS & PROFILE
-- ============================================================

CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT UNIQUE,
  name TEXT,
  sex TEXT CHECK (sex IN ('male','female','other')),
  height_inches REAL,
  start_date DATE,
  goal_weight_lbs REAL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_settings (
  user_id INTEGER PRIMARY KEY REFERENCES users(id),
  bodyweight_lbs REAL,
  meal_plan INTEGER CHECK (meal_plan IN (2,3,4,5)) DEFAULT 5,
  grocery_tier INTEGER CHECK (grocery_tier IN (1,2,3)) DEFAULT 2,
  grocery_store TEXT CHECK (grocery_store IN ('W','R')) DEFAULT 'W',
  weekly_recipe TEXT,
  cycle_number INTEGER DEFAULT 1,
  cycle_used_json TEXT,  -- JSON array of recipe keys used this cycle
  theme TEXT DEFAULT 'dark',
  notes TEXT,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- BODY TRACKING (the dashboards live here)
-- ============================================================

CREATE TABLE IF NOT EXISTS weight_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER REFERENCES users(id),
  measured_on DATE NOT NULL,
  weight_lbs REAL NOT NULL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, measured_on)
);
CREATE INDEX IF NOT EXISTS idx_weight_user_date ON weight_logs(user_id, measured_on);

CREATE TABLE IF NOT EXISTS body_measurements (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER REFERENCES users(id),
  measured_on DATE NOT NULL,
  waist_in REAL,
  chest_in REAL,
  hips_in REAL,
  arms_in REAL,
  thighs_in REAL,
  neck_in REAL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, measured_on)
);

-- ============================================================
-- TRAINING — MASTER DATA (reference for the program)
-- ============================================================

CREATE TABLE IF NOT EXISTS phases (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  days_start INTEGER NOT NULL,
  days_end INTEGER NOT NULL,
  focus TEXT,
  cardio_notes TEXT
);

CREATE TABLE IF NOT EXISTS exercises (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT UNIQUE NOT NULL,
  category TEXT,  -- push/pull/legs/core/conditioning
  is_main_lift BOOLEAN DEFAULT 0,
  form_cues TEXT,  -- JSON array of cues
  has_alternatives BOOLEAN DEFAULT 0,
  youtube_search_term TEXT
);

CREATE TABLE IF NOT EXISTS workouts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  phase_id INTEGER REFERENCES phases(id),
  week_in_phase INTEGER,
  day_of_week TEXT CHECK (day_of_week IN ('Mon','Tue','Wed','Thu','Fri','Sat','Sun')),
  time_of_day TEXT CHECK (time_of_day IN ('AM','PM','SINGLE')) DEFAULT 'SINGLE',
  session_type TEXT,
  label TEXT
);

CREATE TABLE IF NOT EXISTS workout_exercises (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  workout_id INTEGER REFERENCES workouts(id),
  exercise_id INTEGER REFERENCES exercises(id),
  order_idx INTEGER NOT NULL,
  prescription TEXT,
  is_finisher BOOLEAN DEFAULT 0,
  is_note BOOLEAN DEFAULT 0
);

-- ============================================================
-- TRAINING — USER LOGS (THE TRACKING DATA)
-- ============================================================

CREATE TABLE IF NOT EXISTS workout_completions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER REFERENCES users(id),
  workout_exercise_id INTEGER REFERENCES workout_exercises(id),
  completed_on DATE,
  sets_logged TEXT,  -- "135x8, 145x6, 155x4"
  top_set_weight_lbs REAL,  -- parsed top set weight
  top_set_reps INTEGER,     -- parsed top set reps
  rpe REAL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, workout_exercise_id, completed_on)
);
CREATE INDEX IF NOT EXISTS idx_wc_user_date ON workout_completions(user_id, completed_on);

-- ============================================================
-- MEAL PLANNING — RECIPES & CYCLES
-- ============================================================

CREATE TABLE IF NOT EXISTS recipes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  key TEXT UNIQUE NOT NULL,  -- 'spaghetti', 'padkrapao', etc.
  name TEXT NOT NULL,
  short_name TEXT,
  cuisine TEXT,
  source_name TEXT,
  source_url TEXT,
  prep_time_min INTEGER,
  servings_per_batch INTEGER NOT NULL,
  cal_per_serving REAL,
  p_per_serving REAL,
  c_per_serving REAL,
  f_per_serving REAL,
  meal_slot TEXT,  -- 'Lunch', 'Dinner', 'Lunch or Dinner'
  description TEXT,
  swaps TEXT,
  storage_notes TEXT,
  active BOOLEAN DEFAULT 1
);

CREATE TABLE IF NOT EXISTS recipe_ingredients (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  recipe_id INTEGER REFERENCES recipes(id),
  ingredient_name TEXT,
  quantity TEXT,  -- "1.5 tbsp" or "1 lb" — keep flexible
  section TEXT,   -- 'main', 'marinade', 'sauce', 'garnish', 'base'
  order_idx INTEGER
);

CREATE TABLE IF NOT EXISTS recipe_steps (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  recipe_id INTEGER REFERENCES recipes(id),
  step_number INTEGER,
  instruction TEXT
);

-- USER CYCLE TRACKING (each week's pick)
CREATE TABLE IF NOT EXISTS recipe_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER REFERENCES users(id),
  recipe_id INTEGER REFERENCES recipes(id),
  cycle_number INTEGER NOT NULL,
  week_starting DATE NOT NULL,
  cost_estimate REAL,
  satisfaction_rating INTEGER CHECK (satisfaction_rating BETWEEN 1 AND 5),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_rh_user_cycle ON recipe_history(user_id, cycle_number);

-- ============================================================
-- GROCERY & SHOPPING
-- ============================================================

CREATE TABLE IF NOT EXISTS grocery_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  category TEXT,  -- proteins/dairy/carbs/fruit/pantry/supplements
  base_qty REAL,
  unit TEXT,
  cost_warehouse REAL,
  cost_regular REAL,
  tier INTEGER CHECK (tier IN (1,2,3)) DEFAULT 1,
  no_scale BOOLEAN DEFAULT 0,
  amortize_weeks INTEGER DEFAULT 1,
  recipe_id INTEGER REFERENCES recipes(id),
  active BOOLEAN DEFAULT 1
);

CREATE TABLE IF NOT EXISTS shopping_lists (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER REFERENCES users(id),
  generated_on DATE NOT NULL,
  bodyweight_at_time REAL,
  meal_plan INTEGER,
  tier INTEGER,
  store TEXT,
  recipe_id INTEGER REFERENCES recipes(id),
  total_cost REAL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS shopping_list_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  shopping_list_id INTEGER REFERENCES shopping_lists(id),
  grocery_item_id INTEGER REFERENCES grocery_items(id),
  item_name TEXT,  -- denormalized for one-time items
  qty REAL,
  unit TEXT,
  estimated_cost REAL,
  purchased BOOLEAN DEFAULT 0
);

-- ============================================================
-- SUPPLEMENTS
-- ============================================================

CREATE TABLE IF NOT EXISTS supplements (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT UNIQUE NOT NULL,
  default_dose TEXT,
  timing TEXT,
  category TEXT,
  recommended BOOLEAN DEFAULT 1
);

CREATE TABLE IF NOT EXISTS supplement_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER REFERENCES users(id),
  supplement_id INTEGER REFERENCES supplements(id),
  taken_on DATE NOT NULL,
  dose_taken TEXT,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- NOTES (free-form journal)
-- ============================================================

CREATE TABLE IF NOT EXISTS user_notes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER REFERENCES users(id),
  section TEXT,  -- 'overview', 'training', 'meals', 'progress'
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- DASHBOARD VIEWS
-- ============================================================

-- Weight trend with weekly deltas
DROP VIEW IF EXISTS v_weight_trend;
CREATE VIEW v_weight_trend AS
SELECT
  user_id,
  measured_on,
  weight_lbs,
  LAG(weight_lbs) OVER (PARTITION BY user_id ORDER BY measured_on) AS prev_weight,
  weight_lbs - LAG(weight_lbs) OVER (PARTITION BY user_id ORDER BY measured_on) AS weekly_change,
  weight_lbs - FIRST_VALUE(weight_lbs) OVER (PARTITION BY user_id ORDER BY measured_on) AS total_change,
  ROUND(CAST((julianday(measured_on) - julianday(FIRST_VALUE(measured_on) OVER (PARTITION BY user_id ORDER BY measured_on))) AS REAL), 0) AS days_in
FROM weight_logs;

-- Body composition trend (waist is the key fat-loss indicator)
DROP VIEW IF EXISTS v_measurements_trend;
CREATE VIEW v_measurements_trend AS
SELECT
  user_id,
  measured_on,
  waist_in,
  chest_in,
  arms_in,
  thighs_in,
  waist_in - LAG(waist_in) OVER (PARTITION BY user_id ORDER BY measured_on) AS waist_change,
  chest_in - LAG(chest_in) OVER (PARTITION BY user_id ORDER BY measured_on) AS chest_change
FROM body_measurements;

-- Workout completion by date
DROP VIEW IF EXISTS v_workout_completion;
CREATE VIEW v_workout_completion AS
SELECT
  wc.user_id,
  wc.completed_on,
  COUNT(DISTINCT we.workout_id) AS workouts_done,
  COUNT(*) AS exercises_done,
  COUNT(CASE WHEN e.is_main_lift = 1 THEN 1 END) AS main_lifts_done
FROM workout_completions wc
JOIN workout_exercises we ON we.id = wc.workout_exercise_id
JOIN exercises e ON e.id = we.exercise_id
GROUP BY wc.user_id, wc.completed_on;

-- Lift progression for main compounds (Bench, Squat, OHP, Deadlift)
DROP VIEW IF EXISTS v_lift_progression;
CREATE VIEW v_lift_progression AS
SELECT
  wc.user_id,
  e.name AS exercise,
  wc.completed_on,
  wc.sets_logged,
  wc.top_set_weight_lbs,
  wc.top_set_reps,
  -- Estimated 1RM via Epley: weight * (1 + reps/30)
  ROUND(wc.top_set_weight_lbs * (1 + wc.top_set_reps / 30.0), 1) AS estimated_1rm
FROM workout_completions wc
JOIN workout_exercises we ON we.id = wc.workout_exercise_id
JOIN exercises e ON e.id = we.exercise_id
WHERE e.is_main_lift = 1
  AND wc.top_set_weight_lbs IS NOT NULL
ORDER BY wc.user_id, e.name, wc.completed_on;

-- Recipe cycle history with summary
DROP VIEW IF EXISTS v_recipe_cycle_summary;
CREATE VIEW v_recipe_cycle_summary AS
SELECT
  rh.user_id,
  rh.cycle_number,
  COUNT(*) AS recipes_used,
  GROUP_CONCAT(r.short_name, ', ') AS recipes_list,
  MIN(week_starting) AS cycle_started,
  MAX(week_starting) AS last_week,
  SUM(cost_estimate) AS total_cycle_cost,
  AVG(satisfaction_rating) AS avg_satisfaction
FROM recipe_history rh
JOIN recipes r ON r.id = rh.recipe_id
GROUP BY rh.user_id, rh.cycle_number;

-- Weekly grocery spend
DROP VIEW IF EXISTS v_weekly_spend;
CREATE VIEW v_weekly_spend AS
SELECT
  user_id,
  generated_on,
  total_cost AS weekly_cost,
  AVG(total_cost) OVER (
    PARTITION BY user_id
    ORDER BY generated_on
    ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
  ) AS rolling_4wk_avg
FROM shopping_lists
ORDER BY user_id, generated_on;

-- Supplement adherence (% of days each supplement was logged)
DROP VIEW IF EXISTS v_supplement_adherence;
CREATE VIEW v_supplement_adherence AS
SELECT
  sl.user_id,
  s.name AS supplement,
  COUNT(DISTINCT sl.taken_on) AS days_taken,
  MIN(sl.taken_on) AS first_logged,
  MAX(sl.taken_on) AS last_logged,
  ROUND(
    100.0 * COUNT(DISTINCT sl.taken_on) /
    NULLIF(julianday(MAX(sl.taken_on)) - julianday(MIN(sl.taken_on)) + 1, 0),
    1
  ) AS adherence_pct
FROM supplement_logs sl
JOIN supplements s ON s.id = sl.supplement_id
GROUP BY sl.user_id, s.name;

-- Master progress summary (the one-stop dashboard query)
DROP VIEW IF EXISTS v_progress_summary;
CREATE VIEW v_progress_summary AS
SELECT
  u.id AS user_id,
  u.name,
  u.start_date,
  CAST(julianday('now') - julianday(u.start_date) AS INTEGER) AS days_in_program,
  CAST(120 - (julianday('now') - julianday(u.start_date)) AS INTEGER) AS days_remaining,
  (SELECT weight_lbs FROM weight_logs WHERE user_id = u.id ORDER BY measured_on ASC LIMIT 1) AS starting_weight,
  (SELECT weight_lbs FROM weight_logs WHERE user_id = u.id ORDER BY measured_on DESC LIMIT 1) AS current_weight,
  (SELECT weight_lbs FROM weight_logs WHERE user_id = u.id ORDER BY measured_on DESC LIMIT 1) -
    (SELECT weight_lbs FROM weight_logs WHERE user_id = u.id ORDER BY measured_on ASC LIMIT 1) AS weight_change,
  u.goal_weight_lbs,
  (SELECT COUNT(*) FROM workout_completions WHERE user_id = u.id) AS total_exercises_logged,
  (SELECT COUNT(DISTINCT completed_on) FROM workout_completions WHERE user_id = u.id) AS training_days_logged,
  (SELECT cycle_number FROM user_settings WHERE user_id = u.id) AS current_cycle
FROM users u;
