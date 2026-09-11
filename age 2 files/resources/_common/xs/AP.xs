include "./ItemHandler.xs";
include "./APavilion.xs";
include "./SlotData.xs";

int itemArray = -1;

int clientPing = -1;
int lastPing = -1;
int pingRepeatCount = 0;

int completed = 0;
int scenarioId = 0;

int worldMajor = 0;
int worldMinor = 3;
int reportedMismatch = 0;
int lastMessageId = -1;
int startupGranted = 0;
int scenarioItemsRead = 0;
int reportedMissingItems = 0;

bool AP_INITIALIZED = false;

bool CheckScenario() {
    bool opened = xsOpenFile("AP");
    if (opened == false) {
        return (false);
    }
    int receivedScenarioId = xsReadInt();
    if (receivedScenarioId != scenarioId) {
        xsCloseFile();
        return (false);
    }
    xsCloseFile();
    return (true);
}

void ReportMismatch(string field = "", string received = "", string expected = "") {
    if (reportedMismatch == 1) {
        return;
    }
    reportedMismatch = 1;
    xsChatData("<RED>Unexpected " + field + " from Client: " + received);
    xsChatData("<RED>Expected " + field + ": " + expected);
    xsChatData("<RED>These scenarios belong to a different seed or player slot. Reinstall the files generated for this slot.");
    xsDisableRule("ReadAP");
}

void AP_Write()
{
    if (AP_SLOT_ID == -1) {
        return;
    }
    bool created = xsCreateFile(false);
    if (created == false) {
        return;
    }
    xsWriteInt(1);
    xsWriteInt(xsGetGameTime());
    xsWriteInt(worldMajor);
    xsWriteInt(AP_SLOT_ID);
    xsWriteInt(lastMessageId);
    for (i = 0; < 12) {
        xsWriteInt(xsArrayGetInt(itemArray, i));
    }
    xsWriteInt(completed);
    xsWriteInt(scenarioId);
    xsWriteInt(worldMinor);
    for (i = 0; < 29) {
        xsWriteInt(i);
    }
    int sendingLocations = FilterCompletedNotSent();
    for (i = 0; < xsArrayGetSize(sendingLocations)) {
        vector location = xsArrayGetVector(sendingLocations, i);
        int locationId = structGetInt(location, "id");
        if (locationId != -1) {
            xsWriteInt(locationId);
        }
    }
    xsCloseFile();
}

void AP_Read()
{
    bool opened = xsOpenFile("AP");
    if (opened == false) {
        return;
    }

    // Check Scenario
    int receivedScenarioId = xsReadInt();
    if (receivedScenarioId != scenarioId) {
        xsChatData("<RED>Wrong Scenario ID from Client: " + receivedScenarioId);
        xsChatData("<RED>Expected Scenario Id: " + scenarioId);
        xsCloseFile();
        return;
    }

    // Update Ping
    lastPing = clientPing;
    clientPing = xsReadInt();
    if (clientPing == lastPing) {
        xsCloseFile();
        return;
    }

    // Check World Version
    int check_worldMajor = xsReadInt();
    int check_worldMinor = xsReadInt();
    if (check_worldMajor != worldMajor || check_worldMinor != worldMinor) {
        ReportMismatch("Age2 version",
            "" + check_worldMajor + "." + check_worldMinor,
            "" + worldMajor + "." + worldMinor);
        xsCloseFile();
        return;
    }

    // Check Slot Id
    int check_slotId = xsReadInt();
    if (check_slotId != AP_SLOT_ID) {
        ReportMismatch("AP Slot Id", "" + check_slotId, "" + AP_SLOT_ID);
        xsCloseFile();
        return;
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
        xsEnableRule("MarkServerLocations");
    }
    int units = xsReadInt();
    int messages = xsReadInt();
    if (messages == 1) {
        xsEnableRule("ReadMessages");
    }
    completed = xsReadInt();
    xsCloseFile();
}

void AP_Check_Location(int locationId = -1)
{
    SetScenarioLocationComplete(locationId);
}

void SetScenarioId(int id = 0) {
    scenarioId = id;
}

void ReadScenarioItemFile(string filename = "") {
    bool openFile = xsOpenFile(filename);
    if (openFile == false) {
        return;
    }
    int itemCount = xsGetFileSize() / 4; // byte to int
    completed = xsReadInt();
    for (i = 1; < itemCount) {
        int itemId = xsReadInt();
        GiveItem(itemId);
    }
    xsCloseFile();
    scenarioItemsRead = 1;
}

