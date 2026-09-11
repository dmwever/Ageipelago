include "./TechData.xs";

const int TECH_CAPACITY = 400;
const int TECH_ITEM_OFFSET = 3600;
const int SHADOW_CAPACITY = 40;
const int SCAN_CHUNK = 64;
const int NOOP_EFFECT = 0;
const int STALL_TICKS = 12;

const int TECHSANITY_NONE = 0;
const int TECHSANITY_UNITS = 1;
const int TECHSANITY_GENERIC = 2;
const int TECHSANITY_ALL = 3;

const int BEHAVIOR_MUST_RESEARCH = 0;
const int BEHAVIOR_INSTANT = 1;

const int LOCK_ITEMS = 0;
const int LOCK_EFFECTS = 1;

const int UNIQUES_NO = 0;
const int UNIQUES_YES = 1;
const int UNIQUES_EVERYWHERE = 2;

const int EXISTING_VANILLA = 0;
const int EXISTING_LOCK_TECHNOLOGIES = 1;
const int EXISTING_ONLY_LOCK_UNITS = 2;

const int TECH_ATTR_COST_FIRST = 0;
const int TECH_ATTR_COST_LAST = 3;

const int FEUDAL_AGE_TECH = 101;
const int CASTLE_AGE_TECH = 102;
const int IMPERIAL_AGE_TECH = 103;

const float STATE_DISABLE = 0.0;
const float STATE_ENABLE = 1.0;
const float STATE_DONE = 3.0;

int techItemIds = -1;
int techIds = -1;
int techEffects = -1;
int techCivs = -1;
int techUpgrades = -1;
int techUniques = -1;
int techNoEffects = -1;
int techAges = -1;

int techActive = -1;
int techHasItem = -1;
int techResearched = -1;
int techEffectDone = -1;
int techQueued = -1;
int techLocked = -1;
int techGranted = -1;

int techByItem = -1;
int techCount = 0;

int techShadowIds = -1;
int techShadowCount = 0;

int techQueue = -1;
int techQueueHead = 0;
int techQueueTail = 0;
int techQueueCount = 0;
int techQueueStalled = 0;

int techLive = -1;
int techLiveCount = 0;
int techScanCursor = 0;
bool techScanPending = false;
float techResearchCount = 0.0;

int techPending = -1;
int techPendingCount = 0;

bool techsanityReady = false;
int techVanillaAge = -1;

void addTech(int itemId = -1, int id = -1, int effectId = -1, int civ = -1,
             int isUpgrade = 0, int isUnique = 0, int age = 0) {
    if (techCount >= TECH_CAPACITY || id < 1) {
        return;
    }
    int offset = itemId - TECH_ITEM_OFFSET;
    if (offset < 0 || offset >= TECH_CAPACITY) {
        return;
    }
    xsArraySetInt(techItemIds, techCount, itemId);
    xsArraySetInt(techIds, techCount, id);
    xsArraySetInt(techEffects, techCount, effectId);
    xsArraySetInt(techCivs, techCount, civ);
    xsArraySetInt(techUpgrades, techCount, isUpgrade);
    xsArraySetInt(techUniques, techCount, isUnique);
    xsArraySetInt(techAges, techCount, age);
    if (effectId < 0) {
        xsArraySetInt(techNoEffects, techCount, 1);
    }
    else {
        xsArraySetInt(techNoEffects, techCount, 0);
    }
    xsArraySetInt(techByItem, offset, techCount);
    techCount = techCount + 1;
}

void addShadow(int id = -1) {
    if (techShadowCount >= SHADOW_CAPACITY || id < 1) {
        return;
    }
    xsArraySetInt(techShadowIds, techShadowCount, id);
    techShadowCount = techShadowCount + 1;
}

