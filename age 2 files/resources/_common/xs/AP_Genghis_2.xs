include "./AP.xs";

void CavemanExemption() {
}

void InitScenarioLocations() {
  // Scenario-Specific - Not defeatsanity/relics
  AddLocations(30200, 30202);
}

void GiveScenarioItems() {
  ReadScenarioItemFile("GEN2");
}

void SetScenarioAge() {
  SetVanillaAge(DARK_AGE);
}

void main() {
  SetScenarioId(302);
  InitAP();
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(30200);
}

void MakeKushlukFlee() {
  AP_Check_Location(30201);
}

void TakeTayichiudVillage() {
  AP_Check_Location(30202);
}

void SetPavilionLayout() {
    SetPavilionPlacement(142, 123, PAVILION_FACE_SW);
}
