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
    }
}