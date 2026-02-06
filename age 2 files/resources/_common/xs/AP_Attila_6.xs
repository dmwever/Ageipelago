include "./AP.xs";

void InitScenarioSpecific() {
  ScenarioSpecificInit("ATT6");
}

void main() {
  AP_init();
  InitScenarioSpecific();
}

// Scenario-specific locations
void VICTORY() {
  AP_Check_Location(0);
}

void DEFEAT_PATAVIUM() {
  AP_Check_Location(1);
}

void DEFEAT_MEDIOLANUM() {
  AP_Check_Location(2);
}

void DEFEAT_AQUILEIA() {
  AP_Check_Location(3);
}

void DEFEAT_VERONA() {
  AP_Check_Location(4);
}

void DEFEAT_THE_ITALIANS() {
  AP_Check_Location(5);
}

void MEET_THE_POPE() {
  AP_Check_Location(6);
}

void DESTROY_PURPLE_WONDER() {
  AP_Check_Location(7);
}

void DESTROY_GREEN_WONDER() {
  AP_Check_Location(8);
}

void DESTROY_RED_WONDER() {
  AP_Check_Location(9);
}

void DESTROY_ORANGE_WONDER() {
  AP_Check_Location(10);
}

void DESTROY_PURPLE_WONDER_2() {
  AP_Check_Location(11);
}