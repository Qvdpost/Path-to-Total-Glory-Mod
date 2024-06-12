local pttg = core:get_static_object("pttg");
local pttg_upkeep = core:get_static_object("pttg_upkeep")


local function init() 
    pttg:log("Greater Daemon Setup.")

    -- Greater Daemon Upgrade fixes
    greater_daemons.xp_preserved_on_conversion = 1

    pttg_upkeep:add_callback("pttg_Idle", "pttg_character_rank_up", function() core:trigger_custom_event('pttg_character_rank_up', {}) end)
end

cm:add_first_tick_callback(init)

------------------------------ FIXES to the Character Upgrade System --------------------------------------------------------
function CUS:convert_character(character, new_type, new_subtype, opt_inherited_level_proportion, opt_incident, opt_copy_name)

	if character:is_null_interface() then
		script_error("ERROR: convert_character() called with an invalid character interface. They will not get upgraded")
		return
	end

	local x = character:logical_position_x()
	local y = character:logical_position_y()

	if not (is_string(new_type) and is_string(new_subtype)) then
		script_error("ERROR: convert_character_subtype() is being used without valid strings for agent type and subtype")
		return
	end

	local inherited_level_proportion = opt_inherited_level_proportion or 1

	if not is_number(inherited_level_proportion) then
		script_error("ERROR: convert_character_subtype() has received a parameter for level proportion, but it is not a number!")
		return
	end

	if not is_string(opt_incident) and not is_nil(opt_incident) then
		script_error("ERROR: convert_character_subtype() has received a parameter for an incident, but it is not a string!")
		return
	end

	---collect all the old character data
	local old_char_details = {
		mf = character:military_force(),
		rank = character:rank(),
		fm_cqi = character:family_member():command_queue_index(),
		character_details = character:character_details(),
		faction_key = character:faction():name(),
		character_forename = character:get_forename(),
		character_surname = character:get_surname(),
		parent_force = character:embedded_in_military_force(),
		subtype = character:character_subtype_key(),
		traits = {},
		ap = character:action_points_remaining_percent()
	}

    for _, trait in pairs(character:all_traits()) do
        old_char_details.traits[trait] = character:trait_level(trait)
    end

	local new_character
	if character:has_military_force() then
		new_character = cm:replace_general_in_force(old_char_details.mf, new_subtype)
	else
		new_x, new_y = cm:find_valid_spawn_location_for_character_from_position(old_char_details.faction_key, x, y, false)
		new_character = cm:create_agent(old_char_details.faction_key, new_type, new_subtype, new_x, new_y)
	end

	if new_character then
		self:update_new_character(old_char_details, new_character, inherited_level_proportion)
		if opt_incident then
			cm:trigger_incident_with_targets(new_character:faction():command_queue_index(), opt_incident, 0, 0, new_character:command_queue_index(), 0, 0, 0)
		end
	end

end

--- should never need to call this seperately
function CUS:update_new_character(old_char_details, new_char_interface, level_proportion_base)
	cm:reassign_ancillaries_to_character_of_same_faction(old_char_details.character_details, new_char_interface:character_details())

	if old_char_details.character_forename == "" and old_char_details.character_surname == "" then
		cm:randomise_character_name(new_char_interface)
	else
		cm:change_character_localised_name(new_char_interface,old_char_details.character_forename, old_char_details.character_surname,"names_name_2147358938","names_name_2147358938")
	end

	local new_subtype = new_char_interface:character_subtype_key()
	local new_character_level_proportion = level_proportion_base
	local new_char_lookup = cm:char_lookup_str(new_char_interface)
	local traits_to_copy = old_char_details.traits

	if self.subtypes_to_xp_bonus_values[new_subtype] then
		local bonus_value = self.subtypes_to_xp_bonus_values[new_subtype]
		if cm:get_characters_bonus_value(new_char_interface, bonus_value) > 0 then
			new_character_level_proportion = new_character_level_proportion + cm:get_characters_bonus_value(new_char_interface, bonus_value)/100
		end
	end

    for trait, level in pairs(traits_to_copy) do
        cm:force_add_trait(new_char_lookup, trait, false, level)
    end

	if self.subtype_to_bonus_traits[old_char_details.subtype] then
		local trait_to_add= self.subtype_to_bonus_traits[old_char_details.subtype].default

		if self.subtype_to_bonus_traits[old_char_details.subtype][new_subtype] then
			trait_to_add = self.subtype_to_bonus_traits[old_char_details.subtype][new_subtype]
		end

		if trait_to_add then
			cm:force_add_trait(new_char_lookup, trait_to_add)
		end
	end

	if self.subtypes_to_tints[new_subtype] then
		local tint_details = self.subtypes_to_tints[new_subtype]
		local primary_colour_key = tint_details.primary.key
		local primary_colour_amount = cm:random_number(tint_details.primary.intensity_max, tint_details.primary.intensity_min)
		local secondary_colour_key = tint_details.secondary.key
		local secondary_colour_amount = cm:random_number(tint_details.secondary.intensity_max, tint_details.secondary.intensity_min)

		cm:set_tint_activity_state_for_character(new_char_interface, true)
		cm:set_tint_colour_for_character(new_char_interface, primary_colour_key, primary_colour_amount, secondary_colour_key, secondary_colour_amount)
	end

	if self.subtypes_to_composite_scenes[new_subtype] then
		local composite_scene = self.subtypes_to_composite_scenes[new_subtype]
		local x = new_char_interface:logical_position_x();
		local y = new_char_interface:logical_position_y();
		cm:add_scripted_composite_scene_to_logical_position(composite_scene, composite_scene, x, y, x, y + 1, true, false, false);
	end

	if old_char_details.ap > 0 then
		cm:replenish_action_points(new_char_lookup, old_char_details.ap/100)
	end

	cm:add_agent_experience(cm:char_lookup_str(new_char_interface:command_queue_index()), math.floor(old_char_details.rank * new_character_level_proportion)+1, true)
	cm:suppress_immortality(old_char_details.fm_cqi, true)

	cm:callback(function()
		cm:kill_character_and_commanded_unit("family_member_cqi:" .. old_char_details.fm_cqi, true)
	end, 0.5)

	if not old_char_details.parent_force:is_null_interface() then
		cm:embed_agent_in_force(new_char_interface, old_char_details.parent_force)
	end

    pttg:set_state("general_fm_cqi", new_char_interface:family_member():command_queue_index())
