-- local factions_to_template = {
--     ["pttg_grn_savage_orcs"] = { "wurrzag" },
--     ["pttg_tmb_tomb_kings"] = { "khatep", "arkhan", "khalida" },
--     ["pttg_skv_skaven"] = { "snikch", "mors", "thrott" },
--     ["pttg_sla_slaanesh"] = { "azazel" },
--     ["pttg_def_dark_elves"] = { "rakarth", "crone", "lokhir" },
--     ["pttg_lzd_lizardmen"] = { "xtehenhauin", "nakai", "gor-rok" },
--     ["pttg_bst_beastmen"] = { "xmalagor", "morghur", "taurox" },
--     ["pttg_grn_greenskins"] = { "xazhag", "grom", "skarsnik" },
--     ["pttg_kho_khorne"] = { "valkia" },
--     ["pttg_nur_nurgle"] = { "festus" },
--     ["pttg_chs_chaos"] = { "sigvald", "kholek" },
--     ["pttg_vmp_vampire_counts"] = { "ghorst", "kemmler", "vlad+isabella" },
--     ["pttg_dwf_dwarfs"] = { "grombrindal", "ungrim", "belegar" },
--     ["pttg_cst_vampire_coast"] = { "saltspire", "direfin", "noctilus" },
--     ["pttg_tze_tzeentch"] = { "vilitch", "changeling" },
--     ["pttg_emp_empire"] = { "volkmar", "wulfhart", "gelt" },
--     ["pttg_ogr_ogre_kingdoms"] = { "skrag", "greasus" },
--     ["pttg_brt_bretonnia"] = { "repanse", "alberic", "the-fay" },
--     ["pttg_nor_norsca"] = { "throgg", "wulfrik" },
--     ["pttg_hef_high_elves"] = { "alith", "alarielle", "eltharion" },
--     ["pttg_wef_wood_elves"] = { "drycha", "Durthu", "Sisters" },
--     ["pttg_ksl_kislev"] = { "kostaltyn", "ostankya", "Boris" },
--     ["pttg_chd_chaos_dwarfs"] = { "zhatan", "drazhoath" },
--     ["pttg_cth_cathay"] = { "zhao", "miao", "yuan" }
-- }

local pttg = core:get_static_object("pttg");

PttG_ArmyTemplate = {

}

function PttG_ArmyTemplate:new(key, info)
    local self = {}
    if not (key and info.faction and info.culture and info.subculture) then
        script_error("Cannot add template without a name_key, faction, culture and subculture.")
        return false
    end
    self.key = key
    self.faction = info.faction
    self.culture = info.culture
    self.subculture = info.subculture

    self.military_grouping = info.military_grouping

    self.alignment = info.alignment or 'neutral'
    self.units = info.units or {}
    self.mandatory_units = info.mandatory_units or {}
    self.act = info.act

    self.bundles = info.bundles or {}
    self.general_subtype = info.general_subtype
    self.agents = info.agents or {}

    self.distribution = info.distribution

    setmetatable(self, { __index = PttG_ArmyTemplate })
    return self
end

function PttG_ArmyTemplate.repr(self)
    return string.format("ArmyTemplate(%s): %s, %s, %s", self.key, self.faction, self.culture, self.subculture)
end

local pttg_battle_templates = {
    bosses = {
        {
            order = {},
            neutral = {},
            chaos = {}
        },
        {
            order = {},
            neutral = {},
            chaos = {}
        },
        {
            order = {},
            neutral = {},
            chaos = {}
        }
    },
    elites = {
        {
            order = {},
            neutral = {},
            chaos = {}
        },
        {
            order = {},
            neutral = {},
            chaos = {}
        },
        {
            order = {},
            neutral = {},
            chaos = {}
        }
    },
    random = {
        {
            order = {},
            neutral = {},
            chaos = {}
        },
        {
            order = {},
            neutral = {},
            chaos = {}
        },
        {
            order = {},
            neutral = {},
            chaos = {}
        }
    },
    other = {
        {
            order = {},
            neutral = {},
            chaos = {}
        },
    },
    factions = {
    },
    templates = {},
    distributions = {
        default = { -- NOTE: Should sum to 100
            melee_infantry     = 35,
            missile_infantry   = 15,
            monstrous_infantry = 10,
            melee_cavalry      = 7,
            missile_cavalry    = 5,
            war_beast          = 5,
            chariot            = 5,
            monstrous_cavalry  = 5,
            warmachine         = 7,
            monster            = 6,
        }
    },
    excluded_army_templates = {}
}

