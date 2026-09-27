const int CAVEMAN_LEDGER_CAPACITY = 400;
const int CAVEMAN_IMMUNE_CAPACITY = 64;
const int CAVEMAN_EXEMPT_CAPACITY = 32;
const int CAVEMAN_CLASS_CAPACITY = 32;
const int CAVEMAN_MILITIA = 74;

int cavemanUnitIds = -1;
int originalUnitTypes = -1;
int cavemanCount = 0;

int cavemanImmuneUnits = -1;
int cavemanImmuneCount = 0;

int cavemanExemptTypes = -1;
int cavemanExemptCount = 0;

int cavemanScanClasses = -1;
int cavemanClassCount = 0;

int cavemanScan = -1;
float cavemanValue = 0.0;
bool cavemanReady = false;

void MarkUnitCavemanImmune(int unitId = -1) {
    if (unitId < 0 || cavemanImmuneUnits < 0) {
        return;
    }
    if (cavemanImmuneCount >= CAVEMAN_IMMUNE_CAPACITY) {
        return;
    }
    xsArraySetInt(cavemanImmuneUnits, cavemanImmuneCount, unitId);
    cavemanImmuneCount = cavemanImmuneCount + 1;
}

bool isUnitCavemanImmune(int unitId = -1) {
    for (i = 0; < cavemanImmuneCount) {
        if (xsArrayGetInt(cavemanImmuneUnits, i) == unitId) {
            return (true);
        }
    }
    return (false);
}

void ExemptUnitTypeFromCaveman(int typeId = -1) {
    if (typeId < 1 || cavemanExemptTypes < 0) {
        return;
    }
    if (cavemanExemptCount >= CAVEMAN_EXEMPT_CAPACITY) {
        xsChatData("<RED>Caveman: no room to exempt " + typeId);
        return;
    }
    xsArraySetInt(cavemanExemptTypes, cavemanExemptCount, typeId);
    cavemanExemptCount = cavemanExemptCount + 1;
}

bool isTypeExemptFromCaveman(int typeId = -1) {
    for (i = 0; < cavemanExemptCount) {
        if (xsArrayGetInt(cavemanExemptTypes, i) == typeId) {
            return (true);
        }
    }
    return (false);
}

int ledgerIndexOf(int unitId = -1) {
    for (i = 0; < cavemanCount) {
        if (xsArrayGetInt(cavemanUnitIds, i) == unitId) {
            return (i);
        }
    }
    return (-1);
}

int originalTypeOf(int unitId = -1) {
    int index = ledgerIndexOf(unitId);
    if (index < 0) {
        return (-1);
    }
    return (xsArrayGetInt(originalUnitTypes, index));
}

void rememberOriginalType(int unitId = -1, int originalTypeId = -1) {
    int index = ledgerIndexOf(unitId);
    if (index >= 0) {
        xsArraySetInt(originalUnitTypes, index, originalTypeId);
        return;
    }
    if (cavemanCount >= CAVEMAN_LEDGER_CAPACITY) {
        xsChatData("<RED>Caveman: ledger full, " + unitId + " will not climb back.");
        return;
    }
    xsArraySetInt(cavemanUnitIds, cavemanCount, unitId);
    xsArraySetInt(originalUnitTypes, cavemanCount, originalTypeId);
    cavemanCount = cavemanCount + 1;
}

void releaseCaveman(int unitId = -1) {
    int index = ledgerIndexOf(unitId);
    if (index < 0) {
        return;
    }
    int last = cavemanCount - 1;
    xsArraySetInt(cavemanUnitIds, index, xsArrayGetInt(cavemanUnitIds, last));
    xsArraySetInt(originalUnitTypes, index, xsArrayGetInt(originalUnitTypes, last));
    xsArraySetInt(cavemanUnitIds, last, -1);
    xsArraySetInt(originalUnitTypes, last, -1);
    cavemanCount = cavemanCount - 1;
}

void removeDeadCavemen() {
    int i = 0;
    while (i < cavemanCount) {
        if (xsDoesUnitExist(xsArrayGetInt(cavemanUnitIds, i))) {
            i = i + 1;
        } else {
            releaseCaveman(xsArrayGetInt(cavemanUnitIds, i));
        }
    }
}

bool technologyUnlocked(vector unit = cInvalidVector) {
    if (structGetBool(unit, "locked")) {
        return (false);
    }
    if (AP_TS_MODE == TECHSANITY_NONE) {
        return (true);
    }
    int itemId = structGetInt(unit, "upgradeItemId");
    if (itemId < 0) {
        return (true);
    }
    return (TechItemReceived(itemId));
}

