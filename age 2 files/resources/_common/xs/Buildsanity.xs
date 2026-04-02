include "structs.xs";
include "AP_Headers.xs";
include "AP_Constants.xs";

vector buildsanity = cInvalidVector;

vector getBuildingByName(int arrayId = -1, string name = "") {
    if (arrayId == -1) {
        xsChatData("ContainsName: No Array Set");
        return (cInvalidVector);
    }

    int arraySize = xsArrayGetSize(arrayId);

    for (i = 0; < arraySize) {
        vector building = xsArrayGetVector(arrayId, i);
        string buildingName = structGetString(building, "name");
        if (buildingName == name) {
            return (building);
        }
    }
    return (cInvalidVector);
}

int getBuildingsByCost(int arrayId = -1, float cost = -1.0) {
    if (arrayId == -1) {
        xsChatData("getBuildingsByCost: No Array Set");
        return (-1);
    }

    int arraySize = xsArrayGetSize(arrayId);
    
    int filteredArray = xsArrayCreateVector(10, cInvalidVector);

    int j = 0;
    for (i = 0; < arraySize) {
        vector building = xsArrayGetVector(arrayId, i);
        float buildingCost = structGetFloat(building, "resourceCost");
        xsChatData("getBuildingsByCost: " + structGetString(building, "name") + " Cost = " + buildingCost);
        if (buildingCost == cost) {
            xsArraySetVector(filteredArray, j, building);
            j = j + 1;
        }
    }

    return (filteredArray);
}

vector disableBuilding(string buildingName = "", int buildingId = -1, float cost = 0.0, int locationId = -1) {
    vector building = new("Building");
    structSetString(building, "name", buildingName);
    structSetInt(building, "id", buildingId);
    structSetInt(building, "playerCount", xsGetObjectCount(1, structGetInt(building, "id")));
    structSetFloat(building, "resourceCost", cost);
    structSetInt(building, "locationId", locationId);
    xsEffectAmount(cSetAttribute, buildingId, cDisabledFlag, 1.0, 1);
    return (building);
}

void InitBuildsanityStructs() {
    initializeStructsScript();
    defineStruct("Building");
    defineStructAttribute("Building", "name", TYPE_STRING);
    defineStructAttribute("Building", "id", TYPE_INT);
    defineStructAttribute("Building", "playerCount", TYPE_INT);
    defineStructAttribute("Building", "resourceCost", TYPE_FLOAT);
    defineStructAttribute("Building", "locationId", TYPE_INT);

    defineStruct("Buildsanity");
    defineStructAttribute("Buildsanity", "buildings", TYPE_STRUCT_ARRAY);
    defineStructAttribute("Buildsanity", "currentBuildingTotalCost", TYPE_FLOAT);
    defineStructAttribute("Buildsanity", "CastlesBuilt", TYPE_FLOAT);
    defineStructAttribute("Buildsanity", "wondersBuilt", TYPE_FLOAT);

    buildsanity = new("Buildsanity");
    int buildings = xsArrayCreateVector(50, cInvalidVector, "p1-buildings");
    structSetInt(buildsanity, "buildings", buildings);
}

void InitBuildsanityAlways() {
    int buildings = structGetInt(buildsanity, "buildings");

    vector wonder = disableBuilding("Wonder", WONDER, 3000.0, 200);
    xsArraySetVector(buildings, 0, wonder);

    vector outpost = disableBuilding("Outpost", OUTPOST, 30.0, 201);
    xsArraySetVector(buildings, 1, outpost);
}

