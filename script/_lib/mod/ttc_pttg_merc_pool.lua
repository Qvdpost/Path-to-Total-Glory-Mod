local pttg = core:get_static_object("pttg");
local ttc = core:get_static_object("tabletopcaps");
local pttg_pool_manager = core:get_static_object("pttg_pool_manager")

PttG_MercInfo = {
}

function PttG_MercInfo:new(key, category, military_groupings, tier, cost)
    local self = {}
    if not key or not category or #military_groupings == 0 then
        script_error("Cannot add merc without a name_key, category and military_groupings.")
        return false
    end
    self.key = key
    self.category = category
    self.military_groupings = military_groupings
    self.tier = tier or false
    self.weight = false
    self.cost = cost or nil

    setmetatable(self, { __index = PttG_MercInfo })
    return self
end

function PttG_MercInfo.repr(self)
    return string.format("Merc(%s): %s, %s, tier|%s, weight|%s, cost|%s", self.key, '['..table.concat(self.military_groupings, ',')..']', self.category, self.tier, self.weight, self.cost)
end

local pttg_merc_pool = {
    merc_pool = {},
    merc_units = {},
    active_merc_pool = {},
    tiers = { ["core"] = 1, ["special"] = 2, ["rare"] = 3 },
    faction_to_military_grouping = {
        ["wh2_dlc09_skv_clan_rictus"] = "wh2_main_skv",
        ["wh2_dlc13_emp_golden_order"] = "wh_main_group_empire",
        ["wh2_dlc11_vmp_the_barrow_legion"] = "wh_main_group_vampire_counts",
        ["wh2_main_skv_clan_eshin"] = "wh2_main_skv",
        ["wh2_main_skv_clan_skryre"] = "wh2_main_skv_ikit",
        ["wh_main_grn_orcs_of_the_bloody_hand"] = "wh_main_group_greenskins",
        ["wh_dlc08_nor_wintertooth"] = "wh_main_group_norsca",
        ["wh2_main_hef_avelorn"] = "wh2_main_hef",
        ["wh_main_chs_chaos"] = "wh_main_group_chaos",
        ["wh_main_grn_greenskins"] = "wh_main_group_greenskins",
        ["wh2_dlc09_tmb_khemri"] = "wh2_dlc09_tomb_kings",
        ["wh3_main_ogr_goldtooth"] = "wh3_main_ogr",
        ["wh2_dlc15_grn_bonerattlaz"] = "wh_main_group_greenskins",
        ["wh3_main_chs_shadow_legion"] = "wh3_main_group_belakor",
        ["wh_dlc05_wef_wood_elves"] = "wh_dlc05_group_wood_elves",
        ["wh2_dlc17_bst_malagor"] = "wh_dlc03_group_beastmen",
        ["wh3_main_cth_the_northern_provinces"] = "wh3_main_cth",
        ["wh2_dlc17_dwf_thorek_ironbrow"] = "wh_main_group_dwarfs",
        ["wh2_dlc13_lzd_spirits_of_the_jungle"] = "wh2_main_lzd",
        ["wh2_dlc17_lzd_oxyotl"] = "wh2_main_lzd",
        ["wh3_main_kho_exiles_of_khorne"] = "wh3_main_kho",
        ["wh2_main_hef_nagarythe"] = "wh2_main_hef",
        ["wh3_dlc24_tze_the_deceivers"] = "wh3_main_tze",
        ["wh3_dlc20_chs_azazel"] = "wh3_dlc20_group_chs_azazel",
        ["wh2_main_lzd_tlaqua"] = "wh2_main_lzd",
        ["wh3_dlc23_chd_astragoth"] = "wh3_dlc23_group_chaos_dwarfs",
        ["wh2_dlc15_hef_imrik"] = "wh2_main_hef_imrik",
        ["wh3_dlc24_cth_the_celestial_court"] = "wh3_main_cth",
        ["wh3_main_ogr_disciples_of_the_maw"] = "wh3_main_ogr",
        ["wh2_main_def_hag_graef"] = "wh2_main_def",
        ["wh2_dlc15_grn_broken_axe"] = "wh_main_group_greenskins",
        ["wh3_main_emp_cult_of_sigmar"] = "wh_main_group_empire",
        ["wh2_main_def_har_ganeth"] = "wh2_main_def",
        ["wh_dlc03_bst_beastmen"] = "wh_dlc03_group_beastmen",
        ["wh2_main_lzd_hexoatl"] = "wh2_main_lzd",
        ["wh3_dlc24_ksl_daughters_of_the_forest"] = "wh3_main_ksl",
        ["wh2_dlc14_brt_chevaliers_de_lyonesse"] = "wh_main_group_bretonnia",
        ["wh2_main_hef_eataine"] = "wh2_main_hef",
        ["wh2_dlc11_cst_noctilus"] = "wh2_dlc11_group_vampire_coast",
        ["wh2_main_skv_clan_mors"] = "wh2_main_skv",
        ["wh_dlc05_bst_morghur_herd"] = "wh_dlc03_group_beastmen",
        ["wh3_main_sla_seducers_of_slaanesh"] = "wh3_main_sla",
        ["wh2_dlc09_tmb_exiles_of_nehek"] = "wh2_dlc09_tomb_kings",
        ["wh_dlc05_wef_argwylon"] = "wh_dlc05_group_wood_elves",
        ["wh3_dlc20_chs_valkia"] = "wh3_dlc20_group_chs_valkia",
        ["wh2_main_hef_order_of_loremasters"] = "wh2_main_hef",
        ["wh_main_dwf_karak_kadrin"] = "wh_main_group_dwarfs",
        ["wh_main_emp_empire"] = "wh_main_group_empire_reikland",
        ["wh2_twa03_def_rakarth"] = "wh2_main_def",
        ["wh2_dlc16_wef_drycha"] = "wh2_dlc16_group_drycha",
        ["wh_main_brt_bordeleaux"] = "wh_main_group_bretonnia",
        ["wh_main_vmp_vampire_counts"] = "wh_main_group_vampire_counts",
        ["wh2_main_lzd_last_defenders"] = "wh2_main_lzd",
        ["wh2_main_lzd_itza"] = "wh2_main_lzd",
        ["wh2_main_skv_clan_pestilens"] = "wh2_main_skv",
        ["wh_main_brt_bretonnia"] = "wh_main_group_bretonnia",
        ["wh2_main_def_naggarond"] = "wh2_main_def",
        ["wh3_main_tze_oracles_of_tzeentch"] = "wh3_main_tze",
        ["wh2_dlc09_tmb_lybaras"] = "wh2_dlc09_tomb_kings",
        ["wh_main_vmp_schwartzhafen"] = "wh_main_group_vampire_counts",
        ["wh2_dlc12_lzd_cult_of_sotek"] = "wh2_main_lzd",
        ["wh2_dlc11_cst_pirates_of_sartosa"] = "wh2_dlc11_group_vampire_coast_sartosa",
        ["wh_main_grn_crooked_moon"] = "wh_main_group_greenskins",
        ["wh_main_brt_carcassonne"] = "wh_main_group_bretonnia",
        ["wh3_main_ksl_the_great_orthodoxy"] = "wh3_main_ksl",
        ["wh3_main_ksl_the_ice_court"] = "wh3_main_ksl",
        ["wh2_main_hef_yvresse"] = "wh2_main_hef",
        ["wh2_dlc11_cst_vampire_coast"] = "wh2_dlc11_group_vampire_coast",
        ["wh3_dlc20_chs_festus"] = "wh3_dlc20_group_chs_festus",
        ["wh3_dlc23_chd_zhatan"] = "wh3_dlc23_group_chaos_dwarfs",
        ["wh_main_dwf_dwarfs"] = "wh_main_group_dwarfs",
        ["wh2_dlc13_emp_the_huntmarshals_expedition"] = "wh_main_group_empire",
        ["wh2_dlc11_def_the_blessed_dread"] = "wh2_main_def",
        ["wh3_main_nur_poxmakers_of_nurgle"] = "wh3_main_nur",
        ["wh2_dlc11_cst_the_drowned"] = "wh2_dlc11_group_vampire_coast",
        ["wh2_dlc17_bst_taurox"] = "wh_dlc03_group_beastmen",
        ["wh_main_dwf_karak_izor"] = "wh_main_group_dwarfs",
        ["wh3_main_dae_daemon_prince"] = "wh3_main_dae",
        ["wh3_main_dwf_the_ancestral_throng"] = "wh_main_group_dwarfs",
        ["wh2_dlc09_tmb_followers_of_nagash"] = "wh2_dlc09_tomb_kings_arkhan",
        ["wh3_dlc20_chs_vilitch"] = "wh3_dlc20_group_chs_vilitch",
        ["wh3_dlc20_chs_kholek"] = "wh_main_group_chaos",
        ["wh3_main_ksl_ursun_revivalists"] = "wh3_main_ksl",
        ["wh3_dlc23_chd_legion_of_azgorh"] = "wh3_dlc23_group_chaos_dwarfs",
        ["wh2_dlc16_wef_sisters_of_twilight"] = "wh_dlc05_group_wood_elves",
        ["wh2_main_def_cult_of_pleasure"] = "wh3_main_def_morathi",
        ["wh_dlc08_nor_norsca"] = "wh_main_group_norsca",
        ["wh3_main_cth_the_western_provinces"] = "wh3_main_cth",
        ["wh3_main_vmp_caravan_of_blue_roses"] = "wh_main_group_vampire_counts",
        ["wh2_main_skv_clan_moulder"] = "wh2_main_skv",
        ["wh3_dlc20_chs_sigvald"] = "wh_main_group_chaos",
        ["pttg_brt_bretonnia"] = "wh_main_group_bretonnia",
        ["pttg_bst_beastmen"] = "wh_dlc03_group_beastmen",
        ["pttg_chs_chaos"] = "wh_main_group_chaos",
        ["pttg_cst_vampire_coast"] = "wh2_dlc11_group_vampire_coast",
        ["pttg_def_dark_elves"] = "wh2_main_def",
        ["pttg_dwf_dwarfs"] = "wh_main_group_dwarfs",
        ["pttg_emp_empire"] = "wh_main_group_empire",
        ["pttg_grn_greenskins"] = "wh_main_group_greenskins",
        ["pttg_grn_savage_orcs"] = "wh_main_group_savage_orcs",
        ["pttg_hef_high_elves"] = "wh2_main_hef",
        ["pttg_kho_khorne"] = "wh3_main_kho",
        ["pttg_lzd_lizardmen"] = "wh2_main_lzd",
        ["pttg_nor_norsca"] = "wh_main_group_norsca",
        ["pttg_nur_nurgle"] = "wh3_main_nur",
        ["pttg_ogr_ogre_kingdoms"] = "wh3_main_ogr",
        ["pttg_skv_skaven"] = "wh2_main_skv",
        ["pttg_sla_slaanesh"] = "wh3_main_sla",
        ["pttg_tmb_tomb_kings"] = "wh2_dlc09_tomb_kings",
        ["pttg_tze_tzeentch"] = "wh3_main_tze",
        ["pttg_vmp_strygos_empire"] = "wh_main_group_vampire_counts",
        ["pttg_vmp_vampire_counts"] = "wh_main_group_vampire_counts",
        ["pttg_wef_forest_spirits"] = "wh2_dlc16_group_drycha",
        ["pttg_wef_wood_elves"] = "wh_dlc05_group_wood_elves",
        ["pttg_ksl_kislev"] = "wh3_main_ksl",
        ["pttg_chd_chaos_dwarfs"] = "wh3_dlc23_group_chaos_dwarfs",
        ["pttg_cth_cathay"] = "wh3_main_cth",
    }
        
}

-- TODO: implement special rules
local units_with_special_rules = {
    { "wh2_main_skv_inf_plague_monks",                  { subtype = "wh2_main_skv_lord_skrolk" } },
    { "wh3_dlc23_chd_inf_infernal_guard",               { subtype = "wh3_dlc23_chd_drazhoath" } },
    { "wh3_dlc23_chd_inf_infernal_guard_fireglaives",   { subtype = "wh3_dlc23_chd_drazhoath" } },
    { "wh3_dlc23_chd_inf_infernal_guard_great_weapons", { subtype = "wh3_dlc23_chd_drazhoath" } }
}


function pttg_merc_pool:reset_merc_pool()
    for _, tiers in pairs(self.merc_pool) do
        for _, units in ipairs(tiers) do
            for _, unit_info in ipairs(units) do
                unit = unit_info.key
                self:add_unit_to_pool(unit, 0)
            end
        end
    end
end

function pttg_merc_pool:get_tier(group)
    local tier = self.tiers[group]

    if not tier then
        return 4
    end

    return tier
end

local function get_weight(weight)
    local max = 3
    local min = 1
    local value = (max - weight) / (max - min)
    return ((value) * (max - min) + min)
end

function pttg_merc_pool:init_merc_pool()
    pttg:log(string.format("[pttg_MercPool] Initialising units merc pool."))

    for _, military_group in pairs(self.faction_to_military_grouping) do
        self.merc_pool[military_group] = { {}, {}, {}, {} }
    end

    for unit_key, info in pairs(ttc.units) do
        local merc_info = self.merc_units[unit_key]
        if merc_info then
            

            merc_info.weight = get_weight(info.weight)
            merc_info.tier = merc_info.tier or self:get_tier(info.group)
            if not merc_info.cost then
                merc_info.cost = 2
            end

            pttg:log(string.format("[pttg_MercPool] Adding unit %s", merc_info:repr()))

            for _, military_group in pairs(merc_info.military_groupings) do
                pttg:log(string.format("[pttg_MercPool] Inserting in %s at %s", military_group, merc_info.tier))
                if self.merc_pool[military_group] then
                    table.insert(self.merc_pool[military_group][merc_info.tier], merc_info)
                end
            end
        end
    end
end

function pttg_merc_pool:add_unit(unit_info)
    local extra_info = unit_info[4]
    self.merc_units[unit_info[1]] = PttG_MercInfo:new(unit_info[1], extra_info.category, extra_info.military_groupings, extra_info.tier, extra_info.cost)
end

function pttg_merc_pool:add_unit_list(units)
    for _, unit in pairs(units) do
        self:add_unit(unit)
    end
end

function pttg_merc_pool:init_active_merc_pool()
    self.active_merc_pool = pttg:get_state('recruitable_mercs')

    for unit, count in pairs(self.active_merc_pool) do
        self:add_unit_to_pool(unit, count)
    end
end

function pttg_merc_pool:reset_active_merc_pool()
    for unit, count in pairs(self.active_merc_pool) do
        self:add_unit_to_pool(unit, 0)
    end
    self.active_merc_pool = {}
    pttg:set_state("recruitable_mercs", self.active_merc_pool)
end

function pttg_merc_pool:add_unit_to_pool(unit, count)
    pttg:log(string.format("[pttg_RewardChosenRecruit] Recruiting %s(%s)", unit, tostring(count)))

    local faction = cm:get_local_faction()

    cm:add_unit_to_faction_mercenary_pool(
        faction,
        unit,
        "pttg_raise_dead",
        count, 0, 20, count,
        "", "", "",
        false, "pttg_" .. unit
    )
end

function pttg_merc_pool:add_active_unit(unit, count)
    if self.active_merc_pool[unit] then
        self.active_merc_pool[unit] = self.active_merc_pool[unit] + count
    else
        self.active_merc_pool[unit] = count
    end
    pttg:set_state('recruitable_mercs', self.active_merc_pool)
end

function pttg_merc_pool:add_active_units(units)
    for _, unit in pairs(units) do
        pttg:log("[pttg_merc_pool]Adding active recruitable unit [" .. unit .. "]");
        if self.active_merc_pool[unit] then
            self.active_merc_pool[unit] = self.active_merc_pool[unit] + 1
        else
            self.active_merc_pool[unit] = 1
        end
    end

    for unit, count in pairs(self:get_active_units_with_counts()) do
        pttg_merc_pool:add_unit_to_pool(unit, count)
    end

    pttg:set_state('recruitable_mercs', self.active_merc_pool)
end

function pttg_merc_pool:get_active_units()
    local units = {}
    for unit, count in pairs(self.active_merc_pool) do
        for i = 1, count do
            table.insert(units, unit)
        end
    end
end

function pttg_merc_pool:get_active_units_with_counts()
    return self.active_merc_pool
end

function pttg_merc_pool:get_pool(faction_name)
    pttg:log("Getting mercenary pool")
    local military_grouping = self.faction_to_military_grouping[faction_name]
    pttg:log("Getting pool ["..military_grouping.."] for faction with name: "..faction_name)
    if not self.merc_pool[military_grouping] then
        script_error("Could not find a mercenary pool for given military grouping.")
        return false
    end
    return self.merc_pool[military_grouping]
end

