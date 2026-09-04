include "structs.xs";

const int feudal_age = 101;
const int castle_age = 102;
const int imperial_age = 103;
const int ri_wheel_barrow = 213;
const int ri_hand_cart = 249;
const int ri_double_bit_axe = 202;
const int ri_bow_saw = 203;
const int ri_two_man_saw = 221;
const int ri_gold_mining = 55;
const int ri_stone_mining = 278;
const int ri_gold_shaft_mining = 182;
const int ri_stone_shaft_mining = 279;
const int ri_horse_collar = 14;
const int ri_heavy_plow = 13;
const int ri_crop_rotation = 12;
const int ri_domestication = 1014;
const int ri_pastoralism = 1013;
const int ri_transhumance = 1012;
const int ri_cartography = 19;
const int ri_caravan = 48;
const int ri_coinage = 23;
const int ri_banking = 17;
const int ri_guilds = 15;
const int ri_loom = 22;
const int ri_town_watch = 8;
const int ri_town_patrol = 280;
const int ri_herbalMedicine = 441;
const int ri_hoardings = 379;
const int ri_spies = 408;
const int ri_fortified_wall = 194;
const int ri_guard_tower = 140;
const int ri_keep = 63;
const int ri_bombard_tower = 64;
const int ri_ballistics = 93;
const int ri_heated_shot = 380;
const int ri_masonry = 50;
const int ri_murder_holes = 322;
const int ri_treadmill_crane = 54;
const int ri_architecture = 51;
const int ri_arrowslits = 608;
const int ri_chemistry = 47;
const int ri_siege_engineers = 377;
const int ri_careening = 374;
const int ri_dry_dock = 375;
const int ri_shipwright = 373;
const int ri_clinkerConstruction = 908;
const int ri_carvelHull = 907;
const int ri_siphons = 909;
const int ri_incentiaries = 910;
const int ri_war_galley = 34;               // = medium Warships
const int ri_galleon = 35;                  // = heavy Warships
const int ri_demolitionShip = 905;
const int ri_heavyDemolitionShip = 244;
const int ri_elite_cannon_galleon = 376;
const int ri_elite_caravel = 597;
const int ri_elite_longboat = 372;
const int ri_elite_turtle_ship = 488;
const int ri_fishingLines = 906;            // also disable with Economy
const int ri_gillnets = 65;                 // also disable with Economy
const int ri_forging = 67;
const int ri_iron_casting = 68;
const int ri_blast_furnace = 75;
const int ri_fletching = 199;               // also disable with Navy and Defenses
const int ri_bodkin_arrow = 200;            // also disable with Navy and Defenses
const int ri_bracer = 201;                  // also disable with Navy and Defenses
const int ri_scale_mail = 74;
const int ri_chain_mail = 76;
const int ri_plate_mail = 77;
const int ri_padded_archer_armor = 211;
const int ri_leather_archer_armor = 212;
const int ri_ring_archer_armor = 219;
const int ri_scale_barding = 81;
const int ri_chain_barding = 82;
const int ri_plate_barding = 80;
const int ri_crossbowman = 100;
const int ri_arbalester = 237;
const int ri_elite_skirmisher = 98;
const int ri_imperial_skirmisher = 655;
const int ri_heavy_cavalry_archer = 218;
const int ri_elite_genitour = 599;
const int ri_elite_elephant_archer = 481;
const int ri_eliteBolasRider = 1378;
const int ri_thumb_ring = 437;
const int ri_parthian_tactics = 436;
const int ri_man_at_arms = 222;
const int ri_long_swordsman = 207;
const int ri_two_handed_swordsmen = 217;
const int ri_champion = 264;
const int ri_legionary = 885;
const int ri_pikeman = 197;
const int ri_halberdier = 429;
const int ri_champiRunner = 1402;
const int ri_champiWarrior = 1351;
const int ri_eliteChampiWarrior = 1352;
const int ri_eagle_warrior = 384;
const int ri_elite_eagle_warrior = 434;
const int ri_eliteFireLancer = 982;
const int ri_eliteIbirapemaWarrior = 1391;
const int ri_eliteTempleGuard = 1401;
const int ri_eliteWarDog = 1387;
const int ri_gambersons = 875;
const int ri_squires = 215;
const int ri_arson = 602;
const int ri_light_cavalry = 254;
const int ri_hussar = 428;
const int ri_winged_hussar = 786;
const int ri_cavalier = 209;
const int ri_paladin = 265;
const int ri_savar = 526;
const int ri_heavy_camel_rider = 236;
const int ri_imperial_camel_rider = 521;
const int ri_elite_battle_elephant = 631;
const int ri_elite_steppe_lancer = 715;
const int ri_eliteHeiGuangCavalry = 1033;
const int ri_elite_shrivamsha_rider = 843;
const int ri_bloodlines = 435;
const int ri_husbandry = 39;
const int ri_capped_ram = 96;
const int ri_siege_ram = 255;
const int ri_siege_elephant = 838;
const int ri_onager = 257;
const int ri_siege_onager = 320;
const int ri_heavyRocketCart = 980;
const int ri_heavy_scorpion = 239;
const int ri_bombard_cannon = 188;
const int ri_houfnice = 787;
const int ri_atonement = 319;
const int ri_fervor = 252;
const int ri_heresy = 439;
const int ri_redemption = 316;
const int ri_sanctity = 231;
const int ri_devotion = 46;
const int ri_faith = 45;
const int ri_block_printing = 230;
const int ri_illumination = 233;
const int ri_theocracy = 438;
const int ri_conscription = -1;
const int ri_sappers = -1;
const int ri_elite_composite_bowman = 918;
const int ri_elite_jaguar_warrior = 432;
const int ri_elite_ratha = 828;
const int ri_elite_camel_archer = 565;
const int ri_elite_longbowman = 360;
const int ri_elite_hussite_wagon = 781;
const int ri_elite_konnik = 678;
const int ri_elite_coustillier = 751;
const int ri_elite_arambai = 619;
const int ri_elite_cataphract = 361;
const int ri_elite_woad_raider = 370;
const int ri_elite_chu_ko_nu = 362;
const int ri_elite_kipchak = 682;
const int ri_elite_urumi_swordsman = 826;
const int ri_elite_shotel = 569;
const int ri_elite_throwing_axeman = 363;
const int ri_elite_monaspa = 920;
const int ri_elite_huskarl = 365;
const int ri_elite_chakram_thrower = 830;
const int ri_elite_ghulam = 840;
const int ri_elite_tarkan = 2;
const int ri_elite_kamayuk = 509;
const int ri_elite_genoese_crossbowman = 468;
const int ri_elite_samurai = 366;
const int ri_elite_iron_pagoda = 991;
const int ri_elite_liao_dao = 1002;
const int ri_elite_ballista_elephant = 615;
const int ri_elite_war_wagon = 450;
const int ri_elite_leitis = 684;
const int ri_elite_magyar_huszar = 472;
const int ri_elite_karambit_warrior = 617;
const int ri_elite_gbeto = 567;
const int ri_elite_plumed_archer = 27;
const int ri_elite_mangudai = 371;
const int ri_elite_war_elephant = 367;
const int ri_elite_obuch = 779;
const int ri_elite_organ_gun = 563;
const int ri_elite_centurion = 882;
const int ri_elite_mameluke = 368;
const int ri_elite_white_feather_guard = 1064;
const int ri_elite_serjeant = 753;
const int ri_elite_boyar = 504;
const int ri_elite_conquistador = 60;
const int ri_elite_keshik = 680;
const int ri_elite_teutonic_knight = 364;
const int ri_elite_janissary = 369;
const int ri_elite_rattan_archer = 621;
const int ri_elite_berserk = 398;
const int ri_elite_tiger_cavalry = 1036;
const int ri_elite_fire_archer = 1074;
const int ri_eliteQizilbashWarrior = -1;            // Not listed
const int ri_eliteBlackwoodArcher = 1389;
const int ri_eliteKona = 1376;
const int ri_eliteGuechaWarrior = -1;               // Not Listed
const int ri_cilician_fleet = 922;
const int ri_fereters = 921;
const int ri_atlatl = 460;
const int ri_garlandWars = 24;
const int ri_paiks = 833;
const int ri_mahayana = 834;
const int ri_kasbah = 578;
const int ri_maghrebi_camels = 579;
const int ri_wagenburg_tactics = 784;
const int ri_hussite_reforms = 785;
const int ri_yeomen = 3;
const int ri_warwolf = 461;
const int ri_stirrups = 685;
const int ri_bagains = 686;
const int ri_burgundian_vineyards = 754;
const int ri_flemish_revolution = 755;
const int ri_manipur_cavalry = 627;
const int ri_howdah = 626;
const int ri_greek_fire = 464;
const int ri_logistica = 61;
const int ri_stronghold = 482;
const int ri_furorCeltica = 5;
const int ri_great_wall = 462;
const int ri_rocketry = 52;
const int ri_steppe_husbandry = 689;
const int ri_cuman_mercenaries = 690;
const int ri_medical_corps = 831;
const int ri_wootz_steel = 832;
const int ri_royal_heirs = 574;
const int ri_torsion_engines = 575;
const int ri_beardedAxe = 83;
const int ri_chivalry = 493;
const int ri_svan_towers = 923;
const int ri_aznauri_cavalry = 924;
const int ri_anarchy = 16;
const int ri_perfusion = 457;
const int ri_kshatriyas = 835;
const int ri_frontier_guards = 836;
const int ri_grand_trunk_road = 506;
const int ri_shatagni = 507;
const int ri_marauders = 483;
const int ri_atheism = 21;
const int ri_andean_sling = 516;
const int ri_fabric_shields = 517;
const int ri_pavise = 494;
const int ri_silk_road = 499;
const int ri_yasama = 484;
const int ri_kataparuto = 59;
const int ri_fortified_bastions = 996;
const int ri_thunderclap_bombs = 997;
const int ri_lamellar_armor = 1006;
const int ri_ordo_cavalry = 1007;
const int ri_tusk_swords = 622;
const int ri_double_crossbow = 623;
const int ri_eupseong = 486;
const int ri_shinkichon = 445;
const int ri_hill_forts = 691;
const int ri_tower_shields = 692;
const int ri_corvinian_army = 514;
const int ri_recurve_bow = 515;
const int ri_thalassocracy = 624;
const int ri_forced_levy = 625;
const int ri_tigui = 576;
const int ri_farimba = 577;
const int ri_malon = 1379;
const int ri_butalmapu = 1380;
const int ri_hulcheJavelineers = 485;
const int ri_elDorado = 4;
const int ri_nomads = 487;
const int ri_drill = 6;
const int ri_herbalism = 1365;
const int ri_huaracas = 1366;
const int ri_kamandaran = 488;
const int ri_citadels = 7;
const int ri_szlachta_privileges = 782;
const int ri_lechitic_legacy = 783;
const int ri_circumnavigation = 1404;
const int ri_arquebus = 573;
const int ri_ballistas = 883;
const int ri_comitatenses = 884;
const int ri_bimaristan = 28;
const int ri_counterweights = 454;
const int ri_bolt_magazine = 1069;
const int ri_coiled_serpent_array = 1070;
const int ri_first_crusade = 756;
const int ri_hauberk = 757;
const int ri_detinets = 455;
const int ri_druzhina = 513;
const int ri_inquisition = 492;
const int ri_supremacy = 440;
const int ri_silk_armor = 687;
const int ri_timurid_siegecraft = 688;
const int ri_ironclad = 489;
const int ri_crenellations = 11;
const int ri_caciques = 1392;
const int ri_curare = 1393;
const int ri_sipahi = 491;
const int ri_artillery = 10;
const int ri_chatras = 628;
const int ri_paper_money = 629;
const int ri_chieftains = 463;
const int ri_bogsveigar = 49;
const int ri_tuntian = 1061;
const int ri_ming_guang_armor = 1062;
const int ri_red_cliffs_tactics = 1080;
const int ri_sitting_tiger = 1081;

