include "structs.xs";
include "./ScenarioLocations.xs";

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

mutable void AP_Check_Location(int locationId = -1) {
    xsChatData("<RED>AP_Check_Location is still the stub, so location " + locationId
               + " goes nowhere. AP.xs did not define it.");
}

mutable void ApplyCaveman(int units = -1) {
}

mutable void CheckProfessionLocations() {
    xsChatData("<RED>CheckProfessionLocations is still the stub, so a villager changing task"
               + " sends no check. Professions.xs did not define it.");
}

mutable void EvictProfessions() {
}

mutable void CavemanExemption() {
}

mutable void InitScenarioLocations() {
    xsChatData("<RED>This scenario does not define InitScenarioLocations, so it registers no"
               + " locations and can never send a check.");
}

mutable void GiveScenarioItems() {
    xsChatData("<RED>This scenario does not define GiveScenarioItems, so its item file is never"
               + " read and nothing arrives.");
}

mutable void SetScenarioAge() {
    xsChatData("<RED>This scenario does not define SetScenarioAge.");
}

mutable void addTech(int itemId = -1, int id = -1, int effectId = -1, int civ = -1,
                     int isUpgrade = 0, int isUnique = 0, int age = 0, int isLocation = 1,
                     int prerequisiteId = -1) {
    xsChatData("<RED>addTech is still the stub, so tech " + id + " is being discarded."
               + " Techsanity.xs did not define it.");
}

mutable void addUnit(int locationId = -1, int typeId = -1, int lineId = -1, int age = 0,
             int tier = 0, int upgradeItemId = -1, int cavemanExempt = 0) {
    xsChatData("<RED>addUnit is still the stub, so unit location " + locationId + " is being discarded."
               + " Unitsanity.xs did not define it.");
}

mutable void addUnitUntrainable(int typeId = -1, int civId = -1) {
    xsChatData("<RED>addUnitUntrainable is still the stub, so unit " + typeId + " is being left"
               + " trainable. Unitsanity.xs did not define it.");
}

mutable void addUnitItem(int typeId = -1, int itemId = -1) {
    xsChatData("<RED>addUnitItem is still the stub, so unit item " + itemId + " is being discarded."
               + " Unitsanity.xs did not define it.");
}

mutable void addUnitVariant(int typeId = -1, int variantId = -1) {
    xsChatData("<RED>addUnitVariant is still the stub, so unit variant " + variantId + " is being discarded."
               + " Unitsanity.xs did not define it.");
}

mutable void SetPavilionLayout() {
    xsChatData("<RED>This scenario does not define SetPavilionLayout, so it gets no pavilion,"
               + " no victory button and no mercenary seats.");
}

mutable bool HasPavilionPlacement() {
    xsChatData("<RED>HasPavilionPlacement is still the stub. APavilion.xs did not define it, so"
               + " nothing will believe the pavilion was placed.");
    return (false);
}

mutable vector PavilionSpawnPoint() {
    xsChatData("<RED>PavilionSpawnPoint is still the stub. APavilion.xs did not define it, so"
               + " mercenaries would be placed at an invalid position.");
    return (cInvalidVector);
}

mutable vector PavilionMusterPoint() {
    xsChatData("<RED>PavilionMusterPoint is still the stub. APavilion.xs did not define it, so"
               + " mercenaries would be tasked to an invalid position.");
    return (cInvalidVector);
}
