extern const int MIN_SCENARIO_ID = 101;

/* Ages */

extern const int DARK_AGE = 25;
extern const int FEUDAL_AGE = 26;
extern const int CASTLE_AGE = 27;
extern const int IMPERIAL_AGE = 28;

/* Age-up techs. Genie names mislead: 101 is "Middle Age" but grants Feudal. */

extern const int FEUDAL_AGE_TECH = 101;
extern const int CASTLE_AGE_TECH = 102;
extern const int IMPERIAL_AGE_TECH = 103;

/* cAttrSetState values. Float, because ints are not promoted in a call. */

extern const float STATE_DISABLE = 0.0;
extern const float STATE_ENABLE = 2.0;
extern const float STATE_DONE = 3.0;

/* cModifyTech cost attributes; no prelude constant exists */

extern const int TECH_ATTR_COST_FIRST = 0;
extern const int TECH_ATTR_COST_LAST = 3;

/* Binding a tech to this strips its effect, leaving the research action and nothing else. */

extern const int NOOP_EFFECT = 0;

/* Techs */

extern const int TECH_CAPACITY = 400;
extern const int TECH_ITEM_OFFSET = 3600;
extern const int TECH_SHADOW = 1181;

/* Techsanity */

extern const int TECHSANITY_NONE = 0;
extern const int TECHSANITY_UNITS = 1;
extern const int TECHSANITY_GENERIC = 2;
extern const int TECHSANITY_ALL = 3;

/* Tech Behavior */

extern const int BEHAVIOR_MUST_RESEARCH = 0;
extern const int BEHAVIOR_INSTANT = 1;

/* Lock Techs */

extern const int LOCK_ITEMS = 0;
extern const int LOCK_EFFECTS = 1;

/* Shuffle Unique Techs */

extern const int UNIQUES_UNSHUFFLED = 0;
extern const int UNIQUES_SHUFFLED = 1;
extern const int UNIQUES_SHUFFLED_EVERYWHERE = 2;

/* Existing Techs */

extern const int EXISTING_VANILLA = 0;
extern const int EXISTING_FIND_ITEMS = 1;
extern const int EXISTING_ONLY_FIND_UNITS = 2;
extern const int EXISTING_START_IN_DARK_AGE = 3;

/* Mercenary seats. 1180 is the victory tech and 1181 is Techsanity's effect donor, so these
   start above both. Buttons 11-14 are the pavilion's third row; victory sits at button 1. */

extern const int MERCENARY_SEAT_COUNT = 4;
extern const int MERCENARY_SEAT_TECH_FIRST = 1182;
extern const int MERCENARY_SEAT_BUTTON_FIRST = 11;
extern const int MERCENARY_SEAT_RESEARCH_CAP = 1000;

/* APavilion. The hub building, created by XS in every scenario: indestructible, colour-cycling,
   and the only UI surface the randomizer has. PAVILION_BUILDING moved here from the mercenary
   block above, which is where it used to sit. */

extern const int PAVILION_BUILDING = 624;
extern const int PAVILION_OWNER = 1;
extern const int PAVILION_VICTORY_TECH = 1180;
extern const int PAVILION_VICTORY_BUTTON = 1;
extern const int PAVILION_VICTORY_ICON = 107;

/* Spawn and muster are derived, never authored: two and six tiles out from the pavilion along
   its facing. That relationship holds in all twelve scenarios. */

extern const int PAVILION_SPAWN_OFFSET = 2;
extern const int PAVILION_MUSTER_OFFSET = 6;

/* Facing. With x and y, the whole of a scenario's pavilion layout. */

extern const int PAVILION_FACE_SE = 0;   // +y
extern const int PAVILION_FACE_NW = 1;   // -y
extern const int PAVILION_FACE_NE = 2;   // +x
extern const int PAVILION_FACE_SW = 3;   // -x

/* Engine colour ids as the scenario binaries store them: 0-based, one lower than the editor's
   list. Order matches the trigger chain this replaces. The base is unconfirmed - the guide
   documents cUnitColorId with a templating artifact and no value range - so read it back with
   xsGetUnitProperty once before trusting these. */

extern const int PAVILION_COLOR_COUNT = 6;
extern const int PAVILION_COLOR_RED = 1;
extern const int PAVILION_COLOR_GREEN = 2;
extern const int PAVILION_COLOR_PURPLE = 5;
extern const int PAVILION_COLOR_ORANGE = 7;
extern const int PAVILION_COLOR_BLUE = 0;
extern const int PAVILION_COLOR_YELLOW = 3;

/* Invulnerability Level (attribute 129) is a damage threshold, not a flag: a value > 0 is a
   multiplier of base HP, < 0 a fixed HP value. Float, because ints are not promoted in a call.
   cUnitDeletable's polarity is likewise unconfirmed; 0 is the assumption. */

extern const float PAVILION_INVULNERABILITY = 1.0;
extern const float PAVILION_DELETABLE = 0.0;

/* Building Ids */

// Always
extern const int WONDER = 276;
extern const int OUTPOST = 598;

// Economy
extern const int TOWN_CENTER_FOUNDATION = 621;
extern const int HOUSE = 70;
extern const int MILL = 68;
extern const int MINING_CAMP = 584;
extern const int LUMBER_CAMP = 562;
extern const int FARM = 50;
extern const int FISH_TRAP = 199;
extern const int DOCK = 45;

// Tech
extern const int MARKET = 84;
extern const int UNIVERSITY = 209;
extern const int BLACKSMITH = 103;
extern const int MONASTERY = 104;

//Military
extern const int BARRACKS = 12;
extern const int ARCHERY_RANGE = 87;
extern const int STABLE = 101;
extern const int SIEGE_WORKSHOP = 49;
extern const int CASTLE = 82;

//Defense
extern const int PALISADE_GATE = 792;
extern const int GATE = 487;
extern const int PALISADE_WALL = 72;
extern const int STONE_WALL = 117;
extern const int WATCH_TOWER = 79;
extern const int BOMBARD_TOWER = 236;

// Unique Econ
extern const int FOLWARK = 1734;
extern const int MULE_CART = 1808;
extern const int PASTURE = 1889;
extern const int HARBOR = 1189;
extern const int CARAVANSERAI = 1754;
extern const int FEITORIA = 1021;
extern const int SETTLEMENT = 2556;

// Unique Mil/Defense
extern const int FORTIFIED_CHURCH = 1806;
extern const int KREPOST = 1251;
extern const int DONJON = 1665;

// Town Centers and gates are a special case: the foundation must be disabled; here we
// keep the id for the town center and gates themselves.
extern const int townCenterId = 109;
extern const int gateAscendingId = 64;
extern const int gateAscendingOpenId = 78;
extern const int gateDescendingId = 91;
extern const int gateDescendingOpenId = 88;
extern const int gateHorizontalId = 659;
extern const int gateHorizontalOpenId = 661;
extern const int gateVerticalId = 667;
extern const int gateVerticalOpenId = 669;
extern const int palisadeGateAscendingId = 789;
extern const int palisadeGateAscendingOpenId = 790;
extern const int palisadeGateDescendingId = 793;
extern const int palisadeGateDescendingOpenId = 794;
extern const int palisadeGateHorizontalId = 797;
extern const int palisadeGateHorizontalOpenId = 798;
extern const int palisadeGateVerticalId = 801;
extern const int palisadeGateVerticalOpenId = 802;