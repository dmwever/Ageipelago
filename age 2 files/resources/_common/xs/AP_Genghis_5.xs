include "./AP.xs";

void InitScenarioLocations() {
  // Scenario-Specific - Not defeatsanity/relics
  AddLocations(30500, 30507);
}

void GiveScenarioItems() {
  ReadScenarioItemFile("GEN5");
}

void SetScenarioAge() {
  SetVanillaAge(CASTLE_AGE);
}

void main() {
  SetScenarioId(305);
  InitAP();
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(30500);
}

void CaptureGermanFlag() {
  AP_Check_Location(30501);
}

void CapturePolishFlag() {
  AP_Check_Location(30502);
}

void CaptureBohemianFlag() {
  AP_Check_Location(30503);
}

void BuildOneCastle() {
  AP_Check_Location(30504);
}

void BuildTwoCastles() {
  AP_Check_Location(30505);
}

void BuildThreeCastles() {
  AP_Check_Location(30506);
}

void RescueTheHermit() {
  AP_Check_Location(30507);
}

void SetPavilionLayout() {
    SetPavilionPlacement(130, 62, PAVILION_FACE_NE);
}
