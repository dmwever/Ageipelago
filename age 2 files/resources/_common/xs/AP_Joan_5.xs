include "./AP.xs";

void InitScenarioLocations() {
  // Scenario-Specific - Not defeatsanity/relics
  AddLocations(20500, 20514);
}

void GiveScenarioItems() {
  ReadScenarioItemFile("JOAN5");
}

void SetScenarioAge() {
  SetVanillaAge(IMPERIAL_AGE);
}

void main() {
  SetScenarioId(205);
  InitAP();
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(20500);
}

bool VictoryChecked() {
  return (IsCheckedOnServer(20500));
}

void Refugee1() {
  AP_Check_Location(20501);
}

bool Refugee1Checked() {
  return (IsCheckedOnServer(20501));
}

void Refugee2() {
  AP_Check_Location(20502);
}

bool Refugee2Checked() {
  return (IsCheckedOnServer(20502));
}

void Refugee3() {
  AP_Check_Location(20503);
}

bool Refugee3Checked() {
  return (IsCheckedOnServer(20503));
}

void Refugee4() {
  AP_Check_Location(20504);
}

bool Refugee4Checked() {
  return (IsCheckedOnServer(20504));
}

void Refugee5() {
  AP_Check_Location(20505);
}

bool Refugee5Checked() {
  return (IsCheckedOnServer(20505));
}

void Refugee6() {
  AP_Check_Location(20506);
}

bool Refugee6Checked() {
  return (IsCheckedOnServer(20506));
}

void Refugee7() {
  AP_Check_Location(20507);
}

bool Refugee7Checked() {
  return (IsCheckedOnServer(20507));
}

void Refugee8() {
  AP_Check_Location(20508);
}

bool Refugee8Checked() {
  return (IsCheckedOnServer(20508));
}

void Refugee9() {
  AP_Check_Location(20509);
}

bool Refugee9Checked() {
  return (IsCheckedOnServer(20509));
}

void Refugee10() {
  AP_Check_Location(20510);
}

bool Refugee10Checked() {
  return (IsCheckedOnServer(20510));
}

void Loyalists() {
  AP_Check_Location(20511);
}

bool LoyalistsChecked() {
  return (IsCheckedOnServer(20511));
}

void KingsTroop() {
  AP_Check_Location(20512);
}

bool KingsTroopChecked() {
  return (IsCheckedOnServer(20512));
}

void EscortJoan() {
  AP_Check_Location(20513);
}

bool EscortJoanChecked() {
  return (IsCheckedOnServer(20513));
}

void Escort6Refugees() {
  AP_Check_Location(20514);
}

bool Escort6RefugeesChecked() {
  return (IsCheckedOnServer(20514));
}

void SetPavilionLayout() {
    SetPavilionPlacement(6, 176, PAVILION_FACE_NE);
}
