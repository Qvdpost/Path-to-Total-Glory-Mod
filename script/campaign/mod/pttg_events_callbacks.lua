local pttg = core:get_static_object("pttg");
local pttg_glory = core:get_static_object("pttg_glory")
local pttg_merc_pool = core:get_static_object("pttg_merc_pool")
local pttg_side_effects = core:get_static_object("pttg_side_effects")
local pttg_events = core:get_static_object("pttg_event_pool")
local pttg_battle_templates = core:get_static_object("pttg_battle_templates");


function pttg_EventGlory_callback(context)
    if context:choice_key() == 'FIRST' then
        pttg_glory:reward_glory(15)
    elseif context:choice_key() == 'SECOND' then
        pttg_glory:reward_glory(30)
        pttg:set_state('alignment', pttg:get_state('alignment') + 15)
    end
end

function pttg_EventGlory_eligibility_callback(context)
    
    if context.act ~= 1 and context.act ~= 2 then
        return false
    end

    -- if context.alignment > 20 then
    --     return false
    -- end

    local faction_set = 'all'
    if not context.faction:is_contained_in_faction_set(faction_set) then
        return false
    end

    return true
end

function pttg_HiringBoard_callback(context)
	-- body of the callback; what should happen for each choice?
    local hiring_board = cm:create_dilemma_builder('pttg_AgentRecruit')
    local faction = cm:get_local_faction()

    for agent_type, _ in pairs(pttg_merc_pool:recruitable_agents(faction:name())) do 
        local agent_payload = cm:create_payload()
        if agent_type == 'champion' then
			hiring_board:add_choice_payload("FIRST", agent_payload);
            agent_payload:clear()
        elseif agent_type == 'dignitary' then
			hiring_board:add_choice_payload("SECOND", agent_payload);
            agent_payload:clear()
        elseif agent_type == 'engineer' then
			hiring_board:add_choice_payload("THIRD", agent_payload);
            agent_payload:clear()
        elseif agent_type == 'runesmith' then
			hiring_board:add_choice_payload("FOURTH", agent_payload);
            agent_payload:clear()
        elseif agent_type == 'spy' then
			hiring_board:add_choice_payload("FIFTH", agent_payload);
            agent_payload:clear()
        elseif agent_type == 'wizard' then
			hiring_board:add_choice_payload("SIXTH", agent_payload);
            agent_payload:clear()
        end
    end

    local hiring_payload = cm:create_payload()
    -- hiring_payload:text_display("pttg_RecruitAgent_seventh");
    hiring_board:add_choice_payload("SEVENTH", hiring_payload);
    hiring_payload:clear()

    if cm:random_number(100, 1) < 5 then
        -- hiring_payload:text_display("pttg_RecruitAgent_eighth");
        hiring_board:add_choice_payload("EIGHTH", hiring_payload);
        hiring_payload:clear()
    end

    core:add_listener(
        "pttg_agent_recruit",
        "DilemmaChoiceMadeEvent",
        function(context) return context:dilemma() == 'pttg_AgentRecruit' end,
        pttg_AgentRecruit_callback,
        false
    )

    cm:launch_custom_dilemma_from_builder(hiring_board, faction)
end

function pttg_HiringBoard_eligibility_callback(context)
    
    if context.act ~= 1 and context.act ~= 2 then -- only triggers in act 1 or 2
        return false
    end

    local force = cm:get_military_force_by_cqi(pttg:get_state('army_cqi'))
    if force:character_list():num_items() > 3 then
        return false
    end

    if force:character_list():num_items() == 1 then
        context.event.weight = 25
    elseif force:character_list():num_items() == 2 then
        context.event.weight = 15
    elseif force:character_list():num_items() == 3 then
        context.event.weight = 5
    end

    return true
end

