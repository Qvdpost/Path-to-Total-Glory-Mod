local pttg = core:get_static_object("pttg");
local pttg_upkeep = core:get_static_object("pttg_upkeep")



local function init() 
    if not cm:get_saved_value('pttg_setup') then
        local faction = cm:get_local_faction()
        for i = 1, faction:character_list():num_items() - 1 do
            local char = faction:character_list():item_at(i)
            cm:kill_character(cm:char_lookup_str(char))
        end
        cm:set_saved_value('pttg_setup', true)
    end
end

cm:add_first_tick_callback(function() init() end);
