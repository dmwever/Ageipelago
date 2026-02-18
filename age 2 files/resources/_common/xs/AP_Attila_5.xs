include "./AP.xs";

void InitScenarioSpecific() {
  ScenarioSpecificInit("ATT5");
}

void main() {
  AP_init();
  InitScenarioSpecific();
}

// Scenario-specific locations
void Victory() {
  AP_Check_Location(0);
}

void DefeatRomans() {
  AP_Check_Location(1);
}

void DefeatVisigoths() {
  AP_Check_Location(2);
}

void DefeatAlans() {
  AP_Check_Location(3);
}

void DefeatsanityGrey() {
  AP_Check_Location(4);
}

void DefeatsanityRed() {
  AP_Check_Location(5);
}
