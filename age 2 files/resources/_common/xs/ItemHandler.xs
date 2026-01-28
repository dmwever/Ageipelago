

void GiveItem(int itemId = -1) {
    if (itemId <= 25) {
        GiveResource(itemId);
    }
    if (itemId >= 1000 || itemId < 3000) {
        GiveProgressionItem(itemId);
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