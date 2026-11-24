include "./AP.xs";

void InitScenarioLocations() {
  // Scenario-Specific - Not defeatsanity/relics
  AddLocations(10300, 10315);
}

void GiveScenarioItems() {
  ReadScenarioItemFile("ATT3");
}

void SetScenarioAge() {
  SetVanillaAge(CASTLE_AGE);
  SetMaxAge(CASTLE_AGE);
}

void main() {
  SetScenarioId(103);
  InitAP();
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(10300);
}

bool VictoryChecked() {
  return (IsCheckedOnServer(10300));
}

void GreenDock1() {
  AP_Check_Location(10301);
}

bool GreenDock1Checked() {
  return (IsCheckedOnServer(10301));
}

void GreenDock2() {
  AP_Check_Location(10302);
}

bool GreenDock2Checked() {
  return (IsCheckedOnServer(10302));
}

void FindGold() {
  AP_Check_Location(10303);
}

bool FindGoldChecked() {
  return (IsCheckedOnServer(10303));
}

void GreenTC() {
  AP_Check_Location(10304);
}

bool GreenTCChecked() {
  return (IsCheckedOnServer(10304));
}

void BlueDockNorth() {
  AP_Check_Location(10305);
}

bool BlueDockNorthChecked() {
  return (IsCheckedOnServer(10305));
}

void BlueDocksSouth() {
  AP_Check_Location(10306);
}

bool BlueDocksSouthChecked() {
  return (IsCheckedOnServer(10306));
}

void BuildCastle() {
  AP_Check_Location(10307);
}

bool BuildCastleChecked() {
  return (IsCheckedOnServer(10307));
}

void RedTradeCarts() {
  AP_Check_Location(10308);
}

bool RedTradeCartsChecked() {
  return (IsCheckedOnServer(10308));
}

void RedTC() {
  AP_Check_Location(10309);
}

bool RedTCChecked() {
  return (IsCheckedOnServer(10309));
}

void BlueCogs() {
  AP_Check_Location(10310);
}

bool BlueCogsChecked() {
  return (IsCheckedOnServer(10310));
}

void RedDock() {
  AP_Check_Location(10311);
}

bool RedDockChecked() {
  return (IsCheckedOnServer(10311));
}

void RedMarket() {
  AP_Check_Location(10312);
}

bool RedMarketChecked() {
  return (IsCheckedOnServer(10312));
}

void ThreatenWonder() {
  AP_Check_Location(10313);
}

bool ThreatenWonderChecked() {
  return (IsCheckedOnServer(10313));
}

void DestroyWonder() {
  AP_Check_Location(10314);
}

bool DestroyWonderChecked() {
  return (IsCheckedOnServer(10314));
}

void BlueMonastery() {
    AP_Check_Location(10315);
}

bool BlueMonasteryChecked() {
  return (IsCheckedOnServer(10315));
}

void SetPavilionLayout() {
    SetPavilionPlacement(103, 1, PAVILION_FACE_SE);
}
