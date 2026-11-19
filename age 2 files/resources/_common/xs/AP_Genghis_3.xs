include "./AP.xs";

void InitScenarioLocations() {
  // Scenario-Specific - Not defeatsanity/relics
  AddLocations(30300, 30307);
}

void InitScenarioThreats() {
  EnableWonderThreat(4);
}

void GiveScenarioItems() {
  ReadScenarioItemFile("GEN3");
}

void SetScenarioAge() {
  SetVanillaAge(FEUDAL_AGE);
}

void main() {
  SetScenarioId(303);
  InitAP();
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(30300);
}

void DefeatTanguts() {
  AP_Check_Location(30301);
}

bool DefeatTangutsChecked() {
  return (IsCheckedOnServer(30301));
}

void DefeatXiXia() {
  AP_Check_Location(30302);
}

bool DefeatXiXiaChecked() {
  return (IsCheckedOnServer(30302));
}

void DefeatJin() {
  AP_Check_Location(30303);
}

bool DefeatJinChecked() {
  return (IsCheckedOnServer(30303));
}

void DefeatSong() {
  AP_Check_Location(30304);
}

bool DefeatSongChecked() {
  return (IsCheckedOnServer(30304));
}

void FindEngineers() {
  AP_Check_Location(30305);
}

bool FindEngineersChecked() {
  return (IsCheckedOnServer(30305));
}

void FindBombardCannons() {
  AP_Check_Location(30306);
}

bool FindBombardCannonsChecked() {
  return (IsCheckedOnServer(30306));
}

void FindTransportShip() {
  AP_Check_Location(30307);
}

bool FindTransportShipChecked() {
  return (IsCheckedOnServer(30307));
}

void SetPavilionLayout() {
    SetPavilionPlacement(183, 13, PAVILION_FACE_SW);
}
