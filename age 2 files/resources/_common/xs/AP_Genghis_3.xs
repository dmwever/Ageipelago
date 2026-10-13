include "./AP.xs";

void CavemanExemption() {
}

void InitScenarioLocations() {
  // Scenario-Specific - Not defeatsanity/relics
  AddLocations(30300, 30307);
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

void DefeatXiXia() {
  AP_Check_Location(30302);
}

void DefeatJin() {
  AP_Check_Location(30303);
}

void DefeatSong() {
  AP_Check_Location(30304);
}

void FindEngineers() {
  AP_Check_Location(30305);
}

void FindBombardCannons() {
  AP_Check_Location(30306);
}

void FindTransportShip() {
  AP_Check_Location(30307);
}

void SetPavilionLayout() {
    SetPavilionPlacement(177, 22, PAVILION_FACE_NW);
}
