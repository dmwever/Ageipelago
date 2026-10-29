include "./AP.xs";

void InitScenarioLocations() {
  // Scenario-Specific - Not defeatsanity/relics
  AddLocations(30600, 30601);
}

void GiveScenarioItems() {
  ReadScenarioItemFile("GEN6");
}

void SetScenarioAge() {
  SetVanillaAge(IMPERIAL_AGE);
}

void main() {
  SetScenarioId(306);
  InitAP();
}

// Scenario-specific locations
// Winning also sends Subotai Arrives: a run that razes all four Hungarian
// strongholds before the fortieth minute never sees him turn up.
void Victory() {
  GiveVictory();
  AP_Check_Location(30600);
  AP_Check_Location(30601);
}

void SubotaiArrives() {
  AP_Check_Location(30601);
}

void SetPavilionLayout() {
    SetPavilionPlacement(104, 3, PAVILION_FACE_SE);
}
