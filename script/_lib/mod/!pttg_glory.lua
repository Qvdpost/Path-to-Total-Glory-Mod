local pttg = core:get_static_object("pttg");

pttg_glory = {

}

function pttg_glory:reward_glory(amount, min)
    if min then
        amount = cm:random_number(amount, min)
    end
    amount = amount * pttg:get_state("glory_reward_modifier")

    cm:faction_add_pooled_resource(cm:get_local_faction_name(), "pttg_glory_points", "pttg_glory_point_reward",
        amount)
end

function pttg_glory:add_initial_recruit_glory(amount)
    local amount = amount * pttg:get_state("glory_recruit_modifier")

    cm:faction_add_pooled_resource(cm:get_local_faction():name(), "pttg_unit_reward_glory",
        "pttg_glory_unit_recruitment", amount)
end

function pttg_glory:add_recruit_glory(amount)
    if amount < 0 then
        pttg:log("[pttg_glory] Cannot add negative glory.")
        return false
    end

    cm:faction_add_pooled_resource(cm:get_local_faction():name(), "pttg_unit_reward_glory",
        "pttg_glory_unit_recruitment", amount)
end

function pttg_glory:remove_recruit_glory(amount)
    if amount < 0 then
        pttg:log("[pttg_glory] Cannot remove negative glory.")
        return false
    end

    cm:faction_add_pooled_resource(cm:get_local_faction():name(), "pttg_unit_reward_glory",
        "pttg_glory_unit_recruitment", -amount)
end

function pttg_glory:add_training_glory(amount)
    if amount < 0 then
        pttg:log("[pttg_glory] Cannot add negative glory.")
        return false
    end
    cm:faction_add_pooled_resource(cm:get_local_faction():name(), "pttg_glory_training_points",
    "pttg_glory_point_training", amount)
end

function pttg_glory:add_warband_upgrade_glory(amount, hidden)
    if amount < 0 then
        pttg:log("[pttg_glory] Cannot add negative glory.")
        return false
    end
    cm:faction_add_pooled_resource(cm:get_local_faction():name(), "pttg_warband_upgrade_glory",
    "pttg_glory_warband_upgrade", amount)

    if not hidden then
        local pttg_warband_upgrade = core:get_static_object("pttg_warband_upgrade")
        pttg_warband_upgrade:highlight_warband(true)
    end
end

function pttg_glory:add_tech_glory(amount, hidden)
    if amount < 0 then
        pttg:log("[pttg_glory] Cannot add negative glory.")
        return false
    end
    cm:faction_add_pooled_resource(cm:get_local_faction():name(), "pttg_technology_glory",
    "pttg_glory_point_technology", amount)

    if not hidden then
        local tech_button = find_uicomponent(core:get_ui_root(), "hud_campaign", "faction_buttons_docker", "button_group_management", "button_technology")
        if tech_button then
            tech_button:Highlight(true)
        end
    end
end

function pttg_glory:remove_tech_glory(amount)
    if amount < 0 then
        pttg:log("[pttg_glory] Cannot remove negative glory.")
        return false
    end
    cm:faction_add_pooled_resource(cm:get_local_faction():name(), "pttg_technology_glory",
    "pttg_glory_point_technology", -amount)
end

function pttg_glory:get_glory_value()
    local faction = cm:get_faction(cm:get_local_faction_name(true))
    local player_glory = faction:pooled_resource_manager():resource("pttg_glory_points"):value()
    return player_glory
end

function pttg_glory:get_recruit_glory_value()
    local faction = cm:get_faction(cm:get_local_faction_name(true))
    local player_glory = faction:pooled_resource_manager():resource("pttg_unit_reward_glory"):value()
    return player_glory
end

function pttg_glory:get_training_glory()
    local faction = cm:get_faction(cm:get_local_faction_name(true))
    local player_glory = faction:pooled_resource_manager():resource("pttg_glory_training_points"):value()
    return player_glory
end

function pttg_glory:get_warband_glory_value()
    local faction = cm:get_faction(cm:get_local_faction_name(true))
    local player_glory = faction:pooled_resource_manager():resource("pttg_warband_upgrade_glory"):value()
    return player_glory
end

function pttg_glory:get_tech_glory_value()
    local faction = cm:get_faction(cm:get_local_faction_name(true))
    local player_glory = faction:pooled_resource_manager():resource("pttg_technology_glory"):value()
    return player_glory
end

function pttg_glory:reset_recruit_glory(amount)
    local faction = cm:get_local_faction()
    local glory_points = faction:pooled_resource_manager():resource("pttg_unit_reward_glory"):value()
    cm:faction_add_pooled_resource(cm:get_local_faction():name(), "pttg_unit_reward_glory",
        "pttg_glory_unit_recruitment", -glory_points)
end

function pttg_glory:reset_training_glory(amount)
    local faction = cm:get_local_faction()
    local glory_points = faction:pooled_resource_manager():resource("pttg_glory_training_points"):value()
    cm:faction_add_pooled_resource(cm:get_local_faction():name(), "pttg_glory_training_points",
        "pttg_glory_point_training", -glory_points)
end

function pttg_glory:reset_warband_upgrade_glory(amount)
    local faction = cm:get_local_faction()
    local glory_points = faction:pooled_resource_manager():resource("pttg_warband_upgrade_glory"):value()
    cm:faction_add_pooled_resource(cm:get_local_faction():name(), "pttg_warband_upgrade_glory",
        "pttg_glory_warband_upgrade", -glory_points)
end


core:add_static_object("pttg_glory", pttg_glory)
