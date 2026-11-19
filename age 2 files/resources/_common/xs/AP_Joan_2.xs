include "./AP.xs";

void InitScenarioLocations() {
  // Scenario-Specific - Not defeatsanity/relics
  AddLocations(20200, 20211);
}

void GiveScenarioItems() {
  ReadScenarioItemFile("JOAN2");
}

void SetScenarioAge() {
  SetVanillaAge(FEUDAL_AGE);
  SetMaxAge(CASTLE_AGE);
}

void main() {
  SetScenarioId(202);
  InitAP();
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(20200);
}

void ReachBlois() {
  AP_Check_Location(20201);
}

bool ReachBloisChecked() {
  return (IsCheckedOnServer(20201));
}

void FindDock() {
  AP_Check_Location(20202);
}

bool FindDockChecked() {
  return (IsCheckedOnServer(20202));
}

void DefeatBurgundyBlois() {
  AP_Check_Location(20203);
}

bool DefeatBurgundyBloisChecked() {
  return (IsCheckedOnServer(20203));
}

void ConquerBridge() {
  AP_Check_Location(20204);
}

bool ConquerBridgeChecked() {
  return (IsCheckedOnServer(20204));
}

void BringJoanToOrleans() {
  AP_Check_Location(20205);
}

bool BringJoanToOrleansChecked() {
  return (IsCheckedOnServer(20205));
}

void BringCartsToOrleans() {
  AP_Check_Location(20206);
}

bool BringCartsToOrleansChecked() {
  return (IsCheckedOnServer(20206));
}

void FindFarmingVillage() {
  AP_Check_Location(20207);
}

bool FindFarmingVillageChecked() {
  return (IsCheckedOnServer(20207));
}

void NortheastCastle() {
  AP_Check_Location(20208);
}

bool NortheastCastleChecked() {
  return (IsCheckedOnServer(20208));
}

void NorthwestCastle() {
  AP_Check_Location(20209);
}

bool NorthwestCastleChecked() {
  return (IsCheckedOnServer(20209));
}

void SoutheastCastle() {
  AP_Check_Location(20210);
}

bool SoutheastCastleChecked() {
  return (IsCheckedOnServer(20210));
}

void SouthwestCastle() {
  AP_Check_Location(20211);
}

bool SouthwestCastleChecked() {
  return (IsCheckedOnServer(20211));
}

void SetPavilionLayout() {
    SetPavilionPlacement(1, 184, PAVILION_FACE_NE);
}
