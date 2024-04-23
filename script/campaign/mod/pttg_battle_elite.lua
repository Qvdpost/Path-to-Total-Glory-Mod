local pttg = core:get_static_object("pttg");
local pttg_glory = core:get_static_object("pttg_glory")
local pttg_battle_templates = core:get_static_object("pttg_battle_templates");
local pttg_mod_wom = core:get_static_object("pttg_mod_wom")


core:add_listener(
    "pttg_RoomBattle",
    "pttg_StartEliteRoomBattle",
    true,
    function(context)
        local cursor = pttg:get_cursor()

        local invasion_template_army = pttg_battle_templates:get_random_elite_battle_template(cursor.z)
        local invasion_template = invasion_template_army.template
        local invasion_faction = invasion_template_army.info.faction


        local invasion_power = cursor.z * 2 + cursor.z
        local invasion_size = ((cursor.z - 1) * 5) + cursor.y + 4
        local general_level = cursor.z + cursor.y

        pttg:log(string.format("[battle_event] Generating a battle with power: %i of size: %i against %s(%s)",
            invasion_power, invasion_size, invasion_faction, invasion_template))

        Forced_Battle_Manager:pttg_trigger_forced_elite_battle_with_generated_army(
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
            nil                          --	opt_effect_bundle TODO: add effect bundles
        )
    end,
    true
)

core:add_listener(
    "pttg_EliteBattleWon",
    "IncidentOccuredEvent",
    function(context) return context:dilemma() == "pttg_elite_battle_victory" end,
    function(context)
        
        pttg_glory:reward_glory(35, 25)
        
        core:trigger_custom_event('pttg_recruit_reward', {recruit_chances=pttg:get_state("elite_recruit_chances")})

        pttg_mod_wom:increase(10)

        core:trigger_custom_event('pttg_idle', {})
    end,
    true
)