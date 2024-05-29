local pttg = core:get_static_object("pttg");
local pttg_merc_pool = core:get_static_object("pttg_merc_pool")
local pttg_side_effects = core:get_static_object("pttg_side_effects")



function Forced_Battle_Manager:pttg_trigger_forced_battle_with_generated_army(
    target_force_cqi,
    generated_force_faction,
    generated_force_template,
    generated_force_size,
    generated_force_power,
    generated_force_is_attacker,
    destroy_generated_force_after_battle,
    is_ambush,
    opt_player_victory_incident,
    opt_player_defeat_incident,
    opt_general_subtype,
    opt_general_level,
    opt_agents,
    opt_chevrons,
    opt_effect_bundle,
    opt_player_is_generated_force
)
    pttg:log("[trigger_forced_battle] Forced battle against " .. generated_force_template)
    local forced_battle_key = generated_force_template .. "_forced_battle"
    local forced_battle = Forced_Battle_Manager:setup_new_battle(forced_battle_key)

    
    local agents = {}
    for _, agent in pairs(opt_agents) do 
        if agent == 'random' then
            local agent_info = pttg_merc_pool:get_random_agent(generated_force_faction)
            pttg:log("Adding random agent of type: "..agent_info.key)
            table.insert(agents, agent_info)
        elseif type(agent) == 'table' then
            local agent_info = pttg_merc_pool:get_random_agent(generated_force_faction, agent)
            pttg:log("Adding random agent of type: "..agent_info.key)
            table.insert(agents, agent_info)
        elseif pttg_merc_pool.agents[agent] then
            pttg:log("Adding random agent of type: "..pttg_merc_pool.agents[agent].key)
            table.insert(agents, pttg_merc_pool.agents[agent])
        else
            script_error("Could not add agent. Agent does not exist: "..agent)
        end
    end
    
    generated_force_size = generated_force_size - #agents
    local generated_force = WH_Random_Army_Generator:generate_random_army(forced_battle_key, generated_force_template,
        generated_force_size, generated_force_power, true, false)


    forced_battle:add_new_force(forced_battle_key, generated_force, generated_force_faction,
        destroy_generated_force_after_battle, opt_effect_bundle, opt_general_subtype, opt_general_level, agents, opt_chevrons)

    local attacker = target_force_cqi
    local defender = forced_battle_key
    local attacker_victory_incident = opt_player_victory_incident
    local defender_victory_incident = opt_player_defeat_incident

    if generated_force_is_attacker then
        defender = target_force_cqi
        attacker = forced_battle_key
        attacker_victory_incident = opt_player_defeat_incident
        defender_victory_incident = opt_player_victory_incident
    end

    local opt_player_is_generated_force = opt_player_is_generated_force or nil
    if opt_player_is_generated_force then
        cm:disable_event_feed_events(true, "wh_event_category_character", "", "")
    end

    if attacker_victory_incident ~= nil then
        forced_battle:add_post_battle_event("incident", attacker_victory_incident, "attacker_victory")
    end

    if defender_victory_incident ~= nil then
        forced_battle:add_post_battle_event("incident", defender_victory_incident, "defender_victory")
    end

    if not cm:get_character_by_mf_cqi(target_force_cqi) then
        script_error(
            "Error: trying to create a new forced battle, but supplied force CQI doesn't seem to have an associated general")
        return false
    end

    local player_force_general_cqi = cm:get_character_by_mf_cqi(target_force_cqi):command_queue_index()
    local x, y = cm:find_valid_spawn_location_for_character_from_character(generated_force_faction,
        "character_cqi:" .. player_force_general_cqi, false, 6)

    pttg:log(string.format("[trigger_forced_battle] Forced battle spawned at %i,%i.", x, y))

    ---@diagnostic disable-next-line: param-type-mismatch
    forced_battle:trigger_battle(attacker, defender, x, y, is_ambush)
end

