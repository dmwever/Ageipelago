int pavilionId = -1;
int pavilionX = -1;
int pavilionY = -1;
int pavilionFacing = -1;
int pavilionColor = 0;
bool pavilionVictoryShown = false;

void SetPavilionPlacement(int x = -1, int y = -1, int facing = -1) {
    pavilionX = x;
    pavilionY = y;
    pavilionFacing = facing;
}

bool HasPavilionPlacement() {
    return (pavilionX >= 0 && pavilionY >= 0 && pavilionFacing >= 0);
}

int PavilionStepX() {
    if (pavilionFacing == PAVILION_FACE_NE) {
        return (1);
    }
    if (pavilionFacing == PAVILION_FACE_SW) {
        return (-1);
    }
    return (0);
}

int PavilionStepY() {
    if (pavilionFacing == PAVILION_FACE_SE) {
        return (1);
    }
    if (pavilionFacing == PAVILION_FACE_NW) {
        return (-1);
    }
    return (0);
}

vector PavilionOffsetPoint(int tiles = 0) {
    return (xsVectorSet(1.0 * (pavilionX + tiles * PavilionStepX()),
                        1.0 * (pavilionY + tiles * PavilionStepY()),
                        0.0));
}

vector PavilionPoint() {
    return (PavilionOffsetPoint(0));
}

vector PavilionSpawnPoint() {
    return (PavilionOffsetPoint(PAVILION_SPAWN_OFFSET));
}

vector PavilionMusterPoint() {
    return (PavilionOffsetPoint(PAVILION_MUSTER_OFFSET));
}

int PavilionColorAt(int index = -1) {
    if (index == 0) {
        return (PAVILION_COLOR_RED);
    }
    if (index == 1) {
        return (PAVILION_COLOR_GREEN);
    }
    if (index == 2) {
        return (PAVILION_COLOR_PURPLE);
    }
    if (index == 3) {
        return (PAVILION_COLOR_ORANGE);
    }
    if (index == 4) {
        return (PAVILION_COLOR_BLUE);
    }
    return (PAVILION_COLOR_YELLOW);
}

void SetupPavilion() {
    xsSetUnitName(pavilionId, "APavilion");
    xsEffectAmount(cSetUnitAttribute, pavilionId, cInvulnerabilityLevel,
                   PAVILION_INVULNERABILITY, PAVILION_OWNER);
    xsSetUnitProperty(pavilionId, cUnitDeletable, PAVILION_DELETABLE);
}

void SetupVictory() {
    xsEffectAmount(cModifyTech, PAVILION_VICTORY_TECH, cAttrSetLocation,
                   1.0 * PAVILION_BUILDING, PAVILION_OWNER);
    xsEffectAmount(cModifyTech, PAVILION_VICTORY_TECH, cAttrSetButton,
                   1.0 * PAVILION_VICTORY_BUTTON, PAVILION_OWNER);
    xsEffectAmount(cModifyTech, PAVILION_VICTORY_TECH, cAttrSetIcon,
                   1.0 * PAVILION_VICTORY_ICON, PAVILION_OWNER);
    xsEffectAmount(cModifyTech, PAVILION_VICTORY_TECH, cAttrSetState,
                   STATE_DISABLE, PAVILION_OWNER);
    xsSetTechName(PAVILION_VICTORY_TECH, PAVILION_OWNER, "Declare Victory");
    xsSetTechDescription(PAVILION_VICTORY_TECH, PAVILION_OWNER,
                         "End the scenario now, or keep playing for more checks.");
}

void ShowVictory() {
    xsEffectAmount(cModifyTech, PAVILION_VICTORY_TECH, cAttrSetState,
                   STATE_ENABLE, PAVILION_OWNER);
}

bool HasDeclaredVictory() {
    return (xsGetTechState(PAVILION_VICTORY_TECH, PAVILION_OWNER) == cTechStateDone);
}

void AnnounceVictory() {
    if (pavilionVictoryShown == true) {
        return;
    }
    pavilionVictoryShown = true;

    ShowVictory();

    if (pavilionId != -1) {
        xsSetViewPosition(PAVILION_OWNER, PavilionPoint());
        xsFlashUnit(pavilionId, PAVILION_OWNER);
    }
    xsDisplayInstructions("Click Victory in the APavilion to win, or keep playing for checks.",
                          10, PAVILION_OWNER);

    pavilionColor = 0;
    xsEnableRule("PavilionColorCycle");
    xsEnableRule("PavilionDeclareWatch");
}

void InitPavilion() {
    SetPavilionLayout();
    if (HasPavilionPlacement() == false) {
        xsChatData("<RED>APavilion: this scenario never called SetPavilionPlacement(). No hub"
                   + " building, no victory button and no mercenary seats.");
        return;
    }

    pavilionId = xsCreateUnit(PAVILION_BUILDING, PAVILION_OWNER, PavilionPoint(), false, false, true);
    if (pavilionId == -1) {
        xsChatData("<RED>APavilion: could not place the pavilion at " + pavilionX + ", "
                   + pavilionY + ". The tile is occupied or off the map.");
        return;
    }

    SetupPavilion();
    SetupVictory();
}

rule PavilionColorCycle
    inactive
    group Pavilion
    minInterval 1
    maxInterval 1
{
    if (pavilionId == -1) {
        xsDisableSelf();
        return;
    }
    xsSetUnitProperty(pavilionId, cUnitColorId, 1.0 * PavilionColorAt(pavilionColor));
    pavilionColor++;
    if (pavilionColor >= PAVILION_COLOR_COUNT) {
        pavilionColor = 0;
    }
}

rule PavilionDeclareWatch
    inactive
    group Pavilion
    minInterval 1
    maxInterval 1
{
    if (HasDeclaredVictory() == false) {
        return;
    }
    xsDeclareVictory(PAVILION_OWNER, true);
    xsDisableSelf();
}
