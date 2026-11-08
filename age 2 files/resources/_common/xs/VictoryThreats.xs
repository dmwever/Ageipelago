int wonderThreatOwners = -1;
int wonderSlotUnits = -1;
int wonderSlotOwners = -1;
int wonderSlotRevealers = -1;
int wonderSlotFootprint = -1;
int wonderSlotCounting = -1;
int wonderSlotRevealed = -1;
int wonderSlotStartedAt = -1;
int wonderSlotModifiers = -1;
int wonderScan = -1;
int wonderDeepScan = -1;
bool wonderCapacityReported = false;

bool relicThreatEnabled = false;
bool relicCounting = false;
int relicHolder = -1;
int relicStartedAt = -1;
float relicModifier = 0.0;
int relicRevealers = -1;
int relicRevealedMonasteries = -1;
int relicRevealerCount = 0;
int relicScan = -1;
int relicHolders = -1;

void InitVictoryThreats() {
    wonderThreatOwners = xsArrayCreateBool(xsGetNumPlayers(), false, "ap-threat-wonder-owners");
    wonderSlotUnits = xsArrayCreateInt(THREAT_WONDER_CAPACITY, -1, "ap-threat-wonder-units");
    wonderSlotOwners = xsArrayCreateInt(THREAT_WONDER_CAPACITY, -1, "ap-threat-wonder-slot-owners");
    wonderSlotRevealers = xsArrayCreateInt(THREAT_WONDER_CAPACITY, -1, "ap-threat-wonder-revealers");
    wonderSlotFootprint = xsArrayCreateInt(THREAT_WONDER_CAPACITY * THREAT_FOUNDATION_CAPACITY,
                                           -1, "ap-threat-wonder-footprint");
    wonderSlotCounting = xsArrayCreateBool(THREAT_WONDER_CAPACITY, false, "ap-threat-wonder-counting");
    wonderSlotRevealed = xsArrayCreateBool(THREAT_WONDER_CAPACITY, false,
                                           "ap-threat-wonder-revealed");
    wonderSlotStartedAt = xsArrayCreateInt(THREAT_WONDER_CAPACITY, -1, "ap-threat-wonder-started");
    wonderSlotModifiers = xsArrayCreateFloat(THREAT_WONDER_CAPACITY, 0.0, "ap-threat-wonder-modifiers");
    wonderScan = xsArrayCreateInt(1, -1, "ap-threat-wonder-scan");
    wonderDeepScan = xsArrayCreateInt(1, -1, "ap-threat-wonder-deep-scan");

    relicThreatEnabled = false;
    relicCounting = false;
    relicRevealers = xsArrayCreateInt(THREAT_RELIC_REVEAL_CAPACITY, -1, "ap-threat-relic-revealers");
    relicRevealedMonasteries = xsArrayCreateInt(THREAT_RELIC_REVEAL_CAPACITY, -1,
                                                "ap-threat-relic-monasteries");
    relicRevealerCount = 0;
    relicScan = xsArrayCreateInt(1, -1, "ap-threat-relic-scan");
    relicHolders = xsArrayCreateBool(xsGetNumPlayers(), false, "ap-threat-relic-holders");
}

void EnableWonderThreat(int owner = -1) {
    if (owner < 1 || owner > xsArrayGetSize(wonderThreatOwners)) {
        xsChatData("<RED>EnableWonderThreat: player " + owner + " is not in this scenario.");
        return;
    }
    xsArraySetBool(wonderThreatOwners, owner - 1, true);
    xsEnableRule("WonderThreatWatch");
}

void EnableRelicThreat() {
    relicThreatEnabled = true;
    xsEnableRule("RelicThreatWatch");
}

void PinRevealer(int revealerId = -1, int radius = 0) {
    if (revealerId == -1) {
        return;
    }
    xsEffectAmount(cSetUnitAttribute, revealerId, cLineOfSight,
                   1.0 * radius, THREATENED_PLAYER);
}

