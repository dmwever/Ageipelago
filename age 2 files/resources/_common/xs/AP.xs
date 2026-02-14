include "./ProgressionItems.xs";
include "./MercenaryItems.xs";
include "./ResourceItems.xs";
include "./ItemHandler.xs";


int itemArray = -1;
int locationArray = -1;

int clientPing = -1;
int lastPing = -1;
int pingRepeatCount = 0;

int completed = 0;

float protocol = 6.5;
int worldId = 2;
int lastMessageId = -1;

void AP_init()
{
    itemArray = xsArrayCreateInt(12, -1, "Item Array");
    locationArray = xsArrayCreateInt(0, -1, "Location Array");
    GiveStartupItems();
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
    xsWriteInt(completed);
    for (i = 0; < 30) {
    xsWriteInt(i);
    }
    for (i = 0; < xsArrayGetSize(locationArray)) {
        xsWriteInt(xsArrayGetInt(locationArray, i));
    }
    xsCloseFile();
}

void AP_Read()
{
    bool opened = xsOpenFile("AP");
    lastPing = clientPing;
    clientPing = xsReadInt();
    if (clientPing == lastPing) {
        return;
    }
    int check_protocol = xsReadFloat();
    if (check_protocol != protocol) {
        xsChatData("<RED>Unexpected AP World Protocol from Client: %d", check_protocol);
        xsChatData("<RED>Expected Protocol: %d", protocol);
    }
    int check_worldId = xsReadInt();
    if (check_worldId != worldId) {
        xsChatData("<RED>Unexpected AP World ID from Client: %d", check_worldId);
        xsChatData("<RED>Expected World ID: %d", worldId);
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
    if (messages == 1) {
        xsEnableRule("ReadMessages");
    }
    xsCloseFile();
}

void AP_Check_Location(int locationId = -1)
{
    int locationSize = xsArrayGetSize(locationArray);
    xsArrayResizeInt(locationArray, locationSize + 1);
    xsArraySetInt(locationArray, locationSize, locationId);
}

void ScenarioSpecificInit(string filename = "") {
  bool openFile = xsOpenFile(filename);
  int itemCount = xsGetFileSize() / 4;
  completed = xsReadInt();
  for (i = 1; < itemCount) {
    int itemId = xsReadInt();
    GiveItem(itemId);
  }
  xsCloseFile();
}

void GiveVictory() {
    completed = 1;
}

rule ReadAP
    active
    minInterval 2
    maxInterval 4
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

rule ReadMessages
    inactive
    minInterval 1
    maxInterval 1
{
    bool opened = xsOpenFile("messages");
    int messageCount = xsReadInt();
    for (i = 0; < messageCount) {
        int nextMessageId = xsReadInt();
        string message = xsReadString();
        if (lastMessageId <  nextMessageId) {
            lastMessageId = nextMessageId;
            xsChatData(message);
        }
    }
    xsCloseFile();
    xsDisableSelf();
}