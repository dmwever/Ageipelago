/* The Archipelago location ledger.
 *
 * Each location is a Location struct with an id and two flags: scenarioComplete
 * (the game has seen it happen) and serverComplete (the client has acked it).
 *
 * newLocationAddress is the fill count. Nothing may iterate the backing array's
 * full size -- slots past the fill count hold cInvalidVector, and every
 * structGet on one is a failed case-sensitive string lookup that also builds two
 * diagnostic strings. Iterating 1024 slots to read 52 was the single largest
 * per-tick cost in AP_Write.
 */

const int LOCATION_CAPACITY = 1024;

vector locationList = cInvalidVector;
int newLocationAddress = 0;

/* Allocated once in InitLocations and reused. FilterCompletedNotSent fills it
 * and sets filteredCount; callers must iterate filteredCount, never the array
 * size. Allocating a fresh array per call leaked one array per tick. */
int filterArray = -1;
int filteredCount = 0;

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

    /* Ledger capacity and struct-instance capacity are separate limits:
     * LOCATION_CAPACITY sizes the array, MAX_INSTANCE_PER_STRUCT (structs.xs)
     * caps how many Location structs can exist at all. Storing a failed new()
     * would put a cInvalidVector in the ledger and every later read of it would
     * silently return -1. */
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

/* Fills filterArray with locations the game has completed but the server has not
 * acked, and sets filteredCount. Returns the array id for convenience.
 * Entries past filteredCount are stale and must not be read. */
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
