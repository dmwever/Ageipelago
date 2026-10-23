include "./AP_Constants.xs";
include "./SlotData.xs";
include "./AP_Globals.xs";
include "./ItemHandler.xs";
include "./MercenaryLedger.xs";
include "./MercenarySeats.xs";
include "./MercenarySpawn.xs";
include "./APavilion.xs";

int apArrayProbe = -1;

int clientPing = -1;
int lastPing = -1;
int pingRepeatCount = 0;

int completed = 0;
int scenarioId = 0;

int worldMajor = 0;
int worldMinor = 3;
int lastMessageId = -1;
int appliedItemCount = 0;
int scenarioItemsRead = 0;
int reportedMissingItems = 0;
int clientElsewhere = 0;

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
    // Dead weight, kept so ScenarioId stays at byte offset 72 for find_active_campaign.
    for (i = 0; < 12) {
        xsWriteInt(-1);
    }
    xsWriteInt(completed);
    xsWriteInt(scenarioId);
    xsWriteInt(worldMinor);
    xsWriteInt(PendingMercenary());
    xsWriteInt(ConsumedQueueSerial());
    xsWriteInt(appliedItemCount);
    for (i = 0; < 26) {
        xsWriteInt(i);
    }
    int sendingLocations = FilterCompletedNotSent();
    for (i = 0; < filteredCount) {
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

    // The client writes one packet, for whichever scenario it is attached to. During a
    // save/load switch that is not this one -- an expected state, not an install error -- so note
    // it here and act on it below. The checks in between read fields the client fills from the
    // install rather than from the scenario, so they are worth running either way.
    int receivedScenarioId = xsReadInt();
    bool addressedHere = (receivedScenarioId == scenarioId);

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

    int check_seedHigh = xsReadInt();
    int check_seedLow = xsReadInt();
    if (check_seedHigh == -1 && check_seedLow == -1) {
        xsCloseFile();
        return;
    }
    if (check_seedHigh != AP_SEED_HIGH || check_seedLow != AP_SEED_LOW) {
        ReportMismatch("AP Seed",
            "" + check_seedHigh + "-" + check_seedLow,
            "" + AP_SEED_HIGH + "-" + AP_SEED_LOW);
        xsCloseFile();
        return;
    }

    // The install checks out and the packet is simply addressed elsewhere. Say so once per
    // absence, then wait: the client scans for the running scenario and will come back to this one.
    if (addressedHere == false) {
        if (clientElsewhere == 0) {
            clientElsewhere = 1;
            xsChatData("<YELLOW>The AP client is on another scenario. Waiting for it to switch here.");
        }
        xsCloseFile();
        return;
    }
    clientElsewhere = 0;

    int items = xsReadInt();
    if (items == 1) {
        xsEnableRule("ReadItems");
    }
    int free_locations = xsReadInt();
    if (free_locations == 1) {
        xsEnableRule("MarkServerLocations");
    }
    int mercenaries = xsReadInt();
    if (mercenaries == 1) {
        xsEnableRule("ReadMercenaries");
    }
    int messages = xsReadInt();
    if (messages == 1) {
        xsEnableRule("ReadMessages");
    }
    completed = xsReadInt();
    if (completed == 1) {
        AnnounceVictory();
    }
    AckMercenary(xsReadInt());
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
    if (completed == 1) {
        AnnounceVictory();
    }
    for (i = 1; < itemCount) {
        int itemId = xsReadInt();
        GiveItem(itemId);
    }
    xsCloseFile();
    scenarioItemsRead = 1;
}

void GiveVictory() {
    completed = 1;
    AnnounceVictory();
    AP_Write();
}

bool HasVictory() {
    return (completed == 1);
}

rule WriteAP
    inactive
    minInterval 1
    maxInterval 1
{
    AP_Write();
}

rule ReadAP
    inactive
    minInterval 2
    maxInterval 4
{
    AP_Read();
    if (clientPing != lastPing) {
        pingRepeatCount = 0;
    }
    else {
        pingRepeatCount++;
    }

    // A client sitting on another scenario is not disconnected, and it has already said so in
    // yellow. Only warn when the silence is unexplained.
    if (pingRepeatCount >= 5 && clientElsewhere == 0) {
        xsChatData("<RED>AP Client disconnected. Cannot send locations or receive items until connection is reestablised.");
    }
}

void InitAP() {
    if (AP_INITIALIZED == true) {
        if (xsArrayGetSize(apArrayProbe) == 1) {
            return;
        }
        xsChatData("<RED>AP session state was lost. Reinitializing.");
    }

    apArrayProbe = xsArrayCreateInt(1, 0, "ap-array-probe");

    initializeStructsScript();
    InitLocations();
    InitBuildsanity();
    InitAges();
    InitTechsanity();
    InitUnitsanity();
    InitCaveman();
    InitProfessions();
    InitScenarioLocations();
    InitMercenaryLedger();
    InitMercenarySeats();
    InitMercenarySpawn();
    InitTraps();
    InitPavilion();
    xsEnableRule("MercenarySpawnLoop");
    xsEnableRule("WriteAP");
    
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
        GiveStartupBuildings();
        GiveStartupTechs();
        GiveStartupUnits();
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
        xsDisableSelf();
        return;
    }
    int fileInts = xsGetFileSize() / 4; // byte to int
    if (fileInts < 1) {
        xsCloseFile();
        xsDisableSelf();
        return;
    }

    int clientAppliedItems = xsReadInt();
    if (clientAppliedItems != appliedItemCount) {
        xsCloseFile();
        xsDisableSelf();
        return;
    }

    int itemCount = fileInts - 1; // less the header
    // All of it or none: the cursor counts entries, so a partial apply would desync it.
    for (i = 0; < itemCount) {
        GiveItem(xsReadInt());
    }
    appliedItemCount = appliedItemCount + itemCount;
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
        xsDisableSelf();
        return;
    }
    int locationCount = xsGetFileSize() / 4; // byte to int
    for (i = 0; < locationCount) {
        int locationId = xsReadInt();
        if (locationId == -1) {
            continue;
        }

        int locationScenarioId = locationId / 10 / 10;
        if (locationScenarioId < MIN_SCENARIO_ID) {
            vector location = FindLocationById(locationId);
            if (location == cInvalidVector) {
                continue;
            }
            structSetBool(location, "serverComplete", true);
            continue;
        }

        if (locationScenarioId == scenarioId) {
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
        xsDisableSelf();
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

rule ReadMercenaries
    inactive
    minInterval 1
    maxInterval 1
{
    ReadMercenaryQueue();
    xsDisableSelf();
}
