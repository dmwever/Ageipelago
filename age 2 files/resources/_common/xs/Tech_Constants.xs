extern const int TECH_CAPACITY = 400;
extern const int TECH_ITEM_OFFSET = 3600;
extern const int TECH_SHADOW = 1181;
extern const int NOOP_EFFECT = 0;

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
extern const int EXISTING_LOCK_TECHNOLOGIES = 1;
extern const int EXISTING_ONLY_LOCK_UNITS = 2;

/* cModifyTech cost attributes; no prelude constant exists */

extern const int TECH_ATTR_COST_FIRST = 0;
extern const int TECH_ATTR_COST_LAST = 3;

/* Age-up techs. Genie names mislead: 101 is "Middle Age" but grants Feudal. */

extern const int FEUDAL_AGE_TECH = 101;
extern const int CASTLE_AGE_TECH = 102;
extern const int IMPERIAL_AGE_TECH = 103;

/* cAttrSetState values. Float, because ints are not promoted in a call. */

extern const float STATE_DISABLE = 0.0;
extern const float STATE_ENABLE = 1.0;
extern const float STATE_DONE = 3.0;
