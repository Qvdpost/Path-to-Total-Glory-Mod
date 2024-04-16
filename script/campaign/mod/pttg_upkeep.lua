local pttg = core:get_static_object("pttg");

local pttg_upkeep = {
    callbacks = { {}, {}, {} }
}

function pttg_upkeep:add_callback(name, func, prio)
    if self.callbacks[prio or 3][name] then
        pttg:log(string.format("[pttg_upkeep] Added callback name already exists! Skipping."))
        return false
    end
    self.callbacks[prio or 2][name] = func
    return true
end

function pttg_upkeep:resolve()
    for prio, callbacks in pairs(self.callbacks) do
        for name, callback in pairs(callbacks) do
            pttg:log(string.format("[pttg_upkeep] Executing %s", name))
            callback()
        end
    end
end
