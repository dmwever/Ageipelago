include "./AP.xs";

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

void main() {
  SetScenarioId(101);
  InitAP();
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(10100);
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
