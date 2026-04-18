extern const int victoryTech = 1180;

void ShowVictory() {
    xsEffectAmount(cModifyTech, victoryTech, cAttrSetLocation, 624.0);
    xsEffectAmount(cModifyTech, victoryTech, cAttrSetButton, 1.0);
    xsEffectAmount(cModifyTech, victoryTech, cAttrSetIcon, 107.0);
    xsEffectAmount(cModifyTech, victoryTech, cAttrSetState, cAttributeForce);
}

bool DeclareVictory() {
    return (xsGetTechState(victoryTech, 1) == cTechStateDone);
}