extern const int MERCENARY_CAPACITY = 100;

vector mercenaryList = cInvalidVector;
int newMercenaryAddress = 0;

void InitMercenaryTable() {
    defineStruct("Mercenary");
    defineStructAttribute("Mercenary", "id", TYPE_INT);
    defineStructAttribute("Mercenary", "name", TYPE_STRING);
    defineStructAttribute("Mercenary", "unitCount", TYPE_INT);
    defineStructAttribute("Mercenary", "used", TYPE_BOOL);

    defineStruct("MercenaryList");
    defineStructAttribute("MercenaryList", "mercenaries", TYPE_STRUCT_ARRAY);

    mercenaryList = new("MercenaryList");
    int mercenaries = xsArrayCreateVector(MERCENARY_CAPACITY, cInvalidVector, "ap-mercenaries");
    structSetInt(mercenaryList, "mercenaries", mercenaries);
    newMercenaryAddress = 0;
}

vector GetMercenaryById(int mercenaryId = -1) {
    int mercenaries = structGetInt(mercenaryList, "mercenaries");
    for (i = 0; < newMercenaryAddress) {
        vector mercenary = xsArrayGetVector(mercenaries, i);
        if (structGetInt(mercenary, "id") == mercenaryId) {
            return (mercenary);
        }
    }
    return (cInvalidVector);
}

vector addMercenary(int mercenaryId = -1, string mercenaryName = "", int unitCount = 0) {
    if (newMercenaryAddress >= MERCENARY_CAPACITY) {
        xsChatData("<RED>addMercenary: past the capacity of " + MERCENARY_CAPACITY + ", dropped " + mercenaryId);
        return (cInvalidVector);
    }
    if (GetMercenaryById(mercenaryId) != cInvalidVector) {
        return (cInvalidVector);
    }

    vector mercenary = new("Mercenary");
    structSetInt(mercenary, "id", mercenaryId);
    structSetString(mercenary, "name", mercenaryName);
    structSetInt(mercenary, "unitCount", unitCount);
    structSetBool(mercenary, "used", false);

    int mercenaries = structGetInt(mercenaryList, "mercenaries");
    xsArraySetVector(mercenaries, newMercenaryAddress, mercenary);
    newMercenaryAddress = newMercenaryAddress + 1;
    return (mercenary);
}

int MercenaryUnitCount(int mercenaryId = -1) {
    vector mercenary = GetMercenaryById(mercenaryId);
    if (mercenary == cInvalidVector) {
        xsChatData("MercenaryUnitCount: Mercenary does not exist: %d", mercenaryId);
        return (0);
    }
    return (structGetInt(mercenary, "unitCount"));
}

string MercenaryName(int mercenaryId = -1) {
    vector mercenary = GetMercenaryById(mercenaryId);
    if (mercenary == cInvalidVector) {
        xsChatData("MercenaryName: Mercenary does not exist: %d", mercenaryId);
        return ("");
    }
    return (structGetString(mercenary, "name"));
}

bool IsMercenaryUsed(int mercenaryId = -1) {
    vector mercenary = GetMercenaryById(mercenaryId);
    if (mercenary == cInvalidVector) {
        xsChatData("IsMercenaryUsed: Mercenary does not exist: %d", mercenaryId);
        return (false);
    }
    return (structGetBool(mercenary, "used"));
}

void SetMercenaryUsed(int mercenaryId = -1) {
    vector mercenary = GetMercenaryById(mercenaryId);
    if (mercenary == cInvalidVector) {
        xsChatData("SetMercenaryUsed: Mercenary does not exist: %d", mercenaryId);
        return;
    }
    structSetBool(mercenary, "used", true);
}

include "./MercenaryData.xs";

void LoadMercenaries() {
    InitMercenaryTable();
    LoadMercenaryTable();
}
