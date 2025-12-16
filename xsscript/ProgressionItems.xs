//General Items
void TOWN_CENTER_WOOD() {
    xsEffectAmount(cModResource, cAttributeWood, cAttributeAdd, 275.0);
}

void TOWN_CENTER_STONE() {
    xsEffectAmount(cModResource, cAttributeStone, cAttributeAdd, 100.0);
}

// Scenario-specific items
void AP_ATTILA_2_VILLAGERS_TRIGGER() {
    xsSetTriggerVariable(2, 1);
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
    }
}