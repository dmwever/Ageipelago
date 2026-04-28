// Mercenaries by Scenario

//Attila 1
bool romanCampVils = false;
void ROMAN_CAMP_VILS() {
    romanCampVils = true;
}

bool HAS_ROMAN_CAMP_VILS() {
    return (romanCampVils);
}

bool scythianMangudai = false;
void SCYTHIAN_MANGUDAI() {
    scythianMangudai = true;
}

bool HAS_SCYTHIAN_MANGUDAI() {
    return (scythianMangudai);
}

//Attila 2
bool cyanPrisoners = false;
void DYRRHACHIUM_PRISONERS() {
    cyanPrisoners = true;
}

bool HAS_DYRRHACHIUM_PRISONERS() {
    return (cyanPrisoners);
}

bool scythianTroop = false;
void SCYTHIAN_TROOP() {
    scythianTroop = true;
}

bool HAS_SCYTHIAN_TROOP() {
    return (scythianTroop);
}

bool joan1Crossbowmen = false;
void Joan1Crossbowmen() {
    joan1Crossbowmen = true;
}

bool HasJoan1Crossbowmen() {
    return (joan1Crossbowmen);
}

bool joan1Swordsmen = false;
void Joan1Swordsmen() {
    joan1Swordsmen = true;
}

bool HasJoan1Swordsmen() {
    return (joan1Swordsmen);
}

bool joan1Ram = false;
void Joan1Ram() {
    joan1Ram = true;
}

bool HasJoan1Ram() {
    return (joan1Ram);
}

bool joan1Recruits = false;
void Joan1Recruits() {
    joan1Recruits = true;
}

bool HasJoan1Recruits() {
    return (joan1Recruits);
}

void GiveMercenary(int itemId = -1) {
    switch(itemId) {
        case 4000: {
            SCYTHIAN_MANGUDAI();
        }
        case 4001: {
            ROMAN_CAMP_VILS();
        }
        case 4002: {
            DYRRHACHIUM_PRISONERS();
        }
        case 4003: {
            SCYTHIAN_TROOP();
        }
        case 4004: {
            Joan1Ram();
        }
        case 4005: {
            Joan1Crossbowmen();
        }
        case 4006: {
            Joan1Swordsmen();
        }
        case 4007: {
            Joan1Recruits();
        }
    }
}