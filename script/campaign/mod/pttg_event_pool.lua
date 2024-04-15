local pttg = core:get_static_object("pttg");
local ttc = core:get_static_object("tabletopcaps");

local pttg_event_pool = {
    event_pool = {},
    active_event_pool = {},
    excluded_event_pool = {}
}

local pttg_event_pool_manager = {
    pool_list = {}
}

function pttg_event_pool:add_event(event, info)
    pttg:log(string.format('[pttg_event_pool] Adding event: %s (weight:%s, faction_set%s, acts(%s,%s), alignment(%s,%s))',
            event,
            tostring(info.weight),
            tostring(info.faction_set),
            tostring(info.acts.upper),
            tostring(info.acts.lower),
            tostring(info.alignment.upper),
            tostring(info.alignment.lower)
        )
    )
    self.event_pool[event] = info
end

function pttg_event_pool:add_events(events)
    for event, info in pairs(events) do
        self:add_event(event, info)
    end
end

function pttg_event_pool:exclude_event(event)
    self.excluded_event_pool[event] = true
end

function pttg_event_pool:init_events()
    -- ["dummy"] = { weight = false, acts = {upper=nil, lower=nil}, alignment = {upper=nil, lower=nil}, faction_set=nil, callback=nil },
    local events_all = { 
        ["pttg_EventGlory"] = { weight = 10, acts = {upper=nil, lower=nil}, alignment = {upper=10, lower=nil}, faction_set='all', callback=pttg_EventGlory_callback },
    }
    self:add_events(events_all)
    
    self.excluded_event_pool = pttg:get_state('excluded_event_pool')
end

function pttg_event_pool:get_event_callback(event)
    if self.event_pool[event] then
        return self.event_pool[event].callback
    end

    return function() return nil end
end

function pttg_event_pool:is_eligible(event, info)
    local cursor = pttg:get_cursor()
    local alignment = pttg:get_state('alignment')
    local faction = cm:get_local_faction()
    pttg:log(string.format("[pttg_event_pool] Checking eligibility for: %s with alignment %s at %s.", faction:name(), tostring(alignment), tostring(cursor.z)));
    return (cursor.z > (info.acts.lower or -math:huge(cursor.z)) and (cursor.z < (info.acts.upper or math:huge(cursor.z)))) and
        (alignment > (info.alignment.lower or -math:huge(alignment)) and (alignment < (info.alignment.upper or math:huge(alignment)))) and
        ---@diagnostic disable-next-line: undefined-field
        faction:is_contained_in_faction_set(info.faction_set or "all")
end

function pttg_event_pool:random_event()
    local event_pool_key = "pttg_events"

    pttg_event_pool_manager:new_pool("event_pool_key")

    for event, info in pairs(self.event_pool) do
        if self:is_eligible(event, info) then
            pttg_event_pool_manager:add_event(event_pool_key, event, info.weight)
        end
    end

    return pttg_event_pool_manager:generate_pool(event_pool_key, 1, true)[1]

end

function pttg_event_pool_manager:new_pool(key)
	pttg:log("[pttg_event_pool_manager]Random Event Pool Manager: Creating New Event Pool with key [" .. key .. "]");

	local existing_pool = self:get_pool_by_key(key)

	if existing_pool then
		existing_pool.key = key;
		existing_pool.events = {};
		existing_pool.mandatory_events = {};
		existing_pool.faction = "";
		pttg:log("\tPool with key [" .. key .. "] already exists - resetting pool!");
		return true;
	end
	
    local pool = {};
	pool.key = key;
	pool.events = {};
	pool.mandatory_events = {};
	pool.faction = "";
	table.insert(self.pool_list, pool);
	pttg:log("\tPool with key [" .. key .. "] created!");
	return true;
end

function pttg_event_pool_manager:get_pool_by_key(pool_key)
	for i = 1, #self.pool_list do
		if pool_key == self.pool_list[i].key then
			return self.pool_list[i];
		end;
	end;
	
	return false;
end;

function pttg_event_pool_manager:add_event(pool_key, key, weight)
	local pool_data = self:get_pool_by_key(pool_key);
	
	if pool_data then
		for i = 1, weight do
			table.insert(pool_data.events, key);
		end;
		return;
	end;
	
	self:new_pool(pool_key);
	self:add_event(pool_key, key, weight);
end;

function pttg_event_pool_manager:generate_pool(pool_key, event_count, return_as_table)
	local pool = {};
	local pool_data = self:get_pool_by_key(pool_key);

    if not pool_data then
        pttg:log(string.format("Random Event Pool Manager: no pool data found for %s; Aborting.", pool_key));
        return {}
    end

	if not event_count then
		event_count = #pool_data.mandatory_events
	end
		
	pttg:log("Random Event Pool Manager: Getting Random Pool for pool [" .. pool_key .. "] with size [" .. event_count .. "]");
	
	local mandatory_events_added = 0;
	
	for i = 1, #pool_data.mandatory_events do
		table.insert(pool, pool_data.mandatory_events[i]);
		mandatory_events_added = mandatory_events_added + 1;
	end;
	
	if (event_count - mandatory_events_added) > 0 and #pool_data.events == 0 then
		script_error("Random Event Pool Manager: Tried to add events to pool_key [" .. pool_key .. "] but the pool has not been set up with any non-mandatory events - add them first!");
		return false;
	end;
	
	
	for i = 1, event_count - mandatory_events_added do
		local event_index = cm:random_number(#pool_data.events);
		table.insert(pool, pool_data.events[event_index]);
	end;
	
	if #pool == 0 then
		script_error("Random Event Pool Manager: Did not add any events to pool with pool_key [" .. pool_key .. "] - was the pool created?");
		return false;
	elseif return_as_table then
		return pool;
	else
		return table.concat(pool, ",");
	end;
end;

core:add_listener(
    "init_EventPool",
    "pttg_init_complete",
    true,
    function(context)
        pttg_event_pool:init_events()
    end,
    false
)

core:add_static_object("pttg_event_pool", pttg_event_pool);
