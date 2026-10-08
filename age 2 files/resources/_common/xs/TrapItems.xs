int trapScan = -1;      // reused by every xsGetPlayerUnitIds sweep
int trapPool = -1;      // candidates collected out of a sweep, then partially shuffled
int enemyPool = -1;     // player numbers, never unit ids
int trapPoolCount = 0;
int trapTask = -1;      // one slot, reused for every xsTaskUnits call

int soundTrapUntil = -1;
int soundTrapWarned = 0;
int chatTrapUntil = -1;
int chatTrapLine = 0;
int idleTrapUntil = -1;
int raidTrapUntil = -1;
int raidTrapCorner = -1;   // never the same corner twice running

bool ooh = true;

void InitTraps() {
    trapScan = xsArrayCreateInt(1, -1, "ap-trap-scan");
    trapPool = xsArrayCreateInt(TRAP_SCAN_CAPACITY, -1, "ap-trap-pool");
    enemyPool = xsArrayCreateInt(9, -1, "ap-enemy-pool");
    trapTask = xsArrayCreateInt(1, -1, "ap-trap-task");
}

int TrapScale(int easiest = 0, int standard = 0, int medium = 0, int hard = 0, int legendary = 0) {
    if (AP_TRAP_DIFFICULTY == TRAP_DIFFICULTY_EASIEST) {
        return (easiest);
    }
    if (AP_TRAP_DIFFICULTY == TRAP_DIFFICULTY_STANDARD) {
        return (standard);
    }
    if (AP_TRAP_DIFFICULTY == TRAP_DIFFICULTY_MEDIUM) {
        return (medium);
    }
    if (AP_TRAP_DIFFICULTY == TRAP_DIFFICULTY_HARD) {
        return (hard);
    }
    if (AP_TRAP_DIFFICULTY == TRAP_DIFFICULTY_LEGENDARY) {
        return (legendary);
    }
    return (0);
}

int ExtendTrapTime(int until = -1, int seconds = 0) {
    int from = xsGetGameTime();
    if (until > from) {
        from = until;
    }
    return (from + seconds);
}

// --- victim selection -------------------------------------------------------------------------

int TRAP_MILITARY_CLASS_COUNT = 5;

int TrapMilitaryClassAt(int index = -1) {
    if (index == 0) { return (cInfantryClass); }
    if (index == 1) { return (cArcherClass); }
    if (index == 2) { return (cCavalryClass); }
    if (index == 3) { return (cCavalryArcherClass); }
    return (cSiegeWeaponClass);
}

void EmptyTrapPool() {
    trapPoolCount = 0;
}

bool IsHero(int unitId = -1) {
    int heroStatus = 1 * xsGetUnitAttribute(unitId, cHeroStatus, -1);
    return (heroStatus / 2 * 2 != heroStatus);
}

void AddToTrapPool(int unitId = -1) {
    if (unitId == -1 || trapPoolCount >= TRAP_SCAN_CAPACITY) {
        return;
    }
    if (IsHero(unitId)) {
        return;
    }
    xsArraySetInt(trapPool, trapPoolCount, unitId);
    trapPoolCount = trapPoolCount + 1;
}

void SelectPlayerUnitsByClass(int playerId = 1, int classId = -1) {
    int found = xsGetPlayerUnitIds(playerId, classId, trapScan);
    for (i = 0; < xsArrayGetSize(found)) {
        AddToTrapPool(xsArrayGetInt(found, i));
    }
}

void SelectPlayerMilitary(int playerId = 1) {
    EmptyTrapPool();
    for (c = 0; < TRAP_MILITARY_CLASS_COUNT) {
        SelectPlayerUnitsByClass(playerId, TrapMilitaryClassAt(c));
    }
}

void AddAnchorCandidate(int unitId = -1) {
    if (unitId == -1 || trapPoolCount >= TRAP_SCAN_CAPACITY) {
        return;
    }
    xsArraySetInt(trapPool, trapPoolCount, unitId);
    trapPoolCount = trapPoolCount + 1;
}