function pttg_AgentRecruit_callback(context)
	-- body of the callback; what should happen for each choice?
    local choice = context:choice_key()

    local force = cm:get_military_force_by_cqi(pttg:get_state('army_cqi'))
    local cursor = pttg:get_cursor()
    local level = math.round(0.6 * cursor.y + (12 * (cursor.z - 1)))
    -- TODO: add prices per agent
	if choice == 'FIRST' then -- a Champion
        pttg_side_effects:add_agent_to_force(pttg_merc_pool:get_random_agent(cm:get_local_faction_name(), {'champion'}), level, force)
	end
    if choice == 'SECOND' then -- a Dignitary
        pttg_side_effects:add_agent_to_force(pttg_merc_pool:get_random_agent(cm:get_local_faction_name(), {'dignitary'}), level, force)
    end
    if choice == 'THIRD' then -- an Engineer
        pttg_side_effects:add_agent_to_force(pttg_merc_pool:get_random_agent(cm:get_local_faction_name(), {'engineer'}), level, force)
    end
    if choice == 'FOURTH' then -- a Runesmith
        pttg_side_effects:add_agent_to_force(pttg_merc_pool:get_random_agent(cm:get_local_faction_name(), {'runesmith'}), level, force)
    end
    if choice == 'FIFTH' then -- a Spy
        pttg_side_effects:add_agent_to_force(pttg_merc_pool:get_random_agent(cm:get_local_faction_name(), {'spy'}), level, force)
    end
	if choice == 'SIXTH' then -- a Wizard
        pttg_side_effects:add_agent_to_force(pttg_merc_pool:get_random_agent(cm:get_local_faction_name(), {'wizard'}), level, force)
	end
	if choice == 'EIGhTH' then -- Illegible
        -- TODO: make this something cool. Unique hero perhaps?
        local factions = cm:model():world():faction_list()
        local random_faction = factions:item_at(cm:random_number(factions:num_items()-1, 0))
        pttg_side_effects:add_agent_to_force(pttg_merc_pool:get_random_agent(random_faction:name(), 'random'), level, force)
	end
end

function pttg_ogres_feast_angry_callback(context)
	-- body of the callback; what should happen for each choice?

end

function pttg_ogres_feast_angry_eligibility_callback(context)
    return false
end

function pttg_ogres_feast_departure_callback(context)
	-- body of the callback; what should happen for each choice?

end

function pttg_ogres_feast_departure_eligibility_callback(context)
	return false
end

