include "./AP.xs";

void InitScenarioSpecific() {
  ScenarioSpecificInit("ATT6");
}

void main() {
  AP_init();
  InitScenarioSpecific();
}

// Scenario-specific locations
void Victory() {
  AP_Check_Location(0);
}

void DefeatPatavium() {
  AP_Check_Location(1);
}

void DefeatMediolanum() {
  AP_Check_Location(2);
}

void DefeatAquilea() {
  AP_Check_Location(3);
}

void DefeatVerona() {
  AP_Check_Location(4);
}

void DefeatTheItalians() {
  AP_Check_Location(5);
}

void MeetThePope() {
  AP_Check_Location(6);
}

void DestroyPurpleWonder() {
  AP_Check_Location(7);
}

void DestroyGreenWonder() {
  AP_Check_Location(8);
}

void DestroyRedWonder() {
  AP_Check_Location(9);
}

void DestroyOrangeWonder() {
  AP_Check_Location(10);
}

void DestroyPurpleWonder2() {
  AP_Check_Location(11);
}

void DefeatsanityBlue() {
  AP_Check_Location(12);
}
