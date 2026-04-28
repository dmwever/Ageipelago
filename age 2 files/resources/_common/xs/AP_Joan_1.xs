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

void GetSwordsmen() {
  AP_Check_Location(20101);
}

void GetCrossbowmen() {
  AP_Check_Location(20102);
}

void FindRam() {
  AP_Check_Location(20103);
}

void FindVenison() {
  AP_Check_Location(20104);
}

void FindDock() {
  AP_Check_Location(20105);
}

void FindRecruits() {
  AP_Check_Location(20106);
}

void FightHighwaymen() {
  AP_Check_Location(20107);
}