int RevealAround(vector position = cInvalidVector, int radius = 0) {
    xsEffectAmount(cSetAttribute, MAP_REVEALER, cLineOfSight, 1.0 * radius, THREATENED_PLAYER);
    int revealerId = xsCreateUnit(MAP_REVEALER, THREATENED_PLAYER, position, false, false, false);
    if (revealerId == -1) {
        return (-1);
    }
    PinRevealer(revealerId, radius);
    return (revealerId);
}

void RepinRevealers() {
    for (slot = 0; < THREAT_WONDER_CAPACITY) {
        PinRevealer(xsArrayGetInt(wonderSlotRevealers, slot), THREAT_REVEAL_RADIUS);
    }
    for (cell = 0; < THREAT_WONDER_CAPACITY * THREAT_FOUNDATION_CAPACITY) {
        PinRevealer(xsArrayGetInt(wonderSlotFootprint, cell), THREAT_FOUNDATION_LOS);
    }
    for (held = 0; < relicRevealerCount) {
        PinRevealer(xsArrayGetInt(relicRevealers, held), THREAT_RELIC_REVEAL_RADIUS);
    }
}

void RemoveRevealer(int revealerId = -1) {
    if (revealerId == -1) {
        return;
    }
    xsEffectAmount(cSetUnitAttribute, revealerId, cHitpoints, 0.0, THREATENED_PLAYER);
}

int CountdownYears(float modifier = 0.0) {
    return (THREAT_BASE_YEARS + xsCeilToInt(modifier / THREAT_MODIFIER_PER_YEAR));
}

string ThreatOwnerLabel(int owner = -1) {
    return (xsGetPlayerColorTag(owner) + xsGetPlayerName(owner));
}

void ExtendCountdown(int timerId = -1, string message = "", float modifierChange = 0.0) {
    if (modifierChange == 0.0) {
        return;
    }
    float remaining = xsUnsyncGetTimerTimeRemaining(timerId, cTimerUnitYears, -1);
    float extension = modifierChange / THREAT_MODIFIER_PER_YEAR;
    xsDisplayTimer(timerId, message, xsCeilToInt(remaining + extension), cTimerUnitYears, true, -1);
}

bool HasCountdownExpired(int timerId = -1, int startedAt = -1) {
    if (xsGetGameTime() <= startedAt) {
        return (false);
    }
    return (xsUnsyncGetTimerTimeRemaining(timerId, cTimerUnitYears, -1) <= 0.0);
}

void LoseToThreat(string cause = "") {
    xsDisplayInstructions(cause, THREAT_ANNOUNCE_SECONDS, THREATENED_PLAYER, -1, cPanelTop,
                          false, true, "", THREATENED_PLAYER);
    xsDeclareVictory(THREATENED_PLAYER, false);
    xsDisableRule("WonderThreatWatch");
    xsDisableRule("RelicThreatWatch");
}

string WonderTimerMessage(int owner = -1) {
    return (ThreatOwnerLabel(owner) + " Wonder <TIMER>");
}

int FindWonderSlot(int unitId = -1) {
    for (slot = 0; < THREAT_WONDER_CAPACITY) {
        if (xsArrayGetInt(wonderSlotUnits, slot) == unitId) {
            return (slot);
        }
    }
    return (-1);
}

bool IsWonderComplete(int unitId = -1, int owner = -1) {
    float required = xsGetObjectAttribute(owner, WONDER, cTrainTime, 0);
    return (xsGetUnitBuildPoints(unitId) >= required);
}

void RevealFootprint(int slot = -1, int unitId = -1) {
    int rows = THREAT_FOUNDATION_ROWS;
    vector centre = xsGetUnitPosition(unitId);
    float firstX = xsVectorGetX(centre) - 0.5 * rows;
    float firstY = xsVectorGetY(centre) - 0.5 * rows;
    int base = slot * THREAT_FOUNDATION_CAPACITY;
    int placed = 0;
    for (ix = 0; < rows) {
        for (iy = 0; < rows) {
            if (placed >= THREAT_FOUNDATION_CAPACITY) {
                break;
            }
            vector spot = xsVectorSet(firstX + 1.0 * ix, firstY + 1.0 * iy, 0.0);
            xsArraySetInt(wonderSlotFootprint, base + placed,
                          RevealAround(spot, THREAT_FOUNDATION_LOS));
            placed = placed + 1;
        }
    }
    RepinRevealers();
}

