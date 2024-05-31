local pttg = core:get_static_object("pttg");
local pttg_mod_wom = core:get_static_object("pttg_mod_wom")
local pttg_glory = core:get_static_object("pttg_glory")
local pttg_warband_upgrade = core:get_static_object("pttg_warband_upgrade")
local pttg_side_effects = core:get_static_object("pttg_side_effects")


core:add_listener(
    "pttg_RewardChosen",
    "DilemmaChoiceMadeEvent",
    function(context)
        return context:dilemma() == 'pttg_ChooseReward'
    end,
    function(context)
        pttg:log("[PathToTotalGlory][pttg_RewardChosen] resolving reward: ")

        pttg:log(string.format("Choice: %s", context:choice_key()))

        if context:choice_key() == 'FIRST' then -- Recruit Reward
            local cursor = pttg:get_cursor()
            core:trigger_custom_event('pttg_recruit_reward', { 
                recruit_count = pttg:get_state('recruit_count'), 
                recruit_chances = pttg:get_state("recruit_chances")[cursor.z], 
                unique_only = false,
                recruit_glory=pttg:get_state('glory_recruit_default')[cursor.z] 
            })
        elseif context:choice_key() == 'SECOND' then -- WoM reward
            pttg:log("[pttg_RewardChosen] Increasing WoM.")
            pttg_mod_wom:increase(25)
        elseif context:choice_key() == 'THIRD' then -- Glory Reward
            pttg:log("[pttg_RewardChosen] Rewarding Glory")
            -- TODO award faction resource
            pttg_side_effects:unlock_active_tech(pttg:get_state('tech_completion_rate'))
        else                                        -- Decide Later
            pttg:set_state('pending_reward', true)
            core:trigger_custom_event('pttg_Idle', {})
            return true
        end

        pttg:set_state('pending_reward', false)
        core:trigger_custom_event('pttg_Idle', {})

        return true
    end,
    true
)
