include "./AP.xs";

void InitScenarioSpecific() {
  ScenarioSpecificInit("JOAN2");
}

void main() {
  AP_init();
  InitScenarioSpecific();
  SetScenarioId(202);
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(20200);
}