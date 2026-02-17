const int townCenter = 621
const int startingTownCenter = 218
const int house = 70
const int mill = 68

void InitBuildsanityEconomy() {
    xsEffectAmount(cEnableObject, townCenter, cAttributeDisable, 0, 1);
    xsEffectAmount(cModResource, startingTownCenter, cAttributeSet, 0, 1);
    xsEffectAmount(cEnableObject, house, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, 68, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, 562, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, 584, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, 45, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, 84, cAttributeDisable, 0, 1);
}

void InitBuildsanityTech() {
    xsEffectAmount(cEnableObject, 70, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, 68, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, 562, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, 584, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, 45, cAttributeDisable, 0, 1);
    xsEffectAmount(cEnableObject, 84, cAttributeDisable, 0, 1);
}