include "./AP.xs";

void InitScenarioLocations() {
  // Scenario-Specific - Not defeatsanity/relics
  AddLocations(30400, 30404);
}

void GiveScenarioItems() {
  ReadScenarioItemFile("GEN4");
}

void SetScenarioAge() {
  SetVanillaAge(CASTLE_AGE);
}

void main() {
  SetScenarioId(304);
  InitAP();
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(30400);
}

void DefeatRussians() {
  AP_Check_Location(30401);
}

void DefeatKhwarazm() {
  AP_Check_Location(30402);
}

void KipchaksSurrender() {
  AP_Check_Location(30403);
}

void AssassinateTheShah() {
  AP_Check_Location(30404);
}

void SetPavilionLayout() {
    SetPavilionPlacement(189, 139, PAVILION_FACE_NE);
}
