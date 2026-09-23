include "structs.xs";
include "./ScenarioLocations.xs";

mutable void AP_Check_Location(int locationId = -1) {
    xsChatData("<RED>AP_Check_Location is still the stub, so location " + locationId
               + " goes nowhere. AP.xs did not define it.");
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
