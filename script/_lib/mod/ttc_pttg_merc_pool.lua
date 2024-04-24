local pttg = core:get_static_object("pttg");
local ttc = core:get_static_object("tabletopcaps");

PttG_MercInfo = {
}

function PttG_MercInfo:new(key, category, culture, tier)
    local self = {}
    if not key or not category or not culture then
        script_error("Cannot add merc without a name_key, category and culture.")
        return false
    end
    self.key = key
    self.category = category
    self.culture = culture
    self.tier = tier or false
    self.weight = false
    self.cost = 1
    setmetatable(self, { __index = PttG_MercInfo })
    return self
end

function PttG_MercInfo.repr(self)
    return string.format("Merc(%s): %s, %s, %s, %s", self.key, self.culture, self.category, self.tier, self.weight)
end

local pttg_merc_pool = {
    merc_pool = {},
    merc_units = {},
    active_merc_pool = {}
}


--TODO: support these features:
local subculture_defaults = {
    ["wh_main_sc_emp_empire"]          = { "wh_dlc04_emp_inf_free_company_militia_0", "wh_main_emp_cav_empire_knights", "wh_main_emp_inf_halberdiers", "wh_main_emp_inf_handgunners", "wh_main_emp_inf_spearmen_1", "wh_main_emp_inf_swordsmen", "wh2_dlc13_emp_inf_archers_0", "wh_main_emp_inf_crossbowmen" },
    ["wh_main_sc_dwf_dwarfs"]          = { "wh_main_dwf_inf_longbeards", "wh_main_dwf_inf_thunderers_0", "wh_main_dwf_inf_dwarf_warrior_0", "wh_main_dwf_inf_dwarf_warrior_1", "wh_main_dwf_inf_quarrellers_0", "wh_main_dwf_inf_miners_1" },
    ["wh_dlc03_sc_bst_beastmen"]       = { "wh_dlc03_bst_inf_gor_herd_0", "wh_dlc03_bst_inf_ungor_raiders_0", "wh_dlc03_bst_inf_ungor_spearmen_1", "wh_dlc03_bst_inf_gor_herd_0", "wh_dlc03_bst_inf_gor_herd_0" },
    ["wh_dlc05_sc_wef_wood_elves"]     = { "wh_dlc05_wef_inf_eternal_guard_1", "wh_dlc05_wef_inf_glade_guard_0", "wh_dlc05_wef_inf_dryads_0" },
    ["wh_main_sc_brt_bretonnia"]       = { "wh_main_brt_cav_knights_of_the_realm", "wh_dlc07_brt_inf_men_at_arms_2", "wh_main_brt_inf_peasant_bowmen", "wh_main_brt_cav_knights_of_the_realm" },
    ["wh_main_sc_chs_chaos"]           = { "wh_main_chs_inf_chaos_warriors_0", "wh_main_chs_cav_chaos_chariot", "wh_main_chs_inf_chaos_warriors_0", "wh_main_chs_inf_chaos_warriors_0", "wh_dlc01_chs_inf_forsaken_0" },
    ["wh_main_sc_grn_greenskins"]      = { "wh_main_grn_inf_orc_big_uns", "wh_dlc06_grn_inf_nasty_skulkers_0", "wh_main_grn_inf_orc_arrer_boyz", "wh_main_grn_inf_orc_boyz" },
    ["wh_main_sc_grn_savage_orcs"]     = { "wh_main_grn_inf_savage_orc_big_uns", "wh_main_grn_inf_savage_orc_arrer_boyz", "wh_main_grn_inf_savage_orcs" },
    ["wh_main_sc_nor_norsca"]          = { "wh_main_nor_inf_chaos_marauders_0", "wh_dlc08_nor_inf_marauder_hunters_1", "wh_main_nor_inf_chaos_marauders_0", "wh_dlc08_nor_inf_marauder_spearman_0", "wh_main_nor_cav_marauder_horsemen_0" },
    ["wh_main_sc_vmp_vampire_counts"]  = { "wh_main_vmp_inf_crypt_ghouls", "wh_main_vmp_inf_skeleton_warriors_0", "wh_main_vmp_inf_skeleton_warriors_1", "wh_main_vmp_inf_zombie", "wh_main_vmp_mon_fell_bats", "wh_main_vmp_mon_dire_wolves" },
    ["wh2_dlc09_sc_tmb_tomb_kings"]    = { "wh2_dlc09_tmb_inf_nehekhara_warriors_0", "wh2_dlc09_tmb_inf_skeleton_archers_0", "wh2_dlc09_tmb_veh_skeleton_archer_chariot_0", "wh2_dlc09_tmb_inf_nehekhara_warriors_0" },
    ["wh2_main_sc_def_dark_elves"]     = { "wh2_main_def_inf_black_ark_corsairs_0", "wh2_main_def_inf_darkshards_0", "wh2_main_def_inf_dreadspears_0" },
    ["wh2_main_sc_hef_high_elves"]     = { "wh2_main_hef_inf_spearmen_0", "wh2_main_hef_inf_spearmen_0", "wh2_main_hef_inf_archers_1", "wh2_main_hef_cav_silver_helms_0", "wh2_main_hef_inf_lothern_sea_guard_1" },
    ["wh2_main_sc_lzd_lizardmen"]      = { "wh2_main_lzd_inf_saurus_warriors_1", "wh2_main_lzd_inf_saurus_spearmen_0", "wh2_main_lzd_inf_saurus_warriors_1", "wh2_main_lzd_inf_skink_cohort_1" },
    ["wh2_main_sc_skv_skaven"]         = { "wh2_main_skv_inf_clanrats_1", "wh2_main_skv_inf_clanrat_spearmen_1", "wh2_main_skv_inf_night_runners_1", "wh2_main_skv_inf_skavenslave_slingers_0" },
    ["wh2_dlc11_sc_cst_vampire_coast"] = { "wh2_dlc11_cst_inf_zombie_gunnery_mob_0", "wh2_dlc11_cst_inf_zombie_gunnery_mob_0", "wh2_dlc11_cst_inf_zombie_gunnery_mob_1", "wh2_dlc11_cst_mon_bloated_corpse_0", "wh2_dlc11_cst_inf_zombie_deckhands_mob_1" },
    --wh3
    ["wh3_main_sc_cth_cathay"]         = { "wh3_main_cth_inf_jade_warrior_crossbowmen_0", "wh3_main_cth_inf_jade_warrior_crossbowmen_1", "wh3_main_cth_inf_jade_warriors_0", "wh3_main_cth_inf_jade_warriors_1", "wh3_main_cth_inf_iron_hail_gunners_0" },
    ["wh3_main_sc_kho_khorne"]         = { "wh3_main_kho_inf_bloodletters_0" },
    ["wh3_main_sc_ksl_kislev"]         = { "wh3_main_ksl_inf_streltsi_0", "wh3_main_ksl_cav_horse_archers_0", "wh3_main_ksl_inf_armoured_kossars_1", "wh3_main_ksl_inf_armoured_kossars_0", "wh3_main_ksl_cav_winged_lancers_0" },
    ["wh3_main_sc_nur_nurgle"]         = { "wh3_main_nur_inf_plaguebearers_0", "wh3_main_nur_mon_plague_toads_0", "wh3_main_nur_inf_nurglings_0" },
    ["wh3_main_sc_ogr_ogre_kingdoms"]  = { "wh3_main_ogr_inf_ogres_0", "wh3_main_ogr_inf_ogres_1", "wh3_main_ogr_inf_ogres_2" },
    ["wh3_main_sc_sla_slaanesh"]       = { "wh3_main_sla_inf_daemonette_0", "wh3_main_sla_inf_marauders_2" },
    ["wh3_main_sc_tze_tzeentch"]       = { "wh3_main_tze_inf_pink_horrors_0", "wh3_main_tze_inf_blue_horrors_0" },
    ["wh3_main_sc_dae_daemons"]        = { "wh3_main_kho_inf_bloodletters_0", "wh3_main_nur_inf_nurglings_0", "wh3_main_sla_inf_daemonette_0", "wh3_main_tze_inf_pink_horrors_0", "wh3_main_tze_inf_blue_horrors_0" },
    --wh3 DLC
    ["wh3_dlc23_sc_chd_chaos_dwarfs"]  = { "wh3_dlc23_chd_inf_chaos_dwarf_warriors", "wh3_dlc23_chd_inf_chaos_dwarf_warriors_great_weapons", "wh3_dlc23_chd_inf_chaos_dwarf_blunderbusses", "wh3_dlc23_chd_inf_hobgoblin_cutthroats" }
} --:map<string, vector<string>>


local function fix_daemons()
    local daemons_of_chaos = {
        "wh3_dlc20_chs_cav_marauder_horsemen_msla_javelins",
        "wh3_dlc20_chs_inf_chaos_marauders_mkho_dualweapons",
        "wh3_dlc20_chs_inf_chaos_marauders_mnur",
        "wh3_dlc20_chs_inf_chaos_marauders_mtze_spears",
        "wh3_dlc20_chs_inf_chaos_warriors_mnur_greatweapons",
        "wh3_dlc20_chs_inf_chaos_warriors_msla_hellscourges",
        "wh3_dlc20_chs_inf_chaos_warriors_mtze_halberds",
        "wh3_dlc20_chs_inf_forsaken_mkho",
        "wh3_dlc20_chs_inf_forsaken_msla",
        "wh3_dlc20_chs_mon_warshrine_mkho",
        "wh3_dlc20_chs_mon_warshrine_mnur",
        "wh3_dlc20_chs_mon_warshrine_msla",
        "wh3_dlc20_chs_mon_warshrine_mtze",
        "wh3_dlc20_chs_mon_warshrine",
        "wh3_dlc24_tze_inf_centigors_great_weapons",
        "wh3_dlc24_tze_inf_tzaangors",
        "wh3_dlc24_tze_mon_cockatrice",
        "wh3_dlc24_tze_mon_flamers_changebringers",
        "wh3_dlc24_tze_mon_mutalith_vortex_beast",
        "wh3_main_dae_inf_chaos_furies_0",
        "wh3_main_kho_cav_bloodcrushers_0",
        "wh3_main_kho_cav_gorebeast_chariot",
        "wh3_main_kho_cav_skullcrushers_0",
        "wh3_main_kho_inf_bloodletters_0",
        "wh3_main_kho_inf_bloodletters_1",
        "wh3_main_kho_inf_chaos_furies_0",
        "wh3_main_kho_inf_chaos_warhounds_0",
        "wh3_main_kho_inf_chaos_warriors_0",
        "wh3_main_kho_inf_chaos_warriors_1",
        "wh3_main_kho_inf_chaos_warriors_2",
        "wh3_main_kho_inf_flesh_hounds_of_khorne_0",
        "wh3_main_kho_mon_bloodthirster_0",
        "wh3_main_kho_mon_khornataurs_0",
        "wh3_main_kho_mon_khornataurs_1",
        "wh3_main_kho_mon_soul_grinder_0",
        "wh3_main_kho_mon_spawn_of_khorne_0",
        "wh3_main_kho_veh_blood_shrine_0",
        "wh3_main_kho_veh_skullcannon_0",
        "wh3_main_nur_cav_plague_drones_0",
        "wh3_main_nur_cav_plague_drones_1",
        "wh3_main_nur_cav_pox_riders_of_nurgle_0",
        "wh3_main_nur_inf_chaos_furies_0",
        "wh3_main_nur_inf_forsaken_0",
        "wh3_main_nur_inf_nurglings_0",
        "wh3_main_nur_inf_plaguebearers_0",
        "wh3_main_nur_inf_plaguebearers_1",
        "wh3_main_nur_mon_beast_of_nurgle_0",
        "wh3_main_nur_mon_great_unclean_one_0",
        "wh3_main_nur_mon_plague_toads_0",
        "wh3_main_nur_mon_rot_flies_0",
        "wh3_main_nur_mon_soul_grinder_0",
        "wh3_main_nur_mon_spawn_of_nurgle_0",
        "wh3_main_sla_cav_heartseekers_of_slaanesh_0",
        "wh3_main_sla_cav_hellstriders_0",
        "wh3_main_sla_cav_hellstriders_1",
        "wh3_main_sla_cav_seekers_of_slaanesh_0",
        "wh3_main_sla_inf_chaos_furies_0",
        "wh3_main_sla_inf_daemonette_0",
        "wh3_main_sla_inf_daemonette_1",
        "wh3_main_sla_inf_marauders_0",
        "wh3_main_sla_inf_marauders_1",
        "wh3_main_sla_inf_marauders_2",
        "wh3_main_sla_mon_fiends_of_slaanesh_0",
        "wh3_main_sla_mon_keeper_of_secrets_0",
        "wh3_main_sla_mon_soul_grinder_0",
        "wh3_main_sla_mon_spawn_of_slaanesh_0",
        "wh3_main_sla_veh_exalted_seeker_chariot_0",
        "wh3_main_sla_veh_hellflayer_0",
        "wh3_main_sla_veh_seeker_chariot_0",
        "wh3_main_tze_cav_chaos_knights_0",
        "wh3_main_tze_cav_doom_knights_0",
        "wh3_main_tze_inf_blue_horrors_0",
        "wh3_main_tze_inf_chaos_furies_0",
        "wh3_main_tze_inf_forsaken_0",
        "wh3_main_tze_inf_pink_horrors_0",
        "wh3_main_tze_inf_pink_horrors_1",
        "wh3_main_tze_mon_exalted_flamers_0",
        "wh3_main_tze_mon_flamers_0",
        "wh3_main_tze_mon_lord_of_change_0",
        "wh3_main_tze_mon_screamers_0",
        "wh3_main_tze_mon_soul_grinder_0",
        "wh3_main_tze_mon_spawn_of_tzeentch_0",
        "wh3_main_tze_veh_burning_chariot_0"
    }
    for _, unit in pairs(daemons_of_chaos) do
        local unit_info = pttg_merc_pool.merc_units[unit]
        if unit_info then
            table.insert(pttg_merc_pool.merc_pool["wh3_main_dae_daemons"][unit_info.tier], unit_info)
        end
    end
end
---special rules are set up in the database using effects, however, flagging them here is necessary because it is too expensive for the script to check all 1600 possible units for a special rule.
---Valid flags are "subtype", "faction" and "subculture"
---multiple flags are OR, not AND. For example: {subculture = wh3_main_sc_ksl_kislev, subtype = wh3_main_ksl_katarin} would apply to anyone who is from the kislev subculture because it means "Is from kislev OR is katarin"
---Special rules *do* affect the AI.
local units_with_special_rules = {
    { "wh2_main_skv_inf_plague_monks",                  { subtype = "wh2_main_skv_lord_skrolk" } },
    { "wh3_dlc23_chd_inf_infernal_guard",               { subtype = "wh3_dlc23_chd_drazhoath" } },
    { "wh3_dlc23_chd_inf_infernal_guard_fireglaives",   { subtype = "wh3_dlc23_chd_drazhoath" } },
    { "wh3_dlc23_chd_inf_infernal_guard_great_weapons", { subtype = "wh3_dlc23_chd_drazhoath" } }
}


function pttg_merc_pool:reset_merc_pool()
    local faction = cm:get_local_faction()
    for culture, tiers in pairs(self.merc_pool) do
        for tier, units in ipairs(tiers) do
            for i, unit_info in ipairs(units) do
                unit = unit_info.key
                self:add_unit_to_pool(unit, 0)
            end
        end
    end
end

local tiers = { ["core"] = 1, ["special"] = 2, ["rare"] = 3 }
local function get_tier(group)
    tier = tiers[group]

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

    for unit_key, info in pairs(ttc.units) do
        local merc_info = self.merc_units[unit_key]
        if merc_info then
            if not self.merc_pool[merc_info.culture] then
                self.merc_pool[merc_info.culture] = { {}, {}, {}, {} }
            end

            merc_info.weight = get_weight(info.weight)
            merc_info.tier = merc_info.tier or get_tier(info.group)

            pttg:log(string.format("[pttg_MercPool] Adding unit %s", merc_info:repr()))

            table.insert(self.merc_pool[merc_info.culture][tier], merc_info)
        end
    end
    fix_daemons()
