include "./AP.xs";

void InitScenarioSpecific() {
  ScenarioSpecificInit("JOAN4");
}

void main() {
  AP_init();
  InitScenarioSpecific();
  SetScenarioId(204);
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(20400);
}