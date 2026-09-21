include "./AP.xs";

void InitScenarioLocations() {
  // Scenario-Specific - Not defeatsanity/relics
  AddLocations(10200, 10208);
}

void GiveScenarioItems() {
  ReadScenarioItemFile("ATT2");
}

void SetScenarioAge() {
  SetVanillaAge(CASTLE_AGE);
}

void main() {
  SetScenarioId(102);
  InitAP();
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(10200);
}

void RedTC() {
  AP_Check_Location(10201);
}

void GreenLumber() {
  AP_Check_Location(10202);
}

void PurpleVils() {
  AP_Check_Location(10203);
}

void GreyMining() {
  AP_Check_Location(10204);
}

void CyanTCCastle() {
  AP_Check_Location(10205);
}

void ScythianVils() {
  AP_Check_Location(10206);
}

void BuildTC() {
  AP_Check_Location(10207);
}

void BeatTheRomans() {
  AP_Check_Location(10208);
}

void SetMercenarySpawn() {
    SetMercenarySpawnLocation(147, 10, 147, 14);
}
