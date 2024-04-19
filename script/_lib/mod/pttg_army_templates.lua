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
-- wh2_dlc09_skv_tretch_craventail
-- wh2_dlc09_tmb_arkhan
-- wh2_dlc09_tmb_khalida
-- wh2_dlc09_tmb_khatep
-- wh2_dlc09_tmb_settra
-- wh2_dlc10_def_crone_hellebron
-- wh2_dlc10_hef_alarielle
-- wh2_dlc10_hef_alith_anar
-- wh2_dlc11_cst_admiral_tech_01
-- wh2_dlc11_cst_admiral_tech_02
-- wh2_dlc11_cst_admiral_tech_03
-- wh2_dlc11_cst_admiral_tech_04
-- wh2_dlc11_cst_aranessa
-- wh2_dlc11_cst_cylostra
-- wh2_dlc11_cst_harkon
-- wh2_dlc11_cst_noctilus
-- wh2_dlc11_def_lokhir
-- wh2_dlc12_lzd_tehenhauin
-- wh2_dlc12_lzd_tiktaqto
-- wh2_dlc12_skv_ikit_claw
-- wh2_dlc13_emp_cha_markus_wulfhart
-- wh2_dlc13_lzd_gor_rok
-- wh2_dlc13_lzd_nakai
-- wh2_dlc14_brt_repanse
-- wh2_dlc14_def_malus_darkblade
-- wh2_dlc14_def_malus_darkblade_mp
-- wh2_dlc14_skv_deathmaster_snikch
-- wh2_dlc15_grn_grom_the_paunch
-- wh2_dlc15_hef_eltharion
-- wh2_dlc15_hef_imrik
-- wh2_dlc16_skv_throt_the_unclean
-- wh2_dlc16_wef_drycha
-- wh2_dlc16_wef_sisters_of_twilight
-- wh2_dlc17_bst_taurox
-- wh2_dlc17_dwf_thorek
-- wh2_dlc17_lzd_oxyotl
-- wh2_main_def_malekith
-- wh2_main_def_morathi
-- wh2_main_hef_prince_alastar
-- wh2_main_hef_teclis
-- wh2_main_hef_tyrion
-- wh2_main_lzd_kroq_gar
-- wh2_main_lzd_lord_mazdamundi
-- wh2_main_skv_lord_skrolk
-- wh2_main_skv_queek_headtaker
-- wh2_pro08_neu_gotrek
-- wh2_twa03_def_rakarth
-- wh3_dlc20_kho_valkia
-- wh3_dlc20_nur_festus
-- wh3_dlc20_sla_azazel
-- wh3_dlc20_tze_vilitch
-- wh3_dlc23_chd_astragoth
-- wh3_dlc23_chd_drazhoath
-- wh3_dlc23_chd_zhatan
-- wh3_dlc24_cth_yuan_bo
-- wh3_dlc24_grn_grimgor_ironhide_quest_battle
-- wh3_dlc24_ksl_mother_ostankya
-- wh3_dlc24_tze_the_changeling
-- wh3_main_cth_miao_ying
-- wh3_main_cth_zhao_ming
-- wh3_main_dae_belakor
-- wh3_main_dae_daemon_prince
-- wh3_main_dae_daemon_prince_khorne
-- wh3_main_dae_daemon_prince_khorne_fe
-- wh3_main_dae_daemon_prince_nurgle
-- wh3_main_dae_daemon_prince_nurgle_fe
-- wh3_main_dae_daemon_prince_slaanesh
-- wh3_main_dae_daemon_prince_slaanesh_fe
-- wh3_main_dae_daemon_prince_tzeentch
-- wh3_main_dae_daemon_prince_tzeentch_fe
-- wh3_main_kho_skarbrand
-- wh3_main_ksl_boris
-- wh3_main_ksl_katarin
-- wh3_main_ksl_kostaltyn
-- wh3_main_nur_kugath
-- wh3_main_ogr_greasus_goldtooth
-- wh3_main_ogr_skrag_the_slaughterer
-- wh3_main_sla_nkari
-- wh3_main_tze_kairos
-- wh_dlc01_chs_kholek_suneater
-- wh_dlc01_chs_prince_sigvald
-- wh_dlc03_bst_khazrak
-- wh_dlc03_bst_malagor
-- wh_dlc03_emp_boris_todbringer
-- wh_dlc04_emp_volkmar
-- wh_dlc04_vmp_helman_ghorst
-- wh_dlc04_vmp_vlad_con_carstein
-- wh_dlc05_bst_morghur
-- wh_dlc05_vmp_red_duke
-- wh_dlc05_wef_durthu
-- wh_dlc05_wef_orion
-- wh_dlc06_dwf_belegar
-- wh_dlc06_grn_skarsnik
-- wh_dlc06_grn_wurrzag_da_great_prophet
-- wh_dlc07_brt_alberic
-- wh_dlc07_brt_fay_enchantress
-- wh_dlc08_nor_throgg
-- wh_dlc08_nor_wulfrik
-- wh_main_brt_louen_leoncouer
-- wh_main_chs_archaon
-- wh_main_chs_lord_of_change
-- wh_main_dwf_thorgrim_grudgebearer
-- wh_main_dwf_ungrim_ironfist
-- wh_main_emp_balthasar_gelt
-- wh_main_emp_karl_franz
-- wh_main_grn_azhag_the_slaughterer
-- wh_main_grn_grimgor_ironhide
-- wh_main_vmp_heinrich_kemmler
-- wh_main_vmp_mannfred_von_carstein
-- wh_pro01_dwf_grombrindal
-- wh_pro02_vmp_isabella_von_carstein
local pttg = core:get_static_object("pttg");


