//General Items
void TOWN_CENTER_WOOD() {
    xsEffectAmount(cModResource, cAttributeWood, cAttributeAdd, 275.0);
}

void TOWN_CENTER_STONE() {
    xsEffectAmount(cModResource, cAttributeStone, cAttributeAdd, 100.0);
}

// Scenario-specific items
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

bool attila2Villagers = false;
void AP_ATTILA_2_VILLAGERS_TRIGGER() {
    attila2Villagers = true;
}

bool HAS_ATTILA_2_VILLAGERS() {
    return (attila2Villagers);
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
            AP_ATTILA_2_VILLAGERS_TRIGGER();
        }
        case 1003: {
            ATTILA_1_BLEDAS_CAMP();
        }
        case 1004: {
            ATTILA_1_ATTILAS_CAMP();
        }
    }
}