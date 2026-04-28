include "./AP.xs";

void InitScenarioSpecific() {
  ScenarioSpecificInit("JOAN6");
}

void main() {
  AP_init();
  InitScenarioSpecific();
  SetScenarioId(206);
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(20600);
}