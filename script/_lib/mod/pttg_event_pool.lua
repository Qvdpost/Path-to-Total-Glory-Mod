local pttg = core:get_static_object("pttg");
local pttg_pool_manager = core:get_static_object("pttg_pool_manager")

PttG_Event = {

}

function PttG_Event:new(key, faction_set, weight, acts, alignment, callback)
    local self = {}
    if not key or not faction_set then
        script_error("Cannot add event without a name_key and faction_set.")
        return false
    end

    if not (acts[1] or acts[2] or acts[3]) then
        script_error("Cannot add event without any acts to trigger it.")
        return false
    end

    self.key = key
    self.tier = tier
    self.faction_set = faction_set
    self.acts = acts
    self.weight = weight
    self.alignment = alignment
    self.callback = callback

    setmetatable(self, { __index = PttG_Event })
    return self
end

function PttG_Event.repr(self)
    return string.format("Event(%s): %s, %s", self.key, self.faction_set, self.weight)
end

local pttg_event_pool = {
    event_pool = {},
    active_event_pool = {},
    excluded_event_pool = {}
}

function pttg_event_pool:add_event(event, info)
    local event = PttG_Event:new(event, info.faction_set, info.weight, info.acts, info.alignment, info.callback)
    if not event then
        script_error("Could not add evetn. Skipping")
        return false
    end
    
    pttg:log(string.format('[pttg_event_pool] Adding event: %s', event:repr()))
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
    local events_all = {
        ["pttg_EventGlory"] = { weight = 10, acts = { [1] = true, [2] = true }, alignment = { upper = 10, lower = nil }, faction_set = 'all', callback = pttg_EventGlory_callback },
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
    pttg:log(string.format("[pttg_event_pool] Checking eligibility for: %s with alignment %s at %s.", faction:name(),
        tostring(alignment), tostring(cursor.z)));
    return info.acts[cursor.z] and
        (alignment > (info.alignment.lower or -math:huge(alignment)) and (alignment < (info.alignment.upper or math:huge(alignment)))) and
        ---@diagnostic disable-next-line: undefined-field
        faction:is_contained_in_faction_set(info.faction_set or "all")
end

function pttg_event_pool:random_event()
    local event_pool_key = "pttg_events"

    pttg_pool_manager:new_pool(event_pool_key)

    for event, info in pairs(self.event_pool) do
        if self:is_eligible(event, info) then
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
