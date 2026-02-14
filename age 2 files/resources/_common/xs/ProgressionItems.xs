//General Items
void TOWN_CENTER_WOOD() {
    xsEffectAmount(cModResource, cAttributeWood, cAttributeAdd, 275.0);
}

void TOWN_CENTER_STONE() {
    xsEffectAmount(cModResource, cAttributeStone, cAttributeAdd, 100.0);
}

// Scenario-specific items

//Attila 1
bool bledasCamp = false;
void ATTILA_1_BLEDAS_CAMP() {
    bledasCamp = true;
}

bool HAS_BLEDAS_CAMP() {
    return (bledasCamp);
}

bool attilasCamp = false;
void ATTILA_1_ATTILAS_CAMP() {
    attilasCamp = true;
}

bool HAS_ATTILAS_CAMP() {
    return (attilasCamp);
}

bool romanCampVils = false;
void ATTILA_1_ROMAN_CAMP_VILS() {
    romanCampVils = true;
}

bool HAS_ROMAN_CAMP_VILS() {
    return (romanCampVils);
}

//Attila 2
bool attila2Villagers = false;
void ATTILA_2_VILLAGERS_TRIGGER() {
    attila2Villagers = true;
}

bool HAS_ATTILA_2_VILLAGERS() {
    return (attila2Villagers);
}

//Attila 3
bool attila3RedGold = false;
void ATTILA_3_RED_GOLD() {
    attila3RedGold = true;
}

bool HAS_ATTILA_3_RED_GOLD() {
    return (attila3RedGold);
}

bool attila3GreenGold = false;
void ATTILA_3_GREEN_GOLD() {
    attila3GreenGold = true;
}

bool HAS_ATTILA_3_GREEN_GOLD() {
    return (attila3GreenGold);
}

void GiveProgressionItem(int itemId = -1) {
    switch(itemId) {
        case 1000: {
            TOWN_CENTER_WOOD();
        }
        case 1001: {
            TOWN_CENTER_STONE();
        }
        case 1002: {
            ATTILA_1_BLEDAS_CAMP();
        }
        case 1003: {
            ATTILA_1_ATTILAS_CAMP();
        }
        case 1004: {
            ATTILA_2_VILLAGERS_TRIGGER();
        }
        case 1005: {
            ATTILA_3_RED_GOLD();
        }
        case 1006: {
            ATTILA_3_GREEN_GOLD();
        }
    }
}