function pttg_protect_the_caravan_callback(context)
	-- body of the callback; what should happen for each choice?
    local choice = context:choice_key()

	if choice == 'SECOND' then -- Betray them
        local cursor = pttg:get_cursor()

        local player_faction = cm:get_local_faction()

        local enemy_faction = player_faction:culture() .. "_qb1"

        if player_faction:culture() == "wh2_dlc09_tmb_tomb_kings" then
            enemy_faction = "wh2_dlc09_tmb_tombking_qb1"

        elseif player_faction:culture() == "wh_dlc08_nor_norsca" then
            enemy_faction = "wh_main_nor_norsca_qb1"
        end

        local invasion_template_army = PttG_ArmyTemplate:new(
            "tmp_caravan_"..player_faction:culture(), 
            {
                faction = enemy_faction, 
                culture = player_faction:culture(), 
                subculture = player_faction:subculture(), 
                mandatory_units = {}, 
                units = {}, 
                alignment = 'neutral', 
                act = nil 
            }    
        )

        
        if not invasion_template_army then
            script_error("Could not create army template")
            return
        end

        pttg_battle_templates:add_custom_template(invasion_template_army, true)

        local invasion_template = invasion_template_army.key
        local invasion_faction = invasion_template_army.faction

        local invasion_power = 2 + (cursor.z - 1) * 2 + pttg:get_difficulty_mod('ai_army_power_mod')         
        local invasion_size = ((cursor.z - 1) * 12) + cursor.y + pttg:get_difficulty_mod('encounter_size')   
        local general_level = (cursor.z - 1) * 20 + cursor.y
        local invasion_chevrons = (cursor.z - 1) * 2 + (math.floor(cursor.y / 2) * cursor.z)

        pttg:log(string.format("[battle_event] Generating a battle with power: %i of size: %i against %s(%s)",
            invasion_power, invasion_size, invasion_faction, invasion_template))

        Forced_Battle_Manager:pttg_trigger_forced_battle_with_generated_army(
            pttg:get_state('army_cqi'),             --	target_force_cqi
            invasion_faction,                       --	generated_force_faction
            invasion_template,                      --	generated_force_template
            invasion_size,                          --	generated_force_size
            invasion_power,                         --	generated_force_power
            false,                                  --	generated_force_is_attacker
            true,                                   --	destroy_generated_force_after_battle
            false,                                  --	is_ambush
            "pttg_caravan_betrayal_victory",        --	opt_player_victory_incident
            "pttg_battle_defeat",                   --	opt_player_defeat_incident
            invasion_template_army.general_subtype, --	opt_general_subtype
            general_level,                          --	opt_general_level
            invasion_template_army.agents,
            invasion_chevrons,
            nil                                     --	opt_effect_bundle
        )
	end
	if choice == 'FOURTH' then -- Loot the scraps
        cm:trigger_incident(cm:get_local_faction_name(), "pttg_caravan_ambush_scraps", true)
	end
	if choice == 'THIRD' then -- Slay them all
        local pttg = core:get_static_object("pttg");
        local pttg_glory = core:get_static_object("pttg_glory")
        local pttg_merc_pool = core:get_static_object("pttg_merc_pool")
        local pttg_side_effects = core:get_static_object("pttg_side_effects")
        local pttg_events = core:get_static_object("pttg_event_pool")
        local pttg_battle_templates = core:get_static_object("pttg_battle_templates");        local cursor = pttg:get_cursor()

        local player_faction = cm:get_local_faction()

        local enemy_faction = player_faction:culture() .. "_qb1"

        if player_faction:culture() == "wh2_dlc09_tmb_tomb_kings" then
            enemy_faction = "wh2_dlc09_tmb_tombking_qb1"

        elseif player_faction:culture() == "wh_dlc08_nor_norsca" then
            enemy_faction = "wh_main_nor_norsca_qb1"
        end

        local invasion_template_army = PttG_ArmyTemplate:new(
            "tmp_caravan_"..player_faction:culture(), 
            {
                faction = enemy_faction, 
                culture = player_faction:culture(), 
                subculture = player_faction:subculture(), 
                mandatory_units = {}, 
                units = {}, 
                alignment = 'neutral', 
                act = nil 
            }    
        )

        if not invasion_template_army then
            script_error("Could not create army template")
            return
        end
        pttg_battle_templates:add_custom_template(invasion_template_army, true)

        local invasion_template = invasion_template_army.key

        local invasion_power = 2 + (cursor.z - 1) * 2 + pttg:get_difficulty_mod('ai_army_power_mod')         


        local generated_force = WH_Random_Army_Generator:generate_random_army('temp_caravan_army', invasion_template, 6, invasion_power, true, true)
        local generated_units = {}
        for _, unit in pairs(generated_force) do
            table.insert(generated_units, pttg_merc_pool.merc_units[unit])
        end


        local invasion_template_army = pttg_battle_templates:get_random_battle_template(cursor.z)

        
        if not invasion_template_army then
            script_error("Could not get army template")
            return
        end

        invasion_template_army.mandatory_units = generated_units
        invasion_template_army.agents = pttg_merc_pool:get_random_agent(player_faction:name()).subtype
        
        local invasion_template = invasion_template_army.key
        local invasion_faction = invasion_template_army.faction

        local invasion_power = (cursor.z - 1) * 2 + 3 + pttg:get_difficulty_mod('ai_army_power_mod')
        local general_level = (cursor.z - 1) * 20 + cursor.y + 5

        local invasion_chevrons = (cursor.z - 1) * 2 + (math.floor(cursor.y / 2) * cursor.z)

        pttg:log(string.format("[battle_event] Generating a battle with power: %i of size: %i against %s(%s)",
            invasion_power, 20, invasion_faction, invasion_template))

        Forced_Battle_Manager:pttg_trigger_forced_battle_with_generated_army(
            pttg:get_state('army_cqi'),             --	target_force_cqi
            invasion_faction,                       --	generated_force_faction
            invasion_template,                      --	generated_force_template
            18,                                     --	generated_force_size
            invasion_power,                         --	generated_force_power
            false,                                  --	generated_force_is_attacker
            true,                                   --	destroy_generated_force_after_battle
            false,                                  --	is_ambush
            "pttg_caravan_saviour_victory",        --	opt_player_victory_incident
            "pttg_battle_defeat",                   --	opt_player_defeat_incident
            invasion_template_army.general_subtype, --	opt_general_subtype
            general_level,                          --	opt_general_level
            invasion_template_army.agents,
            invasion_chevrons,
            nil                                     --	opt_effect_bundle
        )
	end
	if choice == 'FIRST' then -- Save them
        local cursor = pttg:get_cursor()


        local invasion_template_army = pttg_battle_templates:get_random_battle_template(cursor.z)

        if not invasion_template_army then
            script_error("Could not get army template")
            return
        end
        
        local invasion_template = invasion_template_army.key
        local invasion_faction = invasion_template_army.faction

        local invasion_power = (cursor.z - 1) * 2 + 3 + pttg:get_difficulty_mod('ai_army_power_mod')
        local invasion_size = ((cursor.z - 1) * 7) + cursor.y + pttg:get_difficulty_mod('encounter_size')
        local general_level = (cursor.z - 1) * 20 + cursor.y + 5

        local invasion_chevrons = (cursor.z - 1) * 2 + (math.floor(cursor.y / 2) * cursor.z)

        pttg:log(string.format("[battle_event] Generating a battle with power: %i of size: %i against %s(%s)",
            invasion_power, invasion_size, invasion_faction, invasion_template))

        Forced_Battle_Manager:pttg_trigger_forced_battle_with_generated_army(
            pttg:get_state('army_cqi'),             --	target_force_cqi
            invasion_faction,                       --	generated_force_faction
            invasion_template,                      --	generated_force_template
            invasion_size,                          --	generated_force_size
            invasion_power,                         --	generated_force_power
            false,                                  --	generated_force_is_attacker
            true,                                   --	destroy_generated_force_after_battle
            false,                                  --	is_ambush
            "pttg_caravan_saviour_victory",        --	opt_player_victory_incident
            "pttg_battle_defeat",                   --	opt_player_defeat_incident
            invasion_template_army.general_subtype, --	opt_general_subtype
            general_level,                          --	opt_general_level
            invasion_template_army.agents,
            invasion_chevrons,
            nil                                     --	opt_effect_bundle
        )
	end
