include "./Tech_Constants.xs";
include "./TechData.xs";

vector techsanity = cInvalidVector;
int techArray = -1;
int techCount = 0;

int techByItem = -1;

float techResearchCount = 0.0;

bool techsanityReady = false;

vector getTech(int i = -1) {
    return (xsArrayGetVector(techArray, i));
}

void addTech(int itemId = -1, int id = -1, int effectId = -1, int civ = -1,
             int isUpgrade = 0, int isUnique = 0, int age = 0, int isLocation = 1) {
    if (techCount >= TECH_CAPACITY || id < 1) {
        return;
    }
    int offset = itemId - TECH_ITEM_OFFSET;
    if (isLocation == 1 && (offset < 0 || offset >= TECH_CAPACITY)) {
        return;
    }
    vector tech = new("Tech");
    if (tech == cInvalidVector) {
        xsChatData("<RED>Techsanity: out of Tech struct instances, dropping tech " + id);
        return;
    }
    structSetInt(tech, "itemId", itemId);
    structSetInt(tech, "id", id);
    structSetInt(tech, "effectId", effectId);
    structSetInt(tech, "civ", civ);
    structSetInt(tech, "age", age);
    structSetBool(tech, "isUpgrade", isUpgrade == 1);
    structSetBool(tech, "isUnique", isUnique == 1);
    structSetBool(tech, "isLocation", isLocation == 1);
    structSetBool(tech, "hasItem", false);
    structSetBool(tech, "researched", false);
    structSetBool(tech, "effectDone", false);
    structSetBool(tech, "locked", false);

    xsArraySetVector(techArray, techCount, tech);
    if (isLocation == 1) {
        xsArraySetVector(techByItem, offset, tech);
    }
    techCount = techCount + 1;
}

bool hasNoEffect(vector tech = cInvalidVector) {
    return (structGetInt(tech, "effectId") < 0);
}

bool civCanResearch(vector tech = cInvalidVector) {
    int c = structGetInt(tech, "civ");
    return (c == -1 || c == xsGetPlayerCivilization(1));
}

bool deferEffect(vector tech = cInvalidVector) {
    if (AP_TS_UNIQUES == UNIQUES_UNSHUFFLED || AP_TS_UNIQUES == UNIQUES_SHUFFLED_EVERYWHERE) {
        return (false);
    }
    if (structGetBool(tech, "isUnique") == false) {
        return (false);
    }
    return (civCanResearch(tech) == false);
}

void hardenShadow() {
    if (xsGetTechState(TECH_SHADOW, 1) == cTechStateInvalid) {
        xsChatData("<RED>Techsanity: shadow tech " + TECH_SHADOW + " is unavailable, effects cannot be applied.");
        return;
    }
    xsEffectAmount(cModifyTech, TECH_SHADOW, cAttrSetTime, 0.0, 1);
    for (c = TECH_ATTR_COST_FIRST; <= TECH_ATTR_COST_LAST) {
        xsEffectAmount(cModifyTech, TECH_SHADOW, c, 0.0, 1);
    }
    xsEffectAmount(cModifyTech, TECH_SHADOW, cAttrSetLocation, 0.0 - 1.0, 1);
    xsEffectAmount(cModifyTech, TECH_SHADOW, cAttrSetButton, 0.0, 1);
    xsEffectAmount(cModifyTech, TECH_SHADOW, cAttrSetStacking, 1.0, 1);
    xsEffectAmount(cModifyTech, TECH_SHADOW, cAttrSetStackingResearchCap, 1.0 * TECH_CAPACITY, 1);
    xsEffectAmount(cModifyTech, TECH_SHADOW, cAttrSetState, STATE_ENABLE, 1);
}

void applyViaShadow(vector tech = cInvalidVector) {
    float effect = 1.0 * structGetInt(tech, "effectId");
    xsEffectAmount(cModifyTech, TECH_SHADOW, cAttrSetState, STATE_ENABLE, 1);
    xsEffectAmount(cModifyTech, TECH_SHADOW, cAttrSetEffect, effect, 1);
    xsEffectAmount(cModifyTech, TECH_SHADOW, cAttrSetState, STATE_DONE, 1);
}

