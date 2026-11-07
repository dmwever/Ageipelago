int wonderThreatOwners = -1;
int wonderSlotUnits = -1;
int wonderSlotOwners = -1;
int wonderSlotRevealers = -1;
int wonderSlotCounting = -1;
int wonderSlotStartedAt = -1;
int wonderSlotModifiers = -1;
int wonderScan = -1;
bool wonderCapacityReported = false;

bool relicThreatEnabled = false;
bool relicCounting = false;
int relicHolder = -1;
int relicStartedAt = -1;
float relicModifier = 0.0;
int relicRevealers = -1;
int relicRevealedIds = -1;
int relicRevealerCount = 0;
int relicScan = -1;
int relicHolders = -1;

void InitVictoryThreats() {
    wonderThreatOwners = xsArrayCreateBool(xsGetNumPlayers(), false, "ap-threat-wonder-owners");
    wonderSlotUnits = xsArrayCreateInt(THREAT_WONDER_CAPACITY, -1, "ap-threat-wonder-units");
    wonderSlotOwners = xsArrayCreateInt(THREAT_WONDER_CAPACITY, -1, "ap-threat-wonder-slot-owners");
    wonderSlotRevealers = xsArrayCreateInt(THREAT_WONDER_CAPACITY, -1, "ap-threat-wonder-revealers");
    wonderSlotCounting = xsArrayCreateBool(THREAT_WONDER_CAPACITY, false, "ap-threat-wonder-counting");
    wonderSlotStartedAt = xsArrayCreateInt(THREAT_WONDER_CAPACITY, -1, "ap-threat-wonder-started");
    wonderSlotModifiers = xsArrayCreateFloat(THREAT_WONDER_CAPACITY, 0.0, "ap-threat-wonder-modifiers");
    wonderScan = xsArrayCreateInt(1, -1, "ap-threat-wonder-scan");

    relicThreatEnabled = false;
    relicCounting = false;
    relicRevealers = xsArrayCreateInt(THREAT_RELIC_REVEAL_CAPACITY, -1, "ap-threat-relic-revealers");
    relicRevealedIds = xsArrayCreateInt(THREAT_RELIC_REVEAL_CAPACITY, -1,
                                                "ap-threat-relic-ids");
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

int RevealAround(vector position = cInvalidVector) {
    int revealerId = xsCreateUnit(MAP_REVEALER, THREATENED_PLAYER, position, false, false, false);
    if (revealerId == -1) {
        return (-1);
    }
    xsEffectAmount(cSetUnitAttribute, revealerId, cLineOfSight,
                   1.0 * THREAT_REVEAL_RADIUS, THREATENED_PLAYER);
    return (revealerId);
}

void RemoveRevealer(int revealerId = -1) {
    if (revealerId == -1) {
        return;
    }
    if (xsDoesUnitExist(revealerId)) {
        xsRemoveUnit(revealerId);
    }
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
    xsArraySetInt(wonderSlotRevealers, slot, RevealAround(xsGetUnitPosition(unitId)));
    xsArraySetBool(wonderSlotCounting, slot, false);
}

void StartWonderCountdown(int slot = -1) {
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
    wonderScan = xsGetPlayerUnitIds(owner, WONDER, wonderScan);
    int found = xsArrayGetSize(wonderScan);
    for (i = 0; < found) {
        int unitId = xsArrayGetInt(wonderScan, i);
        if (unitId >= 0 && FindWonderSlot(unitId) == -1) {
            TrackWonder(unitId, owner);
        }
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

bool HasRevealedRelic(int relicId = -1) {
    for (i = 0; < relicRevealerCount) {
        if (xsArrayGetInt(relicRevealedIds, i) == relicId) {
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
        if (relicId < 0 || HasRevealedRelic(relicId)) {
            continue;
        }
        if (relicRevealerCount >= THREAT_RELIC_REVEAL_CAPACITY) {
            return;
        }
        xsArraySetInt(relicRevealedIds, relicRevealerCount, relicId);
        xsArraySetInt(relicRevealers, relicRevealerCount,
                      RevealAround(xsGetUnitPosition(relicId)));
        relicRevealerCount++;
    }
}

void ClearRelicRevealers() {
    for (i = 0; < relicRevealerCount) {
        RemoveRevealer(xsArrayGetInt(relicRevealers, i));
        xsArraySetInt(relicRevealers, i, -1);
        xsArraySetInt(relicRevealedIds, i, -1);
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