// TC Foundation disabled + Extra Town Centers
void InitBuildsanityEconomy() {
    int buildings = structGetInt(buildsanity, "buildings");

    vector townCenter = disableBuilding("Town Center", 621, 275.0, 202);
    structSetInt(townCenter, "playerCount", xsGetObjectCount(1, townCenterId));
    xsArraySetVector(buildings, 2, townCenter);

    vector house = disableBuilding("House", HOUSE, 25.0, 203);
    xsArraySetVector(buildings, 3, house);

    vector mill = disableBuilding("Mill", MILL, 100.0, 204);
    xsArraySetVector(buildings, 4, mill);
    
    vector miningCamp = disableBuilding("Mining Camp", MINING_CAMP, 100.0, 205);
    xsArraySetVector(buildings, 5, miningCamp);
    
    vector lumberCamp = disableBuilding("Lumber Camp", LUMBER_CAMP, 100.0, 206);
    xsArraySetVector(buildings, 6, lumberCamp);
    
    vector dock = disableBuilding("Dock", DOCK, 150.0, 207);
    xsArraySetVector(buildings, 7, dock);
    
    vector farm = disableBuilding("Farm", FARM, 60.0, 208);
    xsArraySetVector(buildings, 8, farm);
    
    vector fishTrap = disableBuilding("Fish Trap", FISH_TRAP, 100.0, 209);
    xsArraySetVector(buildings, 9, fishTrap);

    vector market = disableBuilding("Market", MARKET, 175.0, 210);
    xsArraySetVector(buildings, 10, market);
}

void InitBuildsanityTech() {
    int buildings = structGetInt(buildsanity, "buildings");

    vector university = disableBuilding("University", UNIVERSITY, 200.0, 211);
    xsArraySetVector(buildings, 11, university);

    vector blacksmith = disableBuilding("Blacksmith", BLACKSMITH, 150.0, 212);
    xsArraySetVector(buildings, 12, blacksmith);

    vector monastery = disableBuilding("Monastery", MONASTERY, 175.0, 213);
    xsArraySetVector(buildings, 13, monastery);
}

void InitBuildsanityMilitary() {
    int buildings = structGetInt(buildsanity, "buildings");

    vector barracks = disableBuilding("Barracks", BARRACKS, 175.0, 214);
    xsArraySetVector(buildings, 14, barracks);

    vector archeryRange = disableBuilding("Archery Range", ARCHERY_RANGE, 175.0, 215);
    xsArraySetVector(buildings, 15, archeryRange);

    vector stable = disableBuilding("Stable", STABLE, 175.0, 216);
    xsArraySetVector(buildings, 16, stable);

    vector siegeWorkshop = disableBuilding("Siege Workshop", SIEGE_WORKSHOP, 200.0, 217);
    xsArraySetVector(buildings, 17, siegeWorkshop);

    vector castle = disableBuilding("Castle", CASTLE, 650.0, 218);
    xsArraySetVector(buildings, 18, castle);
}

void InitBuildsanityDefense() {
    int buildings = structGetInt(buildsanity, "buildings");
    
    vector palisadeGate = disableBuilding("Palisade Gate", PALISADE_GATE, 20.0, 219);
    xsArraySetVector(buildings, 19, palisadeGate);

    vector gate = disableBuilding("Stone Gate", GATE, 30.0, 220);
    xsArraySetVector(buildings, 20, gate);

    vector palisadeWall = disableBuilding("Palisade Wall", PALISADE_WALL, 3.0, 221);
    xsArraySetVector(buildings, 21, palisadeWall);

    vector wall = disableBuilding("Stone Wall", STONE_WALL, 5.0, 222);
    xsArraySetVector(buildings, 22, wall);

    vector watchTower = disableBuilding("Watch Tower", WATCH_TOWER, 160.0, 223);
    xsArraySetVector(buildings, 23, watchTower);

    vector bombardTower = disableBuilding("Bombard Tower", BOMBARD_TOWER, 225.0, 224);
    xsArraySetVector(buildings, 24, bombardTower);
}

