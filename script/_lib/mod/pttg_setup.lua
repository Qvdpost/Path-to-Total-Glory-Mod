local pttg = core:get_static_object("pttg");

pttg_setup = {}


function pttg_setup:init() 
    pttg:log("PathToTotalGlory Setup.")
    
    -- Fixes Nurgle recruit starting health.
    recruited_unit_health.units_to_starting_health_bonus_values = {}

    -- Do not reward post-battle rewards.
    core:remove_listener("award_random_magical_item")
end

function pttg_setup:post_init()
    -- Prevent player from moving.
    cm:zero_action_points(cm:char_lookup_str(cm:get_military_force_by_cqi(pttg:get_state("army_cqi")):general_character()))
end

core:add_static_object("pttg_setup", pttg_setup);
