include "structs.xs";
// Always
const int WONDER = 276;
const int OUTPOST = 598;

// Economy
const int TOWN_CENTER_FOUNDATION = 621;
const int HOUSE = 70;
const int MILL = 68;
const int MINING_CAMP = 584;
const int LUMBER_CAMP = 562;
const int FARM = 50;
const int FISH_TRAP = 199;
const int DOCK = 45;

// Tech
const int MARKET = 84;
const int UNIVERSITY = 209;
const int BLACKSMITH = 103;
const int MONASTERY = 104;

//Military
const int BARRACKS = 12;
const int ARCHERY_RANGE = 87;
const int STABLE = 101;
const int SIEGE_WORKSHOP = 49;
const int CASTLE = 82;

//Defense
const int PALISADE_GATE = 792;
const int GATE = 487;
const int PALISADE_WALL = 72;
const int STONE_WALL = 117;
const int WATCH_TOWER = 79;
const int BOMBARD_TOWER = 236;

// Unique Econ
const int FOLWARK = 1734;
const int MULE_CART = 1808;
const int PASTURE = 1889;
const int HARBOR = 1189;
const int CARAVANSERAI = 1754;
const int FEITORIA = 1021;
const int SETTLEMENT = 2556;

// Unique Mil/Defense
const int FORTIFIED_CHURCH = 1806;
const int KREPOST = 1251;
const int DONJON = 1665;

// Town Centers are a special case: the foundation must be disabled; here we
// keep the id for the town center itself.
const int townCenterId = 109;

vector buildsanity = cInvalidVector;

vector getBuildingByName(int arrayId = -1, string name = "") {
    if (arrayId == -1) {
        xsChatData("ContainsName: No Array Set");
        return (cInvalidVector);
    }

    xsChatData("Array id: %d", arrayId);
    int arraySize = xsArrayGetSize(arrayId);
    xsChatData("Array size: %d", arraySize);

    for (i = 0; < arraySize) {
        vector building = xsArrayGetVector(arrayId, i);
        string buildingName = structGetString(building, "name");
        printStructInstance(building);
        if (buildingName == name) {
            return (building);
        }
    }
    return (cInvalidVector);
}

vector disableBuilding(string buildingName = "", int buildingId = -1, float cost = 0.0) {
    vector building = new("Building");
    structSetString(building, "name", buildingName);
    structSetInt(building, "id", buildingId);
    structSetInt(building, "playerCount", xsGetObjectCount(1, structGetInt(building, "id")));
    structSetFloat(building, "resourceCost", cost);
    xsEffectAmount(cSetAttribute, buildingId, cDisabledFlag, 1, 1);
    return building;
}

void InitBuildsanityStructs() {
    initializeStructsScript();
    defineStruct("Building");
    defineStructAttribute("Building", "name", TYPE_STRING);
    defineStructAttribute("Building", "id", TYPE_INT);
    defineStructAttribute("Building", "playerCount", TYPE_INT);
    defineStructAttribute("Building", "resourceCost", TYPE_FLOAT);

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

    vector wonder = disableBuilding("Wonder", 276, 3000.0);
    xsArraySetVector(buildings, 0, wonder);

    vector outpost = disableBuilding("Outpost", 598, 30.0);
    xsArraySetVector(buildings, 1, outpost);
}

// TC Foundation disabled + Extra Town Centers
void InitBuildsanityEconomy() {
    int buildings = structGetInt(buildsanity, "buildings");

    vector townCenter = disableBuilding("Town Center", 621, 375.0);
    structSetInt(townCenter, "playerCount", xsGetObjectCount(1, townCenterId));
    xsArraySetVector(buildings, 2, townCenter);

    vector house = disableBuilding("House", HOUSE, 25.0);
    xsArraySetVector(buildings, 3, house);

    vector mill = disableBuilding("Mill", MILL, 100.0);
    xsArraySetVector(buildings, 4, mill);
    
    vector miningCamp = disableBuilding("Mining Camp", MINING_CAMP, 100.0);
    xsArraySetVector(buildings, 5, miningCamp);
    
    vector lumberCamp = disableBuilding("Lumber Camp", LUMBER_CAMP, 100.0);
    xsArraySetVector(buildings, 6, lumberCamp);
    
    vector dock = disableBuilding("Dock", DOCK, 150.0);
    xsArraySetVector(buildings, 7, dock);
    
    vector farm = disableBuilding("Farm", FARM, 60.0);
    xsArraySetVector(buildings, 8, farm);
    
    vector fishTrap = disableBuilding("Fish Trap", FISH_TRAP, 100.0);
    xsArraySetVector(buildings, 9, fishTrap);

    vector market = disableBuilding("Market", MARKET, 175.0);
    xsArraySetVector(buildings, 10, market);
}

