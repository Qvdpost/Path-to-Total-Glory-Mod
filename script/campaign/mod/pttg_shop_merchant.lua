local pttg = core:get_static_object("pttg");
local pttg_merc_pool = core:get_static_object("pttg_merc_pool");
local pttg_item_pool = core:get_static_object("pttg_item_pool");
local pttg_pool_manager = core:get_static_object("pttg_pool_manager")
local pttg_glory = core:get_static_object("pttg_glory")

local pttg_glory_shop = {
    shop_items = {
        merchandise = { {}, {}, {}, {} },
        units = { {}, {}, {}, {} }
    },
    active_shop_items = {
    },
    excluded_shop_items = {
    }
}

function pttg_glory_shop:reset_rituals()
    pttg_glory_shop:lock_rituals(self.active_shop_items)
    self.active_shop_items = {}
    core:remove_listener('pttg_merc_unlock')
end

function pttg_glory_shop:unlock_ritual(shop_item)
    pttg:log(string.format('[pttg_glory_shop]Unlocking ritual %s', shop_item.ritual))
    local faction = cm:get_local_faction()

    cm:unlock_ritual(faction, shop_item.ritual, 1)
    self.active_shop_items[shop_item.ritual] = shop_item
    pttg:set_state('active_shop_items', self.active_shop_items)
end

function pttg_glory_shop:unlock_rituals(shop_items)
    local faction = cm:get_local_faction()
    for _, shop_item in pairs(shop_items) do
        pttg:log(string.format('[pttg_glory_shop] Unlocking ritual %s', tostring(shop_item.ritual)))
        cm:unlock_ritual(faction, shop_item.ritual, 1)
        self.active_shop_items[shop_item.ritual] = shop_item
    end
    pttg:set_state('active_shop_items', self.active_shop_items)
end

