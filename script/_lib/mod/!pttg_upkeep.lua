local pttg = core:get_static_object("pttg");

local pttg_upkeep = {
    callbacks = {},
    valid_phases ={
        ['pttg_init'] = true,
        ['pttg_ChooseStart'] = true,
        ['pttg_Idle'] = true,
        ['pttg_Rewards'] = true,
        ['pttg_ResolveRoom'] = true,
        ['pttg_ChoosePath'] = true,
        ['pttg_EventRoom'] = true,
        ['pttg_RestRoom'] = true,
        ['pttg_TreasureRoom'] = true,
        ['pttg_ShopRoom'] = true,
        ['pttg_EliteRoomBattle'] = true,
        ['pttg_BossRoomBattle'] = true,
        ['pttg_RegularRoomBattle'] = true,
        ['pttg_RecruitReward'] = true,
        ['pttg_PostRoomBattle'] = true
    }
}

function pttg_upkeep:is_valid_phase(phase_key)
    return self.valid_phases[phase_key]
end

function pttg_upkeep:add_callback(phase, name, func, object, payload, prio)
    if not self:is_valid_phase(phase) then
        script_error("Phase ["..phase.."] is not a valid phase to add a callback.")
        return false
    end

    object = object or nil
    payload = payload or {}
    prio = prio or 2
    if self.callbacks[phase][prio][name] then
        pttg:log(string.format("[pttg_upkeep] Added callback name already exists! Skipping."))
        return false
    end

    self.callbacks[phase][prio][name] = { func = func, payload = payload, object = object }
    return true
end

function pttg_upkeep:remove_callback(phase, name)
    for _, callbacks in pairs(self.callbacks[phase]) do
        if callbacks[name] then
            pttg:log(string.format("[pttg_upkeep] Removing callback %s from phase %s.", name, phase))
            callbacks[name] = nil
            return true
        end
    end

    pttg:log(string.format("[pttg_upkeep] Cannot remove callback %s from phase %s, since it does not exist.", name, phase))
    return false
end

function pttg_upkeep:resolve(phase)
    if not self:is_valid_phase(phase) then
        script_error("Phase ["..phase.."] is not a valid phase to add resolve callbacks.")
        return
    end

    pttg:log(string.format("[pttg_upkeep] Resolving upkeep in phase: %s", phase))
    for prio, callbacks in pairs(self.callbacks[phase]) do
        for name, callback in pairs(callbacks) do
            pttg:log(string.format("[pttg_upkeep] Executing %s(%s)", name, prio))
            callback.func(callback.object, unpack(callback.payload))
        end
    end
end

function pttg_upkeep:init()
    for key, _ in pairs(self.valid_phases) do
        self.callbacks[key] = { {}, {}, {} }
    end
end

core:add_static_object("pttg_upkeep", pttg_upkeep);