void ClearFootprint(int slot = -1) {
    int base = slot * THREAT_FOUNDATION_CAPACITY;
    for (i = 0; < THREAT_FOUNDATION_CAPACITY) {
        RemoveRevealer(xsArrayGetInt(wonderSlotFootprint, base + i));
        xsArraySetInt(wonderSlotFootprint, base + i, -1);
    }
}

void CompleteWonderReveal(int slot = -1) {
    ClearFootprint(slot);
    xsArraySetBool(wonderSlotRevealed, slot, true);
    if (xsArrayGetInt(wonderSlotRevealers, slot) != -1) {
        return;
    }
    xsArraySetInt(wonderSlotRevealers, slot,
                  RevealAround(xsGetUnitPosition(xsArrayGetInt(wonderSlotUnits, slot)),
                               THREAT_REVEAL_RADIUS));
    RepinRevealers();
}

bool HasWonderBegun(int unitId = -1) {
    return (xsGetUnitBuildPoints(unitId) > 0.0);
}

int WonderSlotRevealKind(int slot = -1) {
    if (xsArrayGetInt(wonderSlotRevealers, slot) != -1) {
        return (2);
    }
    if (xsArrayGetInt(wonderSlotFootprint, slot * THREAT_FOUNDATION_CAPACITY) != -1) {
        return (1);
    }
    return (0);
}

void RevealWonderSlot(int slot = -1) {
    if (xsArrayGetBool(wonderSlotRevealed, slot)) {
        return;
    }
    int unitId = xsArrayGetInt(wonderSlotUnits, slot);
    int owner = xsArrayGetInt(wonderSlotOwners, slot);
    if (unitId == -1 || xsDoesUnitExist(unitId) == false) {
        return;
    }
    if (IsWonderComplete(unitId, owner)) {
        xsArraySetBool(wonderSlotRevealed, slot, true);
        xsArraySetInt(wonderSlotRevealers, slot,
                      RevealAround(xsGetUnitPosition(unitId), THREAT_REVEAL_RADIUS));
        RepinRevealers();
        return;
    }
    if (HasWonderBegun(unitId) == false) {
        return;
    }
    xsArraySetBool(wonderSlotRevealed, slot, true);
    RevealFootprint(slot, unitId);
    xsDisplayInstructions(ThreatOwnerLabel(owner) + " has begun a Wonder!",
                          THREAT_ANNOUNCE_SECONDS, owner, WONDER, cPanelTop,
                          false, true, "", THREATENED_PLAYER);
}

void TrackWonder(int unitId = -1, int owner = -1) {
    int slot = FindWonderSlot(-1);
    if (slot == -1) {
        if (wonderCapacityReported) {
            return;
        }
        wonderCapacityReported = true;
        xsChatData("<RED>Victory threats: no room left to track " + xsGetPlayerName(owner)
                   + "'s Wonder, so it carries no countdown.");
        return;
    }
    xsArraySetInt(wonderSlotUnits, slot, unitId);
    xsArraySetInt(wonderSlotOwners, slot, owner);
    xsArraySetBool(wonderSlotCounting, slot, false);
    xsArraySetBool(wonderSlotRevealed, slot, false);
    RevealWonderSlot(slot);
}