vector techsanity = cInvalidVector;

void InitTechsanityStructs() {
    defineStruct("Tech");
    defineStructAttribute("Tech", "name", TYPE_STRING);
    defineStructAttribute("Tech", "id", TYPE_INT);
    defineStructAttribute("Tech", "effectId", TYPE_INT);
    defineStructAttribute("Tech", "");
    defineStructAttribute("Tech", "locationId", TYPE_INT);

    defineStruct("Techsanity");
    defineStructAttribute("Techsanity", "techs", TYPE_STRUCT_ARRAY);
    defineStructAttribute("Techsanity", "techsLocked", TYPE_BOOL);
    defineStructAttribute("Techsanity", "mustResearchForEffect", TYPE_BOOL);

    techsanity = new("Techsanity");
    int techs = xsArrayCreateVector(350, cInvalidVector, "p1_techs");
    structSetInt(techsanity, "techs", techs);
}


void InitTechsanity() {
    InitTechsanityStructs();
    CreateLocations();
    xsEnableRule("TechsanityChecks");
}

void revealTech(vector tech = cInvalidVector) {
    int id = structGetInt(tech, "id");
    xsEffectAmount(cSetAttribute, id, cDisabledFlag, 0.0, 1);
}

void activateTechEffect(vector tech = cInvalidVector) {
    
}

void unlockTech(vector tech = cInvalidVector) {
    if (structGetBool(techsanity, "mustResearchForEffect") == false) {
        activateTechEffect(tech);
    }
    revealTech(tech);
}

void ReceiveTech(int index = -1) {
    int techs = structGetInt(techsanity, "techs");

    vector tech = xsArrayGetVector(techs, index);
    if (structGetBool(techsanity, "techsLocked")) {
        unlockTech(tech);
    }
    else {
        unlockEffect(tech);
    }
}