function pttg_glory_shop:lock_rituals(shop_items)
    pttg:log(string.format('[pttg_glory_shop]Locking rituals %s', #shop_items))
    local faction = cm:get_local_faction()
    for _, shop_item in pairs(shop_items) do
        cm:lock_ritual(faction, shop_item.ritual)
        self.active_shop_items[shop_item.ritual] = nil
    end
    pttg:set_state('active_shop_items', self.active_shop_items)
end

function pttg_glory_shop:lock_ritual(shop_item)
    pttg:log(string.format('[pttg_glory_shop]Locking ritual %s', shop_item.ritual))
    local faction = cm:get_local_faction()

    cm:lock_ritual(faction, shop_item.ritual)
    self.active_shop_items[shop_item.ritual] = nil
    pttg:set_state('active_shop_items', self.active_shop_items)
end

function pttg_glory_shop:init_shop()
    pttg:log(string.format('[pttg_glory_shop] Initialising shop.'))

    self.shop_items.merchandise = pttg_item_pool:get_craftable_items(self.excluded_shop_items)

    self.shop_items.units = pttg_item_pool:get_purchaseable_units()

    self.active_shop_items = pttg:get_state('active_shop_items')
    self.excluded_shop_items = pttg:get_state('excluded_shop_items')

    if #self.active_shop_items > 0 then
        self:enable_shop_button()
    else
        self:disable_shop_button()
    end
end

function pttg_glory_shop:populate_items(num_items, chances, category)
    pttg:log("Populating shop with items from category: "..category)
    local faction = cm:get_local_faction()

    local rando_tiers = { 0, 0, 0 }

    for i = 1, num_items do
        local rando_tier = cm:random_number(100)

        if category == 'units' then
            rando_tier = rando_tier + pttg:get_state('recruit_rarity_offset')
        end

        if rando_tier < chances[1] then
            rando_tiers[1] = rando_tiers[1] + 1
        elseif rando_tier < chances[2] then
            rando_tiers[2] = rando_tiers[2] + 1
        else
            rando_tiers[3] = rando_tiers[3] + 1
        end
    end

    for tier, count in pairs(rando_tiers) do
        if count > 0 then
            local available_pools = self.shop_items[category][tier]

            local shop_pool_key = string.format("pttg_%s_%s_shop", category, tier)
            pttg_pool_manager:new_pool(shop_pool_key)

            for faction_set, items in pairs(available_pools) do
                ---@diagnostic disable-next-line: undefined-field
                if faction:is_contained_in_faction_set(faction_set) then
                    for _, item in pairs(items) do
                        pttg_pool_manager:add_item(shop_pool_key, item, 1)
                    end
                end
            end

            if pttg_pool_manager:get_item_count(shop_pool_key) == 0 then
                pttg:log("Item Pool Manager is empty. Cannot generate any pruchaseable items for tier: "..tier)
            else
                pttg:log(string.format("Generating %s items from a pool of size: %s", count,
                    pttg_pool_manager:get_item_count(shop_pool_key)))
                local purchaseable_items = pttg_pool_manager:generate_pool(shop_pool_key, count, true)
                self:unlock_rituals(purchaseable_items)
            end
        end
    end
end

function pttg_glory_shop:populate_shop()
    local shop_sizes = pttg:get_state('shop_sizes')
    pttg:log(string.format('[pttg_glory_shop] Populating shop with(merch: %i, units:%i)',
        shop_sizes.merchandise,
        shop_sizes.units)
    )

    local cursor = pttg:get_cursor()

    self:populate_items(shop_sizes.merchandise, pttg:get_state('shop_chances'), 'merchandise')
    self:populate_items(shop_sizes.units, pttg:get_state('recruit_chances')[cursor.z], 'units')
end

function pttg_glory_shop:disable_shop_button()
    pttg:log("[pttg_glory_shop] Disabling shop button.")
    local root = core:get_ui_root()

    local button = find_uicomponent(root, "hud_campaign", "faction_buttons_docker", "button_group_management",
        "button_mortuary_cult")

    if not button then
        pttg:log("[pttg_ui] Could not find button.")
        return
    end

    button:SetVisible(false)
    button:SetDisabled(true)
    button:StopPulseHighlight()
    button:Highlight(false)

    return
end

function pttg_glory_shop:enable_shop_button()
    pttg:log("[pttg_glory_shop] Highlighting shop button.")
    local root = core:get_ui_root()

    local button = find_uicomponent(root, "hud_campaign", "faction_buttons_docker", "button_group_management",
        "button_mortuary_cult")

    if not button then
        pttg:log("[pttg_ui] Could not find button.")
        return
    end

    button:SetVisible(true)
    button:SetDisabled(false)
    button:StartPulseHighlight(1)
    button:Highlight(true)

    return
end

local function get_or_create_merchant_glory()
    local docker_uic = find_uicomponent(core:get_ui_root(), "mortuary_cult", "treasury_jars_list")
    local glory_uic = find_uicomponent(docker_uic, "dy_glory")
    local treasury = find_uicomponent(docker_uic, "dy_treasury")

    if glory_uic then
        return glory_uic
    end

    if treasury then
        glory_uic = UIComponent(treasury:CopyComponent("dy_glory"))
        glory_uic_icon = find_uicomponent(glory_uic, "treasury_icon")
        glory_uic_icon:SetImagePath("ui/skins/default/faction_icon_selected.png", 0)
        glory_uic_icon:SetTooltipText("Glory", true)
        glory_uic:SetStateText(tostring(pttg_glory:get_glory_value()), "")
        glory_uic:SetTooltipText("Total Available Glory Points", true)
        glory_uic:SetVisible(true)
        treasury:SetVisible(false)
    end
    
    return glory_uic
end

local function update_merchant_glory()
    local glory_uic = get_or_create_merchant_glory()
    if glory_uic then
        glory_uic:SetStateText(tostring(pttg_glory:get_glory_value()), "")
    end
end

core:add_listener(
    "pttg_MercPanelOpened",
    "PanelOpenedCampaign",
    function(context)
        return context.string == "mortuary_cult"
    end,
    function()
        pttg:log("[pttg_glory_cost] - mortuary_cult panel opened.")
        get_or_create_merchant_glory()
    end,
    true
)

core:add_listener(
    "pttg_Merchant",
    "RitualCompletedEvent",
    function(context)
        return pttg_glory_shop.active_shop_items[context:ritual():ritual_key()]
    end,
    function(context)
        local ritual_key = context:ritual():ritual_key()
        pttg:log(string.format("[pttg_MerchantRecruitRitualCompleted] A item was purchased with %s", ritual_key))
        local shop_item = pttg_glory_shop.active_shop_items[ritual_key]

        if not shop_item then
            return
        end

        pttg:log(string.format("[pttg_MerchantRecruitRitualCompleted] The purchased item is: %s(%s)", shop_item.key, shop_item.category))

        update_merchant_glory()

        if shop_item.category == 'merchandise' then
            pttg_glory_shop.excluded_shop_items[context:ritual():ritual_key()] = true
            pttg:set_state('excluded_shop_items', pttg_glory_shop.excluded_shop_items)
        elseif shop_item.category == 'unit' then
            pttg_merc_pool:add_active_unit(shop_item.key, 1)
            pttg_glory:add_recruit_glory(pttg_merc_pool.merc_units[shop_item.key].cost)

            -- TODO: does not lock it from the shop yet. Update UI??
            pttg_glory_shop:lock_ritual(shop_item)

            local pttg_UI = core:get_static_object("pttg_UI")
            pttg_UI:highlight_recruitment(true)
        end
    end,
    true
)


core:add_listener(
    "pttg_Merchant",
    "pttg_populate_shop",
    true,
    function(context)
        pttg_glory_shop:populate_shop()
        core:trigger_custom_event('pttg_Idle', {})
    end,
    true
)



core:add_listener(
    "init_GloryShop",
    "pttg_init_complete",
    true,
    function(context)
        pttg_glory_shop:init_shop()
    end,
    true
)


core:add_static_object("pttg_glory_shop", pttg_glory_shop);
