const float PROFESSION_MALE_GROUP = 1.0;
const float PROFESSION_FEMALE_GROUP = 2.0;
const float PROFESSION_NO_GROUP = 0.0;
const int PROFESSION_VILLAGER_FEMALE = 293;

int professionScan = -1;
bool professionsReady = false;

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
    int typeId = structGetInt(unit, "typeId");
    int found = xsGetPlayerUnitIds(1, typeId, professionScan);
    for (i = 0; < xsArrayGetSize(found)) {
        int unitId = xsArrayGetInt(found, i);
        if (unitId < 0) {
            continue;
        }
        vector position = xsGetUnitPosition(unitId);
        xsRemoveUnit(unitId);
        int created = xsCreateUnit(baseVillagerId, 1, position, false, true, false);
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

void InitProfessions() {
    if (AP_US_VILLAGER != VILLAGER_PROFESSIONS || unitsanityReady == false) {
        return;
    }
    professionScan = xsArrayCreateInt(1, -1, "pr-scan");
    professionsReady = true;
    RefreshProfessions();
    xsEnableRule("ProfessionSweep");
}

rule ProfessionSweep
    inactive
    group Unitsanity
    minInterval 1
    maxInterval 1
{
    RefreshProfessions();
}
