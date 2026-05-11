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

//Joan 1
bool joan1Transports = false;
void Joan1Transports() {
    joan1Transports = true;
}

bool HasJoan1Transports() {
    return (joan1Transports);
}

//Joan 2
bool joan2Carts = false;
void Joan2Carts() {
    joan2Carts = true;
}

bool HasJoan2Carts() {
    return (joan2Carts);
}

bool joan2Orleans = false;
void Joan2Orleans() {
    joan2Orleans = true;
}

bool HasJoan2Orleans() {
    return (joan2Orleans);
}

bool joan2Dock = false;
void Joan2Dock() {
    joan2Dock = true;
}

bool HasJoan2Dock() {
    return (joan2Dock);
}

// Joan 3
bool joan3Boats = false;
void Joan3Boats() {
    joan3Boats = true;
}

bool HasJoan3Boats() {
    return (joan3Boats);
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
        case 1007: {
            Joan1Transports();
        }
        case 1008: {
            Joan2Orleans();
        }
        case 1019: {
            Joan2Carts();
        }
        case 1010: {
            Joan2Dock();
        }
        case 1011: {
            Joan3Boats();
        }
    }
}