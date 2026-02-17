// Always
const int wonder = 276;
const int outpost = 276;

// Economy
const int townCenterFoundation = 621;
const int startingTownCenter = 218;
const int house = 70;
const int mill = 68;
const int miningCamp = 584;
const int lumberCamp = 562;
const int farm = 50;
const int fishTrap = 199;
const int dock = 45;    //Also disable with military

//Tech
const int market = 84;
const int university = 209;
const int blacksmith = 103;
const int monastery = 84;

//Military
const int barracks = 12;
const int archeryRange = 87;
const int stable = 101;
const int siegeWorkshop = 49;
const int castle = 82; // Also disable with defense

//Defense
const int palisadeGate = 792;
const int gate = 487;
const int palisadeWall = 72;
const int wall = 117;
const int watchTower = 79;
const int bombardTower = 236;

//Unique Economy
const int folwark = 1734;
const int muleCart = 1808;
const int pasture = 1889;
const int harbor = 1189;    //Also disable with military
const int caravanserai = 1021;
const int feitoria = 1021;

//Unique Military
const int fortifiedChurch = 1806; // Also disable with defense
const int krepost = 1251; // Also disable with defense
const int donjon = 1665; // Also disable with defense

void InitBuildsanityAlways() {
    xsEffectAmount(cEnableObject, wonder, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, outpost, cAttributeDisable, 0, 1);
}

// TC Foundation disabled + Extra Town Centers
void InitBuildsanityEconomy() {
    xsEffectAmount(cEnableObject, townCenterFoundation, cAttributeDisable, 0, 1);
    xsEffectAmount(cModResource, startingTownCenter, cAttributeSet, 0, 1);
    xsEffectAmount(cEnableObject, house, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, mill, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, miningCamp, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, lumberCamp, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, muleCart, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, dock, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, harbor, cAttributeDisable, 0, 1);
}

void InitBuildsanityTech() {
    xsEffectAmount(cEnableObject, market, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, university, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, blacksmith, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, monastery, cAttributeDisable, 0, 1);
}

void InitBuildsanityMilitary() {
    xsEffectAmount(cEnableObject, barracks, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, archeryRange, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, siegeWorkshop, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, stable, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, castle, cAttributeDisable, 0, 1);
}

void InitBuildsanityDefense() {
    xsEffectAmount(cEnableObject, 792, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, 487, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, 72, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, 117, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, 79, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, 236, cAttributeDisable, 0, 1);
}

void InitBuildsanityUniqueEcon() {

}

void InitBuildsanityUniqueMilitaryOrDefense() {
    
}

void InitBuildsanity(bool econ = false, bool tech = false, bool mil = false, bool def = false, bool unique = false) {
    InitBuildsanityAlways();
    if (econ == true) {
        InitBuildsanityEconomy();
    }
    if (tech == true) {
        InitBuildsanityMilitary();
    }
    if (mil == true) {
        InitBuildsanityMilitary();
    }
    if (def == true) {
        InitBuildsanityMilitary();
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
}