function forced_battle:add_new_force(force_key, unit_list, faction_key, destroy_after_battle, opt_effect_bundle,opt_general_subtype,opt_general_level, opt_agents, opt_chevrons)
	local force_list = self.force_list
	
	if not is_string(force_key) then
		script_error("ERROR: Forced Battle Manager: Trying to add a new force to forced battle"..self.key.." but provided force key is not a string!")
		return false
	end

	if force_list[force_key] ~= nil then
		script_error("ERROR: Forced Battle Manager: Forced Battle with key [" .. force_key .. "] already exists!");
		return false;
	end

	local new_force = {}
	new_force.key = force_key


	if not is_string(faction_key) then
		script_error("ERROR: Forced Battle Manager: Trying to assign a faction to force"..force_key.." for forced battle "..self.key.." but provided faction_key is not a string!")
		return false
	end
	if cm:get_faction(faction_key) == false then
		script_error("ERROR: Forced Battle Manager: Trying to assign a faction with string"..faction_key.." to force"..force_key.." for forced battle "..self.key.." but this faction_doesn't exist")
		return false
	end

	new_force.faction_key = faction_key

	new_force.destroy_after_battle = destroy_after_battle

	if not is_boolean(new_force.destroy_after_battle) then
		script_error("ERROR: Forced Battle Manager: new forced battle force "..force_key.." destroy_after battle is not a bool")
		return false
	end

	new_force.effect_bundle = opt_effect_bundle or nil

	if new_force.effect_bundle ~= nil and not is_string(new_force.effect_bundle) then
		script_error("ERROR: Forced Battle Manager: new forced battle force "..force_key.." has been given an effect_bundle parameter, but parameter is not a string")
		return false
	end

	new_force.general_subtype = opt_general_subtype or nil

	if new_force.general_subtype  ~= nil and not is_string(new_force.general_subtype ) then
		script_error("ERROR: Forced Battle Manager: new forced battle force "..force_key.." has been given an general_subtype parameter, but parameter is not a string")
		return false
	end

	new_force.general_level = opt_general_level or nil

	if new_force.general_level  ~= nil and not is_number(new_force.general_level) then
		script_error("ERROR: Forced Battle Manager: new forced battle force "..force_key.." has been given an general_level parameter, but parameter is not a string")
		return false
	end

    new_force.agents = opt_agents or nil

    if new_force.agents ~= nil and not is_table(new_force.agents) then
        script_error("ERROR: Forced Battle Manager: new forced battle force "..force_key.." has been given an agents parameter, but parameter is not a table")
		return false
    end

    new_force.chevrons = opt_chevrons or 0

    if new_force.chevrons ~= 0 and not is_number(new_force.chevrons) then
        script_error("ERROR: Forced Battle Manager: new forced battle force "..force_key.." has been given a chevrons parameter, but parameter is not a number")
		return false
    end

	new_force.unit_list = unit_list

	force_list[force_key]= new_force
end

