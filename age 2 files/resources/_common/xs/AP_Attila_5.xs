include "./AP.xs";

void InitScenarioLocations() {
  // Scenario-Specific - Not defeatsanity/relics
  AddLocations(10500, 10503);
}

void GiveScenarioItems() {
  ReadScenarioItemFile("ATT5");
}

void SetScenarioAge() {
  SetVanillaAge(CASTLE_AGE);
}

void main() {
  SetScenarioId(105);
  InitAP();
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(10500);
}

bool VictoryChecked() {
  return (IsCheckedOnServer(10500));
}

void DefeatRomans() {
  AP_Check_Location(10501);
}

bool DefeatRomansChecked() {
  return (IsCheckedOnServer(10501));
}

void DefeatVisigoths() {
  AP_Check_Location(10502);
}

bool DefeatVisigothsChecked() {
  return (IsCheckedOnServer(10502));
}

void DefeatAlans() {
  AP_Check_Location(10503);
}

bool DefeatAlansChecked() {
  return (IsCheckedOnServer(10503));
}

void SetPavilionLayout() {
    SetPavilionPlacement(127, 169, PAVILION_FACE_NW);
}