end

local function pttg_character_rank_up_countdown(countdown, cqi)
	pttg_upkeep:remove_callback("pttg_Idle", "pttg_character_rank_up_countdown")
	if countdown > 0 then
		pttg_upkeep:add_callback("pttg_Idle", "pttg_character_rank_up_countdown", 
			pttg_character_rank_up_countdown,
			nil,
			{countdown-1, cqi}
		)
	else
		local character_list = cm:get_saved_value("player_herald_lords_to_ignore_rankup")

		-- remove the character cqi, so we can ask again
		for i = 1, #character_list do
			if tonumber(tostring(cqi)) == character_list[i] then
				table.remove(character_list, i)
				break
			end
		end
		
		cm:set_saved_value("player_herald_lords_to_ignore_rankup", character_list)
	end
end

core:add_listener(
    "pttg_greater_daemons_rank_up",
    "pttg_character_rank_up",
    function(context)
        local culture = cm:get_local_faction():culture()
        return greater_daemons.valid_cultures[culture] ~= nil
    end,
    function(context)
		cm:callback(
			function()
				local faction = cm:get_local_faction()
				local mf_list = faction:military_force_list()
		
				-- find any valid characters
				for i = 0, mf_list:num_items() - 1 do
					local current_general = mf_list:item_at(i):general_character()
					local current_general_subtype = current_general:character_subtype_key()
					local upgrade_details = greater_daemons.character_types[current_general_subtype]
		
					if current_general:rank() >= greater_daemons.required_level_for_dilemma and upgrade_details and current_general:has_region() and not current_general:is_besieging() and not current_general:is_faction_leader() then
						
						local original_character_cqi = current_general:command_queue_index()
						local character_list = cm:get_saved_value("player_herald_lords_to_ignore_rankup") or {}
						local character_is_valid = true
		
						-- check if the character has already been ignored by the player
						for j = 1, #character_list do
							if original_character_cqi == character_list[j] then
								character_is_valid = false
							end
						end
		
						if character_is_valid and upgrade_details.dilemma then
							-- Send successful event with character CQI.
							core:trigger_event("ScriptEventHeraldUpgradeChance", cm:get_character_by_cqi(original_character_cqi))
		
							local function trigger_upgrade_dilemma()
								cm:trigger_dilemma_with_targets(faction:command_queue_index(), upgrade_details.dilemma, 0, 0, original_character_cqi, 0, 0, 0)
		
								core:add_listener(
									"wh3_main_dilemma_exalted_greater_daemon_choice",
									"DilemmaChoiceMadeEvent",
									function(context)
										return greater_daemons.valid_dilemmas[context:dilemma()]
									end,
									function(context)
										local choice = context:choice()
										
										if choice == 0 then
											cm:callback(function() greater_daemons:upgrade_herald(current_general) end, 0.4)
										else
											if choice == 1 then
												pttg_upkeep:add_callback("pttg_Idle", "pttg_character_rank_up_countdown", 
													pttg_character_rank_up_countdown,
													nil,
													{9, original_character_cqi}
												)
											end
											
											-- keep track of this cqi to ask again later (or permanently ignore)
											table.insert(character_list, original_character_cqi)
											cm:set_saved_value("player_herald_lords_to_ignore_rankup", character_list)
										end
									end,
									false
								)
							end
							
							if cm:is_multiplayer() then
								trigger_upgrade_dilemma()
							else
								cm:trigger_transient_intervention(
									"herald_upgrade_intervention",
									function(intervention)
										intervention:scroll_camera_for_intervention(
											nil,
											current_general:display_position_x(),
											current_general:display_position_y(),
											"",
											nil,
											nil,
											nil,
											function()
												trigger_upgrade_dilemma()
											end
										)
									end
								)
							end
							-- just deal with one character per turn
							break
						end
					end
				end
			end,
			0.4
		)
    end,
    true
)