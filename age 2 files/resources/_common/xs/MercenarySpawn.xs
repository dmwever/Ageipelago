int seatSpawned = -1;      // how many of them have been placed
int seatLastSpawn = -1;    // game time in seconds of the last placement
int mercenarySpawnX = -1;
int mercenarySpawnY = -1;
int mercenaryMusterX = -1;
int mercenaryMusterY = -1;

void SetMercenarySpawnLocation(int spawnX = -1, int spawnY = -1, int musterX = -1, int musterY = -1) {
    mercenarySpawnX = spawnX;
    mercenarySpawnY = spawnY;
    mercenaryMusterX = musterX;
    mercenaryMusterY = musterY;
}

bool HasMercenarySpawn() {
    return (mercenarySpawnX >= 0 && mercenarySpawnY >= 0);
}

vector MercenarySpawnPoint() {
    return (xsVectorSet(1.0 * mercenarySpawnX, 1.0 * mercenarySpawnY, 0.0));
}

vector MercenaryMusterPoint() {
    return (xsVectorSet(1.0 * mercenaryMusterX, 1.0 * mercenaryMusterY, 0.0));
}

void InitMercenarySpawn() {
    seatSpawned = xsArrayCreateInt(MERCENARY_SEAT_COUNT, 0, "ap-seat-spawned");
    seatLastSpawn = xsArrayCreateInt(MERCENARY_SEAT_COUNT, -1, "ap-seat-last-spawn");
}

void ResetSeatSpawn(int seat = -1) {
    xsArraySetInt(seatSpawned, seat, 0);
    xsArraySetInt(seatLastSpawn, seat, -1);
}

void ClearSpawnArea() {
    vector spawn = MercenarySpawnPoint();
    for (player = 0; <= 8) {
        int nearby = xsGetPlayerUnitIds(player, cObjectTypeCreatable);
        for (i = 0; < xsArrayGetSize(nearby)) {
            int unitId = xsArrayGetInt(nearby, i);
            if (unitId != -1 && xsVectorLength(xsGetUnitPosition(unitId) - spawn) < 1.5) {
                xsSetUnitPosition(unitId, MercenaryMusterPoint(), false);
            }
        }
        int buildings = xsGetPlayerUnitIds(player, cObjectTypeBuilding);
        for (b = 0; < xsArrayGetSize(buildings)) {
            int buildingId = xsArrayGetInt(buildings, b);
            if (buildingId != -1 && xsVectorLength(xsGetUnitPosition(buildingId) - spawn) < 1.5) {
                xsRemoveUnit(buildingId);
            }
        }
    }
}

bool SpawnNextSoldier(int seat = -1) {
    int spawned = xsArrayGetInt(seatSpawned, seat);
    int unitId = SeatUnitAt(seat, spawned);
    if (unitId == -1) {
        return (false);
    }
    ClearSpawnArea();
    int created = xsCreateUnit(unitId, 1, MercenarySpawnPoint(), false, true, false);
    if (created == -1) {
        return (false);
    }
    xsSetTriggerVariable(MERCENARY_TASK_VARIABLE, 1);
    xsArraySetInt(seatSpawned, seat, spawned + 1);
    xsArraySetInt(seatLastSpawn, seat, xsGetGameTime());
    return (true);
}

void RunSeat(int seat = -1) {
    int spawned = xsArrayGetInt(seatSpawned, seat);
    if (spawned >= SeatUnitCount(seat)) {
        // The last soldier is what completes a mercenary, not the technology.
        MarkMercenaryComplete(SeatMercenary(seat));
        ClearSeat(seat);
        ResetSeatSpawn(seat);
        return;
    }
    // Start at T-1 rather than the instant research begins, so the first soldier is one second in.
    if (xsGetGameTime() == xsArrayGetInt(seatLastSpawn, seat)) {
        return;
    }
    SpawnNextSoldier(seat);
}

rule MercenarySpawnLoop
    inactive
    group Mercenaries
    highFrequency
{
    if (HasMercenarySpawn() == false) {
        return;
    }
    for (seat = 0; < MERCENARY_SEAT_COUNT) {
        if (SeatState(seat) == SEAT_OFFERED && IsSeatResearching(seat)) {
            MarkSeatRunning(seat);
            xsArraySetInt(seatSpawned, seat, 0);
            xsArraySetInt(seatLastSpawn, seat, xsGetGameTime());
        }
        if (SeatState(seat) == SEAT_RUNNING) {
            RunSeat(seat);
        }
    }
}
