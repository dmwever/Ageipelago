include "./AP.xs";

void InitScenarioSpecific() {
  ScenarioSpecificInit("ATT3");
}

void main() {
  AP_init();
  InitScenarioSpecific();
}

// Scenario-specific locations
void Victory() {
  AP_Check_Location(0);
}

void GreenDock1() {
  AP_Check_Location(1);
}

void GreenDock2() {
  AP_Check_Location(2);
}

void FindGold() {
  AP_Check_Location(3);
}

void GreenTC() {
  AP_Check_Location(4);
}

void BlueDockNorth() {
  AP_Check_Location(5);
}

void BlueDocksSouth() {
  AP_Check_Location(6);
}

void BuildCastle() {
  AP_Check_Location(7);
}

void RedTradeCarts() {
  AP_Check_Location(8);
}

void RedTC() {
  AP_Check_Location(9);
}

void BlueCogs() {
  AP_Check_Location(10);
}

void RedDock() {
  AP_Check_Location(11);
}

void RedMarket() {
  AP_Check_Location(12);
}

void ThreatenWonder() {
  AP_Check_Location(13);
}

void DestroyWonder() {
  AP_Check_Location(14);
}

void BlueMonastery() {
    AP_Check_Location(15);
}

void DefeatsanityBlue() {
    AP_Check_Location(16);
}

void DefeatsanityGreen() {
    AP_Check_Location(17);
}

void DefeatsanityRed() {
    AP_Check_Location(18);
}
