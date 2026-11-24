include "./AP.xs";

void InitScenarioLocations() {
  // Scenario-Specific - Not defeatsanity/relics
  AddLocations(20300, 20308);
}

void GiveScenarioItems() {
  ReadScenarioItemFile("JOAN3");
}

void SetScenarioAge() {
  SetVanillaAge(FEUDAL_AGE);
  SetMaxAge(CASTLE_AGE);
}

void main() {
  SetScenarioId(203);
  InitAP();
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(20300);
}

bool VictoryChecked() {
  return (IsCheckedOnServer(20300));
}

void FindBoats() {
  AP_Check_Location(20301);
}

bool FindBoatsChecked() {
  return (IsCheckedOnServer(20301));
}

void SlayFastolf() {
  AP_Check_Location(20302);
}

bool SlayFastolfChecked() {
  return (IsCheckedOnServer(20302));
}

void DestroyOneCastle() {
  AP_Check_Location(20303);
}

bool DestroyOneCastleChecked() {
  return (IsCheckedOnServer(20303));
}

void DestroyTwoCastles() {
  AP_Check_Location(20304);
}

bool DestroyTwoCastlesChecked() {
  return (IsCheckedOnServer(20304));
}

void DestroyLeftCastle() {
  AP_Check_Location(20305);
}

bool DestroyLeftCastleChecked() {
  return (IsCheckedOnServer(20305));
}

void DestroyCentralCastle() {
  AP_Check_Location(20306);
}

bool DestroyCentralCastleChecked() {
  return (IsCheckedOnServer(20306));
}

void DestroyRightCastle() {
  AP_Check_Location(20307);
}

bool DestroyRightCastleChecked() {
  return (IsCheckedOnServer(20307));
}

void DestroyRearCastle() {
  AP_Check_Location(20308);
}

bool DestroyRearCastleChecked() {
  return (IsCheckedOnServer(20308));
}

void SetPavilionLayout() {
    SetPavilionPlacement(1, 100, PAVILION_FACE_NE);
}