void InitBuildsanityTech() {
    int buildings = structGetInt(buildsanity, "buildings");

    vector university = disableBuilding("University", UNIVERSITY, 200.0);
    xsArraySetVector(buildings, 11, university);

    vector blacksmith = disableBuilding("Blacksmith", BLACKSMITH, 150.0);
    xsArraySetVector(buildings, 12, blacksmith);

    vector monastery = disableBuilding("Monastery", MONASTERY, 175.0);
    xsArraySetVector(buildings, 13, monastery);
}

void InitBuildsanityMilitary() {
    int buildings = structGetInt(buildsanity, "buildings");

    vector barracks = disableBuilding("Barracks", BARRACKS, 175.0);
    xsArraySetVector(buildings, 14, barracks);

    vector archeryRange = disableBuilding("Archery Range", ARCHERY_RANGE, 175.0);
    xsArraySetVector(buildings, 15, archeryRange);

    vector stable = disableBuilding("Stable", STABLE, 175.0);
    xsArraySetVector(buildings, 16, stable);

    vector siegeWorkshop = disableBuilding("Siege Workshop", SIEGE_WORKSHOP, 200.0);
    xsArraySetVector(buildings, 17, siegeWorkshop);

    vector castle = disableBuilding("Castle", CASTLE, 650.0);
    xsArraySetVector(buildings, 18, castle);
}

void InitBuildsanityDefense() {
    int buildings = structGetInt(buildsanity, "buildings");
    
    vector palisadeGate = addBuilding("Palisade Gate", PALISADE_GATE, 20.0);
    xsArraySetVector(buildings, 19, palisadeGate);

    vector gate = addBuilding("Stone Gate", GATE, 30.0);
    xsArraySetVector(buildings, 20, gate);

    vector palisadeWall = addBuilding("Palisade Wall", PALISADE_WALL, 3.0);
    xsArraySetVector(buildings, 21, palisadeWall);

    vector wall = addBuilding("Stone Wall", STONE_WALL, 5.0);
    xsArraySetVector(buildings, 22, wall);

    vector watchTower = addBuilding("Watch Tower", WATCH_TOWER, 160.0);
    xsArraySetVector(buildings, 23, watchTower);

    vector bombardTower = addBuilding("Bombard Tower", BOMBARD_TOWER, 225.0);
    xsArraySetVector(buildings, 24, bombardTower);
}

void InitBuildsanityUniqueEcon() {
    int buildings = structGetInt(buildsanity, "buildings");

    vector folwark = addBuilding("Folwark", FOLWARK, 100.0);
    xsArraySetVector(buildings, 25, folwark);

    vector muleCart = addBuilding("Mule Cart", MULE_CART, 100.0);
    xsArraySetVector(buildings, 26, muleCart);

    vector pasture = addBuilding("Pasture", PASTURE, 110.0);
    xsArraySetVector(buildings, 27, pasture);

    vector harbor = addBuilding("Harbor", HARBOR, 150.0);
    xsArraySetVector(buildings, 28, harbor);

    vector caravanserai = addBuilding("Caravanserai", CARAVANSERAI, 225.0);
    xsArraySetVector(buildings, 29, caravanserai);

    vector feitoria = addBuilding("Feitoria", FEITORIA, 650.0);
    xsArraySetVector(buildings, 30, feitoria);

    vector settlement = disableBuilding("Settlement", 2556, 125.0);
    xsArraySetVector(buildings, 31, settlement);
}

