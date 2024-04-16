local pttg = core:get_static_object("pttg");

local pttg_tele = {
    distance_upper_bound=6
}

local regions = {
    "wh3_dlc20_combi_region_dragons_death",
    "wh3_dlc20_combi_region_glacial_gardens",
    "wh3_dlc20_combi_region_glacier_encampment",
    "wh3_dlc20_combi_region_krudenwald",
    "wh3_dlc23_combi_region_blasted_expanse",
    "wh3_dlc23_combi_region_fort_dorznye_vort",
    "wh3_dlc23_combi_region_gash_kadrak",
    "wh3_dlc23_combi_region_river_ruin",
    "wh3_dlc23_combi_region_uzkulak_port",
    "wh3_main_combi_region_aarnau",
    "wh3_main_combi_region_agrul_migdhal",
    "wh3_main_combi_region_akendorf",
    "wh3_main_combi_region_al_haikk",
    "wh3_main_combi_region_altar_of_facades",
    "wh3_main_combi_region_altar_of_spawns",
    "wh3_main_combi_region_altar_of_the_crimson_harvest",
    "wh3_main_combi_region_altar_of_the_horned_rat",
    "wh3_main_combi_region_altar_of_ultimate_darkness",
    "wh3_main_combi_region_altdorf",
    "wh3_main_combi_region_amblepeak",
    "wh3_main_combi_region_ancient_city_of_quintex",
    "wh3_main_combi_region_angerrial",
    "wh3_main_combi_region_antoch",
    "wh3_main_combi_region_aquitaine",
    "wh3_main_combi_region_argalis",
    "wh3_main_combi_region_arnheim",
    "wh3_main_combi_region_ash_ridge_mountains",
    "wh3_main_combi_region_ashrak",
    "wh3_main_combi_region_averheim",
    "wh3_main_combi_region_avethir",
    "wh3_main_combi_region_axlotl",
    "wh3_main_combi_region_baleful_hills",
    "wh3_main_combi_region_bamboo_crossing",
    "wh3_main_combi_region_barag_dawazbag",
    "wh3_main_combi_region_barak_varr",
    "wh3_main_combi_region_bay_of_blades",
    "wh3_main_combi_region_bechafen",
    "wh3_main_combi_region_beichai",
    "wh3_main_combi_region_bhagar",
    "wh3_main_combi_region_bilbali",
    "wh3_main_combi_region_bilious_cliffs",
    "wh3_main_combi_region_bitter_bay",
    "wh3_main_combi_region_bitterstone_mine",
    "wh3_main_combi_region_black_crag",
    "wh3_main_combi_region_black_creek_spire",
    "wh3_main_combi_region_black_fang",
    "wh3_main_combi_region_black_fortress",
    "wh3_main_combi_region_black_iron_mine",
    "wh3_main_combi_region_black_pyramid_of_nagash",
    "wh3_main_combi_region_black_rock",
    "wh3_main_combi_region_black_tower_of_arkhan",
    "wh3_main_combi_region_blacklight_tower",
    "wh3_main_combi_region_blackstone_post",
    "wh3_main_combi_region_bleak_hold_fortress",
    "wh3_main_combi_region_blizzardpeak",
    "wh3_main_combi_region_blood_mountain",
    "wh3_main_combi_region_bloodpeak",
    "wh3_main_combi_region_bloodwind_keep",
    "wh3_main_combi_region_blue_river",
    "wh3_main_combi_region_bordeleaux",
    "wh3_main_combi_region_brass_keep",
    "wh3_main_combi_region_bridge_of_heaven",
    "wh3_main_combi_region_brionne",
    "wh3_main_combi_region_cairn_thel",
    "wh3_main_combi_region_carroburg",
    "wh3_main_combi_region_castle_alexandronov",
    "wh3_main_combi_region_castle_artois",
    "wh3_main_combi_region_castle_bastonne",
    "wh3_main_combi_region_castle_carcassonne",
    "wh3_main_combi_region_castle_drakenhof",
    "wh3_main_combi_region_castle_of_splendour",
    "wh3_main_combi_region_castle_templehof",
    "wh3_main_combi_region_castle_von_rauken",
    "wh3_main_combi_region_caverns_of_sotek",
    "wh3_main_combi_region_celestial_lake",
    "wh3_main_combi_region_celestial_monastery",
    "wh3_main_combi_region_chamber_of_visions",
    "wh3_main_combi_region_chaos_wasteland",
    "wh3_main_combi_region_chaqua",
    "wh3_main_combi_region_chill_road",
    "wh3_main_combi_region_chimai",
    "wh3_main_combi_region_chupayotl",
    "wh3_main_combi_region_circle_of_destruction",
    "wh3_main_combi_region_citadel_of_dusk",
    "wh3_main_combi_region_citadel_of_lead",
    "wh3_main_combi_region_city_of_the_shugengan",
    "wh3_main_combi_region_clar_karond",
    "wh3_main_combi_region_clarak_spire",
    "wh3_main_combi_region_cliff_of_beasts",
    "wh3_main_combi_region_copher",
    "wh3_main_combi_region_couronne",
    "wh3_main_combi_region_crag_halls_of_findol",
    "wh3_main_combi_region_cragroth_deep",
    "wh3_main_combi_region_crookback_mountain",
    "wh3_main_combi_region_crooked_fang_fort",
    "wh3_main_combi_region_crucible_of_delights",
    "wh3_main_combi_region_cuexotl",
    "wh3_main_combi_region_daemons_gate",
    "wh3_main_combi_region_daemons_landing",
    "wh3_main_combi_region_dagraks_end",
    "wh3_main_combi_region_dai_cheng",
    "wh3_main_combi_region_dargoth",
    "wh3_main_combi_region_darkhold",
    "wh3_main_combi_region_dawns_light",
    "wh3_main_combi_region_deaths_head_monoliths",
    "wh3_main_combi_region_deff_gorge",
    "wh3_main_combi_region_desolation_of_drakenmoor",
    "wh3_main_combi_region_desolation_of_nagash",
    "wh3_main_combi_region_dietershafen",
    "wh3_main_combi_region_dok_karaz",
    "wh3_main_combi_region_doom_glade",
    "wh3_main_combi_region_doomkeep",
    "wh3_main_combi_region_dotternbach",
    "wh3_main_combi_region_drackla_spire",
    "wh3_main_combi_region_dragon_fang_mount",
    "wh3_main_combi_region_dragon_gate",
    "wh3_main_combi_region_dragonhorn_mines",
    "wh3_main_combi_region_dragons_crossroad",
    "wh3_main_combi_region_dread_rock",
    "wh3_main_combi_region_dringorackaz",
    "wh3_main_combi_region_dusk_peaks",
    "wh3_main_combi_region_eagle_eyries",
    "wh3_main_combi_region_eagle_gate",
    "wh3_main_combi_region_eastern_sea_of_dread",
    "wh3_main_combi_region_eilhart",
    "wh3_main_combi_region_ekrund",
    "wh3_main_combi_region_el_kalabad",
    "wh3_main_combi_region_eldar_spire",
    "wh3_main_combi_region_elessaeli",
    "wh3_main_combi_region_elisia",
    "wh3_main_combi_region_erengrad",
    "wh3_main_combi_region_eschen",
    "wh3_main_combi_region_essen",
    "wh3_main_combi_region_evershale",
    "wh3_main_combi_region_eye_of_the_panther",
    "wh3_main_combi_region_fallen_gates",
    "wh3_main_combi_region_fallen_king_mountain",
    "wh3_main_combi_region_fateweavers_crevasse",
    "wh3_main_combi_region_fire_mouth",
    "wh3_main_combi_region_flayed_rock",
    "wh3_main_combi_region_flensburg",
    "wh3_main_combi_region_floating_mountain",
    "wh3_main_combi_region_floating_pyramid",
    "wh3_main_combi_region_floating_village",
    "wh3_main_combi_region_forest_of_arnheim",
    "wh3_main_combi_region_forest_of_gloom",
    "wh3_main_combi_region_fort_bergbres",
    "wh3_main_combi_region_fort_jakova",
    "wh3_main_combi_region_fort_oberstyre",
    "wh3_main_combi_region_fort_ostrosk",
    "wh3_main_combi_region_fort_soll",
    "wh3_main_combi_region_fort_straghov",
    "wh3_main_combi_region_fortress_of_dawn",
    "wh3_main_combi_region_fortress_of_eyes",
    "wh3_main_combi_region_fortress_of_the_damned",
    "wh3_main_combi_region_foundry_of_bones",
    "wh3_main_combi_region_frozen_landing",
    "wh3_main_combi_region_frozen_sea",
    "wh3_main_combi_region_fu_chow",
    "wh3_main_combi_region_fu_hung",
    "wh3_main_combi_region_fuming_serpent",
    "wh3_main_combi_region_fyrus",
    "wh3_main_combi_region_gaean_vale",
    "wh3_main_combi_region_galbaraz",
    "wh3_main_combi_region_ghrond",
    "wh3_main_combi_region_gisoreux",
    "wh3_main_combi_region_gnashraks_lair",
    "wh3_main_combi_region_gnobbly_gorge",
    "wh3_main_combi_region_golden_ziggurat",
    "wh3_main_combi_region_gor_gazan",
    "wh3_main_combi_region_gorger_rock",
    "wh3_main_combi_region_gorssel",
    "wh3_main_combi_region_graeling_moot",
    "wh3_main_combi_region_granite_massif",
    "wh3_main_combi_region_granite_spikes",
    "wh3_main_combi_region_great_canal",
    "wh3_main_combi_region_great_desert_of_araby",
    "wh3_main_combi_region_great_hall_of_greasus",
    "wh3_main_combi_region_great_river",
    "wh3_main_combi_region_great_skull_lakes",
    "wh3_main_combi_region_great_turtle_isle",
    "wh3_main_combi_region_grenzstadt",
    "wh3_main_combi_region_grey_rock_point",
    "wh3_main_combi_region_griffon_gate",
    "wh3_main_combi_region_grimhold",
    "wh3_main_combi_region_grimtop",
    "wh3_main_combi_region_gristle_valley",
    "wh3_main_combi_region_grom_peak",
    "wh3_main_combi_region_gronti_mingol",
    "wh3_main_combi_region_grotrilexs_glare_lighthouse",
    "wh3_main_combi_region_grunburg",
    "wh3_main_combi_region_grung_zint",
    "wh3_main_combi_region_gryphon_wood",
    "wh3_main_combi_region_gulf_of_kislev",
    "wh3_main_combi_region_gulf_of_medes",
    "wh3_main_combi_region_hag_graef",
    "wh3_main_combi_region_hag_hall",
    "wh3_main_combi_region_haichai",
    "wh3_main_combi_region_hanyu_port",
    "wh3_main_combi_region_har_ganeth",
    "wh3_main_combi_region_har_kaldra",
    "wh3_main_combi_region_hell_pit",
    "wh3_main_combi_region_helmgart",
    "wh3_main_combi_region_hergig",
    "wh3_main_combi_region_hexoatl",
    "wh3_main_combi_region_hoteks_column",
    "wh3_main_combi_region_howling_rock",
    "wh3_main_combi_region_hualotal",
    "wh3_main_combi_region_ice_rock_gorge",
    "wh3_main_combi_region_icespewer",
    "wh3_main_combi_region_igerov",
    "wh3_main_combi_region_infernius",
    "wh3_main_combi_region_iron_rock",
    "wh3_main_combi_region_iron_storm",
    "wh3_main_combi_region_ironfrost",
    "wh3_main_combi_region_ironspike",
    "wh3_main_combi_region_isle_of_the_crimson_skull",
    "wh3_main_combi_region_isle_of_wights",
    "wh3_main_combi_region_itza",
    "wh3_main_combi_region_jade_river",
    "wh3_main_combi_region_jade_wind_mountain",
    "wh3_main_combi_region_jungles_of_chian",
    "wh3_main_combi_region_ka_sabar",
    "wh3_main_combi_region_kaiax",
    "wh3_main_combi_region_kappelburg",
    "wh3_main_combi_region_karag_dromar",
    "wh3_main_combi_region_karag_dron",
    "wh3_main_combi_region_karag_orrud",
    "wh3_main_combi_region_karak_angazhar",
    "wh3_main_combi_region_karak_azgal",
    "wh3_main_combi_region_karak_azgaraz",
    "wh3_main_combi_region_karak_azorn",
    "wh3_main_combi_region_karak_azul",
    "wh3_main_combi_region_karak_bhufdar",
    "wh3_main_combi_region_karak_dum",
    "wh3_main_combi_region_karak_eight_peaks",
    "wh3_main_combi_region_karak_hirn",
    "wh3_main_combi_region_karak_izor",
    "wh3_main_combi_region_karak_kadrin",
    "wh3_main_combi_region_karak_krakaten",
    "wh3_main_combi_region_karak_norn",
    "wh3_main_combi_region_karak_raziak",
    "wh3_main_combi_region_karak_ungor",
    "wh3_main_combi_region_karak_vlag",
    "wh3_main_combi_region_karak_vrag",
    "wh3_main_combi_region_karak_ziflin",
    "wh3_main_combi_region_karak_zorn",
    "wh3_main_combi_region_karaz_a_karak",
    "wh3_main_combi_region_karond_kar",
    "wh3_main_combi_region_kauark",
    "wh3_main_combi_region_kemperbad",
    "wh3_main_combi_region_khazid_bordkarag",
    "wh3_main_combi_region_khazid_irkulaz",
    "wh3_main_combi_region_khemri",
    "wh3_main_combi_region_khymerica_spire",
    "wh3_main_combi_region_kings_glade",
    "wh3_main_combi_region_kislev",
    "wh3_main_combi_region_konquata",
    "wh3_main_combi_region_kradtommen",
    "wh3_main_combi_region_kraka_drak",
    "wh3_main_combi_region_kraken_sea",
    "wh3_main_combi_region_krugenheim",
    "wh3_main_combi_region_kunlan",
    "wh3_main_combi_region_lahmia",
    "wh3_main_combi_region_lake",
    "wh3_main_combi_region_languille",
    "wh3_main_combi_region_lashiek",
    "wh3_main_combi_region_laurelorn_forest",
    "wh3_main_combi_region_li_temple",
    "wh3_main_combi_region_li_zhu",
    "wh3_main_combi_region_lizard_sea",
    "wh3_main_combi_region_longship_graveyard",
    "wh3_main_combi_region_lost_plateau",
    "wh3_main_combi_region_lothern",
    "wh3_main_combi_region_luccini",
    "wh3_main_combi_region_lybaras",
    "wh3_main_combi_region_lyonesse",
    "wh3_main_combi_region_macu_peaks",
    "wh3_main_combi_region_magritta",
    "wh3_main_combi_region_mahrak",
    "wh3_main_combi_region_mangrove_coast",
    "wh3_main_combi_region_mangrove_coast_sea",
    "wh3_main_combi_region_marienburg",
    "wh3_main_combi_region_marks_of_the_old_ones",
    "wh3_main_combi_region_martek",
    "wh3_main_combi_region_massif_orcal",
    "wh3_main_combi_region_matorca",
    "wh3_main_combi_region_middenheim",
    "wh3_main_combi_region_middenstag",
    "wh3_main_combi_region_middle_sea",
    "wh3_main_combi_region_mighdal_vongalbarak",
    "wh3_main_combi_region_mine_of_the_bearded_skulls",
    "wh3_main_combi_region_ming_zhu",
    "wh3_main_combi_region_miragliano",
    "wh3_main_combi_region_mistnar",
    "wh3_main_combi_region_misty_mountain",
    "wh3_main_combi_region_monolith_of_borkill_the_bloody_handed",
    "wh3_main_combi_region_monolith_of_bubonicus",
    "wh3_main_combi_region_monolith_of_festerlung",
    "wh3_main_combi_region_monolith_of_flesh",
    "wh3_main_combi_region_montenas",
    "wh3_main_combi_region_montfort",
    "wh3_main_combi_region_monument_of_izzatal",
    "wh3_main_combi_region_monument_of_the_moon",
    "wh3_main_combi_region_mordheim",
    "wh3_main_combi_region_morgheim",
    "wh3_main_combi_region_mount_arachnos",
    "wh3_main_combi_region_mount_athull",
    "wh3_main_combi_region_mount_grey_hag",
    "wh3_main_combi_region_mount_gunbad",
    "wh3_main_combi_region_mount_silverspear",
    "wh3_main_combi_region_mount_squighorn",
    "wh3_main_combi_region_mount_thug",
    "wh3_main_combi_region_mousillon",
    "wh3_main_combi_region_myrmidens",
    "wh3_main_combi_region_nagashizzar",
    "wh3_main_combi_region_nagenhof",
    "wh3_main_combi_region_naggarond",
    "wh3_main_combi_region_naglfari_plain",
    "wh3_main_combi_region_nagrar",
    "wh3_main_combi_region_nahuontl",
    "wh3_main_combi_region_nan_gau",
    "wh3_main_combi_region_nan_li",
    "wh3_main_combi_region_niedling",
    "wh3_main_combi_region_nonchang",
    "wh3_main_combi_region_norden",
    "wh3_main_combi_region_northern_sea_of_chaos",
    "wh3_main_combi_region_northern_straits_of_the_great_ocean",
    "wh3_main_combi_region_northern_straits_of_the_jade_sea",
    "wh3_main_combi_region_novchozy",
    "wh3_main_combi_region_nuja",
    "wh3_main_combi_region_nuln",
    "wh3_main_combi_region_numas",
    "wh3_main_combi_region_oakenhammer",
    "wh3_main_combi_region_okkams_forever_maze",
    "wh3_main_combi_region_oreons_camp",
    "wh3_main_combi_region_oyxl",
    "wh3_main_combi_region_pack_ice_bay",
    "wh3_main_combi_region_pahuax",
    "wh3_main_combi_region_palace_of_princes",
    "wh3_main_combi_region_parravon",
    "wh3_main_combi_region_petrified_forest",
    "wh3_main_combi_region_pfeildorf",
    "wh3_main_combi_region_phoenix_gate",
    "wh3_main_combi_region_pigbarter",
    "wh3_main_combi_region_pillar_of_skulls",
    "wh3_main_combi_region_pillars_of_unseen_constellations",
    "wh3_main_combi_region_plain_of_dogs",
    "wh3_main_combi_region_plain_of_spiders",
    "wh3_main_combi_region_plain_of_tuskers",
    "wh3_main_combi_region_plesk",
    "wh3_main_combi_region_po_mei",
    "wh3_main_combi_region_pools_of_despair",
    "wh3_main_combi_region_port_elistor",
    "wh3_main_combi_region_port_of_secrets",
    "wh3_main_combi_region_port_reaver",
    "wh3_main_combi_region_pox_marsh",
    "wh3_main_combi_region_praag",
    "wh3_main_combi_region_qiang",
    "wh3_main_combi_region_quatar",
    "wh3_main_combi_region_quenelles",
    "wh3_main_combi_region_quetza",
    "wh3_main_combi_region_quittax",
    "wh3_main_combi_region_rackdo_gorge",
    "wh3_main_combi_region_rasetra",
    "wh3_main_combi_region_red_fortress",
    "wh3_main_combi_region_red_river",
    "wh3_main_combi_region_riffraffa",
    "wh3_main_combi_region_river_reik",
    "wh3_main_combi_region_rothkar_spire",
    "wh3_main_combi_region_ruins_end",
    "wh3_main_combi_region_sabre_mountain",
    "wh3_main_combi_region_salzenmund",
    "wh3_main_combi_region_sarl_encampment",
    "wh3_main_combi_region_sartosa",
    "wh3_main_combi_region_scarpels_lair",
    "wh3_main_combi_region_scorpion_coast",
    "wh3_main_combi_region_sea_of_chill",
    "wh3_main_combi_region_sea_of_claws",
    "wh3_main_combi_region_sea_of_malice",
    "wh3_main_combi_region_sea_of_serpents",
    "wh3_main_combi_region_sea_of_squalls",
    "wh3_main_combi_region_sea_of_storms",
    "wh3_main_combi_region_sentinels_of_xeti",
    "wh3_main_combi_region_serpent_coast",
    "wh3_main_combi_region_serpent_coast_sea",
    "wh3_main_combi_region_serpent_jetty",
    "wh3_main_combi_region_serpent_river",
    "wh3_main_combi_region_shagrath",
    "wh3_main_combi_region_shang_wu",
    "wh3_main_combi_region_shang_yang",
    "wh3_main_combi_region_shard_bastion",
    "wh3_main_combi_region_shark_straights",
    "wh3_main_combi_region_shattered_cove",
    "wh3_main_combi_region_shattered_stone_isle",
    "wh3_main_combi_region_shi_long",
    "wh3_main_combi_region_shi_wu",
    "wh3_main_combi_region_shifting_isles",
    "wh3_main_combi_region_shifting_mangrove_coastline",
    "wh3_main_combi_region_shiyamas_rest",
    "wh3_main_combi_region_shrine_of_asuryan",
    "wh3_main_combi_region_shrine_of_khaine",
    "wh3_main_combi_region_shrine_of_kurnous",
    "wh3_main_combi_region_shrine_of_ladrielle",
    "wh3_main_combi_region_shrine_of_loec",
    "wh3_main_combi_region_shrine_of_sotek",
    "wh3_main_combi_region_shrine_of_the_alchemist",
    "wh3_main_combi_region_shroktak_mount",
    "wh3_main_combi_region_silver_pinnacle",
    "wh3_main_combi_region_sjoktraken",
    "wh3_main_combi_region_skavenblight",
    "wh3_main_combi_region_skeggi",
    "wh3_main_combi_region_skrap_towers",
    "wh3_main_combi_region_slavers_point",
    "wh3_main_combi_region_snake_gate",
    "wh3_main_combi_region_sorcerers_islands",
    "wh3_main_combi_region_soteks_trail",
    "wh3_main_combi_region_southern_sea_of_chaos",
    "wh3_main_combi_region_spektazuma",
    "wh3_main_combi_region_spite_reach",
    "wh3_main_combi_region_spitepeak",
    "wh3_main_combi_region_springs_of_eternal_life",
    "wh3_main_combi_region_ssildra_tor",
    "wh3_main_combi_region_statues_of_the_gods",
    "wh3_main_combi_region_steingart",
    "wh3_main_combi_region_stonemine_tower",
    "wh3_main_combi_region_storag_kor",
    "wh3_main_combi_region_stormhenge",
    "wh3_main_combi_region_stormvrack_mount",
    "wh3_main_combi_region_straights_of_chaos",
    "wh3_main_combi_region_straits_of_fear",
    "wh3_main_combi_region_straits_of_lothern",
    "wh3_main_combi_region_straits_of_nagash",
    "wh3_main_combi_region_subatuun",
    "wh3_main_combi_region_sudenburg",
    "wh3_main_combi_region_sulpharets",
    "wh3_main_combi_region_sump_pit",
    "wh3_main_combi_region_sun_tree_glades",
    "wh3_main_combi_region_sunken_khernarch",
    "wh3_main_combi_region_sunken_lands",
    "wh3_main_combi_region_swamp_town",
    "wh3_main_combi_region_swartzhafen",
    "wh3_main_combi_region_tai_tzu",
    "wh3_main_combi_region_talabheim",
    "wh3_main_combi_region_tarantula_coast",
    "wh3_main_combi_region_temple_avenue_of_gold",
    "wh3_main_combi_region_temple_of_addaioth",
    "wh3_main_combi_region_temple_of_elemental_winds",
    "wh3_main_combi_region_temple_of_heimkel",
    "wh3_main_combi_region_temple_of_kara",
    "wh3_main_combi_region_temple_of_khaine",
    "wh3_main_combi_region_temple_of_skulls",
    "wh3_main_combi_region_temple_of_tlencan",
    "wh3_main_combi_region_teotiqua",
    "wh3_main_combi_region_terracotta_graveyard",
    "wh3_main_combi_region_the_albion_channel",
    "wh3_main_combi_region_the_awakening",
    "wh3_main_combi_region_the_bitter_sea",
    "wh3_main_combi_region_the_black_forests",
    "wh3_main_combi_region_the_black_gulf",
    "wh3_main_combi_region_the_black_pillar",
    "wh3_main_combi_region_the_black_pit",
    "wh3_main_combi_region_the_bleak_coast",
    "wh3_main_combi_region_the_bleeding_spire",
    "wh3_main_combi_region_the_blighted_grove",
    "wh3_main_combi_region_the_blood_hall",
    "wh3_main_combi_region_the_blood_swamps",
    "wh3_main_combi_region_the_boiling_sea",
    "wh3_main_combi_region_the_bone_gulch",
    "wh3_main_combi_region_the_broken_lands",
    "wh3_main_combi_region_the_burning_monolith",
    "wh3_main_combi_region_the_challenge_stone",
    "wh3_main_combi_region_the_churning_gulf",
    "wh3_main_combi_region_the_copper_landing",
    "wh3_main_combi_region_the_crystal_spires",
    "wh3_main_combi_region_the_cursed_jungle",
    "wh3_main_combi_region_the_daemonium_coast",
    "wh3_main_combi_region_the_daemons_stump",
    "wh3_main_combi_region_the_dust_gate",
    "wh3_main_combi_region_the_eastern_isles",
    "wh3_main_combi_region_the_estalia_coastline",
    "wh3_main_combi_region_the_falls_of_doom",
    "wh3_main_combi_region_the_far_sea",
    "wh3_main_combi_region_the_fetid_catacombs",
    "wh3_main_combi_region_the_folly_of_malofex",
    "wh3_main_combi_region_the_forbidden_citadel",
    "wh3_main_combi_region_the_forbidding_coast",
    "wh3_main_combi_region_the_forest_of_decay",
    "wh3_main_combi_region_the_fortress_of_vorag",
    "wh3_main_combi_region_the_frozen_city",
    "wh3_main_combi_region_the_galleons_graveyard",
    "wh3_main_combi_region_the_galleons_graveyard_sea",
    "wh3_main_combi_region_the_gallows_tree",
    "wh3_main_combi_region_the_gates_of_zharr",
    "wh3_main_combi_region_the_godless_crater",
    "wh3_main_combi_region_the_golden_colossus",
    "wh3_main_combi_region_the_golden_tower",
    "wh3_main_combi_region_the_great_arena",
    "wh3_main_combi_region_the_great_ocean_north",
    "wh3_main_combi_region_the_great_ocean_south",
    "wh3_main_combi_region_the_haunted_forest",
    "wh3_main_combi_region_the_high_place",
    "wh3_main_combi_region_the_high_sentinel",
    "wh3_main_combi_region_the_howling_citadel",
    "wh3_main_combi_region_the_inner_sea",
    "wh3_main_combi_region_the_iron_coast",
    "wh3_main_combi_region_the_isles",
    "wh3_main_combi_region_the_jade_sea",
    "wh3_main_combi_region_the_lost_palace",
    "wh3_main_combi_region_the_lustria_straight",
    "wh3_main_combi_region_the_maw_gate",
    "wh3_main_combi_region_the_mistnar_crossing",
    "wh3_main_combi_region_the_monolith_of_katam",
    "wh3_main_combi_region_the_monoliths",
    "wh3_main_combi_region_the_moon_shard",
    "wh3_main_combi_region_the_moot",
    "wh3_main_combi_region_the_never_ending_chasm",
    "wh3_main_combi_region_the_oak_of_ages",
    "wh3_main_combi_region_the_palace_of_ruin",
    "wh3_main_combi_region_the_pillars_of_grungni",
    "wh3_main_combi_region_the_pirate_coast",
    "wh3_main_combi_region_the_sacred_pools",
    "wh3_main_combi_region_the_sea_of_dread",
    "wh3_main_combi_region_the_sentinel_of_time",
    "wh3_main_combi_region_the_sentinels",
    "wh3_main_combi_region_the_shard_coast",
    "wh3_main_combi_region_the_silvered_tower_of_sorcerers",
    "wh3_main_combi_region_the_sinhall_monolith",
    "wh3_main_combi_region_the_skull_carvers_abode",
    "wh3_main_combi_region_the_southern_sentinels",
    "wh3_main_combi_region_the_southern_straits",
    "wh3_main_combi_region_the_star_tower",
    "wh3_main_combi_region_the_tower_of_flies",
    "wh3_main_combi_region_the_tower_of_khrakk",
    "wh3_main_combi_region_the_tower_of_torment",
    "wh3_main_combi_region_the_turtle_shallows",
    "wh3_main_combi_region_the_twisted_glade",
    "wh3_main_combi_region_the_twisted_towers",
    "wh3_main_combi_region_the_vampire_coast_sea",
    "wh3_main_combi_region_the_volary",
    "wh3_main_combi_region_the_witchwood",
    "wh3_main_combi_region_the_writhing_fortress",
    "wh3_main_combi_region_thrice_cursed_peak",
    "wh3_main_combi_region_tilean_sea",
    "wh3_main_combi_region_titans_notch",
    "wh3_main_combi_region_tlanxla",
    "wh3_main_combi_region_tlaqua",
    "wh3_main_combi_region_tlax",
    "wh3_main_combi_region_tlaxtlan",
    "wh3_main_combi_region_tobaro",
    "wh3_main_combi_region_tor_achare",
    "wh3_main_combi_region_tor_anlec",
    "wh3_main_combi_region_tor_anroc",
    "wh3_main_combi_region_tor_dranil",
    "wh3_main_combi_region_tor_elasor",
    "wh3_main_combi_region_tor_elyr",
    "wh3_main_combi_region_tor_finu",
    "wh3_main_combi_region_tor_koruali",
    "wh3_main_combi_region_tor_saroir",
    "wh3_main_combi_region_tor_sethai",
    "wh3_main_combi_region_tor_surpindar",
    "wh3_main_combi_region_tor_yvresse",
    "wh3_main_combi_region_tower_of_ashung",
    "wh3_main_combi_region_tower_of_gorgoth",
    "wh3_main_combi_region_tower_of_lysean",
    "wh3_main_combi_region_tower_of_the_stars",
    "wh3_main_combi_region_tower_of_the_sun",
    "wh3_main_combi_region_tralinia",
    "wh3_main_combi_region_tribeslaughter",
    "wh3_main_combi_region_troll_fjord",
    "wh3_main_combi_region_turtle_gate",
    "wh3_main_combi_region_tyrant_peak",
    "wh3_main_combi_region_ubersreik",
    "wh3_main_combi_region_unicorn_gate",
    "wh3_main_combi_region_uzkulak",
    "wh3_main_combi_region_valayas_sorrow",
    "wh3_main_combi_region_vale_of_titans",
    "wh3_main_combi_region_valley_of_horns",
    "wh3_main_combi_region_varenka_hills",
    "wh3_main_combi_region_varg_camp",
    "wh3_main_combi_region_vauls_anvil_loren",
    "wh3_main_combi_region_vauls_anvil_naggaroth",
    "wh3_main_combi_region_vauls_anvil_ulthuan",
    "wh3_main_combi_region_venom_glade",
    "wh3_main_combi_region_verdanos",
    "wh3_main_combi_region_village_of_the_moon",
    "wh3_main_combi_region_village_of_the_tigermen",
    "wh3_main_combi_region_vitevo",
    "wh3_main_combi_region_volcanos_heart",
    "wh3_main_combi_region_volksgrad",
    "wh3_main_combi_region_volulltrax",
    "wh3_main_combi_region_vulture_mountain",
    "wh3_main_combi_region_waili_village",
    "wh3_main_combi_region_waldenhof",
    "wh3_main_combi_region_waterfall_palace",
    "wh3_main_combi_region_wei_jin",
    "wh3_main_combi_region_weismund",
    "wh3_main_combi_region_wellsprings_of_eternity",
    "wh3_main_combi_region_weng_chang",
    "wh3_main_combi_region_white_tower_of_hoeth",
    "wh3_main_combi_region_whitefire_tor",
    "wh3_main_combi_region_whitepeak",
    "wh3_main_combi_region_winter_pyre",
    "wh3_main_combi_region_wissenburg",
    "wh3_main_combi_region_witch_sea",
    "wh3_main_combi_region_wizard_caliphs_palace",
    "wh3_main_combi_region_wolfenburg",
    "wh3_main_combi_region_worlds_edge_archway",
    "wh3_main_combi_region_worm_coast",
    "wh3_main_combi_region_wreckers_point",
    "wh3_main_combi_region_wurtbad",
    "wh3_main_combi_region_xahutec",
    "wh3_main_combi_region_xen_wu",
    "wh3_main_combi_region_xhotl",
    "wh3_main_combi_region_xing_po",
    "wh3_main_combi_region_xlanhuapec",
    "wh3_main_combi_region_xlanzec",
    "wh3_main_combi_region_yetchitch",
    "wh3_main_combi_region_yhetee_peak",
    "wh3_main_combi_region_yuatek",
    "wh3_main_combi_region_zanbaijin",
    "wh3_main_combi_region_zandri",
    "wh3_main_combi_region_zarakzil",
    "wh3_main_combi_region_zavastra",
    "wh3_main_combi_region_zhanshi",
    "wh3_main_combi_region_zharr_naggrund",
    "wh3_main_combi_region_zhizhu",
    "wh3_main_combi_region_zhufbar",
    "wh3_main_combi_region_ziggurat_of_dawn",
    "wh3_main_combi_region_zlatlan",
    "wh3_main_combi_region_zoishenk",
    "wh3_main_combi_region_zvorak"
}