local pttg_battle_templates = {
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
    factions = {
    },
    templates = {}
}

function pttg_battle_templates:add_template(category, template, faction, culture, subculture, alignment, mandatory_units,
                                            units,
                                            act)
    if self.templates[template] then
        pttg:log(string.format("Template %s already exists. Skipping", template))
    end

    pttg:log(string.format("Adding template: %s [%s](%s, %s, %s)",
        template, category, faction, subculture, alignment)
    )
    alignment = alignment or 'neutral'
    mandatory_units = mandatory_units or {}
    units = units or {}

    template_info = {
        faction = faction,
        culture = culture,
        subculture = subculture,
        alignment = alignment,
        units = units,
        mandatory_units = mandatory_units
    }

    if category == 'random' then
        if not act then
            for act = 1, 3 do
                table.insert(self.random[act][alignment], { template = template, info = template_info })
            end
        else
            table.insert(self.random[act][alignment], { template = template, info = template_info })
        end

        -- TODO: figure out if elite and boss templates should also be in here.
        if self.factions[faction] then
            table.insert(self.factions[faction], { template })
        else
            self.factions[faction] = { template }
        end
    elseif category == 'elite' then
        if not act then
            script_error("[pttg_army_templates] Elite templates require an 'act' parameter.")
            return false
        end
        table.insert(self.elites[act][alignment], { template = template, info = template_info })
    elseif category == 'boss' then
        if not act then
            script_error("[pttg_army_templates] Boss templates require an 'act' parameter.")
            return false
        end
        table.insert(self.elites[act][alignment], { template = template, info = template_info })
    else
        script_error(string.format("[pttg_army_templates] Category %s is not supported.", tostring(category)))
        return false
    end

    self.templates[template] = template_info
end