void LoadShadows() {
    addShadow(1181); addShadow(1182); addShadow(1183); addShadow(1184); addShadow(1185);
    addShadow(1186); addShadow(1187); addShadow(1188); addShadow(1189);
    addShadow(1240); addShadow(1241); addShadow(1242); addShadow(1243); addShadow(1244);
    addShadow(1245); addShadow(1246); addShadow(1247); addShadow(1248); addShadow(1249);
    addShadow(1340); addShadow(1341); addShadow(1342); addShadow(1343); addShadow(1344);
    addShadow(1345); addShadow(1346); addShadow(1347); addShadow(1348); addShadow(1349);
    addShadow(1500); addShadow(1501); addShadow(1502); addShadow(1503); addShadow(1504);
    addShadow(1505); addShadow(1506); addShadow(1507); addShadow(1508); addShadow(1509);
}

void SetVanillaAge(int age = -1) {
    techVanillaAge = age;
}

bool civCanResearch(int i = -1) {
    int c = xsArrayGetInt(techCivs, i);
    return (c == -1 || c == xsGetPlayerCivilization(1));
}

int lockModeFor(int i = -1) {
    if (xsArrayGetInt(techNoEffects, i) == 1) {
        return (LOCK_ITEMS);
    }
    return (AP_TS_LOCK);
}

bool effectIsDeferred(int i = -1) {
    if (AP_TS_UNIQUES != UNIQUES_YES) {
        return (false);
    }
    if (xsArrayGetInt(techUniques, i) == 0) {
        return (false);
    }
    return (civCanResearch(i) == false);
}