end

function pttg_protect_the_caravan_eligibility_callback(context)
    return true
end

function pttg_ogre_feast_callback(context)
	-- body of the callback; what should happen for each choice?
    local choice = context:choice_key()

	if choice == 'SECOND' then -- Respectfully decline

	end
	if choice == 'FIRST' then -- Accept the invitation
        core:add_listener(
            "pttg_ogre_feasting",
            "DilemmaChoiceMadeEvent",
            function(context)
                return context:dilemma() == "pttg_ogre_feast_1"
            end,
            pttg_ogre_feast_1_callback,
            false
        )
        cm:callback(
            function() cm:trigger_dilemma(cm:get_local_faction_name(), "pttg_ogre_feast_1") end,
            0.4
        )
	end
end

function pttg_ogre_feast_eligibility_callback(context)   
    if context.act < 2 then
        return false
    end

    if context.alignment > 100 then
        return false
    end

    local faction_set='all' -- Allows to restrict the event to specific factions
    if not context.faction:is_contained_in_faction_set(faction_set) then
        return false
    end

    return true
end

function pttg_ogre_feast_1_callback(context)
	-- body of the callback; what should happen for each choice?
    local choice = context:choice_key()
    cm:force_add_trait(cm:char_lookup_str(cm:get_military_force_by_cqi(pttg:get_state('army_cqi')):general_character()), "pttg_ogre_feast", true, 1)

	if choice == 'SECOND' then -- Time to go

        core:add_listener(
            "pttg_ogres_angry",
            "IncidentOccuredEvent",
            function(context)
                return context:dilemma() == "pttg_ogres_feast_angry"
            end,
            function(context)
                pttg_ogres_feast_angry_callback(context)
            end,
            false
        )
        cm:callback(
            function() cm:trigger_incident(cm:get_local_faction_name(), "pttg_ogres_feast_angry", true) end,
            0.4
        )
        
	end

	if choice == 'FIRST' then -- Yes!       
        local force = cm:get_military_force_by_cqi(pttg:get_state('army_cqi'))
        local character_cco = cco("CcoCampaignCharacter", force:general_character():command_queue_index())
        local char_count = force:character_list():num_items()
        local unit_count = force:unit_list():num_items()
        
        character_cco:Call("MilitaryForceContext.UnitList["..tostring(cm:random_number(unit_count-1, char_count)).."].Disband")
       

        if force:unit_list():num_items() - force:character_list():num_items() == 0 then
            cm:callback(
                function() cm:trigger_incident(cm:get_local_faction_name(), "pttg_ogres_feast_no_more_food", true) end,
                0.4
            )
        else
            core:add_listener(
                "pttg_ogre_feasting",
                "DilemmaChoiceMadeEvent",
                function(context)
                    return context:dilemma() == "pttg_ogre_feast_2"
                end,
                pttg_ogre_feast_2_callback,
                false
            )
            cm:callback(
                function() cm:trigger_dilemma(cm:get_local_faction_name(), "pttg_ogre_feast_2") end,
                0.4
            )
        end
	end
