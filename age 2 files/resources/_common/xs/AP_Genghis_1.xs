include "./AP.xs";

void InitScenarioLocations() {
  // Scenario-Specific - Not defeatsanity/relics
  AddLocations(30100, 30122);
}

void GiveScenarioItems() {
  ReadScenarioItemFile("GEN1");
}

void SetScenarioAge() {
  SetVanillaAge(DARK_AGE);
}

void main() {
  SetScenarioId(301);
  InitAP();
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(30100);
}

// Branching - any: how many tribes joined, whichever they were
void RecruitOneTribe() {
  AP_Check_Location(30101);
}

void RecruitTwoTribes() {
  AP_Check_Location(30102);
}

void RecruitThreeTribes() {
  AP_Check_Location(30103);
}

void AnyRelic() {
  AP_Check_Location(30104);
}

// Branching - all: each tribe in its own right. The Tayichi'uds and the Naiman
// each demand the other's destruction, so a single run can never take both.
void RecruitBlue() {
  AP_Check_Location(30105);
}

void RecruitPurple() {
  AP_Check_Location(30106);
}

void RecruitGrey() {
  AP_Check_Location(30107);
}

void RecruitGreen() {
  AP_Check_Location(30108);
}

void RecruitCyan() {
  AP_Check_Location(30109);
}

// Branching - all: each relic where it lies
void RedMonasteryRelic() {
  AP_Check_Location(30110);
}

void WolfRelic() {
  AP_Check_Location(30111);
}

void PalisadedRelic() {
  AP_Check_Location(30112);
}

// The ten flocks, named for what they stand beside. Three lie in Kereyid (blue)
// country with no nearer landmark to tell them apart, so they are numbered.
void FlockByBlue1() {
  AP_Check_Location(30113);
}

void FlockByBlue2() {
  AP_Check_Location(30114);
}

void FlockByBlue3() {
  AP_Check_Location(30115);
}

void KaraKhitaiHerd() {
  AP_Check_Location(30116);
}

void FlockByGrey() {
  AP_Check_Location(30117);
}

void OpenSteppeFlock() {
  AP_Check_Location(30118);
}

void FlockByRedMonastery() {
  AP_Check_Location(30119);
}

void FlockByGreen() {
  AP_Check_Location(30120);
}

void SoutheastFlock() {
  AP_Check_Location(30121);
}

void FlockByPurple() {
  AP_Check_Location(30122);
}

void SetPavilionLayout() {
    SetPavilionPlacement(38, 149, PAVILION_FACE_NW);
}
