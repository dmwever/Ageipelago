include "./AP.xs";

extern const int ATTILA1_MANGUDAI_UNIT = 11;
extern const int ATTILA1_MANGUDAI_WAVE_SIZE = 18;
extern const int ATTILA1_MANGUDAI_SPAWN_X = 6;
extern const int ATTILA1_MANGUDAI_SPAWN_Y = 38;
extern const int ATTILA1_MANGUDAI_TARGET_X = 37;
extern const int ATTILA1_MANGUDAI_TARGET_Y = 61;

void InitScenarioLocations() {
  // Scenario-Specific - Not defeatsanity/relics
  AddLocations(10100, 10116);
}

void GiveScenarioItems() {
  ReadScenarioItemFile("ATT1");
}

void SetScenarioAge() {
  SetVanillaAge(DARK_AGE);
  SetMaxAge(CASTLE_AGE);
}

int mangudaiWave = -1;
int mangudaiWaveQueuedAt = -1;
int mangudaiWaveCount = 0;
int mangudaiTask = -1;

void InitMangudaiWave() {
    mangudaiWave = xsArrayCreateInt(ATTILA1_MANGUDAI_WAVE_SIZE, -1, "att1-mangudai-wave");
    mangudaiWaveQueuedAt = xsArrayCreateInt(ATTILA1_MANGUDAI_WAVE_SIZE, -1, "att1-mangudai-queued");
    mangudaiTask = xsArrayCreateInt(1, -1, "att1-mangudai-task");
}

void main() {
  SetScenarioId(101);
  InitMangudaiWave();
  InitAP();
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(10100);
}

bool VictoryChecked() {
  return (IsCheckedOnServer(10100));
}

void UniteTheHuns() {
  AP_Check_Location(10101);
}

bool UniteTheHunsChecked() {
  return (IsCheckedOnServer(10101));
}

void FreeVillagers() {
  AP_Check_Location(10102);
}

bool FreeVillagersChecked() {
  return (IsCheckedOnServer(10102));
}

void ResolveScoutAny() {
  AP_Check_Location(10103);
}

bool ResolveScoutAnyChecked() {
  return (IsCheckedOnServer(10103));
}

void CaptureHorsesCamp() {
  AP_Check_Location(10104);
}

bool CaptureHorsesCampChecked() {
  return (IsCheckedOnServer(10104));
}

void CaptureHorseRuins() {
  AP_Check_Location(10105);
}

bool CaptureHorseRuinsChecked() {
  return (IsCheckedOnServer(10105));
}

void CaptureHorsesLumber() {
  AP_Check_Location(10106);
}

bool CaptureHorsesLumberChecked() {
  return (IsCheckedOnServer(10106));
}

void CaptureHorsesBehindBase() {
  AP_Check_Location(10107);
}

bool CaptureHorsesBehindBaseChecked() {
  return (IsCheckedOnServer(10107));
}

void CaptureHorsesWest() {
  AP_Check_Location(10108);
}

bool CaptureHorsesWestChecked() {
  return (IsCheckedOnServer(10108));
}

void CaptureHorsesRoman() {
  AP_Check_Location(10109);
}

bool CaptureHorsesRomanChecked() {
  return (IsCheckedOnServer(10109));
}

void KillTheBoar() {
  AP_Check_Location(10110);
}

bool KillTheBoarChecked() {
  return (IsCheckedOnServer(10110));
}

void BetrayBleda() {
  AP_Check_Location(10111);
}

bool BetrayBledaChecked() {
  return (IsCheckedOnServer(10111));
}

void BlowBledaOff() {
  AP_Check_Location(10112);
}

bool BlowBledaOffChecked() {
  return (IsCheckedOnServer(10112));
}

void FreeScout() {
  AP_Check_Location(10113);
}

bool FreeScoutChecked() {
  return (IsCheckedOnServer(10113));
}

void KillScout() {
  AP_Check_Location(10114);
}

bool KillScoutChecked() {
  return (IsCheckedOnServer(10114));
}

void GiveHorses() {
  AP_Check_Location(10115);
}

bool GiveHorsesChecked() {
  return (IsCheckedOnServer(10115));
}

void DefeatFirstPlayer() {
  AP_Check_Location(10116);
}

bool DefeatFirstPlayerChecked() {
  return (IsCheckedOnServer(10116));
}

void SetPavilionLayout() {
    SetPavilionPlacement(106, 5, PAVILION_FACE_SE);
}

void QueueMangudaiMove(int slot = -1, int unitId = -1) {
    xsArraySetInt(mangudaiWave, slot, unitId);
    xsArraySetInt(mangudaiWaveQueuedAt, slot, xsGetGameTime());
    xsEnableRule("MangudaiWaveMoves");
}

void StartMangudaiWave() {
    for (slot = 0; < ATTILA1_MANGUDAI_WAVE_SIZE) {
        xsArraySetInt(mangudaiWave, slot, -1);
        xsArraySetInt(mangudaiWaveQueuedAt, slot, -1);
    }
    mangudaiWaveCount = 0;
}

bool MangudaiWaveFull() {
    return (mangudaiWaveCount >= ATTILA1_MANGUDAI_WAVE_SIZE);
}

void SpawnMangudai() {
    if (MangudaiWaveFull()) {
        return;
    }
    vector spawn = xsVectorSet(1.0 * ATTILA1_MANGUDAI_SPAWN_X, 1.0 * ATTILA1_MANGUDAI_SPAWN_Y, 0.0);
    int created = xsCreateUnit(ATTILA1_MANGUDAI_UNIT, 1, spawn, false, true, false);
    if (created < 0) {
        return;
    }
    QueueMangudaiMove(mangudaiWaveCount, created);
    mangudaiWaveCount++;
}

bool MangudaiWaveGone() {
    if (MangudaiWaveFull() == false) {
        return (false);
    }
    for (slot = 0; < ATTILA1_MANGUDAI_WAVE_SIZE) {
        int unitId = xsArrayGetInt(mangudaiWave, slot);
        if (unitId >= 0 && xsDoesUnitExist(unitId) && xsGetUnitOwner(unitId) == 1) {
            return (false);
        }
    }
    return (true);
}

void OnUnitReplaced(int oldId = -1, int newId = -1) {
    for (slot = 0; < mangudaiWaveCount) {
        if (xsArrayGetInt(mangudaiWave, slot) == oldId) {
            QueueMangudaiMove(slot, newId);
            return;
        }
    }
}

rule MangudaiWaveMoves
    inactive
    minInterval 1
    maxInterval 1
{
    bool waiting = false;
    vector target = xsVectorSet(1.0 * ATTILA1_MANGUDAI_TARGET_X, 1.0 * ATTILA1_MANGUDAI_TARGET_Y, 0.0);
    for (slot = 0; < mangudaiWaveCount) {
        int queuedAt = xsArrayGetInt(mangudaiWaveQueuedAt, slot);
        if (queuedAt < 0) {
            continue;
        }
        if (queuedAt >= xsGetGameTime()) {
            waiting = true;
            continue;
        }
        xsArraySetInt(mangudaiTask, 0, xsArrayGetInt(mangudaiWave, slot));
        xsTaskUnits(mangudaiTask, cActionTypeMove, target);
        xsArraySetInt(mangudaiWaveQueuedAt, slot, -1);
    }
    if (waiting == false) {
        xsDisableSelf();
    }
}