local function get_random_region()
    local owner = nil
    local region
    while not owner do
        local random_region_name = regions[cm:random_number(#regions, 1)]
        region = cm:get_region_data(random_region_name):region()
        while not region do
            pttg:log(string.format("[pttg_teleporter] Trying again: No region data found for region: %s", random_region_name))
            region = cm:get_region_data(random_region_name):region()
        end
        if region.is_abandoned and not region:is_abandoned() then
            owner = region:owning_faction()
        elseif region.adjacent_region_list then
            pttg:log(string.format("[pttg_teleporter] No owning faction data for region: %s", random_region_name))
            for i = 0, region:adjacent_region_list():num_items()-1 do
                local neighbour = region:adjacent_region_list():item_at(i)
                if not neighbour:is_abandoned() then
                    cm:transfer_region_to_faction(random_region_name, neighbour:owning_faction():name())
                end
            end
        else
            pttg:log(string.format("[pttg_teleporter] Dud region %s", random_region_name))
        end
    end
    pttg:log(string.format("[pttg_teleporter] Random region %s with owner %s", region:name(), region:owning_faction():name()))
    return region
end

function pttg_tele:teleport_to_random_region(character, distance_upper_bound)
    at_war_with = {}
    warring_factions = cm:get_local_faction():factions_at_war_with()
    for i = 0, warring_factions:num_items()-1 do
        at_war_with[warring_factions:item_at(i):name()] = true
    end
    
    local x = -1
    local y = -1
    local random_region
    local distance
    
    while x == -1 do
        random_region = get_random_region()

        distance = cm:random_number(distance_upper_bound or self.distance_upper_bound,1)

        ---@diagnostic disable-next-line: cast-local-type
        x, y = cm:find_valid_spawn_location_for_character_from_settlement(cm:get_local_faction_name(), random_region:name(), false, true, distance)
    end
    pttg:log(string.format("[pttg_teleport][random_region] Teleporting to %s at %i, %i with a distance of %i.", random_region:name(), x, y, distance))

    local tele = cm:teleport_to(cm:char_lookup_str(character), x, y)
    
    pttg:log(string.format("[pttg_teleport][random_region] Teleported: %s.", tostring(tele)))
end

function pttg_tele:teleport_random_distance(character, distance_upper_bound)
    
    local x = -1
    local y = -1
    local distance
    while x == -1 do
        distance = cm:random_number(distance_upper_bound or (self.distance_upper_bound * 10), 1)
        ---@diagnostic disable-next-line: cast-local-type
        x, y = cm:find_valid_spawn_location_for_character_from_character(cm:get_local_faction_name(), cm:char_lookup_str(character:command_queue_index()), false, distance)
    end

    pttg:log(string.format("[pttg_teleport][random_distance] Teleporting to %i, %i for a distance of %i.", x, y, distance))

    local tele = cm:teleport_to(cm:char_lookup_str(character), x, y)

    pttg:log(string.format("[pttg_teleport][random_distance] Teleported: %s.", tostring(tele)))

end

core:add_static_object("pttg_tele", pttg_tele);