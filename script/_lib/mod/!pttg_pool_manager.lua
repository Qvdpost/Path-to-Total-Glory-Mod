local pttg = core:get_static_object("pttg");

local pttg_pool_manager = {
    pool_list = {}
}

function pttg_pool_manager:new_pool(key)
    pttg:log("[pttg_pool_manager]Pool Manager: Creating New Merc Pool with key [" .. key .. "]");

    local existing_pool = self:get_pool_by_key(key)

    if existing_pool then
        existing_pool.key = key;
        existing_pool.items = {};
        existing_pool.mandatory_items = {};
        existing_pool.faction = "";
        pttg:log("\tPool with key [" .. key .. "] already exists - resetting pool!");
        return true;
    end

    local pool = {};
    pool.key = key;
    pool.items = {};
    pool.mandatory_items = {};
    pool.faction = "";
    table.insert(self.pool_list, pool);
    pttg:log("\tPool with key [" .. key .. "] created!");
    return true;
end

function pttg_pool_manager:get_item_count(pool_key)
    local pool_data = self:get_pool_by_key(pool_key);
    if not pool_data then
        return nil
    end

    return #pool_data.items + #pool_data.mandatory_items
end

function pttg_pool_manager:get_pool_by_key(pool_key)
    for i = 1, #self.pool_list do
        if pool_key == self.pool_list[i].key then
            return self.pool_list[i];
        end;
    end;

    return false;
end;

function pttg_pool_manager:add_item(pool_key, key, weight)
    local pool_data = self:get_pool_by_key(pool_key);
    pttg:log(string.format("Pool Manager: adding item: %s", tostring(key)));
    if pool_data then
        for i = 1, weight do
            table.insert(pool_data.items, key);
        end;
        return;
    end;

    self:new_pool(pool_key);
    self:add_item(pool_key, key, weight);
end;

function pttg_pool_manager:generate_pool(pool_key, item_count, return_as_table)
    local pool = {};
    local pool_data = self:get_pool_by_key(pool_key);

    if item_count == 0 then
        if return_as_table then
            return pool;
        else
            return "";
        end
    end;


    if not pool_data then
        pttg:log(string.format("Pool Manager: no pool data found for %s; Aborting.", pool_key));
        return {}
    end

    if not item_count then
        item_count = #pool_data.mandatory_items
        -- 	elseif is_table(item_count) then
        -- 		item_count = cm:random_number(math.max(item_count[1], item_count[2]), math.min(item_count[1], item_count[2]));
    end

    item_count = math.min(19, item_count);

    pttg:log("Pool Manager: Getting Random Pool for pool [" ..
        pool_key .. "] with size [" .. item_count .. "]");

    local mandatory_items_added = 0;

    for i = 1, #pool_data.mandatory_items do
        table.insert(pool, pool_data.mandatory_items[i]);
        mandatory_items_added = mandatory_items_added + 1;
    end;

    if (item_count - mandatory_items_added) > 0 and #pool_data.items == 0 then
        script_error("Pool Manager: Tried to add items to pool_key [" ..
            pool_key .. "] but the pool has not been set up with any non-mandatory items - add them first!");
        return false;
    end;


    for i = 1, item_count - mandatory_items_added do
        local item_index = cm:random_number(#pool_data.items);
        table.insert(pool, pool_data.items[item_index]);
    end;

    if #pool == 0 then
        script_error("Pool Manager: Did not add any items to pool with pool_key [" ..
            pool_key .. "] - was the pool created?");
        return false;
    elseif return_as_table then
        return pool;
    else
        return table.concat(pool, ",");
    end;
end;

core:add_static_object("pttg_pool_manager", pttg_pool_manager);
