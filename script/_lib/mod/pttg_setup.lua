local pttg = core:get_static_object("pttg");
local pttg_upkeep = core:get_static_object("pttg_upkeep")



local function init() 
    pttg:log("PathToTotalGlory Setup.")
    if not cm:get_saved_value('pttg_char_setup') then
        pttg:log("Clearing out starting agents.")
        local faction = cm:get_local_faction()
        pttg:log("Agent count: "..faction:character_list():num_items())
        local characters = {}
        for i = 1, faction:character_list():num_items() - 1 do
            table.insert(characters, faction:character_list():item_at(i))
        end
        for _, char in pairs(characters) do
            pttg:log("Clearing out: ".. char:character_subtype_key().."|"..char:character_type_key())
            cm:kill_character(cm:char_lookup_str(char))
        end
        pttg:log("Clearing out starting agents done.")
        cm:set_saved_value('pttg_char_setup', true)
    end

    -- Fixes Nurgle recruit starting health.
    recruited_unit_health.units_to_starting_health_bonus_values = {}
end

cm:add_first_tick_callback(function() init() end);
