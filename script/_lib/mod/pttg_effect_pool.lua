local pttg = core:get_static_object("pttg");
local pttg_pool_manager = core:get_static_object("pttg_pool_manager")

PttG_Effect = {

}

function PttG_Effect:new(key, faction_set, effects, target, acts)
    local self = {}
    if not key or #effects == 0 then
        script_error("Cannot add effect without a name_key or an effect.")
        return false
    end
    if not (acts[1] or acts[2] or acts[3])  then
        script_error("Effect has no available acts.")
        return false
    end
    if target ~= 'faction' or target ~= 'force' or target ~= 'character' then
        script_error("Effect target not eligible.")
        return false
    end
    
    self.key = key
    self.faction_set = faction_set or 'all'
    self.target = target
    self.acts = acts

    local bundle = cm:create_new_custom_effect_bundle(key)
    for _, effect in pairs(effects) do
        bundle:add_effect(effect.key, effect.scope, effect.value)
    end
    bundle:set_duration(0)
    self.bundle = bundle

    setmetatable(self, { __index = PttG_Effect })
    return self
end

function PttG_Effect.repr(self)
    return string.format("Effect(%s): %s, %s.", self.key, self.faction_set, self.target)
end

local pttg_effect_pool = {
    effect_pool = {},
    active_effect_pool = {},
    excluded_effect_pool = {}
}

function pttg_effect_pool:add_effect(effect, bundle)
    pttg:log(string.format(
        '[pttg_effect_pool] Adding effect: %s',
        effect)
    )
    self.effect_pool[effect] = bundle
end

function pttg_effect_pool:add_effects(effects)
    for effect, info in pairs(effects) do
        self:add_effect(effect, info)
    end
end

function pttg_effect_pool:exclude_effect(effect)
    self.excluded_effect_pool[effect] = true
end

function pttg_effect_pool:apply_effect(key)
    local effect = self.effect_pool[key]
    if effect.target == 'faction' then
        local faction = cm:get_local_faction()
        cm:apply_custom_effect_bundle_to_faction(effect.bundle, faction);
    elseif effect.target == 'character' then
        cm:apply_custom_effect_bundle_to_character( effect.bundle, cm:get_military_force_by_cqi(pttg:get_state('army_cqi')):general_character())
    elseif effect.target == 'force' then 
        cm:apply_custom_effect_bundle_to_force(effect.bundle, cm:get_military_force_by_cqi(pttg:get_state('army_cqi')))
    end
end

function pttg_effect_pool:init_effects()
    local effects_all = {
        ["pttg_EventGlory"] = { weight = 10, acts = { [1] = true, [2] = true }, alignment = { upper = 10, lower = nil }, faction_set = 'all', callback = pttg_EventGlory_callback },
    }
    self:add_effects(effects_all)

    self.excluded_effect_pool = pttg:get_state('excluded_effect_pool')
end

core:add_listener(
    "init_EffectPool",
    "pttg_init_complete",
    true,
    function(context)
        pttg_effect_pool:init_effects()
    end,
    false
)

core:add_static_object("pttg_effect_pool", pttg_effect_pool);


