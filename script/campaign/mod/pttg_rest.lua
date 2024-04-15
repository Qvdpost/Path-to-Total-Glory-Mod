local pttg = core:get_static_object("pttg");

core:add_listener(
    "pttg_RestRoomChosen",
    "pttg_rest_room",
    true,
    function(context)

        pttg:log("[pttg_RestRoom] resolving rest: ")
        local force = cm:get_military_force_by_cqi(pttg:get_state('army_cqi'))
        local unit_list = force:unit_list()
        
        for i = 0, unit_list:num_items() - 1 do
            local unit = unit_list:item_at(i);
            local base = unit:percentage_proportion_of_full_strength() / 100
            local bonus = pttg:get_state('replenishment_factor')
            pttg:log(string.format("[pttg_RestRoom] Healing %s to  %s(%s + %s).", unit:unit_key(), base+bonus, base, bonus))
            if unit:unit_class() ~= "com" then
				---@diagnostic disable-next-line: undefined-field
                cm:set_unit_hp_to_unary_of_maximum(unit, math.clamp(base + bonus, 0.01, 1))
            else -- TODO: Heal characters for half (should we?)
                ---@diagnostic disable-next-line: undefined-field
                cm:set_unit_hp_to_unary_of_maximum(unit, math.clamp(base + bonus/2, 0.01, 1))
			end
            
        end

        core:trigger_custom_event('pttg_idle', {})
    end,
    true
)

local function init()

end

core:add_listener(
    "init_RestRoom",
    "pttg_init_complete",
    true,
    function(context)
        init()
    end,
    false
)