void sendTechCheck(int i = -1) {
    if (techPendingCount >= TECH_CAPACITY) {
        return;
    }
    int locationId = xsArrayGetInt(techItemIds, i);
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
    if (xsArrayGetInt(techQueued, i) == 1) {
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
    xsArraySetInt(techQueued, i, 1);
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
    xsArraySetInt(techQueued, i, 0);
    return (i);
}

void hardenShadows() {
    for (k = 0; < techShadowCount) {
        int sid = xsArrayGetInt(techShadowIds, k);
        xsEffectAmount(cModifyTech, sid, cAttrSetTime, 0.0, 1);
        for (c = TECH_ATTR_COST_FIRST; <= TECH_ATTR_COST_LAST) {
            xsEffectAmount(cModifyTech, sid, c, 0.0, 1);
        }
        xsEffectAmount(cModifyTech, sid, cAttrSetLocation, 0.0 - 1.0, 1);
        xsEffectAmount(cModifyTech, sid, cAttrSetButton, 0.0, 1);
        xsEffectAmount(cModifyTech, sid, cAttrSetStacking, 1.0, 1);
        xsEffectAmount(cModifyTech, sid, cAttrSetStackingResearchCap, 1.0 * TECH_CAPACITY, 1);
        xsEffectAmount(cModifyTech, sid, cAttrSetState, STATE_ENABLE, 1);
    }
}

void applyViaShadow(int i = -1, int shadowId = -1) {
    float effect = 1.0 * xsArrayGetInt(techEffects, i);
    xsEffectAmount(cModifyTech, shadowId, cAttrSetState, STATE_ENABLE, 1);
    xsEffectAmount(cModifyTech, shadowId, cAttrSetEffect, effect, 1);
    xsEffectAmount(cModifyTech, shadowId, cAttrSetState, STATE_DONE, 1);
}

void pumpEffects() {
    if (techQueueCount == 0) {
        techQueueStalled = 0;
        return;
    }
    if (techShadowCount == 0) {
        return;
    }
    int before = techQueueCount;
    for (k = 0; < techShadowCount) {
        if (techQueueCount > 0) {
            int i = dequeueEffect();
            if (i >= 0) {
                applyViaShadow(i, xsArrayGetInt(techShadowIds, k));
                xsArraySetInt(techEffectDone, i, 1);
            }
        }
    }
    if (techQueueCount >= before) {
        techQueueStalled = techQueueStalled + 1;
        if (techQueueStalled == STALL_TICKS) {
            xsChatData("<RED>Techsanity: effect queue is not draining.");
        }
    }
    else {
        techQueueStalled = 0;
    }
}

void tryApplyEffect(int i = -1) {
    if (xsArrayGetInt(techEffectDone, i) == 1) {
        return;
    }
    if (xsArrayGetInt(techQueued, i) == 1) {
        return;
    }
    if (xsArrayGetInt(techGranted, i) == 1) {
        return;
    }
    if (xsArrayGetInt(techHasItem, i) == 0) {
        return;
    }
    if (xsArrayGetInt(techNoEffects, i) == 1) {
        return;
    }
    bool mustResearch = (AP_TS_BEHAVIOR == BEHAVIOR_MUST_RESEARCH)
                     || (xsArrayGetInt(techUpgrades, i) == 1);
    if (mustResearch && xsArrayGetInt(techResearched, i) == 0) {
        return;
    }
    if (effectIsDeferred(i)) {
        return;
    }
    enqueueEffect(i);
}

void stripTech(int i = -1) {
    xsEffectAmount(cModifyTech, xsArrayGetInt(techIds, i), cAttrSetEffect, 1.0 * NOOP_EFFECT, 1);
}

void revealTech(int i = -1) {
    if (xsArrayGetInt(techLocked, i) == 0) {
        return;
    }
    xsEffectAmount(cModifyTech, xsArrayGetInt(techIds, i), cAttrSetState, STATE_ENABLE, 1);
    xsArraySetInt(techLocked, i, 0);
}

void clampAvailable(int i = -1) {
    if (xsArrayGetInt(techHasItem, i) == 1) {
        return;
    }
    if (xsArrayGetInt(techLocked, i) == 1) {
        return;
    }
    if (xsArrayGetInt(techGranted, i) == 1) {
        return;
    }
    if (xsGetTechState(xsArrayGetInt(techIds, i), 1) != cTechStateReady) {
        return;
    }
    xsEffectAmount(cModifyTech, xsArrayGetInt(techIds, i), cAttrSetState, STATE_DISABLE, 1);
    xsArraySetInt(techLocked, i, 1);
}

void onTechResearched(int i = -1) {
    if (xsArrayGetInt(techResearched, i) == 1) {
        return;
    }
    xsArraySetInt(techResearched, i, 1);
    if (xsArrayGetInt(techActive, i) == 1 && xsArrayGetInt(techGranted, i) == 0) {
        sendTechCheck(i);
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
    if (xsArrayGetInt(techHasItem, i) == 1) {
        return;
    }
    xsArraySetInt(techHasItem, i, 1);
    if (lockModeFor(i) == LOCK_ITEMS && xsArrayGetInt(techActive, i) == 1) {
        revealTech(i);
    }
    tryApplyEffect(i);
}

void initTech(int i = -1) {
    int id = xsArrayGetInt(techIds, i);
    if (id < 1) {
        return;
    }
    int state = xsGetTechState(id, 1);
    if (state == cTechStateInvalid) {
        return;
    }
    if (state == cTechStateDone) {
        xsArraySetInt(techResearched, i, 1);
        sendTechCheck(i);
        tryApplyEffect(i);
        return;
    }
    stripTech(i);
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
        if (xsArrayGetInt(techActive, i) == 1 && xsArrayGetInt(techAges, i) < vanillaAge) {
            bool hold = (AP_TS_EXISTING == EXISTING_ONLY_LOCK_UNITS)
                     && (xsArrayGetInt(techUpgrades, i) == 1);
            if (hold == false) {
                xsEffectAmount(cModifyTech, xsArrayGetInt(techIds, i), cAttrSetState, STATE_DONE, 1);
                xsArraySetInt(techGranted, i, 1);
            }
        }
    }
}

void InitTechsanityArrays() {
    techItemIds = xsArrayCreateInt(TECH_CAPACITY, -1, "ts-item-ids");
    techIds = xsArrayCreateInt(TECH_CAPACITY, -1, "ts-ids");
    techEffects = xsArrayCreateInt(TECH_CAPACITY, -1, "ts-effects");
    techCivs = xsArrayCreateInt(TECH_CAPACITY, -1, "ts-civs");
    techUpgrades = xsArrayCreateInt(TECH_CAPACITY, 0, "ts-upgrades");
    techUniques = xsArrayCreateInt(TECH_CAPACITY, 0, "ts-uniques");
    techNoEffects = xsArrayCreateInt(TECH_CAPACITY, 0, "ts-no-effects");
    techAges = xsArrayCreateInt(TECH_CAPACITY, 0, "ts-ages");

    techActive = xsArrayCreateInt(TECH_CAPACITY, 0, "ts-active");
    techHasItem = xsArrayCreateInt(TECH_CAPACITY, 0, "ts-has-item");
    techResearched = xsArrayCreateInt(TECH_CAPACITY, 0, "ts-researched");
    techEffectDone = xsArrayCreateInt(TECH_CAPACITY, 0, "ts-effect-done");
    techQueued = xsArrayCreateInt(TECH_CAPACITY, 0, "ts-queued");
    techLocked = xsArrayCreateInt(TECH_CAPACITY, 0, "ts-locked");
    techGranted = xsArrayCreateInt(TECH_CAPACITY, 0, "ts-granted");

    techByItem = xsArrayCreateInt(TECH_CAPACITY, -1, "ts-by-item");
    techShadowIds = xsArrayCreateInt(SHADOW_CAPACITY, -1, "ts-shadow-ids");
    techQueue = xsArrayCreateInt(TECH_CAPACITY, -1, "ts-queue");
    techLive = xsArrayCreateInt(TECH_CAPACITY, -1, "ts-live");
    techPending = xsArrayCreateInt(TECH_CAPACITY, -1, "ts-pending");
}

void InitTechsanity() {
    if (AP_TS_MODE == TECHSANITY_NONE) {
        return;
    }

    InitTechsanityArrays();
    LoadTechTable();
    LoadShadows();

    if (techCount == 0) {
        xsChatData("<RED>Techsanity is enabled but no techs are installed. Run /install for this seed.");
        return;
    }

    for (i = 0; < techCount) {
        if (civCanResearch(i)) {
            xsArraySetInt(techActive, i, 1);
        }
    }

    hardenShadows();
    reconstructStartingState();

    for (j = 0; < techCount) {
        if (xsArrayGetInt(techActive, j) == 1 && xsArrayGetInt(techGranted, j) == 0) {
            initTech(j);
        }
    }

    techsanityReady = true;
    techResearchCount = xsPlayerAttribute(1, cAttributeResearchCount);
    xsEnableRule("TechsanityChecks");
    xsEnableRule("TechsanityWatchdog");
}

void GiveStartupTechs() {
    bool opened = xsOpenFile("techs");
    if (opened == false) {
        return;
    }
    int itemCount = xsGetFileSize() / 4; // byte to int
    for (i = 0; < itemCount) {
        UnlockTech(xsReadInt() - TECH_ITEM_OFFSET);
    }
    bool closed = xsCloseFile();
}

rule TechsanityChecks
    inactive
    group Techsanity
    highFrequency
{
    if (techsanityReady == false) {
        return;
    }
    float researched = xsPlayerAttribute(1, cAttributeResearchCount);
    if (researched > techResearchCount) {
        techResearchCount = researched;
        techScanPending = true;
        techScanCursor = 0;
    }
    if (techScanPending == false) {
        return;
    }
    int budget = SCAN_CHUNK;
    while (budget > 0 && techScanCursor < techLiveCount) {
        int i = xsArrayGetInt(techLive, techScanCursor);
        if (xsGetTechState(xsArrayGetInt(techIds, i), 1) == cTechStateDone) {
            onTechResearched(i);
            liveRemoveAt(techScanCursor);
        }
        else {
            techScanCursor = techScanCursor + 1;
        }
        budget = budget - 1;
    }
    if (techScanCursor >= techLiveCount) {
        techScanPending = false;
        techScanCursor = 0;
    }
}

rule TechsanityWatchdog
    inactive
    minInterval 2
    maxInterval 3
{
    if (techsanityReady == false) {
        return;
    }
    for (k = 0; < techLiveCount) {
        clampAvailable(xsArrayGetInt(techLive, k));
    }
    pumpEffects();
}