end

function pttg_ogre_feast_2_callback(context)
	-- body of the callback; what should happen for each choice?
    local choice = context:choice_key()

    cm:force_add_trait(cm:char_lookup_str(cm:get_military_force_by_cqi(pttg:get_state('army_cqi')):general_character()), "pttg_ogre_feast", true, 1)

	if choice == 'SECOND' then -- Resist
        cm:trigger_incident(cm:get_local_faction_name(), "pttg_ogres_feast_departure", true)
	end

	if choice == 'FIRST' then -- More!
        local force = cm:get_military_force_by_cqi(pttg:get_state('army_cqi'))
        local character_cco = cco("CcoCampaignCharacter", force:general_character():command_queue_index())
        local char_count = force:character_list():num_items()
        local unit_count = force:unit_list():num_items()
        
        character_cco:Call("MilitaryForceContext.UnitList["..tostring(cm:random_number(unit_count-1, char_count)).."].Disband")

        if force:unit_list():num_items() - force:character_list():num_items() == 0 then
            cm:callback(
                function() cm:trigger_incident(cm:get_local_faction_name(), "pttg_ogres_feast_no_more_food", true) end,
                0.4
            )
        else
            core:add_listener(
                "pttg_ogre_feating",
                "DilemmaChoiceMadeEvent",
                function(context)
                    return context:dilemma() == "pttg_ogre_feast_2"
                end,
                pttg_ogre_feast_2_callback,
                false
            )
            cm:callback(
                function() cm:trigger_dilemma(cm:get_local_faction_name(), "pttg_ogre_feast_2") end,
                0.4
            )
        end
	end
end

function pttg_slaanesh_tempation_callback(context)
	-- body of the callback; what should happen for each choice?
    local choice = context:choice_key()

    -- TODO: add a followup event

	if choice == 'SECOND' then -- Wealth beyond recognition
        pttg_glory:reward_glory(10000)
        pttg:set_state("shop_sizes", { merchandise = 0, units = pttg:get_state("shop_sizes").units })
	end
	if choice == 'THIRD' then -- None of this
	end
	if choice == 'FIRST' then -- Just the wares, please.
        local pttg_glory_shop = core:get_static_object("pttg_glory_shop")
        pttg_glory_shop:enable_shop_button()
        pttg_glory_shop:populate_shop_custom({ merchandise = 6, units = 0 }, { 0, 0, 50, 100 }, {0, 0, 0})  
        local chances = pttg:get_state("shop_chances")
        chances[1] = 30
        chances[2] = 100
        pttg:set_state("shop_chances", chances)
	end
