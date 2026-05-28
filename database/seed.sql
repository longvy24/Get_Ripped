-- ============================================================
-- GET RIPPED — Seed Data (reference data, not user data)
-- ============================================================
-- Run AFTER schema.sql.
-- This populates the master tables with the program's content:
-- phases, recipes, exercises, supplements, grocery item templates.
-- User-specific data (weights, workouts done) gets migrated from JSON backup.
-- ============================================================

-- PHASES
INSERT INTO phases (id, name, days_start, days_end, focus, cardio_notes) VALUES
  (1, 'Phase 1: Ramp-Up', 1, 21, 'Movement quality, conditioning base, habit', 'Walking + light incline'),
  (2, 'Phase 2: Build', 22, 60, 'Strength + volume, body recomp begins', '3 steady, 1 HIIT, AM cardio on M/W/F'),
  (3, 'Phase 3: Push', 61, 90, 'Heavier lifts, harder conditioning', '2 HIIT, 2 steady, 1 sprint, AM cardio M/Th/F'),
  (4, 'Phase 4: Peak/Cut', 91, 120, 'Sharpen physique, maintain strength', '4 HIIT/circuits, 1 long walk, AM cardio M/T/Th/F');

-- RECIPES (the 5 primary meals)
INSERT INTO recipes (key, name, short_name, cuisine, source_name, source_url, prep_time_min, servings_per_batch, cal_per_serving, p_per_serving, c_per_serving, f_per_serving, meal_slot, description, swaps, storage_notes) VALUES
  ('spaghetti', 'One-Pot Spaghetti & Meat Sauce', 'Spaghetti', 'Italian-American', 'Brian Lagerstrom', 'https://www.youtube.com/watch?v=vrFQkLyGLzc', 25, 4, 734, 49, 88, 22, 'Dinner',
   'One-pot wonder. Ground beef + Italian sausage + tomato + pasta all cooked together so the pasta absorbs the sauce as it simmers.',
   '1 lb 80/20 → 1 lb 90/10 (saves 50g fat) · 8 oz Italian sausage → 4 oz · 50g Parmesan → 30g · Any pasta shape works.',
   'Weekly batch (3.5×). Use big Dutch oven. Portion into 13-14 containers Sunday. Microwave 90 sec with splash of water.'),

  ('padkrapao', 'Pad Kra Pao (Ground Beef variant)', 'Pad Kra Pao', 'Thai', 'Sam the Cooking Guy', 'https://www.thecookingguy.com/recipes/pad-kra-pao', 20, 3, 570, 42, 51, 22.5, 'Lunch or Dinner',
   'Thai basil stir-fry with ground beef. The 5-ingredient sauce is the magic — sweet, salty, umami, slightly spicy.',
   'Ground pork → 90/10 ground beef · 1 tbsp oil → 1/2 tbsp · 1 tbsp sugar → 1 tsp',
   'Weekly batch (5×). Pre-prep aromatics Sat night, stir-fry in 2 batches Sun. Basil added at end. Don''t freeze.'),

  ('dakgangjeong', 'Dakgangjeong (Pan-Fried, Sugar-Reduced)', 'Dakgangjeong', 'Korean', 'Maangchi', 'https://www.maangchi.com/recipe/easy-dakgangjeong', 30, 4, 510, 37, 59, 11.5, 'Lunch',
   'Korean crispy chicken in sweet-spicy gochujang glaze. Pan-fried (not deep-fried) and sugar cut by 70%.',
   'Deep-fry → pan-fry (saves 150 cal/serving) · 1/2 cup potato starch → 1 tbsp · 1/3 cup brown sugar → 2 tbsp · Skip rice syrup · +2 tbsp gochujang',
   'Weekly batch (3.5×). Pan-fry in 4-5 batches Sunday. Loses crispness in fridge — re-crisp in air fryer 380°F 3 min if desired.'),

  ('soyglaze', 'Soy Glazed Chicken Rice Bowl', 'Soy Glaze', 'Asian (Taiwanese-style)', 'Tiffy Cooks', 'https://tiffycooks.com/soy-glazed-chicken-rice-bowl-20-minutes-only/', 20, 4, 500, 31, 64, 11.5, 'Lunch',
   'Pan-seared chicken in sweet-savory soy glaze simmered with Coke Zero for caramelized depth.',
   'Skin-on thighs → SKINLESS (saves 70 cal/thigh) · Regular Coke → Coke Zero (saves 140 cal + 39g sugar) · 1 tsp oil',
   'Weekly batch (3.5×). Marinate chicken Sunday AM, pan-fry afternoon. Combine in big pot, reduce with Coke Zero.'),

  ('bunthitnuong', 'Bun Thit Nuong (Vietnamese Grilled Pork)', 'Bun Thit Nuong', 'Vietnamese', 'Hungry Huy', 'https://www.hungryhuy.com/bun-thit-nuong-recipe-vietnamese-grilled-bbq-pork-with-rice-vermicelli-vegetables/', 30, 4, 530, 40, 52, 17, 'Lunch or Dinner',
   'Vietnamese grilled pork marinated overnight, oven-baked, served over rice vermicelli OR white rice.',
   'Pork shoulder → pork loin · 1/4 cup sugar → 2 tbsp · 3 tbsp oil → 1 tbsp · Skip herbs/lettuce',
   'Weekly batch (3.5×). Slice + marinate 5 lb pork Sat night. Oven-bake in 2 batches Sun. Big mason jar of nuoc cham.');