function pttg_battle_templates:add_template(category, key, info)
    if self.templates[key] then
        pttg:log(string.format("Template %s already exists. Skipping", key))
        return false
    end

    local template = PttG_ArmyTemplate:new(key, info)

    if not template then
        script_error(string.format("Template %s could not be created. Skipping", key))
        return false
    end


    pttg:log(string.format("Adding %s", template:repr())
    )


    if category == 'random' then
        if not template.act then
            for act = 1, 3 do
                table.insert(self.random[act][template.alignment], template)
            end
        elseif type(template.act) == 'number' then
            table.insert(self.random[template.act][template.alignment], template)
        elseif type(template.act) == 'table' then
            for _, act in pairs(template.act) do
                table.insert(self.random[act][template.alignment], template)
            end
        end

        -- TODO: figure out if elite and boss templates should also be in here.
        if self.factions[template.faction] then
            table.insert(self.factions[template.faction], template)
        else
            self.factions[template.faction] = { template }
        end
    elseif category == 'elite' then
        if not template.act then
            script_error("[pttg_army_templates] Elite templates require an 'act' parameter.")
            return false
        elseif type(template.act) == 'number' then
            table.insert(self.elites[template.act][template.alignment], template)
        elseif type(template.act) == 'table' then
            for _, act in pairs(template.act) do
                table.insert(self.elites[act][template.alignment], template)
            end
        end
    elseif category == 'boss' then
        if not template.act or not type(template.act == 'number') then
            script_error("[pttg_army_templates] Boss templates require an 'act' number parameter.")
            return false
        end
        table.insert(self.bosses[template.act][template.alignment], template)
    elseif category == 'other' then
        if not template.act or not type(template.act == 'number') then
            script_error("[pttg_army_templates] Boss templates require an 'act' number parameter.")
            return false
        end
        table.insert(self.other[template.act][template.alignment], template)
    else
        script_error(string.format("[pttg_army_templates] Category %s is not supported.", tostring(category)))
        return false
    end

    self.templates[template.key] = template
end

