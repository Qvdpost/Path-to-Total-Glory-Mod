local pttg = core:get_static_object("pttg");
local pttg_UI = core:get_static_object("pttg_UI")
local pttg_tele = core:get_static_object("pttg_tele")
local pttg_merc_pool = core:get_static_object("pttg_merc_pool")
local pttg_mod_wom = core:get_static_object("pttg_mod_wom")
local pttg_glory = core:get_static_object("pttg_glory")
local pttg_side_effects = core:get_static_object("pttg_side_effects")


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
		end,
		true
	);
end

cm:add_first_tick_callback(setup_post_battle_option_listener)