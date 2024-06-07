local pttg = core:get_static_object("pttg");
local pttg_glory = core:get_static_object("pttg_glory")
local pttg_battle_templates = core:get_static_object("pttg_battle_templates");
local pttg_mod_wom = core:get_static_object("pttg_mod_wom")
local pttg_upkeep = core:get_static_object("pttg_upkeep")
local pttg_effect_pool = core:get_static_object("pttg_effect_pool")

core:add_listener(
    "pttg_BossRoomBattle",
    "pttg_StartBossRoomBattle",
    true,
    function(context)
        local cursor = pttg:get_cursor()

        pttg_upkeep:resolve("pttg_BossRoomBattle")

        pttg:set_state("battle_ongoing", "pttg_boss_battle_victory")

        local invasion_template_army = pttg_battle_templates:get_random_boss_battle_template(cursor.z)
        local invasion_template = invasion_template_army.key
        local invasion_faction = invasion_template_army.faction


        local invasion_power = (cursor.z - 1) * 2 + 5 +  pttg:get_difficulty_mod('ai_army_power_mod') -- easy:4|6|8 medium:5|7|9 hard:6|8|10
        local invasion_size = 10 + pttg:get_difficulty_mod('encounter_size') + ((cursor.z - 1) * 2)   -- easy:12|14|16 medium:14|16|18 hard:16|18|20
        local general_level = (cursor.z - 1) * 20 + cursor.y + 10

        local invasion_chevrons = (cursor.z - 1) * 2 + (math.floor(cursor.y / 2) * cursor.z)

        local invasion_effect_bundle = invasion_template_army.effect_bundle or
        pttg_effect_pool:get_random_army_effect_bundle(pttg:get_difficulty_index())

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
            "pttg_boss_battle_victory",             --	opt_player_victory_incident
            "pttg_battle_defeat",                   --	opt_player_defeat_incident
            invasion_template_army.general_subtype, --	opt_general_subtype
            general_level,                          --	opt_general_level
            invasion_template_army.agents,
            invasion_chevrons,
            invasion_effect_bundle --	opt_effect_bundle
        )
    end,
    true
)

core:add_listener(
    "pttg_BossBattleWon",
    "IncidentOccuredEvent",
    function(context) return context:dilemma() == "pttg_boss_battle_victory" end,
    function(context)
        pttg_glory:reward_glory(105, 95)

        pttg_mod_wom:increase(10)

        pttg_upkeep:resolve("pttg_PostRoomBattle")

        pttg:set_state("battle_ongoing", false)

        cm:heal_military_force(cm:get_military_force_by_cqi(pttg:get_state('army_cqi')))

        core:trigger_custom_event('pttg_recruit_reward', {
            recruit_count = 3,
            recruit_chances = pttg:get_state("boss_recruit_chances"),
            unique_only = true,
            recruit_glory = 4
        })

        cm:callback(
            function() cm:trigger_incident(cm:get_local_faction():name(), 'pttg_boss_treasure', true) end,
            0.4
        )
    end,
    true
)