function pttg_battle_templates:get_random_battle_template(act)
    local random_encounter_alignment = cm:random_number(99) - math.clamp(pttg:get_state('alignment') / 4, -33, 33)

    local alignment_templates = nil
    if random_encounter_alignment <= 33 then     -- order encounter
        alignment_templates = self.random[act].order
    elseif random_encounter_alignment <= 66 then -- neutral encounter
        alignment_templates = self.random[act].neutral
    else                                         -- chaos encounter
        alignment_templates = self.random[act].chaos
    end

    local random_encounter = alignment_templates[cm:random_number(#alignment_templates)]
    pttg:log(string.format("[pttg_army_templates] Random template: %s", random_encounter.key))
    return random_encounter
end

function pttg_battle_templates:get_random_elite_battle_template(act)
    local random_encounter_alignment = cm:random_number(99) - math.clamp(pttg:get_state('alignment') / 2, -33, 33)

    local alignment_templates = nil
    if random_encounter_alignment <= 33 then -- order encounter
        alignment_templates = self.elites[act].order
    elseif random_encounter_alignment <= 66 then -- neutral encounter
        alignment_templates = self.elites[act].neutral
    else -- chaos encounter
        alignment_templates = self.elites[act].chaos
    end

    local random_encounter = alignment_templates[cm:random_number(#alignment_templates)]
    pttg:log(string.format("[pttg_army_templates] Random Elite template: %s", random_encounter.key))

    return random_encounter
end

function pttg_battle_templates:get_random_boss_battle_template(act)
    local random_encounter_alignment = cm:random_number(99) - math.clamp(pttg:get_state('alignment') / 2, -33, 33)

    local alignment_templates = nil
    if random_encounter_alignment <= 33 then -- order encounter
        alignment_templates = self.bosses[act].order
    elseif random_encounter_alignment <= 66 then -- neutral encounter
        alignment_templates = self.bosses[act].neutral
    else -- chaos encounter
        alignment_templates = self.bosses[act].chaos
    end

    local random_encounter = alignment_templates[cm:random_number(#alignment_templates)]
    pttg:log(string.format("[pttg_army_templates] Random Elite template: %s", random_encounter.key))
    return random_encounter
end

function pttg_battle_templates:get_distribution(key)
    return self.distributions[key]
end

function pttg_battle_templates:add_distribution(key, distribution)
    if self.distributions[key] then
        pttg:log("Army distribution key [" .. key .. "] already exists. Skipping.")
        return false
    end

    self.distributions[key] = distribution
    return true
end

local function init()

    local bosses = {
        -------------------- ACT 1 --------------------
        -------------------- Order --------------------
        ["pttg_boss_zhao_ming"] = { general_subtype="wh3_main_cth_zhao_ming", agents={}, faction = "pttg_cth_cathay", culture = "wh3_main_cth_cathay", subculture = "wh3_main_sc_cth_cathay", mandatory_units = {{key="wh3_dlc24_cth_mon_celestial_lion"}}, units = {}, alignment = 'order', act = 1 },

        -------------------- Neutral ------------------
        ["pttg_boss_vlad_and_isabella"] = { general_subtype="wh_dlc04_vmp_vlad_con_carstein", agents={"wh_pro02_vmp_isabella_von_carstein_hero"}, faction = "pttg_vmp_vampire_counts", culture = "wh_main_vmp_vampire_counts", subculture = "wh_main_sc_vmp_vampire_counts", mandatory_units = {{key="wh_dlc02_vmp_cav_blood_knights_0"}, {key="wh_dlc02_vmp_cav_blood_knights_0"}}, units = {}, alignment = 'neutral', act = 1 },

        -------------------- Chaos ---------------------
        ["pttg_boss_kholek_suneater"] = { general_subtype="wh_dlc01_chs_kholek_suneater", agents={"random"}, faction = "pttg_chs_chaos", culture = "wh_main_chs_chaos", subculture = "wh_main_sc_chs_chaos", mandatory_units = {{key ="wh_dlc01_chs_mon_dragon_ogre"}, {key="wh_dlc01_chs_mon_dragon_ogre"}}, units = {}, alignment = 'chaos', act = 1 },

        -------------------- ACT 2 --------------------
        -------------------- Order --------------------
        ["pttg_boss_boris"] = { general_subtype="wh3_main_ksl_boris", agents={"wh3_main_ksl_frost_maiden_ice"}, faction = "pttg_ksl_kislev", culture = "wh3_main_ksl_kislev", subculture = "wh3_main_sc_ksl_kislev", mandatory_units = {{key="wh3_main_ksl_veh_little_grom_0"}, {key="wh3_main_ksl_cav_war_bear_riders_1"}, {key="wh3_main_ksl_cav_war_bear_riders_1"}}, units = {}, alignment = 'order', act = 2 },
        -------------------- Neutral ------------------
        ["pttg_boss_crone_hellebron"] = { general_subtype="wh2_dlc10_def_crone_hellebron", agents={""}, faction = "pttg_def_dark_elves", culture = "wh2_main_def_dark_elves", subculture = "wh2_main_sc_def_dark_elves", mandatory_units = {{key="wh2_dlc10_def_inf_sisters_of_slaughter"}, {key="wh2_dlc14_def_veh_bloodwrack_shrine_0"}}, units = {}, alignment = 'neutral', act = 2 },
        -------------------- Chaos ---------------------
        
        ["pttg_boss_astragoth"] = { general_subtype="wh3_dlc23_chd_astragoth", agents={"random", "random"}, faction = "pttg_chd_chaos_dwarfs", culture = "wh3_dlc23_chd_chaos_dwarfs", subculture = "wh3_dlc23_sc_chd_chaos_dwarfs", mandatory_units = {{key ="wh3_dlc23_chd_cav_bull_centaurs_greatweapons"}, {key="wh3_dlc23_chd_mon_kdaai_destroyer"}}, units = {}, alignment = 'chaos', act = 2 },

        -------------------- ACT 3 --------------------
        -------------------- Order --------------------
        ["pttg_boss_tyrion"] = { general_subtype="wh2_main_hef_tyrion", agents={"wh2_main_hef_teclis"}, faction = "pttg_hef_high_elves", culture = "wh2_main_hef_high_elves", subculture = "wh2_main_sc_hef_high_elves", mandatory_units = {{key="wh2_main_hef_mon_phoenix_flamespyre"}, {key="wh2_main_hef_inf_phoenix_guard"}, {key="wh2_main_hef_inf_phoenix_guard"}}, units = {}, alignment = 'order', act = 3 },
        -------------------- Neutral ------------------
        ["pttg_boss_settra"] = { general_subtype="wh2_dlc09_tmb_settra", agents={"random", "random"}, faction = "pttg_tmb_tomb_kings", culture = "wh2_dlc09_tmb_tomb_king", subculture = "wh2_dlc09_sc_tmb_tomb_kings", mandatory_units = {{key="wh2_dlc09_tmb_veh_khemrian_warsphinx_0"}, {key="wh2_dlc09_tmb_mon_necrosphinx_0"}, {key="wh2_dlc09_tmb_art_casket_of_souls_0"}}, units = {}, alignment = 'neutral', act = 3 },
        -------------------- Chaos ---------------------
        ["pttg_boss_archaon"] = { general_subtype="wh_main_chs_archaon", agents={"random", "random"}, faction = "pttg_chs_chaos", culture = "wh_main_chs_chaos", subculture = "wh_main_sc_chs_chaos", mandatory_units = {{key ="wh_main_chs_art_hellcannon"}, {key="wh_dlc01_chs_inf_chosen_2"}}, units = {}, alignment = 'chaos', act = 3 },
    }

    -- TODO Fix elite encounters.
    local elites = {
        -------------------- ACT 1 --------------------
        -------------------- Order --------------------
        ["pttg_elite_empire"] = { general_subtype = "wh2_dlc13_emp_cha_markus_wulfhart", agents = {"wh2_dlc13_emp_hunter_doctor_hertwig_van_hal", "wh2_dlc13_emp_hunter_jorek_grimm", "wh2_dlc13_emp_hunter_kalara_of_wydrioth","wh2_dlc13_emp_hunter_rodrik_l_anguille"}, faction = "pttg_emp_empire", culture = "wh_main_emp_empire", subculture = "wh_main_sc_emp_empire", mandatory_units = {{key="wh2_dlc13_emp_veh_war_wagon_0"}, {key="wh2_dlc13_emp_inf_huntsmen_0"}, {key="wh2_dlc13_emp_inf_huntsmen_0"}}, units = {}, alignment = 'order', act = 1 },


        -------------------- Neutral ------------------
        ["pttg_elite_greenskins"] = { general_subtype="wh_dlc06_grn_wurrzag_da_great_prophet", faction = "pttg_grn_savage_orcs", culture = "wh_main_grn_greenskins", subculture = "wh_main_sc_grn_savage_orcs", mandatory_units = {}, units = {}, alignment = 'neutral', act = 1 },
        ["pttg_elite_ghoul_horde"] = { faction = "pttg_vmp_strygos_empire", culture = "wh_main_vmp_vampire_counts", subculture = "wh_main_sc_vmp_vampire_counts", mandatory_units = {{ key="wh_main_vmp_mon_terrorgheist" }}, units = { { key = "wh_main_vmp_inf_zombie", weight = 10 }, { key = "wh_main_vmp_mon_fell_bats", weight = 10 }, { key = "wh_main_vmp_mon_dire_wolves", weight = 10 }, { key = "wh_dlc04_vmp_veh_corpse_cart_0", weight = 5 }, { key = "wh_main_vmp_inf_crypt_ghouls", weight = 30 }, { key = "wh_main_vmp_mon_crypt_horrors", weight = 20 } }, alignment = 'neutral', act = 1 },
        
        -------------------- Chaos ---------------------
        ["pttg_elite_beastmen"] = { general_subtype="wh_dlc03_bst_malagor", faction = "pttg_bst_beastmen", culture = "wh_dlc03_bst_beastmen", subculture = "wh_dlc03_sc_bst_beastmen", agents={"random"}, mandatory_units = {}, units = {}, alignment = 'chaos', act = 1 },
        
        -------------------- ACT 2 --------------------
        -------------------- Order --------------------
        ["pttg_elite_lizardmen"] = { general_subtype="wh2_dlc12_lzd_tehenhauin", faction = "pttg_lzd_lizardmen", culture = "wh2_main_lzd_lizardmen", subculture = "wh2_main_sc_lzd_lizardmen", mandatory_units = {}, units = {}, alignment = 'order', act = 2 },
        -------------------- Neutral ------------------
        ["pttg_elite_skrag_the_slaughterer"] = { general_subtype="wh3_main_ogr_skrag_the_slaughterer", agents={"random"}, faction = "pttg_ogr_ogre_kingdoms", culture = "wh3_main_ogr_ogre_kingdoms", subculture = "wh3_main_sc_ogr_ogre_kingdoms", mandatory_units = {{key="wh3_main_ogr_mon_gorgers_0"},{key="wh3_main_ogr_mon_gorgers_0"},{key="wh3_main_ogr_mon_giant_0"},}, units = {}, alignment = "neutral", act = 2 },
        -------------------- Chaos ---------------------
        ["pttg_elite_snikch"] = { general_subtype="wh2_dlc14_skv_deathmaster_snikch", agents={"random"}, faction = "pttg_skv_skaven", culture = "wh2_main_skv_skaven", subculture = "wh2_main_sc_skv_skaven", mandatory_units = {{key="wh2_main_skv_inf_death_globe_bombardiers"},{key="wh2_dlc14_skv_inf_eshin_triads_0"},}, units = {}, alignment = "chaos", act = 2 },
        -------------------- ACT 3 --------------------
        -------------------- Order --------------------
        ["pttg_elite_malakai"] = { general_subtype="wh3_dlc25_dwf_malakai_makaisson", agents={"random", "random"}, faction = "pttg_dwf_dwarfs", culture = "wh_main_dwf_dwarfs", subculture = "wh_main_sc_dwf_dwarfs", mandatory_units = {{key="wh3_dlc25_dwf_veh_thunderbarge_malakai"},{key="wh3_dlc25_dwf_art_goblin_hewer"},}, units = {}, alignment = "order", act = 3 },        
        -------------------- Neutral ------------------
        ["pttg_elite_noctilus"] = { general_subtype="wh2_dlc11_cst_noctilus", agents={"random", "random"}, faction = "pttg_cst_vampire_coast", culture = "wh2_dlc11_cst_vampire_coast", subculture = "wh2_dlc11_sc_cst_vampire_coast", mandatory_units = {{key="wh2_dlc11_cst_mon_necrofex_colossus_0"},{key="wh2_dlc11_cst_mon_rotting_leviathan_0"},}, units = {}, alignment = "neutral", act = 3 },
        -------------------- Chaos ---------------------
        ["pttg_elite_tamurkhan"] = { general_subtype="wh3_dlc25_nur_tamurkhan", agents={"wh3_dlc25_nur_kayzk_the_befouled", "random"}, faction = "pttg_nur_nurgle", culture = "wh3_main_nur_nurgle", subculture = "wh3_main_sc_nur_nurgle", mandatory_units = {{key="wh3_dlc25_nur_chieftain_mon_toad_dragon"},{key="wh3_dlc25_nur_chieftain_cav_rot_knights"},}, units = {}, alignment = "chaos", act = 3 },

        -------------------- Other --------------------
        -------------------- Order --------------------
        -------------------- Neutral ------------------
        ["pttg_wef_forest_spirits"] = { faction = "pttg_wef_forest_spirits", culture = "wh_dlc05_wef_wood_elves", subculture = "wh_dlc05_sc_wef_wood_elves", mandatory_units = {}, units = { { key = "wh2_dlc16_wef_mon_malicious_treeman_0", weight = 10 }, { key = "wh_dlc05_wef_mon_treeman_0", weight = 10 }, { key = "wh2_dlc16_wef_mon_wolves_0", weight = 10 }, { key = "wh2_dlc16_wef_mon_malicious_treekin_0", weight = 10 }, { key = "wh2_dlc16_wef_mon_hawks_0", weight = 10 }, { key = "wh2_dlc16_wef_mon_harpies_0", weight = 10 }, { key = "wh2_dlc16_wef_mon_harpies_0", weight = 10 }, { key = "wh2_dlc16_wef_mon_feral_manticore", weight = 5 }, { key = "wh2_dlc16_wef_mon_giant_spiders_0", weight = 10 }, { key = "wh_dlc05_wef_mon_great_eagle_0", weight = 10 }, { key = "wh_dlc05_wef_mon_treekin_0", weight = 20 }, { key = "wh2_dlc16_wef_mon_cave_bats", weight = 20 }, { key = "wh2_dlc16_wef_inf_malicious_dryads_0", weight = 40 }, { key = "wh_dlc05_wef_inf_dryads_0", weight = 40 }, }, alignment = 'order', act = { 1, 2 } },

        -------------------- Chaos ---------------------
    }

    -- TODO fix the commented templates with cool mili groups or units
    local random = {
        ["pttg_tomb_kings"] = { faction = "pttg_tmb_tomb_kings", culture = "wh2_dlc09_tmb_tomb_kings", subculture = "wh2_dlc09_sc_tmb_tomb_kings", mandatory_units = {}, units = {}, alignment = 'neutral', act = nil },
        ["pttg_empire"] = { faction = "pttg_emp_empire", culture = "wh_main_emp_empire", subculture = "wh_main_sc_emp_empire", mandatory_units = {}, units = {}, alignment = 'order', act = nil },
        ["pttg_tzeentch"] = { faction = "pttg_tze_tzeentch", culture = "wh3_main_tze_tzeentch", subculture = "wh3_main_sc_tze_tzeentch", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
        ["pttg_vampire_coast"] = { faction = "pttg_cst_vampire_coast", culture = "wh2_dlc11_cst_vampire_coast", subculture = "wh2_dlc11_sc_cst_vampire_coast", mandatory_units = {}, units = {}, alignment = 'neutral', act = nil },
        ["pttg_dwarfs"] = { faction = "pttg_dwf_dwarfs", culture = "wh_main_dwf_dwarfs", subculture = "wh_main_sc_dwf_dwarfs", mandatory_units = {}, units = {}, alignment = 'order', act = nil },
        ["pttg_vampire_counts"] = { faction = "pttg_vmp_vampire_counts", culture = "wh_main_vmp_vampire_counts", subculture = "wh_main_sc_vmp_vampire_counts", mandatory_units = {}, units = {}, alignment = 'neutral', act = nil },
        ["pttg_chaos"] = { faction = "pttg_chs_chaos", culture = "wh_main_chs_chaos", subculture = "wh_main_sc_chs_chaos", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
        ["pttg_nurgle"] = { faction = "pttg_nur_nurgle", culture = "wh3_main_nur_nurgle", subculture = "wh3_main_sc_nur_nurgle", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
        ["pttg_khorne"] = { faction = "pttg_kho_khorne", culture = "wh3_main_kho_khorne", subculture = "wh3_main_sc_kho_khorne", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
        ["pttg_grn_spider_cult"] = { faction = "pttg_grn_greenskins", culture = "wh_main_grn_greenskins", subculture = "wh_main_sc_grn_greenskins", military_grouping = "wh2_main_rogue_black_spider_tribe", mandatory_units = {}, units = {}, alignment = 'neutral', act = 1 },
        ["pttg_greenskins"] = { faction = "pttg_grn_greenskins", culture = "wh_main_grn_greenskins", subculture = "wh_main_sc_grn_greenskins", mandatory_units = {}, units = {}, alignment = 'neutral', act = nil },
        ["pttg_beastmen"] = { faction = "pttg_bst_beastmen", culture = "wh_dlc03_bst_beastmen", subculture = "wh_dlc03_sc_bst_beastmen", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
        ["pttg_lzd_host_of_tepok"] = { faction = "pttg_lzd_lizardmen", culture = "wh2_main_lzd_lizardmen", subculture = "wh2_main_sc_lzd_lizardmen", military_grouping = "wh3_dlc23_rogue_sacred_host_of_tepok", mandatory_units = {}, units = {}, alignment = 'order', act = { 2, 3 } },
        ["pttg_lizardmen"] = { faction = "pttg_lzd_lizardmen", culture = "wh2_main_lzd_lizardmen", subculture = "wh2_main_sc_lzd_lizardmen", mandatory_units = {}, units = {}, alignment = 'order', act = nil },
        ["pttg_dark_elves"] = { faction = "pttg_def_dark_elves", culture = "wh2_main_def_dark_elves", subculture = "wh2_main_sc_def_dark_elves", mandatory_units = {}, units = {}, alignment = 'neutral', act = nil },
        ["pttg_slaanesh"] = { faction = "pttg_sla_slaanesh", culture = "wh3_main_sla_slaanesh", subculture = "wh3_main_sc_sla_slaanesh", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
        ["pttg_skaven"] = { faction = "pttg_skv_skaven", culture = "wh2_main_skv_skaven", subculture = "wh2_main_sc_skv_skaven", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
        ["pttg_savage_orcs"] = { faction = "pttg_grn_savage_orcs", culture = "wh_main_grn_greenskins", subculture = "wh_main_sc_grn_savage_orcs", mandatory_units = {}, units = {}, alignment = 'neutral', act = nil },
        ["pttg_ogre_kingdoms"] = { faction = "pttg_ogr_ogre_kingdoms", culture = "wh3_main_ogr_ogre_kingdoms", subculture = "wh3_main_sc_ogr_ogre_kingdoms", mandatory_units = {}, units = {}, alignment = 'neutral', act = nil },
        ["pttg_bretonnia"] = { faction = "pttg_brt_bretonnia", culture = "wh_main_brt_bretonnia", subculture = "wh_main_sc_brt_bretonnia", mandatory_units = {}, units = {}, alignment = 'order', act = nil },
        ["pttg_norsca"] = { faction = "pttg_nor_norsca", culture = "wh_dlc08_nor_norsca", subculture = "wh2_main_sc_hef_high_elves", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
        ["pttg_high_elves"] = { faction = "pttg_hef_high_elves", culture = "wh2_main_hef_high_elves", subculture = "wh2_main_sc_skv_skaven", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
        ["pttg_wood_elves"] = { faction = "pttg_wef_wood_elves", culture = "wh_dlc05_wef_wood_elves", subculture = "wh_dlc05_sc_wef_wood_elves", mandatory_units = {}, units = {}, alignment = 'order', act = nil },
        ["pttg_kislev"] = { faction = "pttg_ksl_kislev", culture = "wh3_main_ksl_kislev", subculture = "wh3_main_sc_ksl_kislev", mandatory_units = {}, units = {}, alignment = 'order', act = nil },
        ["pttg_chaos_dwarfs"] = { faction = "pttg_chd_chaos_dwarfs", culture = "wh3_dlc23_chd_chaos_dwarfs", subculture = "wh3_dlc23_sc_chd_chaos_dwarfs", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
        ["pttg_cathay"] = { faction = "pttg_cth_cathay", culture = "wh3_main_cth_cathay", subculture = "wh3_main_sc_cth_cathay", mandatory_units = {}, units = {}, alignment = 'order', act = nil },
        -- ["pttg_grn_greenskins_orcs_only"] = { faction = "pttg_grn_greenskins", culture = "wh_main_grn_greenskins", subculture = "wh_main_sc_grn_greenskins", mandatory_units = {}, units = {}, alignment = 'neutral', act = nil },
        -- ["pttg_khorne_spawned_armies"] = { faction = "pttg_kho_khorne", culture = "wh3_main_kho_khorne", subculture = "wh3_main_sc_kho_khorne", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
        -- ["pttg_lzd_dino_rampage"] = { faction = "pttg_lzd_lizardmen", culture = "wh2_main_lzd_lizardmen", subculture = "wh2_main_sc_lzd_lizardmen", mandatory_units = {}, units = {}, alignment = 'order', act = nil },
        -- ["pttg_def_corsairs"] = { faction = "pttg_def_dark_elves", culture = "wh2_main_def_dark_elves", subculture = "wh2_main_sc_def_dark_elves", mandatory_units = {}, units = {}, alignment = 'neutral', act = nil },
        -- ["pttg_skv_skryre_drill_team"] = { faction = "pttg_skv_skaven", culture = "wh2_main_skv_skaven", subculture = "wh2_main_sc_skv_skaven", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
        -- ["pttg_skv_moulder"] = { faction = "pttg_skv_skaven", culture = "wh2_main_skv_skaven", subculture = "wh2_main_sc_skv_skaven", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
        -- ["pttg_skv_pestilens_and_rats"] = { faction = "pttg_skv_skaven", culture = "wh2_main_skv_skaven", subculture = "wh2_main_sc_skv_skaven", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
    }
    for template, template_info in pairs(random) do
        pttg_battle_templates:add_template('random',
            template, template_info)
    end

    for template, template_info in pairs(elites) do
        pttg_battle_templates:add_template('elite',
            template, template_info)
    end

    for template, template_info in pairs(bosses) do
        pttg_battle_templates:add_template('boss',
            template, template_info)
    end
end

core:add_listener(
    "init_BattleTemplates",
    "pttg_init_complete",
    true,
    function(context)
        init()
    end,
    false
)

core:add_static_object("pttg_battle_templates", pttg_battle_templates);