function pttg_battle_templates:get_random_battle_template(act)
    local random_encounter_alignment = cm:random_number(99) - math.min(33, pttg:get_state('alignment') / 4)

    local alignment_templates = nil
    if random_encounter_alignment <= 33 then     -- order encounter
        alignment_templates = self.random[act].order
    elseif random_encounter_alignment <= 66 then -- neutral encounter
        alignment_templates = self.random[act].neutral
    else                                         -- chaos encounter
        alignment_templates = self.random[act].chaos
    end

    local random_encounter = alignment_templates[cm:random_number(#alignment_templates)]
    pttg:log(string.format("[pttg_army_templates] Random template: %s", random_encounter.template))
    return random_encounter
end

function pttg_battle_templates:get_random_elite_battle_template(act)
    local random_encounter_alignment = cm:random_number(99) - math.min(33, pttg:get_state('alignment') / 2)

    local alignment_templates = nil
    if random_encounter_alignment <= 33 then     -- order encounter
        alignment_templates = self.elites[act].order
    elseif random_encounter_alignment <= 66 then -- neutral encounter
        alignment_templates = self.elites[act].neutral
    else                                         -- chaos encounter
        alignment_templates = self.elites[act].chaos
    end

    local random_encounter = alignment_templates[cm:random_number(#alignment_templates)]
    pttg:log(string.format("[pttg_army_templates] Random Elite template: %s", random_encounter.template))
    return random_encounter
end

local function init()
    local elites = {
        ["wh2_dlc12_lzd_tehenhauin"] = { faction = "pttg_lzd_lizardmen", culture = "wh2_main_lzd_lizardmen", subculture = "wh2_main_sc_lzd_lizardmen", mandatory_units = {}, units = {}, alignment = 'order', act = 1 },
        ["wh_main_grn_azhag_the_slaughterer"] = { faction = "pttg_grn_greenskins", culture = "wh_main_grn_greenskins", subculture = "wh_main_sc_grn_greenskins", mandatory_units = {}, units = {}, alignment = 'neutral', act = 1 },
        ["wh_dlc03_bst_malagor"] = { faction = "pttg_bst_beastmen", culture = "wh_dlc03_bst_beastmen", subculture = "wh_dlc03_sc_bst_beastmen", mandatory_units = {}, units = {}, alignment = 'chaos', act = 1 },
    }

    local random = {
        ["pttg_tomb_kings"] = { faction = "pttg_tmb_tomb_kings", culture = "wh2_dlc09_tmb_tomb_kings", subculture = "wh2_dlc09_sc_tmb_tomb_kings", mandatory_units = {}, units = {}, alignment = 'neutral', act = nil },
        ["pttg_empire"] = { faction = "pttg_emp_empire", culture = "wh_main_emp_empire", subculture = "wh_main_sc_emp_empire", mandatory_units = {}, units = {}, alignment = 'order', act = nil },
        ["pttg_tzeentch"] = { faction = "pttg_tze_tzeentch", culture = "wh3_main_tze_tzeentch", subculture = "wh3_main_sc_tze_tzeentch", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
        ["pttg_vampire_coast"] = { faction = "pttg_cst_vampire_coast", culture = "wh2_dlc11_cst_vampire_coast", subculture = "wh2_dlc11_sc_cst_vampire_coast", mandatory_units = {}, units = {}, alignment = 'neutral', act = nil },
        ["pttg_dwarfs"] = { faction = "pttg_dwf_dwarfs", culture = "wh_main_dwf_dwarfs", subculture = "wh_main_sc_dwf_dwarfs", mandatory_units = {}, units = {}, alignment = 'order', act = nil },
        ["pttg_vampire_counts"] = { faction = "pttg_vmp_vampire_counts", culture = "wh_main_vmp_vampire_counts", subculture = "wh_main_sc_vmp_vampire_counts", mandatory_units = {}, units = {}, alignment = 'neutral', act = nil },
        ["pttg_chaos"] = { faction = "pttg_chs_chaos", culture = "wh_main_chs_chaos", subculture = "wh_main_sc_chs_chaos", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
        ["pttg_nurgle"] = { faction = "pttg_nur_nurgle", culture = "wh3_main_nur_nurgle", subculture = "wh3_main_sc_nur_nurgle", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
        ["pttg_khorne_spawned_armies"] = { faction = "pttg_kho_khorne", culture = "wh3_main_kho_khorne", subculture = "wh3_main_sc_kho_khorne", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
        ["pttg_khorne"] = { faction = "pttg_kho_khorne", culture = "wh3_main_kho_khorne", subculture = "wh3_main_sc_kho_khorne", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
        ["pttg_grn_spider_cult"] = { faction = "pttg_grn_greenskins", culture = "wh_main_grn_greenskins", subculture = "wh_main_sc_grn_greenskins", mandatory_units = {}, units = {}, alignment = 'neutral', act = nil },
        ["pttg_grn_greenskins_orcs_only"] = { faction = "pttg_grn_greenskins", culture = "wh_main_grn_greenskins", subculture = "wh_main_sc_grn_greenskins", mandatory_units = {}, units = {}, alignment = 'neutral', act = nil },
        ["pttg_greenskins"] = { faction = "pttg_grn_greenskins", culture = "wh_main_grn_greenskins", subculture = "wh_main_sc_grn_greenskins", mandatory_units = {}, units = {}, alignment = 'neutral', act = nil },
        ["pttg_beastmen"] = { faction = "pttg_bst_beastmen", culture = "wh_dlc03_bst_beastmen", subculture = "wh_dlc03_sc_bst_beastmen", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
        ["pttg_lzd_dino_rampage"] = { faction = "pttg_lzd_lizardmen", culture = "wh2_main_lzd_lizardmen", subculture = "wh2_main_sc_lzd_lizardmen", mandatory_units = {}, units = {}, alignment = 'order', act = nil },
        ["pttg_lzd_sanctum_ambush"] = { faction = "pttg_lzd_lizardmen", culture = "wh2_main_lzd_lizardmen", subculture = "wh2_main_sc_lzd_lizardmen", mandatory_units = {}, units = {}, alignment = 'order', act = nil },
        ["pttg_lizardmen"] = { faction = "pttg_lzd_lizardmen", culture = "wh2_main_lzd_lizardmen", subculture = "wh2_main_sc_lzd_lizardmen", mandatory_units = {}, units = {}, alignment = 'order', act = nil },
        ["pttg_dark_elves"] = { faction = "pttg_def_dark_elves", culture = "wh2_main_def_dark_elves", subculture = "wh2_main_sc_def_dark_elves", mandatory_units = {}, units = {}, alignment = 'neutral', act = nil },
        ["pttg_def_corsairs"] = { faction = "pttg_def_dark_elves", culture = "wh2_main_def_dark_elves", subculture = "wh2_main_sc_def_dark_elves", mandatory_units = {}, units = {}, alignment = 'neutral', act = nil },
        ["pttg_slaanesh"] = { faction = "pttg_sla_slaanesh", culture = "wh3_main_sla_slaanesh", subculture = "wh3_main_sc_sla_slaanesh", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
        ["pttg_skv_skryre_drill_team"] = { faction = "pttg_skv_skaven", culture = "wh2_main_skv_skaven", subculture = "wh2_main_sc_skv_skaven", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
        ["pttg_skv_moulder"] = { faction = "pttg_skv_skaven", culture = "wh2_main_skv_skaven", subculture = "wh2_main_sc_skv_skaven", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
        ["pttg_skv_pestilens_and_rats"] = { faction = "pttg_skv_skaven", culture = "wh2_main_skv_skaven", subculture = "wh2_main_sc_skv_skaven", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
        ["pttg_skaven"] = { faction = "pttg_skv_skaven", culture = "wh2_main_skv_skaven", subculture = "wh2_main_sc_skv_skaven", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
        ["pttg_savage_orcs"] = { faction = "pttg_grn_savage_orcs", culture = "wh_main_grn_greenskins", subculture = "wh_main_sc_grn_savage_orcs", mandatory_units = {}, units = {}, alignment = 'neutral', act = nil },
        ["pttg_ogre_kingdoms"] = { faction = "pttg_skvpttg_ogr_ogre_kingdoms_skaven", culture = "wh3_main_ogr_ogre_kingdoms", subculture = "wh3_main_sc_ogr_ogre_kingdoms", mandatory_units = {}, units = {}, alignment = 'neutral', act = nil },
        ["pttg_bretonnia"] = { faction = "pttg_brt_bretonnia", culture = "wh_main_brt_bretonnia", subculture = "wh_main_sc_brt_bretonnia", mandatory_units = {}, units = {}, alignment = 'order', act = nil },
        ["pttg_nor_fimir"] = { faction = "pttg_nor_norsca", culture = "wh_dlc08_nor_norsca", subculture = "wh_dlc08_sc_nor_norsca", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
        ["pttg_norsca"] = { faction = "pttg_nor_norsca", culture = "wh_dlc08_nor_norsca", subculture = "wh2_main_sc_hef_high_elves", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
        ["pttg_high_elves"] = { faction = "pttg_hef_high_elves", culture = "wh2_main_hef_high_elves", subculture = "wh2_main_sc_skv_skaven", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
        ["pttg_vmp_ghoul_horde"] = { faction = "pttg_vmp_strygos_empire", culture = "wh_main_vmp_vampire_counts", subculture = "wh_main_sc_vmp_vampire_counts", mandatory_units = {}, units = { { key = "wh_main_vmp_inf_crypt_ghouls", weight = 30 }, { key = "wh_main_vmp_mon_crypt_horrors", weight = 20 }, { key = "wh_main_vmp_mon_terrorgheist", weight = 10 } }, alignment = 'neutral', act = 1 },
        ["pttg_wood_elves"] = { faction = "pttg_wef_wood_elves", culture = "wh_dlc05_wef_wood_elves", subculture = "wh_dlc05_sc_wef_wood_elves", mandatory_units = {}, units = {}, alignment = 'order', act = nil },
        ["pttg_wef_forest_spirits"] = { faction = "pttg_wef_forest_spirits", culture = "wh_dlc05_wef_wood_elves", subculture = "wh_dlc05_sc_wef_wood_elves", mandatory_units = {}, units = {{key="wh2_dlc16_wef_mon_harpies_0",weight=},{key="wh2_dlc16_wef_mon_harpies_0",weight=10},{key="wh2_dlc16_wef_mon_feral_manticore",weight=5},{key="wh2_dlc16_wef_mon_giant_spiders_0",weight=10},{key="wh_dlc05_wef_mon_great_eagle_0",weight=10},{key="wh_dlc05_wef_mon_treekin_0",weight=20},{key="wh2_dlc16_wef_mon_cave_bats",weight=20},{key="wh2_dlc16_wef_inf_malicious_dryads_0",weight=40},{key="wh_dlc05_wef_inf_dryads_0",weight=40},}, alignment = 'order', act = nil },
        ["pttg_kislev"] = { faction = "pttg_ksl_kislev", culture = "wh3_main_ksl_kislev", subculture = "wh3_main_sc_ksl_kislev", mandatory_units = {}, units = {}, alignment = 'order', act = nil },
        ["pttg_chaos_dwarfs"] = { faction = "pttg_chd_chaos_dwarfs", culture = "wh3_dlc23_chd_chaos_dwarfs", subculture = "wh3_dlc23_sc_chd_chaos_dwarfs", mandatory_units = {}, units = {}, alignment = 'chaos', act = nil },
        ["pttg_cathay"] = { faction = "pttg_cth_cathay", culture = "wh3_main_cth_cathay", subculture = "wh3_main_sc_cth_cathay", mandatory_units = {}, units = {}, alignment = 'order', act = nil },
    }
    for template, template_info in pairs(random) do
        pttg_battle_templates:add_template('random',
            template, template_info.faction, template_info.culture,
            template_info.subculture, template_info.alignment,
            template_info.mandatory_units, template_info.units
        )
    end

    for template, template_info in pairs(elites) do
        pttg_battle_templates:add_template('elite',
            template, template_info.faction, template_info.culture,
            template_info.subculture, template_info.alignment,
            template_info.mandatory_units, template_info.units, template_info.act
        )
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
