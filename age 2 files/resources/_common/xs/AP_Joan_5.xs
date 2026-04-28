include "./AP.xs";

void InitScenarioSpecific() {
  ScenarioSpecificInit("JOAN5");
}

void main() {
  AP_init();
  InitScenarioSpecific();
  SetScenarioId(205);
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(20500);
}