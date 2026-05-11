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

void DefeatEnglishGuards() {
  AP_Check_Location(20401);
}

void ReachBase() {
  AP_Check_Location(20402);
}

void DestroyTroyesTC() {
  AP_Check_Location(20403);
}

void DestroyChalonsTC() {
  AP_Check_Location(20404);
}

void DestroyRheimsTC() {
  AP_Check_Location(20405);
}