include "./UnitData.xs";

int unitArray = -1;
extern int unitTableCount = 0;   /* not unitCount: MercenarySeats.xs has a parameter by that name */

extern int unitsOwned = -1;

int receivedItems = -1;

/* Keyed by genie id, not scanned: typeRowIndex[id] is the row holding that id, canonicalType[id]
   is the row id a variant belongs to. Both -1 when unknown. */
int typeRowIndex = -1;
int canonicalType = -1;


vector getUnit(int i = -1) {
    return (xsArrayGetVector(unitArray, i));
}

int findUnit(int typeId = -1) {
    if (typeId < 0 || typeId >= TYPE_INDEX_CAPACITY) {
        return (-1);
    }
    return (xsArrayGetInt(typeRowIndex, typeId));
}

int idList(vector unit = cInvalidVector, string attrName = "") {
    if (validateInstanceAttribute(unit, attrName, TYPE_INT_ARRAY) == false) {
        return (-1);
    }
    return (xsArrayGetInt(getValueArrayRefAfterValidation(), 0));
}

void setIdList(vector unit = cInvalidVector, string attrName = "", int arrayId = -1) {
    if (validateInstanceAttribute(unit, attrName, TYPE_INT_ARRAY)) {
        xsArraySetInt(getValueArrayRefAfterValidation(), 0, arrayId);
    }
}

void appendId(int list = -1, int capacity = 0, int value = -1) {
    for (i = 0; < capacity) {
        if (xsArrayGetInt(list, i) == value) {
            return;
        }
        if (xsArrayGetInt(list, i) < 0) {
            xsArraySetInt(list, i, value);
            return;
        }
    }
}

void addUnit(int locationId = -1, int typeId = -1, int lineId = -1, int age = 0,
             int tier = 0, int upgradeItemId = -1, int cavemanExempt = 0) {
    if (unitTableCount >= UNIT_CAPACITY || typeId < 1) {
        return;
    }
    vector unit = new("Unit");
    if (unit == cInvalidVector) {
        xsChatData("<RED>Unitsanity: out of Unit struct instances, dropping unit " + typeId);
        return;
    }
    structSetInt(unit, "typeId", typeId);
    structSetInt(unit, "locationId", locationId);
    structSetInt(unit, "lineId", lineId);
    structSetInt(unit, "age", age);
    structSetInt(unit, "tier", tier);
    structSetInt(unit, "upgradeItemId", upgradeItemId);
    structSetBool(unit, "cavemanExempt", cavemanExempt == 1);
    structSetBool(unit, "trainable", true);
    structSetInt(unit, "owned", 0);
    structSetBool(unit, "hasItems", false);
    structSetBool(unit, "locked", false);
    setIdList(unit, "itemIds",
              xsArrayCreateInt(UNIT_ITEM_CAPACITY, -1, "us-items-" + unitTableCount));
    setIdList(unit, "variantIds",
              xsArrayCreateInt(UNIT_VARIANT_CAPACITY, -1, "us-variants-" + unitTableCount));
    xsArraySetVector(unitArray, unitTableCount, unit);
    if (typeId < TYPE_INDEX_CAPACITY) {
        xsArraySetInt(typeRowIndex, typeId, unitTableCount);
    }
    unitTableCount = unitTableCount + 1;
}

void addUnitUntrainable(int typeId = -1, int civId = -1) {
    if (civId != xsGetPlayerCivilization(1)) {
        return;
    }
    int index = findUnit(typeId);
    if (index < 0) {
        return;
    }
    structSetBool(getUnit(index), "trainable", false);
}

void addUnitItem(int typeId = -1, int itemId = -1) {
    int index = findUnit(typeId);
    if (index < 0) {
        return;
    }
    appendId(idList(getUnit(index), "itemIds"), UNIT_ITEM_CAPACITY, itemId);
}

