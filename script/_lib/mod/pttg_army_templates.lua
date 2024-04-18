-- local factions_to_template = {
--     ["pttg_grn_savage_orcs"] = { "wurrzag" },
--     ["pttg_tmb_tomb_kings"] = { "khatep", "arkhan", "khalida" },
--     ["pttg_skv_skaven"] = { "snikch", "mors", "thrott" },
--     ["pttg_sla_slaanesh"] = { "azazel" },
--     ["pttg_def_dark_elves"] = { "rakarth", "crone", "lokhir" },
--     ["pttg_lzd_lizardmen"] = { "tehenhauin", "nakai", "gor-rok" },
--     ["pttg_bst_beastmen"] = { "malagor", "morghur", "taurox" },
--     ["pttg_grn_greenskins"] = { "azhag", "grom", "skarsnik" },
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
        order = {},
        neutral = {},
        chaos = {}
    },
    factions = {
        ["pttg_grn_savage_orcs"] = { "pttg_savage_orcs" }
    },
    templates = {}
}

function pttg_battle_templates:add_template(category, template, faction, subculture, alignment, mandatory_units, units,
                                            act)
    if self.templates[template] then
        pttg:log(string.format("Template %s already exists. Skipping", template))
    end

    alignment = alignment or 'neutral'
    mandatory_units = mandatory_units or {}
    units = units or {}
    template_info = {
        faction = faction,
        subculture = subculture,
        alignment = alignment,
        units = units,
        mandatory_units = mandatory_units
    }
    if category == 'random' then
        self.random[template][alignment] = template_info
        if self.factions[faction][template] then
            table.insert(self.factions[faction], { template })
        else
            self.factions[faction] = { template }
        end
    elseif category == 'elite' then
        if not act then
            pttg:log("Elite templates require an 'act' parameter.")
            return false
        end
        table.insert(self.elites[alignment], template_info)
    elseif category == 'boss' then
        if not act then
            pttg:log("Boss templates require an 'act' parameter.")
            return false
        end
        table.insert(self.elites[alignment], template_info)
    else
        pttg:log(string.format("Category %s is not supported.", category))
    end

    self.templates[template] = template_info
end