void InitBuildsanityUniqueEcon() {
    int buildings = structGetInt(buildsanity, "buildings");

    vector folwark = disableBuilding("Folwark", FOLWARK, 100.0, 225);
    xsArraySetVector(buildings, 25, folwark);

    vector muleCart = disableBuilding("Mule Cart", MULE_CART, 100.0, 226);
    xsArraySetVector(buildings, 26, muleCart);

    vector pasture = disableBuilding("Pasture", PASTURE, 110.0, 227);
    xsArraySetVector(buildings, 27, pasture);

    vector harbor = disableBuilding("Harbor", HARBOR, 150.0, 228);
    xsArraySetVector(buildings, 28, harbor);

    vector caravanserai = disableBuilding("Caravanserai", CARAVANSERAI, 225.0, 229);
    xsArraySetVector(buildings, 29, caravanserai);

    vector feitoria = disableBuilding("Feitoria", FEITORIA, 650.0, 230);
    xsArraySetVector(buildings, 30, feitoria);

    vector settlement = disableBuilding("Settlement", 2556, 125.0, 231);
    xsArraySetVector(buildings, 31, settlement);
}

void InitBuildsanityUniqueMilitaryOrDefense() {
    int buildings = structGetInt(buildsanity, "buildings");

    vector fortifiedChurch = disableBuilding("Fortified Church", FORTIFIED_CHURCH, 200.0, 232);
    xsArraySetVector(buildings, 32, fortifiedChurch);

    vector krepost = disableBuilding("Krepost", KREPOST, 350.0, 233);
    xsArraySetVector(buildings, 33, krepost);

    vector donjon = disableBuilding("Donjon", DONJON, 225.0, 234);
    xsArraySetVector(buildings, 34, donjon);
}

void InitBuildsanity(bool econ = false, bool tech = false, bool mil = false, bool def = false, bool unique = false) {
    xsChatData("This Should Only Appear Once: %d", econ);
    InitBuildsanityStructs();
    InitBuildsanityAlways();
    if (econ == true) {
        InitBuildsanityEconomy();
    }
    if (tech == true) {
        InitBuildsanityTech();
    }
    if (mil == true) {
        InitBuildsanityMilitary();
    }
    if (def == true) {
        InitBuildsanityDefense();
    }
    if (unique == true) {
        if (econ == false && mil == false && def == false) {
            InitBuildsanityUniqueEcon();
            InitBuildsanityUniqueMilitaryOrDefense();
        }
        else {
            if (econ == true) {
                InitBuildsanityUniqueEcon();
            }
            if (mil == true || def == true) {
                InitBuildsanityUniqueMilitaryOrDefense();
            }
        }
    }
    xsEnableRule("BuildsanityChecks");
}

bool Built(int buildings = -1, string name = "") {
    if (name == "" || buildings == -1) {
        return (false);
    }
    vector building = getBuildingByName(buildings, name);
    int built = xsGetObjectCount(1, structGetInt(building, "id"));
    if (name == "Town Center") {
        built = xsGetObjectCount(1, townCenterId);
    } 
    if (built > structGetInt(building, "playerCount")) {
        return (true);
    }
    return (false);
}

void updateCosts(int buildings = -1) {
    for (i = 0; < xsArrayGetSize(buildings)) {
        vector building = xsArrayGetVector(buildings, i);
        int built = xsGetObjectCount(1, structGetInt(building, "id"));
        if (structGetString(building, "name") == "Town Center") {
            built = xsGetObjectCount(1, townCenterId);
        }
        if (built > structGetInt(building, "playerCount")) {
            structSetInt(building, "playerCount", built);
        }
    }
}

