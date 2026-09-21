const int LOCATION_CAPACITY = 1024;

vector locationList = cInvalidVector;
int newLocationAddress = 0;

int filterArray = -1;
extern int filteredCount = 0;

vector GetLocationById(int id = -1) {
    if (id == -1) {
        xsChatData("GetLocationById: No Id Set");
        return (cInvalidVector);
    }

    int locations = structGetInt(locationList, "locations");

    for (i = 0; < newLocationAddress) {
        vector location = xsArrayGetVector(locations, i);
        int locationId = structGetInt(location, "id");
        if (locationId == id) {
            return (location);
        }
    }

    xsChatData("Location Not Found: %d", id);
    return (cInvalidVector);
}

vector AddLocation(int id = -1, bool scenarioComplete = false, bool serverComplete = false) {
    if (id == -1) {
        xsChatData("Invalid location id: " + id);
        return (cInvalidVector);
    }

    int locations = structGetInt(locationList, "locations");
    if (newLocationAddress >= xsArrayGetSize(locations)) {
        xsChatData("<RED>AddLocation: ledger full at " + newLocationAddress
                 + ", dropping location " + id);
        return (cInvalidVector);
    }

    vector location = new("Location");
    if (location == cInvalidVector) {
        xsChatData("<RED>AddLocation: out of Location struct instances, dropping location " + id);
        return (cInvalidVector);
    }

    structSetInt(location, "id", id);
    structSetBool(location, "scenarioComplete", scenarioComplete);
    structSetBool(location, "serverComplete", serverComplete);

    xsArraySetVector(locations, newLocationAddress, location);
    newLocationAddress++;

    return (location);
}

int AddLocations(int idStart = -1, int idEnd = -1, bool scenarioComplete = false, bool serverComplete = false) {
    if (idStart == -1 || idEnd == -1 || idStart > idEnd) {
        xsChatData("Invalid start/end id for AddLocations: idStart = " + idStart + ", idEnd = " + idEnd);
        return (-1);
    }

    int arrayLength = idEnd - idStart + 1;      // inclusive of both ends
    int array = xsArrayCreateVector(arrayLength, cInvalidVector);

    for (i = idStart; <= idEnd) {
        vector location = AddLocation(i, scenarioComplete, serverComplete);
        xsArraySetVector(array, i - idStart, location);
    }

    return (array);
}

void InitLocations() {
    defineStruct("Location");
    defineStructAttribute("Location", "id", TYPE_INT);
    defineStructAttribute("Location", "scenarioComplete", TYPE_BOOL);
    defineStructAttribute("Location", "serverComplete", TYPE_BOOL);

    defineStruct("LocationList");
    defineStructAttribute("LocationList", "locations", TYPE_STRUCT_ARRAY);

    locationList = new("LocationList");
    int locations = xsArrayCreateVector(LOCATION_CAPACITY, cInvalidVector, "ap-locations");
    structSetInt(locationList, "locations", locations);

    filterArray = xsArrayCreateVector(LOCATION_CAPACITY, cInvalidVector, "ap-locations-filtered");
    filteredCount = 0;
}

int FilterCompletedNotSent() {
    int locations = structGetInt(locationList, "locations");

    filteredCount = 0;
    for (i = 0; < newLocationAddress) {
        vector location = xsArrayGetVector(locations, i);
        bool scenarioComplete = structGetBool(location, "scenarioComplete");
        bool serverComplete = structGetBool(location, "serverComplete");
        if (scenarioComplete == true && serverComplete == false) {
            xsArraySetVector(filterArray, filteredCount, location);
            filteredCount = filteredCount + 1;
        }
    }

    return (filterArray);
}

void SetScenarioLocationComplete(int locationId = -1) {
    vector location = GetLocationById(locationId);
    if (location == cInvalidVector) {
        xsChatData("SetScenarioLocationComplete: Location does not exist: %d", locationId);
        return;
    }

    structSetBool(location, "scenarioComplete", true);
}

bool IsScenarioLocationComplete(int locationId = -1) {
    vector location = GetLocationById(locationId);
    if (location == cInvalidVector) {
        xsChatData("IsScenarioLocationComplete: Location does not exist: %d", locationId);
        return (false);
    }

    return (structGetBool(location, "scenarioComplete"));
}

void SetServerLocationComplete(int locationId = -1) {
    vector location = GetLocationById(locationId);
    if (location == cInvalidVector) {
        xsChatData("SetServerLocationComplete: Location does not exist: %d", locationId);
        return;
    }

    structSetBool(location, "serverComplete", true);
}

bool IsServerLocationComplete(int locationId = -1) {
    vector location = GetLocationById(locationId);
    if (location == cInvalidVector) {
        xsChatData("IsServerLocationComplete: Location does not exist: %d", locationId);
        return (false);
    }

    return (structGetBool(location, "serverComplete"));
}
