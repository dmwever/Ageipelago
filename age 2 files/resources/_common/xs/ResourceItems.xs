void FILLER_WOOD_SMALL() {
    xsEffectAmount(cModResource, cAttributeWood, cAttributeAdd, 100.0);
}

void FILLER_FOOD_SMALL() {
    xsEffectAmount(cModResource, cAttributeFood, cAttributeAdd, 100.0);
}

void FILLER_GOLD_SMALL() {
    xsEffectAmount(cModResource, cAttributeGold, cAttributeAdd, 100.0);
}

void FILLER_STONE_SMALL() {
    xsEffectAmount(cModResource, cAttributeStone, cAttributeAdd, 50.0);
}

void FILLER_WOOD_MEDIUM() {
    xsEffectAmount(cModResource, cAttributeWood, cAttributeAdd, 250.0);
}

void FILLER_FOOD_MEDIUM() {
    xsEffectAmount(cModResource, cAttributeFood, cAttributeAdd, 250.0);
}

void FILLER_GOLD_MEDIUM() {
    xsEffectAmount(cModResource, cAttributeGold, cAttributeAdd, 250.0);
}

void FILLER_STONE_MEDIUM() {
    xsEffectAmount(cModResource, cAttributeStone, cAttributeAdd, 125.0);
}

void FILLER_WOOD_LARGE() {
    xsEffectAmount(cModResource, cAttributeWood, cAttributeAdd, 1000.0);
}

void FILLER_FOOD_LARGE() {
    xsEffectAmount(cModResource, cAttributeFood, cAttributeAdd, 1000.0);
}

void FILLER_GOLD_LARGE() {
    xsEffectAmount(cModResource, cAttributeGold, cAttributeAdd, 1000.0);
}

void FILLER_STONE_LARGE() {
    xsEffectAmount(cModResource, cAttributeStone, cAttributeAdd, 500.0);
}

void STARTING_WOOD_SMALL() {
    xsEffectAmount(cModResource, cAttributeWood, cAttributeAdd, 50.0);
}

void STARTING_FOOD_SMALL() {
    xsEffectAmount(cModResource, cAttributeFood, cAttributeAdd, 50.0);
}

void STARTING_GOLD_SMALL() {
    xsEffectAmount(cModResource, cAttributeGold, cAttributeAdd, 50.0);
}

void STARTING_STONE_SMALL() {
    xsEffectAmount(cModResource, cAttributeStone, cAttributeAdd, 25.0);
}

void STARTING_WOOD_MEDIUM() {
    xsEffectAmount(cModResource, cAttributeWood, cAttributeAdd, 100.0);
}

void STARTING_FOOD_MEDIUM() {
    xsEffectAmount(cModResource, cAttributeFood, cAttributeAdd, 100.0);
}

void STARTING_GOLD_MEDIUM() {
    xsEffectAmount(cModResource, cAttributeGold, cAttributeAdd, 100.0);
}

void STARTING_STONE_MEDIUM() {
    xsEffectAmount(cModResource, cAttributeStone, cAttributeAdd, 50.0);
}

void STARTING_WOOD_LARGE() {
    xsEffectAmount(cModResource, cAttributeWood, cAttributeAdd, 250.0);
}

void STARTING_FOOD_LARGE() {
    xsEffectAmount(cModResource, cAttributeFood, cAttributeAdd, 250.0);
}

void STARTING_GOLD_LARGE() {
    xsEffectAmount(cModResource, cAttributeGold, cAttributeAdd, 250.0);
}

void STARTING_STONE_LARGE() {
    xsEffectAmount(cModResource, cAttributeStone, cAttributeAdd, 125.0);
}

void GiveResource(int itemId = -1) {
    switch(itemId) {
        case 1: {
            FILLER_WOOD_SMALL();
        }
        case 2: {
            FILLER_FOOD_SMALL();
        }
        case 3: {
            FILLER_GOLD_SMALL();
        }
        case 4: {
            FILLER_STONE_SMALL();
        }
        case 5: {
            FILLER_WOOD_MEDIUM();
        }
        case 6: {
            FILLER_FOOD_MEDIUM();
        }
        case 7: {
            FILLER_GOLD_MEDIUM();
        }
        case 8: {
            FILLER_STONE_MEDIUM();
        }
        case 9: {
            FILLER_WOOD_LARGE();
        }
        case 10: {
            FILLER_FOOD_LARGE();
        }
        case 11: {
            FILLER_GOLD_LARGE();
        }
        case 12: {
            FILLER_STONE_LARGE();
        }
        case 13: {
            STARTING_WOOD_SMALL();
        }
        case 14: {
            STARTING_FOOD_SMALL();
        }
        case 15: {
            STARTING_GOLD_SMALL();
        }
        case 16: {
            STARTING_STONE_SMALL();
        }
        case 17: {
            STARTING_WOOD_MEDIUM();
        }
        case 18: {
            STARTING_FOOD_MEDIUM();
        }
        case 19: {
            STARTING_GOLD_MEDIUM();
        }
        case 20: {
            STARTING_STONE_MEDIUM();
        }
        case 21: {
            STARTING_WOOD_LARGE();
        }
        case 22: {
            STARTING_FOOD_LARGE();
        }
        case 23: {
            STARTING_GOLD_LARGE();
        }
        case 24: {
            STARTING_STONE_LARGE();
        }
    }
}