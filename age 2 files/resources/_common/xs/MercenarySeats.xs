// One "Seat" instance per seat, kept in seat order so a seat index is still a position. The unit
// list stays an xsArray handle stored on the instance: that is how the struct library holds array
// attributes, so TYPE_INT_ARRAY is read and written with structGetInt/structSetInt.
int seats = -1;

// The serial of the queue this game has actually consumed, echoed back in the scenario packet. -1
// until one is read, which is a mismatch against any serial the client has written, so a fresh game
// asks for the queue without the client having to guess.
int consumedQueueSerial = -1;

extern const int SEAT_EMPTY = 0;
extern const int SEAT_OFFERED = 1;
extern const int SEAT_RUNNING = 2;

int SeatTech(int seat = -1) {
    return (MERCENARY_SEAT_TECH_FIRST + seat);
}

int SeatButton(int seat = -1) {
    return (MERCENARY_SEAT_BUTTON_FIRST + seat);
}

// The one place a seat index becomes an instance. Out of range answers cInvalidVector, which every
// struct getter reports as -1 instead of reading past the end of an array.
vector SeatAt(int seat = -1) {
    if (seat < 0 || seat >= MERCENARY_SEAT_COUNT) {
        return (cInvalidVector);
    }
    return (xsArrayGetVector(seats, seat));
}

int SeatMercenary(int seat = -1) {
    return (structGetInt(SeatAt(seat), "mercenaryId"));
}

int SeatState(int seat = -1) {
    return (structGetInt(SeatAt(seat), "state"));
}

int SeatUnitCount(int seat = -1) {
    return (structGetInt(SeatAt(seat), "unitCount"));
}

int SeatUnits(int seat = -1) {
    return (structGetInt(SeatAt(seat), "units"));
}

void HardenSeat(int seat = -1) {
    int tech = SeatTech(seat);
    if (xsGetTechState(tech, 1) == cTechStateInvalid) {
        xsChatData("<RED>MercenarySeats: tech " + tech + " does not exist in this dataset, so seat " + seat + " cannot be offered.");
        return;
    }
    xsEffectAmount(cModifyTech, tech, cAttrSetState, STATE_DISABLE, 1);
    for (c = TECH_ATTR_COST_FIRST; <= TECH_ATTR_COST_LAST) {
        xsEffectAmount(cModifyTech, tech, c, 0.0, 1);
    }
    xsEffectAmount(cModifyTech, tech, cAttrSetEffect, 1.0 * NOOP_EFFECT, 1);
    xsEffectAmount(cModifyTech, tech, cAttrSetStacking, 1.0, 1);
    xsEffectAmount(cModifyTech, tech, cAttrSetStackingResearchCap, 1.0 * MERCENARY_CAPACITY, 1);
    xsEffectAmount(cModifyTech, tech, cAttrSetLocation, 1.0 * PAVILION_BUILDING, 1);
    xsEffectAmount(cModifyTech, tech, cAttrSetButton, 1.0 * SeatButton(seat), 1);
}

void InitMercenarySeats() {
    defineStruct("Seat");
    defineStructAttribute("Seat", "mercenaryId", TYPE_INT);
    defineStructAttribute("Seat", "unitCount", TYPE_INT);
    defineStructAttribute("Seat", "state", TYPE_INT);
    defineStructAttribute("Seat", "units", TYPE_INT_ARRAY);

    seats = xsArrayCreateVector(MERCENARY_SEAT_COUNT, cInvalidVector, "ap-seats");
    for (seat = 0; < MERCENARY_SEAT_COUNT) {
        vector emptySeat = new("Seat");
        structSetInt(emptySeat, "mercenaryId", -1);
        structSetInt(emptySeat, "unitCount", 0);
        structSetInt(emptySeat, "state", SEAT_EMPTY);
        // new() seeds an array attribute with a one element array, so the real one replaces it.
        structSetInt(emptySeat, "units",
                     xsArrayCreateInt(MERCENARY_MAX_UNITS, -1, "ap-seat-units-" + seat));
        xsArraySetVector(seats, seat, emptySeat);
        HardenSeat(seat);
    }
}

void SetSeatUnit(int seat = -1, int index = -1, int unitId = -1) {
    if (index < 0 || index >= MERCENARY_MAX_UNITS) {
        return;
    }
    xsArraySetInt(SeatUnits(seat), index, unitId);
}

int SeatUnitAt(int seat = -1, int index = -1) {
    if (index < 0 || index >= MERCENARY_MAX_UNITS) {
        return (-1);
    }
    return (xsArrayGetInt(SeatUnits(seat), index));
}