function forced_battle:forced_battle_stage_2()
    --- if we spawned the forces, we don't have CQIs or interfaces for them, so get them here using the invasion keys assigned earlier
    local attacker_invasion_object
    local attacker_force
    local attacker_faction
    local target_invasion_object
    local target_force
    local target_faction

    if(self.attacker.force_key) then
        attacker_invasion_object = invasion_manager:get_invasion(self.attacker.force_key)
        attacker_force = attacker_invasion_object:get_force()
        attacker_faction = attacker_force:faction()
        self.attacker.cqi = attacker_force:command_queue_index()
    else
        attacker_force = cm:get_military_force_by_cqi(self.attacker.cqi)
        attacker_faction = attacker_force:faction()
    end

    if(self.target.force_key) then
        target_invasion_object = invasion_manager:get_invasion(self.target.force_key)
        target_force = target_invasion_object:get_force()
        target_faction = target_force:faction()
        self.target.cqi = target_force:command_queue_index()
    else
        target_force = cm:get_military_force_by_cqi(self.target.cqi)
        target_faction = target_force:faction()
    end

    local force
    local generated_force
    if cm:get_local_faction_name() == attacker_faction:name() then
        force = self.force_list[self.target.force_key]
        generated_force = target_force
    else 
        force = self.force_list[self.attacker.force_key]
        generated_force = attacker_force
    end


    for _, agent in pairs(force.agents or {}) do
        pttg:log(string.format("Adding agent %s to spawned force.", agent.key))
        local character = pttg_side_effects:add_agent_to_force(agent, generated_force)

        local agent_record = cco("CcoAgentSubtypeRecord", agent.key)

        local is_legend = (agent_record:Call("OnscreenNameOverride"):find("Legendary") ~= nil)
        pttg:log("Agent "..agent.key.." is legend: "..tostring(is_legend)..". Changing name to: ".. agent_record:Call("AssociatedUnitOverride.Name"))
        if is_legend then
            cm:change_character_custom_name(
                character,
                agent_record:Call("AssociatedUnitOverride.Name"),
                "",
                "",
                ""
            )
        end
    end

    pttg_side_effects:grant_characters_levels(force.general_level, generated_force)

    pttg_side_effects:grant_units_chevrons(force.chevrons, generated_force)

    -- change name of general if they are unique
    local general_record = cco("CcoAgentSubtypeRecord", generated_force:general_character():character_subtype_key())

    local is_legend = (general_record:Call("OnscreenNameOverride"):find("Legendary") ~= nil)
    pttg:log("General "..generated_force:general_character():character_subtype_key().." is legend: "..tostring(is_legend)..". Changing name to: ".. general_record:Call("AssociatedUnitOverride.Name"))

    if is_legend then
        cm:change_character_custom_name(
           generated_force:general_character(),
           general_record:Call("AssociatedUnitOverride.Name"),
            "",
            "",
            ""
        )
    end

    

    -- can't ambush a garrisoned force
    if target_force:has_garrison_residence() then
        self.is_ambush = false
    end
    
    -- lock the retreat button is if the attacker is in a stance that can't retreat - if they try to they instantly die.
    if attacker_force:active_stance() == "MILITARY_FORCE_ACTIVE_STANCE_TYPE_DOUBLE_TIME" or attacker_force:active_stance() ==  "MILITARY_FORCE_ACTIVE_STANCE_TYPE_MARCH" then
        local uim = cm:get_campaign_ui_manager();
        uim:override("retreat"):lock();
    end

    ---declare war if needed. Can't use standard invasion manager behaviour here because it doesn't kick in in time for the attack
    if not attacker_faction:at_war_with(target_faction) then
        cm:disable_event_feed_events(true, "wh_event_category_diplomacy", "", "");
        cm:disable_event_feed_events(true, "wh_event_category_character", "", "");
        
        local callback_delay = 0.2
        cm:callback(function() cm:disable_event_feed_events(false, "wh_event_category_diplomacy", "", "") end, callback_delay);
        cm:callback(function() cm:disable_event_feed_events(false, "wh_event_category_character", "", "") end, callback_delay);
        
        core:add_listener(
        "FactionLeaderDeclaresWarInvasionFactionDeclaresWar",
        "FactionLeaderDeclaresWar",
        true,
            function()
                cm:force_attack_of_opportunity(self.attacker.cqi, self.target.cqi, self.is_ambush)
            end,
        false
        )

        self.attacker.faction = attacker_faction:name()
        
        cm:force_declare_war(attacker_faction:name(), target_faction:name(),false,false, false)
    else
         cm:force_attack_of_opportunity(self.attacker.cqi, self.target.cqi, self.is_ambush)
    end

end

function forced_battle:trigger_post_battle_events(attacker_victory)

	local event_type = ""
	local event_key = ""

	if attacker_victory and self.attacker_victory_event~= nil then
		event_type = self.attacker_victory_event.event_type
		event_key = self.attacker_victory_event.event_key
	elseif not attacker_victory and self.defender_victory_event ~= nil then
		event_type = self.defender_victory_event.event_type
		event_key = self.defender_victory_event.event_key
	else 
		-- supressing events here so that the player doesn't get a bunch of "faction/army destroyed events for an army they didn't even fight"
		local callback_delay = 0.2
		cm:disable_event_feed_events(true, "wh_event_category_diplomacy", "", "")
		cm:disable_event_feed_events(true, "wh_event_category_character", "", "")
		cm:callback(function() 
			cm:callback(function() cm:disable_event_feed_events(false, "wh_event_category_diplomacy", "", "") end, callback_delay)
			cm:callback(function() cm:disable_event_feed_events(false, "wh_event_category_character", "", "") end, callback_delay)
		end, callback_delay)
		return
	end

    -- NOTE: original used the self.attacker.faction exclusively which messes with swapping the roles.
	if event_type == "incident" then
        cm:trigger_incident(cm:get_local_faction_name(), event_key, true)
    elseif event_type == "dilemma" then
        cm:trigger_dilemma(cm:get_local_faction_name(), event_key)
    end
end