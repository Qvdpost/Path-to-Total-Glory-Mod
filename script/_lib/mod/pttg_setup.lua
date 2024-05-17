local pttg = core:get_static_object("pttg");
local pttg_upkeep = core:get_static_object("pttg_upkeep")



local function init() 
    pttg:log("PathToTotalGlory Setup.")
    
    -- Fixes Nurgle recruit starting health.
    recruited_unit_health.units_to_starting_health_bonus_values = {}
end

local function post_init()
    -- Prevent player from moving.
    cm:zero_action_points(cm:char_lookup_str(cm:get_military_force_by_cqi(pttg:get_state("army_cqi")):general_character()))
end

core:add_listener(
    "pttg_mode_selection",
    "IncidentOccuredEvent",
    function(context) return context:dilemma() == "pttg_how_its_played" end,
    function(context)
        post_init()
    end,
    false
)

cm:add_first_tick_callback(function() init() end);
