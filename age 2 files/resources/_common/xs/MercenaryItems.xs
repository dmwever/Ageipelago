// Mercenaries by Scenario

//Attila 1
bool attila1RomanVillagers = false;
void Attila1RomanVillagers() {
    attila1RomanVillagers = true;
}

bool HasAttila1RomanVillagers() {
    return (attila1RomanVillagers);
}

bool attila1ScythianMangudai = false;
void Attila1ScythianMangudai() {
    attila1ScythianMangudai = true;
}

bool HasAttila1ScythianMangudai() {
    return (attila1ScythianMangudai);
}

//Attila 2
bool attila2DyrrhachiumPrisoners = false;
void Attila2DyrrhachiumPrisoners() {
    attila2DyrrhachiumPrisoners = true;
}

bool HasAttila2DyrrhachiumPrisoners() {
    return (attila2DyrrhachiumPrisoners);
}

bool attila2ScythianTroop = false;
void Attila2ScythianTroop() {
    attila2ScythianTroop = true;
}

bool HasAttila2ScythianTroop() {
    return (attila2ScythianTroop);
}

// Joan 1
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

// Joan 5
bool joan5Loyalists = false;
void Joan5Loyalists() {
    joan5Loyalists = true;
}

bool HasJoan5Loyalists() {
    return (joan5Loyalists);
}

bool joan5KingsTroop = false;
void Joan5KingsTroop() {
    joan5KingsTroop = true;
}

bool HasJoan5KingsTroop() {
    return (joan5KingsTroop);
}

// Joan 6
bool joan6LaHire = false;
void Joan6LaHire() {
    joan6LaHire = true;
}

bool HasJoan6LaHire() {
    return (joan6LaHire);
}

bool joan6Artillery = false;
void Joan6Artillery() {
    joan6Artillery = true;
}

bool HasJoan6Artillery() {
    return (joan6Artillery);
}


void GiveMercenary(int itemId = -1) {
    switch(itemId) {
        case 4000: {
            Attila1ScythianMangudai();
        }
        case 4001: {
            Attila1RomanVillagers();
        }
        case 4002: {
            Attila2DyrrhachiumPrisoners();
        }
        case 4003: {
            Attila2ScythianTroop();
        }
        case 4004: {
            Joan1Ram();
        }
        case 4005: {
            Joan1Swordsmen();
        }
        case 4006: {
            Joan1Crossbowmen();
        }
        case 4007: {
            Joan1Recruits();
        }
        case 4008: {
            Joan5Loyalists();
        }
        case 4009: {
            Joan5KingsTroop();
        }
        case 4010: {
            Joan6LaHire();
        }
        case 4011: {
            Joan6Artillery();
        }
    }
}