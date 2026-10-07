include "./FillerData.xs";

int fillerIds = -1;
int fillerKinds = -1;
int fillerThresholds = -1;
int fillerCount = 0;

bool fillerReady = false;

int fillerScan = -1;

void addFillerLocation(int id = -1, int kind = -1, int threshold = 0) {
    if (fillerCount >= FILLER_CAPACITY || id < 1) {
        return;
    }
    if (AddLocation(id) == cInvalidVector) {
        xsChatData("<RED>addFillerLocation: not enough struct space to add filler. Expand struct instance count.");
        return;
    }
    xsArraySetInt(fillerIds, fillerCount, id);
    xsArraySetInt(fillerKinds, fillerCount, kind);
    xsArraySetInt(fillerThresholds, fillerCount, threshold);
    fillerCount = fillerCount + 1;
}

float ownedCount() {
    int units = xsGetPlayerUnitIds(1, -1, fillerScan);
    return (1.0 * xsArrayGetSize(units));
}

float counterFor(int kind = -1) {
    if (kind == FILLER_EXPLORE) {
        return (xsPlayerAttribute(1, ATTR_EXPLORATION));
    }
    if (kind == FILLER_KILL_UNITS) {
        return (xsPlayerAttribute(1, ATTR_KILLS));
    }
    if (kind == FILLER_RAZE_BUILDINGS) {
        return (xsPlayerAttribute(1, ATTR_RAZINGS));
    }
    if (kind == FILLER_CONVERT_UNITS) {
        return (xsPlayerAttribute(1, ATTR_CONVERSIONS));
    }
    if (kind == FILLER_OWN_UNITS) {
        return (ownedCount());
    }
    return (-1.0);
}

void checkFillerLocations() {
    for (i = 0; < fillerCount) {
        int id = xsArrayGetInt(fillerIds, i);
        if (IsScenarioLocationComplete(id) == false) {
            float have = counterFor(xsArrayGetInt(fillerKinds, i));
            if (have >= 1.0 * xsArrayGetInt(fillerThresholds, i)) {
                AP_Check_Location(id);
            }
        }
    }
}

void InitFiller() {
    if (FILLER_SEED_HIGH == -1 && FILLER_SEED_LOW == -1) {
        return;
    }
    if (FILLER_SEED_HIGH != AP_SEED_HIGH || FILLER_SEED_LOW != AP_SEED_LOW) {
        xsChatData("<RED>Milestones: filler data is from the wrong seed. Run /install in the Age 2 client.");
        return;
    }

    fillerIds = xsArrayCreateInt(FILLER_CAPACITY, -1, "fl-ids");
    fillerKinds = xsArrayCreateInt(FILLER_CAPACITY, -1, "fl-kinds");
    fillerThresholds = xsArrayCreateInt(FILLER_CAPACITY, 0, "fl-thresholds");
    fillerCount = 0;

    LoadFillerTable();

    fillerReady = fillerCount > 0;
    if (fillerReady) {
        xsEnableRule("FillerChecks");
    }
}

rule FillerChecks
    inactive
    group Filler
    minInterval 1
    maxInterval 1
{
    if (fillerReady == false || startupGranted == 0) {
        return;
    }
    checkFillerLocations();
}
