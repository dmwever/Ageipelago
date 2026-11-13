include "./ProgressionItems.xs";
include "./MercenaryItems.xs";
include "./ResourceItems.xs";
include "./Buildsanity.xs";
include "./Ages.xs";
include "./Unitsanity.xs";
include "./Techsanity.xs";
include "./Caveman.xs";
include "./Professions.xs";
include "./TrapItems.xs";

void GiveItem(int itemId = -1) {
    if (itemId == AP_ITEM_SKIP) {
        return;
    }
    if (itemId >= AP_RESOURCE_ITEM_MIN && itemId < AP_RESOURCE_ITEM_MAX) {
        GiveResource(itemId);
        return;
    }
    if (itemId >= AP_AGE_ITEM_MIN && itemId < AP_AGE_ITEM_MAX) {
        UnlockAge(itemId);
        return;
    }
    if (itemId >= AP_BUILDING_ITEM_OFFSET && itemId < AP_BUILDING_ITEM_MAX) {
        UnlockBuilding(itemId - AP_BUILDING_ITEM_OFFSET);
        return;
    }
    if (itemId >= AP_UNIT_ITEM_OFFSET && itemId < AP_UNIT_ITEM_OFFSET + UNIT_ITEM_SPAN) {
        UnlockUnitItem(itemId);
        RefreshProfessions();
        return;
    }
    if (itemId >= AP_PROGRESSION_ITEM_MIN && itemId < AP_PROGRESSION_ITEM_MAX) {
        GiveProgressionItem(itemId);
        return;
    }
    if (itemId >= TECH_ITEM_OFFSET && itemId < AP_TECH_ITEM_MAX) {
        UnlockTech(itemId - TECH_ITEM_OFFSET);
        return;
    }
    if (itemId >= AP_MERC_ITEM_MIN && itemId < AP_MERC_ITEM_MAX) {
        GiveMercenary(itemId);
        return;
    }
    if (itemId >= AP_TRAP_ITEM_MIN && itemId < AP_TRAP_ITEM_MAX) {
        GiveTrap(itemId);
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
        UnlockTech(xsReadInt() - TECH_ITEM_OFFSET, true);
    }
    bool closed = xsCloseFile();
}

void GiveStartupUnits() {
    bool opened = xsOpenFile("units");
    if (opened == false) {
        return;
    }
    int itemCount = xsGetFileSize() / 4; // byte to int
    for (i = 0; < itemCount) {
        UnlockUnitItem(xsReadInt());
    }
    bool closed = xsCloseFile();
    RefreshProfessions();
}