local function init()
    local elites = {
        ["tehenhauin"] = { faction = "pttg_lzd_lizardmen", subculture = "wh2_main_sc_lzd_lizardmen", mandatory_units = {}, units = {}, alignment = nil }
    }

    local random = {
        ["pttg_tomb_kings"] = { faction = "pttg_tmb_tomb_kings", subculture = "wh2_dlc09_sc_tmb_tomb_kings", mandatory_units = {}, units = {}, alignment = 'neutral' },
        ["pttg_empire"] = { faction = "pttg_emp_empire", subculture = "wh_main_sc_emp_empire", mandatory_units = {}, units = {}, alignment = 'order' },
        ["pttg_tzeentch"] = { faction = "pttg_tze_tzeentch", subculture = "wh3_main_sc_tze_tzeentch", mandatory_units = {}, units = {}, alignment = 'chaos' },
        ["pttg_vampire_coast"] = { faction = "pttg_cst_vampire_coast", subculture = "wh2_dlc11_sc_cst_vampire_coast", mandatory_units = {}, units = {}, alignment = 'neutral' },
        ["pttg_dwarfs"] = { faction = "pttg_dwf_dwarfs", subculture = "wh_main_sc_dwf_dwarfs", mandatory_units = {}, units = {}, alignment = 'order' },
        ["pttg_vampire_counts"] = { faction = "pttg_vmp_vampire_counts", subculture = "wh_main_sc_vmp_vampire_counts", mandatory_units = {}, units = {}, alignment = 'neutral' },
        ["pttg_chaos"] = { faction = "pttg_chs_chaos", subculture = "wh_main_sc_chs_chaos", mandatory_units = {}, units = {}, alignment = 'chaos' },
        ["pttg_nurgle"] = { faction = "pttg_nur_nurgle", subculture = "wh3_main_sc_nur_nurgle", mandatory_units = {}, units = {}, alignment = 'chaos' },
        ["pttg_khorne_spawned_armies"] = { faction = "pttg_kho_khorne", subculture = "wh3_main_sc_kho_khorne", mandatory_units = {}, units = {}, alignment = 'chaos' },
        ["pttg_khorne"] = { faction = "pttg_kho_khorne", subculture = "wh3_main_sc_kho_khorne", mandatory_units = {}, units = {}, alignment = 'chaos' },
        ["pttg_grn_spider_cult"] = { faction = "pttg_grn_greenskins", subculture = "wh_main_sc_grn_greenskins", mandatory_units = {}, units = {}, alignment = 'neutral' },
        ["pttg_grn_greenskins_orcs_only"] = { faction = "pttg_grn_greenskins", subculture = "wh_main_sc_grn_greenskins", mandatory_units = {}, units = {}, alignment = 'neutral' },
        ["pttg_greenskins"] = { faction = "pttg_grn_greenskins", subculture = "wh_main_sc_grn_greenskins", mandatory_units = {}, units = {}, alignment = 'neutral' },
        ["pttg_beastmen"] = { faction = "pttg_bst_beastmen", subculture = "wh_dlc03_sc_bst_beastmen", mandatory_units = {}, units = {}, alignment = 'chaos' },
        ["pttg_lzd_dino_rampage"] = { faction = "pttg_lzd_lizardmen", subculture = "wh2_main_sc_lzd_lizardmen", mandatory_units = {}, units = {}, alignment = 'order' },
        ["pttg_lzd_sanctum_ambush"] = { faction = "pttg_lzd_lizardmen", subculture = "wh2_main_sc_lzd_lizardmen", mandatory_units = {}, units = {}, alignment = 'order' },
        ["pttg_lizardmen"] = { faction = "pttg_lzd_lizardmen", subculture = "wh2_main_sc_lzd_lizardmen", mandatory_units = {}, units = {}, alignment = 'order' },
        ["pttg_dark_elves"] = { faction = "pttg_def_dark_elves", subculture = "wh2_main_sc_def_dark_elves", mandatory_units = {}, units = {}, alignment = 'neutral' },
        ["pttg_def_corsairs"] = { faction = "pttg_def_dark_elves", subculture = "wh2_main_sc_def_dark_elves", mandatory_units = {}, units = {}, alignment = 'neutral' },
        ["pttg_slaanesh"] = { faction = "pttg_sla_slaanesh", subculture = "wh3_main_sc_sla_slaanesh", mandatory_units = {}, units = {}, alignment = 'chaos' },
        ["pttg_skv_skryre_drill_team"] = { faction = "pttg_skv_skaven", subculture = "wh2_main_sc_skv_skaven", mandatory_units = {}, units = {}, alignment = 'chaos' },
        ["pttg_skv_moulder"] = { faction = "pttg_skv_skaven", subculture = "wh2_main_sc_skv_skaven", mandatory_units = {}, units = {}, alignment = 'chaos' },
        ["pttg_skv_pestilens_and_rats"] = { faction = "pttg_skv_skaven", subculture = "wh2_main_sc_skv_skaven", mandatory_units = {}, units = {}, alignment = 'chaos' },
        ["pttg_skaven"] = { faction = "pttg_skv_skaven", subculture = "wh2_main_sc_skv_skaven", mandatory_units = {}, units = {}, alignment = 'chaos' },
        ["pttg_savage_orcs"] = { faction = "pttg_grn_savage_orcs", subculture = "wh_main_sc_grn_savage_orcs", mandatory_units = {}, units = {}, alignment = 'neutral' },
        ["pttg_ogre_kingdoms"] = { faction = "pttg_skvpttg_ogr_ogre_kingdoms_skaven", subculture = "wh3_main_sc_ogr_ogre_kingdoms", mandatory_units = {}, units = {}, alignment = 'neutral' },
        ["pttg_bretonnia"] = { faction = "pttg_brt_bretonnia", subculture = "wh_main_sc_brt_bretonnia", mandatory_units = {}, units = {}, alignment = 'order' },
        ["pttg_nor_fimir"] = { faction = "pttg_nor_norsca", subculture = "wh_dlc08_sc_nor_norsca", mandatory_units = {}, units = {}, alignment = 'chaos' },
        ["pttg_norsca"] = { faction = "pttg_nor_norsca", subculture = "wh2_main_sc_hef_high_elves", mandatory_units = {}, units = {}, alignment = 'chaos' },
        ["pttg_high_elves"] = { faction = "pttg_hef_high_elves", subculture = "wh2_main_sc_skv_skaven", mandatory_units = {}, units = {}, alignment = 'chaos' },
        ["pttg_vmp_ghoul_horde"] = { faction = "pttg_vmp_strygos_empire", subculture = "wh_main_sc_vmp_vampire_counts", mandatory_units = {}, units = {}, alignment = 'neutral' },
        ["pttg_wood_elves"] = { faction = "pttg_wef_wood_elves", subculture = "wh_dlc05_sc_wef_wood_elves", mandatory_units = {}, units = {}, alignment = 'order' },
        ["pttg_wef_forest_spirits"] = { faction = "pttg_wef_forest_spirits", subculture = "wh_dlc05_sc_wef_wood_elves", mandatory_units = {}, units = {}, alignment = 'order' },
        ["pttg_kislev"] = { faction = "pttg_ksl_kislev", subculture = "wh3_main_sc_ksl_kislev", mandatory_units = {}, units = {}, alignment = 'order' },
        ["pttg_chaos_dwarfs"] = { faction = "pttg_chd_chaos_dwarfs", subculture = "wh3_dlc23_sc_chd_chaos_dwarfs", mandatory_units = {}, units = {}, alignment = 'chaos' },
        ["pttg_cathay"] = { faction = "pttg_cth_cathay", subculture = "wh3_main_sc_cth_cathay", mandatory_units = {}, units = {}, alignment = 'order' },
    }
    for template, template_info in pairs(random) do
        pttg_battle_templates:add_template(
            template_info.category, template, template_info.faction,
            template_info.subculture, template_info.alignment,
            template_info.mandatory_units, template_info.units
        )
    end

    for template, template_info in pairs(elites) do
        pttg_battle_templates:add_template(
            template_info.category, template, template_info.faction,
            template_info.subculture, template_info.alignment,
            template_info.mandatory_units, template_info.units
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
