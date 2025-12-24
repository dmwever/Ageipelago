include "./AP.xs";


void InitScenarioSpecific() {
  GiveScenarioSpecificItems("ATT1");
}

void main() {
  AP_init();
  InitScenarioSpecific();
}

// Scenario-specific locations
void VICTORY() {
  AP_Check_Location(0);
}

void UNITE_THE_HUNS() {
  AP_Check_Location(1);
}

void FREE_VILLAGERS() {
  AP_Check_Location(2);
}

void RESOLVE_SCOUT_ANY() {
  AP_Check_Location(3);
}

void CAPTURE_HORSES_CAMP() {
  AP_Check_Location(4);
}

void CAPTURE_HORSE_RUINS() {
  AP_Check_Location(5);
}

void CAPTURE_HORSES_LUMBER() {
  AP_Check_Location(6);
}

void CAPTURE_HORSES_BEHIND_BASE() {
  AP_Check_Location(7);
}

void CAPTURE_HORSES_WEST() {
  AP_Check_Location(8);
}

void CAPTURE_HORSES_ROMAN() {
  AP_Check_Location(9);
}

void KILL_THE_BOAR() {
  AP_Check_Location(10);
}

void BETRAY_BLEDA() {
  AP_Check_Location(11);
}

void BLOW_BLEDA_OFF() {
  AP_Check_Location(12);
}

void FREE_SCOUT() {
  AP_Check_Location(13);
}

void KILL_SCOUT() {
  AP_Check_Location(14);
}

void GIVE_HORSES() {
  AP_Check_Location(15);
}

void DEFEAT_FIRST_PLAYER() {
  AP_Check_Location(16);
}