int cavemanTarget(int originalTypeId = -1) {
    int index = findUnit(originalTypeId);
    if (index < 0) {
        return (originalTypeId);
    }
    vector originalUnit = getUnit(index);
    int lineId = structGetInt(originalUnit, "lineId");
    int originalTier = structGetInt(originalUnit, "tier");
    int bestTier = -1;
    int bestTypeId = -1;
    for (j = 0; < unitTableCount) {
        vector unit = getUnit(j);
        if (structGetInt(unit, "lineId") != lineId) {
            continue;
        }
        int tier = structGetInt(unit, "tier");
        if (tier > originalTier || tier <= bestTier) {
            continue;
        }
        if (technologyUnlocked(unit) == false) {
            continue;
        }
        bestTier = tier;
        bestTypeId = structGetInt(unit, "typeId");
    }
    if (bestTypeId < 0) {
        return (CAVEMAN_MILITIA);
    }
    return (bestTypeId);
}

void transformUnit(int unitId = -1, int toTypeId = -1, int originalTypeId = -1) {
    vector position = xsGetUnitPosition(unitId);
    xsRemoveUnit(unitId);
    releaseCaveman(unitId);
    int created = xsCreateUnit(toTypeId, 1, position, false, true, false);
    if (created < 0) {
        return;
    }
    if (toTypeId != originalTypeId) {
        rememberOriginalType(created, originalTypeId);
    }
}

void cavemanSweepClass(int classId = -1) {
    int found = xsGetPlayerUnitIds(1, classId, cavemanScan);
    for (i = 0; < xsArrayGetSize(found)) {
        int unitId = xsArrayGetInt(found, i);
        if (unitId < 0 || isUnitCavemanImmune(unitId)) {
            continue;
        }
        int currentTypeId = xsGetUnitType(unitId);
        int originalTypeId = originalTypeOf(unitId);
        if (originalTypeId < 0) {
            int index = findUnit(currentTypeId);
            if (index < 0 || structGetBool(getUnit(index), "cavemanExempt")
                    || isTypeExemptFromCaveman(currentTypeId)) {
                continue;
            }
            originalTypeId = currentTypeId;
        }
        int target = cavemanTarget(originalTypeId);
        if (target != currentTypeId) {
            transformUnit(unitId, target, originalTypeId);
        }
    }
}

void ApplyCaveman() {
    if (cavemanReady == false) {
        return;
    }
    removeDeadCavemen();
    for (c = 0; < cavemanClassCount) {
        cavemanSweepClass(xsArrayGetInt(cavemanScanClasses, c));
    }
}

void rememberClass(int classId = -1) {
    if (classId < 0) {
        return;
    }
    for (i = 0; < cavemanClassCount) {
        if (xsArrayGetInt(cavemanScanClasses, i) == classId) {
            return;
        }
    }
    if (cavemanClassCount >= CAVEMAN_CLASS_CAPACITY) {
        return;
    }
    xsArraySetInt(cavemanScanClasses, cavemanClassCount, classId);
    cavemanClassCount = cavemanClassCount + 1;
}

void InitCaveman() {
    if (AP_US_CAVEMAN == 0 || unitsanityReady == false) {
        return;
    }
    cavemanUnitIds = xsArrayCreateInt(CAVEMAN_LEDGER_CAPACITY, -1, "cm-ids");
    originalUnitTypes = xsArrayCreateInt(CAVEMAN_LEDGER_CAPACITY, -1, "cm-original-types");
    cavemanImmuneUnits = xsArrayCreateInt(CAVEMAN_IMMUNE_CAPACITY, -1, "cm-immune");
    cavemanExemptTypes = xsArrayCreateInt(CAVEMAN_EXEMPT_CAPACITY, -1, "cm-exempt");
    cavemanScanClasses = xsArrayCreateInt(CAVEMAN_CLASS_CAPACITY, -1, "cm-classes");
    cavemanScan = xsArrayCreateInt(1, -1, "cm-scan");

    for (j = 0; < unitTableCount) {
        vector unit = getUnit(j);
        if (structGetBool(unit, "cavemanExempt") == false) {
            rememberClass(xsGetObjectClass(structGetInt(unit, "typeId")));
        }
    }
    if (cavemanClassCount == 0) {
        xsChatData("<RED>Caveman: no unit classes resolved, so nothing will be downgraded.");
        return;
    }

    CavemanExemption();
    cavemanReady = true;
    cavemanValue = xsPlayerAttribute(1, cAttributeValueCurrentUnits);
    ApplyCaveman();
    xsEnableRule("CavemanSweep");
}

rule CavemanSweep
    inactive
    group Unitsanity
    highFrequency
{
    if (cavemanReady == false) {
        return;
    }
    float value = xsPlayerAttribute(1, cAttributeValueCurrentUnits);
    if (value == cavemanValue) {
        return;
    }
    cavemanValue = value;
    ApplyCaveman();
}
