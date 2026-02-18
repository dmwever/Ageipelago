include "./AP.xs";

void InitScenarioSpecific() {
  ScenarioSpecificInit("ATT4");
}

void main() {
  AP_init();
  InitScenarioSpecific();
}

// Scenario-specific locations
void Victory() {
  AP_Check_Location(0);
}

void DefeatBurgundyAll() {
  AP_Check_Location(1);
}

void DefeatMetz() {
  AP_Check_Location(2);
}

void DefeatOrleans() {
  AP_Check_Location(3);
}

void DefeatRomanArms() {
  AP_Check_Location(4);
}

void TributeBurgundyAll() {
  AP_Check_Location(5);
}

void CastleBurgundyAll() {
  AP_Check_Location(6);
}

void DefeatOrAllyBurgundyAny() {
  AP_Check_Location(7);
}
