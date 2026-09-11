include "./ProgressionItems.xs";
include "./MercenaryItems.xs";
include "./ResourceItems.xs";
include "./Buildsanity.xs";
include "./Techsanity.xs";

/*        0        Victory
 *        1 -   24 Resources
 *       25 -   29 Ages
 *       30 -  199 Civs
 *      200 -  299 Buildings
 *      300 -  999 Units
 *     1000 - 2999 Scenario progression
 *     3000 - 3499 Progressive scenarios
 *     3500 - 3599 Campaign unlocks
 *     3600 - 3999 Techs
 *     4000 - 4999 Mercenaries
 */
const int AP_RESOURCE_ITEM_MIN    = 1;
const int AP_RESOURCE_ITEM_MAX    = 25;

const int AP_BUILDING_ITEM_OFFSET = 200;
const int AP_BUILDING_ITEM_MAX    = 300;

const int AP_PROGRESSION_ITEM_MIN = 1000;
const int AP_PROGRESSION_ITEM_MAX = 3000;

const int AP_TECH_ITEM_OFFSET     = 3600;
const int AP_TECH_ITEM_MAX        = 4000;

const int AP_MERC_ITEM_MIN        = 4000;
const int AP_MERC_ITEM_MAX        = 5000;

void GiveItem(int itemId = -1) {
    if (itemId >= AP_RESOURCE_ITEM_MIN && itemId < AP_RESOURCE_ITEM_MAX) {
        GiveResource(itemId);
        return;
    }
    if (itemId >= AP_BUILDING_ITEM_OFFSET && itemId < AP_BUILDING_ITEM_MAX) {
        UnlockBuilding(itemId - AP_BUILDING_ITEM_OFFSET);
        return;
    }
    if (itemId >= AP_PROGRESSION_ITEM_MIN && itemId < AP_PROGRESSION_ITEM_MAX) {
        GiveProgressionItem(itemId);
        return;
    }
    if (itemId >= AP_TECH_ITEM_OFFSET && itemId < AP_TECH_ITEM_MAX) {
        UnlockTech(itemId - AP_TECH_ITEM_OFFSET);
        return;
    }
    if (itemId >= AP_MERC_ITEM_MIN && itemId < AP_MERC_ITEM_MAX) {
        GiveMercenary(itemId);
        return;
    }
}

void GiveStartupBuildings() {
    bool opened = xsOpenFile("buildings");
    if (opened == false) {
        return;
    }
    int itemCount = xsGetFileSize() / 4; // byte to int
    for (i = 0; < itemCount) {
        UnlockBuilding(xsReadInt() - AP_BUILDING_ITEM_OFFSET);
    }
    bool closed = xsCloseFile();
}

void GiveStartupTechs() {
    bool opened = xsOpenFile("techs");
    if (opened == false) {
        return;
    }
    int itemCount = xsGetFileSize() / 4; // byte to int
    for (i = 0; < itemCount) {
        UnlockTech(xsReadInt() - TECH_ITEM_OFFSET);
    }
    bool closed = xsCloseFile();
}

void GiveStartupItems() {
    bool opened = xsOpenFile("startup");
    if (opened == false) {
        return;
    }
    int itemCount = xsGetFileSize() / 4; // byte to int
    for (i = 0; < itemCount) {
        int itemId = xsReadInt();
        GiveItem(itemId);
    }
    bool closed = xsCloseFile();
}