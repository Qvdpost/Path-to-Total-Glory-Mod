local pttg = core:get_static_object("pttg");
local pttg_glory = core:get_static_object("pttg_glory")
local pttg_battle_templates = core:get_static_object("pttg_battle_templates");
local pttg_mod_wom = core:get_static_object("pttg_mod_wom")
local pttg_upkeep = core:get_static_object("pttg_upkeep")


core:add_listener(
    "pttg_BossRoomBattle",
    "pttg_StartBossRoomBattle",
    true,
    function(context)
        local cursor = pttg:get_cursor()

        pttg_upkeep:resolve("pttg_BossRoomBattle")

        local invasion_template_army = pttg_battle_templates:get_random_elite_battle_template(cursor.z)
        local invasion_template = invasion_template_army.template
        local invasion_faction = invasion_template_army.info.faction


        local invasion_power = cursor.z
        local invasion_size = ((cursor.z - 1) * 5) + cursor.y + 2
        local general_level = cursor.z + cursor.y

        pttg:log(string.format("[battle_event] Generating a battle with power: %i of size: %i against %s(%s)",
            invasion_power, invasion_size, invasion_faction, invasion_template))

        Forced_Battle_Manager:pttg_trigger_forced_battle_with_generated_army(
            pttg:get_state('army_cqi'), --	target_force_cqi
            invasion_faction,           --	generated_force_faction
            invasion_template,          --	generated_force_template
            invasion_size,              --	generated_force_size
            invasion_power,             --	generated_force_power
            false,                      --	generated_force_is_attacker
            true,                       --	destroy_generated_force_after_battle
            false,                      --	is_ambush
            "pttg_boss_battle_victory", --	opt_player_victory_incident
            "pttg_battle_defeat",       --	opt_player_defeat_incident
            nil,                        --	opt_general_subtype
            general_level,              --	opt_general_level
            nil                         --	opt_effect_bundle
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

        core:trigger_custom_event('pttg_recruit_reward', { recruit_chances = pttg:get_state("boss_recruit_chances") })
        pttg_glory:add_initial_recruit_glory(1)

        cm:callback( -- we need to wait a tick for this to work, so we don't loop this event
            function()
                pttg_mod_wom:increase(10)
            end,
            0.4
        )

        cm:heal_military_force(cm:get_military_force_by_cqi(pttg:get_state('army_cqi')))

        core:trigger_custom_event('pttg_Idle', {})
    end,
    true
)