function pttg_merc_pool:trigger_recruitment(amount, recruit_chances, unique_only)
    local faction = cm:get_local_faction()
    pttg:log(string.format("[pttg_RecruitReward] Recruiting units for %s", faction:culture()))

    recruit_chances = recruit_chances or pttg:get_state('recruit_chances')

    local rando_tiers = { 0, 0, 0 }

    for i = 1, amount do
        local offset = pttg:get_state('recruit_rarity_offset')
        local rando_tier = cm:random_number(100) - offset
        pttg:log(string.format("[pttg_RecruitReward] Adding tier for roll %s(%s)", rando_tier, offset))
        if rando_tier < recruit_chances[1] then
            rando_tiers[1] = rando_tiers[1] + 1
            pttg:set_state('recruit_rarity_offset', math.min(40, offset + 1))
        elseif rando_tier < recruit_chances[2] then
            rando_tiers[2] = rando_tiers[2] + 1
        else
            rando_tiers[3] = rando_tiers[3] + 1
            pttg:set_state('recruit_rarity_offset', -5)
        end
    end

    local merc_pool = self:get_pool(faction:name())
    if not merc_pool then
        script_error("No available merc pool for faction: "..faction:name())
        return false
    end

    for tier, count in pairs(rando_tiers) do
        if count > 0 then
            pttg:log(string.format("[pttg_RecruitReward] Adding %s units of tier %s", count, tier))
            local available_merc_pool = merc_pool[tier]


            local recruit_pool_key = "pttg_recruit_reward"
            pttg_pool_manager:new_pool(recruit_pool_key)

            for _, merc in pairs(available_merc_pool) do
                pttg_pool_manager:add_item(recruit_pool_key, merc.key, merc.weight)
            end

            pttg_merc_pool:add_active_units(pttg_pool_manager:generate_pool(recruit_pool_key, count, true, unique_only))
        end
    end
end

ttc.add_post_setup_callback(
    function()
        pttg_merc_pool:reset_merc_pool()
        pttg_merc_pool:init_merc_pool()
    end
);