void StartWonderCountdown(int slot = -1) {
    CompleteWonderReveal(slot);
    int owner = xsArrayGetInt(wonderSlotOwners, slot);
    float modifier = xsPlayerAttribute(owner, cAttributeHunWonderBonus);
    xsArraySetBool(wonderSlotCounting, slot, true);
    xsArraySetInt(wonderSlotStartedAt, slot, xsGetGameTime());
    xsArraySetFloat(wonderSlotModifiers, slot, modifier);
    xsDisplayTimer(slot, WonderTimerMessage(owner), CountdownYears(modifier), cTimerUnitYears, true, -1);
    xsDisplayInstructions(ThreatOwnerLabel(owner) + " has completed a Wonder! Destroy it before time runs out.",
                          THREAT_ANNOUNCE_SECONDS, owner, WONDER, cPanelTop,
                          false, true, "", THREATENED_PLAYER);
}

void ReleaseWonderSlot(int slot = -1) {
    if (xsArrayGetBool(wonderSlotCounting, slot)) {
        xsClearTimer(slot, -1);
    }
    RemoveRevealer(xsArrayGetInt(wonderSlotRevealers, slot));
    ClearFootprint(slot);
    xsArraySetBool(wonderSlotRevealed, slot, false);
    xsArraySetInt(wonderSlotUnits, slot, -1);
    xsArraySetInt(wonderSlotOwners, slot, -1);
    xsArraySetInt(wonderSlotRevealers, slot, -1);
    xsArraySetBool(wonderSlotCounting, slot, false);
}

bool IsWonderStanding(int slot = -1) {
    int unitId = xsArrayGetInt(wonderSlotUnits, slot);
    if (xsDoesUnitExist(unitId) == false) {
        return (false);
    }
    return (xsGetUnitOwner(unitId) == xsArrayGetInt(wonderSlotOwners, slot));
}

void RetireWonderOwner(int owner = -1) {
    xsArraySetBool(wonderThreatOwners, owner - 1, false);
    for (slot = 0; < THREAT_WONDER_CAPACITY) {
        if (xsArrayGetInt(wonderSlotOwners, slot) == owner) {
            ReleaseWonderSlot(slot);
        }
    }
}

void ScanOwnerWonders(int owner = -1) {
    int listed = xsGetPlayerUnitIds(owner, WONDER, wonderScan);
    if (listed < 0) {
        return;
    }
    wonderScan = listed;
    int found = xsArrayGetSize(wonderScan);
    for (i = 0; < found) {
        int unitId = xsArrayGetInt(wonderScan, i);
        if (unitId >= 0 && FindWonderSlot(unitId) == -1) {
            TrackWonder(unitId, owner);
        }
    }
}

int CountOwnerFoundations(int owner = -1) {
    int standing = xsGetObjectCount(owner, WONDER);
    int total = xsGetObjectCountTotal(owner, WONDER);
    if (standing < 0 || total < 0) {
        return (-1);
    }
    return (total - standing);
}

int TrackedFoundations(int owner = -1) {
    int found = 0;
    for (slot = 0; < THREAT_WONDER_CAPACITY) {
        if (xsArrayGetInt(wonderSlotOwners, slot) == owner) {
            int unitId = xsArrayGetInt(wonderSlotUnits, slot);
            if (unitId != -1 && xsDoesUnitExist(unitId)
                && IsWonderComplete(unitId, owner) == false) {
                found = found + 1;
            }
        }
    }
    return (found);
}

void ScanOwnerFoundations(int owner = -1) {
    int listed = xsGetPlayerUnitIds(owner, -1, wonderDeepScan);
    if (listed < 0) {
        return;
    }
    wonderDeepScan = listed;
    int units = xsArrayGetSize(wonderDeepScan);
    for (i = 0; < units) {
        int unitId = xsArrayGetInt(wonderDeepScan, i);
        if (unitId < 0) {
            continue;
        }
        if (xsGetUnitObjectId(unitId) != WONDER) {
            continue;
        }
        if (FindWonderSlot(unitId) == -1) {
            TrackWonder(unitId, owner);
        }
    }
}

void WatchOwnerFoundations(int owner = -1) {
    int found = CountOwnerFoundations(owner);
    if (found < 0) {
        return;
    }
    if (found > TrackedFoundations(owner)) {
        ScanOwnerFoundations(owner);
    }
}

