//General Items
void TOWN_CENTER_WOOD() {
    xsEffectAmount(cModResource, cAttributeWood, cAttributeAdd, 275.0);
}

void TOWN_CENTER_STONE() {
    xsEffectAmount(cModResource, cAttributeStone, cAttributeAdd, 100.0);
}

// Scenario-specific items
void ATTILA_1_BLEDAS_CAMP(string scenario = "") {
    if (scenario == "ATT1") {
        xsSetTriggerVariable(6, 1);
    }
}

void ATTILA_1_ATTILAS_CAMP(string scenario = "") {
    if (scenario == "ATT1") {
        xsSetTriggerVariable(7, 1);
    }
}

void AP_ATTILA_2_VILLAGERS_TRIGGER(string scenario = "") {
    if (scenario == "ATT2") {
        xsSetTriggerVariable(2, 1);
    }
}

void GiveProgressionItem(int itemId = -1, string scenario = "") {
    switch(itemId) {
        case 1000: {
            TOWN_CENTER_WOOD();
        }
        case 1001: {
            TOWN_CENTER_STONE();
        }
        case 1002: {
            AP_ATTILA_2_VILLAGERS_TRIGGER(scenario);
        }
        case 1003: {
            ATTILA_1_BLEDAS_CAMP(scenario);
        }
        case 1004: {
            ATTILA_1_ATTILAS_CAMP(scenario);
        }
    }
}