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

PttG_ArmyEffect = {

}

function PttG_ArmyEffect:new(key, info)
    local self = {}
    if not (key or #info.effects == 0 or info.tier) then
        script_error("Cannot add army effect without a name_key, tier or an effect.")
        return false
    end

    self.key = key
    self.effects = info.effects
    self.persistent = info.persistent == nil or info.persistent
    self.tier = info.tier
    local bundle = cm:create_new_custom_effect_bundle(key)
    if not bundle then
        script_error("Invalid bundle key. Check your effect_bundles table.")
        return false
    end
    for _, effect in pairs(info.effects) do
        bundle:add_effect(effect.key, effect.scope, effect.value)
    end
    bundle:set_duration(1)
    self.bundle = bundle

    setmetatable(self, { __index = PttG_ArmyEffect })
    return self
end

function PttG_ArmyEffect.repr(self)
    return string.format("ArmyEffect(%s)", self.key)
end

local pttg_effect_pool = {
    effect_pool = {},
    active_effect_pool = {},
    excluded_effect_pool = {},
    campaign_effect_pool = {},
    active_campaign_effects = {},
    army_effect_pool = { {}, {}, {} },
    excluded_army_effect_pool = {},
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
    pttg:set_state("excluded_effect_pool", self.excluded_effect_pool)
end

function pttg_effect_pool:add_army_effect(key, effect)
    if self.army_effect_pool[key] then
        script_error("Army effect already exists. Skipping "..key)
        return false
    end

    local army_effect = PttG_ArmyEffect:new(key, effect)
    if not army_effect then
        script_error("Could not create army effect. Skipping: "..key)
        return false
    end
    pttg:log(string.format(
        '[pttg_effect_pool] Adding army effect: %s',
        army_effect.key)
    )
    self.army_effect_pool[army_effect.key] = army_effect

    table.insert(self.army_effect_pool[army_effect.tier], army_effect)
end

function pttg_effect_pool:add_army_effects(effects)
    for key, effect in pairs(effects) do
        self:add_army_effect(key, effect)
    end
end

function pttg_effect_pool:get_random_army_effect(tier)
    if tier < 1 or tier > 3 then
        pttg:log("Random army effect of tier ["..tostring(tier).."] not supported.")
        return nil
    end
    local random_army_effect = nil
    local success = false 
    for i = 1, 10 do
        random_army_effect = self.army_effect_pool[tier][cm:random_number(#self.army_effect_pool[tier])]
        if not self.excluded_army_effect_pool[random_army_effect.key] then
            success = true
            break
        end
    end

    if not success then
        script_error("Could not get a unexcluded random army effect. Returning random army effect for tier: "..tostring(tier))
    end
    pttg:log("Random army effect: "..random_army_effect.key)
    return random_army_effect
end

function pttg_effect_pool:get_random_army_effect_bundle(tier)
    if tier == 4 then
        local army_effects = {self:get_random_army_effect(tier-1), self:get_random_army_effect(tier-1)}
        local effects = {}
        for _, army_effect in pairs(army_effects) do
            if not army_effect.pesistent then
                self:exclude_army_effect(army_effect.key)
            end
            for _, effect in pairs(army_effect.effects) do
                table.insert(effects, effect)
            end
        end
        local merged_army_effect = PttG_ArmyEffect:new("temp_bundle", { effects=effects })
        if not merged_army_effect then
            script_error("Failed merging army effects.")
            return nil
        end
        return merged_army_effect.bundle
    end

    local army_effect = self:get_random_army_effect(tier)
    pttg:log("Getting random army effect for tier: "..tostring(tier))

    if army_effect then
        if not army_effect.pesistent then
            self:exclude_army_effect(army_effect.key)
        end
        return army_effect.bundle
    end
    
    script_error("Failed getting a random army effect.")
    return nil
end

function pttg_effect_pool:exclude_army_effect(effect)
    self.excluded_army_effect_pool[effect] = true
    pttg:set_state("excluded_army_effect_pool", self.excluded_army_effect_pool)
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

    -- Requires entries in effect_bundles and localisation
    local army_effects = {
        magic_resist_easy = { tier = 1, effects = { {key = "wh_main_effect_character_stat_magic_resistance", scope = "force_to_force_own", value = 10} }},
        magic_resist_regular = { tier = 2, effects = { {key = "wh_main_effect_character_stat_magic_resistance", scope = "force_to_force_own", value = 30} }},
        magic_resist_hard = { tier = 3, effects = { {key = "wh_main_effect_character_stat_magic_resistance", scope = "force_to_force_own", value = 60} }},
        monster_hunter_easy = { tier = 1, effects = { {key = "wh_main_effect_character_stat_bonus_vs_large", scope = "force_to_force_own", value = 10} }},
        monster_hunter_regular = { tier = 2, effects = { {key = "wh_main_effect_character_stat_bonus_vs_large", scope = "force_to_force_own", value = 20} }},
        monster_hunter_hard = { tier = 3, effects = { {key = "wh_main_effect_character_stat_bonus_vs_large", scope = "force_to_force_own", value = 40} }},
        regenerative_regular = { tier = 2, effects = { {key = "wh2_main_effect_ability_enable_regeneration", scope = "force_to_force_own", value = 1} }},
        regenerative_hard = { tier = 3, effects = { {key = "wh2_main_effect_ability_enable_regeneration", scope = "force_to_force_own", value = 1} }},
        unseen_death = { tier = 3, effects = { {key = "wh2_dlc10_effect_attribute_enable_snipe", scope = "force_to_force_own", value = 1} }, {key = "wh_main_effect_attribute_enable_stalk", scope = "force_to_force_own", value = 1} },
        amaterasu = { tier = 2, effects = { {key = "wh2_main_effect_character_stat_enable_flaming_attacks", scope = "force_to_force_own", value = 1} }},
        gonzalez = { tier = 1, effects = { {key = "wh_main_effect_character_stat_speed", scope = "force_to_force_own", value = 20} }},
        ratatat = { tier = 1, effects = { {key = "wh_main_effect_force_stat_reload_time_reduction", scope = "force_to_force_own", value = 20} }},
        chonkers = { tier = 1, effects = { {key = "wh3_main_effect_force_stat_unit_mass_percentage_mod", scope = "force_to_force_own", value = 20} }},
        matrix_regular = { tier = 2, effects = { {key = "wh_main_effect_force_stat_missile_resistance", scope = "force_to_force_own", value = 20} }},
        matrix_hard = { tier = 3, effects = { {key = "wh_main_effect_force_stat_missile_resistance", scope = "force_to_force_own", value = 35} }},
        bulldozers_easy = { tier = 1, effects = { {key = "wh_main_effect_force_stat_charge_bonus_pct", scope = "force_to_force_own", value = 20} }},
        bulldozers_regular = { tier = 2, effects = { {key = "wh_main_effect_force_stat_charge_bonus_pct", scope = "force_to_force_own", value = 40} }},
    }

    self:add_army_effects(army_effects)

    self.excluded_effect_pool = pttg:get_state('excluded_effect_pool')
    self.excluded_army_effect_pool = pttg:get_state('excluded_army_effect_pool')
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


