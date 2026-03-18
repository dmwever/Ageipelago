include "./AP.xs";


void InitScenarioSpecific() {
  ScenarioSpecificInit("ATT2");
}

void main() {
  AP_init();
  InitScenarioSpecific();
  SetScenarioId(102);
}

// Scenario-specific locations
void Victory() {
  AP_Check_Location(0);
}

void RedTC() {
  AP_Check_Location(1);
}

void GreenLumber() {
  AP_Check_Location(2);
}

void PurpleVils() {
  AP_Check_Location(3);
}

void GreyMining() {
  AP_Check_Location(4);
}

void CyanTC() {
  AP_Check_Location(5);
}

void ScythianVils() {
  AP_Check_Location(6);
}

void BuildTC() {
  AP_Check_Location(7);
}

void BeatTheRomans() {
  AP_Check_Location(8);
}

void DefeatsanityRed() {
  AP_Check_Location(9);
}

void DefeatsanityGreen() {
  AP_Check_Location(10);
}

void DefeatsanityPurple() {
  AP_Check_Location(11);
}

void DefeatsanityGrey() {
  AP_Check_Location(12);
}

void DefeatsanityCyan() {
  AP_Check_Location(13);
}

void DefeatsanityOrange() {
  AP_Check_Location(14);
}