-- SUPPLEMENTS
INSERT INTO supplements (name, default_dose, timing, category, recommended) VALUES
  ('Multivitamin', '1 capsule', 'With breakfast', 'micro', 1),
  ('Fish Oil', '2 softgels (~2400mg)', 'With breakfast or dinner', 'omega-3', 1),
  ('Creatine Monohydrate', '5g', 'Any time, mix in shake', 'strength', 1),
  ('Whey Protein', '1.5-2 scoops', 'Post-workout + mid-morning', 'protein', 1),
  ('Pre-Workout', '1 scoop, 20-30 min pre-lift', 'Heavy days only (2-3x/wk)', 'stimulant', 1),
  ('Collagen Peptides', '10-15g', 'Morning', 'joint', 0);

-- MAIN COMPOUND EXERCISES (the ones tracked for lift progression)
INSERT INTO exercises (name, category, is_main_lift, form_cues, has_alternatives, youtube_search_term) VALUES
  ('Barbell Bench Press', 'push', 1, '["Grip slightly wider than shoulders","Plant feet, slight arch","Lower to mid-chest, elbows ~75°","Press straight, no bounce"]', 1, 'barbell bench press proper form'),
  ('Back Squat', 'legs', 1, '["Bar on traps or rear delts","Feet shoulder-width, toes out","Sit between heels, depth below parallel","Drive through heels"]', 1, 'back squat proper form'),
  ('Standing Overhead Press', 'push', 1, '["Bar at clavicle, brace abs + glutes","Press up and slightly back","Push hips forward past head","Don''t hyperextend lower back"]', 1, 'standing overhead press form'),
  ('Deadlift', 'pull', 1, '["Bar over mid-foot","Hips below shoulders, flat back","Push floor away","Lock out hips and shoulders together"]', 1, 'deadlift proper form'),
  ('Trap Bar Deadlift', 'pull', 1, '["Stand inside trap bar","More squat-like position","Drive floor away","Easier on lower back"]', 0, 'trap bar deadlift form'),
  ('Romanian Deadlift', 'pull', 1, '["Soft knees - bend once at start","Hinge at hips, bar slides down legs","Push hips back, feel hamstring stretch","Drive hips forward"]', 0, 'romanian deadlift form'),
  ('Pull-up', 'pull', 1, '["Hands wider than shoulders, palms forward","Dead hang start","Chin over bar, lead with chest","Control the descent"]', 0, 'pull-up proper form'),
  ('Weighted Pull-up', 'pull', 1, '["Same form as bodyweight","Add 10-25 lbs via belt","Quality reps over quantity"]', 0, 'weighted pull-up form'),
  ('Barbell Row', 'pull', 1, '["Hinge at hips to 45°","Bar at thigh start","Row to lower chest/upper abs","No body english"]', 0, 'barbell row form'),
  ('Pendlay Row', 'pull', 1, '["Like barbell row but bar resets on floor","Explosive concentric","Strict form, more power"]', 0, 'pendlay row form'),
  ('Lat Pulldown', 'pull', 1, '["Wide grip, slight back lean","Pull to UPPER chest","Drive elbows down and back","Squeeze lats at bottom"]', 0, 'lat pulldown form'),
  ('Incline DB Press', 'push', 1, '["Bench at 30-45°","Elbows ~45°","Lower to chest level","Press up and slightly together"]', 0, 'incline dumbbell press form'),
  ('Hip Thrust', 'legs', 1, '["Upper back on bench, bar on hip crease (pad!)","Knees ~90° at top","Drive hips up, squeeze glutes","Full hip extension only"]', 0, 'hip thrust form'),
  ('Hack Squat', 'legs', 1, '["Feet shoulder-width on platform","More upright than back squat","Full ROM, drive through heels"]', 0, 'hack squat form'),
  ('Leg Press', 'legs', 1, '["Feet shoulder-width, mid-foot","Depth: knees toward chest","Don''t lock out","Don''t round lower back"]', 0, 'leg press form'),
  ('Goblet Squat', 'legs', 1, '["Hold DB vertical at chest","Feet shoulder-width","Squat between knees, depth below parallel","Drive through heels"]', 0, 'goblet squat form'),
  ('Bulgarian Split Squat', 'legs', 1, '["Back foot laces down on bench","Front shin vertical at bottom","Descend straight down","Drive through front heel"]', 0, 'bulgarian split squat form'),
  ('Dumbbell Bench Press', 'push', 1, '["Lie flat, DBs over chest, elbows ~45°","Lower until DBs at chest level","Press up and slightly together","Plant feet"]', 0, 'dumbbell bench press form'),
  ('Seated DB Shoulder Press', 'push', 1, '["Back against pad, DBs at ear level","Press straight overhead","Don''t flare elbows wide"]', 0, 'seated dumbbell shoulder press form'),
  ('Front Squat', 'legs', 1, '["Bar on front delts, elbows HIGH","Stay upright","Same depth as back squat"]', 1, 'front squat form'),
  ('Close-Grip Bench', 'push', 1, '["Hands shoulder-width","Tuck elbows tight","Drive elbows back behind body"]', 1, 'close-grip bench form'),
  ('Chest-Supported Row', 'pull', 1, '["Chest pinned to pad","Pull DBs/handles to hips","Squeeze blades at top"]', 0, 'chest-supported row form'),
  ('One-Arm DB Row', 'pull', 1, '["Hand and same-side knee on bench","Row DB to hip pocket","Slight torso rotation okay at top"]', 0, 'one-arm dumbbell row form'),
  ('Seated Cable Row', 'pull', 1, '["Tall posture","Pull handle to lower chest","Squeeze blades, control release"]', 0, 'seated cable row form');

