include "./AP.xs";

void InitScenarioSpecific() {
  ScenarioSpecificInit("ATT1");
}

void main() {
  AP_init();
  InitScenarioSpecific();
}

// Scenario-specific locations
void Victory() {
  AP_Check_Location(0);
}

void UniteTheHuns() {
  AP_Check_Location(1);
}

void FreeVillagers() {
  AP_Check_Location(2);
}

void ResolveScoutAny() {
  AP_Check_Location(3);
}

void CaptureHorsesCamp() {
  AP_Check_Location(4);
}

void CaptureHorsesRuins() {
  AP_Check_Location(5);
}

void CaptureHorsesLumber() {
  AP_Check_Location(6);
}

void CsptureHorsesBehindBase() {
  AP_Check_Location(7);
}

void CaptureHorsesWest() {
  AP_Check_Location(8);
}

void CaptureHorsesRoman() {
  AP_Check_Location(9);
}

void KillTheBoar() {
  AP_Check_Location(10);
}

void BetrayBleda() {
  AP_Check_Location(11);
}

void BlowBledaOff() {
  AP_Check_Location(12);
}

void FreeScout() {
  AP_Check_Location(13);
}

void KillScout() {
  AP_Check_Location(14);
}

void GiveHorses() {
  AP_Check_Location(15);
}

void DefeatFirstPlayer() {
  AP_Check_Location(16);
}

void DefeatsanityBlue() {
AP_Check_Location(17);
}

void DefeatsanityRed() {
AP_Check_Location(18);
}

void DefeatsanityGreen() {
AP_Check_Location(19);
}

void DefeatsanityPurple() {
AP_Check_Location(20);
}
