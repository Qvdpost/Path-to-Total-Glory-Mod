local pttg = core:get_static_object("pttg");
local pttg_glory = core:get_static_object("pttg_glory")
local pttg_battle_templates = core:get_static_object("pttg_battle_templates");
local pttg_upkeep = core:get_static_object("pttg_upkeep")


core:add_listener(
    "pttg_RegularRoomBattle",
    "pttg_StartRoomBattle",
    true,
    function(context)
        local cursor = pttg:get_cursor()

        pttg:set_state("battle_ongoing", "pttg_battle_victory")

        pttg_upkeep:resolve("pttg_RegularRoomBattle")

        local invasion_template_army = pttg_battle_templates:get_random_battle_template(cursor.z)
        local invasion_template = invasion_template_army.key
        local invasion_faction = invasion_template_army.faction

        local invasion_power = 2 + (cursor.z - 1) * 2 +
        pttg:get_difficulty_mod('ai_army_power_mod')                                                      -- easy:1|3|5 medium:2|4|6 hard:3|5|7
        local invasion_size = ((cursor.z - 1) * 12) + cursor.y +
        pttg:get_difficulty_mod('encounter_size')                                                         -- easy:2+y|14+y|19+y medium:4+y|16+y|20 hard:6+y|16+y|20
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
            cm:random_number(2) == 1,               --	generated_force_is_attacker
            true,                                   --	destroy_generated_force_after_battle
            false,                                  --	is_ambush
            "pttg_battle_victory",                  --	opt_player_victory_incident
            "pttg_battle_defeat",                   --	opt_player_defeat_incident
            invasion_template_army.general_subtype, --	opt_general_subtype
            general_level,                          --	opt_general_level
            invasion_template_army.agents,
            invasion_chevrons,
            nil                                     --	opt_effect_bundle
        )
    end,
    true
)

core:add_listener(
    "pttg_BattleWon",
    "IncidentOccuredEvent",
    function(context) return context:dilemma() == "pttg_battle_victory" end,
    function(context)
        pttg:log("[pttg_battle_victory] Victory event received.")

        pttg:set_state("battle_ongoing", false)

        pttg_glory:reward_glory(20, 10)
        
        pttg_upkeep:resolve("pttg_PostRoomBattle")
                
        core:trigger_custom_event('pttg_Rewards', {})
    end,
    true
)

core:add_listener(
    "pttg_BattleDefeat",
    "IncidentOccuredEvent",
    function(context) return context:dilemma() == "pttg_battle_defeat" end,
    function(context)
        pttg:log("Game over.")
        local faction = cm:get_local_faction()

        local characters = {}
        for i = 0, faction:character_list():num_items() - 1 do
            table.insert(characters, faction:character_list():item_at(i))   
        end
        for _, character in pairs(characters) do
            pttg:log("Killing: ".. character:character_subtype_key().. "|" .. character:character_type_key())
            cm:kill_character(cm:char_lookup_str(character), true)
        end

        local regions = {}
        for i = 0, faction:region_list():num_items() - 1 do
            table.insert(regions, faction:region_list():item_at(i))
        end
        for _, region in pairs(regions) do
            pttg:log("Abandoning: ".. region:name())
            cm:set_region_abandoned(region:name())
        end
    end,
    true
)