void addUnitVariant(int typeId = -1, int variantId = -1) {
    int index = findUnit(typeId);
    if (index < 0) {
        return;
    }
    appendId(idList(getUnit(index), "variantIds"), UNIT_VARIANT_CAPACITY, variantId);
    if (variantId >= 0 && variantId < TYPE_INDEX_CAPACITY) {
        xsArraySetInt(canonicalType, variantId, typeId);
    }
}

int canonicalTypeOf(int typeId = -1) {
    if (typeId < 0 || typeId >= TYPE_INDEX_CAPACITY) {
        return (typeId);
    }
    int canonical = xsArrayGetInt(canonicalType, typeId);
    if (canonical < 0) {
        return (typeId);
    }
    return (canonical);
}

void setObjectDisable(int objectId = -1, float disableFlag = 1.0, bool enable = false) {
    xsEffectAmount(cSetAttribute, objectId, cDisabledFlag, disableFlag, 1);
    if (enable) {
        xsEffectAmount(cEnableObject, objectId, cAttributeEnable, 1.0, 1);
    }
}

void setUnitDisable(vector unit = cInvalidVector, float disableFlag = 1.0) {
    bool enable = false;
    if (disableFlag == 0.0 && ageReached(structGetInt(unit, "age"))
        && structGetBool(unit, "trainable")) {
        enable = true;
    }
    setObjectDisable(structGetInt(unit, "typeId"), disableFlag, enable);
    int variants = idList(unit, "variantIds");
    for (i = 0; < UNIT_VARIANT_CAPACITY) {
        if (xsArrayGetInt(variants, i) < 0) {
            break;
        }
        setObjectDisable(xsArrayGetInt(variants, i), disableFlag, false);
    }
}

void setUnitHidden(vector unit = cInvalidVector, bool hidden = true) {
    float disableFlag = 0.0; //Enable
    if (hidden) {
        disableFlag = 1.0;
    }
    setUnitDisable(unit, disableFlag);
    structSetBool(unit, "locked", hidden);
}

void MarkRowOwned(int index = -1) {
    if (index < 0) {
        return;
    }
    vector unit = getUnit(index);
    if (structGetInt(unit, "owned") > 0) {
        return;
    }
    int locationId = structGetInt(unit, "locationId");
    if (locationId < 0) {
        return;
    }
    structSetInt(unit, "owned", 1);
    AP_Check_Location(locationId);
}

bool MarkOwnedByType(int typeId = -1) {
    bool found = false;
    int index = findUnit(typeId);
    if (index >= 0) {
        MarkRowOwned(index);
        found = true;
    }
    int canonical = canonicalTypeOf(typeId);
    if (canonical != typeId) {
        int canonicalIndex = findUnit(canonical);
        if (canonicalIndex >= 0) {
            MarkRowOwned(canonicalIndex);
            found = true;
        }
    }
    return (found);
}

void checkOwnedUnits(int units = -1) {
    for (i = 0; < xsArrayGetSize(units)) {
        int unitId = xsArrayGetInt(units, i);
        if (unitId < 0) {
            continue;
        }
        if (MarkOwnedByType(xsGetUnitCopyId(unitId)) == false) {
            MarkOwnedByType(xsGetUnitObjectId(unitId));
        }
    }
}

bool hasItem(int itemId = -1) {
    int offset = itemId - AP_UNIT_ITEM_OFFSET;
    if (offset < 0 || offset >= UNIT_ITEM_SPAN) {
        return (false);
    }
    return (xsArrayGetBool(receivedItems, offset));
}

bool hasAllItems(vector unit = cInvalidVector) {
    int items = idList(unit, "itemIds");
    for (i = 0; < UNIT_ITEM_CAPACITY) {
        int itemId = xsArrayGetInt(items, i);
        if (itemId < 0) {
            return (true);
        }
        if (hasItem(itemId) == false) {
            return (false);
        }
    }
    return (true);
}

void refreshUnitLocks() {
    for (j = 0; < unitTableCount) {
        vector unit = getUnit(j);
        if (structGetBool(unit, "locked") == false) {
            continue;
        }
        if (hasAllItems(unit)) {
            structSetBool(unit, "hasItems", true);
            if (isProfession(unit)) {
                structSetBool(unit, "locked", false);
            } else {
                setUnitHidden(unit, false);
            }
            cavemanTargetsStale = true;
            unitsDirty = true;
        }
    }
}

