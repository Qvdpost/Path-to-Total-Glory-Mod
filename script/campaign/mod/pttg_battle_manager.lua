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

    -- TODO: cleaner check for effect bundle interface
	if new_force.effect_bundle ~= nil and not (is_string(new_force.effect_bundle) or (new_force.effect_bundle.is_null_interface and not new_force.effect_bundle:is_null_interface())) then
		script_error("ERROR: Forced Battle Manager: new forced battle force "..force_key.." has been given an effect_bundle parameter, but parameter is not a string or a valid interface")
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

---- Internal - Function called when the force of the invasion is spawned
function invasion:force_created(general_cqi, declare_war, invite_attacker_allies, invite_defender_allies, was_respawn)
	self.general_cqi = general_cqi;
	self.declare_war = declare_war;
	self.invite_attacker_allies = invite_attacker_allies;
	self.invite_defender_allies = invite_defender_allies;
	
	if was_respawn == nil then
		was_respawn = false;
	end
	
	if self.target_type ~= "NONE" then
		cm:cai_disable_movement_for_character("character_cqi:"..general_cqi);
		
		if self.target_type == "PATROL" then
			self.patrol_position = 1;
		end
	end
	
	if self.immortal_general ~= nil then
		out.invasions("\t\tMaking Character Immortal: "..tostring(self.immortal_general));
		cm:set_character_immortality("character_cqi:"..general_cqi, self.immortal_general);
	end
	
	local force = cm:force_from_general_cqi(general_cqi);
	
	if force then
		self.force_cqi = force:command_queue_index();
	end
	
	out.invasions("\t\tForce Spawned (General CQI: "..tostring(general_cqi)..", Force CQI: "..tostring(self.force_cqi)..", Invasion: "..tostring(self.key)..")");
	
	self.turn_spawned = cm:model():turn_number();
	
	if self.callback ~= nil and type(self.callback) == "function" then
		self.callback(self);
	end
	
	if #self.effect > 0 then
		self:apply_effect();
	end

    if #self.custom_effect > 0 then
		self:apply_custom_effect();
	end
	
	if self.experience_amount then
		self:add_character_experience();
	end
	
	if self.unit_experience_amount then
		self:add_unit_experience();
	end
	
	if self.target_faction ~= nil then
		local this_faction = cm:get_faction(self.faction);
		local enemy_faction = cm:get_faction(self.target_faction);
		
		if this_faction and enemy_faction then
			if this_faction:at_war_with(enemy_faction) == false then
				if declare_war == true then
					if this_faction:is_vassal() then
						cm:force_declare_war(this_faction:master():name(), self.target_faction, invite_attacker_allies, invite_defender_allies);
					else
						cm:force_declare_war(self.faction, self.target_faction, invite_attacker_allies, invite_defender_allies);
					end
					
					out.invasions("\t\t\tDeclared war on "..tostring(self.target_faction));
				end
			end
		end
	end
	
	if was_respawn == true then
		self.respawn_turn = 0;
		
		if self.respawn_count and self.respawn_count > -1 then
			self.respawn_count = self.respawn_count - 1;
			
			if self.respawn_count == 0 then
				self.respawn = false;
				self.respawn_delay = nil;
				self.respawn_turn = nil;
			end
		end
		core:trigger_event("ScriptEventInvasionManagerRespawn", cm:get_character_by_cqi(general_cqi));
	end
end

--- @function apply_custom_effect
--- @desc Allows you to apply a custom effect bundle to the forces in this invasion
--- @p string effect_key, The key of the effect bundle
--- @p number turns, The turns the effect bundle will be applied for after the invasion is started
function invasion:apply_custom_effect(effect)
	if not effect then
		for i = 1, #self.custom_effect do
			out.invasions("Invasion: Applying stored custom effect '"..self.custom_effect[i]:key().."' ("..self.custom_effect[i]:duration()..") to force "..self.force_cqi);
			cm:apply_custom_effect_bundle_to_force(self.custom_effect[i], cm:get_military_force_by_cqi(self.force_cqi));
		end;
	elseif self.started then
		out.invasions("Invasion: Applying custom effect '"..effect:key().."' ("..effect:duration()..") to force "..self.force_cqi);
        cm:apply_custom_effect_bundle_to_force(effect, cm:get_military_force_by_cqi(self.force_cqi));
	else
        if not self.custom_effect then
            self.custom_effect = {}
        end
		out.invasions("Invasion: Preparing custom effect '"..effect:key().."' ("..effect:duration()..")");
		table.insert(self.custom_effect, effect);
	end
end

function forced_battle:spawn_generated_force(force_key, x, y)
	local force = self.force_list[force_key]
	
	local new_x,new_y = cm:find_valid_spawn_location_for_character_from_position(force.faction_key,x,y,true,7)

	---remove any invasions with the same key just in case
	invasion_manager:remove_invasion(force.key)

	self.invasion_key = force.key..new_x..new_y

	local forced_battle_force = invasion_manager:new_invasion(force.key,force.faction_key, force.unit_list,{new_x, new_y})
	if force.general_subtype ~= nil then
		forced_battle_force:create_general(false, force.general_subtype)
	end
	if force.general_level ~= nil then
		forced_battle_force:add_character_experience(force.general_level, true)
	end

	if force.effect_bundle ~=nil then
		local bundle_duration = -1
        if is_string(force.effect_bundle) then
		    forced_battle_force:apply_effect(force.effect_bundle, bundle_duration)
        else
            forced_battle_force:apply_custom_effect(force.effect_bundle, bundle_duration)
        end
	end

	--- here we target the spawned invasion at the force they're attacking, if it already exists, otherwise it'll just mooch around post-battle
	local invasion_target_cqi
	local invasion_target_faction_key

	if self.target.is_existing then
		invasion_target_cqi = cm:get_character_by_mf_cqi(self.target.cqi):command_queue_index()
		invasion_target_faction_key = cm:get_character_by_mf_cqi(self.target.cqi):faction():name()
	end

	if self.attacker.is_existing then
		invasion_target_cqi = cm:get_character_by_mf_cqi(self.attacker.cqi):command_queue_index()
		invasion_target_faction_key = cm:get_character_by_mf_cqi(self.attacker.cqi):faction():name()
	end

	if self.target.existing or self.attacker.is_existing then
		forced_battle_force:set_target("CHARACTER", invasion_target_cqi, invasion_target_faction_key)
		forced_battle_force:add_aggro_radius(25, {invasion_target_faction_key}, 1)
	end

	forced_battle_force:start_invasion(
		function()
			self:forced_battle_stage_2(self)
		end,
		false,false,false)
	force.spawned = true
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

    local general_level = generated_force:general_character():rank()
    for _, agent in pairs(force.agents or {}) do
        pttg:log(string.format("Adding agent %s to spawned force.", agent.key))
        local character = pttg_side_effects:add_agent_to_force(agent, general_level, generated_force)

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