void SelectAnchorClass(int classId = -1) {
    int found = xsGetPlayerUnitIds(1, classId, trapScan);
    for (i = 0; < xsArrayGetSize(found)) {
        AddAnchorCandidate(xsArrayGetInt(found, i));
    }
}

void SelectAnchorCandidates() {
    EmptyTrapPool();
    for (c = 0; < TRAP_MILITARY_CLASS_COUNT) {
        SelectAnchorClass(TrapMilitaryClassAt(c));
    }
    SelectAnchorClass(cVillagerClass);
}

/* Partial Fisher-Yates: swap a random survivor into slot i, so the first `take` entries are a
   uniform sample with no repeats and no retry loop that could spin. */
int TakeCountFromPool(int take = 0) {
    if (take > trapPoolCount) {
        take = trapPoolCount;
    }
    for (i = 0; < take) {
        int j = i + xsGetRandomNumberMax(trapPoolCount - i);
        int held = xsArrayGetInt(trapPool, i);
        xsArraySetInt(trapPool, i, xsArrayGetInt(trapPool, j));
        xsArraySetInt(trapPool, j, held);
    }
    return (take);
}

int GetCountFromPercent(int count = 0, int percent = 0) {
    if (count <= 0 || percent <= 0) {
        return (0);
    }
    int take = count * percent / 100;
    if (take < 1) {
        take = 1;
    }
    if (take > count) {
        take = count;
    }
    return (take);
}

bool IsEnemy(int playerId = -1) {
    if (playerId == 1) {
        return (false);
    }
    if (xsGetPlayerInGame(playerId) == false) {
        return (false);
    }
    return (xsGetDiplomacy(1, playerId) == cDiplomacyEnemy);
}

int GetRandomEnemy() {
    int count = 0;
    for (p = 1; <= 8) {
        if (IsEnemy(p)) {
            xsArraySetInt(enemyPool, count, p);
            count = count + 1;
        }
    }
    if (count == 0) {
        return (-1);
    }
    return (xsArrayGetInt(enemyPool, xsGetRandomNumberMax(count)));
}

int TRAP_RESOURCE_COUNT = 4;

int TrapResourceAt(int index = -1) {
    if (index == 0) {
        return (cAttributeWood);
    }
    if (index == 1) {
        return (cAttributeFood);
    }
    if (index == 2) {
        return (cAttributeGold);
    }
    return (cAttributeStone);
}

// --- the traps --------------------------------------------------------------------------------

void TRAP_WOLOLO() {
    xsPlaySound("PLAY_TAUNT_30");
    int enemy = GetRandomEnemy();
    if (enemy == -1) {
        return;
    }
    SelectPlayerMilitary(1);
    int taken = TakeCountFromPool(GetCountFromPercent(trapPoolCount, TrapScale(5, 10, 20, 35, 50)));
    for (i = 0; < taken) {
        xsSetUnitOwner(xsArrayGetInt(trapPool, i), enemy, true);
    }
    xsChatData("<RED>Wololo!");
}

float INQUISITION_RADIUS = 5.0;
float TAU = 6.2831853;

void TRAP_SPANISH_INQUISITION() {
    xsPlaySound("PLAY_ATTACK_MONK_CONVERTING");
    int total = TrapScale(2, 3, 5, 8, 12);
    int enemy = GetRandomEnemy();
    if (enemy == -1) {
        return;
    }
    SelectAnchorCandidates();
    if (trapPoolCount == 0) {
        return;
    }
    vector at = xsGetUnitPosition(xsArrayGetInt(trapPool, xsGetRandomNumberMax(trapPoolCount)));
    for (n = 0; < total) {
        float angle = TAU * n / total;
        vector where = xsVectorSet(xsVectorGetX(at) + INQUISITION_RADIUS * cos(angle),
                                   xsVectorGetY(at) + INQUISITION_RADIUS * sin(angle),
                                   0.0);
        if (xsCreateUnit(TRAP_MISSIONARY, enemy, where, false, true, false) == -1) {
            xsCreateUnit(TRAP_MISSIONARY, enemy, at, false, true, false);
        }
    }
    xsChatData("<RED>Nobody expects the Spanish Inquisition!");
}

