if not get_mct then return end
local mct = get_mct();

if not mct then return end
local mct_mod = mct:register_mod("tot_glory")

mct_mod:set_title("Path to Total Glory")
mct_mod:set_author("Quinner")
mct_mod:set_description("A roguelite on rails experience for TW Warhammer III.")

mct_mod:set_log_file_path("mod_logs/tot_glory.log")

-- Difficulty
local mct_option = mct_mod:add_new_option("difficulty", "dropdown")
mct_option:add_dropdown_value("easy", "Easy", "Provides an easier experience.", true)
mct_option:add_dropdown_value("regular", "Regular", "Regular difficulty, quite challenging.", false)
mct_option:add_dropdown_value("hard", "Hard", "Encounter more legendary battles and more difficult enemies. Bosses and Legendary armies gain stronger effects.", false)
mct_option:add_dropdown_value("legendary", "Legendary", "Legendary battles become even harder.")

mct_option:set_default_value("regular")


-- ProcGen Seed
local mct_option = mct_mod:add_new_option("random_seed", "checkbox")
local mct_option = mct_mod:add_new_option("seed", "slider")
mct_option:slider_set_min_max(0, 10000)
mct_option:slider_set_step_size(1)
mct_option:set_default_value(34)

local option_pttg_logging_enabled = mct_mod:add_new_option("logging_enabled", "checkbox");
option_pttg_logging_enabled:set_text("Enable logging");
option_pttg_logging_enabled:set_tooltip_text("If enabled, a log will be populated as you play. Use it to report bugs!");
option_pttg_logging_enabled:set_default_value(false);
