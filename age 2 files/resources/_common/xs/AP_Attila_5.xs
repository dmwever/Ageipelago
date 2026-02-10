include "./AP.xs";

void InitScenarioSpecific() {
  ScenarioSpecificInit("ATT5");
}

void main() {
  AP_init();
  InitScenarioSpecific();
}

// Scenario-specific locations
void VICTORY() {
  AP_Check_Location(0);
}

void DEFEAT_ROMANS() {
  AP_Check_Location(1);
}

void DEFEAT_VISIGOTHS() {
  AP_Check_Location(2);
}

void DEFEAT_ALANS() {
  AP_Check_Location(3);
}