void TRAP_NO_SIEGE() {
    xsPlaySound("PLAY_TAUNT_19");
    EmptyTrapPool();
    SelectPlayerUnitsByClass(1, cSiegeWeaponClass);
    int taken = TakeCountFromPool(GetCountFromPercent(trapPoolCount, TrapScale(10, 20, 35, 60, 100)));
    for (i = 0; < taken) {
        xsSetUnitHitpoints(xsArrayGetInt(trapPool, i), 0.0);
    }
    xsChatData("<RED>Long Time, No Siege");
}

void TRAP_OOH_AHH() {
    soundTrapUntil = ExtendTrapTime(soundTrapUntil, TrapScale(10, 20, 30, 45, 60));
    ooh = true;
    xsEnableRule("TrapSoundLoop");
    xsChatData("<RED>Ooh! Ahh!");
}

void TRAP_THEOLOGIANS() {
    xsPlaySound("PLAY_TAUNT_18");
    chatTrapUntil = ExtendTrapTime(chatTrapUntil, TrapScale(10, 20, 30, 45, 60));
    xsEnableRule("TrapChatLoop");
}

void TRAP_IDLE_VILLAGERS() {
    xsPlaySound("PLAY_VMDL_MOVE");
    idleTrapUntil = ExtendTrapTime(idleTrapUntil, TrapScale(10, 15, 20, 30, 45));
    xsEnableRule("TrapIdleLoop");
    xsChatData("<RED>Now that's a good idea!");
}

void TRAP_FLEMISH_REVOLUTION() {
    xsPlaySound("PLAY_REVOLUTION_DECLARED");
    EmptyTrapPool();
    SelectPlayerUnitsByClass(1, cVillagerClass);
    int taken = TakeCountFromPool(GetCountFromPercent(trapPoolCount, TrapScale(5, 10, 20, 35, 60)));
    for (i = 0; < taken) {
        int villager = xsArrayGetInt(trapPool, i);
        vector where = xsGetUnitPosition(villager);
        xsRemoveUnit(villager);
        xsCreateUnit(TRAP_FLEMISH_MILITIA, 1, where);
    }
    xsChatData("<RED>Vive la France!");
}

void TRAP_RAIDING_PARTY() {
    xsPlaySound("PLAY_TAUNT_23");
    raidTrapUntil = ExtendTrapTime(raidTrapUntil, TrapScale(10, 20, 30, 45, 60));
    xsEnableRule("TrapRaidLoop");
    xsChatData("<RED>Raiding Party!");
}

void TRAP_TRIBUTE() {
    xsPlaySound("PLAY_TAUNT_38");
    int percent = TrapScale(5, 10, 20, 35, 60);
    int enemy = GetRandomEnemy();
    for (r = 0; < TRAP_RESOURCE_COUNT) {
        int resource = TrapResourceAt(r);
        float taken = xsPlayerAttribute(1, resource) * percent / 100.0;
        if (taken > 0.0) {
            xsEffectAmount(cModResource, resource, cAttributeAdd, -1.0 * taken, 1);
            if (enemy != -1) {
                xsEffectAmount(cModResource, resource, cAttributeAdd, taken, enemy);
            }
        }
    }
    xsChatData("<RED>Give Me Your Extra Resources!");
}