void InitBuildsanityUniqueMilitaryOrDefense() {
    vector fortifiedChurch = addBuilding("Fortified Church", FORTIFIED_CHURCH, 200.0);
    xsArraySetVector(buildings, 32, fortifiedChurch);

    vector krepost = addBuilding("Krepost", KREPOST, 350.0);
    xsArraySetVector(buildings, 33, krepost);

    vector donjon = addBuilding("Donjon", DONJON, 225.0);
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
        return false;
    }
    vector building = getBuildingByName(buildings, name);
    int built = xsGetObjectCount(1, structGetInt(building, "id"));
    if (built > structGetInt(building, "playerCount")) {
        structSetInt(building, "playerCount", built);
        return true;
    }
    return false;
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
        xsChatData("Castle");
        return;
    }

    if (wondersBuilt > structGetFloat(buildsanity, "wondersBuilt")) {
        structSetFloat(buildsanity, "wondersBuilt", wondersBuilt);
        xsChatData("Wonder");
        return;
    }

    int buildings = structGetInt(buildsanity, "buildings");
    float newBuildingCost = buildingTotalCost - structGetFloat(buildsanity, "currentBuildingTotalCost");

    if (newBuildingCost == 3.0) {
        if (Built(buildings, "Palisade Wall")) {
            xsChatData("Palisade Wall");
        }
    }

    if (newBuildingCost == 5.0) {
        if (Built(buildings, "Stone Wall")) {
            xsChatData("Stone Wall");
        }
    }

    if (newBuildingCost == 20.0) {
        if (Built(buildings, "Palisade Gate")) {
            xsChatData("Palisade Gate");
        }
    }

    if (newBuildingCost == 25.0) {
        if (Built(buildings, "House")) {
            xsChatData("House");
        }
    }
    
    if (newBuildingCost == 30.0) {
        if (Built(buildings, "Stone Gate")) {
            xsChatData("Stone Gate");
        }
        else if (Built(buildings, "Outpost")) {
            xsChatData("Outpost");
        }
    }
    
    if (newBuildingCost == 60.0) {
        if (Built(buildings, "Farm")) {
            xsChatData("Farm");
        }
    }
    
    if (newBuildingCost == 100.0) {
        if (Built(buildings, "Mule Cart")) {
            xsChatData("Mule Cart");
        }
        else if (Built(buildings, "Mill")) {
            xsChatData("Mill");
        }
        else if (Built(buildings, "Lumber Camp")) {
            xsChatData("Lumber Camp");
        }
        else if (Built(buildings, "Mining Camp")) {
            xsChatData("Mining Camp");
        }
        else if (Built(buildings, "Folwark")) {
            xsChatData("Folwark");
        }
        else if (Built(buildings, "Fish Trap")) {
            xsChatData("Fish Trap");
        } 
    }
    
    if (newBuildingCost == 110.0) {
        if (Built(buildings, "Pasture")) {
            xsChatData("Pasture");
        }
    }
    
    if (newBuildingCost == 125.0) {
        if (Built(buildings, "Settlement")) {
            xsChatData("Settlement");
        }
    }
    
    if (newBuildingCost == 150.0) {
        if (Built(buildings, "Blacksmith")) {
            xsChatData("Blacksmith");
        }
        else if (Built(buildings, "Dock")) {
            xsChatData("Dock");
        }
        else if (Built(buildings, "Harbor")) {
            xsChatData("Harbor");
        }
    }

    if (newBuildingCost == 160.0) {
        if (Built(buildings, "Watch Tower")) {
            xsChatData("Watch Tower");
        }
    }

    if (newBuildingCost == 175.0) {
        if (Built(buildings, "Market")) {
            xsChatData("Market");
        }
        else if (Built(buildings, "Monastery")) {
            xsChatData("Monastery");
        }
        else if (Built(buildings, "Barracks")) {
            xsChatData("Barracks");
        }
        else if (Built(buildings, "Archery Range")) {
            xsChatData("Archery Range");
        }
        else if (Built(buildings, "Stable")) {
            xsChatData("Stable");
        }
    }

    if (newBuildingCost == 200.0) {
        if (Built(buildings, "University")) {
            xsChatData("University");
        }
        else if (Built(buildings, "Fortified Church")) {
            xsChatData("Fortified Church");
        }
        else if (Built(buildings, "Siege Workshop")) {
            xsChatData("Siege Workshop");
        }
    }

    if (newBuildingCost == 225.0) {
        if (Built(buildings, "Donjon")) {
            xsChatData("Donjon");
        }
        else if (Built(buildings, "Caravanserai")) {
            xsChatData("Caravanserai");
        }
        else if (Built(buildings, "Bombard Tower")) {
            xsChatData("Bombard Tower");
        }
    }

    if (newBuildingCost == 350.0) {
        if (Built(buildings, "Krepost")) {
            xsChatData("Krepost");
        }
    }

    if (newBuildingCost == 375.0) {
        if (Built(buildings, "Town Center")) {
            xsChatData("Town Center");
        }
    }

    if (newBuildingCost == 650.0) {
        if (Built(buildings, "Feitoria")) {
            xsChatData("Feitoria");
        }
    }

    structSetFloat(buildsanity, "currentBuildingTotalCost", buildingTotalCost);
}

void UnlockBuilding(int ItemId = -1) {
    int buildings = structGetInt(buildsanity, "buildings");

    vector building = xsArrayGetVector(buildings, ItemId);
    
    int id = structGetInt(building, "id");
    xsEffectAmount(cSetAttribute, id, cDisabledFlag, 0, 1);
}