include "./AP.xs";

void InitScenarioSpecific() {
  ScenarioSpecificInit("JOAN1");
}

void main() {
  AP_init();
  InitScenarioSpecific();
  SetScenarioId(201);
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(20100);
}