void GiveTrap(int itemId = -1) {
    switch(itemId) {
        case 5000: {
            TRAP_WOLOLO();
        }
        case 5001: {
            TRAP_SPANISH_INQUISITION();
        }
        case 5002: {
            TRAP_NO_SIEGE();
        }
        case 5003: {
            TRAP_OOH_AHH();
        }
        case 5004: {
            TRAP_THEOLOGIANS();
        }
        case 5005: {
            TRAP_IDLE_VILLAGERS();
        }
        case 5006: {
            TRAP_FLEMISH_REVOLUTION();
        }
        case 5007: {
            TRAP_RAIDING_PARTY();
        }
        case 5008: {
            TRAP_TRIBUTE();
        }
    }
}

// --- the timed traps --------------------------------------------------------------------------

int TRAP_CHAT_LINE_COUNT = 6;

string TrapChatLineAt(int index = -1) {
    if (index == 0) {
        return ("<YELLOW>Theologian: the relic is a symbol, not a resource.");
    }
    if (index == 1) {
        return ("<YELLOW>Theologian: monks do not convert siege. Stop asking.");
    }
    if (index == 2) {
        return ("<YELLOW>Theologian: consider the fate of the unattended sheep.");
    }
    if (index == 3) {
        return ("<YELLOW>Theologian: a wonder is merely a very confident house.");
    }
    if (index == 4) {
        return ("<YELLOW>Theologian: have you considered the Feudal Age, spiritually?");
    }
    return ("<YELLOW>Theologian: Wololo is a prayer, not a threat.");
}

rule TrapSoundLoop
    inactive
    group Traps
    minInterval 2
    maxInterval 2
{
    if (xsGetGameTime() >= soundTrapUntil) {
        xsDisableSelf();
        return;
    }
    if (ooh) {
        xsPlaySound("PLAY_TAUNT_09");
        ooh = false;
    }
    else {
        xsPlaySound("PLAY_TAUNT_07");
        ooh = true;
    }
}

rule TrapChatLoop
    inactive
    group Traps
    minInterval 1
    maxInterval 1
{
    if (xsGetGameTime() >= chatTrapUntil) {
        xsDisableSelf();
        return;
    }
    xsChatData(TrapChatLineAt(chatTrapLine));
    chatTrapLine = chatTrapLine + 1;
    if (chatTrapLine >= TRAP_CHAT_LINE_COUNT) {
        chatTrapLine = 0;
    }
}

rule TrapIdleLoop
    inactive
    group Traps
    minInterval 1
    maxInterval 1
{
    if (xsGetGameTime() >= idleTrapUntil) {
        xsDisableSelf();
        return;
    }
    EmptyTrapPool();
    SelectPlayerUnitsByClass(1, cVillagerClass);
    int taken = TakeCountFromPool(GetCountFromPercent(trapPoolCount, TrapScale(10, 20, 35, 60, 100)));
    for (i = 0; < taken) {
        xsStopUnit(xsArrayGetInt(trapPool, i));
    }
}

vector RaidCorner(int index = -1) {
    float edge = 3.0;
    float far_x = xsGetMapWidth() - edge;
    float far_y = xsGetMapHeight() - edge;
    if (index == 0) { return (xsVectorSet(edge, edge, 0.0)); }
    if (index == 1) { return (xsVectorSet(far_x, edge, 0.0)); }
    if (index == 2) { return (xsVectorSet(edge, far_y, 0.0)); }
    return (xsVectorSet(far_x, far_y, 0.0));
}

int NextRaidCorner() {
    int corner = xsGetRandomNumberMax(4);
    if (corner == raidTrapCorner) {
        corner = (corner + 1 + xsGetRandomNumberMax(3)) % 4;
    }
    raidTrapCorner = corner;
    return (corner);
}

rule TrapRaidLoop
    inactive
    group Traps
    minInterval 1
    maxInterval 1
{
    if (xsGetGameTime() >= raidTrapUntil) {
        xsDisableSelf();
        return;
    }
    vector where = RaidCorner(NextRaidCorner());
    SelectPlayerMilitary(1);
    for (i = 0; < trapPoolCount) {
        xsArraySetInt(trapTask, 0, xsArrayGetInt(trapPool, i));
        xsTaskUnits(trapTask, cActionTypeMove, where);
    }
}
