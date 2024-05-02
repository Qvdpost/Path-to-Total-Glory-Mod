local pttg = core:get_static_object("pttg");
local pttg_pool_manager = core:get_static_object("pttg_pool_manager")

PttG_Event = {

}

function PttG_Event:new(key, callback, eligibility_callback, weight)
    local self = {}
        
    self.key = key
    self.weight = weight
    self.callback = callback
    self.eligibility_callback = eligibility_callback

    setmetatable(self, { __index = PttG_Event })
    return self
end

function PttG_Event.repr(self)
    return string.format("Event(%s): %s", self.key, self.weight)
end

local pttg_event_pool = {
    event_pool = {},
    active_event_pool = {},
    excluded_event_pool = {}
}

function pttg_event_pool:add_event(key, info)
    local event = PttG_Event:new(key, info.callback, info.eligibility_callback, info.weight)
    if not event then
        script_error("Could not add event. Skipping")
        return false
    end

    pttg:log(string.format('[pttg_event_pool] Adding event: %s', event:repr()))
    if self.event_pool[event.key] then
        pttg:log("Even already exists. Skipping!")
    end
    self.event_pool[event.key] = event
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
    local events_all = {
        ["pttg_EventGlory"] = { weight = 10, callback = pttg_EventGlory_callback, eligibility_callback = pttg_EventGlory_eligibility_callback },
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

function pttg_event_pool:random_event()
    local event_pool_key = "pttg_events"

    pttg_pool_manager:new_pool(event_pool_key)

    local context = {
        act = pttg:get_cursor().z,
        alignment = pttg:get_state('alignment'),
        faction = cm:get_local_faction()
    }

    for event, info in pairs(self.event_pool) do
        if info.eligibility_callback(context) then
            pttg_pool_manager:add_item(event_pool_key, event, info.weight)
        end
    end

    return pttg_pool_manager:generate_pool(event_pool_key, 1, true)[1]
end

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
