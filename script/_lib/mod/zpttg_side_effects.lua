local pttg = core:get_static_object("pttg");
local pttg_merc_pool = core:get_static_object("pttg_merc_pool")


local pttg_side_effects = {

}

function pttg_side_effects:heal_force(factor, use_tier_scale)
    local force = cm:get_military_force_by_cqi(pttg:get_state('army_cqi'))
    local unit_list = force:unit_list()

    local scale = 1

    for i = 0, unit_list:num_items() - 1 do
        local unit = unit_list:item_at(i);
        local base = unit:percentage_proportion_of_full_strength() / 100

        pttg:log(string.format("[pttg_RestRoom] Healing %s to  %s(%s + %s).", unit:unit_key(), base + factor, base,
        factor))
        if unit:unit_class() ~= "com" then
            if use_tier_scale then
                scale = 1 / pttg_merc_pool.merc_units[unit:unit_key()].tier
            end
            ---@diagnostic disable-next-line: undefined-field
            cm:set_unit_hp_to_unary_of_maximum(unit, math.clamp(base + (factor * scale), 0.01, 1))
        else -- TODO: Heal characters for half (should we?)
            ---@diagnostic disable-next-line: undefined-field
            cm:set_unit_hp_to_unary_of_maximum(unit, math.clamp(base + (factor / 2), 0.01, 1))
        end
    end
end

function pttg_side_effects:grant_general_levels(amount)
    local character = cm:get_military_force_by_cqi(pttg:get_state('army_cqi')):general_character()
    local lookup = cm:char_lookup_str(character)
    local current_character_rank = character:rank()
    local character_rank = amount

    ---@diagnostic disable-next-line: undefined-field
    local xp = cm.character_xp_per_level[math.min(current_character_rank + character_rank, 50)] - cm.character_xp_per_level[current_character_rank]

    cm:add_agent_experience(lookup, xp)
end

function pttg_side_effects:grant_characters_levels(amount)
    local army_chars = cm:get_military_force_by_cqi(pttg:get_state('army_cqi')):character_list()
    for i = 0, army_chars:num_items()-1 do
        local character = army_chars:item_at(i)
        local lookup = cm:char_lookup_str(character)
        local current_character_rank = character:rank()
        local character_rank = amount
    
        ---@diagnostic disable-next-line: undefined-field
        local xp = cm.character_xp_per_level[math.min(current_character_rank + character_rank, 50)] - cm.character_xp_per_level[current_character_rank]
    
        cm:add_agent_experience(lookup, xp)
    end
   
end

core:add_static_object("pttg_side_effects", pttg_side_effects);