void GiveVictory() {
    completed = 1;
    AP_Write();
}

bool HasVictory() {
    return (completed == 1);
}

rule ReadAP
    inactive
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

void InitAP() {
    if (AP_INITIALIZED == true) {
        if (xsArrayGetSize(itemArray) == 12) {
            return;
        }
        xsChatData("<RED>AP session state was lost. Reinitializing.");
    }

    itemArray = xsArrayCreateInt(12, -1, "Item Array");

    initializeStructsScript();
    InitLocations();
    InitBuildsanity();
    InitScenarioLocations();
    xsEffectAmount(cModifyTech, victoryTech, cAttrSetState, cAttributeDisable);

    xsEnableRule("ConnectAP");
    AP_INITIALIZED = true;
}

rule ConnectAP
    inactive
    minInterval 1
    maxInterval 1
{
    if (scenarioId == -1) {
        xsChatData("<RED>Scenario Id is not defined. Please set the Scenario Id before initializing this scenario.");
        return;
    }
    if (AP_SLOT_ID == -1) {
        xsChatData("<RED>This install has no Archipelago slot. Connect the client and run /install.");
        return;
    }
    if (startupGranted == 0) {
        xsChatData("<YELLOW>Waiting for Client Connection");
    }
    if (CheckScenario() == false) {
        return;
    }

    if (startupGranted == 0) {
        xsChatData("<GREEN>Client Connected!");
        GiveStartupItems();
        GiveStartupBuildings();
        startupGranted = 1;
    }

    GiveScenarioItems();
    if (scenarioItemsRead == 0) {
        if (reportedMissingItems == 0) {
            reportedMissingItems = 1;
            xsChatData("<RED>Waiting for this scenario's Archipelago items...");
        }
        return;
    }

    xsEnableRule("ReadAP");
    xsDisableSelf();
}

rule ReadItems
    inactive
    minInterval 1
    maxInterval 1
{
    bool opened = xsOpenFile("items");
    if (opened == false) {
        return;
    }
    int itemCount = xsGetFileSize() / 4; // byte to int
    if (itemCount > 12) {   // itemArray is 12 slots; never index past it
        itemCount = 12;
    }
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
    bool opened = xsOpenFile("free_items");
    if (opened == false) {
        return;
    }
    int freeCount = xsGetFileSize() / 4; // byte to int
    if (freeCount > 12) {
        freeCount = 12;
    }
    int freed = 0;
    for (i = 0; < freeCount) {
        int itemId = xsReadInt();
        if (itemId != -1) {
            freed = 0;
            for (j = 0; < 12) {
                if (freed == 0 && xsArrayGetInt(itemArray, j) == itemId) {
                    xsArraySetInt(itemArray, j, -1);
                    freed = 1;
                }
            }
        }
    }
    xsCloseFile();
    xsDisableSelf();
}

rule MarkServerLocations
    inactive
    minInterval 1
    maxInterval 1
{
    bool opened = xsOpenFile("locations");
    if (opened == false) {
        return;
    }
    int locationCount = xsGetFileSize() / 4; // byte to int
    for (i = 0; < locationCount) {
        int locationId = xsReadInt();
        if (locationId == -1) {
            continue;
        }

        // Scenario locations start with the scenario's location id. values below the minimum scenario id are safe to include.
        int locationScenarioId = locationId / 10 / 10;
        if (locationScenarioId < MIN_SCENARIO_ID || locationScenarioId == scenarioId) {
            SetServerLocationComplete(locationId);
        }
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
    if (opened == false) {
        return;
    }
    int messageCount = xsReadInt();
    int fileLength = xsGetFileSize();
    for (i = 0; < messageCount) {
        int nextMessageId = xsReadInt();

        // IMPORTANT: Use this for hunting down messages that crash AoE2! Comment out xsChatData(message);
        // Do not remove these lines unless you want to fix things the hard way!
        // int filePosition = xsGetFilePosition();
        // xsChatData("Message Id: " + nextMessageId);
        // xsChatData("Position: " + filePosition);
        // int stringLength = xsReadInt();
        // if (stringLength > fileLength - filePosition) {
        //     xsChatData("String is too long: " + stringLength);
        //     return;
        // }
        // bool backToMessageLength = xsSetFilePosition(filePosition);

        string message = xsReadString();
        if (lastMessageId <  nextMessageId) {
            lastMessageId = nextMessageId;
            xsChatData(message);
        }
    }
    xsCloseFile();
    xsDisableSelf();
}