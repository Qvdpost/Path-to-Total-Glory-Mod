local pttg = core:get_static_object("pttg");

local pttg_merc_pool_manager = {
    pool_list = {}
}

function pttg_merc_pool_manager:new_pool(key)
    pttg:log("[pttg_merc_pool]Random Merc Pool Manager: Creating New Merc Pool with key [" .. key .. "]");

    local existing_pool = self:get_pool_by_key(key)

    if existing_pool then
        existing_pool.key = key;
        existing_pool.units = {};
        existing_pool.mandatory_units = {};
        existing_pool.faction = "";
        pttg:log("\tPool with key [" .. key .. "] already exists - resetting pool!");
        return true;
    end

    local pool = {};
    pool.key = key;
    pool.units = {};
    pool.mandatory_units = {};
    pool.faction = "";
    table.insert(self.pool_list, pool);
    pttg:log("\tPool with key [" .. key .. "] created!");
    return true;
end

function pttg_merc_pool_manager:get_pool_by_key(pool_key)
    for i = 1, #self.pool_list do
        if pool_key == self.pool_list[i].key then
            return self.pool_list[i];
        end;
    end;

    return false;
end;

function pttg_merc_pool_manager:add_unit(pool_key, key, weight)
    local pool_data = self:get_pool_by_key(pool_key);

    if pool_data then
        for i = 1, weight do
            table.insert(pool_data.units, key);
        end;
        return;
    end;

    self:new_pool(pool_key);
    self:add_unit(pool_key, key, weight);
end;

function pttg_merc_pool_manager:generate_pool(pool_key, unit_count, return_as_table)
    local pool = {};
    local pool_data = self:get_pool_by_key(pool_key);

    if not pool_data then
        pttg:log(string.format("Random Merc Pool Manager: no pool data found for %s; Aborting.", pool_key));
        return {}
    end

    if not unit_count then
        unit_count = #pool_data.mandatory_units
        -- 	elseif is_table(unit_count) then
        -- 		unit_count = cm:random_number(math.max(unit_count[1], unit_count[2]), math.min(unit_count[1], unit_count[2]));
    end

    unit_count = math.min(19, unit_count);

    pttg:log("Random Merc Pool Manager: Getting Random Pool for pool [" ..
        pool_key .. "] with size [" .. unit_count .. "]");

    local mandatory_units_added = 0;

    for i = 1, #pool_data.mandatory_units do
        table.insert(pool, pool_data.mandatory_units[i]);
        mandatory_units_added = mandatory_units_added + 1;
    end;

    if (unit_count - mandatory_units_added) > 0 and #pool_data.units == 0 then
        script_error("Random Merc Pool Manager: Tried to add units to pool_key [" ..
            pool_key .. "] but the pool has not been set up with any non-mandatory units - add them first!");
        return false;
    end;


    for i = 1, unit_count - mandatory_units_added do
        local unit_index = cm:random_number(#pool_data.units);
        table.insert(pool, pool_data.units[unit_index]);
    end;

    if #pool == 0 then
        script_error("Random Merc Pool Manager: Did not add any units to pool with pool_key [" ..
            pool_key .. "] - was the pool created?");
        return false;
    elseif return_as_table then
        return pool;
    else
        return table.concat(pool, ",");
    end;
end;

core:add_listener(
    "pttg_RewardChosenRecruit",
    "pttg_recruit_reward",
    true,
    function(context)
        local faction = cm:get_local_faction()
        pttg:log(string.format("[pttg_RewardChosenRecruit] Recruiting units for %s", faction:culture()))

        local function concatArray(a, b)
            if not b then
                return a
            end

            for _, item in pairs(b) do
                table.insert(a, item)
            end
            return a
        end

        local available_merc_pool = pttg_merc_pool.merc_pool[cm:get_local_faction():culture()][1]

        available_merc_pool = concatArray(available_merc_pool,
            pttg_merc_pool.merc_pool[cm:get_local_faction():culture()][2])
        available_merc_pool = concatArray(available_merc_pool,
            pttg_merc_pool.merc_pool[cm:get_local_faction():culture()][3])

        local recruit_pool_key = "pttg_recruit_reward"
        pttg_merc_pool_manager:new_pool(recruit_pool_key)

        for _, merc in pairs(available_merc_pool) do
            pttg_merc_pool_manager:add_unit(recruit_pool_key, merc.key, merc.weight)
        end

        pttg_merc_pool:add_active_units(pttg_merc_pool_manager:generate_pool(recruit_pool_key, 3, true))
    end,
    true
)

core:add_listener(
    "pttg_ResetMercPool",
    "pttg_phase1",
    true,
    function(context)
        pttg_merc_pool:reset_active_merc_pool()
        local faction = cm:get_local_faction()
        local glory_recruit_points = faction:pooled_resource_manager():resource("pttg_unit_reward_glory"):value()
        cm:faction_add_pooled_resource(cm:get_local_faction():name(), "pttg_unit_reward_glory",
            "pttg_glory_unit_recruitment", -glory_recruit_points)
    end,
    true
)
