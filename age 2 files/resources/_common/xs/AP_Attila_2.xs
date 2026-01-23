include "./AP.xs";


void InitScenarioSpecific() {
  ScenarioSpecificInit("ATT2");
}

void main() {
  AP_init();
  InitScenarioSpecific();
}

// Scenario-specific locations
void ATT2_VICTORY() {
  AP_Check_Location(0);
}

void ATT2_RED_TC() {
  AP_Check_Location(1);
}

void ATT2_GREEN_LUMBER() {
  AP_Check_Location(2);
}

void ATT2_PURPLE_VILS() {
  AP_Check_Location(3);
}

void ATT2_GREY_MINING() {
  AP_Check_Location(4);
}

void ATT2_CYAN_TC() {
  AP_Check_Location(5);
}

void ATT2_SCYTHIAN_VILS() {
  AP_Check_Location(6);
}

void ATT2_BUILD_TC() {
  AP_Check_Location(7);
}

void ATT2_BEAT_THE_ROMANS() {
  AP_Check_Location(8);
}