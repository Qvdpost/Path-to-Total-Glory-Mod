local pttg = core:get_static_object("pttg");

local pttg_upkeep = {
    callbacks = { {}, {}, {} }
}

function pttg_upkeep:add_callback(name, func, object, payload, prio)
    object = object or nil
    payload = payload or {}
    prio = prio or 2
    if self.callbacks[prio][name] then
        pttg:log(string.format("[pttg_upkeep] Added callback name already exists! Skipping."))
        return false
    end

    self.callbacks[prio][name] = { func = func, payload = payload, object = object }
    return true
end

function pttg_upkeep:resolve()
    pttg:log(string.format("[pttg_upkeep] Resolving upkeep"))
    for prio, callbacks in pairs(self.callbacks) do
        for name, callback in pairs(callbacks) do
            pttg:log(string.format("[pttg_upkeep] Executing %s", name))
            callback.func(callback.object, unpack(callback.payload))
        end
    end
end

core:add_static_object("pttg_upkeep", pttg_upkeep);
