local pttg = core:get_static_object("pttg")
local pttg_side_effects = core:get_static_object("pttg_side_effects")
local pttg_wom = core:get_static_object("pttg_mod_wom")
local pttg_battle = core:get_static_object("pttg_battle")

local function setup_post_battle_option_listener()
	core:add_listener(
		"pttg_post_battle_options",
		"CharacterPostBattleCaptureOption",
		true,
		function(context)
            pttg:log("Processing Captive Option: "..context:get_outcome_key())
            
			if context:get_outcome_key() == "kill" then
                -- Gain Scrap for Upgrades
                -- Highlight training somehow?
                -- pttg_glory:add_training_glory(1)

            elseif context:get_outcome_key() == "enslave" or context:get_outcome_key() == "enslave_replenishment_only" or context:get_outcome_key() == "none" then
                -- Replenish Force
                pttg_side_effects:heal_force(0.2, true)
            elseif context:get_outcome_key() == "release" then
                -- Gain Glory
                -- pttg_glory:reward_glory(25)
                core:trigger_custom_event("pttg_glory_focus", {})
            end

            -- TODO: reduce wom in case of auto-resolve?
            if pttg_battle.spent_wom_reserves then
                pttg:log("Adjusting Winds of Magic for spent wom: "..pttg_battle.spent_wom_reserves)
                local efficiency = pttg:get_state('wom_efficiency')
                pttg_wom:decrease(pttg_battle.spent_wom_reserves - (pttg_battle.spent_wom_reserves * efficiency))
                pttg_battle.spent_wom_reserves = nil
            end
		end,
		true
	);
end

cm:add_first_tick_callback(setup_post_battle_option_listener)