bool TickWonderSlot(int slot = -1) {
    int unitId = xsArrayGetInt(wonderSlotUnits, slot);
    if (unitId == -1) {
        return (false);
    }
    if (IsWonderStanding(slot) == false) {
        ReleaseWonderSlot(slot);
        return (false);
    }

    int owner = xsArrayGetInt(wonderSlotOwners, slot);
    if (xsArrayGetBool(wonderSlotCounting, slot) == false) {
        RevealWonderSlot(slot);
        if (IsWonderComplete(unitId, owner)) {
            StartWonderCountdown(slot);
        }
        return (false);
    }

    float appliedModifier = xsArrayGetFloat(wonderSlotModifiers, slot);
    float currentModifier = xsPlayerAttribute(owner, cAttributeHunWonderBonus);
    ExtendCountdown(slot, WonderTimerMessage(owner), currentModifier - appliedModifier);
    xsArraySetFloat(wonderSlotModifiers, slot, currentModifier);
    return (HasCountdownExpired(slot, xsArrayGetInt(wonderSlotStartedAt, slot)));
}

rule WonderThreatWatch
    inactive
    group VictoryThreats
    minInterval 1
    maxInterval 1
{
    int players = xsArrayGetSize(wonderThreatOwners);
    for (index = 0; < players) {
        if (xsArrayGetBool(wonderThreatOwners, index)) {
            int owner = index + 1;
            if (xsGetPlayerInGame(owner)) {
                ScanOwnerWonders(owner);
                WatchOwnerFoundations(owner);
            }
            else {
                RetireWonderOwner(owner);
            }
        }
    }

    for (slot = 0; < THREAT_WONDER_CAPACITY) {
        if (TickWonderSlot(slot)) {
            LoseToThreat(ThreatOwnerLabel(xsArrayGetInt(wonderSlotOwners, slot))
                         + "'s Wonder has stood long enough. You have been defeated.");
            return;
        }
    }
}

string RelicTimerMessage(int holder = -1) {
    return (ThreatOwnerLabel(holder) + " Relics <TIMER>");
}

bool IsRelicThreatHolder(int player = -1) {
    if (player == THREATENED_PLAYER || player <= 0) {
        return (false);
    }
    if (xsGetPlayerInGame(player) == false) {
        return (false);
    }
    return (xsGetDiplomacy(player, THREATENED_PLAYER) == cDiplomacyEnemy);
}

int FindRelicMonastery(int relicId = -1) {
    int containerId = xsGetGarrisonedInUnitId(relicId);
    if (containerId < 0) {
        return (-1);
    }
    if (xsGetUnitObjectId(containerId) != MONASTERY) {
        return (-1);
    }
    return (containerId);
}

bool IsAlliedWithHolders(int player = -1) {
    int players = xsArrayGetSize(relicHolders);
    for (index = 0; < players) {
        int other = index + 1;
        if (other != player && xsArrayGetBool(relicHolders, index)) {
            if (xsGetDiplomacy(player, other) != cDiplomacyAlly
                || xsGetDiplomacy(other, player) != cDiplomacyAlly) {
                return (false);
            }
        }
    }
    return (true);
}

int FindRelicHolder() {
    int holder = -1;
    int players = xsArrayGetSize(relicHolders);
    for (index = 0; < players) {
        xsArraySetBool(relicHolders, index, false);
    }

    int found = xsGetPlayerUnitIds(0, cRelicClass, relicScan);
    if (found >= 0) {
        relicScan = found;
    }
    if (relicScan < 0) {
        return (-1);
    }
    int relics = xsArrayGetSize(relicScan);
    if (relics == 0) {
        return (-1);
    }

    for (i = 0; < relics) {
        int relicId = xsArrayGetInt(relicScan, i);
        if (relicId < 0) {
            continue;
        }
        int monasteryId = FindRelicMonastery(relicId);
        if (monasteryId == -1) {
            return (-1);
        }
        int monasteryOwner = xsGetUnitOwner(monasteryId);
        if (IsRelicThreatHolder(monasteryOwner) == false) {
            return (-1);
        }
        if (IsAlliedWithHolders(monasteryOwner) == false) {
            return (-1);
        }
        xsArraySetBool(relicHolders, monasteryOwner - 1, true);
        if (holder == -1) {
            holder = monasteryOwner;
        }
    }
    return (holder);
}

