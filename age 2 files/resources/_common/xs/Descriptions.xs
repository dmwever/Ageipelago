bool classificationLoaded = false;

string checkedMark() {
    return ("<CheckBoxChecked>");
}

string uncheckedMark() {
    return ("<CheckBoxUnchecked>");
}

string classificationTag(int locationClass = 0) {
    if (locationClass == LOCATION_CLASS_PROGRESSION) {
        return ("<PURPLE>");
    }
    if (locationClass == LOCATION_CLASS_USEFUL) {
        return ("<BLUE>");
    }
    if (locationClass == LOCATION_CLASS_FILLER) {
        return ("<AQUA>");
    }
    return ("");
}

bool ShouldDecorateLocation(vector location = cInvalidVector) {
    if (location == cInvalidVector) {
        return (false);
    }
    if (classificationLoaded == false) {
        return (true);
    }
    return (structGetInt(location, "classification") != LOCATION_CLASS_UNSCOUTED);
}

string checkedSegment(vector location = cInvalidVector) {
    if (structGetBool(location, "scenarioComplete")
     || structGetBool(location, "serverComplete")) {
        return (checkedMark() + "<GREEN>Checked<DEFAULT>");
    }
    return (uncheckedMark()
          + classificationTag(structGetInt(location, "classification"))
          + "Unchecked<DEFAULT>");
}

string effectSegment(bool unlocked = false, bool isActive = false) {
    if (isActive) {
        return ("<GREEN>Active<DEFAULT>");
    }
    if (unlocked) {
        return ("<YELLOW>Must Research<DEFAULT>");
    }
    return ("<RED>Awaiting Item<DEFAULT>");
}

string EffectStatusText(vector location = cInvalidVector, int tooltipId = -1,
                        bool unlocked = false, bool isActive = false) {
    return (checkedSegment(location) + " - " + effectSegment(unlocked, isActive)
          + "\n" + xsGetString(tooltipId));
}

void RefreshDescriptions() {
    int locations = structGetInt(locationList, "locations");
    for (i = 0; < newLocationAddress) {
        RefreshLocationDescription(xsArrayGetVector(locations, i));
    }
}

void LoadClassification() {
    bool opened = xsOpenFile("classification");
    if (opened == false) {
        return;
    }
    int entries = xsGetFileSize() / CLASSIFICATION_ENTRY_BYTES;
    for (i = 0; < entries) {
        int locationId = xsReadInt();
        int locationClass = xsReadInt();
        vector location = FindLocationById(locationId);
        if (location == cInvalidVector) {
            continue;
        }
        structSetInt(location, "classification", locationClass);
    }
    xsCloseFile();
    classificationLoaded = true;
}
