int seatSpawned = -1;      // how many of them have been placed
int seatLastSpawn = -1;    // game time in seconds of the last placement
int spawnAreaScan = -1;    // reused by every ClearSpawnArea scan; see InitMercenarySpawn
int mercenarySpawnX = -1;
int mercenarySpawnY = -1;
int mercenaryMusterX = -1;
int mercenaryMusterY = -1;
bool spawnPointWarned = false;

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

int SPAWN_AREA_CLASS_COUNT = 5;

int SpawnAreaClassAt(int index = -1) {
    if (index == 0) { return (cBuildingClass); }
    if (index == 1) { return (cWallClass); }
    if (index == 2) { return (cGateClass); }
    if (index == 3) { return (cTowerClass); }
    return (cMiscBuildingClass);
}

void ClearSpawnArea() {
    vector spawn = MercenarySpawnPoint();
    for (c = 0; < SPAWN_AREA_CLASS_COUNT) {
        int classId = SpawnAreaClassAt(c);
        for (player = 0; <= 8) {
            int buildings = xsGetPlayerUnitIds(player, classId, spawnAreaScan);
            for (b = 0; < xsArrayGetSize(buildings)) {
                int buildingId = xsArrayGetInt(buildings, b);
                if (buildingId != -1
                    && xsVectorLength(xsGetUnitPosition(buildingId) - spawn) < 1.5) {
                    xsRemoveUnit(buildingId);
                }
            }
        }
    }
}

bool SpawnNextSoldier(int seat = -1) {
    int spawned = xsArrayGetInt(seatSpawned, seat);
    int unitId = SeatUnitAt(seat, spawned);
    if (unitId == -1) {
        xsChatData("<RED>MercenarySpawn: seat " + seat + " wanted soldier " + spawned + " of "
                   + SeatUnitCount(seat) + ", but its unit list holds "
                   + xsArrayGetSize(SeatUnits(seat)) + ". Nothing placed.");
        return (false);
    }
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
    for (seat = 0; < MERCENARY_SEAT_COUNT) {
        if (SeatState(seat) == SEAT_OFFERED && IsSeatResearching(seat)) {
            if (HasMercenarySpawn() == false) {
                if (spawnPointWarned == false) {
                    xsChatData("<RED>MercenarySpawn: seat " + seat + " is researching, but this"
                               + " scenario never called SetMercenarySpawn(). Nothing can spawn.");
                    spawnPointWarned = true;
                }
                return;
            }
            MarkSeatRunning(seat);
            xsArraySetInt(seatSpawned, seat, 0);
            xsArraySetInt(seatLastSpawn, seat, xsGetGameTime());
            ClearSpawnArea();
        }
        if (SeatState(seat) == SEAT_RUNNING) {
            RunSeat(seat);
        }
    }
}