void tryApplyEffect(vector tech = cInvalidVector) {
    if (structGetBool(tech, "effectDone")) {
        return;
    }
    if (structGetBool(tech, "hasItem") == false) {
        return;
    }
    if (hasNoEffect(tech)) {
        return;
    }
    bool mustResearch = (AP_TS_BEHAVIOR == BEHAVIOR_MUST_RESEARCH)
                     || structGetBool(tech, "isUpgrade");
    if (mustResearch && structGetBool(tech, "researched") == false) {
        return;
    }
    if (deferEffect(tech)) {
        return;
    }
    applyViaShadow(tech);
    structSetBool(tech, "effectDone", true);
}

void stripTech(vector tech = cInvalidVector) {
    xsEffectAmount(cModifyTech, structGetInt(tech, "id"), cAttrSetEffect, 1.0 * NOOP_EFFECT, 1);
}

void revealTech(vector tech = cInvalidVector) {
    if (structGetBool(tech, "locked") == false) {
        return;
    }
    xsEffectAmount(cModifyTech, structGetInt(tech, "id"), cAttrSetState, STATE_ENABLE, 1);
    structSetBool(tech, "locked", false);
}

void ensureLocked(vector tech = cInvalidVector) {
    if (structGetBool(tech, "hasItem")) {
        return;
    }
    if (structGetBool(tech, "locked")) {
        return;
    }
    int id = structGetInt(tech, "id");
    if (xsGetTechState(id, 1) != cTechStateReady) {
        return;
    }
    xsEffectAmount(cModifyTech, id, cAttrSetState, STATE_DISABLE, 1);
    structSetBool(tech, "locked", true);
}

void onTechResearched(vector tech = cInvalidVector) {
    if (structGetBool(tech, "researched")) {
        return;
    }
    structSetBool(tech, "researched", true);
    AP_Check_Location(structGetInt(tech, "itemId"));
    tryApplyEffect(tech);
}

void UnlockTech(int itemOffset = -1) {
    if (itemOffset < 0 || itemOffset >= TECH_CAPACITY) {
        return;
    }
    vector tech = xsArrayGetVector(techByItem, itemOffset);
    if (tech == cInvalidVector) {
        return;
    }
    if (structGetBool(tech, "hasItem")) {
        return;
    }
    structSetBool(tech, "hasItem", true);
    if (AP_TS_LOCK == LOCK_ITEMS && civCanResearch(tech)) {
        revealTech(tech);
    }
    tryApplyEffect(tech);
}

void initTech(vector tech = cInvalidVector) {
    int id = structGetInt(tech, "id");
    if (id < 1) {
        return;
    }
    int state = xsGetTechState(id, 1);
    if (state == cTechStateInvalid) {
        return;
    }
    if (state == cTechStateDone) {
        structSetBool(tech, "researched", true);
        structSetBool(tech, "effectDone", true);
        return;
    }
    stripTech(tech);
    AddLocation(structGetInt(tech, "itemId"));
}

void completeIfPending(int id = -1) {
    if (xsGetTechState(id, 1) == cTechStateDone) {
        return;
    }
    xsEffectAmount(cModifyTech, id, cAttrSetState, STATE_DONE, 1);
}

