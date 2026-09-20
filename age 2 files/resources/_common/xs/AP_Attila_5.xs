include "./AP.xs";

void InitScenarioLocations() {
  // Scenario-Specific - Not defeatsanity/relics
  AddLocations(10500, 10503);
}

void GiveScenarioItems() {
  ReadScenarioItemFile("ATT5");
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

void DefeatRomans() {
  AP_Check_Location(10501);
}

void DefeatVisigoths() {
  AP_Check_Location(10502);
}

void DefeatAlans() {
  AP_Check_Location(10503);
}

void SetMercenarySpawn() {
    SetMercenarySpawnLocation(125, 167, 121, 163);
}
