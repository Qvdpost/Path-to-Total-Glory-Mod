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

function pttg_glory:add_initial_recruit_glory()
    local amount = pttg:get_state("glory_recruit_default") * pttg:get_state("glory_recruit_modifier")

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


core:add_static_object("pttg_glory", pttg_glory)