end

function pttg_slaanesh_tempation_eligibility_callback(context)
    return true
end

function pttg_tzeentch_changer_callback(context)
	-- body of the callback; what should happen for each choice?
    local choice = context:choice_key()

    -- TODO: add negatives
    -- TODO: add followups

	if choice == 'SECOND' then -- Exchange for Protective Magics 
        cm:apply_effect_bundle_to_force("pttg_tze_barrier", pttg:get_state('army_cqi'), -1)

        -- TODO: add deceiver reduce stats??
	end
	if choice == 'THIRD' then -- Send them on their way

	end
	if choice == 'FIRST' then -- Exchange for Arcane Knowledge
        local force = cm:get_military_force_by_cqi(pttg:get_state('army_cqi'))

        for i = 0, force:character_list():num_items() do
            local character = force:character_list():item_at(i)
            cm:force_add_trait(cm:char_lookup_str(character), "pttg_spell_mastery", true, 2)
        end

        -- TODO: add deceiver follow-up: Random Spells Cast

        pttg:set_state("wom_efficiency", pttg:get_state("wom_efficiency") + 25)
	end
end

function pttg_tzeentch_changer_eligibility_callback(context)
	-- TODO: implement body of the callback; when is this event eligible for the player? e.g. acts, alignment, faction_set
    
    if context.act < 2 then -- only triggers in act 1
        return false
    end

    -- Only triggers if the player has a chaotic alignment (greater than 20), but not too chaotic (less than 100)
    if context.alignment < 100 then
        return false
    end

    local faction_set='all' -- Allows to restrict the event to specific factions
    if not context.faction:is_contained_in_faction_set(faction_set) then
        return false
    end

    -- add in any restrictions you would like!
    return true
end

function pttg_khorne_pledge_callback(context)
	-- body of the callback; what should happen for each choice?
    local choice = context:choice_key()


	if choice == 'SECOND' then -- Refute the brute
        -- TODO: add khorne army templates
        cm:force_add_trait(cm:char_lookup_str(cm:get_military_force_by_cqi(pttg:get_state('army_cqi')):general_character()), "pttg_khorne_scorned", true, 1)

	end
	if choice == 'THIRD' then -- Come to your senses

	end
	if choice == 'FIRST' then -- Pledge yourself to bloodshed
        cm:force_add_trait(cm:char_lookup_str(cm:get_military_force_by_cqi(pttg:get_state('army_cqi')):general_character()), "pttg_khorne_pledge", true, 1)
        -- TODO: add follow up with damage check after battles
        
	end
end

function pttg_khorne_pledge_eligibility_callback(context)
	-- TODO: implement body of the callback; when is this event eligible for the player? e.g. acts, alignment, faction_set
    
    if context.act ~= 1 then -- only triggers in act 1
        return false
    end

    -- Only triggers if the player has a chaotic alignment (greater than 20), but not too chaotic (less than 100)
    if context.alignment < 100 then
        return false
    end

    local faction_set='all' -- Allows to restrict the event to specific factions
    if not context.faction:is_contained_in_faction_set(faction_set) then
        return false
    end

    -- add in any restrictions you would like!
    return true
end

function pttg_nurgle_maze_found_callback(context)
	-- body of the callback; what should happen for each choice?
    --TODO: add followup rare event. Replace army with nurgle demons if not nurgle army... 'Nurgle's Harvest'
    cm:force_add_trait(cm:char_lookup_str(cm:get_military_force_by_cqi(pttg:get_state('army_cqi')):general_character()), "pttg_nurgle_botanist", true, 1)
end

