include "./AP.xs";


void InitScenarioSpecific() {
  GiveScenarioSpecificItems("ATT2");
}

void main() {
  AP_init();
  InitScenarioSpecific();
}

// Scenario-specific locations
void ATT2_VICTORY() {
  AP_Check_Location(0);
}

void Att2RedTC() {
  AP_Check_Location(1);
}

void Att2GreenLumber() {
  AP_Check_Location(2);
}

void Att2PurpleVills() {
  AP_Check_Location(3);
}

void Att2GreyMining() {
  AP_Check_Location(4);
}

void Att2CyanTC() {
  AP_Check_Location(5);
}

void Att2ScythianVills() {
  AP_Check_Location(6);
}

void Att2BuildTC() {
  AP_Check_Location(7);
}

void Att2BeatTheRomans() {
  AP_Check_Location(8);
}

void Att2DefeatsanityRed() {
  AP_Check_Location(9);
}

void Att2DefeatsanityGreen() {
  AP_Check_Location(10);
}

void Att2DefeatsanityPurple() {
  AP_Check_Location(11);
}

void Att2DefeatsanityGrey() {
  AP_Check_Location(12);
}

void Att2DefeatsanityCyan() {
  AP_Check_Location(13);
}

void Att2DefeatsanityOrange() {
  AP_Check_Location(14);
}
