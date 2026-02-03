include "./AP.xs";

void InitScenarioSpecific() {
  ScenarioSpecificInit("ATT3");
}

void main() {
  AP_init();
  InitScenarioSpecific();
}

// Scenario-specific locations
void VICTORY() {
  AP_Check_Location(0);
}

void GREEN_DOCK_1() {
  AP_Check_Location(1);
}

void GREEN_DOCK_2() {
  AP_Check_Location(2);
}

void FIND_GOLD() {
  AP_Check_Location(3);
}

void GREEN_TC() {
  AP_Check_Location(4);
}

void BLUE_DOCK_NORTH() {
  AP_Check_Location(5);
}

void BLUE_DOCKS_SOUTH() {
  AP_Check_Location(6);
}

void BUILD_CASTLE() {
  AP_Check_Location(7);
}

void RED_TRADE_CARTS() {
  AP_Check_Location(8);
}

void RED_TC() {
  AP_Check_Location(9);
}

void BLUE_COGS() {
  AP_Check_Location(10);
}

void RED_DOCK() {
  AP_Check_Location(11);
}

void RED_MARKET() {
  AP_Check_Location(12);
}

void THREATEN_WONDER() {
  AP_Check_Location(13);
}

void DESTROY_WONDER() {
  AP_Check_Location(14);
}

void BLUE_MONASTERY() {
    AP_Check_Location(15);
}