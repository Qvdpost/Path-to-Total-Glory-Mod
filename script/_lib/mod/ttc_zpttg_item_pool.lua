local pttg = core:get_static_object("pttg");
local pttg_merc_pool = core:get_static_object("pttg_merc_pool")

local pttg_item_pool = {
    item_pool = {
        craftable = { {}, {}, {}, {} },
        rewards = { {}, {}, {}, {} }
    },
    unit_pool = {
        craftable = { {}, {}, {}, {} },
        rewards = { {}, {}, {}, {} }
    },
    items = {},
    excluded_items = {}
}

function pttg_item_pool:add_item(item, info)
    pttg:log(string.format('[pttg_item_pool] Adding item: %s (%s, %s, %s, %s)',
            item,
            tostring(info.uniqueness),
            tostring(info.category),
            tostring(info.faction_set),
            tostring(info.ritual)
        )
    )

    local pool = nil
    if info.category == 'unit' then
        pool = self.unit_pool
    else
        pool = self.item_pool
    end

    local tier = self:item_tier(info.uniqueness)

    if pool['rewards'][tier][info.faction_set] then
        table.insert(pool['rewards'][tier][info.faction_set], {item=item, info=info})
    else
        pool['rewards'][tier][info.faction_set] = {{item=item, info=info}}
    end

    if info.ritual then
        if pool['craftable'][tier][info.faction_set] then
            table.insert(pool['craftable'][tier][info.faction_set], {item=item, info=info})
        else
            pool['craftable'][tier][info.faction_set] = {{item=item, info=info}}
        end
    end

    self.items[item] = info
end

function pttg_item_pool:add_items(items)
    for item, info in pairs(items) do
        self:add_item(item, info)
    end
end

function pttg_item_pool:get_craftable_item_rituals(excluded_items)
    return self.item_pool.craftable
end

function pttg_item_pool:get_purchaseable_unit_rituals()
    return self.unit_pool.craftable
end

function pttg_item_pool:item_tier(uniqueness)
    -- wh2_dlc17_anc_group_rune	150	150
    -- wh_main_anc_group_crafted	199	199

    if uniqueness < 30 then -- wh_main_anc_group_common	29	0
        return 1
    elseif uniqueness < 50 then -- wh_main_anc_group_uncommon	49	30
        return 2
    elseif uniqueness < 100 then -- wh_main_anc_group_rare	100	50
        return 3
    else -- wh_main_anc_group_unique	200	200
        return 4
    end

end

function pttg_item_pool:init()

    pttg:log(string.format('[pttg_item_pool] Initialising items.'))

    self:add_item("pttg_glorious_weapon", { ["uniqueness"] = 75, ["category"] = "weapon", ["faction_set"] = "all", ["ritual"] = "pttg_ritual_glorious_weapon"})

    self.excluded_items = pttg:get_state('excluded_items')

    local tier_to_uniqueness = {29, 49, 99}

    for tier, units in pairs(pttg_merc_pool.merc_pool[cm:get_local_faction():culture()]) do
        for _, unit_info in pairs(units) do
            unit_info.uniqueness = tier_to_uniqueness[tier]
            unit_info.category = 'unit'
            unit_info.ritual = "pttg_ritual_"..unit_info.key
            unit_info.faction_set = 'all'
            self:add_item(unit_info.key, unit_info)
        end
    end
end

core:add_listener(
    "init_GloryShop",
    "pttg_init_complete",
    true,
    function(context)
        pttg_item_pool:init()
    end,
    true
)

core:add_static_object("pttg_item_pool", pttg_item_pool);
