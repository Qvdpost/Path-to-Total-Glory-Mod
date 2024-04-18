local pttg = core:get_static_object("pttg");
local pttg_glory = core:get_static_object("pttg_glory")


local factions_to_template = {
    ["pttg_grn_savage_orcs"] = { "wurrzag" },
    ["pttg_tmb_tomb_kings"] = { "khatep", "arkhan", "khalida" },
    ["pttg_skv_skaven"] = { "snikch", "mors", "thrott" },
    ["pttg_sla_slaanesh"] = { "azazel" },
    ["pttg_def_dark_elves"] = { "rakarth", "crone", "lokhir" },
    ["pttg_lzd_lizardmen"] = { "tehenhauin", "nakai", "gor-rok" },
    ["pttg_bst_beastmen"] = { "malagor", "morghur", "taurox" },
    ["pttg_grn_greenskins"] = { "azhag", "grom", "skarsnik" },
    ["pttg_kho_khorne"] = { "valkia" },
    ["pttg_nur_nurgle"] = { "festus" },
    ["pttg_chs_chaos"] = { "sigvald", "kholek" },
    ["pttg_vmp_vampire_counts"] = { "ghorst", "kemmler", "vlad+isabella" },
    ["pttg_dwf_dwarfs"] = { "grombrindal", "ungrim", "belegar" },
    ["pttg_cst_vampire_coast"] = { "saltspire", "direfin", "noctilus" },
    ["pttg_tze_tzeentch"] = { "vilitch", "changeling" },
    ["pttg_emp_empire"] = { "volkmar", "wulfhart", "gelt" },
    ["pttg_ogr_ogre_kingdoms"] = { "skrag", "greasus" },
    ["pttg_brt_bretonnia"] = { "repanse", "alberic", "the-fay" },
    ["pttg_nor_norsca"] = { "throgg", "wulfrik" },
    ["pttg_hef_high_elves"] = { "alith", "alarielle", "eltharion" },
    ["pttg_wef_wood_elves"] = { "drycha", "Durthu", "Sisters" },
    ["pttg_ksl_kislev"] = { "kostaltyn", "ostankya", "Boris" },
    ["pttg_chd_chaos_dwarfs"] = { "zhatan", "drazhoath" },
    ["pttg_cth_cathay"] = { "zhao", "miao", "yuan" }
}

local faction_keyset = {}
for k in pairs(factions_to_template) do
    table.insert(faction_keyset, k)
end

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

core:add_listener(
    "pttg_RoomBattle",
    "pttg_StartEliteRoomBattle",
    true,
    function(context)
        local cursor = pttg:get_cursor()
        local faction = cm:get_local_faction()
        local character = cm:get_character_by_mf_cqi(pttg:get_state('army_cqi'))

        local invasion_faction = faction_keyset[math.random(1, #faction_keyset)]
        local invasion_templates = factions_to_template[invasion_faction]

        local invasion_template = invasion_templates[cm:random_number(#invasion_templates)]


        local invasion_power = cursor.z
        local invasion_size = ((cursor.z - 1) * 5) + cursor.y + 2
        local general_level = cursor.z + cursor.y

        pttg:log(string.format("[battle_event] Generating a battle with power: %i of size: %i against %s(%s)",
            invasion_power, invasion_size, invasion_faction, invasion_template))

        Forced_Battle_Manager:pttg_trigger_forced_battle_with_generated_army(
            pttg:get_state('army_cqi'),  --	target_force_cqi
            invasion_faction,            --	generated_force_faction
            invasion_template,           --	generated_force_template
            invasion_size,               --	generated_force_size
            invasion_power,              --	generated_force_power
            false,                       --	generated_force_is_attacker
            true,                        --	destroy_generated_force_after_battle
            false,                       --	is_ambush
            "pttg_elite_battle_victory", --	opt_player_victory_incident
            "pttg_battle_defeat",        --	opt_player_defeat_incident
            nil,                         --	opt_general_subtype
            general_level,               --	opt_general_level
            nil                          --	opt_effect_bundle
        )
    end,
    true
)

core:add_listener(
    "pttg_EliteBattleWon",
    "IncidentOccuredEvent",
    function(context) return context:dilemma() == "pttg_elite_battle_victory" end,
    function(context)
        cm:callback( -- we need to wait a tick for this to work, for some reason
            function()
                local character = cm:get_character_by_mf_cqi(pttg:get_state('army_cqi'))
                cm:replenish_action_points(cm:char_lookup_str(character));
                cm:scroll_camera_from_current(false, 1,
                    { character:display_position_x(), character:display_position_y(), 14.7, 0.0, 12.0 });
            end,
            0.2
        )
        pttg_glory:reward_glory(35, 25)

        core:trigger_custom_event('pttg_phase3', {})
    end,
    true
)
