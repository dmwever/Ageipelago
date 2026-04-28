include "./AP.xs";

void InitScenarioSpecific() {
  ScenarioSpecificInit("JOAN3");
}

void main() {
  AP_init();
  InitScenarioSpecific();
  SetScenarioId(203);
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(20300);
}