function pttg_nurgle_maze_callback(context)
	-- body of the callback; what should happen for each choice?
    local choice = context:choice_key()

	if choice == 'SECOND' then -- Fan out
        -- TODO: improve plague effects
        local plagues = {
            "wh3_dlc25_nur_random_plague_1",
            "wh3_dlc25_nur_random_plague_2",
            "wh3_dlc25_nur_random_plague_3",
            "wh3_dlc25_nur_random_plague_4",
            "wh3_dlc25_nur_random_plague_5",
        }
        local selected_plague = plagues[cm:random_number(#plagues)]

        local faction = cm:get_faction("wh3_main_nur_nurgle_qb1")
        local force = cm:get_military_force_by_cqi(pttg:get_state("army_cqi"))

        ---@diagnostic disable-next-line: param-type-mismatch, redundant-parameter
        cm:spawn_plague_at_military_force(faction, force, selected_plague);


        pttg_side_effects:attrition_force(0.07, false)

        core:add_listener(
            "pttg_nurgle_maze_searching",
            "DilemmaChoiceMadeEvent",
            function(context)
                return context:dilemma() == "pttg_nurgle_maze_1"
            end,
            pttg_nurgle_maze_1_callback,
            false
        )

        cm:callback(
            function() cm:trigger_dilemma(cm:get_local_faction_name(), "pttg_nurgle_maze_1") end,
            0.4
        )
	end
	if choice == 'THIRD' then -- Turn around

	end
	if choice == 'FIRST' then -- Go in alone
        -- Upgrade general into a different one
        -- give some nurgle love
        -- TODO: let player choose an agent type instead of random one.
        local factions = {}

        for faction, _ in pairs(pttg_merc_pool.faction_to_agents) do
            table.insert(factions, faction)
        end

        local random_general = pttg_merc_pool:get_random_general(factions[cm:random_number(#factions)])
        CUS:convert_character(cm:get_military_force_by_cqi(pttg:get_state('army_cqi')):general_character(), "general", random_general.subtype, 1)
        cm:force_add_trait(cm:char_lookup_str(cm:get_military_force_by_cqi(pttg:get_state('army_cqi')):general_character()), "pttg_nurgle_transformation", true, 1)

        cm:callback(
            function() cm:trigger_incident(cm:get_local_faction_name(), "pttg_nurgle_maze_transformed") end,
            0.4
        )
	end
end

function pttg_nurgle_maze_eligibility_callback(context)
	-- TODO: implement body of the callback; when is this event eligible for the player? e.g. acts, alignment, faction_set
    
    if context.act == 3 then 
        return false
    end

    for _, faction_set in pairs({"anc_set_exclusive_vampire_counts", "anc_set_multi_tomb_kings_vampire_coast"}) do
        if context.faction:is_contained_in_faction_set(faction_set) then
            return false
        end
    end

    -- add in any restrictions you would like!
    return true
end

function pttg_nurgle_maze_1_callback(context)
	-- body of the callback; what should happen for each choice?
    local choice = context:choice_key()

    pttg_side_effects:attrition_force(0.07, false)

	if choice == 'SECOND' then -- Turn back

	end
	if choice == 'FIRST' then -- Continue the search

        if cm:random_number(7) == 7 then
            core:add_listener(
                "pttg_nurgle_secret_found",
                "DilemmaChoiceMadeEvent",
                function(context)
                    return context:dilemma() == "pttg_nurgle_maze_found"
                end,
                pttg_nurgle_maze_found_callback,
                false
            )

            cm:callback(
                function() cm:trigger_incident(cm:get_local_faction_name(), "pttg_nurgle_maze_found") end,
                0.4
            )
            return
        end

        core:add_listener(
            "pttg_ogre_feating",
            "DilemmaChoiceMadeEvent",
            function(context)
                return context:dilemma() == "pttg_nurgle_maze_1"
            end,
            pttg_nurgle_maze_1_callback,
            false
        )

        cm:callback(
            function() cm:trigger_dilemma(cm:get_local_faction_name(), "pttg_nurgle_maze_1") end,
            0.4
        )

	end
end

-- Dark Elf/Vampirates event that adds army abilities
-- 