void ClearSeatUnits(int seat = -1) {
    int units = SeatUnits(seat);
    for (i = 0; < MERCENARY_MAX_UNITS) {
        xsArraySetInt(units, i, -1);
    }
}

void ClearSeat(int seat = -1) {
    xsEffectAmount(cModifyTech, SeatTech(seat), cAttrSetState, STATE_DISABLE, 1);
    vector cleared = SeatAt(seat);
    structSetInt(cleared, "mercenaryId", -1);
    structSetInt(cleared, "unitCount", 0);
    structSetInt(cleared, "state", SEAT_EMPTY);
}

void OfferSeat(int seat = -1, int mercenaryId = -1) {
    int tech = SeatTech(seat);
    if (xsGetTechState(tech, 1) == cTechStateInvalid) {
        return;
    }
    int unitCount = MercenaryUnitCount(mercenaryId);
    if (unitCount < 1) {
        xsChatData("<RED>OfferSeat: mercenary " + mercenaryId + " has no units, so seat " + seat + " was left empty.");
        return;
    }

    xsEffectAmount(cModifyTech, tech, cAttrSetState, STATE_DISABLE, 1);
    xsEffectAmount(cModifyTech, tech, cAttrSetTime, 1.0 * unitCount, 1);
    xsEffectAmount(cModifyTech, tech, cAttrSetState, STATE_ENABLE, 1);

    vector offered = SeatAt(seat);
    structSetInt(offered, "mercenaryId", mercenaryId);
    structSetInt(offered, "unitCount", unitCount);
    structSetInt(offered, "state", SEAT_OFFERED);
}

void SyncSeat(int seat = -1, int mercenaryId = -1) {
    if (SeatMercenary(seat) == mercenaryId) {
        return;
    }
    if (mercenaryId == -1) {
        ClearSeat(seat);
        return;
    }
    if (IsMercenaryUsed(mercenaryId)) {
        ClearSeat(seat);
        return;
    }
    OfferSeat(seat, mercenaryId);
}

int ConsumedQueueSerial() {
    return (consumedQueueSerial);
}

bool IsSeatResearching(int seat = -1) {
    return (xsGetTechState(SeatTech(seat), 1) == cTechStateResearching);
}

void MarkSeatRunning(int seat = -1) {
    structSetInt(SeatAt(seat), "state", SEAT_RUNNING);
}

// mercenary_queue.xsdat carries one record per seat in seat order, so position is the seat: an empty
// seat is a bare -1, a filled one is an id followed by one int per soldier. There is no length in
// the file, which is why the unit count has to come from MercenaryTable -- a table describing
// different mercenaries than the queue makes every seat after the first read garbage.
void ReadMercenaryQueue() {
    bool opened = xsOpenFile("mercenary_queue");
    if (opened == false) {
        return;
    }
    int available = xsGetFileSize() / 4; // byte to int
    if (available < 1) {
        xsCloseFile();
        return;
    }
    // The serial leads the file, so it is consumed before any seat record.
    consumedQueueSerial = xsReadInt();
    int consumed = 1;
    for (seat = 0; < MERCENARY_SEAT_COUNT) {
        if (consumed >= available) {
            SyncSeat(seat, -1);
            continue;
        }
        int mercenaryId = xsReadInt();
        consumed = consumed + 1;
        if (mercenaryId == -1) {
            SyncSeat(seat, -1);
            continue;
        }
        int units = MercenaryUnitCount(mercenaryId);
        if (units < 1 || (consumed + units) > available) {
            xsChatData("<RED>ReadMercenaryQueue: mercenary " + mercenaryId + " does not match the installed table; the rest of the queue was skipped.");
            SyncSeat(seat, -1);
            consumed = available;
            continue;
        }
        for (u = 0; < units) {
            SetSeatUnit(seat, u, xsReadInt());
            consumed = consumed + 1;
        }
        SyncSeat(seat, mercenaryId);
    }
    xsCloseFile();
}

// mercenaries.xsdat is the ids of every mercenary already spent, keyed by id rather than position,
// so it needs no agreement with any other ordering.
void ReadUsedMercenaries() {
    bool opened = xsOpenFile("mercenaries");
    if (opened == false) {
        return;
    }
    int count = xsGetFileSize() / 4; // byte to int
    for (i = 0; < count) {
        SetMercenaryUsed(xsReadInt());
    }
    xsCloseFile();
}