void UnlockUnitItem(int itemId = -1) {
    int offset = itemId - AP_UNIT_ITEM_OFFSET;
    if (offset < 0 || offset >= UNIT_ITEM_SPAN) {
        return;
    }
    xsArraySetBool(receivedItems, offset, true);
    if (unitsanityReady) {
        refreshUnitLocks();
    }
}

void InitUnitsanityStructs() {
    defineStruct("Unit");
    defineStructAttribute("Unit", "typeId", TYPE_INT);
    defineStructAttribute("Unit", "locationId", TYPE_INT);
    defineStructAttribute("Unit", "lineId", TYPE_INT);
    defineStructAttribute("Unit", "age", TYPE_INT);
    defineStructAttribute("Unit", "tier", TYPE_INT);
    defineStructAttribute("Unit", "upgradeItemId", TYPE_INT);
    defineStructAttribute("Unit", "cavemanExempt", TYPE_BOOL);
    defineStructAttribute("Unit", "trainable", TYPE_BOOL);
    defineStructAttribute("Unit", "owned", TYPE_INT);
    defineStructAttribute("Unit", "hasItems", TYPE_BOOL);
    defineStructAttribute("Unit", "locked", TYPE_BOOL);
    defineStructAttribute("Unit", "itemIds", TYPE_INT_ARRAY);
    defineStructAttribute("Unit", "variantIds", TYPE_INT_ARRAY);

    unitArray = xsArrayCreateVector(UNIT_CAPACITY, cInvalidVector, "us-units");
    typeRowIndex = xsArrayCreateInt(TYPE_INDEX_CAPACITY, -1, "us-type-rows");
    canonicalType = xsArrayCreateInt(TYPE_INDEX_CAPACITY, -1, "us-canonical");
    receivedItems = xsArrayCreateBool(UNIT_ITEM_SPAN, false, "us-received");
}

void InitUnitsanity() {
    if (AP_US_MODE == UNITSANITY_NONE) {
        return;
    }
    if (US_SEED_HIGH != AP_SEED_HIGH || US_SEED_LOW != AP_SEED_LOW) {
        xsChatData("<RED>Unitsanity: unit data is from the wrong seed. Run /install in the Age 2 client.");
        return;
    }

    InitUnitsanityStructs();
    LoadUnitTable();

    if (unitTableCount == 0) {
        xsChatData("<RED>Unitsanity is enabled but no units are installed. Run /install for this seed.");
        return;
    }

    for (j = 0; < unitTableCount) {
        vector unit = getUnit(j);
        setUnitHidden(unit, true);
        int locationId = structGetInt(unit, "locationId");
        if (locationId >= 0) {
            AddLocation(locationId);
        }
    }

    unitsanityReady = true;
    xsEnableRule("UnitsanityChecks");
}

int testArray = -1;

int PROFESSION_SWEEP_SECONDS = 2;
int lastProfessionSweep = -1;

rule UnitsanityChecks
    inactive
    minInterval 1
    maxInterval 1
    group Unitsanity
{
    if (unitsanityReady == false || startupGranted == 0) {
        return;
    }

    int units = xsGetPlayerUnitIds(1, -1, testArray);

    int owned = xsArrayGetSize(units);
    if (owned != unitsOwned) {
        unitsOwned = owned;
        unitsDirty = true;
        return;
    }
    if (unitsDirty == false) {
        if (xsGetGameTime() - lastProfessionSweep >= PROFESSION_SWEEP_SECONDS) {
            lastProfessionSweep = xsGetGameTime();
            CheckProfessionLocations(units);
        }
        return;
    }

    unitsTransformed = false;
    ApplyCaveman(units);
    EvictProfessions();
    if (unitsTransformed) {
        return;
    }

    unitsDirty = false;
    checkOwnedUnits(units);
}