end

function pttg_merc_pool:add_unit(unit_info)
    local extra_info = unit_info[4]
    self.merc_units[unit_info[1]] = PttG_MercInfo:new(unit_info[1], extra_info.category, extra_info.culture, extra_info.tier)
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

ttc.add_post_setup_callback(
    function()
        pttg_merc_pool:reset_merc_pool()
        pttg_merc_pool:init_merc_pool()
    end
);

local function init_merc_list()
    local mercenaries = {
        { "wh3_main_cth_inf_jade_warrior_crossbowmen_0",            "core",    2, { culture = "wh3_main_cth_cathay", category = "inf_ranged", tier = nil, } },
        { "wh3_main_cth_inf_jade_warrior_crossbowmen_1",            "core",    2, { culture = "wh3_main_cth_cathay", category = "inf_ranged", tier = nil, } },
        { "wh3_main_cth_inf_jade_warriors_0",                       "core",    2, { culture = "wh3_main_cth_cathay", category = "inf_melee", tier = nil, } },
        { "wh3_main_cth_inf_jade_warriors_1",                       "core",    2, { culture = "wh3_main_cth_cathay", category = "inf_melee", tier = nil, } },
        { "wh3_main_cth_inf_peasant_archers_0",                     "core",    1, { culture = "wh3_main_cth_cathay", category = "inf_ranged", tier = nil, } },
        { "wh3_main_cth_inf_peasant_spearmen_1",                    "core",    1, { culture = "wh3_main_cth_cathay", category = "inf_melee", tier = nil, } },
        { "wh3_main_cth_cav_peasant_horsemen_0",                    "core",    1, { culture = "wh3_main_cth_cathay", category = "war_beast", tier = nil, } },
        { "wh3_main_cth_inf_iron_hail_gunners_0",                   "core",    3, { culture = "wh3_main_cth_cathay", category = "inf_ranged", tier = nil, } },
        { "wh3_main_cth_cav_jade_lancers_0",                        "special", 1, { culture = "wh3_main_cth_cathay", category = "war_beast", tier = nil, } },
        { "wh3_main_cth_art_grand_cannon_0",                        "special", 2, { culture = "wh3_main_cth_cathay", category = "artillery", tier = nil, } },
        { "wh3_main_cth_inf_crane_gunners_0",                       "special", 2, { culture = "wh3_main_cth_cathay", category = "inf_ranged", tier = nil, } },
        { "wh3_main_cth_veh_sky_junk_0",                            "special", 3, { culture = "wh3_main_cth_cathay", category = "war_beast", tier = nil, } },
        { "wh3_main_cth_veh_sky_lantern_0",                         "special", 1, { culture = "wh3_main_cth_cathay", category = "war_beast", tier = nil, } },
        { "wh3_main_cth_inf_dragon_guard_0",                        "rare",    1, { culture = "wh3_main_cth_cathay", category = "inf_melee", tier = nil, } },
        { "wh3_main_cth_inf_dragon_guard_crossbowmen_0",            "rare",    1, { culture = "wh3_main_cth_cathay", category = "inf_ranged", tier = nil, } },
        { "wh3_main_cth_cav_jade_longma_riders_0",                  "rare",    2, { culture = "wh3_main_cth_cathay", category = "war_beast", tier = nil, } },
        { "wh3_main_cth_art_fire_rain_rocket_battery_0",            "rare",    2, { culture = "wh3_main_cth_cathay", category = "artillery", tier = nil, } },
        { "wh3_main_cth_mon_terracotta_sentinel_0",                 "rare",    3, { culture = "wh3_main_cth_cathay", category = "inf_melee", tier = nil, } },
        { "wh3_main_cth_veh_war_compass_0",                         "rare",    1, { culture = "wh3_main_cth_cathay", category = "war_machine", tier = nil, } },
        { "wh3_main_kho_inf_bloodletters_0",                        "core",    2, { culture = "wh3_main_kho_khorne", category = "inf_melee", tier = nil, } },
        { "wh3_main_kho_inf_chaos_warhounds_0",                     "core",    3, { culture = "wh3_main_kho_khorne", category = "inf_melee", tier = nil, } },
        { "wh3_main_kho_inf_chaos_warriors_0",                      "core",    1, { culture = "wh3_main_kho_khorne", category = "inf_melee", tier = nil, } },
        { "wh3_main_kho_inf_chaos_warriors_1",                      "core",    1, { culture = "wh3_main_kho_khorne", category = "inf_melee", tier = nil, } },
        { "wh3_main_kho_inf_chaos_warriors_2",                      "core",    1, { culture = "wh3_main_kho_khorne", category = "inf_melee", tier = nil, } },
        { "wh3_main_kho_inf_bloodletters_1",                        "special", 2, { culture = "wh3_main_kho_khorne", category = "inf_melee", tier = nil, } },
        { "wh3_main_kho_cav_bloodcrushers_0",                       "special", 2, { culture = "wh3_main_kho_khorne", category = "cavalry", tier = nil, } },
        { "wh3_main_kho_cav_gorebeast_chariot",                     "special", 1, { culture = "wh3_main_kho_khorne", category = "war_machine", tier = nil, } },
        { "wh3_main_kho_mon_khornataurs_0",                         "special", 3, { culture = "wh3_main_kho_khorne", category = "inf_melee", tier = nil, } },
        { "wh3_main_kho_mon_khornataurs_1",                         "special", 3, { culture = "wh3_main_kho_khorne", category = "inf_melee", tier = nil, } },
        { "wh3_main_kho_inf_flesh_hounds_of_khorne_0",              "special", 1, { culture = "wh3_main_kho_khorne", category = "inf_melee", tier = nil, } },
        { "wh3_main_kho_inf_chaos_furies_0",                        "special", 1, { culture = "wh3_main_kho_khorne", category = "inf_melee", tier = nil, } },
        { "wh3_main_kho_cav_skullcrushers_0",                       "rare",    2, { culture = "wh3_main_kho_khorne", category = "cavalry", tier = nil, } },
        { "wh3_main_kho_mon_bloodthirster_0",                       "rare",    3, { culture = "wh3_main_kho_khorne", category = "inf_melee", tier = nil, } },
        { "wh3_main_kho_mon_soul_grinder_0",                        "rare",    2, { culture = "wh3_main_kho_khorne", category = "inf_ranged", tier = nil, } },
        { "wh3_main_kho_mon_spawn_of_khorne_0",                     "rare",    1, { culture = "wh3_main_kho_khorne", category = "inf_melee", tier = nil, } },
        { "wh3_main_kho_veh_blood_shrine_0",                        "rare",    1, { culture = "wh3_main_kho_khorne", category = "war_beast", tier = nil, } },
        { "wh3_main_kho_veh_skullcannon_0",                         "rare",    2, { culture = "wh3_main_kho_khorne", category = "war_beast", tier = nil, } },
        { "wh3_main_ksl_cav_winged_lancers_0",                      "core",    3, { culture = "wh3_main_ksl_kislev", category = "war_beast", tier = nil, } },
        { "wh3_main_ksl_inf_armoured_kossars_0",                    "core",    2, { culture = "wh3_main_ksl_kislev", category = "inf_ranged", tier = nil, } },
        { "wh3_main_ksl_inf_armoured_kossars_1",                    "core",    2, { culture = "wh3_main_ksl_kislev", category = "inf_ranged", tier = nil, } },
        { "wh3_main_ksl_cav_horse_archers_0",                       "core",    3, { culture = "wh3_main_ksl_kislev", category = "war_beast", tier = nil, } },
        { "wh3_main_ksl_cav_horse_raiders_0",                       "core",    3, { culture = "wh3_main_ksl_kislev", category = "war_beast", tier = nil, } },
        { "wh3_main_ksl_inf_kossars_0",                             "core",    1, { culture = "wh3_main_ksl_kislev", category = "inf_ranged", tier = nil, } },
        { "wh3_main_ksl_inf_kossars_1",                             "core",    1, { culture = "wh3_main_ksl_kislev", category = "inf_ranged", tier = nil, } },
        { "wh3_main_ksl_inf_streltsi_0",                            "core",    3, { culture = "wh3_main_ksl_kislev", category = "inf_ranged", tier = nil, } },
        { "wh3_main_ksl_cav_war_bear_riders_1",                     "special", 3, { culture = "wh3_main_ksl_kislev", category = "war_beast", tier = nil, } },
        { "wh3_main_ksl_cav_gryphon_legion_0",                      "special", 2, { culture = "wh3_main_ksl_kislev", category = "war_beast", tier = nil, } },
        { "wh3_main_ksl_inf_tzar_guard_0",                          "special", 2, { culture = "wh3_main_ksl_kislev", category = "inf_melee", tier = nil, } },
        { "wh3_main_ksl_inf_tzar_guard_1",                          "special", 2, { culture = "wh3_main_ksl_kislev", category = "inf_melee", tier = nil, } },
        { "wh3_main_ksl_veh_heavy_war_sled_0",                      "special", 3, { culture = "wh3_main_ksl_kislev", category = "war_machine", tier = nil, } },
        { "wh3_main_ksl_veh_light_war_sled_0",                      "special", 2, { culture = "wh3_main_ksl_kislev", category = "war_machine", tier = nil, } },
        { "wh3_main_ksl_mon_elemental_bear_0",                      "rare",    3, { culture = "wh3_main_ksl_kislev", category = "inf_melee", tier = nil, } },
        { "wh3_main_ksl_mon_snow_leopard_0",                        "rare",    1, { culture = "wh3_main_ksl_kislev", category = "inf_melee", tier = nil, } },
        { "wh3_main_ksl_veh_little_grom_0",                         "rare",    2, { culture = "wh3_main_ksl_kislev", category = "war_machine", tier = nil, } },
        { "wh3_main_ksl_inf_ice_guard_0",                           "rare",    1, { culture = "wh3_main_ksl_kislev", category = "inf_ranged", tier = nil, } },
        { "wh3_main_ksl_inf_ice_guard_1",                           "rare",    1, { culture = "wh3_main_ksl_kislev", category = "inf_ranged", tier = nil, } },
        { "wh3_main_nur_inf_forsaken_0",                            "core",    3, { culture = "wh3_main_nur_nurgle", category = "inf_melee", tier = nil, } },
        { "wh3_main_nur_inf_nurglings_0",                           "core",    1, { culture = "wh3_main_nur_nurgle", category = "inf_melee", tier = nil, } },
        { "wh3_main_nur_inf_plaguebearers_0",                       "core",    2, { culture = "wh3_main_nur_nurgle", category = "inf_melee", tier = nil, } },
        { "wh3_main_nur_mon_plague_toads_0",                        "core",    3, { culture = "wh3_main_nur_nurgle", category = "inf_melee", tier = nil, } },
        { "wh3_main_nur_cav_pox_riders_of_nurgle_0",                "special", 2, { culture = "wh3_main_nur_nurgle", category = "cavalry", tier = nil, } },
        { "wh3_main_nur_inf_chaos_furies_0",                        "special", 1, { culture = "wh3_main_nur_nurgle", category = "inf_melee", tier = nil, } },
        { "wh3_main_nur_mon_beast_of_nurgle_0",                     "special", 1, { culture = "wh3_main_nur_nurgle", category = "inf_melee", tier = nil, } },
        { "wh3_main_nur_inf_plaguebearers_1",                       "special", 2, { culture = "wh3_main_nur_nurgle", category = "inf_melee", tier = nil, } },
        { "wh3_main_nur_mon_rot_flies_0",                           "special", 1, { culture = "wh3_main_nur_nurgle", category = "inf_melee", tier = nil, } },
        { "wh3_main_nur_cav_plague_drones_0",                       "rare",    1, { culture = "wh3_main_nur_nurgle", category = "cavalry", tier = nil, } },
        { "wh3_main_nur_cav_plague_drones_1",                       "rare",    1, { culture = "wh3_main_nur_nurgle", category = "cavalry", tier = nil, } },
        { "wh3_main_nur_mon_great_unclean_one_0",                   "rare",    3, { culture = "wh3_main_nur_nurgle", category = "inf_melee", tier = nil, } },
        { "wh3_main_nur_mon_soul_grinder_0",                        "rare",    2, { culture = "wh3_main_nur_nurgle", category = "inf_ranged", tier = nil, } },
        { "wh3_main_nur_mon_spawn_of_nurgle_0",                     "rare",    1, { culture = "wh3_main_nur_nurgle", category = "inf_melee", tier = nil, } },
        { "wh3_main_ogr_inf_gnoblars_0",                            "core",    1, { culture = "wh3_main_ogr_ogre_kingdoms", category = "inf_melee", tier = nil, } },
        { "wh3_main_ogr_inf_gnoblars_1",                            "core",    1, { culture = "wh3_main_ogr_ogre_kingdoms", category = "inf_melee", tier = nil, } },
        { "wh3_main_ogr_inf_ogres_0",                               "core",    2, { culture = "wh3_main_ogr_ogre_kingdoms", category = "inf_melee", tier = nil, } },
        { "wh3_main_ogr_inf_ogres_1",                               "core",    2, { culture = "wh3_main_ogr_ogre_kingdoms", category = "inf_melee", tier = nil, } },
        { "wh3_main_ogr_inf_ogres_2",                               "core",    2, { culture = "wh3_main_ogr_ogre_kingdoms", category = "inf_melee", tier = nil, } },
        { "wh3_main_ogr_cav_mournfang_cavalry_0",                   "special", 2, { culture = "wh3_main_ogr_ogre_kingdoms", category = "cavalry", tier = nil, } },
        { "wh3_main_ogr_cav_mournfang_cavalry_1",                   "special", 2, { culture = "wh3_main_ogr_ogre_kingdoms", category = "cavalry", tier = nil, } },
        { "wh3_main_ogr_cav_mournfang_cavalry_2",                   "special", 2, { culture = "wh3_main_ogr_ogre_kingdoms", category = "cavalry", tier = nil, } },
        { "wh3_main_ogr_inf_ironguts_0",                            "special", 1, { culture = "wh3_main_ogr_ogre_kingdoms", category = "inf_melee", tier = nil, } },
        { "wh3_main_ogr_inf_leadbelchers_0",                        "special", 2, { culture = "wh3_main_ogr_ogre_kingdoms", category = "inf_ranged", tier = nil, } },
        { "wh3_main_ogr_inf_maneaters_0",                           "special", 2, { culture = "wh3_main_ogr_ogre_kingdoms", category = "inf_melee", tier = nil, } },
        { "wh3_main_ogr_inf_maneaters_1",                           "special", 2, { culture = "wh3_main_ogr_ogre_kingdoms", category = "inf_melee", tier = nil, } },
        { "wh3_main_ogr_inf_maneaters_2",                           "special", 2, { culture = "wh3_main_ogr_ogre_kingdoms", category = "inf_melee", tier = nil, } },
        { "wh3_main_ogr_inf_maneaters_3",                           "special", 2, { culture = "wh3_main_ogr_ogre_kingdoms", category = "inf_ranged", tier = nil, } },
        { "wh3_main_ogr_mon_gorgers_0",                             "special", 2, { culture = "wh3_main_ogr_ogre_kingdoms", category = "inf_melee", tier = nil, } },
        { "wh3_main_ogr_mon_sabretusk_pack_0",                      "special", 1, { culture = "wh3_main_ogr_ogre_kingdoms", category = "inf_melee", tier = nil, } },
        { "wh3_main_ogr_mon_giant_0",                               "rare",    2, { culture = "wh3_main_ogr_ogre_kingdoms", category = "inf_melee", tier = nil, } },
        { "wh3_main_ogr_mon_stonehorn_0",                           "rare",    2, { culture = "wh3_main_ogr_ogre_kingdoms", category = "cavalry", tier = nil, } },
        { "wh3_main_ogr_mon_stonehorn_1",                           "rare",    3, { culture = "wh3_main_ogr_ogre_kingdoms", category = "cavalry", tier = nil, } },
        { "wh3_main_ogr_veh_gnoblar_scraplauncher_0",               "rare",    1, { culture = "wh3_main_ogr_ogre_kingdoms", category = "war_machine", tier = nil, } },
        { "wh3_main_ogr_veh_ironblaster_0",                         "rare",    2, { culture = "wh3_main_ogr_ogre_kingdoms", category = "war_machine", tier = nil, } },
        { "wh3_main_ogr_cav_crushers_0",                            "rare",    2, { culture = "wh3_main_ogr_ogre_kingdoms", category = "cavalry", tier = nil, } },
        { "wh3_main_ogr_cav_crushers_1",                            "rare",    2, { culture = "wh3_main_ogr_ogre_kingdoms", category = "cavalry", tier = nil, } },
        { "wh3_main_sla_inf_marauders_0",                           "core",    1, { culture = "wh3_main_sla_slaanesh", category = "inf_melee", tier = nil, } },
        { "wh3_main_sla_inf_marauders_1",                           "core",    1, { culture = "wh3_main_sla_slaanesh", category = "inf_melee", tier = nil, } },
        { "wh3_main_sla_inf_marauders_2",                           "core",    1, { culture = "wh3_main_sla_slaanesh", category = "inf_melee", tier = nil, } },
        { "wh3_main_sla_inf_daemonette_0",                          "core",    3, { culture = "wh3_main_sla_slaanesh", category = "inf_melee", tier = nil, } },
        { "wh3_main_sla_cav_hellstriders_0",                        "core",    1, { culture = "wh3_main_sla_slaanesh", category = "war_beast", tier = nil, } },
        { "wh3_main_sla_cav_hellstriders_1",                        "core",    1, { culture = "wh3_main_sla_slaanesh", category = "war_beast", tier = nil, } },
        { "wh3_main_sla_cav_seekers_of_slaanesh_0",                 "special", 2, { culture = "wh3_main_sla_slaanesh", category = "war_beast", tier = nil, } },
        { "wh3_main_sla_inf_chaos_furies_0",                        "special", 1, { culture = "wh3_main_sla_slaanesh", category = "inf_melee", tier = nil, } },
        { "wh3_main_sla_inf_daemonette_1",                          "special", 2, { culture = "wh3_main_sla_slaanesh", category = "inf_melee", tier = nil, } },
        { "wh3_main_sla_mon_fiends_of_slaanesh_0",                  "special", 2, { culture = "wh3_main_sla_slaanesh", category = "inf_melee", tier = nil, } },
        { "wh3_main_sla_veh_seeker_chariot_0",                      "special", 1, { culture = "wh3_main_sla_slaanesh", category = "war_machine", tier = nil, } },
        { "wh3_main_sla_mon_keeper_of_secrets_0",                   "rare",    3, { culture = "wh3_main_sla_slaanesh", category = "inf_melee", tier = nil, } },
        { "wh3_main_sla_cav_heartseekers_of_slaanesh_0",            "rare",    2, { culture = "wh3_main_sla_slaanesh", category = "war_beast", tier = nil, } },
        { "wh3_main_sla_mon_soul_grinder_0",                        "rare",    2, { culture = "wh3_main_sla_slaanesh", category = "inf_melee", tier = nil, } },
        { "wh3_main_sla_mon_spawn_of_slaanesh_0",                   "rare",    1, { culture = "wh3_main_sla_slaanesh", category = "inf_melee", tier = nil, } },
        { "wh3_main_sla_veh_exalted_seeker_chariot_0",              "rare",    2, { culture = "wh3_main_sla_slaanesh", category = "war_machine", tier = nil, } },
        { "wh3_main_sla_veh_hellflayer_0",                          "rare",    2, { culture = "wh3_main_sla_slaanesh", category = "war_machine", tier = nil, } },
        { "wh3_main_tze_inf_forsaken_0",                            "core",    3, { culture = "wh3_main_tze_tzeentch", category = "inf_melee", tier = nil, } },
        { "wh3_main_tze_inf_pink_horrors_0",                        "core",    2, { culture = "wh3_main_tze_tzeentch", category = "inf_ranged", tier = nil, } },
        { "wh3_main_tze_inf_blue_horrors_0",                        "core",    1, { culture = "wh3_main_tze_tzeentch", category = "inf_ranged", tier = nil, } },
        { "wh3_main_tze_inf_pink_horrors_1",                        "special", 2, { culture = "wh3_main_tze_tzeentch", category = "inf_ranged", tier = nil, } },
        { "wh3_main_tze_cav_chaos_knights_0",                       "special", 2, { culture = "wh3_main_tze_tzeentch", category = "war_beast", tier = nil, } },
        { "wh3_main_tze_mon_screamers_0",                           "special", 1, { culture = "wh3_main_tze_tzeentch", category = "inf_melee", tier = nil, } },
        { "wh3_main_tze_mon_flamers_0",                             "special", 2, { culture = "wh3_main_tze_tzeentch", category = "inf_ranged", tier = nil, } },
        { "wh3_main_tze_inf_chaos_furies_0",                        "special", 1, { culture = "wh3_main_tze_tzeentch", category = "inf_melee", tier = nil, } },
        { "wh3_main_tze_cav_doom_knights_0",                        "rare",    2, { culture = "wh3_main_tze_tzeentch", category = "inf_melee", tier = nil, } },
        { "wh3_main_tze_mon_exalted_flamers_0",                     "rare",    2, { culture = "wh3_main_tze_tzeentch", category = "inf_ranged", tier = nil, } },
        { "wh3_main_tze_mon_lord_of_change_0",                      "rare",    3, { culture = "wh3_main_tze_tzeentch", category = "inf_melee", tier = nil, } },
        { "wh3_main_tze_mon_soul_grinder_0",                        "rare",    2, { culture = "wh3_main_tze_tzeentch", category = "inf_ranged", tier = nil, } },
        { "wh3_main_tze_mon_spawn_of_tzeentch_0",                   "rare",    1, { culture = "wh3_main_tze_tzeentch", category = "inf_melee", tier = nil, } },
        { "wh3_main_tze_veh_burning_chariot_0",                     "rare",    2, { culture = "wh3_main_tze_tzeentch", category = "war_beast", tier = nil, } },
        { "wh3_main_dae_inf_chaos_furies_0",                        "special", 1, { culture = "wh3_main_dae_daemons", category = "inf_melee", tier = nil, } },
        { "wh3_dlc20_chs_cav_chaos_chariot_mkho",                   "core",    1, { culture = "wh_main_chs_chaos", category = "war_machine", tier = nil, } },
        { "wh3_dlc20_chs_cav_chaos_chariot_mnur",                   "core",    1, { culture = "wh_main_chs_chaos", category = "war_machine", tier = nil, } },
        { "wh3_dlc20_chs_cav_chaos_chariot_msla",                   "core",    1, { culture = "wh_main_chs_chaos", category = "war_machine", tier = nil, } },
        { "wh3_dlc20_chs_cav_chaos_chariot_mtze",                   "core",    1, { culture = "wh_main_chs_chaos", category = "war_machine", tier = nil, } },
        { "wh3_dlc20_chs_inf_chaos_marauders_mkho",                 "core",    1, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh3_dlc20_chs_inf_chaos_marauders_mkho_dualweapons",     "core",    1, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh3_dlc20_chs_inf_chaos_marauders_mnur",                 "core",    1, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh3_dlc20_chs_inf_chaos_marauders_mnur_greatweapons",    "core",    1, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh3_dlc20_chs_inf_chaos_marauders_msla",                 "core",    1, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh3_dlc20_chs_inf_chaos_marauders_msla_hellscourges",    "core",    1, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh3_dlc20_chs_inf_chaos_marauders_mtze",                 "core",    1, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh3_dlc20_chs_inf_chaos_marauders_mtze_spears",          "core",    1, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh3_dlc20_chs_inf_chaos_warriors_mnur",                  "core",    2, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh3_dlc20_chs_inf_chaos_warriors_mnur_greatweapons",     "core",    3, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh3_dlc20_chs_inf_chaos_warriors_msla",                  "core",    2, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh3_dlc20_chs_inf_chaos_warriors_msla_hellscourges",     "core",    3, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh3_dlc20_chs_inf_chaos_warriors_mtze",                  "core",    2, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh3_dlc20_chs_inf_chaos_warriors_mtze_halberds",         "core",    3, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh3_dlc20_chs_cav_marauder_horsemen_mkho_throwing_axes", "core",    1, { culture = "wh_main_chs_chaos", category = "war_beast", tier = nil, } },
        { "wh3_dlc20_chs_cav_marauder_horsemen_mnur_throwing_axes", "core",    1, { culture = "wh_main_chs_chaos", category = "war_beast", tier = nil, } },
        { "wh3_dlc20_chs_cav_marauder_horsemen_msla_javelins",      "core",    1, { culture = "wh_main_chs_chaos", category = "war_beast", tier = nil, } },
        { "wh3_dlc20_chs_cav_marauder_horsemen_mtze_javelins",      "core",    1, { culture = "wh_main_chs_chaos", category = "war_beast", tier = nil, } },
        { "wh3_dlc20_chs_inf_forsaken_mkho",                        "core",    3, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh3_dlc20_chs_inf_forsaken_msla",                        "core",    3, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh3_dlc20_chs_cav_chaos_knights_mkho",                   "special", 2, { culture = "wh_main_chs_chaos", category = "war_beast", tier = nil, } },
        { "wh3_dlc20_chs_cav_chaos_knights_mkho_lances",            "special", 2, { culture = "wh_main_chs_chaos", category = "war_beast", tier = nil, } },
        { "wh3_dlc20_chs_cav_chaos_knights_mnur",                   "special", 2, { culture = "wh_main_chs_chaos", category = "war_beast", tier = nil, } },
        { "wh3_dlc20_chs_cav_chaos_knights_mnur_lances",            "special", 2, { culture = "wh_main_chs_chaos", category = "war_beast", tier = nil, } },
        { "wh3_dlc20_chs_cav_chaos_knights_msla",                   "special", 2, { culture = "wh_main_chs_chaos", category = "war_beast", tier = nil, } },
        { "wh3_dlc20_chs_cav_chaos_knights_msla_lances",            "special", 2, { culture = "wh_main_chs_chaos", category = "war_beast", tier = nil, } },
        { "wh3_dlc20_chs_cav_chaos_knights_mtze_lances",            "special", 2, { culture = "wh_main_chs_chaos", category = "war_beast", tier = nil, } },
        { "wh3_dlc20_chs_inf_chosen_mkho",                          "special", 2, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh3_dlc20_chs_inf_chosen_mkho_dualweapons",              "special", 2, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh3_dlc20_chs_inf_chosen_mnur",                          "special", 2, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh3_dlc20_chs_inf_chosen_mnur_greatweapons",             "special", 2, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh3_dlc20_chs_inf_chosen_msla",                          "special", 2, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh3_dlc20_chs_inf_chosen_msla_hellscourges",             "special", 2, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh3_dlc20_chs_inf_chosen_mtze",                          "special", 2, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh3_dlc20_chs_inf_chosen_mtze_halberds",                 "special", 2, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh3_dlc20_chs_mon_warshrine",                            "special", 2, { culture = "wh_main_chs_chaos", category = "war_beast", tier = nil, } },
        { "wh3_dlc20_chs_mon_warshrine_mkho",                       "special", 2, { culture = "wh_main_chs_chaos", category = "war_beast", tier = nil, } },
        { "wh3_dlc20_chs_mon_warshrine_mnur",                       "special", 2, { culture = "wh_main_chs_chaos", category = "war_beast", tier = nil, } },
        { "wh3_dlc20_chs_mon_warshrine_msla",                       "special", 2, { culture = "wh_main_chs_chaos", category = "war_beast", tier = nil, } },
        { "wh3_dlc20_chs_mon_warshrine_mtze",                       "special", 2, { culture = "wh_main_chs_chaos", category = "war_beast", tier = nil, } },
        { "wh3_main_nur_mon_spawn_of_nurgle_0_warriors",            "rare",    1, { culture = "wh3_main_nur_nurgle", category = "inf_melee", tier = nil, } },
        { "wh_main_emp_cav_empire_knights",                         "core",    3, { culture = "wh_main_emp_empire", category = "cavalry", tier = nil, } },
        { "wh_main_emp_inf_halberdiers",                            "core",    2, { culture = "wh_main_emp_empire", category = "inf_melee", tier = nil, } },
        { "wh_main_emp_inf_handgunners",                            "core",    3, { culture = "wh_main_emp_empire", category = "inf_ranged", tier = nil, } },
        { "wh_main_emp_inf_spearmen_0",                             "core",    1, { culture = "wh_main_emp_empire", category = "inf_melee", tier = nil, } },
        { "wh_main_emp_inf_spearmen_1",                             "core",    1, { culture = "wh_main_emp_empire", category = "inf_melee", tier = nil, } },
        { "wh_main_emp_inf_swordsmen",                              "core",    1, { culture = "wh_main_emp_empire", category = "inf_melee", tier = nil, } },
        { "wh_main_emp_inf_crossbowmen",                            "core",    1, { culture = "wh_main_emp_empire", category = "inf_ranged", tier = nil, } },
        { "wh_dlc04_emp_inf_free_company_militia_0",                "core",    2, { culture = "wh_main_emp_empire", category = "inf_ranged", tier = nil, } },
        { "wh2_dlc13_emp_inf_archers_0",                            "core",    1, { culture = "wh_main_emp_empire", category = "inf_ranged", tier = nil, } },
        { "wh_main_emp_cav_demigryph_knights_0",                    "special", 3, { culture = "wh_main_emp_empire", category = "cavalry", tier = nil, } },
        { "wh_main_emp_cav_demigryph_knights_1",                    "special", 3, { culture = "wh_main_emp_empire", category = "cavalry", tier = nil, } },
        { "wh_main_emp_cav_outriders_0",                            "special", 1, { culture = "wh_main_emp_empire", category = "cavalry", tier = nil, } },
        { "wh_main_emp_cav_outriders_1",                            "special", 2, { culture = "wh_main_emp_empire", category = "cavalry", tier = nil, } },
        { "wh_main_emp_cav_pistoliers_1",                           "special", 1, { culture = "wh_main_emp_empire", category = "cavalry", tier = nil, } },
        { "wh_main_emp_cav_reiksguard",                             "special", 2, { culture = "wh_main_emp_empire", category = "cavalry", tier = nil, } },
        { "wh_main_emp_art_great_cannon",                           "special", 2, { culture = "wh_main_emp_empire", category = "artillery", tier = nil, } },
        { "wh_main_emp_art_mortar",                                 "special", 2, { culture = "wh_main_emp_empire", category = "artillery", tier = nil, } },
        { "wh_main_emp_inf_greatswords",                            "special", 1, { culture = "wh_main_emp_empire", category = "inf_melee", tier = nil, } },
        { "wh_dlc04_emp_cav_knights_blazing_sun_0",                 "special", 2, { culture = "wh_main_emp_empire", category = "cavalry", tier = nil, } },
        { "wh_dlc04_emp_inf_flagellants_0",                         "special", 1, { culture = "wh_main_emp_empire", category = "inf_melee", tier = nil, } },
        { "wh2_dlc13_emp_inf_huntsmen_0",                           "special", 1, { culture = "wh_main_emp_empire", category = "inf_ranged", tier = nil, } },
        { "wh_main_emp_art_helblaster_volley_gun",                  "rare",    2, { culture = "wh_main_emp_empire", category = "artillery", tier = nil, } },
        { "wh_main_emp_art_helstorm_rocket_battery",                "rare",    2, { culture = "wh_main_emp_empire", category = "artillery", tier = nil, } },
        { "wh_main_emp_veh_luminark_of_hysh_0",                     "rare",    3, { culture = "wh_main_emp_empire", category = "war_machine", tier = nil, } },
        { "wh_main_emp_veh_steam_tank",                             "rare",    3, { culture = "wh_main_emp_empire", category = "war_machine", tier = nil, } },
        { "wh2_dlc13_emp_veh_war_wagon_0",                          "rare",    1, { culture = "wh_main_emp_empire", category = "war_machine", tier = nil, } },
        { "wh2_dlc13_emp_veh_war_wagon_1",                          "rare",    2, { culture = "wh_main_emp_empire", category = "war_machine", tier = nil, } },
        { "wh_main_dwf_inf_dwarf_warrior_0",                        "core",    1, { culture = "wh_main_dwf_dwarfs", category = "inf_melee", tier = nil, } },
        { "wh_main_dwf_inf_dwarf_warrior_1",                        "core",    2, { culture = "wh_main_dwf_dwarfs", category = "inf_melee", tier = nil, } },
        { "wh_main_dwf_inf_longbeards",                             "core",    3, { culture = "wh_main_dwf_dwarfs", category = "inf_melee", tier = nil, } },
        { "wh_main_dwf_inf_longbeards_1",                           "core",    3, { culture = "wh_main_dwf_dwarfs", category = "inf_melee", tier = nil, } },
        { "wh_main_dwf_inf_miners_0",                               "core",    1, { culture = "wh_main_dwf_dwarfs", category = "inf_melee", tier = nil, } },
        { "wh_main_dwf_inf_miners_1",                               "core",    1, { culture = "wh_main_dwf_dwarfs", category = "inf_melee", tier = nil, } },
        { "wh_main_dwf_inf_quarrellers_0",                          "core",    1, { culture = "wh_main_dwf_dwarfs", category = "inf_ranged", tier = nil, } },
        { "wh_main_dwf_inf_quarrellers_1",                          "core",    2, { culture = "wh_main_dwf_dwarfs", category = "inf_ranged", tier = nil, } },
        { "wh_main_dwf_inf_thunderers_0",                           "core",    2, { culture = "wh_main_dwf_dwarfs", category = "inf_ranged", tier = nil, } },
        { "wh_main_dwf_art_cannon",                                 "special", 2, { culture = "wh_main_dwf_dwarfs", category = "artillery", tier = nil, } },
        { "wh_main_dwf_art_grudge_thrower",                         "special", 1, { culture = "wh_main_dwf_dwarfs", category = "artillery", tier = nil, } },
        { "wh_main_dwf_inf_hammerers",                              "special", 2, { culture = "wh_main_dwf_dwarfs", category = "inf_melee", tier = nil, } },
        { "wh_main_dwf_inf_ironbreakers",                           "special", 2, { culture = "wh_main_dwf_dwarfs", category = "inf_melee", tier = nil, } },
        { "wh_main_dwf_veh_gyrobomber",                             "special", 2, { culture = "wh_main_dwf_dwarfs", category = "inf_ranged", tier = nil, } },
        { "wh_main_dwf_veh_gyrocopter_0",                           "special", 2, { culture = "wh_main_dwf_dwarfs", category = "inf_ranged", tier = nil, } },
        { "wh_main_dwf_veh_gyrocopter_1",                           "special", 2, { culture = "wh_main_dwf_dwarfs", category = "inf_ranged", tier = nil, } },
        { "wh_main_dwf_inf_slayers",                                "special", 1, { culture = "wh_main_dwf_dwarfs", category = "inf_melee", tier = nil, } },
        { "wh_dlc06_dwf_art_bolt_thrower_0",                        "special", 1, { culture = "wh_main_dwf_dwarfs", category = "artillery", tier = nil, } },
        { "wh_dlc06_dwf_inf_bugmans_rangers_0",                     "special", 2, { culture = "wh_main_dwf_dwarfs", category = "inf_ranged", tier = nil, } },
        { "wh_dlc06_dwf_inf_rangers_0",                             "special", 1, { culture = "wh_main_dwf_dwarfs", category = "inf_ranged", tier = nil, } },
        { "wh_dlc06_dwf_inf_rangers_1",                             "special", 1, { culture = "wh_main_dwf_dwarfs", category = "inf_ranged", tier = nil, } },
        { "wh2_dlc10_dwf_inf_giant_slayers",                        "special", 2, { culture = "wh_main_dwf_dwarfs", category = "inf_melee", tier = nil, } },
        { "wh_main_dwf_art_flame_cannon",                           "rare",    2, { culture = "wh_main_dwf_dwarfs", category = "artillery", tier = nil, } },
        { "wh_main_dwf_art_organ_gun",                              "rare",    2, { culture = "wh_main_dwf_dwarfs", category = "artillery", tier = nil, } },
        { "wh_main_dwf_inf_irondrakes_0",                           "rare",    2, { culture = "wh_main_dwf_dwarfs", category = "inf_ranged", tier = nil, } },
        { "wh_main_dwf_inf_irondrakes_2",                           "rare",    2, { culture = "wh_main_dwf_dwarfs", category = "inf_ranged", tier = nil, } },
        { "wh_main_vmp_inf_crypt_ghouls",                           "core",    2, { culture = "wh_main_vmp_vampire_counts", category = "inf_melee", tier = nil, } },
        { "wh_main_vmp_inf_skeleton_warriors_0",                    "core",    1, { culture = "wh_main_vmp_vampire_counts", category = "inf_melee", tier = nil, } },
        { "wh_main_vmp_inf_skeleton_warriors_1",                    "core",    1, { culture = "wh_main_vmp_vampire_counts", category = "inf_melee", tier = nil, } },
        { "wh_main_vmp_inf_zombie",                                 "core",    1, { culture = "wh_main_vmp_vampire_counts", category = "inf_melee", tier = nil, } },
        { "wh_main_vmp_mon_fell_bats",                              "core",    3, { culture = "wh_main_vmp_vampire_counts", category = "inf_melee", tier = nil, } },
        { "wh_main_vmp_mon_dire_wolves",                            "core",    3, { culture = "wh_main_vmp_vampire_counts", category = "inf_melee", tier = nil, } },
        { "wh_main_vmp_cav_hexwraiths",                             "special", 2, { culture = "wh_main_vmp_vampire_counts", category = "cavalry", tier = nil, } },
        { "wh_main_vmp_inf_grave_guard_0",                          "special", 1, { culture = "wh_main_vmp_vampire_counts", category = "inf_melee", tier = nil, } },
        { "wh_main_vmp_inf_grave_guard_1",                          "special", 1, { culture = "wh_main_vmp_vampire_counts", category = "inf_melee", tier = nil, } },
        { "wh_main_vmp_mon_crypt_horrors",                          "special", 2, { culture = "wh_main_vmp_vampire_counts", category = "inf_melee", tier = nil, } },
        { "wh_main_vmp_cav_black_knights_0",                        "special", 2, { culture = "wh_main_vmp_vampire_counts", category = "cavalry", tier = nil, } },
        { "wh_main_vmp_cav_black_knights_3",                        "special", 2, { culture = "wh_main_vmp_vampire_counts", category = "cavalry", tier = nil, } },
        { "wh_main_vmp_mon_vargheists",                             "special", 2, { culture = "wh_main_vmp_vampire_counts", category = "inf_melee", tier = nil, } },
        { "wh_dlc04_vmp_veh_corpse_cart_0",                         "special", 2, { culture = "wh_main_vmp_vampire_counts", category = "war_machine", tier = nil, } },
        { "wh_dlc04_vmp_veh_corpse_cart_1",                         "special", 3, { culture = "wh_main_vmp_vampire_counts", category = "war_machine", tier = nil, } },
        { "wh_dlc04_vmp_veh_corpse_cart_2",                         "special", 3, { culture = "wh_main_vmp_vampire_counts", category = "war_machine", tier = nil, } },
        { "wh_main_vmp_inf_cairn_wraiths",                          "rare",    1, { culture = "wh_main_vmp_vampire_counts", category = "inf_melee", tier = nil, } },
        { "wh_main_vmp_mon_terrorgheist",                           "rare",    3, { culture = "wh_main_vmp_vampire_counts", category = "inf_melee", tier = nil, } },
        { "wh_main_vmp_mon_varghulf",                               "rare",    2, { culture = "wh_main_vmp_vampire_counts", category = "inf_melee", tier = nil, } },
        { "wh_main_vmp_veh_black_coach",                            "rare",    2, { culture = "wh_main_vmp_vampire_counts", category = "war_machine", tier = nil, } },
        { "wh_dlc02_vmp_cav_blood_knights_0",                       "rare",    2, { culture = "wh_main_vmp_vampire_counts", category = "cavalry", tier = nil, } },
        { "wh_dlc04_vmp_veh_mortis_engine_0",                       "rare",    3, { culture = "wh_main_vmp_vampire_counts", category = "war_machine", tier = nil, } },
        { "wh2_dlc11_vmp_inf_crossbowmen",                          "special", 1, { culture = "wh_main_vmp_vampire_counts", category = "inf_ranged", tier = nil, } },
        { "wh2_dlc11_vmp_inf_handgunners",                          "rare",    1, { culture = "wh_main_vmp_vampire_counts", category = "inf_ranged", tier = nil, } },
        { "wh_main_brt_cav_knights_of_the_realm",                   "core",    2, { culture = "wh_main_brt_bretonnia", category = "cavalry", tier = nil, } },
        { "wh_main_brt_cav_mounted_yeomen_0",                       "core",    1, { culture = "wh_main_brt_bretonnia", category = "cavalry", tier = nil, } },
        { "wh_main_brt_cav_mounted_yeomen_1",                       "core",    1, { culture = "wh_main_brt_bretonnia", category = "cavalry", tier = nil, } },
        { "wh_main_brt_inf_men_at_arms",                            "core",    3, { culture = "wh_main_brt_bretonnia", category = "inf_melee", tier = nil, } },
        { "wh_main_brt_inf_peasant_bowmen",                         "core",    1, { culture = "wh_main_brt_bretonnia", category = "inf_ranged", tier = nil, } },
        { "wh_main_brt_inf_spearmen_at_arms",                       "core",    3, { culture = "wh_main_brt_bretonnia", category = "inf_melee", tier = nil, } },
        { "wh_dlc07_brt_cav_knights_errant_0",                      "core",    3, { culture = "wh_main_brt_bretonnia", category = "cavalry", tier = nil, } },
        { "wh_dlc07_brt_inf_men_at_arms_1",                         "core",    3, { culture = "wh_main_brt_bretonnia", category = "inf_melee", tier = nil, } },
        { "wh_dlc07_brt_inf_men_at_arms_2",                         "core",    3, { culture = "wh_main_brt_bretonnia", category = "inf_melee", tier = nil, } },
        { "wh_dlc07_brt_inf_peasant_bowmen_1",                      "core",    2, { culture = "wh_main_brt_bretonnia", category = "inf_ranged", tier = nil, } },
        { "wh_dlc07_brt_inf_peasant_bowmen_2",                      "core",    2, { culture = "wh_main_brt_bretonnia", category = "inf_ranged", tier = nil, } },
        { "wh_dlc07_brt_inf_spearmen_at_arms_1",                    "core",    3, { culture = "wh_main_brt_bretonnia", category = "inf_melee", tier = nil, } },
        { "wh_dlc07_brt_peasant_mob_0",                             "core",    1, { culture = "wh_main_brt_bretonnia", category = "inf_melee", tier = nil, } },
        { "wh_main_brt_cav_pegasus_knights",                        "special", 2, { culture = "wh_main_brt_bretonnia", category = "cavalry", tier = nil, } },
        { "wh_dlc07_brt_cav_questing_knights_0",                    "special", 2, { culture = "wh_main_brt_bretonnia", category = "cavalry", tier = nil, } },
        { "wh_dlc07_brt_inf_battle_pilgrims_0",                     "special", 1, { culture = "wh_main_brt_bretonnia", category = "inf_melee", tier = nil, } },
        { "wh_dlc07_brt_inf_foot_squires_0",                        "special", 1, { culture = "wh_main_brt_bretonnia", category = "inf_melee", tier = nil, } },
        { "wh_dlc07_brt_inf_grail_reliquae_0",                      "special", 2, { culture = "wh_main_brt_bretonnia", category = "inf_melee", tier = nil, } },
        { "wh_main_brt_art_field_trebuchet",                        "rare",    1, { culture = "wh_main_brt_bretonnia", category = "artillery", tier = nil, } },
        { "wh_main_brt_cav_grail_knights",                          "rare",    2, { culture = "wh_main_brt_bretonnia", category = "cavalry", tier = nil, } },
        { "wh_dlc07_brt_cav_grail_guardians_0",                     "rare",    2, { culture = "wh_main_brt_bretonnia", category = "cavalry", tier = nil, } },
        { "wh_dlc07_brt_cav_royal_hippogryph_knights_0",            "rare",    2, { culture = "wh_main_brt_bretonnia", category = "war_beast", tier = nil, } },
        { "wh_dlc07_brt_cav_royal_pegasus_knights_0",               "rare",    2, { culture = "wh_main_brt_bretonnia", category = "cavalry", tier = nil, } },
        { "wh_main_grn_cav_forest_goblin_spider_riders_0",          "core",    2, { culture = "wh_main_grn_greenskins", category = "cavalry", tier = nil, } },
        { "wh_main_grn_cav_forest_goblin_spider_riders_1",          "core",    2, { culture = "wh_main_grn_greenskins", category = "cavalry", tier = nil, } },
        { "wh_main_grn_cav_goblin_wolf_riders_0",                   "core",    1, { culture = "wh_main_grn_greenskins", category = "cavalry", tier = nil, } },
        { "wh_main_grn_cav_goblin_wolf_riders_1",                   "core",    1, { culture = "wh_main_grn_greenskins", category = "cavalry", tier = nil, } },
        { "wh_main_grn_inf_goblin_archers",                         "core",    1, { culture = "wh_main_grn_greenskins", category = "inf_ranged", tier = nil, } },
        { "wh_main_grn_inf_goblin_spearmen",                        "core",    1, { culture = "wh_main_grn_greenskins", category = "inf_melee", tier = nil, } },
        { "wh_main_grn_inf_night_goblin_archers",                   "core",    3, { culture = "wh_main_grn_greenskins", category = "inf_ranged", tier = nil, } },
        { "wh_main_grn_inf_night_goblin_fanatics",                  "core",    3, { culture = "wh_main_grn_greenskins", category = "inf_melee", tier = nil, } },
        { "wh_main_grn_inf_night_goblin_fanatics_1",                "core",    3, { culture = "wh_main_grn_greenskins", category = "inf_ranged", tier = nil, } },
        { "wh_main_grn_inf_night_goblins",                          "core",    3, { culture = "wh_main_grn_greenskins", category = "inf_melee", tier = nil, } },
        { "wh_main_grn_inf_orc_arrer_boyz",                         "core",    2, { culture = "wh_main_grn_greenskins", category = "inf_ranged", tier = nil, } },
        { "wh_main_grn_inf_orc_big_uns",                            "core",    2, { culture = "wh_main_grn_greenskins", category = "inf_melee", tier = nil, } },
        { "wh_main_grn_inf_orc_boyz",                               "core",    1, { culture = "wh_main_grn_greenskins", category = "inf_melee", tier = nil, } },
        { "wh_main_grn_inf_savage_orc_arrer_boyz",                  "core",    3, { culture = "wh_main_grn_greenskins", category = "inf_ranged", tier = nil, } },
        { "wh_main_grn_inf_savage_orc_big_uns",                     "core",    3, { culture = "wh_main_grn_greenskins", category = "inf_melee", tier = nil, } },
        { "wh_main_grn_inf_savage_orcs",                            "core",    3, { culture = "wh_main_grn_greenskins", category = "inf_melee", tier = nil, } },
        { "wh_dlc06_grn_inf_nasty_skulkers_0",                      "core",    2, { culture = "wh_main_grn_greenskins", category = "inf_melee", tier = nil, } },
        { "wh_main_grn_cav_goblin_wolf_chariot",                    "special", 1, { culture = "wh_main_grn_greenskins", category = "war_machine", tier = nil, } },
        { "wh_main_grn_cav_orc_boar_boy_big_uns",                   "special", 2, { culture = "wh_main_grn_greenskins", category = "cavalry", tier = nil, } },
        { "wh_main_grn_cav_orc_boar_boyz",                          "special", 1, { culture = "wh_main_grn_greenskins", category = "cavalry", tier = nil, } },
        { "wh_main_grn_cav_orc_boar_chariot",                       "special", 2, { culture = "wh_main_grn_greenskins", category = "war_machine", tier = nil, } },
        { "wh_main_grn_cav_savage_orc_boar_boy_big_uns",            "special", 2, { culture = "wh_main_grn_greenskins", category = "cavalry", tier = nil, } },
        { "wh_main_grn_cav_savage_orc_boar_boyz",                   "special", 1, { culture = "wh_main_grn_greenskins", category = "cavalry", tier = nil, } },
        { "wh_main_grn_inf_black_orcs",                             "special", 2, { culture = "wh_main_grn_greenskins", category = "inf_melee", tier = nil, } },
        { "wh_main_grn_mon_trolls",                                 "special", 1, { culture = "wh_main_grn_greenskins", category = "inf_melee", tier = nil, } },
        { "wh_dlc06_grn_cav_squig_hoppers_0",                       "special", 2, { culture = "wh_main_grn_greenskins", category = "cavalry", tier = nil, } },
        { "wh_dlc06_grn_inf_squig_herd_0",                          "special", 1, { culture = "wh_main_grn_greenskins", category = "inf_melee", tier = nil, } },
        { "wh2_dlc15_grn_mon_river_trolls_0",                       "special", 2, { culture = "wh_main_grn_greenskins", category = "inf_melee", tier = nil, } },
        { "wh2_dlc15_grn_mon_stone_trolls_0",                       "special", 2, { culture = "wh_main_grn_greenskins", category = "inf_melee", tier = nil, } },
        { "wh_main_grn_art_doom_diver_catapult",                    "rare",    2, { culture = "wh_main_grn_greenskins", category = "artillery", tier = nil, } },
        { "wh_main_grn_art_goblin_rock_lobber",                     "rare",    1, { culture = "wh_main_grn_greenskins", category = "artillery", tier = nil, } },
        { "wh_main_grn_mon_arachnarok_spider_0",                    "rare",    3, { culture = "wh_main_grn_greenskins", category = "war_beast", tier = nil, } },
        { "wh_main_grn_mon_giant",                                  "rare",    2, { culture = "wh_main_grn_greenskins", category = "inf_melee", tier = nil, } },
        { "wh2_dlc15_grn_mon_rogue_idol_0",                         "rare",    3, { culture = "wh_main_grn_greenskins", category = "inf_melee", tier = nil, } },
        { "wh2_dlc15_grn_veh_snotling_pump_wagon_0",                "rare",    1, { culture = "wh_main_grn_greenskins", category = "war_machine", tier = nil, } },
        { "wh2_dlc15_grn_veh_snotling_pump_wagon_flappas_0",        "rare",    1, { culture = "wh_main_grn_greenskins", category = "war_machine", tier = nil, } },
        { "wh2_dlc15_grn_veh_snotling_pump_wagon_roller_0",         "rare",    1, { culture = "wh_main_grn_greenskins", category = "war_machine", tier = nil, } },
        { "wh_dlc06_grn_inf_squig_explosive_0",                     "core",    3, { culture = "wh_main_grn_greenskins", category = "inf_melee", tier = nil, } },
        { "wh_main_chs_mon_chaos_warhounds_0",                      "core",    3, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh_main_chs_mon_chaos_warhounds_1",                      "core",    3, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh_main_chs_cav_marauder_horsemen_0",                    "core",    1, { culture = "wh_main_chs_chaos", category = "war_beast", tier = nil, } },
        { "wh_main_chs_cav_marauder_horsemen_1",                    "core",    1, { culture = "wh_main_chs_chaos", category = "war_beast", tier = nil, } },
        { "wh_main_chs_inf_chaos_marauders_0",                      "core",    1, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh_main_chs_inf_chaos_marauders_1",                      "core",    1, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh_main_chs_inf_chaos_warriors_0",                       "core",    2, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh_main_chs_inf_chaos_warriors_1",                       "core",    2, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh_main_chs_cav_chaos_chariot",                          "core",    1, { culture = "wh_main_chs_chaos", category = "war_machine", tier = nil, } },
        { "wh_dlc01_chs_inf_chaos_warriors_2",                      "core",    3, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh_dlc01_chs_inf_forsaken_0",                            "core",    3, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh_dlc06_chs_cav_marauder_horsemasters_0",               "core",    3, { culture = "wh_main_chs_chaos", category = "war_beast", tier = nil, } },
        { "wh_main_chs_mon_trolls",                                 "special", 1, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh_main_chs_inf_chosen_0",                               "special", 2, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh_main_chs_inf_chosen_1",                               "special", 2, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh_main_chs_cav_chaos_knights_0",                        "special", 2, { culture = "wh_main_chs_chaos", category = "war_beast", tier = nil, } },
        { "wh_main_chs_cav_chaos_knights_1",                        "special", 2, { culture = "wh_main_chs_chaos", category = "war_beast", tier = nil, } },
        { "wh_dlc01_chs_cav_gorebeast_chariot",                     "special", 1, { culture = "wh_main_chs_chaos", category = "war_machine", tier = nil, } },
        { "wh_dlc01_chs_mon_dragon_ogre",                           "special", 2, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh_dlc01_chs_mon_trolls_1",                              "special", 1, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh_dlc01_chs_inf_chosen_2",                              "special", 2, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh_dlc06_chs_feral_manticore",                           "special", 2, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh_dlc06_chs_inf_aspiring_champions_0",                  "special", 1, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh_main_chs_art_hellcannon",                             "rare",    2, { culture = "wh_main_chs_chaos", category = "artillery", tier = nil, } },
        { "wh_main_chs_mon_chaos_spawn",                            "rare",    1, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh_main_chs_mon_giant",                                  "rare",    2, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh_dlc01_chs_mon_dragon_ogre_shaggoth",                  "rare",    3, { culture = "wh_main_chs_chaos", category = "inf_melee", tier = nil, } },
        { "wh_dlc03_bst_inf_chaos_warhounds_0",                     "core",    3, { culture = "wh_dlc03_bst_beastmen", category = "inf_melee", tier = nil, } },
        { "wh_dlc03_bst_inf_chaos_warhounds_1",                     "core",    3, { culture = "wh_dlc03_bst_beastmen", category = "inf_melee", tier = nil, } },
        { "wh_dlc03_bst_inf_ungor_raiders_0",                       "core",    1, { culture = "wh_dlc03_bst_beastmen", category = "inf_ranged", tier = nil, } },
        { "wh_dlc03_bst_inf_gor_herd_0",                            "core",    2, { culture = "wh_dlc03_bst_beastmen", category = "inf_melee", tier = nil, } },
        { "wh_dlc03_bst_inf_gor_herd_1",                            "core",    2, { culture = "wh_dlc03_bst_beastmen", category = "inf_melee", tier = nil, } },
        { "wh_dlc03_bst_inf_ungor_herd_1",                          "core",    1, { culture = "wh_dlc03_bst_beastmen", category = "inf_melee", tier = nil, } },
        { "wh_dlc03_bst_inf_ungor_spearmen_0",                      "core",    1, { culture = "wh_dlc03_bst_beastmen", category = "inf_melee", tier = nil, } },
        { "wh_dlc03_bst_inf_ungor_spearmen_1",                      "core",    1, { culture = "wh_dlc03_bst_beastmen", category = "inf_melee", tier = nil, } },
        { "wh2_dlc17_bst_cav_tuskgor_chariot_0",                    "core",    1, { culture = "wh_dlc03_bst_beastmen", category = "war_machine", tier = nil, } },
        { "wh_dlc03_bst_inf_minotaurs_0",                           "special", 2, { culture = "wh_dlc03_bst_beastmen", category = "inf_melee", tier = nil, } },
        { "wh_dlc03_bst_inf_minotaurs_1",                           "special", 2, { culture = "wh_dlc03_bst_beastmen", category = "inf_melee", tier = nil, } },
        { "wh_dlc03_bst_inf_minotaurs_2",                           "special", 2, { culture = "wh_dlc03_bst_beastmen", category = "inf_melee", tier = nil, } },
        { "wh_dlc05_bst_mon_harpies_0",                             "special", 1, { culture = "wh_dlc03_bst_beastmen", category = "inf_melee", tier = nil, } },
        { "wh_dlc03_bst_inf_razorgor_herd_0",                       "special", 1, { culture = "wh_dlc03_bst_beastmen", category = "inf_melee", tier = nil, } },
        { "wh_dlc03_bst_feral_manticore",                           "special", 2, { culture = "wh_dlc03_bst_beastmen", category = "inf_melee", tier = nil, } },
        { "wh_dlc03_bst_inf_bestigor_herd_0",                       "special", 1, { culture = "wh_dlc03_bst_beastmen", category = "inf_melee", tier = nil, } },
        { "wh_dlc03_bst_inf_centigors_0",                           "special", 1, { culture = "wh_dlc03_bst_beastmen", category = "inf_melee", tier = nil, } },
        { "wh_dlc03_bst_inf_centigors_1",                           "special", 1, { culture = "wh_dlc03_bst_beastmen", category = "inf_ranged", tier = nil, } },
        { "wh_dlc03_bst_inf_centigors_2",                           "special", 1, { culture = "wh_dlc03_bst_beastmen", category = "inf_melee", tier = nil, } },
        { "wh_dlc03_bst_cav_razorgor_chariot_0",                    "special", 2, { culture = "wh_dlc03_bst_beastmen", category = "war_machine", tier = nil, } },
        { "wh_dlc03_bst_mon_chaos_spawn_0",                         "rare",    1, { culture = "wh_dlc03_bst_beastmen", category = "inf_melee", tier = nil, } },
        { "wh_dlc03_bst_mon_giant_0",                               "rare",    2, { culture = "wh_dlc03_bst_beastmen", category = "inf_melee", tier = nil, } },
        { "wh_dlc03_bst_inf_cygor_0",                               "rare",    3, { culture = "wh_dlc03_bst_beastmen", category = "inf_ranged", tier = nil, } },
        { "wh2_dlc17_bst_mon_ghorgon_0",                            "rare",    3, { culture = "wh_dlc03_bst_beastmen", category = "inf_melee", tier = nil, } },
        { "wh2_dlc17_bst_mon_jabberslythe_0",                       "rare",    3, { culture = "wh_dlc03_bst_beastmen", category = "inf_melee", tier = nil, } },
        { "wh_dlc05_wef_inf_glade_guard_0",                         "core",    2, { culture = "wh_dlc05_wef_wood_elves", category = "inf_ranged", tier = nil, } },
        { "wh_dlc05_wef_inf_glade_guard_1",                         "core",    3, { culture = "wh_dlc05_wef_wood_elves", category = "inf_ranged", tier = nil, } },
        { "wh_dlc05_wef_inf_glade_guard_2",                         "core",    3, { culture = "wh_dlc05_wef_wood_elves", category = "inf_ranged", tier = nil, } },
        { "wh_dlc05_wef_cav_glade_riders_0",                        "core",    1, { culture = "wh_dlc05_wef_wood_elves", category = "cavalry", tier = nil, } },
        { "wh_dlc05_wef_cav_glade_riders_1",                        "core",    1, { culture = "wh_dlc05_wef_wood_elves", category = "cavalry", tier = nil, } },
        { "wh_dlc05_wef_inf_dryads_0",                              "core",    1, { culture = "wh_dlc05_wef_wood_elves", category = "inf_melee", tier = nil, } },
        { "wh_dlc05_wef_inf_eternal_guard_0",                       "core",    1, { culture = "wh_dlc05_wef_wood_elves", category = "inf_melee", tier = nil, } },
        { "wh_dlc05_wef_inf_eternal_guard_1",                       "core",    2, { culture = "wh_dlc05_wef_wood_elves", category = "inf_melee", tier = nil, } },
        { "wh2_dlc16_wef_cav_glade_riders_2",                       "core",    2, { culture = "wh_dlc05_wef_wood_elves", category = "cavalry", tier = nil, } },
        { "wh2_dlc16_wef_inf_malicious_dryads_0",                   "core",    3, { culture = "wh_dlc05_wef_wood_elves", category = "inf_melee", tier = nil, } },
        { "wh2_dlc16_wef_mon_cave_bats",                            "core",    3, { culture = "wh_dlc05_wef_wood_elves", category = "inf_melee", tier = nil, } },
        { "wh_dlc05_wef_inf_deepwood_scouts_0",                     "special", 1, { culture = "wh_dlc05_wef_wood_elves", category = "inf_ranged", tier = nil, } },
        { "wh_dlc05_wef_inf_deepwood_scouts_1",                     "special", 1, { culture = "wh_dlc05_wef_wood_elves", category = "inf_ranged", tier = nil, } },
        { "wh_dlc05_wef_mon_treekin_0",                             "special", 2, { culture = "wh_dlc05_wef_wood_elves", category = "inf_melee", tier = nil, } },
        { "wh_dlc05_wef_mon_great_eagle_0",                         "special", 2, { culture = "wh_dlc05_wef_wood_elves", category = "inf_melee", tier = nil, } },
        { "wh_dlc05_wef_cav_hawk_riders_0",                         "special", 2, { culture = "wh_dlc05_wef_wood_elves", category = "cavalry", tier = nil, } },
        { "wh_dlc05_wef_inf_wardancers_0",                          "special", 1, { culture = "wh_dlc05_wef_wood_elves", category = "inf_melee", tier = nil, } },
        { "wh_dlc05_wef_inf_wardancers_1",                          "special", 1, { culture = "wh_dlc05_wef_wood_elves", category = "inf_melee", tier = nil, } },
        { "wh_dlc05_wef_inf_wildwood_rangers_0",                    "special", 2, { culture = "wh_dlc05_wef_wood_elves", category = "inf_melee", tier = nil, } },
        { "wh_dlc05_wef_cav_wild_riders_0",                         "special", 2, { culture = "wh_dlc05_wef_wood_elves", category = "cavalry", tier = nil, } },
        { "wh_dlc05_wef_cav_wild_riders_1",                         "special", 2, { culture = "wh_dlc05_wef_wood_elves", category = "cavalry", tier = nil, } },
        { "wh2_dlc16_wef_inf_bladesingers_0",                       "special", 2, { culture = "wh_dlc05_wef_wood_elves", category = "inf_melee", tier = nil, } },
        { "wh2_dlc16_wef_mon_giant_spiders_0",                      "special", 1, { culture = "wh_dlc05_wef_wood_elves", category = "inf_melee", tier = nil, } },
        { "wh2_dlc16_wef_mon_feral_manticore",                      "special", 2, { culture = "wh_dlc05_wef_wood_elves", category = "inf_melee", tier = nil, } },
        { "wh2_dlc16_wef_mon_harpies_0",                            "special", 1, { culture = "wh_dlc05_wef_wood_elves", category = "inf_melee", tier = nil, } },
        { "wh2_dlc16_wef_mon_hawks_0",                              "special", 1, { culture = "wh_dlc05_wef_wood_elves", category = "inf_melee", tier = nil, } },
        { "wh2_dlc16_wef_mon_malicious_treekin_0",                  "special", 2, { culture = "wh_dlc05_wef_wood_elves", category = "inf_melee", tier = nil, } },
        { "wh2_dlc16_wef_mon_wolves_0",                             "special", 1, { culture = "wh_dlc05_wef_wood_elves", category = "inf_melee", tier = nil, } },
        { "wh_dlc05_wef_forest_dragon_0",                           "rare",    3, { culture = "wh_dlc05_wef_wood_elves", category = "inf_melee", tier = nil, } },
        { "wh_dlc05_wef_mon_treeman_0",                             "rare",    3, { culture = "wh_dlc05_wef_wood_elves", category = "inf_melee", tier = nil, } },
        { "wh_dlc05_wef_inf_waywatchers_0",                         "rare",    1, { culture = "wh_dlc05_wef_wood_elves", category = "inf_ranged", tier = nil, } },
        { "wh_dlc05_wef_cav_sisters_thorn_0",                       "rare",    1, { culture = "wh_dlc05_wef_wood_elves", category = "cavalry", tier = nil, } },
        { "wh2_dlc16_wef_cav_great_stag_knights_0",                 "rare",    1, { culture = "wh_dlc05_wef_wood_elves", category = "cavalry", tier = nil, } },
        { "wh2_dlc16_wef_mon_malicious_treeman_0",                  "rare",    3, { culture = "wh_dlc05_wef_wood_elves", category = "inf_melee", tier = nil, } },
        { "wh2_dlc16_wef_mon_zoats",                                "rare",    1, { culture = "wh_dlc05_wef_wood_elves", category = "inf_melee", tier = nil, } },
        { "wh_main_nor_mon_chaos_warhounds_0",                      "core",    3, { culture = "wh_dlc08_nor_norsca", category = "inf_melee", tier = nil, } },
        { "wh_main_nor_mon_chaos_warhounds_1",                      "core",    3, { culture = "wh_dlc08_nor_norsca", category = "inf_melee", tier = nil, } },
        { "wh_main_nor_cav_marauder_horsemen_1",                    "core",    1, { culture = "wh_dlc08_nor_norsca", category = "war_beast", tier = nil, } },
        { "wh_main_nor_inf_chaos_marauders_0",                      "core",    1, { culture = "wh_dlc08_nor_norsca", category = "inf_melee", tier = nil, } },
        { "wh_main_nor_inf_chaos_marauders_1",                      "core",    1, { culture = "wh_dlc08_nor_norsca", category = "inf_melee", tier = nil, } },
        { "wh_main_nor_cav_marauder_horsemen_0",                    "core",    2, { culture = "wh_dlc08_nor_norsca", category = "war_beast", tier = nil, } },
        { "wh_main_nor_cav_chaos_chariot",                          "core",    2, { culture = "wh_dlc08_nor_norsca", category = "war_machine", tier = nil, } },
        { "wh_dlc08_nor_inf_marauder_spearman_0",                   "core",    1, { culture = "wh_dlc08_nor_norsca", category = "inf_melee", tier = nil, } },
        { "wh_dlc08_nor_inf_marauder_hunters_0",                    "core",    1, { culture = "wh_dlc08_nor_norsca", category = "inf_ranged", tier = nil, } },
        { "wh_dlc08_nor_inf_marauder_hunters_1",                    "core",    1, { culture = "wh_dlc08_nor_norsca", category = "inf_ranged", tier = nil, } },
        { "wh_dlc08_nor_cav_marauder_horsemasters_0",               "core",    3, { culture = "wh_dlc08_nor_norsca", category = "war_beast", tier = nil, } },
        { "wh_main_nor_mon_chaos_trolls",                           "special", 2, { culture = "wh_dlc08_nor_norsca", category = "inf_melee", tier = nil, } },
        { "wh_dlc08_nor_mon_warwolves_0",                           "special", 1, { culture = "wh_dlc08_nor_norsca", category = "inf_melee", tier = nil, } },
        { "wh_dlc08_nor_mon_norscan_ice_trolls_0",                  "special", 2, { culture = "wh_dlc08_nor_norsca", category = "inf_melee", tier = nil, } },
        { "wh_dlc08_nor_feral_manticore",                           "special", 1, { culture = "wh_dlc08_nor_norsca", category = "inf_melee", tier = nil, } },
        { "wh_dlc08_nor_inf_marauder_berserkers_0",                 "special", 1, { culture = "wh_dlc08_nor_norsca", category = "inf_melee", tier = nil, } },
        { "wh_dlc08_nor_inf_marauder_champions_0",                  "special", 2, { culture = "wh_dlc08_nor_norsca", category = "inf_melee", tier = nil, } },
        { "wh_dlc08_nor_inf_marauder_champions_1",                  "special", 2, { culture = "wh_dlc08_nor_norsca", category = "inf_melee", tier = nil, } },
        { "wh_dlc08_nor_mon_skinwolves_0",                          "special", 2, { culture = "wh_dlc08_nor_norsca", category = "inf_melee", tier = nil, } },
        { "wh_dlc08_nor_mon_skinwolves_1",                          "special", 2, { culture = "wh_dlc08_nor_norsca", category = "inf_melee", tier = nil, } },
        { "wh_dlc08_nor_veh_marauder_warwolves_chariot_0",          "special", 2, { culture = "wh_dlc08_nor_norsca", category = "war_machine", tier = nil, } },
        { "wh_dlc08_nor_mon_fimir_0",                               "rare",    1, { culture = "wh_dlc08_nor_norsca", category = "inf_melee", tier = nil, } },
        { "wh_dlc08_nor_mon_fimir_1",                               "rare",    1, { culture = "wh_dlc08_nor_norsca", category = "inf_melee", tier = nil, } },
        { "wh_dlc08_nor_mon_frost_wyrm_0",                          "rare",    3, { culture = "wh_dlc08_nor_norsca", category = "inf_melee", tier = nil, } },
        { "wh_dlc08_nor_mon_norscan_giant_0",                       "rare",    2, { culture = "wh_dlc08_nor_norsca", category = "inf_melee", tier = nil, } },
        { "wh_dlc08_nor_mon_war_mammoth_0",                         "rare",    2, { culture = "wh_dlc08_nor_norsca", category = "inf_melee", tier = nil, } },
        { "wh_dlc08_nor_mon_war_mammoth_1",                         "rare",    3, { culture = "wh_dlc08_nor_norsca", category = "war_beast", tier = nil, } },
        { "wh_dlc08_nor_mon_war_mammoth_2",                         "rare",    3, { culture = "wh_dlc08_nor_norsca", category = "war_beast", tier = nil, } },
        { "wh2_main_lzd_inf_skink_cohort_1",                        "core",    1, { culture = "wh2_main_lzd_lizardmen", category = "inf_ranged", tier = nil, } },
        { "wh2_main_lzd_inf_skink_skirmishers_0",                   "core",    1, { culture = "wh2_main_lzd_lizardmen", category = "inf_ranged", tier = nil, } },
        { "wh2_main_lzd_inf_saurus_spearmen_0",                     "core",    2, { culture = "wh2_main_lzd_lizardmen", category = "inf_melee", tier = nil, } },
        { "wh2_main_lzd_inf_saurus_spearmen_1",                     "core",    2, { culture = "wh2_main_lzd_lizardmen", category = "inf_melee", tier = nil, } },
        { "wh2_main_lzd_inf_saurus_warriors_0",                     "core",    2, { culture = "wh2_main_lzd_lizardmen", category = "inf_melee", tier = nil, } },
        { "wh2_main_lzd_inf_saurus_warriors_1",                     "core",    2, { culture = "wh2_main_lzd_lizardmen", category = "inf_melee", tier = nil, } },
        { "wh2_main_lzd_inf_skink_cohort_0",                        "core",    1, { culture = "wh2_main_lzd_lizardmen", category = "inf_melee", tier = nil, } },
        { "wh2_main_lzd_cav_cold_ones_feral_0",                     "core",    3, { culture = "wh2_main_lzd_lizardmen", category = "inf_melee", tier = nil, } },
        { "wh2_dlc12_lzd_inf_skink_red_crested_0",                  "core",    3, { culture = "wh2_main_lzd_lizardmen", category = "inf_melee", tier = nil, } },
        { "wh2_main_lzd_mon_kroxigors",                             "special", 2, { culture = "wh2_main_lzd_lizardmen", category = "inf_melee", tier = nil, } },
        { "wh2_main_lzd_cav_terradon_riders_0",                     "special", 1, { culture = "wh2_main_lzd_lizardmen", category = "cavalry", tier = nil, } },
        { "wh2_main_lzd_cav_terradon_riders_1",                     "special", 1, { culture = "wh2_main_lzd_lizardmen", category = "cavalry", tier = nil, } },
        { "wh2_main_lzd_mon_bastiladon_0",                          "special", 1, { culture = "wh2_main_lzd_lizardmen", category = "inf_melee", tier = nil, } },
        { "wh2_main_lzd_mon_bastiladon_1",                          "special", 2, { culture = "wh2_main_lzd_lizardmen", category = "war_beast", tier = nil, } },
        { "wh2_main_lzd_mon_bastiladon_2",                          "special", 2, { culture = "wh2_main_lzd_lizardmen", category = "war_beast", tier = nil, } },
        { "wh2_main_lzd_mon_stegadon_0",                            "special", 2, { culture = "wh2_main_lzd_lizardmen", category = "inf_melee", tier = nil, } },
        { "wh2_main_lzd_mon_stegadon_1",                            "special", 2, { culture = "wh2_main_lzd_lizardmen", category = "war_beast", tier = nil, } },
        { "wh2_main_lzd_inf_chameleon_skinks_0",                    "special", 1, { culture = "wh2_main_lzd_lizardmen", category = "inf_ranged", tier = nil, } },
        { "wh2_main_lzd_inf_temple_guards",                         "special", 1, { culture = "wh2_main_lzd_lizardmen", category = "inf_melee", tier = nil, } },
        { "wh2_main_lzd_cav_cold_one_spearmen_1",                   "special", 1, { culture = "wh2_main_lzd_lizardmen", category = "cavalry", tier = nil, } },
        { "wh2_main_lzd_cav_cold_ones_1",                           "special", 1, { culture = "wh2_main_lzd_lizardmen", category = "cavalry", tier = nil, } },
        { "wh2_main_lzd_cav_horned_ones_0",                         "special", 2, { culture = "wh2_main_lzd_lizardmen", category = "cavalry", tier = nil, } },
        { "wh2_dlc12_lzd_mon_salamander_pack_0",                    "special", 2, { culture = "wh2_main_lzd_lizardmen", category = "inf_ranged", tier = nil, } },
        { "wh2_dlc12_lzd_mon_bastiladon_3",                         "special", 2, { culture = "wh2_main_lzd_lizardmen", category = "war_beast", tier = nil, } },
        { "wh2_dlc12_lzd_cav_ripperdactyl_riders_0",                "special", 1, { culture = "wh2_main_lzd_lizardmen", category = "cavalry", tier = nil, } },
        { "wh2_dlc13_lzd_mon_razordon_pack_0",                      "special", 2, { culture = "wh2_main_lzd_lizardmen", category = "inf_ranged", tier = nil, } },
        { "wh2_dlc13_lzd_mon_sacred_kroxigors_0",                   "special", 2, { culture = "wh2_main_lzd_lizardmen", category = "inf_melee", tier = nil, } },
        { "wh2_main_lzd_mon_ancient_stegadon",                      "rare",    3, { culture = "wh2_main_lzd_lizardmen", category = "war_beast", tier = nil, } },
        { "wh2_main_lzd_mon_carnosaur_0",                           "rare",    2, { culture = "wh2_main_lzd_lizardmen", category = "inf_melee", tier = nil, } },
        { "wh2_dlc12_lzd_mon_ancient_salamander_0",                 "rare",    1, { culture = "wh2_main_lzd_lizardmen", category = "inf_ranged", tier = nil, } },
        { "wh2_dlc12_lzd_mon_ancient_stegadon_1",                   "rare",    3, { culture = "wh2_main_lzd_lizardmen", category = "war_beast", tier = nil, } },
        { "wh2_dlc13_lzd_mon_dread_saurian_0",                      "rare",    2, { culture = "wh2_main_lzd_lizardmen", category = "inf_melee", tier = nil, } },
        { "wh2_dlc13_lzd_mon_dread_saurian_1",                      "rare",    3, { culture = "wh2_main_lzd_lizardmen", category = "war_beast", tier = nil, } },
        { "wh2_dlc17_lzd_inf_chameleon_stalkers_0",                 "rare",    1, { culture = "wh2_main_lzd_lizardmen", category = "inf_melee", tier = nil, } },
        { "wh2_dlc17_lzd_mon_coatl_0",                              "rare",    2, { culture = "wh2_main_lzd_lizardmen", category = "inf_melee", tier = nil, } },
        { "wh2_dlc17_lzd_mon_troglodon_0",                          "rare",    2, { culture = "wh2_main_lzd_lizardmen", category = "inf_melee", tier = nil, } },
        { "wh2_main_skv_inf_clanrat_spearmen_0",                    "core",    2, { culture = "wh2_main_skv_skaven", category = "inf_melee", tier = nil, } },
        { "wh2_main_skv_inf_clanrat_spearmen_1",                    "core",    2, { culture = "wh2_main_skv_skaven", category = "inf_melee", tier = nil, } },
        { "wh2_main_skv_inf_clanrats_0",                            "core",    2, { culture = "wh2_main_skv_skaven", category = "inf_melee", tier = nil, } },
        { "wh2_main_skv_inf_clanrats_1",                            "core",    2, { culture = "wh2_main_skv_skaven", category = "inf_melee", tier = nil, } },
        { "wh2_main_skv_inf_skavenslave_spearmen_0",                "core",    1, { culture = "wh2_main_skv_skaven", category = "inf_melee", tier = nil, } },
        { "wh2_main_skv_inf_skavenslaves_0",                        "core",    1, { culture = "wh2_main_skv_skaven", category = "inf_melee", tier = nil, } },
        { "wh2_main_skv_inf_night_runners_0",                       "core",    3, { culture = "wh2_main_skv_skaven", category = "inf_ranged", tier = nil, } },
        { "wh2_main_skv_inf_night_runners_1",                       "core",    3, { culture = "wh2_main_skv_skaven", category = "inf_ranged", tier = nil, } },
        { "wh2_main_skv_inf_skavenslave_slingers_0",                "core",    1, { culture = "wh2_main_skv_skaven", category = "inf_ranged", tier = nil, } },
        { "wh2_main_skv_mon_rat_ogres",                             "special", 2, { culture = "wh2_main_skv_skaven", category = "inf_melee", tier = nil, } },
        { "wh2_main_skv_inf_death_runners_0",                       "special", 1, { culture = "wh2_main_skv_skaven", category = "inf_melee", tier = nil, } },
        { "wh2_main_skv_inf_gutter_runner_slingers_0",              "special", 1, { culture = "wh2_main_skv_skaven", category = "inf_ranged", tier = nil, } },
        { "wh2_main_skv_inf_gutter_runner_slingers_1",              "special", 1, { culture = "wh2_main_skv_skaven", category = "inf_ranged", tier = nil, } },
        { "wh2_main_skv_inf_gutter_runners_0",                      "special", 1, { culture = "wh2_main_skv_skaven", category = "inf_ranged", tier = nil, } },
        { "wh2_main_skv_inf_gutter_runners_1",                      "special", 1, { culture = "wh2_main_skv_skaven", category = "inf_ranged", tier = nil, } },
        { "wh2_main_skv_inf_poison_wind_globadiers",                "special", 2, { culture = "wh2_main_skv_skaven", category = "inf_ranged", tier = nil, } },
        { "wh2_main_skv_inf_warpfire_thrower",                      "special", 1, { culture = "wh2_main_skv_skaven", category = "inf_ranged", tier = nil, } },
        { "wh2_main_skv_inf_plague_monk_censer_bearer",             "special", 2, { culture = "wh2_main_skv_skaven", category = "inf_melee", tier = nil, } },
        { "wh2_main_skv_inf_plague_monks",                          "special", 1, { culture = "wh2_main_skv_skaven", category = "inf_melee", tier = nil, } },
        { "wh2_main_skv_inf_stormvermin_0",                         "special", 1, { culture = "wh2_main_skv_skaven", category = "inf_melee", tier = nil, } },
        { "wh2_main_skv_inf_stormvermin_1",                         "special", 1, { culture = "wh2_main_skv_skaven", category = "inf_melee", tier = nil, } },
        { "wh2_dlc12_skv_inf_ratling_gun_0",                        "special", 1, { culture = "wh2_main_skv_skaven", category = "inf_ranged", tier = nil, } },
        { "wh2_dlc12_skv_inf_warplock_jezzails_0",                  "special", 2, { culture = "wh2_main_skv_skaven", category = "inf_ranged", tier = nil, } },
        { "wh2_dlc12_skv_veh_doom_flayer_0",                        "special", 2, { culture = "wh2_main_skv_skaven", category = "war_machine", tier = nil, } },
        { "wh2_dlc14_skv_inf_eshin_triads_0",                       "special", 1, { culture = "wh2_main_skv_skaven", category = "inf_melee", tier = nil, } },
        { "wh2_dlc14_skv_inf_poison_wind_mortar_0",                 "special", 2, { culture = "wh2_main_skv_skaven", category = "inf_ranged", tier = nil, } },
        { "wh2_dlc14_skv_inf_warp_grinder_0",                       "special", 1, { culture = "wh2_main_skv_skaven", category = "inf_melee", tier = nil, } },
        { "wh2_dlc16_skv_mon_rat_ogre_mutant",                      "special", 3, { culture = "wh2_main_skv_skaven", category = "inf_melee", tier = nil, } },
        { "wh2_dlc16_skv_mon_wolf_rats_0",                          "special", 1, { culture = "wh2_main_skv_skaven", category = "inf_melee", tier = nil, } },
        { "wh2_dlc16_skv_mon_wolf_rats_1",                          "special", 1, { culture = "wh2_main_skv_skaven", category = "inf_melee", tier = nil, } },
        { "wh2_main_skv_art_plagueclaw_catapult",                   "rare",    1, { culture = "wh2_main_skv_skaven", category = "artillery", tier = nil, } },
        { "wh2_main_skv_art_warp_lightning_cannon",                 "rare",    2, { culture = "wh2_main_skv_skaven", category = "artillery", tier = nil, } },
        { "wh2_main_skv_veh_doomwheel",                             "rare",    2, { culture = "wh2_main_skv_skaven", category = "war_machine", tier = nil, } },
        { "wh2_main_skv_mon_hell_pit_abomination",                  "rare",    3, { culture = "wh2_main_skv_skaven", category = "inf_melee", tier = nil, } },
        { "wh2_main_skv_inf_death_globe_bombardiers",               "rare",    1, { culture = "wh2_main_skv_skaven", category = "inf_ranged", tier = nil, } },
        { "wh2_dlc16_skv_mon_brood_horror_0",                       "rare",    2, { culture = "wh2_main_skv_skaven", category = "inf_melee", tier = nil, } },
        { "wh2_main_hef_inf_archers_0",                             "core",    1, { culture = "wh2_main_hef_high_elves", category = "inf_ranged", tier = nil, } },
        { "wh2_main_hef_inf_archers_1",                             "core",    2, { culture = "wh2_main_hef_high_elves", category = "inf_ranged", tier = nil, } },
        { "wh2_main_hef_inf_lothern_sea_guard_0",                   "core",    2, { culture = "wh2_main_hef_high_elves", category = "inf_ranged", tier = nil, } },
        { "wh2_main_hef_inf_lothern_sea_guard_1",                   "core",    3, { culture = "wh2_main_hef_high_elves", category = "inf_ranged", tier = nil, } },
        { "wh2_main_hef_inf_gate_guard",                            "core",    3, { culture = "wh2_main_hef_high_elves", category = "inf_ranged", tier = nil, } },
        { "wh2_main_hef_cav_ellyrian_reavers_1",                    "core",    2, { culture = "wh2_main_hef_high_elves", category = "cavalry", tier = nil, } },
        { "wh2_main_hef_inf_spearmen_0",                            "core",    1, { culture = "wh2_main_hef_high_elves", category = "inf_melee", tier = nil, } },
        { "wh2_main_hef_cav_ellyrian_reavers_0",                    "core",    1, { culture = "wh2_main_hef_high_elves", category = "cavalry", tier = nil, } },
        { "wh2_main_hef_cav_silver_helms_0",                        "core",    2, { culture = "wh2_main_hef_high_elves", category = "cavalry", tier = nil, } },
        { "wh2_main_hef_cav_silver_helms_1",                        "core",    3, { culture = "wh2_main_hef_high_elves", category = "cavalry", tier = nil, } },
        { "wh2_dlc15_hef_inf_rangers_0",                            "core",    3, { culture = "wh2_main_hef_high_elves", category = "inf_melee", tier = nil, } },
        { "wh2_main_hef_inf_phoenix_guard",                         "special", 2, { culture = "wh2_main_hef_high_elves", category = "inf_melee", tier = nil, } },
        { "wh2_main_hef_inf_swordmasters_of_hoeth_0",               "special", 2, { culture = "wh2_main_hef_high_elves", category = "inf_melee", tier = nil, } },
        { "wh2_main_hef_inf_white_lions_of_chrace_0",               "special", 1, { culture = "wh2_main_hef_high_elves", category = "inf_melee", tier = nil, } },
        { "wh2_main_hef_cav_dragon_princes",                        "special", 2, { culture = "wh2_main_hef_high_elves", category = "cavalry", tier = nil, } },
        { "wh2_main_hef_cav_ithilmar_chariot",                      "special", 2, { culture = "wh2_main_hef_high_elves", category = "war_machine", tier = nil, } },
        { "wh2_main_hef_cav_tiranoc_chariot",                       "special", 1, { culture = "wh2_main_hef_high_elves", category = "war_machine", tier = nil, } },
        { "wh2_main_hef_mon_great_eagle",                           "special", 2, { culture = "wh2_main_hef_high_elves", category = "inf_melee", tier = nil, } },
        { "wh2_dlc10_hef_inf_shadow_warriors_0",                    "special", 1, { culture = "wh2_main_hef_high_elves", category = "inf_ranged", tier = nil, } },
        { "wh2_dlc15_hef_inf_silverin_guard_0",                     "special", 1, { culture = "wh2_main_hef_high_elves", category = "inf_melee", tier = nil, } },
        { "wh2_dlc15_hef_mon_war_lions_of_chrace_0",                "special", 1, { culture = "wh2_main_hef_high_elves", category = "inf_melee", tier = nil, } },
        { "wh2_dlc15_hef_veh_lion_chariot_of_chrace_0",             "special", 2, { culture = "wh2_main_hef_high_elves", category = "war_machine", tier = nil, } },
        { "wh2_main_hef_art_eagle_claw_bolt_thrower",               "rare",    1, { culture = "wh2_main_hef_high_elves", category = "artillery", tier = nil, } },
        { "wh2_main_hef_mon_moon_dragon",                           "rare",    2, { culture = "wh2_main_hef_high_elves", category = "inf_melee", tier = nil, } },
        { "wh2_main_hef_mon_phoenix_flamespyre",                    "rare",    1, { culture = "wh2_main_hef_high_elves", category = "inf_melee", tier = nil, } },
        { "wh2_main_hef_mon_phoenix_frostheart",                    "rare",    1, { culture = "wh2_main_hef_high_elves", category = "inf_melee", tier = nil, } },
        { "wh2_main_hef_mon_star_dragon",                           "rare",    3, { culture = "wh2_main_hef_high_elves", category = "inf_melee", tier = nil, } },
        { "wh2_main_hef_mon_sun_dragon",                            "rare",    2, { culture = "wh2_main_hef_high_elves", category = "inf_melee", tier = nil, } },
        { "wh2_dlc10_hef_inf_sisters_of_avelorn_0",                 "rare",    1, { culture = "wh2_main_hef_high_elves", category = "inf_ranged", tier = nil, } },
        { "wh2_dlc15_hef_mon_arcane_phoenix_0",                     "rare",    2, { culture = "wh2_main_hef_high_elves", category = "inf_melee", tier = nil, } },
        { "wh2_dlc10_hef_inf_dryads_0",                             "core",    3, { culture = "wh2_main_hef_high_elves", category = "inf_melee", tier = nil, } },
        { "wh2_dlc10_hef_mon_treekin_0",                            "special", 2, { culture = "wh2_main_hef_high_elves", category = "inf_melee", tier = nil, } },
        { "wh2_dlc10_hef_inf_shadow_walkers_0",                     "special", 2, { culture = "wh2_main_hef_high_elves", category = "inf_ranged", tier = nil, } },
        { "wh2_dlc15_hef_inf_mistwalkers_faithbearers_0",           "special", 1, { culture = "wh2_main_hef_high_elves", category = "inf_melee", tier = nil, } },
        { "wh2_dlc15_hef_inf_mistwalkers_sentinels_0",              "special", 1, { culture = "wh2_main_hef_high_elves", category = "inf_ranged", tier = nil, } },
        { "wh2_dlc15_hef_inf_mistwalkers_skyhawks_0",               "special", 1, { culture = "wh2_main_hef_high_elves", category = "inf_ranged", tier = nil, } },
        { "wh2_dlc15_hef_inf_mistwalkers_spireguard_0",             "special", 1, { culture = "wh2_main_hef_high_elves", category = "inf_ranged", tier = nil, } },
        { "wh2_dlc10_hef_mon_treeman_0",                            "rare",    3, { culture = "wh2_main_hef_high_elves", category = "inf_melee", tier = nil, } },
        { "wh2_dlc15_hef_inf_mistwalkers_griffon_knights_0",        "rare",    3, { culture = "wh2_main_hef_high_elves", category = "war_beast", tier = nil, } },
        { "wh2_main_def_inf_black_ark_corsairs_0",                  "core",    2, { culture = "wh2_main_def_dark_elves", category = "inf_melee", tier = nil, } },
        { "wh2_main_def_inf_black_ark_corsairs_1",                  "core",    2, { culture = "wh2_main_def_dark_elves", category = "inf_ranged", tier = nil, } },
        { "wh2_main_def_inf_darkshards_0",                          "core",    1, { culture = "wh2_main_def_dark_elves", category = "inf_ranged", tier = nil, } },
        { "wh2_main_def_inf_darkshards_1",                          "core",    2, { culture = "wh2_main_def_dark_elves", category = "inf_ranged", tier = nil, } },
        { "wh2_main_def_cav_dark_riders_2",                         "core",    2, { culture = "wh2_main_def_dark_elves", category = "cavalry", tier = nil, } },
        { "wh2_main_def_inf_bleakswords_0",                         "core",    1, { culture = "wh2_main_def_dark_elves", category = "inf_melee", tier = nil, } },
        { "wh2_main_def_inf_dreadspears_0",                         "core",    1, { culture = "wh2_main_def_dark_elves", category = "inf_melee", tier = nil, } },
        { "wh2_main_def_inf_witch_elves_0",                         "core",    3, { culture = "wh2_main_def_dark_elves", category = "inf_melee", tier = nil, } },
        { "wh2_main_def_cav_dark_riders_0",                         "core",    1, { culture = "wh2_main_def_dark_elves", category = "cavalry", tier = nil, } },
        { "wh2_main_def_cav_dark_riders_1",                         "core",    2, { culture = "wh2_main_def_dark_elves", category = "cavalry", tier = nil, } },
        { "wh2_main_def_inf_harpies",                               "special", 1, { culture = "wh2_main_def_dark_elves", category = "inf_melee", tier = nil, } },
        { "wh2_dlc10_def_mon_feral_manticore_0",                    "special", 2, { culture = "wh2_main_def_dark_elves", category = "inf_melee", tier = nil, } },
        { "wh2_main_def_inf_shades_0",                              "special", 1, { culture = "wh2_main_def_dark_elves", category = "inf_ranged", tier = nil, } },
        { "wh2_main_def_inf_shades_1",                              "special", 2, { culture = "wh2_main_def_dark_elves", category = "inf_ranged", tier = nil, } },
        { "wh2_main_def_inf_shades_2",                              "special", 2, { culture = "wh2_main_def_dark_elves", category = "inf_ranged", tier = nil, } },
        { "wh2_main_def_inf_black_guard_0",                         "special", 2, { culture = "wh2_main_def_dark_elves", category = "inf_melee", tier = nil, } },
        { "wh2_main_def_cav_cold_one_knights_0",                    "special", 1, { culture = "wh2_main_def_dark_elves", category = "cavalry", tier = nil, } },
        { "wh2_main_def_cav_cold_one_knights_1",                    "special", 2, { culture = "wh2_main_def_dark_elves", category = "cavalry", tier = nil, } },
        { "wh2_main_def_inf_har_ganeth_executioners_0",             "special", 2, { culture = "wh2_main_def_dark_elves", category = "inf_melee", tier = nil, } },
        { "wh2_main_def_cav_cold_one_chariot",                      "special", 2, { culture = "wh2_main_def_dark_elves", category = "war_machine", tier = nil, } },
        { "wh2_dlc10_def_cav_doomfire_warlocks_0",                  "special", 2, { culture = "wh2_main_def_dark_elves", category = "cavalry", tier = nil, } },
        { "wh2_dlc14_def_cav_scourgerunner_chariot_0",              "special", 2, { culture = "wh2_main_def_dark_elves", category = "war_machine", tier = nil, } },
        { "wh2_main_def_art_reaper_bolt_thrower",                   "rare",    1, { culture = "wh2_main_def_dark_elves", category = "artillery", tier = nil, } },
        { "wh2_main_def_mon_black_dragon",                          "rare",    3, { culture = "wh2_main_def_dark_elves", category = "inf_melee", tier = nil, } },
        { "wh2_main_def_mon_war_hydra",                             "rare",    2, { culture = "wh2_main_def_dark_elves", category = "inf_melee", tier = nil, } },
        { "wh2_dlc10_def_mon_kharibdyss_0",                         "rare",    2, { culture = "wh2_main_def_dark_elves", category = "inf_melee", tier = nil, } },
        { "wh2_dlc14_def_mon_bloodwrack_medusa_0",                  "rare",    1, { culture = "wh2_main_def_dark_elves", category = "inf_melee", tier = nil, } },
        { "wh2_dlc14_def_veh_bloodwrack_shrine_0",                  "rare",    2, { culture = "wh2_main_def_dark_elves", category = "war_machine", tier = nil, } },
        { "wh2_twa03_def_mon_wolves_0",                             "special", 1, { culture = "wh2_main_def_dark_elves", category = "inf_melee", tier = nil, } },
        { "wh2_twa03_def_mon_war_mammoth_0",                        "rare",    2, { culture = "wh2_main_def_dark_elves", category = "inf_melee", tier = nil, } },
        { "wh2_twa03_grn_mon_wyvern_0",                             "rare",    1, { culture = "wh_main_grn_greenskins", category = "inf_melee", tier = nil, } },
        { "wh3_main_monster_feral_bears",                           "special", 2, { culture = "wh3_main_ksl_kislev", category = "inf_melee", tier = nil, } },
        { "wh3_main_monster_feral_ice_bears",                       "rare",    1, { culture = "wh3_main_ksl_kislev", category = "inf_melee", tier = nil, } },
        { "wh2_dlc10_def_inf_sisters_of_slaughter",                 "rare",    1, { culture = "wh2_main_def_dark_elves", category = "inf_melee", tier = nil, } },
        { "wh2_dlc09_tmb_inf_nehekhara_warriors_0",                 "core",    3, { culture = "wh2_dlc09_tmb_tomb_kings", category = "inf_melee", tier = nil, } },
        { "wh2_dlc09_tmb_inf_skeleton_archers_0",                   "core",    1, { culture = "wh2_dlc09_tmb_tomb_kings", category = "inf_ranged", tier = nil, } },
        { "wh2_dlc09_tmb_inf_skeleton_spearmen_0",                  "core",    1, { culture = "wh2_dlc09_tmb_tomb_kings", category = "inf_melee", tier = nil, } },
        { "wh2_dlc09_tmb_inf_skeleton_warriors_0",                  "core",    1, { culture = "wh2_dlc09_tmb_tomb_kings", category = "inf_melee", tier = nil, } },
        { "wh2_dlc09_tmb_veh_skeleton_archer_chariot_0",            "core",    2, { culture = "wh2_dlc09_tmb_tomb_kings", category = "war_machine", tier = nil, } },
        { "wh2_dlc09_tmb_veh_skeleton_chariot_0",                   "core",    2, { culture = "wh2_dlc09_tmb_tomb_kings", category = "war_machine", tier = nil, } },
        { "wh2_dlc09_tmb_cav_skeleton_horsemen_0",                  "core",    1, { culture = "wh2_dlc09_tmb_tomb_kings", category = "cavalry", tier = nil, } },
        { "wh2_dlc09_tmb_cav_skeleton_horsemen_archers_0",          "core",    2, { culture = "wh2_dlc09_tmb_tomb_kings", category = "cavalry", tier = nil, } },
        { "wh2_dlc09_tmb_inf_tomb_guard_0",                         "special", 1, { culture = "wh2_dlc09_tmb_tomb_kings", category = "inf_melee", tier = nil, } },
        { "wh2_dlc09_tmb_inf_tomb_guard_1",                         "special", 1, { culture = "wh2_dlc09_tmb_tomb_kings", category = "inf_melee", tier = nil, } },
        { "wh2_dlc09_tmb_mon_carrion_0",                            "special", 1, { culture = "wh2_dlc09_tmb_tomb_kings", category = "inf_melee", tier = nil, } },
        { "wh2_dlc09_tmb_mon_sepulchral_stalkers_0",                "special", 2, { culture = "wh2_dlc09_tmb_tomb_kings", category = "inf_ranged", tier = nil, } },
        { "wh2_dlc09_tmb_mon_ushabti_0",                            "special", 2, { culture = "wh2_dlc09_tmb_tomb_kings", category = "inf_melee", tier = nil, } },
        { "wh2_dlc09_tmb_mon_ushabti_1",                            "special", 2, { culture = "wh2_dlc09_tmb_tomb_kings", category = "inf_ranged", tier = nil, } },
        { "wh2_dlc09_tmb_cav_necropolis_knights_0",                 "special", 2, { culture = "wh2_dlc09_tmb_tomb_kings", category = "cavalry", tier = nil, } },
        { "wh2_dlc09_tmb_cav_necropolis_knights_1",                 "special", 2, { culture = "wh2_dlc09_tmb_tomb_kings", category = "cavalry", tier = nil, } },
        { "wh2_dlc09_tmb_cav_nehekhara_horsemen_0",                 "special", 1, { culture = "wh2_dlc09_tmb_tomb_kings", category = "cavalry", tier = nil, } },
        { "wh2_dlc09_tmb_mon_tomb_scorpion_0",                      "rare",    1, { culture = "wh2_dlc09_tmb_tomb_kings", category = "inf_melee", tier = nil, } },
        { "wh2_dlc09_tmb_mon_heirotitan_0",                         "rare",    3, { culture = "wh2_dlc09_tmb_tomb_kings", category = "inf_melee", tier = nil, } },
        { "wh2_dlc09_tmb_mon_necrosphinx_0",                        "rare",    3, { culture = "wh2_dlc09_tmb_tomb_kings", category = "inf_melee", tier = nil, } },
        { "wh2_dlc09_tmb_art_casket_of_souls_0",                    "rare",    1, { culture = "wh2_dlc09_tmb_tomb_kings", category = "war_machine", tier = nil, } },
        { "wh2_dlc09_tmb_art_screaming_skull_catapult_0",           "rare",    1, { culture = "wh2_dlc09_tmb_tomb_kings", category = "artillery", tier = nil, } },
        { "wh2_dlc09_tmb_veh_khemrian_warsphinx_0",                 "rare",    2, { culture = "wh2_dlc09_tmb_tomb_kings", category = "war_beast", tier = nil, } },
        { "wh2_pro06_tmb_mon_bone_giant_0",                         "rare",    2, { culture = "wh2_dlc09_tmb_tomb_kings", category = "inf_ranged", tier = nil, } },
        { "wh2_dlc09_tmb_mon_dire_wolves",                          "core",    3, { culture = "wh2_dlc09_tmb_tomb_kings", category = "inf_melee", tier = nil, } },
        { "wh2_dlc09_tmb_mon_fell_bats",                            "core",    3, { culture = "wh2_dlc09_tmb_tomb_kings", category = "inf_melee", tier = nil, } },
        { "wh2_dlc09_tmb_inf_crypt_ghouls",                         "core",    3, { culture = "wh2_dlc09_tmb_tomb_kings", category = "inf_melee", tier = nil, } },
        { "wh2_dlc09_tmb_cav_hexwraiths",                           "special", 2, { culture = "wh2_dlc09_tmb_tomb_kings", category = "cavalry", tier = nil, } },
        { "wh2_dlc11_cst_inf_sartosa_free_company_0",               "core",    3, { culture = "wh2_dlc11_cst_vampire_coast", category = "inf_melee", tier = nil, } },
        { "wh2_dlc11_cst_inf_sartosa_militia_0",                    "core",    3, { culture = "wh2_dlc11_cst_vampire_coast", category = "inf_ranged", tier = nil, } },
        { "wh2_dlc11_cst_inf_zombie_deckhands_mob_0",               "core",    1, { culture = "wh2_dlc11_cst_vampire_coast", category = "inf_melee", tier = nil, } },
        { "wh2_dlc11_cst_inf_zombie_deckhands_mob_1",               "core",    1, { culture = "wh2_dlc11_cst_vampire_coast", category = "inf_melee", tier = nil, } },
        { "wh2_dlc11_cst_inf_zombie_gunnery_mob_0",                 "core",    1, { culture = "wh2_dlc11_cst_vampire_coast", category = "inf_ranged", tier = nil, } },
        { "wh2_dlc11_cst_inf_zombie_gunnery_mob_1",                 "core",    2, { culture = "wh2_dlc11_cst_vampire_coast", category = "inf_ranged", tier = nil, } },
        { "wh2_dlc11_cst_inf_zombie_gunnery_mob_2",                 "core",    2, { culture = "wh2_dlc11_cst_vampire_coast", category = "inf_ranged", tier = nil, } },
        { "wh2_dlc11_cst_inf_zombie_gunnery_mob_3",                 "core",    3, { culture = "wh2_dlc11_cst_vampire_coast", category = "inf_ranged", tier = nil, } },
        { "wh2_dlc11_cst_mon_bloated_corpse_0",                     "core",    3, { culture = "wh2_dlc11_cst_vampire_coast", category = "inf_melee", tier = nil, } },
        { "wh2_dlc11_cst_mon_fell_bats",                            "core",    3, { culture = "wh2_dlc11_cst_vampire_coast", category = "inf_melee", tier = nil, } },
        { "wh2_dlc11_cst_mon_scurvy_dogs",                          "core",    3, { culture = "wh2_dlc11_cst_vampire_coast", category = "inf_melee", tier = nil, } },
        { "wh2_dlc11_cst_art_carronade",                            "special", 2, { culture = "wh2_dlc11_cst_vampire_coast", category = "artillery", tier = nil, } },
        { "wh2_dlc11_cst_art_mortar",                               "special", 2, { culture = "wh2_dlc11_cst_vampire_coast", category = "artillery", tier = nil, } },
        { "wh2_dlc11_cst_cav_deck_droppers_0",                      "special", 1, { culture = "wh2_dlc11_cst_vampire_coast", category = "cavalry", tier = nil, } },
        { "wh2_dlc11_cst_cav_deck_droppers_1",                      "special", 1, { culture = "wh2_dlc11_cst_vampire_coast", category = "cavalry", tier = nil, } },
        { "wh2_dlc11_cst_cav_deck_droppers_2",                      "special", 1, { culture = "wh2_dlc11_cst_vampire_coast", category = "cavalry", tier = nil, } },
        { "wh2_dlc11_cst_inf_deck_gunners_0",                       "special", 1, { culture = "wh2_dlc11_cst_vampire_coast", category = "inf_ranged", tier = nil, } },
        { "wh2_dlc11_cst_inf_depth_guard_0",                        "special", 2, { culture = "wh2_dlc11_cst_vampire_coast", category = "inf_melee", tier = nil, } },
        { "wh2_dlc11_cst_inf_depth_guard_1",                        "special", 2, { culture = "wh2_dlc11_cst_vampire_coast", category = "inf_melee", tier = nil, } },
        { "wh2_dlc11_cst_inf_syreens",                              "special", 2, { culture = "wh2_dlc11_cst_vampire_coast", category = "inf_melee", tier = nil, } },
        { "wh2_dlc11_cst_mon_animated_hulks_0",                     "special", 1, { culture = "wh2_dlc11_cst_vampire_coast", category = "inf_melee", tier = nil, } },
        { "wh2_dlc11_cst_mon_rotting_prometheans_0",                "special", 2, { culture = "wh2_dlc11_cst_vampire_coast", category = "inf_melee", tier = nil, } },
        { "wh2_dlc11_cst_mon_rotting_prometheans_gunnery_mob_0",    "special", 2, { culture = "wh2_dlc11_cst_vampire_coast", category = "war_beast", tier = nil, } },
        { "wh2_dlc11_cst_mon_mournguls_0",                          "rare",    1, { culture = "wh2_dlc11_cst_vampire_coast", category = "inf_melee", tier = nil, } },
        { "wh2_dlc11_cst_mon_necrofex_colossus_0",                  "rare",    3, { culture = "wh2_dlc11_cst_vampire_coast", category = "war_beast", tier = nil, } },
        { "wh2_dlc11_cst_mon_rotting_leviathan_0",                  "rare",    3, { culture = "wh2_dlc11_cst_vampire_coast", category = "war_beast", tier = nil, } },
        { "wh2_dlc11_cst_mon_terrorgheist",                         "rare",    3, { culture = "wh2_dlc11_cst_vampire_coast", category = "inf_melee", tier = nil, } },
        { "wh3_dlc23_chd_inf_chaos_dwarf_blunderbusses",            "core",    3, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "inf_ranged", tier = nil, } },
        { "wh3_dlc23_chd_inf_chaos_dwarf_warriors",                 "core",    2, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "inf_melee", tier = nil, } },
        { "wh3_dlc23_chd_inf_chaos_dwarf_warriors_great_weapons",   "core",    2, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "inf_melee", tier = nil, } },
        { "wh3_dlc23_chd_inf_goblin_labourers",                     "core",    1, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "inf_melee", tier = nil, } },
        { "wh3_dlc23_chd_inf_hobgoblin_archers",                    "core",    1, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "inf_ranged", tier = nil, } },
        { "wh3_dlc23_chd_inf_hobgoblin_cutthroats",                 "core",    3, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "inf_melee", tier = nil, } },
        { "wh3_dlc23_chd_inf_orc_labourers",                        "core",    1, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "inf_melee", tier = nil, } },
        { "wh3_dlc23_chd_inf_hobgoblin_sneaky_gits",                "special", 1, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "inf_melee", tier = nil, } },
        { "wh3_dlc23_chd_inf_infernal_guard",                       "special", 1, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "inf_melee", tier = nil, } },
        { "wh3_dlc23_chd_inf_infernal_guard_fireglaives",           "special", 1, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "inf_ranged", tier = nil, } },
        { "wh3_dlc23_chd_inf_infernal_guard_great_weapons",         "special", 1, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "inf_melee", tier = nil, } },
        { "wh3_dlc23_chd_veh_deathshrieker_rocket_launcher",        "special", 2, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "war_machine", tier = nil, } },
        { "wh3_dlc23_chd_veh_iron_daemon",                          "special", 2, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "war_machine", tier = nil, } },
        { "wh3_dlc23_chd_veh_magma_cannon",                         "special", 2, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "war_machine", tier = nil, } },
        { "wh3_dlc23_chd_veh_skullcracker",                         "special", 2, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "war_machine", tier = nil, } },
        { "wh3_dlc23_chd_cav_bull_centaurs_axe",                    "special", 2, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "inf_melee", tier = nil, } },
        { "wh3_dlc23_chd_cav_bull_centaurs_dual_axe",               "special", 2, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "inf_melee", tier = nil, } },
        { "wh3_dlc23_chd_cav_bull_centaurs_greatweapons",           "special", 2, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "inf_melee", tier = nil, } },
        { "wh3_dlc23_chd_inf_infernal_ironsworn",                   "special", 2, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "inf_melee", tier = nil, } },
        { "wh3_dlc23_chd_mon_kdaai_fireborn",                       "special", 2, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "inf_melee", tier = nil, } },
        { "wh3_dlc23_chd_cav_hobgoblin_wolf_raiders_bows",          "rare",    1, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "cavalry", tier = nil, } },
        { "wh3_dlc23_chd_cav_hobgoblin_wolf_raiders_spears",        "rare",    1, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "cavalry", tier = nil, } },
        { "wh3_dlc23_chd_mon_great_taurus",                         "rare",    1, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "inf_melee", tier = nil, } },
        { "wh3_dlc23_chd_mon_lammasu",                              "rare",    2, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "inf_melee", tier = nil, } },
        { "wh3_dlc23_chd_mon_bale_taurus",                          "rare",    2, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "inf_melee", tier = nil, } },
        { "wh3_dlc23_chd_mon_kdaai_destroyer",                      "rare",    3, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "inf_melee", tier = nil, } },
        { "wh3_dlc23_chd_veh_dreadquake_mortar",                    "rare",    3, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "war_machine", tier = nil, } },
        { "wh3_dlc23_chd_veh_skullcracker_1dreadquake",             "rare",    3, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "war_machine", tier = nil, } },
        { "wh3_dlc23_chd_veh_iron_daemon_1dreadquake",              "rare",    3, { culture = "wh3_dlc23_chd_chaos_dwarfs", category = "war_machine", tier = nil, } },
        { "wh3_dlc24_bst_inf_tzaangors",                            "special", 1, { culture = "wh_dlc03_bst_beastmen", category = "inf_melee", tier = nil, } },
        { "wh3_dlc24_bst_mon_incarnate_elemental_of_beasts",        "rare",    3, { culture = "wh_dlc03_bst_beastmen", category = "inf_melee", tier = nil, } },
        { "wh3_dlc24_cth_inf_onyx_crowmen",                         "special", 1, { culture = "wh3_main_cth_cathay", category = "inf_melee", tier = nil, } },
        { "wh3_dlc24_cth_mon_jade_lion",                            "special", 3, { culture = "wh3_main_cth_cathay", category = "inf_melee", tier = nil, } },
        { "wh3_dlc24_cth_mon_jet_lion",                             "special", 3, { culture = "wh3_main_cth_cathay", category = "inf_melee", tier = nil, } },
        { "wh3_dlc24_cth_veh_zhangu_war_drum",                      "rare",    2, { culture = "wh3_main_cth_cathay", category = "war_machine", tier = nil, } },
        { "wh3_dlc24_ksl_inf_akshina_ambushers",                    "rare",    1, { culture = "wh3_main_ksl_kislev", category = "inf_ranged", tier = nil, } },
        { "wh3_dlc24_ksl_mon_incarnate_elemental_of_beasts",        "rare",    3, { culture = "wh3_main_ksl_kislev", category = "inf_melee", tier = nil, } },
        { "wh3_dlc24_ksl_mon_the_things_in_the_woods",              "special", 2, { culture = "wh3_main_ksl_kislev", category = "inf_melee", tier = nil, } },
        { "wh3_dlc24_lzd_mon_carnosaur_0",                          "rare",    2, { culture = "wh2_main_lzd_lizardmen", category = "inf_melee", tier = nil, } },
        { "wh3_dlc24_tze_inf_tzaangors",                            "special", 1, { culture = "wh3_main_tze_tzeentch", category = "inf_melee", tier = nil, } },
        { "wh3_dlc24_tze_mon_cockatrice",                           "rare",    2, { culture = "wh3_main_tze_tzeentch", category = "inf_melee", tier = nil, } },
        { "wh3_dlc24_tze_mon_mutalith_vortex_beast",                "rare",    3, { culture = "wh3_main_tze_tzeentch", category = "inf_melee", tier = nil, } },
        { "wh3_dlc24_tze_mon_flamers_changebringers",               "special", 2, { culture = "wh3_main_tze_tzeentch", category = "inf_melee", tier = nil, } },
        { "wh3_dlc24_ksl_mon_frost_wyrm",                           "rare",    2, { culture = "wh3_main_ksl_kislev", category = "inf_melee", tier = nil, } },
        { "wh3_dlc24_cth_mon_great_moon_bird",                      "special", 3, { culture = "wh3_main_cth_cathay", category = "inf_melee", tier = nil, } },
        { "wh3_dlc24_ksl_inf_kislevite_warriors",                   "core",    1, { culture = "wh3_main_ksl_kislev", category = "inf_melee", tier = nil, } },
        { "wh3_dlc24_tze_inf_centigors_great_weapons",              "special", 1, { culture = "wh3_main_tze_tzeentch", category = "inf_melee", tier = nil, } },
        { "wh3_dlc24_cth_mon_celestial_lion",                       "rare",    2, { culture = "wh3_main_cth_cathay", category = "inf_melee", tier = nil, } },
    }
    pttg_merc_pool:add_unit_list(mercenaries)
end

cm:add_first_tick_callback(function() init_merc_list() end);

core:add_static_object("pttg_merc_pool", pttg_merc_pool);
