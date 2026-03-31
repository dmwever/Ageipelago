include "./ProgressionItems.xs";
include "./MercenaryItems.xs";
include "./ResourceItems.xs";
include "./Buildsanity.xs";

const int AP_BUILDING_ITEM_OFFSET = 200;

void GiveItem(int itemId = -1) {
    if (itemId < 25) {
        GiveResource(itemId);
    }
    if (itemId >= 200 && itemId < 300) {
        UnlockBuilding(itemId - AP_BUILDING_ITEM_OFFSET);
    }
    if (itemId >= 1000 && itemId < 3000) {
        GiveProgressionItem(itemId);
    }
    if (itemId >= 4000) {
        GiveMercenary(itemId);
    }
}

void GiveStartupBuildings() {
    bool opened = xsOpenFile("buildings");
    int itemCount = xsGetFileSize() / 4;
    for (i = 0; < itemCount) {
        UnlockBuilding(xsReadInt() - AP_BUILDING_ITEM_OFFSET);
    }
}

void GiveStartupItems() {
    bool opened = xsOpenFile("startup");
    int itemCount = xsGetFileSize() / 4;
    for (i = 0; < itemCount) {
        int itemId = xsReadInt();
        GiveItem(itemId);
    }
    bool closed = xsCloseFile();
}