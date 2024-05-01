local pttg = core:get_static_object("pttg");
local pttg_merc_pool = core:get_static_object("pttg_merc_pool")
local pttg_glory = core:get_static_object("pttg_glory")

local pttg_side_effects = {

}

function pttg_side_effects:heal_force(factor, use_tier_scale)
    local force = cm:get_military_force_by_cqi(pttg:get_state('army_cqi'))
    local unit_list = force:unit_list()

    local scale = 1

    for i = 0, unit_list:num_items() - 1 do
        local unit = unit_list:item_at(i);
        local base = unit:percentage_proportion_of_full_strength() / 100

        
        if unit:unit_class() ~= "com" then
            if use_tier_scale then
                scale = 1 / pttg_merc_pool.merc_units[unit:unit_key()].tier
            end
            pttg:log(string.format("[pttg_RestRoom] Healing unit %s to  %s(%s + %s).", unit:unit_key(), base + (factor * scale), base, (factor * scale)))
            ---@diagnostic disable-next-line: undefined-field
            cm:set_unit_hp_to_unary_of_maximum(unit, math.clamp(base + (factor * scale), 0.01, 1))
        else -- TODO: Heal characters for half (should we?)
            ---@diagnostic disable-next-line: undefined-field
            pttg:log(string.format("[pttg_RestRoom] Healing character %s to  %s(%s + %s).", unit:unit_key(), base + (factor / 2), base, (factor / 2)))
            cm:set_unit_hp_to_unary_of_maximum(unit, math.clamp(base + (factor / 2), 0.01, 1))
        end
    end
end

function pttg_side_effects:attrition_force(factor, use_tier_scale)
    local force = cm:get_military_force_by_cqi(pttg:get_state('army_cqi'))
    local unit_list = force:unit_list()

    local scale = 1

    for i = 0, unit_list:num_items() - 1 do
        local unit = unit_list:item_at(i);
        local base = unit:percentage_proportion_of_full_strength() / 100

        pttg:log(string.format("[pttg_RestRoom] Attritioning %s to  %s(%s - %s).", unit:unit_key(), base - factor, base,
        factor))
        if unit:unit_class() ~= "com" then
            if use_tier_scale then
                scale = 1 / pttg_merc_pool.merc_units[unit:unit_key()].tier
            end
            ---@diagnostic disable-next-line: undefined-field
            cm:set_unit_hp_to_unary_of_maximum(unit, math.clamp(base - (factor * scale), 0.01, 1))
        else -- TODO: Heal characters for half (should we?)
            ---@diagnostic disable-next-line: undefined-field
            cm:set_unit_hp_to_unary_of_maximum(unit, math.clamp(base - (factor / 2), 0.01, 1))
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

function pttg_RandomStart_callback(context)
	-- body of the callback; what should happen for each choice?
    local choice = context:choice_key()

    if choice == 'SECOND' then
        local general = cm:get_military_force_by_cqi(pttg:get_state("army_cqi")):general_character()
        cm:remove_all_units_from_general(general)
        cm:wound_character(cm:char_lookup_str(general), 1)
        pttg_merc_pool:trigger_recruitment(pttg:get_difficulty_mod('random_start_recruit_merc_count'), pttg:get_state('recruit_chances'))
        pttg_glory:add_recruit_glory(pttg:get_difficulty_mod('random_start_recruit_glory'))
    end

end

core:add_listener(
    "pttg_event_resolved",
    "DilemmaChoiceMadeEvent",
    function(context)
        return context:dilemma() == 'pttg_RandomStart'
    end,
    function(context)
        pttg_RandomStart_callback(context)
    end,
    false
)

function pttg_side_effects:zero_merc_cost()
    local recruitment_cost_bundle_key = "pttg_merc_recruit_cost_down";
	local faction = cm:get_local_faction()

    if faction:has_effect_bundle(recruitment_cost_bundle_key) then
        return
    end

    local recruitment_cost_bundle = cm:create_new_custom_effect_bundle(recruitment_cost_bundle_key);
    
    recruitment_cost_bundle:add_effect("wh3_main_effect_mercenary_cost_mod", "faction_to_character_own_factionwide_armytext", -10000);
    recruitment_cost_bundle:set_duration(0);

    recruitment_cost_bundle:add_effect("wh_main_effect_force_all_campaign_recruitment_cost_all", "faction_to_character_own_factionwide_armytext", -10000);
    recruitment_cost_bundle:set_duration(0);

    cm:apply_custom_effect_bundle_to_faction(recruitment_cost_bundle, faction);
end

core:add_static_object("pttg_side_effects", pttg_side_effects);
