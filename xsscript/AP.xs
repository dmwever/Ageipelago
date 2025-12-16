include "./ProgressionItems.xs";
include "./ResourceItems.xs";


int itemArray = -1;
int locationArray = -1;

int clientPing = -1;
int lastPing = -1;
int pingRepeatCount = 0;

float protocol = 6.5;
int worldId = 2;
int lastMessageId = -1;

void AP_init()
{
    itemArray = xsArrayCreateInt(12, -1, "Item Array");
    locationArray = xsArrayCreateInt(0, -1, "Location Array");
}

void AP_Write()
{
    xsCreateFile(false);
    xsWriteInt(1);
    xsWriteInt(xsGetGameTime());
    xsWriteFloat(protocol);
    xsWriteInt(worldId); 
    xsWriteInt(lastMessageId);
    for (i = 0; < 12) {
        xsWriteInt(xsArrayGetInt(itemArray, i));
    }
    for (i = 0; < 31) {
    xsWriteInt(i);
    }
    for (i = 0; < xsArrayGetSize(locationArray)) {
        xsWriteInt(xsArrayGetInt(locationArray, i));
    }
    xsCloseFile();
}

void AP_Read()
{
    xsOpenFile("AP");
    clientPing = xsReadInt();
    int check_protocol = xsReadFloat();
    if (check_protocol != protocol) {
        xsChatData("Unexpected AP World Protocol from Client: %d", check_protocol);
        xsChatData("Expected Protocol: %d", protocol);
    }
    int check_worldId = xsReadInt();
    if (check_worldId != worldId) {
        xsChatData("Unexpected AP World ID from Client: %d", check_worldId);
        xsChatData("Expected World ID: %d", worldId);
    }
    int items = xsReadInt();
    if (items == 1) {
        xsEnableRule("ReadItems");
    }
    int free_items = xsReadInt();
    if (free_items == 1) {
        xsEnableRule("FreeItems");
    }
    int free_locations = xsReadInt();
    if (free_locations == 1) {
        xsEnableRule("FreeLocations");
    }
    int units = xsReadInt();
    int messages = xsReadInt();
    xsCloseFile();
}

void AP_Check_Location(int locationId = -1)
{
    xsChatData("Location Id : %d", locationId);
    int locationSize = xsArrayGetSize(locationArray);
    xsChatData("Location Array Size : %d", locationSize);
    xsArrayResizeInt(locationArray, locationSize + 1);
    xsArraySetInt(locationArray, locationSize, locationId);
    xsChatData("Location Id : %d", xsArrayGetInt(locationArray, locationSize));
}

void GiveItem(int itemId = -1) {
    if (itemId <= 25) {
        GiveResource(itemId);
    }
    if (itemId >= 1000 || itemId < 3000) {
        GiveProgressionItem(itemId);
    }
}

// This rule prints the value of a every 2 seconds.
rule ReadAP
    active
    minInterval 1
    maxInterval 1
{
    AP_Read();
    if (clientPing > lastPing) {
        pingRepeatCount = 0;
    }
    else {
        pingRepeatCount++;
    }

    if (pingRepeatCount >= 5) {
        xsChatData("<RED>AP Client disconnected. Cannot send locations or receive items until connection is reestablised.");
    }
}

rule ReadItems
    inactive
    minInterval 1
    maxInterval 1
{
    xsOpenFile("items");
    int itemCount = xsGetFileSize();
    for (i = 0; < itemCount) {
        int itemId = xsReadInt();
        if (xsArrayGetInt(itemArray, i) == -1) {
            GiveItem(itemId);
            xsArraySetInt(itemArray, i, itemId);
        }
    }
    xsCloseFile();
    xsDisableSelf();
}

rule FreeItems
    inactive
    minInterval 1
    maxInterval 1
{
    xsOpenFile("free_items");
    for (i = 0; < 12) {
        int itemId = xsReadInt();
        if (itemId == -1) {
            continue;
        }
        for (j = 0; < 12) {
            if (xsArrayGetInt(itemArray, i) == itemId) {
                xsArraySetInt(itemArray, i, -1);
            }
        }
    }
    xsCloseFile();
    xsDisableSelf();
}

rule FreeLocations
    inactive
    minInterval 1
    maxInterval 1
{
    xsOpenFile("locations");
    int locationCount = xsGetFileSize();
    for (i = 0; < locationCount) {
        int locationId = xsReadInt();
        int arraySize = xsArrayGetSize(locationArray);
        for (j = 0; < arraySize - 1) {
            if (xsArrayGetInt(locationArray, j) == locationId) {
                int nextLocation = xsArrayGetInt(locationArray, j + 1);
                xsArraySetInt(locationArray, j, nextLocation);
                xsArraySetInt(locationArray, j + 1, locationId);
            }
        }
        xsArrayResizeInt(locationArray, arraySize - 1);
    }
    xsCloseFile();
    xsDisableSelf();
}