bool HasRevealedMonastery(int monasteryId = -1) {
    for (i = 0; < relicRevealerCount) {
        if (xsArrayGetInt(relicRevealedMonasteries, i) == monasteryId) {
            return (true);
        }
    }
    return (false);
}

void RevealRelics() {
    int found = xsGetPlayerUnitIds(0, cRelicClass, relicScan);
    if (found >= 0) {
        relicScan = found;
    }
    if (relicScan < 0) {
        return;
    }
    int relics = xsArrayGetSize(relicScan);
    for (i = 0; < relics) {
        int relicId = xsArrayGetInt(relicScan, i);
        if (relicId < 0) {
            continue;
        }
        int monasteryId = FindRelicMonastery(relicId);
        if (monasteryId < 0 || HasRevealedMonastery(monasteryId)) {
            continue;
        }
        if (relicRevealerCount >= THREAT_RELIC_REVEAL_CAPACITY) {
            return;
        }
        xsArraySetInt(relicRevealedMonasteries, relicRevealerCount, monasteryId);
        xsArraySetInt(relicRevealers, relicRevealerCount,
                      RevealAround(xsGetUnitPosition(monasteryId),
                                   THREAT_RELIC_REVEAL_RADIUS));
        relicRevealerCount++;
    }
    RepinRevealers();
}

void ClearRelicRevealers() {
    for (i = 0; < relicRevealerCount) {
        RemoveRevealer(xsArrayGetInt(relicRevealers, i));
        xsArraySetInt(relicRevealers, i, -1);
        xsArraySetInt(relicRevealedMonasteries, i, -1);
    }
    relicRevealerCount = 0;
}

void StartRelicCountdown(int holder = -1) {
    relicCounting = true;
    relicHolder = holder;
    relicStartedAt = xsGetGameTime();
    relicModifier = xsPlayerAttribute(holder, cAttributeHunRelicBonus);
    RevealRelics();
    xsDisplayTimer(THREAT_WONDER_CAPACITY, RelicTimerMessage(holder), CountdownYears(relicModifier),
                   cTimerUnitYears, true, -1);
    xsDisplayInstructions(ThreatOwnerLabel(holder) + " holds every relic! Take one back before time runs out.",
                          THREAT_ANNOUNCE_SECONDS, holder, -1, cPanelTop,
                          false, true, "", THREATENED_PLAYER);
}

void CancelRelicCountdown() {
    relicCounting = false;
    relicHolder = -1;
    xsClearTimer(THREAT_WONDER_CAPACITY, -1);
    ClearRelicRevealers();
}

rule RelicThreatWatch
    inactive
    group VictoryThreats
    minInterval 1
    maxInterval 1
{
    if (relicThreatEnabled == false) {
        xsDisableSelf();
        return;
    }

    int holder = FindRelicHolder();
    if (relicCounting == false) {
        if (holder != -1) {
            StartRelicCountdown(holder);
        }
        return;
    }
    if (holder != relicHolder) {
        CancelRelicCountdown();
        return;
    }

    float currentModifier = xsPlayerAttribute(holder, cAttributeHunRelicBonus);
    ExtendCountdown(THREAT_WONDER_CAPACITY, RelicTimerMessage(holder), currentModifier - relicModifier);
    relicModifier = currentModifier;
    if (HasCountdownExpired(THREAT_WONDER_CAPACITY, relicStartedAt)) {
        LoseToThreat(ThreatOwnerLabel(holder) + " has held every relic long enough. You have been defeated.");
    }
}
