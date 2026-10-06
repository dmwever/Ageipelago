const float PROFESSION_MALE_GROUP = 1.0;
const float PROFESSION_FEMALE_GROUP = 2.0;
const float PROFESSION_NO_GROUP = 0.0;
const int PROFESSION_VILLAGER_FEMALE = 293;

bool isProfession(vector unit = cInvalidVector) {
    return (structGetBool(unit, "cavemanExempt")
            && structGetInt(unit, "lineId") >= 0
            && structGetInt(unit, "tier") > 0);
}

int baseVillager(int lineId = -1) {
    for (j = 0; < unitTableCount) {
        vector unit = getUnit(j);
        if (structGetInt(unit, "lineId") == lineId && structGetInt(unit, "tier") == 0) {
            return (structGetInt(unit, "typeId"));
        }
    }
    return (-1);
}

float getVillagerSwapGroup(int baseVillagerId = -1) {
    if (baseVillagerId == PROFESSION_VILLAGER_FEMALE) {
        return (PROFESSION_FEMALE_GROUP);
    }
    return (PROFESSION_MALE_GROUP);
}

void setVillagerSwapGroup(int typeId = -1, float swapGroup = 0.0) {
    xsEffectAmount(cSetAttribute, typeId, cTaskSwapGroup, swapGroup, 1);
}

void evictProfession(vector unit = cInvalidVector, int baseVillagerId = -1) {
    int found = xsGetPlayerUnitIds(1, structGetInt(unit, "typeId"));
    for (i = 0; < xsArrayGetSize(found)) {
        int unitId = xsArrayGetInt(found, i);
        if (unitId < 0 || xsDoesUnitExist(unitId) == false) {
            continue;
        }
        vector position = xsGetUnitPosition(unitId);
        xsRemoveUnit(unitId);
        int created = xsCreateUnit(baseVillagerId, 1, position, false, true, false);
        unitsTransformed = true;
    }
}

void RefreshProfessions() {
    if (professionsReady == false) {
        return;
    }
    for (j = 0; < unitTableCount) {
        vector unit = getUnit(j);
        if (isProfession(unit) == false) {
            continue;
        }
        int baseVillagerId = baseVillager(structGetInt(unit, "lineId"));
        if (baseVillagerId < 0) {
            continue;
        }
        if (hasAllItems(unit)) {
            setVillagerSwapGroup(structGetInt(unit, "typeId"), getVillagerSwapGroup(baseVillagerId));
            continue;
        }
        setVillagerSwapGroup(structGetInt(unit, "typeId"), PROFESSION_NO_GROUP);
        evictProfession(unit, baseVillagerId);
    }
}

void CheckProfessionLocations() {
    if (professionsReady == false) {
        return;
    }
    for (j = 0; < unitTableCount) {
        vector unit = getUnit(j);
        if (isProfession(unit) == false || structGetInt(unit, "owned") > 0) {
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

void EvictProfessions() {
    if (professionsReady == false) {
        return;
    }
    for (j = 0; < unitTableCount) {
        vector unit = getUnit(j);
        if (isProfession(unit) == false || hasAllItems(unit)) {
            continue;
        }
        int baseVillagerId = baseVillager(structGetInt(unit, "lineId"));
        if (baseVillagerId >= 0) {
            evictProfession(unit, baseVillagerId);
        }
    }
}

void InitProfessions() {
    if (AP_US_VILLAGER != VILLAGER_PROFESSIONS || unitsanityReady == false) {
        return;
    }
    professionsReady = true;
    RefreshProfessions();
}
