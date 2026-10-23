extern int apVanillaAge = DARK_AGE;

extern int apMaxAge = IMPERIAL_AGE;

bool has_castle = false;
bool has_imperial = false;

bool feudalRegistered = false;
bool castleRegistered = false;
bool imperialRegistered = false;

int ageTechFor(int age = -1) {
    if (age == FEUDAL_AGE) {
        return (FEUDAL_AGE_TECH);
    }
    if (age == CASTLE_AGE) {
        return (CASTLE_AGE_TECH);
    }
    if (age == IMPERIAL_AGE) {
        return (IMPERIAL_AGE_TECH);
    }
    return (-1);
}

bool ageRegistered(int age = -1) {
    if (age == FEUDAL_AGE) {
        return (feudalRegistered);
    }
    if (age == CASTLE_AGE) {
        return (castleRegistered);
    }
    if (age == IMPERIAL_AGE) {
        return (imperialRegistered);
    }
    return (false);
}

void setAgeRegistered(int age = -1) {
    if (age == FEUDAL_AGE) {
        feudalRegistered = true;
    }
    if (age == CASTLE_AGE) {
        castleRegistered = true;
    }
    if (age == IMPERIAL_AGE) {
        imperialRegistered = true;
    }
}

void SetVanillaAge(int age = -1) {
    apVanillaAge = age;
}

void SetMaxAge(int age = -1) {
    apMaxAge = age;
}

void completeIfPending(int id = -1) {
    if (xsGetTechState(id, 1) == cTechStateDone) {
        return;
    }
    xsEffectAmount(cModifyTech, id, cAttrSetState, STATE_DONE, 1);
}

void ClimbToVanillaAge() {
    if (AP_TS_EXISTING == EXISTING_START_IN_DARK_AGE) {
        return;
    }
    if (apVanillaAge >= FEUDAL_AGE) {
        completeIfPending(FEUDAL_AGE_TECH);
    }
    if (apVanillaAge >= CASTLE_AGE) {
        completeIfPending(CASTLE_AGE_TECH);
    }
    if (apVanillaAge >= IMPERIAL_AGE) {
        completeIfPending(IMPERIAL_AGE_TECH);
    }
}

void lockAge(int age = -1) {
    int id = ageTechFor(age);
    if (id < 0) {
        return;
    }
    if (xsGetTechState(id, 1) == cTechStateDone) {
        return;
    }
    xsEffectAmount(cModifyTech, id, cAttrSetState, STATE_DISABLE, 1);
}

void UnlockAge(int itemId = -1) {
    int id = ageTechFor(itemId);
    if (id < 0) {
        return;
    }
    if (itemId > apMaxAge) {
        return;
    }
    if (xsGetTechState(id, 1) == cTechStateDone) {
        return;
    }
    if (ageReached(itemId - 1)) {
        xsEffectAmount(cModifyTech, id, cAttrSetState, STATE_ENABLE, 1);
    }
    else {
        if (itemId == CASTLE_AGE) {
            has_castle = true;
        }
        if (itemId == IMPERIAL_AGE) {
            has_imperial = true;
        }
    }
}

void InitAges() {
    feudalRegistered = false;
    castleRegistered = false;
    imperialRegistered = false;
    SetScenarioAge();
    ClimbToVanillaAge();
    for (capped = FEUDAL_AGE; <= IMPERIAL_AGE) {
        if (capped > apMaxAge) {
            lockAge(capped);
        }
    }
    if (AP_SHUFFLE_AGES != 1) {
        return;
    }
    for (age = FEUDAL_AGE; <= IMPERIAL_AGE) {
        if (age <= apMaxAge && xsGetTechState(ageTechFor(age), 1) != cTechStateDone) {
            vector location = AddLocation(age);
            if (location != cInvalidVector) {
                setAgeRegistered(age);
            }
            lockAge(age);
        }
    }
    xsEnableRule("ShuffleAgesUpdate");
}

rule ShuffleAgesUpdate
    inactive
    group Ages
    minInterval 1
    maxInterval 1
{
    int reached = 0;
    for (age = FEUDAL_AGE; <= IMPERIAL_AGE) {
        if (xsGetTechState(ageTechFor(age), 1) == cTechStateDone) {
            if (ageRegistered(age)) {
                AP_Check_Location(age);
            }
            if (age == FEUDAL_AGE && has_castle) {
                UnlockAge(CASTLE_AGE);
                has_castle = false;
            }
            if (age == CASTLE_AGE && has_imperial) {
                UnlockAge(IMPERIAL_AGE);
                has_imperial = false;
            }
            reached++;
        }
    }

    if (reached == apMaxAge - DARK_AGE) {
        xsDisableSelf();
    }
}