void reconstructStartingState(int vanillaAge = -1) {
    if (vanillaAge >= 1) {
        completeIfPending(FEUDAL_AGE_TECH);
    }
    if (vanillaAge >= 2) {
        completeIfPending(CASTLE_AGE_TECH);
    }
    if (vanillaAge >= 3) {
        completeIfPending(IMPERIAL_AGE_TECH);
    }
    for (i = 0; < techCount) {
        vector tech = getTech(i);
        if (civCanResearch(tech) && structGetInt(tech, "age") < vanillaAge) {
            bool grant = true;
            if (structGetBool(tech, "isLocation")) {
                if (AP_TS_EXISTING == EXISTING_LOCK_TECHNOLOGIES) {
                    grant = false;
                }
                if (AP_TS_EXISTING == EXISTING_ONLY_LOCK_UNITS
                 && structGetBool(tech, "isUpgrade")) {
                    grant = false;
                }
            }
            if (grant) {
                completeIfPending(structGetInt(tech, "id"));
                structSetBool(tech, "researched", true);
                structSetBool(tech, "effectDone", true);
            }
        }
    }
}

void InitTechsanityStructs() {
    defineStruct("Tech");
    defineStructAttribute("Tech", "itemId", TYPE_INT);
    defineStructAttribute("Tech", "id", TYPE_INT);
    defineStructAttribute("Tech", "effectId", TYPE_INT);
    defineStructAttribute("Tech", "civ", TYPE_INT);
    defineStructAttribute("Tech", "age", TYPE_INT);
    defineStructAttribute("Tech", "isUpgrade", TYPE_BOOL);
    defineStructAttribute("Tech", "isUnique", TYPE_BOOL);
    defineStructAttribute("Tech", "isLocation", TYPE_BOOL);
    defineStructAttribute("Tech", "hasItem", TYPE_BOOL);
    defineStructAttribute("Tech", "researched", TYPE_BOOL);
    defineStructAttribute("Tech", "effectDone", TYPE_BOOL);
    defineStructAttribute("Tech", "locked", TYPE_BOOL);

    defineStruct("Techsanity");
    defineStructAttribute("Techsanity", "techs", TYPE_STRUCT_ARRAY);

    techsanity = new("Techsanity");
    techArray = xsArrayCreateVector(TECH_CAPACITY, cInvalidVector, "ts-techs");
    structSetInt(techsanity, "techs", techArray);

    techByItem = xsArrayCreateVector(TECH_CAPACITY, cInvalidVector, "ts-by-item");
}

void InitTechsanity() {
    if (AP_TS_MODE == TECHSANITY_NONE) {
        return;
    }
    if (AP_TECH_SEED_HIGH != AP_SEED_HIGH || AP_TECH_SEED_LOW != AP_SEED_LOW) {
        xsChatData("<RED>Techsanity: tech data is from the wrong seed. Run /install in the Age 2 client.");
        return;
    }

    InitTechsanityStructs();
    LoadTechTable();

    if (techCount == 0) {
        xsChatData("<RED>Techsanity is enabled but no techs are installed. Run /install for this seed.");
        return;
    }

    hardenShadow();
    SetScenarioAge();

    for (j = 0; < techCount) {
        vector tech = getTech(j);
        if (structGetBool(tech, "isLocation") && civCanResearch(tech)
         && structGetBool(tech, "researched") == false) {
            initTech(tech);
        }
    }

    techsanityReady = true;
    techResearchCount = xsPlayerAttribute(1, cAttributeResearchCount);
    xsEnableRule("TechsanityUpdate");
}

rule TechsanityUpdate
    inactive
    group Techsanity
    minInterval 1
    maxInterval 1
{
    if (techsanityReady == false) {
        return;
    }

    float researched = xsPlayerAttribute(1, cAttributeResearchCount);
    if (researched > techResearchCount) {
        techResearchCount = researched;
        for (i = 0; < techCount) {
            vector tech = getTech(i);
            if (structGetBool(tech, "isLocation") &&
                structGetBool(tech, "researched") == false &&
                xsGetTechState(structGetInt(tech, "id"), 1) == cTechStateDone) {
                    onTechResearched(tech);
            }
        }
    }

    if (AP_TS_LOCK == LOCK_ITEMS) {
        for (i = 0; < techCount) {
            vector lockableTech = getTech(i);
            if (structGetBool(lockableTech, "isLocation")
             && structGetBool(lockableTech, "researched") == false) {
                ensureLocked(lockableTech);
            }
        }
    }
}
