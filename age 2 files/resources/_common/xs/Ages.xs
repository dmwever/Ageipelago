int apVanillaAge = DARK_AGE;

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

void SetVanillaAge(int age = -1) {
    apVanillaAge = age;
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
    if (xsGetTechState(id, 1) == cTechStateDone) {
        return;
    }
    xsEffectAmount(cModifyTech, id, cAttrSetState, STATE_ENABLE, 1);
}

void InitAges() {
    SetScenarioAge();
    if (AP_SHUFFLE_AGES != 1) {
        return;
    }
    for (age = FEUDAL_AGE; <= IMPERIAL_AGE) {
        vector location = AddLocation(age);
        lockAge(age);
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
            AP_Check_Location(age);
            reached++;
        }
    }
    if (reached == 3) {
        xsDisableSelf();
    }
}