rule BuildsanityChecks
    inactive
    group Buildsanity
    highFrequency
{
    float buildingTotalCost = xsPlayerAttribute(1, cAttributeValueCurrentBuildings);
    float castlesBuilt = xsPlayerAttribute(1, cAttributeTotalCastlesBuilt);
    float wondersBuilt = xsPlayerAttribute(1, cAttributeTotalWondersBuilt);

    if (structGetFloat(buildsanity, "currentBuildingTotalCost") > buildingTotalCost) {
        structSetFloat(buildsanity, "currentBuildingTotalCost", buildingTotalCost);
        return;
    }

    if (castlesBuilt > structGetFloat(buildsanity, "castlesBuilt")) {
        structSetFloat(buildsanity, "castlesBuilt", castlesBuilt);
        AP_Check_Location(200);
        return;
    }

    if (wondersBuilt > structGetFloat(buildsanity, "wondersBuilt")) {
        structSetFloat(buildsanity, "wondersBuilt", wondersBuilt);
        AP_Check_Location(201);
        return;
    }
    
    if (structGetFloat(buildsanity, "currentBuildingTotalCost") == buildingTotalCost) {
        updateCosts(structGetInt(buildsanity, "buildings"));
        return;
    }

    int buildings = structGetInt(buildsanity, "buildings");
    float newBuildingCost = buildingTotalCost - structGetFloat(buildsanity, "currentBuildingTotalCost");

    xsChatData("Debug: Building Built. Cost: " + newBuildingCost);

    int buildingsAtCost = getBuildingsByCost(buildings, newBuildingCost);
    for (i = 0; < xsArrayGetSize(buildingsAtCost)) {
        vector building = xsArrayGetVector(buildingsAtCost, i);
        printStructInstance(building);
        xsChatData(structGetString(building, "name"));
        if (Built(buildings, structGetString(building, "name"))) {
            AP_Check_Location(structGetInt(building, "locationId"));
        }
    }

    updateCosts(buildings);

    structSetFloat(buildsanity, "currentBuildingTotalCost", buildingTotalCost);
}

void checkPrerequisites(vector building = cInvalidVector) {
    if (building == cInvalidVector) {
        xsChatData("checkPrerequisites: Building not found.");
    }

    string name = structGetString(building, "name");

    // Dark
    if (name == "Farm") {
        if (xsGetObjectCount(1, MILL) > 0) {
            xsChatData("Unlock Farm Please");
            xsEffectAmount(cEnableObject, FARM, cAttributeEnable, 1.0, 1);
        }
    }

    //Feudal
    if (name == "Stable" || name == "Archery Range") {
        if (xsGetObjectCount(1, BARRACKS) > 0 && xsGetTechState(101, 1) == cTechStateDone) {
            xsChatData("Unlock Stable/Arch Please");
            xsEffectAmount(cEnableObject, structGetInt(building, "id"), cAttributeEnable, 1.0, 1);
        }
    }

    if (name == "Blacksmith") {
        if (xsGetTechState(101, 1) == cTechStateDone) {
            xsChatData("Unlock Smith Please");
            xsEffectAmount(cEnableObject, BLACKSMITH, cAttributeEnable, 1.0, 1);
        }
    }

    if (name == "Market") {
        if (xsGetObjectCount(1, MILL) > 0 && xsGetTechState(101, 1) == cTechStateDone) {
            xsChatData("Unlock Market Please");
            xsEffectAmount(cEnableObject, MARKET, cAttributeEnable, 1.0, 1);
        }
    }

    // Castle
    if (name == "Siege Workshop") {
        if (xsGetObjectCount(1, BLACKSMITH) > 0 && xsGetTechState(102, 1) == cTechStateDone) {
            xsChatData("Unlock Siege Please");
            xsEffectAmount(cEnableObject, SIEGE_WORKSHOP, cAttributeEnable, 1.0, 1);
        }
    }

    if (name == "Monastery" || name == "University" || name == "Castle") {
        if (xsGetTechState(102, 1) == cTechStateDone) {
            xsChatData("Unlock Castle Age Please");
            xsEffectAmount(cEnableObject, structGetInt(building, "id"), cAttributeEnable, 1.0, 1);
        }
    }
}

void UnlockBuilding(int index = -1) {
    int buildings = structGetInt(buildsanity, "buildings");

    vector building = xsArrayGetVector(buildings, index);
    
    int id = structGetInt(building, "id");
    xsEffectAmount(cSetAttribute, id, cDisabledFlag, 0.0, 1);

    checkPrerequisites(building);
}