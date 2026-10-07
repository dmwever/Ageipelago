include "./FillerData.xs";

int fillerIds = -1;
int fillerKinds = -1;
int fillerThresholds = -1;
int fillerCount = 0;

bool fillerReady = false;

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
}
