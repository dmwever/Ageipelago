int seatMercenaries = -1;
int seatUnitCounts = -1;
int seatStates = -1;
int seatUnits = -1;        // one xsArrayCreateInt handle per seat, holding that seat's unit ids

extern const int SEAT_EMPTY = 0;
extern const int SEAT_OFFERED = 1;
extern const int SEAT_RUNNING = 2;

int SeatTech(int seat = -1) {
    return (MERCENARY_SEAT_TECH_FIRST + seat);
}

int SeatButton(int seat = -1) {
    return (MERCENARY_SEAT_BUTTON_FIRST + seat);
}

int SeatMercenary(int seat = -1) {
    return (xsArrayGetInt(seatMercenaries, seat));
}

int SeatState(int seat = -1) {
    return (xsArrayGetInt(seatStates, seat));
}

int SeatUnitCount(int seat = -1) {
    return (xsArrayGetInt(seatUnitCounts, seat));
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
    seatMercenaries = xsArrayCreateInt(MERCENARY_SEAT_COUNT, -1, "ap-seat-mercenaries");
    seatUnitCounts = xsArrayCreateInt(MERCENARY_SEAT_COUNT, 0, "ap-seat-units");
    seatStates = xsArrayCreateInt(MERCENARY_SEAT_COUNT, SEAT_EMPTY, "ap-seat-states");
    seatUnits = xsArrayCreateInt(MERCENARY_SEAT_COUNT, -1, "ap-seat-unit-lists");
    for (seat = 0; < MERCENARY_SEAT_COUNT) {
        xsArraySetInt(seatUnits, seat,
                      xsArrayCreateInt(MERCENARY_MAX_UNITS, -1, "ap-seat-units-" + seat));
        HardenSeat(seat);
    }
}

void SetSeatUnit(int seat = -1, int index = -1, int unitId = -1) {
    if (index < 0 || index >= MERCENARY_MAX_UNITS) {
        return;
    }
    xsArraySetInt(xsArrayGetInt(seatUnits, seat), index, unitId);
}

int SeatUnitAt(int seat = -1, int index = -1) {
    if (index < 0 || index >= MERCENARY_MAX_UNITS) {
        return (-1);
    }
    return (xsArrayGetInt(xsArrayGetInt(seatUnits, seat), index));
}

void ClearSeatUnits(int seat = -1) {
    int units = xsArrayGetInt(seatUnits, seat);
    for (i = 0; < MERCENARY_MAX_UNITS) {
        xsArraySetInt(units, i, -1);
    }
}

void ClearSeat(int seat = -1) {
    xsEffectAmount(cModifyTech, SeatTech(seat), cAttrSetState, STATE_DISABLE, 1);
    xsArraySetInt(seatMercenaries, seat, -1);
    xsArraySetInt(seatUnitCounts, seat, 0);
    xsArraySetInt(seatStates, seat, SEAT_EMPTY);
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

    xsArraySetInt(seatMercenaries, seat, mercenaryId);
    xsArraySetInt(seatUnitCounts, seat, unitCount);
    xsArraySetInt(seatStates, seat, SEAT_OFFERED);
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

bool IsSeatResearching(int seat = -1) {
    return (xsGetTechState(SeatTech(seat), 1) == cTechStateResearching);
}

void MarkSeatRunning(int seat = -1) {
    xsArraySetInt(seatStates, seat, SEAT_RUNNING);
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
    int consumed = 0;
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
        if (units < 1 || consumed + units > available) {
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