local function init_merc_list()
    local mercenaries = {
        {"wh3_main_cth_inf_jade_warrior_crossbowmen_0", "core", 2, { military_groupings = {"wh3_main_cth","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh3_main_cth_inf_jade_warrior_crossbowmen_1", "core", 2, { military_groupings = {"wh3_main_cth","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh3_main_cth_inf_jade_warriors_0", "core", 2, { military_groupings = {"wh3_main_cth","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_cth_inf_jade_warriors_1", "core", 2, { military_groupings = {"wh3_main_cth","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_cth_inf_peasant_archers_0", "core", 1, { military_groupings = {"wh3_main_cth","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair"}, category = "inf_ranged", tier = nil, cost = 1 }},
        {"wh3_main_cth_inf_peasant_spearmen_1", "core", 1, { military_groupings = {"wh2_main_rogue_morrsliebs_howlers","wh3_main_cth","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_main_cth_cav_peasant_horsemen_0", "core", 1, { military_groupings = {"wh3_main_cth"}, category = "war_beast", tier = nil, cost = 1 }},
        {"wh3_main_cth_inf_iron_hail_gunners_0", "core", 3, { military_groupings = {"wh3_main_cth","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh3_main_cth_cav_jade_lancers_0", "special", 1, { military_groupings = {"wh3_main_cth"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh3_main_cth_art_grand_cannon_0", "special", 2, { military_groupings = {"wh3_main_cth"}, category = "artillery", tier = nil, cost = 2 }},
        {"wh3_main_cth_inf_crane_gunners_0", "special", 2, { military_groupings = {"wh3_main_cth","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh3_main_cth_veh_sky_junk_0", "special", 3, { military_groupings = {"wh3_main_cth"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh3_main_cth_veh_sky_lantern_0", "special", 1, { military_groupings = {"wh3_main_cth"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh3_main_cth_inf_dragon_guard_0", "rare", 1, { military_groupings = {"wh2_main_rogue_celestial_storm","wh3_main_cth","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_cth_inf_dragon_guard_crossbowmen_0", "rare", 1, { military_groupings = {"wh3_main_cth","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh3_main_cth_cav_jade_longma_riders_0", "rare", 2, { military_groupings = {"wh3_main_cth"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh3_main_cth_art_fire_rain_rocket_battery_0", "rare", 2, { military_groupings = {"wh3_main_cth"}, category = "artillery", tier = nil, cost = 2 }},
        {"wh3_main_cth_mon_terracotta_sentinel_0", "rare", 3, { military_groupings = {"wh3_main_cth"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_cth_veh_war_compass_0", "rare", 2, { military_groupings = {"wh3_main_cth"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh3_main_kho_inf_bloodletters_0", "core", 2, { military_groupings = {"wh3_dlc20_group_chs_valkia","wh3_main_dae","wh3_main_group_belakor","wh3_main_kho","wh3_main_pro_kho"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_kho_inf_chaos_warhounds_0", "core", 3, { military_groupings = {"wh3_main_dae","wh3_main_kho","wh3_main_pro_kho"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_main_kho_inf_chaos_warriors_0", "core", 1, { military_groupings = {"wh2_main_rogue_hung_warband","wh3_dlc20_group_chs_valkia","wh3_main_dae","wh3_main_group_belakor","wh3_main_kho","wh3_main_pro_kho","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_main_kho_inf_chaos_warriors_1", "core", 1, { military_groupings = {"wh3_dlc20_group_chs_valkia","wh3_main_dae","wh3_main_group_belakor","wh3_main_kho","wh3_main_pro_kho","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_main_kho_inf_chaos_warriors_2", "core", 1, { military_groupings = {"wh3_dlc20_group_chs_valkia","wh3_main_dae","wh3_main_group_belakor","wh3_main_kho","wh3_main_pro_kho","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_main_kho_inf_bloodletters_1", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_valkia","wh3_main_dae","wh3_main_group_belakor","wh3_main_kho","wh3_main_pro_kho"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_kho_cav_bloodcrushers_0", "special", 2, { military_groupings = {"wh3_main_dae","wh3_main_kho","wh3_main_pro_kho"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh3_main_kho_cav_gorebeast_chariot", "special", 1, { military_groupings = {"wh3_dlc20_group_chs_valkia","wh3_main_dae","wh3_main_group_belakor","wh3_main_kho","wh_main_group_chaos"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh3_main_kho_mon_khornataurs_0", "special", 3, { military_groupings = {"wh3_main_dae","wh3_main_kho","wh3_main_pro_kho"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_kho_mon_khornataurs_1", "special", 3, { military_groupings = {"wh3_main_dae","wh3_main_kho"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_kho_inf_flesh_hounds_of_khorne_0", "special", 1, { military_groupings = {"wh3_dlc20_group_chs_valkia","wh3_main_dae","wh3_main_kho"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_kho_inf_chaos_furies_0", "special", 1, { military_groupings = {"wh3_main_dae","wh3_main_kho","wh3_main_pro_kho"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_main_kho_cav_skullcrushers_0", "rare", 2, { military_groupings = {"wh3_dlc20_group_chs_valkia","wh3_main_dae","wh3_main_group_belakor","wh3_main_kho","wh_main_group_chaos"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh3_main_kho_mon_bloodthirster_0", "rare", 3, { military_groupings = {"wh3_dlc20_group_chs_valkia","wh3_main_dae","wh3_main_kho"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_kho_mon_soul_grinder_0", "rare", 2, { military_groupings = {"wh3_dlc20_group_chs_valkia","wh3_main_dae","wh3_main_kho"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh3_main_kho_mon_spawn_of_khorne_0", "rare", 1, { military_groupings = {"wh3_dlc20_group_chs_valkia","wh3_main_dae","wh3_main_group_belakor","wh3_main_kho","wh3_main_pro_kho","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_kho_veh_blood_shrine_0", "rare", 1, { military_groupings = {"wh3_main_dae","wh3_main_kho"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh3_main_kho_veh_skullcannon_0", "rare", 2, { military_groupings = {"wh3_dlc20_group_chs_valkia","wh3_main_dae","wh3_main_kho"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh3_main_ksl_cav_winged_lancers_0", "core", 3, { military_groupings = {"wh3_main_ksl"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh3_main_ksl_inf_armoured_kossars_0", "core", 2, { military_groupings = {"wh3_main_ksl"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh3_main_ksl_inf_armoured_kossars_1", "core", 2, { military_groupings = {"wh3_main_ksl"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh3_main_ksl_cav_horse_archers_0", "core", 3, { military_groupings = {"wh3_main_ksl"}, category = "war_beast", tier = nil, cost = 1 }},
        {"wh3_main_ksl_cav_horse_raiders_0", "core", 3, { military_groupings = {"wh3_main_ksl"}, category = "war_beast", tier = nil, cost = 1 }},
        {"wh3_main_ksl_inf_kossars_0", "core", 1, { military_groupings = {"wh3_main_ksl"}, category = "inf_ranged", tier = nil, cost = 1 }},
        {"wh3_main_ksl_inf_kossars_1", "core", 1, { military_groupings = {"wh3_main_ksl"}, category = "inf_ranged", tier = nil, cost = 1 }},
        {"wh3_main_ksl_inf_streltsi_0", "core", 3, { military_groupings = {"wh3_main_ksl"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh3_main_ksl_cav_war_bear_riders_1", "special", 3, { military_groupings = {"wh3_main_ksl"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh3_main_ksl_cav_gryphon_legion_0", "special", 2, { military_groupings = {"wh3_main_ksl"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh3_main_ksl_inf_tzar_guard_0", "special", 2, { military_groupings = {"wh3_main_ksl"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_ksl_inf_tzar_guard_1", "special", 2, { military_groupings = {"wh3_main_ksl"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_ksl_veh_heavy_war_sled_0", "special", 3, { military_groupings = {"wh3_main_ksl"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh3_main_ksl_veh_light_war_sled_0", "special", 2, { military_groupings = {"wh3_main_ksl"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh3_main_ksl_mon_elemental_bear_0", "rare", 3, { military_groupings = {"wh3_main_ksl"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_ksl_mon_snow_leopard_0", "rare", 1, { military_groupings = {"wh3_main_ksl"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_ksl_veh_little_grom_0", "rare", 2, { military_groupings = {"wh3_main_ksl"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh3_main_ksl_inf_ice_guard_0", "rare", 1, { military_groupings = {"wh3_main_ksl"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh3_main_ksl_inf_ice_guard_1", "rare", 1, { military_groupings = {"wh3_main_ksl"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh3_main_nur_inf_forsaken_0", "core", 3, { military_groupings = {"wh3_main_dae","wh3_main_nur"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_nur_inf_nurglings_0", "core", 1, { military_groupings = {"wh3_dlc20_group_chs_festus","wh3_main_dae","wh3_main_nur"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_main_nur_inf_plaguebearers_0", "core", 2, { military_groupings = {"wh3_dlc20_group_chs_festus","wh3_main_dae","wh3_main_group_belakor","wh3_main_nur"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_nur_mon_plague_toads_0", "core", 3, { military_groupings = {"wh3_main_dae","wh3_main_nur"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_nur_cav_pox_riders_of_nurgle_0", "special", 2, { military_groupings = {"wh3_main_dae","wh3_main_nur"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh3_main_nur_inf_chaos_furies_0", "special", 1, { military_groupings = {"wh3_main_dae","wh3_main_nur"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_main_nur_mon_beast_of_nurgle_0", "special", 1, { military_groupings = {"wh2_main_rogue_abominations","wh3_dlc20_group_chs_festus","wh3_main_dae","wh3_main_nur"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_nur_inf_plaguebearers_1", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_festus","wh3_main_dae","wh3_main_group_belakor","wh3_main_nur"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_nur_mon_rot_flies_0", "special", 1, { military_groupings = {"wh3_main_dae","wh3_main_nur"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_nur_cav_plague_drones_0", "rare", 1, { military_groupings = {"wh3_dlc20_group_chs_festus","wh3_main_dae","wh3_main_nur"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh3_main_nur_cav_plague_drones_1", "rare", 1, { military_groupings = {"wh3_main_dae","wh3_main_nur"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh3_main_nur_mon_great_unclean_one_0", "rare", 3, { military_groupings = {"wh3_dlc20_group_chs_festus","wh3_main_dae","wh3_main_nur"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_nur_mon_soul_grinder_0", "rare", 2, { military_groupings = {"wh3_dlc20_group_chs_festus","wh3_main_dae","wh3_main_nur"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh3_main_nur_mon_spawn_of_nurgle_0", "rare", 1, { military_groupings = {"wh3_main_dae","wh3_main_nur"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_ogr_inf_gnoblars_0", "core", 1, { military_groupings = {"wh3_main_ogr"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_main_ogr_inf_gnoblars_1", "core", 1, { military_groupings = {"wh2_main_rogue_stuff_snatchers","wh3_main_ogr"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_main_ogr_inf_ogres_0", "core", 2, { military_groupings = {"wh3_main_ogr","wh3_main_rogue_the_challenge_stone_pact"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_ogr_inf_ogres_1", "core", 2, { military_groupings = {"wh3_main_ogr","wh3_main_rogue_the_challenge_stone_pact"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_ogr_inf_ogres_2", "core", 2, { military_groupings = {"wh3_main_ogr","wh3_main_rogue_the_challenge_stone_pact"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_ogr_cav_mournfang_cavalry_0", "special", 2, { military_groupings = {"wh3_main_ogr"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh3_main_ogr_cav_mournfang_cavalry_1", "special", 2, { military_groupings = {"wh3_main_ogr"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh3_main_ogr_cav_mournfang_cavalry_2", "special", 2, { military_groupings = {"wh3_main_ogr"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh3_main_ogr_inf_ironguts_0", "special", 1, { military_groupings = {"wh3_main_ogr","wh3_main_rogue_the_challenge_stone_pact"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_ogr_inf_leadbelchers_0", "special", 2, { military_groupings = {"wh3_main_ogr","wh3_main_rogue_the_challenge_stone_pact"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh3_main_ogr_inf_maneaters_0", "special", 2, { military_groupings = {"wh2_dlc11_group_vampire_coast_sartosa","wh3_main_ogr","wh3_main_rogue_the_challenge_stone_pact"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_ogr_inf_maneaters_1", "special", 2, { military_groupings = {"wh3_main_ogr","wh3_main_rogue_the_challenge_stone_pact"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_ogr_inf_maneaters_2", "special", 2, { military_groupings = {"wh3_main_ogr","wh3_main_rogue_the_challenge_stone_pact"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_ogr_inf_maneaters_3", "special", 2, { military_groupings = {"wh2_dlc11_group_vampire_coast_sartosa","wh3_main_ogr","wh3_main_rogue_the_challenge_stone_pact"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh3_main_ogr_mon_gorgers_0", "special", 2, { military_groupings = {"wh2_main_rogue_beastcatchas","wh3_main_ogr"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_ogr_mon_sabretusk_pack_0", "special", 1, { military_groupings = {"wh3_main_ogr"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_ogr_mon_giant_0", "rare", 2, { military_groupings = {"wh3_main_ogr"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_ogr_mon_stonehorn_0", "rare", 2, { military_groupings = {"wh3_main_ogr"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh3_main_ogr_mon_stonehorn_1", "rare", 3, { military_groupings = {"wh3_main_ogr"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh3_main_ogr_veh_gnoblar_scraplauncher_0", "rare", 1, { military_groupings = {"wh3_main_ogr"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh3_main_ogr_veh_ironblaster_0", "rare", 2, { military_groupings = {"wh3_main_ogr"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh3_main_ogr_cav_crushers_0", "rare", 2, { military_groupings = {"wh3_main_ogr"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh3_main_ogr_cav_crushers_1", "rare", 2, { military_groupings = {"wh3_main_ogr"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh3_main_sla_inf_marauders_0", "core", 1, { military_groupings = {"wh3_main_dae","wh3_main_sla"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_main_sla_inf_marauders_1", "core", 1, { military_groupings = {"wh3_main_dae","wh3_main_sla"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_main_sla_inf_marauders_2", "core", 1, { military_groupings = {"wh3_main_dae","wh3_main_sla"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_main_sla_inf_daemonette_0", "core", 3, { military_groupings = {"wh3_dlc20_group_chs_azazel","wh3_main_dae","wh3_main_def_morathi","wh3_main_group_belakor","wh3_main_sla"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_sla_cav_hellstriders_0", "core", 1, { military_groupings = {"wh3_dlc20_group_chs_azazel","wh3_main_dae","wh3_main_group_belakor","wh3_main_sla","wh_main_group_chaos"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh3_main_sla_cav_hellstriders_1", "core", 1, { military_groupings = {"wh3_dlc20_group_chs_azazel","wh3_main_dae","wh3_main_group_belakor","wh3_main_sla","wh_main_group_chaos"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh3_main_sla_cav_seekers_of_slaanesh_0", "special", 2, { military_groupings = {"wh3_main_dae","wh3_main_sla"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh3_main_sla_inf_chaos_furies_0", "special", 1, { military_groupings = {"wh3_main_dae","wh3_main_sla"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_main_sla_inf_daemonette_1", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_azazel","wh3_main_dae","wh3_main_def_morathi","wh3_main_group_belakor","wh3_main_sla"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_sla_mon_fiends_of_slaanesh_0", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_azazel","wh3_main_dae","wh3_main_sla"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_sla_veh_seeker_chariot_0", "special", 1, { military_groupings = {"wh3_dlc20_group_chs_azazel","wh3_main_dae","wh3_main_sla"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh3_main_sla_mon_keeper_of_secrets_0", "rare", 3, { military_groupings = {"wh3_dlc20_group_chs_azazel","wh3_main_dae","wh3_main_sla"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_sla_cav_heartseekers_of_slaanesh_0", "rare", 2, { military_groupings = {"wh3_main_dae","wh3_main_sla"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh3_main_sla_mon_soul_grinder_0", "rare", 2, { military_groupings = {"wh3_dlc20_group_chs_azazel","wh3_main_dae","wh3_main_sla"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_sla_mon_spawn_of_slaanesh_0", "rare", 1, { military_groupings = {"wh3_dlc20_group_chs_azazel","wh3_main_dae","wh3_main_group_belakor","wh3_main_sla","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_sla_veh_exalted_seeker_chariot_0", "rare", 2, { military_groupings = {"wh3_main_dae","wh3_main_sla"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh3_main_sla_veh_hellflayer_0", "rare", 2, { military_groupings = {"wh3_main_dae","wh3_main_sla"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh3_main_tze_inf_forsaken_0", "core", 3, { military_groupings = {"wh3_dlc20_group_chs_vilitch","wh3_main_dae","wh3_main_group_belakor","wh3_main_pro_tze","wh3_main_tze","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_tze_inf_pink_horrors_0", "core", 2, { military_groupings = {"wh3_dlc20_group_chs_vilitch","wh3_main_dae","wh3_main_group_belakor","wh3_main_pro_tze","wh3_main_tze"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh3_main_tze_inf_blue_horrors_0", "core", 1, { military_groupings = {"wh3_main_dae","wh3_main_pro_tze","wh3_main_tze"}, category = "inf_ranged", tier = nil, cost = 1 }},
        {"wh3_main_tze_inf_pink_horrors_1", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_vilitch","wh3_main_dae","wh3_main_group_belakor","wh3_main_pro_tze","wh3_main_tze"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh3_main_tze_cav_chaos_knights_0", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_vilitch","wh3_main_dae","wh3_main_pro_tze","wh3_main_tze","wh_main_group_chaos"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh3_main_tze_mon_screamers_0", "special", 1, { military_groupings = {"wh3_main_dae","wh3_main_tze"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_tze_mon_flamers_0", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_vilitch","wh3_main_dae","wh3_main_pro_tze","wh3_main_tze"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh3_main_tze_inf_chaos_furies_0", "special", 1, { military_groupings = {"wh3_main_dae","wh3_main_pro_tze","wh3_main_tze"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_main_tze_cav_doom_knights_0", "rare", 2, { military_groupings = {"wh3_dlc20_group_chs_vilitch","wh3_main_dae","wh3_main_group_belakor","wh3_main_pro_tze","wh3_main_tze","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_tze_mon_exalted_flamers_0", "rare", 2, { military_groupings = {"wh3_main_dae","wh3_main_pro_tze","wh3_main_tze"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh3_main_tze_mon_lord_of_change_0", "rare", 3, { military_groupings = {"wh3_dlc20_group_chs_vilitch","wh3_main_dae","wh3_main_pro_tze","wh3_main_tze"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_tze_mon_soul_grinder_0", "rare", 2, { military_groupings = {"wh3_dlc20_group_chs_vilitch","wh3_main_dae","wh3_main_tze"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh3_main_tze_mon_spawn_of_tzeentch_0", "rare", 1, { military_groupings = {"wh3_dlc20_group_chs_vilitch","wh3_main_dae","wh3_main_group_belakor","wh3_main_pro_tze","wh3_main_tze","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_tze_veh_burning_chariot_0", "rare", 2, { military_groupings = {"wh3_main_dae","wh3_main_tze"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh3_main_dae_inf_chaos_furies_0", "special", 1, { military_groupings = {"wh3_dlc20_group_chs_azazel","wh3_dlc20_group_chs_festus","wh3_dlc20_group_chs_valkia","wh3_dlc20_group_chs_vilitch","wh3_main_dae"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_dlc20_chs_cav_chaos_chariot_mkho", "core", 1, { military_groupings = {"wh3_dlc20_group_chs_valkia","wh3_main_group_belakor","wh3_main_kho","wh_main_group_chaos"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_cav_chaos_chariot_mnur", "core", 1, { military_groupings = {"wh3_dlc20_group_chs_festus","wh3_main_group_belakor","wh3_main_nur","wh_main_group_chaos"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_cav_chaos_chariot_msla", "core", 1, { military_groupings = {"wh3_dlc20_group_chs_azazel","wh3_main_group_belakor","wh3_main_sla","wh_main_group_chaos"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_cav_chaos_chariot_mtze", "core", 1, { military_groupings = {"wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh3_main_tze","wh_main_group_chaos"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_inf_chaos_marauders_mkho", "core", 1, { military_groupings = {"wh3_dlc20_group_chs_valkia","wh3_main_group_belakor","wh3_main_kho","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_dlc20_chs_inf_chaos_marauders_mkho_dualweapons", "core", 1, { military_groupings = {"wh3_dlc20_group_chs_valkia","wh3_main_dae","wh3_main_group_belakor","wh3_main_kho","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_dlc20_chs_inf_chaos_marauders_mnur", "core", 1, { military_groupings = {"wh3_dlc20_group_chs_festus","wh3_main_dae","wh3_main_group_belakor","wh3_main_nur","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_dlc20_chs_inf_chaos_marauders_mnur_greatweapons", "core", 1, { military_groupings = {"wh3_dlc20_group_chs_festus","wh3_main_group_belakor","wh3_main_nur","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_dlc20_chs_inf_chaos_marauders_msla", "core", 1, { military_groupings = {"wh3_dlc20_group_chs_azazel","wh3_main_group_belakor","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_dlc20_chs_inf_chaos_marauders_msla_hellscourges", "core", 1, { military_groupings = {"wh3_dlc20_group_chs_azazel","wh3_main_group_belakor","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_dlc20_chs_inf_chaos_marauders_mtze", "core", 1, { military_groupings = {"wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh3_main_tze","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_dlc20_chs_inf_chaos_marauders_mtze_spears", "core", 1, { military_groupings = {"wh3_dlc20_group_chs_vilitch","wh3_main_dae","wh3_main_group_belakor","wh3_main_tze","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_dlc20_chs_inf_chaos_warriors_mnur", "core", 2, { military_groupings = {"wh3_dlc20_group_chs_festus","wh3_main_group_belakor","wh3_main_nur","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_inf_chaos_warriors_mnur_greatweapons", "core", 3, { military_groupings = {"wh3_dlc20_group_chs_festus","wh3_main_dae","wh3_main_group_belakor","wh3_main_nur","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_inf_chaos_warriors_msla", "core", 2, { military_groupings = {"wh3_dlc20_group_chs_azazel","wh3_main_group_belakor","wh3_main_sla","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_inf_chaos_warriors_msla_hellscourges", "core", 3, { military_groupings = {"wh3_dlc20_group_chs_azazel","wh3_main_dae","wh3_main_group_belakor","wh3_main_sla","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_inf_chaos_warriors_mtze", "core", 2, { military_groupings = {"wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh3_main_tze","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_inf_chaos_warriors_mtze_halberds", "core", 3, { military_groupings = {"wh3_dlc20_group_chs_vilitch","wh3_main_dae","wh3_main_group_belakor","wh3_main_tze","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_cav_marauder_horsemen_mkho_throwing_axes", "core", 1, { military_groupings = {"wh3_dlc20_group_chs_valkia","wh3_main_group_belakor","wh3_main_kho","wh_main_group_chaos"}, category = "war_beast", tier = nil, cost = 1 }},
        {"wh3_dlc20_chs_cav_marauder_horsemen_mnur_throwing_axes", "core", 1, { military_groupings = {"wh3_dlc20_group_chs_festus","wh3_main_group_belakor","wh3_main_nur","wh_main_group_chaos"}, category = "war_beast", tier = nil, cost = 1 }},
        {"wh3_dlc20_chs_cav_marauder_horsemen_msla_javelins", "core", 1, { military_groupings = {"wh3_dlc20_group_chs_azazel","wh3_main_dae","wh3_main_group_belakor","wh3_main_sla","wh_main_group_chaos"}, category = "war_beast", tier = nil, cost = 1 }},
        {"wh3_dlc20_chs_cav_marauder_horsemen_mtze_javelins", "core", 1, { military_groupings = {"wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh3_main_tze","wh_main_group_chaos"}, category = "war_beast", tier = nil, cost = 1 }},
        {"wh3_dlc20_chs_inf_forsaken_mkho", "core", 3, { military_groupings = {"wh3_dlc20_group_chs_valkia","wh3_main_dae","wh3_main_group_belakor","wh3_main_kho","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_inf_forsaken_msla", "core", 3, { military_groupings = {"wh3_dlc20_group_chs_azazel","wh3_main_dae","wh3_main_group_belakor","wh3_main_sla","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_cav_chaos_knights_mkho", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_valkia","wh3_main_group_belakor","wh3_main_kho","wh_main_group_chaos"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_cav_chaos_knights_mkho_lances", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_valkia","wh3_main_group_belakor","wh3_main_kho","wh_main_group_chaos"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_cav_chaos_knights_mnur", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_festus","wh3_main_group_belakor","wh3_main_nur","wh_main_group_chaos"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_cav_chaos_knights_mnur_lances", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_festus","wh3_main_group_belakor","wh3_main_nur","wh_main_group_chaos"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_cav_chaos_knights_msla", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_azazel","wh3_main_group_belakor","wh3_main_sla","wh_main_group_chaos"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_cav_chaos_knights_msla_lances", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_azazel","wh3_main_group_belakor","wh3_main_sla","wh_main_group_chaos"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_cav_chaos_knights_mtze_lances", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh3_main_tze","wh_main_group_chaos"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_inf_chosen_mkho", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_valkia","wh3_main_group_belakor","wh3_main_kho","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_inf_chosen_mkho_dualweapons", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_valkia","wh3_main_group_belakor","wh3_main_kho","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_inf_chosen_mnur", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_festus","wh3_main_group_belakor","wh3_main_nur","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_inf_chosen_mnur_greatweapons", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_festus","wh3_main_group_belakor","wh3_main_nur","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_inf_chosen_msla", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_azazel","wh3_main_group_belakor","wh3_main_sla","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_inf_chosen_msla_hellscourges", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_azazel","wh3_main_group_belakor","wh3_main_sla","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_inf_chosen_mtze", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh3_main_tze","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_inf_chosen_mtze_halberds", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh3_main_tze","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_mon_warshrine", "special", 2, { military_groupings = {"wh3_main_dae","wh3_main_group_belakor","wh_main_group_chaos"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_mon_warshrine_mkho", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_valkia","wh3_main_dae","wh3_main_group_belakor","wh3_main_kho","wh_main_group_chaos"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_mon_warshrine_mnur", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_festus","wh3_main_dae","wh3_main_group_belakor","wh3_main_nur","wh_main_group_chaos"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_mon_warshrine_msla", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_azazel","wh3_main_dae","wh3_main_group_belakor","wh3_main_sla","wh_main_group_chaos"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh3_dlc20_chs_mon_warshrine_mtze", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_vilitch","wh3_main_dae","wh3_main_group_belakor","wh3_main_tze","wh_main_group_chaos"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh3_main_nur_mon_spawn_of_nurgle_0_warriors", "rare", 1, { military_groupings = {"wh3_dlc20_group_chs_festus","wh3_main_group_belakor","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_emp_cav_empire_knights", "core", 3, { military_groupings = {"wh2_main_rogue_scions_of_tesseninck","wh_main_group_empire","wh_main_group_empire_reikland","wh_main_group_kislev","wh_main_group_teb"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh_main_emp_inf_halberdiers", "core", 2, { military_groupings = {"wh2_dlc11_cst_rogue_freebooters_of_port_royale","wh2_dlc11_cst_shanty_middle_sea_brigands","wh2_main_rogue_gerhardts_mercenaries","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair","wh_main_group_empire","wh_main_group_empire_reikland","wh_main_group_kislev","wh_main_group_teb"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_emp_inf_handgunners", "core", 3, { military_groupings = {"wh2_dlc11_cst_rogue_freebooters_of_port_royale","wh2_dlc11_cst_shanty_middle_sea_brigands","wh2_main_rogue_gerhardts_mercenaries","wh2_main_rogue_jerrods_errantry","wh2_main_rogue_pirates_of_the_far_sea","wh2_main_rogue_pirates_of_the_southern_ocean","wh2_main_rogue_pirates_of_trantio","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair","wh_main_group_empire","wh_main_group_empire_reikland","wh_main_group_kislev","wh_main_group_teb"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_main_emp_inf_spearmen_0", "core", 1, { military_groupings = {"wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair","wh_main_group_empire","wh_main_group_empire_reikland","wh_main_group_kislev","wh_main_group_teb"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh_main_emp_inf_spearmen_1", "core", 1, { military_groupings = {"wh2_main_rogue_jerrods_errantry","wh2_main_rogue_scions_of_tesseninck","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair","wh_main_group_empire","wh_main_group_empire_reikland","wh_main_group_kislev","wh_main_group_teb"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh_main_emp_inf_swordsmen", "core", 1, { military_groupings = {"wh2_dlc11_cst_rogue_freebooters_of_port_royale","wh2_main_rogue_bernhoffs_brigands","wh2_main_rogue_scions_of_tesseninck","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair","wh_main_group_empire","wh_main_group_empire_reikland","wh_main_group_kislev","wh_main_group_teb"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh_main_emp_inf_crossbowmen", "core", 1, { military_groupings = {"wh2_dlc09_rogue_pilgrims_of_myrmidia","wh2_main_rogue_bernhoffs_brigands","wh2_main_rogue_scions_of_tesseninck","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair","wh_main_group_empire","wh_main_group_empire_reikland","wh_main_group_kislev","wh_main_group_teb"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_dlc04_emp_inf_free_company_militia_0", "core", 2, { military_groupings = {"wh2_dlc11_cst_rogue_freebooters_of_port_royale","wh2_main_rogue_bernhoffs_brigands","wh2_main_rogue_gerhardts_mercenaries","wh2_main_rogue_pirates_of_the_far_sea","wh2_main_rogue_pirates_of_the_southern_ocean","wh2_main_rogue_pirates_of_trantio","wh_main_group_empire","wh_main_group_empire_reikland"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_dlc13_emp_inf_archers_0", "core", 1, { military_groupings = {"wh_main_group_empire","wh_main_group_empire_reikland"}, category = "inf_ranged", tier = nil, cost = 1 }},
        {"wh_main_emp_cav_demigryph_knights_0", "special", 3, { military_groupings = {"wh_main_group_empire","wh_main_group_empire_reikland"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh_main_emp_cav_demigryph_knights_1", "special", 3, { military_groupings = {"wh_main_group_empire","wh_main_group_empire_reikland"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh_main_emp_cav_outriders_0", "special", 1, { military_groupings = {"wh2_dlc11_cst_shanty_middle_sea_brigands","wh2_main_rogue_gerhardts_mercenaries","wh_main_group_empire","wh_main_group_empire_reikland","wh_main_group_kislev","wh_main_group_teb"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh_main_emp_cav_outriders_1", "special", 2, { military_groupings = {"wh2_main_rogue_college_of_pyrotechnics","wh_main_group_empire","wh_main_group_empire_reikland","wh_main_group_kislev","wh_main_group_teb"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh_main_emp_cav_pistoliers_1", "special", 1, { military_groupings = {"wh2_main_rogue_scions_of_tesseninck","wh_main_group_empire","wh_main_group_empire_reikland","wh_main_group_kislev","wh_main_group_teb"}, category = "cavalry", tier = nil, cost = 1 }},
        {"wh_main_emp_cav_reiksguard", "special", 2, { military_groupings = {"wh_main_group_empire","wh_main_group_empire_reikland"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh_main_emp_art_great_cannon", "special", 2, { military_groupings = {"wh2_dlc11_cst_rogue_freebooters_of_port_royale","wh2_dlc11_cst_shanty_middle_sea_brigands","wh2_main_rogue_pirates_of_the_far_sea","wh2_main_rogue_pirates_of_the_southern_ocean","wh2_main_rogue_pirates_of_trantio","wh_main_group_empire","wh_main_group_empire_reikland"}, category = "artillery", tier = nil, cost = 2 }},
        {"wh_main_emp_art_mortar", "special", 2, { military_groupings = {"wh2_dlc09_rogue_pilgrims_of_myrmidia","wh2_dlc11_cst_rogue_freebooters_of_port_royale","wh2_dlc11_cst_shanty_middle_sea_brigands","wh2_main_rogue_bernhoffs_brigands","wh2_main_rogue_gerhardts_mercenaries","wh2_main_rogue_jerrods_errantry","wh2_main_rogue_pirates_of_trantio","wh_main_group_empire","wh_main_group_empire_reikland","wh_main_group_kislev","wh_main_group_teb"}, category = "artillery", tier = nil, cost = 2 }},
        {"wh_main_emp_inf_greatswords", "special", 1, { military_groupings = {"wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair","wh_main_group_empire","wh_main_group_empire_reikland","wh_main_group_kislev","wh_main_group_teb"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc04_emp_cav_knights_blazing_sun_0", "special", 2, { military_groupings = {"wh2_dlc09_rogue_pilgrims_of_myrmidia","wh2_main_rogue_jerrods_errantry","wh_main_group_empire","wh_main_group_empire_reikland"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh_dlc04_emp_inf_flagellants_0", "special", 1, { military_groupings = {"wh2_main_rogue_jerrods_errantry","wh2_main_rogue_morrsliebs_howlers","wh_main_group_empire","wh_main_group_empire_reikland"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc13_emp_inf_huntsmen_0", "special", 1, { military_groupings = {"wh_main_group_empire","wh_main_group_empire_reikland"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_main_emp_art_helblaster_volley_gun", "rare", 2, { military_groupings = {"wh_main_group_empire","wh_main_group_empire_reikland"}, category = "artillery", tier = nil, cost = 2 }},
        {"wh_main_emp_art_helstorm_rocket_battery", "rare", 2, { military_groupings = {"wh2_main_rogue_college_of_pyrotechnics","wh_main_group_empire","wh_main_group_empire_reikland"}, category = "artillery", tier = nil, cost = 2 }},
        {"wh_main_emp_veh_luminark_of_hysh_0", "rare", 3, { military_groupings = {"wh_main_group_empire","wh_main_group_empire_reikland"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh_main_emp_veh_steam_tank", "rare", 3, { military_groupings = {"wh2_main_rogue_college_of_pyrotechnics","wh3_main_tze","wh_main_group_empire","wh_main_group_empire_reikland"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh2_dlc13_emp_veh_war_wagon_0", "rare", 1, { military_groupings = {"wh_main_group_empire","wh_main_group_empire_reikland"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh2_dlc13_emp_veh_war_wagon_1", "rare", 2, { military_groupings = {"wh_main_group_empire","wh_main_group_empire_reikland"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh_main_dwf_inf_dwarf_warrior_0", "core", 1, { military_groupings = {"wh3_dlc23_rogue_karaz_a_karak_expedition","wh3_dlc23_rogue_the_cult_of_morgrim","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair","wh_main_group_dwarfs"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_dwf_inf_dwarf_warrior_1", "core", 2, { military_groupings = {"wh3_dlc23_rogue_karaz_a_karak_expedition","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair","wh_main_group_dwarfs"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_dwf_inf_longbeards", "core", 3, { military_groupings = {"wh3_dlc23_rogue_karaz_a_karak_expedition","wh3_dlc23_rogue_the_cult_of_morgrim","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair","wh_main_group_dwarfs"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_dwf_inf_longbeards_1", "core", 3, { military_groupings = {"wh3_dlc23_rogue_karaz_a_karak_expedition","wh3_dlc23_rogue_the_cult_of_morgrim","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair","wh_main_group_dwarfs"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_dwf_inf_miners_0", "core", 1, { military_groupings = {"wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair","wh_main_group_dwarfs"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh_main_dwf_inf_miners_1", "core", 1, { military_groupings = {"wh2_main_rogue_doomseekers","wh3_dlc23_rogue_karaz_a_karak_expedition","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair","wh_main_group_dwarfs"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh_main_dwf_inf_quarrellers_0", "core", 1, { military_groupings = {"wh3_dlc23_rogue_karaz_a_karak_expedition","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair","wh_main_group_dwarfs"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_main_dwf_inf_quarrellers_1", "core", 2, { military_groupings = {"wh3_dlc23_rogue_karaz_a_karak_expedition","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair","wh_main_group_dwarfs"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_main_dwf_inf_thunderers_0", "core", 2, { military_groupings = {"wh2_dlc11_cst_rogue_bleak_coast_buccaneers","wh3_dlc23_rogue_the_cult_of_morgrim","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair","wh_main_group_dwarfs"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_main_dwf_art_cannon", "special", 2, { military_groupings = {"wh3_dlc23_rogue_the_cult_of_morgrim","wh_main_group_dwarfs"}, category = "artillery", tier = nil, cost = 2 }},
        {"wh_main_dwf_art_grudge_thrower", "special", 1, { military_groupings = {"wh3_dlc23_rogue_karaz_a_karak_expedition","wh_main_group_dwarfs"}, category = "artillery", tier = nil, cost = 2 }},
        {"wh_main_dwf_inf_hammerers", "special", 2, { military_groupings = {"wh2_main_rogue_doomseekers","wh3_dlc23_rogue_the_cult_of_morgrim","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair","wh_main_group_dwarfs"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_dwf_inf_ironbreakers", "special", 2, { military_groupings = {"wh3_dlc23_rogue_karaz_a_karak_expedition","wh3_dlc23_rogue_the_cult_of_morgrim","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair","wh_main_group_dwarfs"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_dwf_veh_gyrobomber", "special", 2, { military_groupings = {"wh2_dlc11_cst_rogue_bleak_coast_buccaneers","wh2_main_rogue_doomseekers","wh3_dlc23_rogue_the_cult_of_morgrim","wh_main_group_dwarfs"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_main_dwf_veh_gyrocopter_0", "special", 2, { military_groupings = {"wh2_dlc11_cst_rogue_bleak_coast_buccaneers","wh3_dlc23_rogue_karaz_a_karak_expedition","wh_main_group_dwarfs"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_main_dwf_veh_gyrocopter_1", "special", 2, { military_groupings = {"wh3_dlc23_rogue_karaz_a_karak_expedition","wh_main_group_dwarfs"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_main_dwf_inf_slayers", "special", 1, { military_groupings = {"wh2_dlc11_cst_rogue_bleak_coast_buccaneers","wh2_main_rogue_doomseekers","wh2_main_rogue_pirates_of_trantio","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair","wh_main_group_dwarfs"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc06_dwf_art_bolt_thrower_0", "special", 1, { military_groupings = {"wh3_dlc23_rogue_the_cult_of_morgrim","wh_main_group_dwarfs"}, category = "artillery", tier = nil, cost = 2 }},
        {"wh_dlc06_dwf_inf_bugmans_rangers_0", "special", 2, { military_groupings = {"wh3_dlc23_rogue_karaz_a_karak_expedition","wh_main_group_dwarfs"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_dlc06_dwf_inf_rangers_0", "special", 1, { military_groupings = {"wh_main_group_dwarfs"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_dlc06_dwf_inf_rangers_1", "special", 1, { military_groupings = {"wh_main_group_dwarfs"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_dlc10_dwf_inf_giant_slayers", "special", 2, { military_groupings = {"wh2_dlc11_cst_rogue_bleak_coast_buccaneers","wh_main_group_dwarfs"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_dwf_art_flame_cannon", "rare", 2, { military_groupings = {"wh2_dlc11_cst_rogue_bleak_coast_buccaneers","wh2_main_rogue_doomseekers","wh_main_group_dwarfs"}, category = "artillery", tier = nil, cost = 2 }},
        {"wh_main_dwf_art_organ_gun", "rare", 2, { military_groupings = {"wh2_dlc11_cst_rogue_bleak_coast_buccaneers","wh3_dlc23_rogue_the_cult_of_morgrim","wh_main_group_dwarfs"}, category = "artillery", tier = nil, cost = 2 }},
        {"wh_main_dwf_inf_irondrakes_0", "rare", 2, { military_groupings = {"wh2_dlc11_cst_rogue_bleak_coast_buccaneers","wh2_main_rogue_doomseekers","wh3_dlc23_rogue_the_cult_of_morgrim","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair","wh_main_group_dwarfs"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_main_dwf_inf_irondrakes_2", "rare", 2, { military_groupings = {"wh2_main_rogue_pirates_of_trantio","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair","wh_main_group_dwarfs"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_main_vmp_inf_crypt_ghouls", "core", 2, { military_groupings = {"wh2_dlc11_cst_shanty_shark_straight_seadogs","wh2_main_rogue_abominations","wh2_main_rogue_heirs_of_mourkain","wh_main_group_vampire_counts"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_vmp_inf_skeleton_warriors_0", "core", 1, { military_groupings = {"wh2_main_rogue_the_wandering_dead","wh_main_group_vampire_counts"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh_main_vmp_inf_skeleton_warriors_1", "core", 1, { military_groupings = {"wh2_main_rogue_the_wandering_dead","wh_main_group_vampire_counts"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh_main_vmp_inf_zombie", "core", 1, { military_groupings = {"wh2_main_rogue_the_wandering_dead","wh_main_group_vampire_counts"}, category = "inf_melee", tier = nil, cost = 0 }},
        {"wh_main_vmp_mon_fell_bats", "core", 3, { military_groupings = {"wh2_main_rogue_beastcatchas","wh_main_group_vampire_counts"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_vmp_mon_dire_wolves", "core", 3, { military_groupings = {"wh2_main_rogue_heirs_of_mourkain","wh_main_group_vampire_counts"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_vmp_cav_hexwraiths", "special", 2, { military_groupings = {"wh2_dlc11_cst_shanty_shark_straight_seadogs","wh_main_group_vampire_counts"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh_main_vmp_inf_grave_guard_0", "special", 1, { military_groupings = {"wh2_dlc11_cst_shanty_shark_straight_seadogs","wh_main_group_vampire_counts"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_vmp_inf_grave_guard_1", "special", 1, { military_groupings = {"wh_main_group_vampire_counts"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_vmp_mon_crypt_horrors", "special", 2, { military_groupings = {"wh2_dlc11_cst_shanty_shark_straight_seadogs","wh2_main_rogue_abominations","wh2_main_rogue_heirs_of_mourkain","wh_main_group_vampire_counts"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_vmp_cav_black_knights_0", "special", 2, { military_groupings = {"wh2_main_rogue_the_wandering_dead","wh_main_group_vampire_counts"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh_main_vmp_cav_black_knights_3", "special", 2, { military_groupings = {"wh2_main_rogue_scourge_of_aquitaine","wh_main_group_vampire_counts"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh_main_vmp_mon_vargheists", "special", 2, { military_groupings = {"wh2_dlc11_cst_shanty_shark_straight_seadogs","wh_main_group_vampire_counts"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc04_vmp_veh_corpse_cart_0", "special", 2, { military_groupings = {"wh2_main_rogue_heirs_of_mourkain","wh_main_group_vampire_counts"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh_dlc04_vmp_veh_corpse_cart_1", "special", 3, { military_groupings = {"wh_main_group_vampire_counts"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh_dlc04_vmp_veh_corpse_cart_2", "special", 3, { military_groupings = {"wh_main_group_vampire_counts"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh_main_vmp_inf_cairn_wraiths", "rare", 1, { military_groupings = {"wh2_dlc11_cst_shanty_shark_straight_seadogs","wh_main_group_vampire_counts"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_vmp_mon_terrorgheist", "rare", 3, { military_groupings = {"wh_main_group_vampire_counts"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_vmp_mon_varghulf", "rare", 2, { military_groupings = {"wh_main_group_vampire_counts"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_vmp_veh_black_coach", "rare", 2, { military_groupings = {"wh_main_group_vampire_counts"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh_dlc02_vmp_cav_blood_knights_0", "rare", 2, { military_groupings = {"wh2_main_rogue_scourge_of_aquitaine","wh_main_group_vampire_counts"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh_dlc04_vmp_veh_mortis_engine_0", "rare", 3, { military_groupings = {"wh_main_group_vampire_counts"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh2_dlc11_vmp_inf_crossbowmen", "special", 1, { military_groupings = {""}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_dlc11_vmp_inf_handgunners", "rare", 1, { military_groupings = {""}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_main_brt_cav_knights_of_the_realm", "core", 2, { military_groupings = {"wh2_main_rogue_jerrods_errantry","wh2_main_rogue_scourge_of_aquitaine","wh_main_group_bretonnia"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh_main_brt_cav_mounted_yeomen_0", "core", 1, { military_groupings = {"wh2_main_rogue_bernhoffs_brigands","wh_main_group_bretonnia"}, category = "cavalry", tier = nil, cost = 1 }},
        {"wh_main_brt_cav_mounted_yeomen_1", "core", 1, { military_groupings = {"wh2_main_rogue_bernhoffs_brigands","wh_main_group_bretonnia"}, category = "cavalry", tier = nil, cost = 1 }},
        {"wh_main_brt_inf_men_at_arms", "core", 3, { military_groupings = {"wh2_dlc09_rogue_pilgrims_of_myrmidia","wh2_main_rogue_bernhoffs_brigands","wh_main_group_bretonnia"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_brt_inf_peasant_bowmen", "core", 1, { military_groupings = {"wh2_main_rogue_bernhoffs_brigands","wh_main_group_bretonnia"}, category = "inf_ranged", tier = nil, cost = 1 }},
        {"wh_main_brt_inf_spearmen_at_arms", "core", 3, { military_groupings = {"wh_main_group_bretonnia"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc07_brt_cav_knights_errant_0", "core", 3, { military_groupings = {"wh_main_group_bretonnia"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh_dlc07_brt_inf_men_at_arms_1", "core", 3, { military_groupings = {"wh_main_group_bretonnia"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc07_brt_inf_men_at_arms_2", "core", 3, { military_groupings = {"wh_main_group_bretonnia"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc07_brt_inf_peasant_bowmen_1", "core", 2, { military_groupings = {"wh_main_group_bretonnia"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_dlc07_brt_inf_peasant_bowmen_2", "core", 2, { military_groupings = {"wh_main_group_bretonnia"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_dlc07_brt_inf_spearmen_at_arms_1", "core", 3, { military_groupings = {"wh_main_group_bretonnia"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc07_brt_peasant_mob_0", "core", 1, { military_groupings = {"wh2_main_rogue_pirates_of_the_far_sea","wh2_main_rogue_pirates_of_the_southern_ocean","wh_main_group_bretonnia"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh_main_brt_cav_pegasus_knights", "special", 2, { military_groupings = {"wh2_main_rogue_pirates_of_trantio","wh2_main_rogue_scourge_of_aquitaine","wh_main_group_bretonnia"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh_dlc07_brt_cav_questing_knights_0", "special", 2, { military_groupings = {"wh_main_group_bretonnia"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh_dlc07_brt_inf_battle_pilgrims_0", "special", 1, { military_groupings = {"wh2_dlc09_rogue_pilgrims_of_myrmidia","wh2_main_rogue_jerrods_errantry","wh_main_group_bretonnia"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc07_brt_inf_foot_squires_0", "special", 1, { military_groupings = {"wh2_dlc09_rogue_pilgrims_of_myrmidia","wh_main_group_bretonnia"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc07_brt_inf_grail_reliquae_0", "special", 2, { military_groupings = {"wh2_main_rogue_morrsliebs_howlers","wh_main_group_bretonnia"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_brt_art_field_trebuchet", "rare", 1, { military_groupings = {"wh2_main_rogue_bernhoffs_brigands","wh_main_group_bretonnia"}, category = "artillery", tier = nil, cost = 2 }},
        {"wh_main_brt_cav_grail_knights", "rare", 2, { military_groupings = {"wh2_dlc09_rogue_pilgrims_of_myrmidia","wh2_main_rogue_jerrods_errantry","wh2_main_rogue_scourge_of_aquitaine","wh_main_group_bretonnia"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh_dlc07_brt_cav_grail_guardians_0", "rare", 2, { military_groupings = {"wh_main_group_bretonnia"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh_dlc07_brt_cav_royal_hippogryph_knights_0", "rare", 2, { military_groupings = {"wh_main_group_bretonnia"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh_dlc07_brt_cav_royal_pegasus_knights_0", "rare", 2, { military_groupings = {"wh_main_group_bretonnia"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh_main_grn_cav_forest_goblin_spider_riders_0", "core", 2, { military_groupings = {"wh2_dlc09_rogue_dwellers_of_zardok","wh2_dlc12_grn_leaf_cutterz_tribe","wh2_main_rogue_black_spider_tribe","wh2_main_rogue_stuff_snatchers","wh_main_group_greenskins"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh_main_grn_cav_forest_goblin_spider_riders_1", "core", 2, { military_groupings = {"wh2_dlc09_rogue_dwellers_of_zardok","wh2_dlc12_grn_leaf_cutterz_tribe","wh2_main_rogue_black_spider_tribe","wh2_main_rogue_stuff_snatchers","wh_main_group_greenskins"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh_main_grn_cav_goblin_wolf_riders_0", "core", 1, { military_groupings = {"wh2_dlc12_grn_leaf_cutterz_tribe","wh2_main_rogue_beastcatchas","wh2_main_rogue_mangy_houndz","wh_main_group_greenskins"}, category = "cavalry", tier = nil, cost = 1 }},
        {"wh_main_grn_cav_goblin_wolf_riders_1", "core", 1, { military_groupings = {"wh2_dlc12_grn_leaf_cutterz_tribe","wh2_main_rogue_beastcatchas","wh_main_group_greenskins"}, category = "cavalry", tier = nil, cost = 1 }},
        {"wh_main_grn_inf_goblin_archers", "core", 1, { military_groupings = {"wh2_dlc11_cst_rogue_boyz_of_the_forbidden_coast","wh2_dlc12_grn_leaf_cutterz_tribe","wh2_main_rogue_black_spider_tribe","wh_main_group_greenskins"}, category = "inf_ranged", tier = nil, cost = 1 }},
        {"wh_main_grn_inf_goblin_spearmen", "core", 1, { military_groupings = {"wh2_dlc12_grn_leaf_cutterz_tribe","wh2_main_rogue_black_spider_tribe","wh_main_group_greenskins"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh_main_grn_inf_night_goblin_archers", "core", 3, { military_groupings = {"wh2_dlc09_rogue_dwellers_of_zardok","wh2_dlc12_grn_leaf_cutterz_tribe","wh2_main_rogue_mangy_houndz","wh_main_group_greenskins"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_main_grn_inf_night_goblin_fanatics", "core", 3, { military_groupings = {"wh2_dlc12_grn_leaf_cutterz_tribe","wh2_main_rogue_stuff_snatchers","wh_main_group_greenskins"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_grn_inf_night_goblin_fanatics_1", "core", 3, { military_groupings = {"wh2_main_rogue_morrsliebs_howlers","wh2_main_rogue_stuff_snatchers","wh_main_group_greenskins"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_main_grn_inf_night_goblins", "core", 3, { military_groupings = {"wh2_dlc09_rogue_dwellers_of_zardok","wh2_dlc12_grn_leaf_cutterz_tribe","wh_main_group_greenskins"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_grn_inf_orc_arrer_boyz", "core", 2, { military_groupings = {"wh2_dlc12_grn_leaf_cutterz_tribe","wh2_main_rogue_teef_snatchaz","wh_main_group_greenskins"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_main_grn_inf_orc_big_uns", "core", 2, { military_groupings = {"wh2_dlc11_cst_rogue_boyz_of_the_forbidden_coast","wh2_dlc12_grn_leaf_cutterz_tribe","wh_main_group_greenskins"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_grn_inf_orc_boyz", "core", 1, { military_groupings = {"wh2_dlc12_grn_leaf_cutterz_tribe","wh2_main_rogue_mangy_houndz","wh2_main_rogue_teef_snatchaz","wh_main_group_greenskins"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_grn_inf_savage_orc_arrer_boyz", "core", 3, { military_groupings = {"wh2_dlc12_grn_leaf_cutterz_tribe","wh2_main_rogue_boneclubbers_tribe","wh_main_group_greenskins","wh_main_group_savage_orcs"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_main_grn_inf_savage_orc_big_uns", "core", 3, { military_groupings = {"wh2_dlc12_grn_leaf_cutterz_tribe","wh2_main_rogue_boneclubbers_tribe","wh_main_group_greenskins","wh_main_group_savage_orcs"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_grn_inf_savage_orcs", "core", 3, { military_groupings = {"wh2_dlc12_grn_leaf_cutterz_tribe","wh_main_group_greenskins","wh_main_group_savage_orcs"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc06_grn_inf_nasty_skulkers_0", "core", 2, { military_groupings = {"wh2_main_rogue_morrsliebs_howlers","wh2_main_rogue_stuff_snatchers","wh_main_group_greenskins"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh_main_grn_cav_goblin_wolf_chariot", "special", 1, { military_groupings = {"wh2_dlc12_grn_leaf_cutterz_tribe","wh_main_group_greenskins"}, category = "war_machine", tier = nil, cost = 1 }},
        {"wh_main_grn_cav_orc_boar_boy_big_uns", "special", 2, { military_groupings = {"wh2_dlc12_grn_leaf_cutterz_tribe","wh_main_group_greenskins"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh_main_grn_cav_orc_boar_boyz", "special", 1, { military_groupings = {"wh2_dlc11_cst_rogue_boyz_of_the_forbidden_coast","wh2_dlc12_grn_leaf_cutterz_tribe","wh2_main_rogue_teef_snatchaz","wh_main_group_greenskins"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh_main_grn_cav_orc_boar_chariot", "special", 2, { military_groupings = {"wh2_dlc12_grn_leaf_cutterz_tribe","wh_main_group_greenskins"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh_main_grn_cav_savage_orc_boar_boy_big_uns", "special", 2, { military_groupings = {"wh2_dlc12_grn_leaf_cutterz_tribe","wh2_main_rogue_boneclubbers_tribe","wh_main_group_greenskins","wh_main_group_savage_orcs"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh_main_grn_cav_savage_orc_boar_boyz", "special", 1, { military_groupings = {"wh2_dlc12_grn_leaf_cutterz_tribe","wh_main_group_greenskins","wh_main_group_savage_orcs"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh_main_grn_inf_black_orcs", "special", 2, { military_groupings = {"wh2_dlc11_cst_rogue_boyz_of_the_forbidden_coast","wh2_dlc12_grn_leaf_cutterz_tribe","wh2_main_rogue_boneclubbers_tribe","wh2_main_rogue_gerhardts_mercenaries","wh3_dlc24_group_labourer_rebels","wh_main_group_greenskins"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_grn_mon_trolls", "special", 1, { military_groupings = {"wh2_dlc12_grn_leaf_cutterz_tribe","wh2_main_rogue_black_spider_tribe","wh2_main_rogue_troll_skullz","wh_main_group_greenskins","wh_main_group_savage_orcs"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc06_grn_cav_squig_hoppers_0", "special", 2, { military_groupings = {"wh2_main_rogue_beastcatchas","wh2_main_rogue_morrsliebs_howlers","wh_main_group_greenskins"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh_dlc06_grn_inf_squig_herd_0", "special", 1, { military_groupings = {"wh2_main_rogue_beastcatchas","wh_main_group_greenskins"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc15_grn_mon_river_trolls_0", "special", 2, { military_groupings = {"wh_main_group_greenskins"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc15_grn_mon_stone_trolls_0", "special", 2, { military_groupings = {"wh_main_group_greenskins"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_grn_art_doom_diver_catapult", "rare", 2, { military_groupings = {"wh2_dlc11_cst_rogue_boyz_of_the_forbidden_coast","wh2_dlc12_grn_leaf_cutterz_tribe","wh2_main_rogue_morrsliebs_howlers","wh3_dlc24_group_labourer_rebels","wh_main_group_greenskins"}, category = "artillery", tier = nil, cost = 2 }},
        {"wh_main_grn_art_goblin_rock_lobber", "rare", 1, { military_groupings = {"wh2_dlc11_cst_rogue_boyz_of_the_forbidden_coast","wh2_dlc12_grn_leaf_cutterz_tribe","wh2_main_rogue_black_spider_tribe","wh3_dlc24_group_labourer_rebels","wh_main_group_greenskins"}, category = "artillery", tier = nil, cost = 2 }},
        {"wh_main_grn_mon_arachnarok_spider_0", "rare", 3, { military_groupings = {"wh2_dlc09_rogue_dwellers_of_zardok","wh2_main_rogue_black_spider_tribe","wh2_main_rogue_morrsliebs_howlers","wh_main_group_greenskins"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh_main_grn_mon_giant", "rare", 2, { military_groupings = {"wh2_main_rogue_gerhardts_mercenaries","wh2_main_rogue_troll_skullz","wh_main_group_greenskins"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc15_grn_mon_rogue_idol_0", "rare", 3, { military_groupings = {"wh_main_group_greenskins"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc15_grn_veh_snotling_pump_wagon_0", "rare", 1, { military_groupings = {"wh_main_group_greenskins"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh2_dlc15_grn_veh_snotling_pump_wagon_flappas_0", "rare", 1, { military_groupings = {"wh_main_group_greenskins"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh2_dlc15_grn_veh_snotling_pump_wagon_roller_0", "rare", 1, { military_groupings = {"wh_main_group_greenskins"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh_dlc06_grn_inf_squig_explosive_0", "core", 3, { military_groupings = {"wh_main_group_greenskins"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_chs_mon_chaos_warhounds_0", "core", 3, { military_groupings = {"wh2_main_rogue_mangy_houndz","wh3_dlc20_group_chs_azazel","wh3_dlc20_group_chs_festus","wh3_dlc20_group_chs_valkia","wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh3_main_rogue_the_challenge_stone_pact","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh_main_chs_mon_chaos_warhounds_1", "core", 3, { military_groupings = {"wh2_main_rogue_beastcatchas","wh2_main_rogue_hung_warband","wh2_main_rogue_mangy_houndz","wh3_dlc20_group_chs_azazel","wh3_dlc20_group_chs_festus","wh3_dlc20_group_chs_valkia","wh3_dlc20_group_chs_vilitch","wh3_main_dae","wh3_main_group_belakor","wh3_main_nur","wh3_main_rogue_the_challenge_stone_pact","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh_main_chs_cav_marauder_horsemen_0", "core", 1, { military_groupings = {"wh2_main_rogue_hung_warband","wh3_dlc20_group_chs_azazel","wh3_dlc20_group_chs_festus","wh3_dlc20_group_chs_valkia","wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh3_main_rogue_the_challenge_stone_pact","wh_main_group_chaos"}, category = "war_beast", tier = nil, cost = 1 }},
        {"wh_main_chs_cav_marauder_horsemen_1", "core", 1, { military_groupings = {"wh2_main_rogue_hung_warband","wh3_dlc20_group_chs_azazel","wh3_dlc20_group_chs_festus","wh3_dlc20_group_chs_valkia","wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh3_main_rogue_the_challenge_stone_pact","wh_main_group_chaos"}, category = "war_beast", tier = nil, cost = 1 }},
        {"wh_main_chs_inf_chaos_marauders_0", "core", 1, { military_groupings = {"wh3_dlc20_group_chs_azazel","wh3_dlc20_group_chs_festus","wh3_dlc20_group_chs_valkia","wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh3_main_rogue_the_challenge_stone_pact","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh_main_chs_inf_chaos_marauders_1", "core", 1, { military_groupings = {"wh3_dlc20_group_chs_azazel","wh3_dlc20_group_chs_festus","wh3_dlc20_group_chs_valkia","wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh3_main_rogue_the_challenge_stone_pact","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh_main_chs_inf_chaos_warriors_0", "core", 2, { military_groupings = {"wh2_main_rogue_vashnaars_conquest","wh3_dlc20_group_chs_azazel","wh3_dlc20_group_chs_festus","wh3_dlc20_group_chs_valkia","wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh3_main_rogue_the_challenge_stone_pact","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_chs_inf_chaos_warriors_1", "core", 2, { military_groupings = {"wh2_main_rogue_vashnaars_conquest","wh3_dlc20_group_chs_azazel","wh3_dlc20_group_chs_festus","wh3_dlc20_group_chs_valkia","wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh3_main_rogue_the_challenge_stone_pact","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_chs_cav_chaos_chariot", "core", 1, { military_groupings = {"wh2_main_rogue_hung_warband","wh3_dlc20_group_chs_azazel","wh3_dlc20_group_chs_festus","wh3_dlc20_group_chs_valkia","wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh3_main_rogue_the_challenge_stone_pact","wh_main_group_chaos"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh_dlc01_chs_inf_chaos_warriors_2", "core", 3, { military_groupings = {"wh2_main_rogue_vashnaars_conquest","wh3_dlc20_group_chs_azazel","wh3_dlc20_group_chs_festus","wh3_dlc20_group_chs_valkia","wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc01_chs_inf_forsaken_0", "core", 3, { military_groupings = {"wh2_main_rogue_abominations","wh2_main_rogue_morrsliebs_howlers","wh3_dlc20_group_chs_azazel","wh3_dlc20_group_chs_festus","wh3_dlc20_group_chs_valkia","wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc06_chs_cav_marauder_horsemasters_0", "core", 3, { military_groupings = {"wh2_main_rogue_hung_warband","wh3_dlc20_group_chs_azazel","wh3_dlc20_group_chs_festus","wh3_dlc20_group_chs_valkia","wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh_main_group_chaos"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh_main_chs_mon_trolls", "special", 1, { military_groupings = {"wh2_main_rogue_gerhardts_mercenaries","wh2_main_rogue_troll_skullz","wh3_dlc20_group_chs_azazel","wh3_dlc20_group_chs_festus","wh3_dlc20_group_chs_valkia","wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh3_main_rogue_the_challenge_stone_pact","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_chs_inf_chosen_0", "special", 2, { military_groupings = {"wh2_main_rogue_vashnaars_conquest","wh3_dlc20_group_chs_azazel","wh3_dlc20_group_chs_festus","wh3_dlc20_group_chs_valkia","wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh3_main_rogue_the_challenge_stone_pact","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_chs_inf_chosen_1", "special", 2, { military_groupings = {"wh2_main_rogue_vashnaars_conquest","wh3_dlc20_group_chs_azazel","wh3_dlc20_group_chs_festus","wh3_dlc20_group_chs_valkia","wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh3_main_rogue_the_challenge_stone_pact","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_chs_cav_chaos_knights_0", "special", 2, { military_groupings = {"wh2_main_rogue_hung_warband","wh2_main_rogue_vashnaars_conquest","wh3_dlc20_group_chs_azazel","wh3_dlc20_group_chs_festus","wh3_dlc20_group_chs_valkia","wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh3_main_rogue_the_challenge_stone_pact","wh_main_group_chaos"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh_main_chs_cav_chaos_knights_1", "special", 2, { military_groupings = {"wh2_main_rogue_hung_warband","wh2_main_rogue_vashnaars_conquest","wh3_dlc20_group_chs_azazel","wh3_dlc20_group_chs_festus","wh3_dlc20_group_chs_valkia","wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh3_main_rogue_the_challenge_stone_pact","wh_main_group_chaos"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh_dlc01_chs_cav_gorebeast_chariot", "special", 1, { military_groupings = {"wh2_main_rogue_hung_warband","wh3_dlc20_group_chs_azazel","wh3_dlc20_group_chs_festus","wh3_dlc20_group_chs_valkia","wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh_main_group_chaos"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh_dlc01_chs_mon_dragon_ogre", "special", 2, { military_groupings = {"wh3_main_group_belakor","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc01_chs_mon_trolls_1", "special", 1, { military_groupings = {"wh2_main_rogue_boneclubbers_tribe","wh3_dlc20_group_chs_azazel","wh3_dlc20_group_chs_festus","wh3_dlc20_group_chs_valkia","wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc01_chs_inf_chosen_2", "special", 2, { military_groupings = {"wh2_main_rogue_vashnaars_conquest","wh3_dlc20_group_chs_azazel","wh3_dlc20_group_chs_festus","wh3_dlc20_group_chs_valkia","wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc06_chs_feral_manticore", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_azazel","wh3_dlc20_group_chs_festus","wh3_dlc20_group_chs_valkia","wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc06_chs_inf_aspiring_champions_0", "special", 1, { military_groupings = {"wh3_dlc20_group_chs_azazel","wh3_dlc20_group_chs_festus","wh3_dlc20_group_chs_valkia","wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_chs_art_hellcannon", "rare", 2, { military_groupings = {"wh2_main_rogue_hung_warband","wh2_main_rogue_vashnaars_conquest","wh3_dlc23_group_chaos_dwarfs","wh3_main_group_belakor","wh3_main_rogue_the_challenge_stone_pact","wh_main_group_chaos"}, category = "artillery", tier = nil, cost = 2 }},
        {"wh_main_chs_mon_chaos_spawn", "rare", 1, { military_groupings = {"wh2_main_rogue_abominations","wh2_main_rogue_beastcatchas","wh3_dlc20_group_chs_azazel","wh3_dlc20_group_chs_festus","wh3_dlc20_group_chs_valkia","wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh3_main_rogue_the_challenge_stone_pact","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_chs_mon_giant", "rare", 2, { military_groupings = {"wh3_dlc20_group_chs_azazel","wh3_dlc20_group_chs_festus","wh3_dlc20_group_chs_valkia","wh3_dlc20_group_chs_vilitch","wh3_main_group_belakor","wh3_main_rogue_the_challenge_stone_pact","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc01_chs_mon_dragon_ogre_shaggoth", "rare", 3, { military_groupings = {"wh3_main_group_belakor","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc03_bst_inf_chaos_warhounds_0", "core", 3, { military_groupings = {"wh_dlc03_group_beastmen"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh_dlc03_bst_inf_chaos_warhounds_1", "core", 3, { military_groupings = {"wh_dlc03_group_beastmen"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh_dlc03_bst_inf_ungor_raiders_0", "core", 1, { military_groupings = {"wh_dlc03_group_beastmen"}, category = "inf_ranged", tier = nil, cost = 1 }},
        {"wh_dlc03_bst_inf_gor_herd_0", "core", 2, { military_groupings = {"wh_dlc03_group_beastmen"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc03_bst_inf_gor_herd_1", "core", 2, { military_groupings = {"wh_dlc03_group_beastmen"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc03_bst_inf_ungor_herd_1", "core", 1, { military_groupings = {"wh2_main_rogue_abominations","wh_dlc03_group_beastmen"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh_dlc03_bst_inf_ungor_spearmen_0", "core", 1, { military_groupings = {"wh_dlc03_group_beastmen"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh_dlc03_bst_inf_ungor_spearmen_1", "core", 1, { military_groupings = {"wh_dlc03_group_beastmen"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh2_dlc17_bst_cav_tuskgor_chariot_0", "core", 1, { military_groupings = {"wh_dlc03_group_beastmen"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh_dlc03_bst_inf_minotaurs_0", "special", 2, { military_groupings = {"wh_dlc03_group_beastmen"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc03_bst_inf_minotaurs_1", "special", 2, { military_groupings = {"wh_dlc03_group_beastmen"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc03_bst_inf_minotaurs_2", "special", 2, { military_groupings = {"wh2_dlc09_rogue_dwellers_of_zardok","wh_dlc03_group_beastmen"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc05_bst_mon_harpies_0", "special", 1, { military_groupings = {"wh2_main_rogue_hung_warband","wh_dlc03_group_beastmen"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh_dlc03_bst_inf_razorgor_herd_0", "special", 1, { military_groupings = {"wh2_main_rogue_abominations","wh_dlc03_group_beastmen"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc03_bst_feral_manticore", "special", 2, { military_groupings = {"wh2_main_rogue_abominations","wh_dlc03_group_beastmen"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc03_bst_inf_bestigor_herd_0", "special", 1, { military_groupings = {"wh2_dlc09_rogue_dwellers_of_zardok","wh_dlc03_group_beastmen"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc03_bst_inf_centigors_0", "special", 1, { military_groupings = {"wh2_dlc09_rogue_dwellers_of_zardok","wh_dlc03_group_beastmen"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc03_bst_inf_centigors_1", "special", 1, { military_groupings = {"wh_dlc03_group_beastmen"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_dlc03_bst_inf_centigors_2", "special", 1, { military_groupings = {"wh_dlc03_group_beastmen"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc03_bst_cav_razorgor_chariot_0", "special", 2, { military_groupings = {"wh_dlc03_group_beastmen"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh_dlc03_bst_mon_chaos_spawn_0", "rare", 1, { military_groupings = {"wh_dlc03_group_beastmen"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc03_bst_mon_giant_0", "rare", 2, { military_groupings = {"wh_dlc03_group_beastmen"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc03_bst_inf_cygor_0", "rare", 3, { military_groupings = {"wh2_main_rogue_abominations","wh2_main_rogue_boneclubbers_tribe","wh2_main_rogue_troll_skullz","wh_dlc03_group_beastmen"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_dlc17_bst_mon_ghorgon_0", "rare", 3, { military_groupings = {"wh_dlc03_group_beastmen"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc17_bst_mon_jabberslythe_0", "rare", 3, { military_groupings = {"wh_dlc03_group_beastmen"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc05_wef_inf_glade_guard_0", "core", 2, { military_groupings = {"wh2_dlc16_group_drycha","wh2_main_rogue_worldroot_rangers","wh_dlc05_group_wood_elves"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_dlc05_wef_inf_glade_guard_1", "core", 3, { military_groupings = {"wh2_dlc16_group_drycha","wh2_main_rogue_hunters_of_kurnous","wh_dlc05_group_wood_elves"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_dlc05_wef_inf_glade_guard_2", "core", 3, { military_groupings = {"wh2_dlc16_group_drycha","wh2_main_rogue_hunters_of_kurnous","wh_dlc05_group_wood_elves"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_dlc05_wef_cav_glade_riders_0", "core", 1, { military_groupings = {"wh2_dlc16_group_drycha","wh2_main_rogue_worldroot_rangers","wh_dlc05_group_wood_elves"}, category = "cavalry", tier = nil, cost = 1 }},
        {"wh_dlc05_wef_cav_glade_riders_1", "core", 1, { military_groupings = {"wh2_dlc16_group_drycha","wh2_main_rogue_hunters_of_kurnous","wh_dlc05_group_wood_elves"}, category = "cavalry", tier = nil, cost = 1 }},
        {"wh_dlc05_wef_inf_dryads_0", "core", 1, { military_groupings = {"wh2_main_rogue_wrath_of_nature","wh_dlc05_group_wood_elves"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh_dlc05_wef_inf_eternal_guard_0", "core", 1, { military_groupings = {"wh2_dlc16_group_drycha","wh_dlc05_group_wood_elves"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc05_wef_inf_eternal_guard_1", "core", 2, { military_groupings = {"wh2_dlc16_group_drycha","wh_dlc05_group_wood_elves"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc16_wef_cav_glade_riders_2", "core", 2, { military_groupings = {"wh2_dlc16_group_drycha","wh2_main_rogue_hunters_of_kurnous","wh2_main_rogue_worldroot_rangers","wh_dlc05_group_wood_elves"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_dlc16_wef_inf_malicious_dryads_0", "core", 3, { military_groupings = {"wh2_dlc16_group_drycha"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh2_dlc16_wef_mon_cave_bats", "core", 3, { military_groupings = {"wh3_main_ksl"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc05_wef_inf_deepwood_scouts_0", "special", 1, { military_groupings = {"wh2_dlc16_group_drycha","wh_dlc05_group_wood_elves"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_dlc05_wef_inf_deepwood_scouts_1", "special", 1, { military_groupings = {"wh2_dlc16_group_drycha","wh2_main_rogue_hunters_of_kurnous","wh_dlc05_group_wood_elves"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_dlc05_wef_mon_treekin_0", "special", 2, { military_groupings = {"wh2_main_rogue_wrath_of_nature","wh_dlc05_group_wood_elves"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc05_wef_mon_great_eagle_0", "special", 2, { military_groupings = {"wh2_dlc16_group_drycha","wh2_main_rogue_wrath_of_nature","wh_dlc05_group_wood_elves"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc05_wef_cav_hawk_riders_0", "special", 2, { military_groupings = {"wh2_dlc09_rogue_eyes_of_the_jungle","wh2_dlc11_cst_shanty_dragon_spine_privateers","wh2_dlc16_group_drycha","wh_dlc05_group_wood_elves"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh_dlc05_wef_inf_wardancers_0", "special", 1, { military_groupings = {"wh2_dlc11_cst_shanty_dragon_spine_privateers","wh2_dlc16_group_drycha","wh_dlc05_group_wood_elves"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc05_wef_inf_wardancers_1", "special", 1, { military_groupings = {"wh2_dlc11_cst_shanty_dragon_spine_privateers","wh2_dlc16_group_drycha","wh2_main_rogue_hunters_of_kurnous","wh_dlc05_group_wood_elves"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc05_wef_inf_wildwood_rangers_0", "special", 2, { military_groupings = {"wh2_dlc09_rogue_eyes_of_the_jungle","wh2_dlc16_group_drycha","wh2_main_rogue_hunters_of_kurnous","wh2_main_rogue_worldroot_rangers","wh_dlc05_group_wood_elves"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc05_wef_cav_wild_riders_0", "special", 2, { military_groupings = {"wh_dlc05_group_wood_elves"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh_dlc05_wef_cav_wild_riders_1", "special", 2, { military_groupings = {"wh2_main_rogue_hunters_of_kurnous","wh_dlc05_group_wood_elves"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_dlc16_wef_inf_bladesingers_0", "special", 2, { military_groupings = {"wh_dlc05_group_wood_elves"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc16_wef_mon_giant_spiders_0", "special", 1, { military_groupings = {"wh2_dlc16_group_drycha","wh3_main_ksl"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh2_dlc16_wef_mon_feral_manticore", "special", 2, { military_groupings = {"wh2_dlc16_group_drycha"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc16_wef_mon_harpies_0", "special", 1, { military_groupings = {"wh2_dlc16_group_drycha"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh2_dlc16_wef_mon_hawks_0", "special", 1, { military_groupings = {"wh2_dlc16_group_drycha"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc16_wef_mon_malicious_treekin_0", "special", 2, { military_groupings = {"wh2_dlc16_group_drycha"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc16_wef_mon_wolves_0", "special", 1, { military_groupings = {"wh2_dlc16_group_drycha"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc05_wef_forest_dragon_0", "rare", 3, { military_groupings = {"wh2_dlc11_cst_shanty_dragon_spine_privateers","wh2_dlc16_group_drycha","wh2_main_rogue_wrath_of_nature","wh_dlc05_group_wood_elves"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc05_wef_mon_treeman_0", "rare", 3, { military_groupings = {"wh_dlc05_group_wood_elves"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc05_wef_inf_waywatchers_0", "rare", 1, { military_groupings = {"wh2_dlc09_rogue_eyes_of_the_jungle","wh2_dlc11_cst_shanty_dragon_spine_privateers","wh2_main_rogue_hunters_of_kurnous","wh_dlc05_group_wood_elves"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_dlc05_wef_cav_sisters_thorn_0", "rare", 1, { military_groupings = {"wh2_dlc09_rogue_eyes_of_the_jungle","wh_dlc05_group_wood_elves"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_dlc16_wef_cav_great_stag_knights_0", "rare", 1, { military_groupings = {"wh_dlc05_group_wood_elves"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_dlc16_wef_mon_malicious_treeman_0", "rare", 3, { military_groupings = {"wh2_dlc16_group_drycha"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc16_wef_mon_zoats", "rare", 1, { military_groupings = {"wh2_dlc16_group_drycha","wh2_main_lzd","wh_dlc05_group_wood_elves"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_main_nor_mon_chaos_warhounds_0", "core", 3, { military_groupings = {"wh2_main_rogue_hung_warband","wh_main_group_norsca","wh_main_group_norsca_steppe"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh_main_nor_mon_chaos_warhounds_1", "core", 3, { military_groupings = {"wh2_dlc09_rogue_black_creek_raiders","wh2_main_rogue_hung_warband","wh_main_group_norsca","wh_main_group_norsca_steppe"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh_main_nor_cav_marauder_horsemen_1", "core", 1, { military_groupings = {"wh2_main_rogue_hung_warband","wh_main_group_norsca","wh_main_group_norsca_steppe"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh_main_nor_inf_chaos_marauders_0", "core", 1, { military_groupings = {"wh2_main_rogue_hung_warband","wh_main_group_norsca","wh_main_group_norsca_steppe"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh_main_nor_inf_chaos_marauders_1", "core", 1, { military_groupings = {"wh2_dlc09_rogue_black_creek_raiders","wh2_main_rogue_hung_warband","wh_main_group_norsca","wh_main_group_norsca_steppe"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh_main_nor_cav_marauder_horsemen_0", "core", 2, { military_groupings = {"wh2_dlc09_rogue_black_creek_raiders","wh2_main_rogue_hung_warband","wh_main_group_norsca","wh_main_group_norsca_steppe"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh_main_nor_cav_chaos_chariot", "core", 2, { military_groupings = {"wh2_main_rogue_hung_warband","wh_main_group_norsca","wh_main_group_norsca_steppe"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh_dlc08_nor_inf_marauder_spearman_0", "core", 1, { military_groupings = {"wh_main_group_norsca","wh_main_group_norsca_steppe"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh_dlc08_nor_inf_marauder_hunters_0", "core", 1, { military_groupings = {"wh2_dlc11_cst_rogue_the_churning_gulf_raiders","wh_main_group_norsca","wh_main_group_norsca_steppe"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_dlc08_nor_inf_marauder_hunters_1", "core", 1, { military_groupings = {"wh_main_group_norsca","wh_main_group_norsca_steppe"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh_dlc08_nor_cav_marauder_horsemasters_0", "core", 3, { military_groupings = {"wh_main_group_norsca","wh_main_group_norsca_steppe"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh_main_nor_mon_chaos_trolls", "special", 2, { military_groupings = {"wh2_main_rogue_hung_warband","wh_main_group_norsca","wh_main_group_norsca_steppe"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc08_nor_mon_warwolves_0", "special", 1, { military_groupings = {"wh2_dlc11_cst_rogue_the_churning_gulf_raiders","wh_main_group_norsca"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc08_nor_mon_norscan_ice_trolls_0", "special", 2, { military_groupings = {"wh2_dlc11_cst_rogue_the_churning_gulf_raiders","wh_main_group_norsca"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc08_nor_feral_manticore", "special", 1, { military_groupings = {"wh_main_group_norsca","wh_main_group_norsca_steppe"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc08_nor_inf_marauder_berserkers_0", "special", 1, { military_groupings = {"wh2_dlc11_cst_rogue_the_churning_gulf_raiders","wh2_dlc11_cst_shanty_middle_sea_brigands","wh_main_group_norsca","wh_main_group_norsca_steppe"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc08_nor_inf_marauder_champions_0", "special", 2, { military_groupings = {"wh_main_group_norsca","wh_main_group_norsca_steppe"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc08_nor_inf_marauder_champions_1", "special", 2, { military_groupings = {"wh2_dlc11_cst_rogue_the_churning_gulf_raiders","wh2_dlc11_cst_shanty_middle_sea_brigands","wh_main_group_norsca","wh_main_group_norsca_steppe"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc08_nor_mon_skinwolves_0", "special", 2, { military_groupings = {"wh_main_group_norsca","wh_main_group_norsca_steppe"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc08_nor_mon_skinwolves_1", "special", 2, { military_groupings = {"wh_main_group_norsca","wh_main_group_norsca_steppe"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc08_nor_veh_marauder_warwolves_chariot_0", "special", 2, { military_groupings = {"wh_main_group_norsca"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh_dlc08_nor_mon_fimir_0", "rare", 1, { military_groupings = {"wh2_dlc11_cst_rogue_the_churning_gulf_raiders","wh_main_group_norsca"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc08_nor_mon_fimir_1", "rare", 1, { military_groupings = {"wh2_dlc11_cst_rogue_the_churning_gulf_raiders","wh_main_group_norsca"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc08_nor_mon_frost_wyrm_0", "rare", 3, { military_groupings = {"wh2_dlc11_cst_rogue_the_churning_gulf_raiders","wh2_dlc11_cst_shanty_middle_sea_brigands","wh_main_group_norsca"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc08_nor_mon_norscan_giant_0", "rare", 2, { military_groupings = {"wh_main_group_norsca","wh_main_group_norsca_steppe"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc08_nor_mon_war_mammoth_0", "rare", 2, { military_groupings = {"wh2_dlc11_cst_rogue_the_churning_gulf_raiders","wh_main_group_norsca","wh_main_group_norsca_steppe"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh_dlc08_nor_mon_war_mammoth_1", "rare", 3, { military_groupings = {"wh_main_group_norsca","wh_main_group_norsca_steppe"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh_dlc08_nor_mon_war_mammoth_2", "rare", 3, { military_groupings = {"wh_main_group_norsca","wh_main_group_norsca_steppe"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh2_main_lzd_inf_skink_cohort_1", "core", 1, { military_groupings = {"wh2_main_lzd","wh3_dlc23_rogue_sacred_host_of_tepok"}, category = "inf_ranged", tier = nil, cost = 1 }},
        {"wh2_main_lzd_inf_skink_skirmishers_0", "core", 1, { military_groupings = {"wh2_main_lzd","wh3_dlc23_rogue_sacred_host_of_tepok"}, category = "inf_ranged", tier = nil, cost = 1 }},
        {"wh2_main_lzd_inf_saurus_spearmen_0", "core", 2, { military_groupings = {"wh2_main_lzd"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_lzd_inf_saurus_spearmen_1", "core", 2, { military_groupings = {"wh2_main_lzd","wh2_main_rogue_celestial_storm"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_lzd_inf_saurus_warriors_0", "core", 2, { military_groupings = {"wh2_main_lzd"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_lzd_inf_saurus_warriors_1", "core", 2, { military_groupings = {"wh2_main_lzd","wh2_main_rogue_celestial_storm"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_lzd_inf_skink_cohort_0", "core", 1, { military_groupings = {"wh2_main_lzd","wh3_dlc23_rogue_sacred_host_of_tepok"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh2_main_lzd_cav_cold_ones_feral_0", "core", 3, { military_groupings = {"wh2_main_lzd","wh3_dlc23_rogue_sacred_host_of_tepok"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc12_lzd_inf_skink_red_crested_0", "core", 3, { military_groupings = {"wh2_main_lzd","wh3_dlc23_rogue_sacred_host_of_tepok"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_lzd_mon_kroxigors", "special", 2, { military_groupings = {"wh2_main_lzd","wh2_main_rogue_celestial_storm"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_lzd_cav_terradon_riders_0", "special", 1, { military_groupings = {"wh2_main_lzd","wh3_dlc23_rogue_sacred_host_of_tepok"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_main_lzd_cav_terradon_riders_1", "special", 1, { military_groupings = {"wh2_main_lzd","wh3_dlc23_rogue_sacred_host_of_tepok"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_main_lzd_mon_bastiladon_0", "special", 1, { military_groupings = {"wh2_main_lzd","wh2_main_rogue_black_spider_tribe"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_lzd_mon_bastiladon_1", "special", 2, { military_groupings = {"wh2_main_lzd"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh2_main_lzd_mon_bastiladon_2", "special", 2, { military_groupings = {"wh2_main_lzd","wh3_dlc23_rogue_sacred_host_of_tepok"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh2_main_lzd_mon_stegadon_0", "special", 2, { military_groupings = {"wh2_main_lzd"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_lzd_mon_stegadon_1", "special", 2, { military_groupings = {"wh2_main_lzd"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh2_main_lzd_inf_chameleon_skinks_0", "special", 1, { military_groupings = {"wh2_main_lzd"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_main_lzd_inf_temple_guards", "special", 1, { military_groupings = {"wh2_main_lzd"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_lzd_cav_cold_one_spearmen_1", "special", 1, { military_groupings = {"wh2_main_lzd","wh2_main_rogue_celestial_storm"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_main_lzd_cav_cold_ones_1", "special", 1, { military_groupings = {"wh2_main_lzd","wh2_main_rogue_celestial_storm"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_main_lzd_cav_horned_ones_0", "special", 2, { military_groupings = {"wh2_main_lzd"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_dlc12_lzd_mon_salamander_pack_0", "special", 2, { military_groupings = {"wh2_main_lzd","wh3_dlc23_rogue_sacred_host_of_tepok"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_dlc12_lzd_mon_bastiladon_3", "special", 2, { military_groupings = {"wh2_main_lzd"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh2_dlc12_lzd_cav_ripperdactyl_riders_0", "special", 1, { military_groupings = {"wh2_main_lzd","wh3_dlc23_rogue_sacred_host_of_tepok"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_dlc13_lzd_mon_razordon_pack_0", "special", 2, { military_groupings = {"wh2_main_lzd","wh3_dlc23_rogue_sacred_host_of_tepok"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_dlc13_lzd_mon_sacred_kroxigors_0", "special", 2, { military_groupings = {"wh2_main_lzd","wh3_dlc23_rogue_sacred_host_of_tepok"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_lzd_mon_ancient_stegadon", "rare", 3, { military_groupings = {"wh2_main_lzd"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh2_main_lzd_mon_carnosaur_0", "rare", 2, { military_groupings = {"wh2_main_lzd","wh2_main_rogue_beastcatchas"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc12_lzd_mon_ancient_salamander_0", "rare", 1, { military_groupings = {"wh2_main_lzd","wh3_dlc23_rogue_sacred_host_of_tepok"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_dlc12_lzd_mon_ancient_stegadon_1", "rare", 3, { military_groupings = {"wh2_main_lzd"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh2_dlc13_lzd_mon_dread_saurian_0", "rare", 2, { military_groupings = {"wh2_main_lzd"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc13_lzd_mon_dread_saurian_1", "rare", 3, { military_groupings = {"wh2_main_lzd","wh3_dlc23_rogue_sacred_host_of_tepok"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh2_dlc17_lzd_inf_chameleon_stalkers_0", "rare", 1, { military_groupings = {"wh2_main_lzd","wh3_dlc23_rogue_sacred_host_of_tepok"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc17_lzd_mon_coatl_0", "rare", 2, { military_groupings = {"wh2_main_lzd","wh3_dlc23_rogue_sacred_host_of_tepok"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc17_lzd_mon_troglodon_0", "rare", 2, { military_groupings = {"wh2_main_lzd","wh3_dlc23_rogue_sacred_host_of_tepok"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_skv_inf_clanrat_spearmen_0", "core", 2, { military_groupings = {"wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_skv_inf_clanrat_spearmen_1", "core", 2, { military_groupings = {"wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_skv_inf_clanrats_0", "core", 2, { military_groupings = {"wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_skv_inf_clanrats_1", "core", 2, { military_groupings = {"wh2_dlc11_cst_rogue_grey_point_scuttlers","wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_skv_inf_skavenslave_spearmen_0", "core", 1, { military_groupings = {"wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh2_main_skv_inf_skavenslaves_0", "core", 1, { military_groupings = {"wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh2_main_skv_inf_night_runners_0", "core", 3, { military_groupings = {"wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_main_skv_inf_night_runners_1", "core", 3, { military_groupings = {"wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_main_skv_inf_skavenslave_slingers_0", "core", 1, { military_groupings = {"wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_ranged", tier = nil, cost = 1 }},
        {"wh2_main_skv_mon_rat_ogres", "special", 2, { military_groupings = {"wh2_dlc11_cst_rogue_grey_point_scuttlers","wh2_main_rogue_abominations","wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_skv_inf_death_runners_0", "special", 1, { military_groupings = {"wh2_main_rogue_stuff_snatchers","wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_skv_inf_gutter_runner_slingers_0", "special", 1, { military_groupings = {"wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_main_skv_inf_gutter_runner_slingers_1", "special", 1, { military_groupings = {"wh2_dlc11_cst_rogue_grey_point_scuttlers","wh2_main_rogue_stuff_snatchers","wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_main_skv_inf_gutter_runners_0", "special", 1, { military_groupings = {"wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_main_skv_inf_gutter_runners_1", "special", 1, { military_groupings = {"wh2_main_rogue_stuff_snatchers","wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_main_skv_inf_poison_wind_globadiers", "special", 2, { military_groupings = {"wh2_dlc11_cst_rogue_grey_point_scuttlers","wh2_main_rogue_morrsliebs_howlers","wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_main_skv_inf_warpfire_thrower", "special", 1, { military_groupings = {"wh2_dlc11_cst_rogue_grey_point_scuttlers","wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_main_skv_inf_plague_monk_censer_bearer", "special", 2, { military_groupings = {"wh2_main_rogue_morrsliebs_howlers","wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_skv_inf_plague_monks", "special", 1, { military_groupings = {"wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_skv_inf_stormvermin_0", "special", 1, { military_groupings = {"wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_skv_inf_stormvermin_1", "special", 1, { military_groupings = {"wh2_dlc11_cst_rogue_grey_point_scuttlers","wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc12_skv_inf_ratling_gun_0", "special", 1, { military_groupings = {"wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_dlc12_skv_inf_warplock_jezzails_0", "special", 2, { military_groupings = {"wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_dlc12_skv_veh_doom_flayer_0", "special", 2, { military_groupings = {"wh2_main_skv","wh2_main_skv_ikit"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh2_dlc14_skv_inf_eshin_triads_0", "special", 1, { military_groupings = {"wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc14_skv_inf_poison_wind_mortar_0", "special", 2, { military_groupings = {"wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_dlc14_skv_inf_warp_grinder_0", "special", 1, { military_groupings = {"wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc16_skv_mon_rat_ogre_mutant", "special", 3, { military_groupings = {"wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc16_skv_mon_wolf_rats_0", "special", 1, { military_groupings = {"wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc16_skv_mon_wolf_rats_1", "special", 1, { military_groupings = {"wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_skv_art_plagueclaw_catapult", "rare", 1, { military_groupings = {"wh2_main_skv","wh2_main_skv_ikit"}, category = "artillery", tier = nil, cost = 2 }},
        {"wh2_main_skv_art_warp_lightning_cannon", "rare", 2, { military_groupings = {"wh2_dlc11_cst_rogue_grey_point_scuttlers","wh2_main_skv","wh2_main_skv_ikit"}, category = "artillery", tier = nil, cost = 2 }},
        {"wh2_main_skv_veh_doomwheel", "rare", 2, { military_groupings = {"wh2_dlc11_cst_rogue_grey_point_scuttlers","wh2_main_rogue_morrsliebs_howlers","wh2_main_skv","wh2_main_skv_ikit"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh2_main_skv_mon_hell_pit_abomination", "rare", 3, { military_groupings = {"wh2_main_rogue_abominations","wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_skv_inf_death_globe_bombardiers", "rare", 1, { military_groupings = {"wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_dlc16_skv_mon_brood_horror_0", "rare", 2, { military_groupings = {"wh2_main_skv","wh2_main_skv_ikit"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_hef_inf_archers_0", "core", 1, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik","wh2_main_rogue_tor_elithis","wh2_main_rogue_vauls_expedition","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_main_hef_inf_archers_1", "core", 2, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik","wh2_main_rogue_tor_elithis","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_main_hef_inf_lothern_sea_guard_0", "core", 2, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik","wh2_main_rogue_tor_elithis","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_main_hef_inf_lothern_sea_guard_1", "core", 3, { military_groupings = {"wh2_dlc11_cst_shanty_dragon_spine_privateers","wh2_main_hef","wh2_main_hef_imrik","wh2_main_rogue_tor_elithis","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_main_hef_inf_gate_guard", "core", 3, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_main_hef_cav_ellyrian_reavers_1", "core", 2, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik","wh2_main_rogue_tor_elithis"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_main_hef_inf_spearmen_0", "core", 1, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik","wh2_main_rogue_tor_elithis","wh2_main_rogue_vauls_expedition","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_hef_cav_ellyrian_reavers_0", "core", 1, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik","wh2_main_rogue_tor_elithis","wh2_main_rogue_vauls_expedition"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_main_hef_cav_silver_helms_0", "core", 2, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_main_hef_cav_silver_helms_1", "core", 3, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_dlc15_hef_inf_rangers_0", "core", 3, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_hef_inf_phoenix_guard", "special", 2, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_hef_inf_swordmasters_of_hoeth_0", "special", 2, { military_groupings = {"wh2_dlc11_cst_shanty_dragon_spine_privateers","wh2_main_hef","wh2_main_hef_imrik","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_hef_inf_white_lions_of_chrace_0", "special", 1, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik","wh3_main_rogue_alliance_of_order","wh3_main_rogue_the_treaty_of_ashshair"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_hef_cav_dragon_princes", "special", 2, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik","wh2_main_rogue_tor_elithis"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_main_hef_cav_ithilmar_chariot", "special", 2, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh2_main_hef_cav_tiranoc_chariot", "special", 1, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh2_main_hef_mon_great_eagle", "special", 2, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik","wh2_main_rogue_tor_elithis"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc10_hef_inf_shadow_warriors_0", "special", 1, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_dlc15_hef_inf_silverin_guard_0", "special", 1, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc15_hef_mon_war_lions_of_chrace_0", "special", 1, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc15_hef_veh_lion_chariot_of_chrace_0", "special", 2, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh2_main_hef_art_eagle_claw_bolt_thrower", "rare", 1, { military_groupings = {"wh2_dlc11_cst_shanty_dragon_spine_privateers","wh2_main_hef","wh2_main_hef_imrik","wh2_main_rogue_tor_elithis","wh2_main_rogue_vauls_expedition"}, category = "artillery", tier = nil, cost = 2 }},
        {"wh2_main_hef_mon_moon_dragon", "rare", 2, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_hef_mon_phoenix_flamespyre", "rare", 1, { military_groupings = {"wh2_dlc11_cst_shanty_dragon_spine_privateers","wh2_main_hef","wh2_main_hef_imrik"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_hef_mon_phoenix_frostheart", "rare", 1, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_hef_mon_star_dragon", "rare", 3, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_hef_mon_sun_dragon", "rare", 2, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc10_hef_inf_sisters_of_avelorn_0", "rare", 1, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_dlc15_hef_mon_arcane_phoenix_0", "rare", 2, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc10_hef_inf_dryads_0", "core", 3, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc10_hef_mon_treekin_0", "special", 2, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc10_hef_inf_shadow_walkers_0", "special", 2, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_dlc15_hef_inf_mistwalkers_faithbearers_0", "special", 1, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc15_hef_inf_mistwalkers_sentinels_0", "special", 1, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_dlc15_hef_inf_mistwalkers_skyhawks_0", "special", 1, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_dlc15_hef_inf_mistwalkers_spireguard_0", "special", 1, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_dlc10_hef_mon_treeman_0", "rare", 3, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc15_hef_inf_mistwalkers_griffon_knights_0", "rare", 3, { military_groupings = {"wh2_main_hef","wh2_main_hef_imrik"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh2_main_def_inf_black_ark_corsairs_0", "core", 2, { military_groupings = {"wh2_dlc09_rogue_black_creek_raiders","wh2_dlc11_cst_harpoon_the_sunken_land_corsairs","wh2_dlc11_cst_rogue_tyrants_of_the_black_ocean","wh2_main_def","wh2_main_rogue_mengils_manflayers","wh3_main_def_morathi"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_def_inf_black_ark_corsairs_1", "core", 2, { military_groupings = {"wh2_dlc09_rogue_black_creek_raiders","wh2_dlc11_cst_rogue_tyrants_of_the_black_ocean","wh2_main_def","wh2_main_rogue_mengils_manflayers","wh3_main_def_morathi"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_main_def_inf_darkshards_0", "core", 1, { military_groupings = {"wh2_dlc11_cst_harpoon_the_sunken_land_corsairs","wh2_main_def","wh3_main_def_morathi"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_main_def_inf_darkshards_1", "core", 2, { military_groupings = {"wh2_main_def","wh2_main_rogue_vashnaars_conquest","wh3_main_def_morathi"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_main_def_cav_dark_riders_2", "core", 2, { military_groupings = {"wh2_dlc11_cst_harpoon_the_sunken_land_corsairs","wh2_main_def","wh3_main_def_morathi"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_main_def_inf_bleakswords_0", "core", 1, { military_groupings = {"wh2_main_def","wh3_main_def_morathi"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh2_main_def_inf_dreadspears_0", "core", 1, { military_groupings = {"wh2_dlc11_cst_harpoon_the_sunken_land_corsairs","wh2_main_def","wh3_main_def_morathi"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh2_main_def_inf_witch_elves_0", "core", 3, { military_groupings = {"wh2_main_def","wh3_main_def_morathi"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_def_cav_dark_riders_0", "core", 1, { military_groupings = {"wh2_dlc11_cst_harpoon_the_sunken_land_corsairs","wh2_main_def","wh3_main_def_morathi"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_main_def_cav_dark_riders_1", "core", 2, { military_groupings = {"wh2_main_def","wh2_main_rogue_mengils_manflayers","wh3_main_def_morathi"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_main_def_inf_harpies", "special", 1, { military_groupings = {"wh2_dlc11_cst_harpoon_the_sunken_land_corsairs","wh2_dlc11_cst_rogue_tyrants_of_the_black_ocean","wh2_main_def","wh3_main_def_morathi"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh2_dlc10_def_mon_feral_manticore_0", "special", 2, { military_groupings = {"wh2_main_def","wh3_main_def_morathi"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_def_inf_shades_0", "special", 1, { military_groupings = {"wh2_main_def","wh3_main_def_morathi"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_main_def_inf_shades_1", "special", 2, { military_groupings = {"wh2_main_def","wh2_main_rogue_mengils_manflayers","wh3_main_def_morathi"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_main_def_inf_shades_2", "special", 2, { military_groupings = {"wh2_dlc09_rogue_eyes_of_the_jungle","wh2_main_def","wh2_main_rogue_mengils_manflayers","wh3_main_def_morathi"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_main_def_inf_black_guard_0", "special", 2, { military_groupings = {"wh2_dlc11_cst_rogue_tyrants_of_the_black_ocean","wh2_main_def","wh3_main_def_morathi"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_def_cav_cold_one_knights_0", "special", 1, { military_groupings = {"wh2_dlc09_rogue_eyes_of_the_jungle","wh2_main_def","wh2_main_rogue_vashnaars_conquest","wh3_main_def_morathi"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_main_def_cav_cold_one_knights_1", "special", 2, { military_groupings = {"wh2_dlc11_cst_rogue_tyrants_of_the_black_ocean","wh2_main_def","wh2_main_rogue_vashnaars_conquest","wh3_main_def_morathi"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_main_def_inf_har_ganeth_executioners_0", "special", 2, { military_groupings = {"wh2_main_def","wh3_main_def_morathi"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_def_cav_cold_one_chariot", "special", 2, { military_groupings = {"wh2_main_def","wh2_main_rogue_vashnaars_conquest","wh3_main_def_morathi"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh2_dlc10_def_cav_doomfire_warlocks_0", "special", 2, { military_groupings = {"wh2_dlc11_cst_rogue_tyrants_of_the_black_ocean","wh2_main_def","wh3_main_def_morathi"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_dlc14_def_cav_scourgerunner_chariot_0", "special", 2, { military_groupings = {"wh2_main_def","wh3_main_def_morathi"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh2_main_def_art_reaper_bolt_thrower", "rare", 1, { military_groupings = {"wh2_dlc09_rogue_black_creek_raiders","wh2_dlc11_cst_harpoon_the_sunken_land_corsairs","wh2_dlc11_cst_rogue_tyrants_of_the_black_ocean","wh2_main_def","wh2_main_rogue_mengils_manflayers","wh2_main_rogue_vashnaars_conquest","wh3_main_def_morathi"}, category = "artillery", tier = nil, cost = 2 }},
        {"wh2_main_def_mon_black_dragon", "rare", 3, { military_groupings = {"wh2_main_def","wh2_main_rogue_vashnaars_conquest","wh3_main_def_morathi"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_main_def_mon_war_hydra", "rare", 2, { military_groupings = {"wh2_dlc09_rogue_dwellers_of_zardok","wh2_dlc11_cst_rogue_tyrants_of_the_black_ocean","wh2_main_def","wh2_main_rogue_beastcatchas","wh3_main_def_morathi"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc10_def_mon_kharibdyss_0", "rare", 2, { military_groupings = {"wh2_dlc11_cst_rogue_tyrants_of_the_black_ocean","wh2_main_def","wh3_main_def_morathi"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc14_def_mon_bloodwrack_medusa_0", "rare", 1, { military_groupings = {"wh2_main_def","wh3_main_def_morathi"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc14_def_veh_bloodwrack_shrine_0", "rare", 2, { military_groupings = {"wh2_main_def","wh3_main_def_morathi"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh2_twa03_def_mon_wolves_0", "special", 1, { military_groupings = {""}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_twa03_def_mon_war_mammoth_0", "rare", 2, { military_groupings = {""}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_twa03_grn_mon_wyvern_0", "rare", 1, { military_groupings = {""}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_monster_feral_bears", "special", 2, { military_groupings = {"wh2_dlc16_group_drycha","wh3_main_ksl"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_main_monster_feral_ice_bears", "rare", 1, { military_groupings = {"wh3_main_ksl"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc10_def_inf_sisters_of_slaughter", "rare", 1, { military_groupings = {"wh2_main_def","wh3_main_def_morathi"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc09_tmb_inf_nehekhara_warriors_0", "core", 3, { military_groupings = {"wh2_dlc09_tomb_kings","wh2_dlc09_tomb_kings_arkhan"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc09_tmb_inf_skeleton_archers_0", "core", 1, { military_groupings = {"wh2_dlc09_tomb_kings","wh2_dlc09_tomb_kings_arkhan"}, category = "inf_ranged", tier = nil, cost = 1 }},
        {"wh2_dlc09_tmb_inf_skeleton_spearmen_0", "core", 1, { military_groupings = {"wh2_dlc09_tomb_kings","wh2_dlc09_tomb_kings_arkhan"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh2_dlc09_tmb_inf_skeleton_warriors_0", "core", 1, { military_groupings = {"wh2_dlc09_tomb_kings","wh2_dlc09_tomb_kings_arkhan"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh2_dlc09_tmb_veh_skeleton_archer_chariot_0", "core", 2, { military_groupings = {"wh2_dlc09_tomb_kings","wh2_dlc09_tomb_kings_arkhan"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh2_dlc09_tmb_veh_skeleton_chariot_0", "core", 2, { military_groupings = {"wh2_dlc09_tomb_kings","wh2_dlc09_tomb_kings_arkhan"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh2_dlc09_tmb_cav_skeleton_horsemen_0", "core", 1, { military_groupings = {"wh2_dlc09_tomb_kings","wh2_dlc09_tomb_kings_arkhan"}, category = "cavalry", tier = nil, cost = 1 }},
        {"wh2_dlc09_tmb_cav_skeleton_horsemen_archers_0", "core", 2, { military_groupings = {"wh2_dlc09_tomb_kings","wh2_dlc09_tomb_kings_arkhan"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_dlc09_tmb_inf_tomb_guard_0", "special", 1, { military_groupings = {"wh2_dlc09_tomb_kings","wh2_dlc09_tomb_kings_arkhan"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc09_tmb_inf_tomb_guard_1", "special", 1, { military_groupings = {"wh2_dlc09_tomb_kings","wh2_dlc09_tomb_kings_arkhan"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc09_tmb_mon_carrion_0", "special", 1, { military_groupings = {"wh2_dlc09_tomb_kings","wh2_dlc09_tomb_kings_arkhan"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc09_tmb_mon_sepulchral_stalkers_0", "special", 2, { military_groupings = {"wh2_dlc09_tomb_kings","wh2_dlc09_tomb_kings_arkhan"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_dlc09_tmb_mon_ushabti_0", "special", 2, { military_groupings = {"wh2_dlc09_tomb_kings","wh2_dlc09_tomb_kings_arkhan"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc09_tmb_mon_ushabti_1", "special", 2, { military_groupings = {"wh2_dlc09_tomb_kings","wh2_dlc09_tomb_kings_arkhan"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_dlc09_tmb_cav_necropolis_knights_0", "special", 2, { military_groupings = {"wh2_dlc09_tomb_kings","wh2_dlc09_tomb_kings_arkhan"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_dlc09_tmb_cav_necropolis_knights_1", "special", 2, { military_groupings = {"wh2_dlc09_tomb_kings","wh2_dlc09_tomb_kings_arkhan"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_dlc09_tmb_cav_nehekhara_horsemen_0", "special", 1, { military_groupings = {"wh2_dlc09_tomb_kings","wh2_dlc09_tomb_kings_arkhan"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_dlc09_tmb_mon_tomb_scorpion_0", "rare", 1, { military_groupings = {"wh2_dlc09_tomb_kings","wh2_dlc09_tomb_kings_arkhan"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc09_tmb_mon_heirotitan_0", "rare", 3, { military_groupings = {"wh2_dlc09_tomb_kings","wh2_dlc09_tomb_kings_arkhan"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc09_tmb_mon_necrosphinx_0", "rare", 3, { military_groupings = {"wh2_dlc09_tomb_kings","wh2_dlc09_tomb_kings_arkhan"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc09_tmb_art_casket_of_souls_0", "rare", 1, { military_groupings = {"wh2_dlc09_tomb_kings","wh2_dlc09_tomb_kings_arkhan"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh2_dlc09_tmb_art_screaming_skull_catapult_0", "rare", 1, { military_groupings = {"wh2_dlc09_tomb_kings","wh2_dlc09_tomb_kings_arkhan"}, category = "artillery", tier = nil, cost = 2 }},
        {"wh2_dlc09_tmb_veh_khemrian_warsphinx_0", "rare", 2, { military_groupings = {"wh2_dlc09_tomb_kings","wh2_dlc09_tomb_kings_arkhan"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh2_pro06_tmb_mon_bone_giant_0", "rare", 2, { military_groupings = {"wh2_dlc09_tomb_kings","wh2_dlc09_tomb_kings_arkhan"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_dlc09_tmb_mon_dire_wolves", "core", 3, { military_groupings = {"wh2_dlc09_tomb_kings_arkhan"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc09_tmb_mon_fell_bats", "core", 3, { military_groupings = {"wh2_dlc09_tomb_kings_arkhan"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc09_tmb_inf_crypt_ghouls", "core", 3, { military_groupings = {"wh2_dlc09_tomb_kings_arkhan"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc09_tmb_cav_hexwraiths", "special", 2, { military_groupings = {"wh2_dlc09_tomb_kings_arkhan"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_dlc11_cst_inf_sartosa_free_company_0", "core", 3, { military_groupings = {"wh2_dlc11_group_vampire_coast_sartosa"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc11_cst_inf_sartosa_militia_0", "core", 3, { military_groupings = {"wh2_dlc11_group_vampire_coast_sartosa"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_dlc11_cst_inf_zombie_deckhands_mob_0", "core", 1, { military_groupings = {"wh2_dlc11_cst_shanty_shark_straight_seadogs","wh2_dlc11_group_vampire_coast","wh2_dlc11_group_vampire_coast_sartosa"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh2_dlc11_cst_inf_zombie_deckhands_mob_1", "core", 1, { military_groupings = {"wh2_dlc11_cst_rogue_terrors_of_the_dark_straights","wh2_dlc11_group_vampire_coast","wh2_dlc11_group_vampire_coast_sartosa"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh2_dlc11_cst_inf_zombie_gunnery_mob_0", "core", 1, { military_groupings = {"wh2_dlc11_group_vampire_coast","wh2_dlc11_group_vampire_coast_sartosa"}, category = "inf_ranged", tier = nil, cost = 1 }},
        {"wh2_dlc11_cst_inf_zombie_gunnery_mob_1", "core", 2, { military_groupings = {"wh2_dlc11_group_vampire_coast","wh2_dlc11_group_vampire_coast_sartosa"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_dlc11_cst_inf_zombie_gunnery_mob_2", "core", 2, { military_groupings = {"wh2_dlc11_group_vampire_coast","wh2_dlc11_group_vampire_coast_sartosa"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_dlc11_cst_inf_zombie_gunnery_mob_3", "core", 3, { military_groupings = {"wh2_dlc11_group_vampire_coast","wh2_dlc11_group_vampire_coast_sartosa"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_dlc11_cst_mon_bloated_corpse_0", "core", 3, { military_groupings = {"wh2_dlc11_group_vampire_coast","wh2_dlc11_group_vampire_coast_sartosa"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc11_cst_mon_fell_bats", "core", 3, { military_groupings = {"wh2_dlc11_group_vampire_coast","wh2_dlc11_group_vampire_coast_sartosa"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc11_cst_mon_scurvy_dogs", "core", 3, { military_groupings = {"wh2_dlc11_group_vampire_coast","wh2_dlc11_group_vampire_coast_sartosa"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc11_cst_art_carronade", "special", 2, { military_groupings = {"wh2_dlc11_cst_rogue_terrors_of_the_dark_straights","wh2_dlc11_group_vampire_coast","wh2_dlc11_group_vampire_coast_sartosa"}, category = "artillery", tier = nil, cost = 2 }},
        {"wh2_dlc11_cst_art_mortar", "special", 2, { military_groupings = {"wh2_dlc11_cst_shanty_shark_straight_seadogs","wh2_dlc11_group_vampire_coast","wh2_dlc11_group_vampire_coast_sartosa"}, category = "artillery", tier = nil, cost = 2 }},
        {"wh2_dlc11_cst_cav_deck_droppers_0", "special", 1, { military_groupings = {"wh2_dlc11_group_vampire_coast","wh2_dlc11_group_vampire_coast_sartosa"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_dlc11_cst_cav_deck_droppers_1", "special", 1, { military_groupings = {"wh2_dlc11_group_vampire_coast","wh2_dlc11_group_vampire_coast_sartosa"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_dlc11_cst_cav_deck_droppers_2", "special", 1, { military_groupings = {"wh2_dlc11_group_vampire_coast","wh2_dlc11_group_vampire_coast_sartosa"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh2_dlc11_cst_inf_deck_gunners_0", "special", 1, { military_groupings = {"wh2_dlc11_cst_rogue_terrors_of_the_dark_straights","wh2_dlc11_group_vampire_coast","wh2_dlc11_group_vampire_coast_sartosa"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh2_dlc11_cst_inf_depth_guard_0", "special", 2, { military_groupings = {"wh2_dlc11_cst_rogue_terrors_of_the_dark_straights","wh2_dlc11_group_vampire_coast","wh2_dlc11_group_vampire_coast_sartosa"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc11_cst_inf_depth_guard_1", "special", 2, { military_groupings = {"wh2_dlc11_cst_rogue_terrors_of_the_dark_straights","wh2_dlc11_group_vampire_coast","wh2_dlc11_group_vampire_coast_sartosa"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc11_cst_inf_syreens", "special", 2, { military_groupings = {"wh2_dlc11_cst_rogue_terrors_of_the_dark_straights","wh2_dlc11_group_vampire_coast","wh2_dlc11_group_vampire_coast_sartosa"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc11_cst_mon_animated_hulks_0", "special", 1, { military_groupings = {"wh2_dlc11_group_vampire_coast","wh2_dlc11_group_vampire_coast_sartosa"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc11_cst_mon_rotting_prometheans_0", "special", 2, { military_groupings = {"wh2_dlc11_cst_shanty_shark_straight_seadogs","wh2_dlc11_group_vampire_coast","wh2_dlc11_group_vampire_coast_sartosa"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc11_cst_mon_rotting_prometheans_gunnery_mob_0", "special", 2, { military_groupings = {"wh2_dlc11_cst_rogue_terrors_of_the_dark_straights","wh2_dlc11_cst_shanty_shark_straight_seadogs","wh2_dlc11_group_vampire_coast","wh2_dlc11_group_vampire_coast_sartosa"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh2_dlc11_cst_mon_mournguls_0", "rare", 1, { military_groupings = {"wh2_dlc11_group_vampire_coast","wh2_dlc11_group_vampire_coast_sartosa","wh_main_group_vampire_counts"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh2_dlc11_cst_mon_necrofex_colossus_0", "rare", 3, { military_groupings = {"wh2_dlc11_cst_rogue_terrors_of_the_dark_straights","wh2_dlc11_group_vampire_coast","wh2_dlc11_group_vampire_coast_sartosa"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh2_dlc11_cst_mon_rotting_leviathan_0", "rare", 3, { military_groupings = {"wh2_dlc11_cst_rogue_terrors_of_the_dark_straights","wh2_dlc11_group_vampire_coast","wh2_dlc11_group_vampire_coast_sartosa"}, category = "war_beast", tier = nil, cost = 2 }},
        {"wh2_dlc11_cst_mon_terrorgheist", "rare", 3, { military_groupings = {"wh2_dlc11_cst_rogue_terrors_of_the_dark_straights","wh2_dlc11_group_vampire_coast","wh2_dlc11_group_vampire_coast_sartosa"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc23_chd_inf_chaos_dwarf_blunderbusses", "core", 3, { military_groupings = {"wh3_dlc23_group_chaos_dwarfs"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh3_dlc23_chd_inf_chaos_dwarf_warriors", "core", 2, { military_groupings = {"wh3_dlc23_group_chaos_dwarfs"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc23_chd_inf_chaos_dwarf_warriors_great_weapons", "core", 2, { military_groupings = {"wh3_dlc23_group_chaos_dwarfs"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc23_chd_inf_goblin_labourers", "core", 1, { military_groupings = {"wh3_dlc23_group_chaos_dwarfs","wh3_dlc24_group_labourer_rebels"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_dlc23_chd_inf_hobgoblin_archers", "core", 1, { military_groupings = {"wh3_dlc23_group_chaos_dwarfs","wh3_dlc24_group_labourer_rebels"}, category = "inf_ranged", tier = nil, cost = 1 }},
        {"wh3_dlc23_chd_inf_hobgoblin_cutthroats", "core", 1, { military_groupings = {"wh3_dlc23_group_chaos_dwarfs","wh3_dlc24_group_labourer_rebels"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_dlc23_chd_inf_orc_labourers", "core", 1, { military_groupings = {"wh3_dlc23_group_chaos_dwarfs","wh3_dlc24_group_labourer_rebels"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_dlc23_chd_inf_hobgoblin_sneaky_gits", "special", 1, { military_groupings = {"wh3_dlc23_group_chaos_dwarfs","wh3_dlc24_group_labourer_rebels"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_dlc23_chd_inf_infernal_guard", "special", 1, { military_groupings = {"wh3_dlc23_group_chaos_dwarfs"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc23_chd_inf_infernal_guard_fireglaives", "special", 1, { military_groupings = {"wh3_dlc23_group_chaos_dwarfs"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh3_dlc23_chd_inf_infernal_guard_great_weapons", "special", 1, { military_groupings = {"wh3_dlc23_group_chaos_dwarfs"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc23_chd_veh_deathshrieker_rocket_launcher", "special", 2, { military_groupings = {"wh3_dlc23_group_chaos_dwarfs"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh3_dlc23_chd_veh_iron_daemon", "special", 2, { military_groupings = {"wh3_dlc23_group_chaos_dwarfs"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh3_dlc23_chd_veh_magma_cannon", "special", 2, { military_groupings = {"wh3_dlc23_group_chaos_dwarfs"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh3_dlc23_chd_veh_skullcracker", "special", 2, { military_groupings = {"wh3_dlc23_group_chaos_dwarfs"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh3_dlc23_chd_cav_bull_centaurs_axe", "special", 2, { military_groupings = {"wh3_dlc23_group_chaos_dwarfs"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc23_chd_cav_bull_centaurs_dual_axe", "special", 2, { military_groupings = {"wh3_dlc23_group_chaos_dwarfs"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc23_chd_cav_bull_centaurs_greatweapons", "special", 2, { military_groupings = {"wh3_dlc23_group_chaos_dwarfs"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc23_chd_inf_infernal_ironsworn", "special", 2, { military_groupings = {"wh3_dlc23_group_chaos_dwarfs"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc23_chd_mon_kdaai_fireborn", "special", 2, { military_groupings = {"wh3_dlc23_group_chaos_dwarfs"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc23_chd_cav_hobgoblin_wolf_raiders_bows", "rare", 1, { military_groupings = {"wh3_dlc23_group_chaos_dwarfs","wh3_dlc24_group_labourer_rebels"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh3_dlc23_chd_cav_hobgoblin_wolf_raiders_spears", "rare", 1, { military_groupings = {"wh3_dlc23_group_chaos_dwarfs","wh3_dlc24_group_labourer_rebels"}, category = "cavalry", tier = nil, cost = 2 }},
        {"wh3_dlc23_chd_mon_great_taurus", "rare", 1, { military_groupings = {"wh3_dlc23_group_chaos_dwarfs"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc23_chd_mon_lammasu", "rare", 2, { military_groupings = {"wh3_dlc23_group_chaos_dwarfs"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc23_chd_mon_bale_taurus", "rare", 2, { military_groupings = {"wh2_main_rogue_abominations","wh3_dlc23_group_chaos_dwarfs"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc23_chd_mon_kdaai_destroyer", "rare", 3, { military_groupings = {"wh3_dlc23_group_chaos_dwarfs"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc23_chd_veh_dreadquake_mortar", "rare", 3, { military_groupings = {"wh3_dlc23_group_chaos_dwarfs"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh3_dlc23_chd_veh_skullcracker_1dreadquake", "rare", 3, { military_groupings = {"wh3_dlc23_group_chaos_dwarfs"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh3_dlc23_chd_veh_iron_daemon_1dreadquake", "rare", 3, { military_groupings = {"wh3_dlc23_group_chaos_dwarfs"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh3_dlc24_bst_inf_tzaangors", "special", 1, { military_groupings = {"wh_dlc03_group_beastmen"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc24_bst_mon_incarnate_elemental_of_beasts", "rare", 3, { military_groupings = {"wh_dlc03_group_beastmen"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc24_cth_inf_onyx_crowmen", "special", 1, { military_groupings = {"wh3_main_cth"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc24_cth_mon_jade_lion", "special", 3, { military_groupings = {"wh3_main_cth"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc24_cth_mon_jet_lion", "special", 3, { military_groupings = {"wh3_main_cth"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc24_cth_veh_zhangu_war_drum", "rare", 2, { military_groupings = {"wh3_main_cth"}, category = "war_machine", tier = nil, cost = 2 }},
        {"wh3_dlc24_ksl_inf_akshina_ambushers", "rare", 1, { military_groupings = {"wh3_main_ksl"}, category = "inf_ranged", tier = nil, cost = 2 }},
        {"wh3_dlc24_ksl_mon_incarnate_elemental_of_beasts", "rare", 3, { military_groupings = {"wh3_main_ksl"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc24_ksl_mon_the_things_in_the_woods", "special", 2, { military_groupings = {"wh2_main_rogue_abominations","wh3_main_ksl"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc24_lzd_mon_carnosaur_0", "rare", 2, { military_groupings = {"wh3_main_tze"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc24_tze_inf_tzaangors", "special", 1, { military_groupings = {"wh3_dlc20_group_chs_vilitch","wh3_main_dae","wh3_main_group_belakor","wh3_main_tze","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc24_tze_mon_cockatrice", "rare", 2, { military_groupings = {"wh3_dlc20_group_chs_vilitch","wh3_main_dae","wh3_main_group_belakor","wh3_main_tze","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc24_tze_mon_mutalith_vortex_beast", "rare", 3, { military_groupings = {"wh3_dlc20_group_chs_vilitch","wh3_main_dae","wh3_main_group_belakor","wh3_main_tze","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc24_tze_mon_flamers_changebringers", "special", 2, { military_groupings = {"wh3_dlc20_group_chs_vilitch","wh3_main_dae","wh3_main_group_belakor","wh3_main_tze","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc24_ksl_mon_frost_wyrm", "rare", 2, { military_groupings = {"wh3_main_ksl"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc24_cth_mon_great_moon_bird", "special", 3, { military_groupings = {"wh3_main_cth"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc24_ksl_inf_kislevite_warriors", "core", 1, { military_groupings = {"wh3_main_ksl"}, category = "inf_melee", tier = nil, cost = 1 }},
        {"wh3_dlc24_tze_inf_centigors_great_weapons", "special", 1, { military_groupings = {"wh3_dlc20_group_chs_vilitch","wh3_main_dae","wh3_main_group_belakor","wh3_main_tze","wh_main_group_chaos"}, category = "inf_melee", tier = nil, cost = 2 }},
        {"wh3_dlc24_cth_mon_celestial_lion", "rare", 2, { military_groupings = {"wh3_main_cth"}, category = "inf_melee", tier = nil, cost = 2 }},
    }
    pttg_merc_pool:add_unit_list(mercenaries)
end

cm:add_first_tick_callback(function() init_merc_list() end);

core:add_static_object("pttg_merc_pool", pttg_merc_pool);