-- ACCESSORY EXERCISES (not main lifts — for completeness)
INSERT INTO exercises (name, category, is_main_lift, form_cues, has_alternatives, youtube_search_term) VALUES
  ('Cable Crossover', 'push', 0, '["Slight forward lean, arms slightly bent","Bring hands down and across","Squeeze chest at bottom"]', 0, 'cable crossover form'),
  ('Cable Fly', 'push', 0, '["Pulleys at chest height","Arms slightly bent throughout","Bring hands together in wide arc"]', 0, 'cable fly form'),
  ('DB Lateral Raise', 'push', 0, '["Slight bend in elbows","Raise to shoulder height","Pour the pitchers tilt at top"]', 0, 'dumbbell lateral raise form'),
  ('Cable Lateral Raise', 'push', 0, '["Stand sideways to cable","Constant tension throughout"]', 0, 'cable lateral raise form'),
  ('Rope Triceps Pushdown', 'push', 0, '["Pin elbows at sides","Extend arms fully, spread rope at bottom","Slow on the way up"]', 0, 'rope triceps pushdown form'),
  ('Overhead Triceps Ext', 'push', 0, '["Face away from cable","Elbows pointed up, only forearms move","Squeeze at full extension"]', 0, 'overhead triceps extension form'),
  ('Skullcrusher', 'push', 0, '["Bar over forehead with bent arms","Lower toward forehead","Extend by straightening elbows only"]', 1, 'skullcrusher form'),
  ('Face Pull', 'pull', 0, '["Rope at face height","Pull to face, elbows high","Externally rotate at end","Slow, light weight"]', 0, 'face pull form'),
  ('EZ Bar Curl', 'pull', 0, '["EZ bar reduces wrist strain","No body sway","Full ROM"]', 0, 'ez bar curl form'),
  ('DB Curl', 'pull', 0, '["Elbows pinned to sides","Curl up, no elbow swing","Squeeze biceps at top"]', 0, 'dumbbell curl form'),
  ('Hammer Curl', 'pull', 0, '["Neutral grip (palms facing each other)","Targets brachialis","No swinging"]', 0, 'hammer curl form'),
  ('Barbell Curl', 'pull', 0, '["Straight bar, shoulder-width grip","No leaning back","Full ROM"]', 0, 'barbell curl form'),
  ('Walking Lunge', 'legs', 0, '["Long step forward","Back knee 1-2 inches off floor","Front shin vertical","Drive through front heel"]', 0, 'walking lunge form'),
  ('Leg Curl', 'legs', 0, '["Pad on achilles, not calf","Full ROM","Slow eccentric"]', 0, 'lying leg curl form'),
  ('Leg Extension', 'legs', 0, '["Pad on top of ankle","Full extension at top","Slow eccentric"]', 0, 'leg extension form'),
  ('Standing Calf Raise', 'legs', 0, '["Balls of feet on platform","Full stretch at bottom","Full contraction at top, pause"]', 0, 'standing calf raise form'),
  ('Seated Calf Raise', 'legs', 0, '["Targets soleus","Same ROM as standing","Heavy weight is fine"]', 0, 'seated calf raise form'),
  ('Glute-Ham Raise', 'legs', 0, '["Ankles locked, knees on pad","Lower slowly with control","Contract hamstrings to come up"]', 0, 'glute-ham raise form'),
  ('Hanging Leg Raise', 'core', 0, '["Grip pull-up bar, dead hang","Lift legs straight to 90°+","No swinging"]', 0, 'hanging leg raise form'),
  ('Hanging Knee Raise', 'core', 0, '["Same as leg raise, bent knees","Easier version"]', 0, 'hanging knee raise form'),
  ('Plank', 'core', 0, '["Forearms under shoulders","Brace abs AND glutes","Body straight, no sag/pike"]', 0, 'plank form'),
  ('Side Plank', 'core', 0, '["Forearm under shoulder","Lift hips high, straight line"]', 0, 'side plank form'),
  ('Dead Bug', 'core', 0, '["On back, arms up, knees at 90°","Lower opposite arm and leg","KEEP LOW BACK FLAT"]', 0, 'dead bug form'),
  ('Cable Crunch', 'core', 0, '["Kneel facing cable, rope behind head","Crunch with ABS not arms","Round forward"]', 0, 'cable crunch form'),
  ('Cable Wood Chop', 'core', 0, '["Arms relatively straight","Rotate through torso","Power from rotation not arms"]', 0, 'cable wood chop form'),
  ('Push-up', 'push', 0, '["Straight body, no sag/pike","Hands under shoulders","Lower to ground, elbows ~45°"]', 0, 'push-up form'),
  ('Kettlebell Swing', 'conditioning', 0, '["Hike KB between legs","Drive hips forward explosively","KB to chest height (Russian)"]', 0, 'kettlebell swing form'),
  ('DB Push Press', 'push', 0, '["DBs at shoulders","Slight knee dip then drive explosively","Use leg drive"]', 0, 'dumbbell push press form'),
  ('Battle Rope', 'conditioning', 0, '["Athletic stance","Whip continuously","Alternate or together"]', 0, 'battle rope workout'),
  ('Box Jump', 'conditioning', 0, '["Athletic stance, arm swing","Land soft in quarter-squat","Step DOWN not jump down"]', 0, 'box jump form'),
  ('DB Thruster', 'conditioning', 0, '["DBs at shoulders","Squat down to parallel","Drive up into OH press in one motion"]', 0, 'dumbbell thruster form'),
  ('Sled Push', 'conditioning', 0, '["Low body angle","Drive knees and arms hard","Short choppy steps"]', 0, 'sled push form'),
  ('Inverted Row', 'pull', 0, '["Bar at hip height, body under","Body straight from heels to head","Pull chest to bar","Harder: feet elevated"]', 0, 'inverted row form'),
  ('Heavy Plate Carry', 'conditioning', 0, '["Plate in each hand","Tall posture, brace core","Smooth controlled steps"]', 0, 'plate carry form'),
  ('Farmer Carry', 'conditioning', 0, '["DBs at sides, neutral grip","Tall posture, brace core","Small steady steps"]', 0, 'farmer carry form');

