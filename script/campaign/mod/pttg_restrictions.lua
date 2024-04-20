local pttg = core:get_static_object("pttg");
local mct = get_mct();
local pttg_upkeep = core:get_static_object("pttg_upkeep")


local function restrict_player()
    core:add_listener(
        "award_random_magical_item",
        "TriggerPostBattleAncillaries",
        true,
        function(context)
            return false;
        end,
        true
    );
end

-- TODO: find a better place for this
local function zero_merc_cost()
    local recruitment_cost_bundle_key = "pttg_merc_recruit_cost_down";
	local faction = cm:get_local_faction()

    if faction:has_effect_bundle(recruitment_cost_bundle_key) then
        return
    end

    local recruitment_cost_bundle = cm:create_new_custom_effect_bundle(recruitment_cost_bundle_key);
    
    recruitment_cost_bundle:add_effect("wh3_main_effect_mercenary_cost_mod", "faction_to_character_own_factionwide_armytext", -10000);
    recruitment_cost_bundle:set_duration(0);

    recruitment_cost_bundle:add_effect("wh_main_effect_force_all_campaign_recruitment_cost_all", "faction_to_character_own_factionwide_armytext", -10000);
    recruitment_cost_bundle:set_duration(0);

    cm:apply_custom_effect_bundle_to_faction(recruitment_cost_bundle, faction);
end

local function init() 
    pttg_upkeep:add_callback("pttg_zero_merc_cost", zero_merc_cost, nil)
end

cm:add_first_tick_callback(function() restrict_player() end);

cm:add_first_tick_callback(function() init() end);
