include "./Tech_Constants.xs";
include "./TechData.xs";

vector techsanity = cInvalidVector;
int techArray = -1;
int techCount = 0;

int techByItem = -1;

int techQueue = -1;
int techQueueHead = 0;
int techQueueTail = 0;
int techQueueCount = 0;

int techLive = -1;
int techLiveCount = 0;
float techResearchCount = 0.0;

int techPending = -1;
int techPendingCount = 0;

bool techsanityReady = false;
int techVanillaAge = -1;

vector techAt(int i = -1) {
    return (xsArrayGetVector(techArray, i));
}

void addTech(int itemId = -1, int id = -1, int effectId = -1, int civ = -1,
             int isUpgrade = 0, int isUnique = 0, int age = 0) {
    if (techCount >= TECH_CAPACITY || id < 1) {
        return;
    }
    int offset = itemId - TECH_ITEM_OFFSET;
    if (offset < 0 || offset >= TECH_CAPACITY) {
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
    structSetBool(tech, "hasItem", false);
    structSetBool(tech, "researched", false);
    structSetBool(tech, "effectDone", false);
    structSetBool(tech, "queued", false);
    structSetBool(tech, "locked", false);

    xsArraySetVector(techArray, techCount, tech);
    xsArraySetInt(techByItem, offset, techCount);
    techCount = techCount + 1;
}

void SetVanillaAge(int age = -1) {
    techVanillaAge = age;
}

bool hasNoEffect(vector tech = cInvalidVector) {
    return (structGetInt(tech, "effectId") < 0);
}

bool civCanResearch(vector tech = cInvalidVector) {
    int c = structGetInt(tech, "civ");
    return (c == -1 || c == xsGetPlayerCivilization(1));
}

int lockModeFor(vector tech = cInvalidVector) {
    if (hasNoEffect(tech)) {
        return (LOCK_ITEMS);
    }
    return (AP_TS_LOCK);
}

bool effectIsDeferred(vector tech = cInvalidVector) {
    if (AP_TS_UNIQUES != UNIQUES_YES) {
        return (false);
    }
    if (structGetBool(tech, "isUnique") == false) {
        return (false);
    }
    return (civCanResearch(tech) == false);
}

void sendTechCheck(vector tech = cInvalidVector) {
    if (techPendingCount >= TECH_CAPACITY) {
        return;
    }
    int locationId = structGetInt(tech, "itemId");
    for (k = 0; < techPendingCount) {
        if (xsArrayGetInt(techPending, k) == locationId) {
            return;
        }
    }
    xsArraySetInt(techPending, techPendingCount, locationId);
    techPendingCount = techPendingCount + 1;
}

int TechPendingCount() {
    return (techPendingCount);
}

int TechPendingAt(int k = -1) {
    if (k < 0 || k >= techPendingCount) {
        return (-1);
    }
    return (xsArrayGetInt(techPending, k));
}

bool IsTechLocation(int locationId = -1) {
    return (locationId >= TECH_ITEM_OFFSET && locationId < TECH_ITEM_OFFSET + TECH_CAPACITY);
}

void AckTechLocation(int locationId = -1) {
    for (k = 0; < techPendingCount) {
        if (xsArrayGetInt(techPending, k) == locationId) {
            xsArraySetInt(techPending, k, xsArrayGetInt(techPending, techPendingCount - 1));
            techPendingCount = techPendingCount - 1;
            return;
        }
    }
}

void liveAdd(int i = -1) {
    if (techLiveCount >= TECH_CAPACITY) {
        return;
    }
    xsArraySetInt(techLive, techLiveCount, i);
    techLiveCount = techLiveCount + 1;
}

void liveRemoveAt(int k = -1) {
    if (k < 0 || k >= techLiveCount) {
        return;
    }
    xsArraySetInt(techLive, k, xsArrayGetInt(techLive, techLiveCount - 1));
    techLiveCount = techLiveCount - 1;
}

void enqueueEffect(int i = -1) {
    vector tech = techAt(i);
    if (structGetBool(tech, "queued")) {
        return;
    }
    if (techQueueCount >= TECH_CAPACITY) {
        return;
    }
    xsArraySetInt(techQueue, techQueueTail, i);
    techQueueTail = techQueueTail + 1;
    if (techQueueTail >= TECH_CAPACITY) {
        techQueueTail = 0;
    }
    techQueueCount = techQueueCount + 1;
    structSetBool(tech, "queued", true);
}

int dequeueEffect() {
    if (techQueueCount == 0) {
        return (-1);
    }
    int i = xsArrayGetInt(techQueue, techQueueHead);
    techQueueHead = techQueueHead + 1;
    if (techQueueHead >= TECH_CAPACITY) {
        techQueueHead = 0;
    }
    techQueueCount = techQueueCount - 1;
    structSetBool(techAt(i), "queued", false);
    return (i);
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

void pumpEffects() {
    while (techQueueCount > 0) {
        int i = dequeueEffect();
        if (i >= 0) {
            vector tech = techAt(i);
            applyViaShadow(tech);
            structSetBool(tech, "effectDone", true);
        }
    }
}

void tryApplyEffect(int i = -1) {
    vector tech = techAt(i);
    if (structGetBool(tech, "effectDone")) {
        return;
    }
    if (structGetBool(tech, "queued")) {
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
    if (effectIsDeferred(tech)) {
        return;
    }
    enqueueEffect(i);
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

void clampAvailable(int i = -1) {
    vector tech = techAt(i);
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

void onTechResearched(int i = -1) {
    vector tech = techAt(i);
    if (structGetBool(tech, "researched")) {
        return;
    }
    structSetBool(tech, "researched", true);
    if (civCanResearch(tech)) {
        sendTechCheck(tech);
    }
    tryApplyEffect(i);
}

void UnlockTech(int itemOffset = -1) {
    if (itemOffset < 0 || itemOffset >= TECH_CAPACITY) {
        return;
    }
    int i = xsArrayGetInt(techByItem, itemOffset);
    if (i < 0 || i >= techCount) {
        return;
    }
    vector tech = techAt(i);
    if (structGetBool(tech, "hasItem")) {
        return;
    }
    structSetBool(tech, "hasItem", true);
    if (lockModeFor(tech) == LOCK_ITEMS && civCanResearch(tech)) {
        revealTech(tech);
    }
    tryApplyEffect(i);
}

void initTech(int i = -1) {
    vector tech = techAt(i);
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
        sendTechCheck(tech);
        tryApplyEffect(i);
        return;
    }
    stripTech(tech);
    liveAdd(i);
}

void reconstructStartingState() {
    int vanillaAge = techVanillaAge;
    if (vanillaAge < 0) {
        xsChatData("<RED>Techsanity: this scenario never called SetVanillaAge; assuming Dark Age.");
        vanillaAge = DARK_AGE;
    }
    if (vanillaAge >= 1) {
        xsEffectAmount(cModifyTech, FEUDAL_AGE_TECH, cAttrSetState, STATE_DONE, 1);
    }
    if (vanillaAge >= 2) {
        xsEffectAmount(cModifyTech, CASTLE_AGE_TECH, cAttrSetState, STATE_DONE, 1);
    }
    if (vanillaAge >= 3) {
        xsEffectAmount(cModifyTech, IMPERIAL_AGE_TECH, cAttrSetState, STATE_DONE, 1);
    }
    if (AP_TS_EXISTING == EXISTING_LOCK_TECHNOLOGIES) {
        return;
    }
    for (i = 0; < techCount) {
        vector tech = techAt(i);
        if (civCanResearch(tech) && structGetInt(tech, "age") < vanillaAge) {
            bool hold = (AP_TS_EXISTING == EXISTING_ONLY_LOCK_UNITS)
                     && structGetBool(tech, "isUpgrade");
            if (hold == false) {
                xsEffectAmount(cModifyTech, structGetInt(tech, "id"), cAttrSetState, STATE_DONE, 1);
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
    defineStructAttribute("Tech", "hasItem", TYPE_BOOL);
    defineStructAttribute("Tech", "researched", TYPE_BOOL);
    defineStructAttribute("Tech", "effectDone", TYPE_BOOL);
    defineStructAttribute("Tech", "queued", TYPE_BOOL);
    defineStructAttribute("Tech", "locked", TYPE_BOOL);

    defineStruct("Techsanity");
    defineStructAttribute("Techsanity", "techs", TYPE_STRUCT_ARRAY);

    techsanity = new("Techsanity");
    techArray = xsArrayCreateVector(TECH_CAPACITY, cInvalidVector, "ts-techs");
    structSetInt(techsanity, "techs", techArray);

    techByItem = xsArrayCreateInt(TECH_CAPACITY, -1, "ts-by-item");
    techQueue = xsArrayCreateInt(TECH_CAPACITY, -1, "ts-queue");
    techLive = xsArrayCreateInt(TECH_CAPACITY, -1, "ts-live");
    techPending = xsArrayCreateInt(TECH_CAPACITY, -1, "ts-pending");
}

void InitTechsanity() {
    if (AP_TS_MODE == TECHSANITY_NONE) {
        return;
    }

    InitTechsanityStructs();
    LoadTechTable();

    if (techCount == 0) {
        xsChatData("<RED>Techsanity is enabled but no techs are installed. Run /install for this seed.");
        return;
    }

    hardenShadow();
    reconstructStartingState();

    for (j = 0; < techCount) {
        vector tech = techAt(j);
        if (civCanResearch(tech) && structGetBool(tech, "researched") == false) {
            initTech(j);
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
        int k = 0;
        while (k < techLiveCount) {
            int i = xsArrayGetInt(techLive, k);
            if (xsGetTechState(structGetInt(techAt(i), "id"), 1) == cTechStateDone) {
                onTechResearched(i);
                liveRemoveAt(k);
            }
            else {
                k = k + 1;
            }
        }
    }

    for (c = 0; < techLiveCount) {
        clampAvailable(xsArrayGetInt(techLive, c));
    }

    pumpEffects();
}