-- GROCERY ITEMS (base set, excluding recipe-specific)
INSERT INTO grocery_items (name, category, base_qty, unit, cost_warehouse, cost_regular, tier, no_scale, amortize_weeks) VALUES
  ('Bone-in chicken thighs (cheapest meat protein)', 'Proteins', 5, 'lb', 1.50, 2.50, 1, 0, 1),
  ('Ground beef 80/20 (family pack)', 'Proteins', 3, 'lb', 4.00, 5.50, 1, 0, 1),
  ('Eggs (general use)', 'Proteins', 1, 'doz', 3.00, 5.50, 1, 0, 1),
  ('Chicken breast (variety, optional)', 'Proteins', 1.5, 'lb', 4.00, 6.00, 3, 0, 1),
  ('Bacon (occasional treat)', 'Proteins', 0.5, 'lb', 7.00, 9.00, 3, 0, 1),
  ('Whole milk', 'Dairy', 2, 'gal', 4.50, 5.50, 1, 0, 1),
  ('Greek yogurt (2 store-brand tubs)', 'Dairy', 64, 'oz', 0.13, 0.22, 1, 0, 1),
  ('White rice (from bulk bag)', 'Carbs', 5, 'lb', 0.80, 1.20, 1, 0, 1),
  ('Oats (Member''s Mark canister)', 'Carbs', 24, 'oz', 0.30, 0.35, 1, 0, 1),
  ('Granola (yogurt bowls)', 'Carbs', 1, 'box', 4.00, 5.50, 1, 0, 1),
  ('Bananas (cheapest fresh fruit)', 'Fruit', 12, 'ct', 0.22, 0.30, 1, 0, 1),
  ('Apples (bagged)', 'Fruit', 4, 'ct', 0.50, 0.75, 2, 0, 1),
  ('Frozen strawberries (4 lb bag, amortized)', 'Fruit', 2, 'lb', 2.50, 4.50, 2, 0, 1),
  ('Frozen mixed berries (variety)', 'Fruit', 1, 'lb', 5.00, 7.00, 3, 0, 1),
  ('Peanut butter (40 oz Member''s Mark)', 'Pantry', 1, 'jar', 8.00, 10.00, 1, 1, 6),
  ('Vegetable oil', 'Pantry', 1, 'bottle', 5.00, 7.00, 1, 1, 8),
  ('Salt, pepper, basic spices', 'Pantry', 1, 'set', 10.00, 15.00, 1, 1, 12),
  ('Honey (sweetener)', 'Pantry', 1, 'jar', 4.00, 6.00, 1, 1, 6),
  ('Cinnamon (overnight oats)', 'Pantry', 1, 'jar', 3.00, 4.50, 1, 1, 24),
  ('Whey protein (Member''s Mark 6 lb)', 'Supplements', 1, 'tub', 55.00, 65.00, 1, 1, 6),
  ('Multivitamin (store brand)', 'Supplements', 1, 'bottle', 8.00, 12.00, 1, 1, 12),
  ('Fish oil (Nature Made)', 'Supplements', 1, 'bottle', 12.00, 18.00, 1, 1, 4),
  ('Creatine monohydrate', 'Supplements', 1, 'tub', 18.00, 25.00, 1, 1, 24),
  ('Pre-workout (Gorilla Mode, Amazon)', 'Supplements', 1, 'tub', 50.00, 50.00, 3, 1, 8);
