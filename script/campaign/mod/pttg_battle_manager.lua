local pttg = core:get_static_object("pttg");


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
    opt_effect_bundle,
    opt_player_is_generated_force
)
    pttg:log("[trigger_forced_battle] Forced battle against " .. generated_force_template)
    local forced_battle_key = generated_force_template .. "_forced_battle"
    local forced_battle = Forced_Battle_Manager:setup_new_battle(forced_battle_key)
    local generated_force = WH_Random_Army_Generator:generate_random_army(forced_battle_key, generated_force_template,
        generated_force_size, generated_force_power, true, false)

    forced_battle:add_new_force(forced_battle_key, generated_force, generated_force_faction,
        destroy_generated_force_after_battle, opt_effect_bundle, opt_general_subtype, opt_general_level)

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

function Forced_Battle_Manager:pttg_trigger_forced_elite_battle_with_generated_army(
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
    opt_effect_bundle,
    opt_player_is_generated_force
)
    pttg:log("[trigger_forced_battle] Forced battle against " .. generated_force_template)
    local forced_battle_key = generated_force_template .. "_forced_battle"
    local forced_battle = Forced_Battle_Manager:setup_new_battle(forced_battle_key)
    local generated_force = WH_Random_Army_Generator:generate_random_army(forced_battle_key, generated_force_template,
        generated_force_size, generated_force_power, true, false)

    forced_battle:add_new_force(forced_battle_key, generated_force, generated_force_faction,
        destroy_generated_force_after_battle, opt_effect_bundle, opt_general_subtype, opt_general_level)

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
