include "./UnitData.xs";

int unitArray = -1;
int unitTableCount = 0;   /* not unitCount: MercenarySeats.xs has a parameter by that name */

bool unitsanityReady = false;

float unitsValue = 0.0;

int receivedItems = -1;

vector getUnit(int i = -1) {
    return (xsArrayGetVector(unitArray, i));
}

int findUnit(int gameId = -1) {
    for (i = 0; < unitTableCount) {
        if (structGetInt(getUnit(i), "gameId") == gameId) {
            return (i);
        }
    }
    return (-1);
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

void addUnit(int locationId = -1, int gameId = -1, int lineId = -1, int age = 0,
             int tier = 0, int isLocation = 0) {
    if (unitTableCount >= UNIT_CAPACITY || gameId < 1) {
        return;
    }
    vector unit = new("Unit");
    if (unit == cInvalidVector) {
        xsChatData("<RED>Unitsanity: out of Unit struct instances, dropping unit " + gameId);
        return;
    }
    structSetInt(unit, "gameId", gameId);
    structSetInt(unit, "locationId", locationId);
    structSetInt(unit, "lineId", lineId);
    structSetInt(unit, "age", age);
    structSetInt(unit, "tier", tier);
    structSetBool(unit, "isLocation", isLocation == 1);
    structSetInt(unit, "owned", 0);
    structSetBool(unit, "hasItems", false);
    structSetBool(unit, "locked", false);
    setIdList(unit, "itemIds",
              xsArrayCreateInt(UNIT_ITEM_CAPACITY, -1, "us-items-" + unitTableCount));
    setIdList(unit, "variantIds",
              xsArrayCreateInt(UNIT_VARIANT_CAPACITY, -1, "us-variants-" + unitTableCount));
    xsArraySetVector(unitArray, unitTableCount, unit);
    unitTableCount = unitTableCount + 1;
}

void addUnitItem(int gameId = -1, int itemId = -1) {
    int index = findUnit(gameId);
    if (index < 0) {
        return;
    }
    appendId(idList(getUnit(index), "itemIds"), UNIT_ITEM_CAPACITY, itemId);
}

void addUnitVariant(int gameId = -1, int variantId = -1) {
    int index = findUnit(gameId);
    if (index < 0) {
        return;
    }
    appendId(idList(getUnit(index), "variantIds"), UNIT_VARIANT_CAPACITY, variantId);
}

bool ageReached(int age = 0) {
    if (age == FEUDAL_AGE) {
        return (xsGetTechState(FEUDAL_AGE_TECH, 1) == cTechStateDone);
    }
    if (age == CASTLE_AGE) {
        return (xsGetTechState(CASTLE_AGE_TECH, 1) == cTechStateDone);
    }
    if (age == IMPERIAL_AGE) {
        return (xsGetTechState(IMPERIAL_AGE_TECH, 1) == cTechStateDone);
    }
    return (true);
}

void setObjectDisable(int objectId = -1, float disableFlag = 1.0, bool enable = false) {
    xsEffectAmount(cSetAttribute, objectId, cDisabledFlag, disableFlag, 1);
    if (enable) {
        xsEffectAmount(cEnableObject, objectId, cAttributeEnable, 1.0, 1);
    }
}

void setUnitDisable(vector unit = cInvalidVector, float disableFlag = 1.0) {
    bool enable = false;
    if (disableFlag == 0.0 && ageReached(structGetInt(unit, "age"))) {
        enable = true;
    }
    setObjectDisable(structGetInt(unit, "gameId"), disableFlag, enable);
    int variants = idList(unit, "variantIds");
    for (i = 0; < UNIT_VARIANT_CAPACITY) {
        if (xsArrayGetInt(variants, i) < 0) {
            break;
        }
        setObjectDisable(xsArrayGetInt(variants, i), disableFlag, enable);
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

int countOwned(vector unit = cInvalidVector) {
    int total = xsGetObjectCount(1, structGetInt(unit, "gameId"));
    int variants = idList(unit, "variantIds");
    for (i = 0; < UNIT_VARIANT_CAPACITY) {
        if (xsArrayGetInt(variants, i) < 0) {
            break;
        }
        total = total + xsGetObjectCount(1, xsArrayGetInt(variants, i));
    }
    return (total);
}

void checkOwnedUnits() {
    for (j = 0; < unitTableCount) {
        vector unit = getUnit(j);
        if (structGetInt(unit, "owned") > 0) {
            continue;
        }
        int locationId = structGetInt(unit, "locationId");
        if (locationId < 0) {
            continue;
        }
        int owned = countOwned(unit);
        if (owned > 0) {
            structSetInt(unit, "owned", owned);
            AP_Check_Location(locationId);
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
            setUnitHidden(unit, false);
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
    defineStructAttribute("Unit", "gameId", TYPE_INT);
    defineStructAttribute("Unit", "locationId", TYPE_INT);
    defineStructAttribute("Unit", "lineId", TYPE_INT);
    defineStructAttribute("Unit", "age", TYPE_INT);
    defineStructAttribute("Unit", "tier", TYPE_INT);
    defineStructAttribute("Unit", "isLocation", TYPE_BOOL);
    defineStructAttribute("Unit", "owned", TYPE_INT);
    defineStructAttribute("Unit", "hasItems", TYPE_BOOL);
    defineStructAttribute("Unit", "locked", TYPE_BOOL);
    defineStructAttribute("Unit", "itemIds", TYPE_INT_ARRAY);
    defineStructAttribute("Unit", "variantIds", TYPE_INT_ARRAY);

    unitArray = xsArrayCreateVector(UNIT_CAPACITY, cInvalidVector, "us-units");
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
    unitsValue = xsPlayerAttribute(1, cAttributeValueCurrentUnits);
    checkOwnedUnits();
    xsEnableRule("UnitsanityChecks");
}

rule UnitsanityChecks
    inactive
    group Unitsanity
    highFrequency
{
    if (unitsanityReady == false) {
        return;
    }

    float value = xsPlayerAttribute(1, cAttributeValueCurrentUnits);
    if (value == unitsValue) {
        return;
    }
    unitsValue = value;
    checkOwnedUnits();
}
