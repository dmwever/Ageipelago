include "./AP.xs";

void InitScenarioSpecific() {
  ScenarioSpecificInit("ATT4");
}

void main() {
  AP_init();
  InitScenarioSpecific();
}

// Scenario-specific locations
void VICTORY() {
  AP_Check_Location(0);
}

void DEFEAT_BURGUNDY_ALL() {
  AP_Check_Location(1);
}

void DEFEAT_METZ() {
  AP_Check_Location(2);
}

void DEFEAT_ORLEANS() {
  AP_Check_Location(3);
}

void DEFEAT_ROMAN_ARMY() {
  AP_Check_Location(4);
}

void TRIBUTE_BURGUNDY_ALL() {
  AP_Check_Location(5);
}

void CASTLE_BURGUNDY_ALL() {
  AP_Check_Location(6);
}

void DEFEAT_OR_ALLY_BURGUNDY_ANY() {
  AP_Check_Location(7);
}