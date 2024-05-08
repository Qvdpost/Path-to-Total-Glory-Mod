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

PttG_CampaignEffect = {

}

function PttG_CampaignEffect:new(key, info)
    local self = {}
    if not key or not (type(info.callback) == 'function') then
        script_error("Cannot add a campaign effect without a name_key or a callback.")
        return false
    end
    
    self.key = key
    self.callback = info.callback
    self.args = info.args or {}

    setmetatable(self, { __index = PttG_CampaignEffect })
    return self
end

function PttG_CampaignEffect.repr(self)
    return string.format("CampaignEffect(%s)", self.key)
end

local pttg_effect_pool = {
    effect_pool = {},
    active_effect_pool = {},
    excluded_effect_pool = {},
    campaign_effect_pool = {},
    active_campaign_effects = {},
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

function pttg_effect_pool:add_campaign_effect(key, info)
    if self.campaign_effect_pool[key] then
        script_error("Campaign effect already exists. Skipping "..key)
        return false
    end

    local campaign_effect = PttG_CampaignEffect:new(key, info)
    if not campaign_effect then
        script_error("Could not create campaign effect. Skipping: "..key)
        return false
    end
    pttg:log(string.format(
        '[pttg_effect_pool] Adding campaign effect: %s',
        campaign_effect.key)
    )
    self.campaign_effect_pool[campaign_effect.key] = campaign_effect
end

function pttg_effect_pool:update_campaign_effect_args(key, args)
    pttg_effect_pool.campaign_effect_pool[key].args = args
end

function pttg_effect_pool:activate_campaign_effect(key, args)
    self.active_campaign_effects[key] = args or pttg_effect_pool.campaign_effect_pool[key].args
    cm:set_saved_value('pttg_active_campaign_effects', self.active_campaign_effects)
end

function pttg_effect_pool:deactivate_campaign_effect(key)
    self.active_campaign_effects[key] = nil
    cm:set_saved_value('pttg_active_campaign_effects', self.active_campaign_effects)
end

function pttg_effect_pool:load_campaign_effects()
    self.active_campaign_effects = cm:get_saved_value("pttg_active_campaign_effects") or {}
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

function pttg_effect_pool:apply_campaign_effects()
    for key, args in pairs(self.active_campaign_effects) do
        pttg:log("Applying campaign effect: "..key)
        local campaign_effect = self.campaign_effect_pool[key]
        campaign_effect.callback(unpack(args))
    end
end

function pttg_effect_pool:init_effects()
    local effects_all = {
        
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


