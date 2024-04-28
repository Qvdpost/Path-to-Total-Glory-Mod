local pttg = core:get_static_object("pttg");
local pttg_merc_pool = core:get_static_object("pttg_merc_pool")

PttG_Item = {

}

function PttG_Item:new(key, tier, category, faction_set, ritual)
    local self = {}
    if not key or not category or not faction_set then
        script_error("Cannot add item without a name_key, category and faction_set.")
        return false
    end

    self.key = key
    self.tier = tier
    self.category = category
    self.faction_set = faction_set
    self.ritual = ritual

    setmetatable(self, { __index = PttG_Item })
    return self
end

function PttG_Item.repr(self)
    return string.format("Item(%s): %s, %s, %s, %s", self.key, self.faction_set, self.category, self.tier, self.ritual or 'no ritual')
end

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
    local item = PttG_Item:new(item, self:item_tier(info.uniqueness), info.category, info.faction_set, info.ritual)
    if not item then
        pttg:log(string.format("[pttg_item_pool] Cound not add item: %s. Skipping.", item))
        return
    end

    pttg:log(string.format('[pttg_item_pool] Adding item: %s', item:repr()))

    local pool = nil
    if item.category == 'unit' then
        pool = self.unit_pool
    else
        pool = self.item_pool
    end


    if pool['rewards'][item.tier][item.faction_set] then
        table.insert(pool['rewards'][item.tier][item.faction_set], item)
    else
        pool['rewards'][item.tier][item.faction_set] = { item }
    end

    if item.ritual then
        if pool['craftable'][item.tier][item.faction_set] then
            table.insert(pool['craftable'][item.tier][item.faction_set], item)
        else
            pool['craftable'][item.tier][item.faction_set] = { item }
        end
    end

    self.items[item.key] = item
end

function pttg_item_pool:add_items(items)
    for item, info in pairs(items) do
        self:add_item(item, info)
    end
end

function pttg_item_pool:get_craftable_items(excluded_items)
    return self.item_pool.craftable
end

function pttg_item_pool:get_purchaseable_units()
    return self.unit_pool.craftable
end

function pttg_item_pool:get_reward_items(excluded_items)
    return self.item_pool.rewards
end

function pttg_item_pool:item_tier(uniqueness)
    -- wh2_dlc17_anc_group_rune	150	150
    -- wh_main_anc_group_crafted	199	199

    if uniqueness < 30 then      -- wh_main_anc_group_common	29	0
        return 1
    elseif uniqueness < 50 then  -- wh_main_anc_group_uncommon	49	30
        return 2
    elseif uniqueness < 100 then -- wh_main_anc_group_rare	100	50
        return 3
    else                         -- wh_main_anc_group_unique	200	200
        return 4
    end
end

function pttg_item_pool:init()
    pttg:log(string.format('[pttg_item_pool] Initialising items.'))

    self:add_item("pttg_glorious_weapon",
        {
            ["uniqueness"] = 75,
            ["category"] = "weapon",
            ["faction_set"] = "all",
            ["ritual"] =
            "pttg_ritual_glorious_weapon"
        })

    self.excluded_items = pttg:get_state('excluded_items')

    local tier_to_uniqueness = { 29, 49, 99 }

    for tier, units in pairs(pttg_merc_pool:get_pool(cm:get_local_faction_name())) do
        for _, unit_info in pairs(units) do
            unit_info.uniqueness = tier_to_uniqueness[tier]
            unit_info.category = 'unit'
            unit_info.ritual = "pttg_ritual_" .. unit_info.key
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
