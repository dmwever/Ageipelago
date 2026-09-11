/*
 * ##########################################################
 *       __  __      ____  _                   _
 *       \ \/ /___  / ___|| |_ _ __ _   _  ___| |_ ___
 *        \  // __| \___ \| __| '__| | | |/ __| __/ __|
 *        /  \\__ \  ___) | |_| |  | |_| | (__| |_\__ \
 *       /_/\_\___/ |____/ \__|_|   \__,_|\___|\__|___/
 *
 * ##########################################################
 *
 * Created by MrKirby -- https://github.com/KSneijders/XsStructs
 * Version: 1.0.0 (2026-01-25)
 *
 * ######################## Credits #########################
 * XS-Check by Alian -- https://github.com/Divy1211/xs-check
 * Ascii art by: https://patorjk.com/software/taag
 * ##########################################################
 */

bool STRUCTS_INITIALIZED = false;

extern int MAX_STRUCT_COUNT = 10;
extern int MAX_STRUCT_ATTRIBUTES = 12;
extern int MAX_INSTANCE_PER_STRUCT = 400;
extern int STRUCT_PRINT_BUFFER_SIZE = 200;

extern int TYPE_INT = 0;
extern int TYPE_BOOL = 1;
extern int TYPE_FLOAT = 2;
extern int TYPE_STRING = 3;
extern int TYPE_VECTOR = 4;
extern int TYPE_STRUCT = 5;
extern int TYPE_INT_ARRAY = 100;
extern int TYPE_BOOL_ARRAY = 101;
extern int TYPE_FLOAT_ARRAY = 102;
extern int TYPE_STRING_ARRAY = 103;
extern int TYPE_VECTOR_ARRAY = 104;
extern int TYPE_STRUCT_ARRAY = 105;
extern int TYPE_INT_ARRAY_2D = 200;
extern int TYPE_BOOL_ARRAY_2D = 201;
extern int TYPE_FLOAT_ARRAY_2D = 202;
extern int TYPE_STRING_ARRAY_2D = 203;
extern int TYPE_VECTOR_ARRAY_2D = 204;
extern int TYPE_STRUCT_ARRAY_2D = 205;
extern int TYPE_INT_ARRAY_3D = 300;
extern int TYPE_BOOL_ARRAY_3D = 301;
extern int TYPE_FLOAT_ARRAY_3D = 302;
extern int TYPE_STRING_ARRAY_3D = 303;
extern int TYPE_VECTOR_ARRAY_3D = 304;
extern int TYPE_STRUCT_ARRAY_3D = 305;
/* Nesting arrays deeper than three is supported (also in printing).
   So for a 5D string array, use: 503 */

int STRUCT_NAME_ARRAY = -1;
int STRUCT_ATTRIBUTE_NAMES_ARRAY_ARRAY = -1;
int STRUCT_ATTRIBUTE_TYPES_ARRAY_ARRAY = -1;
int STRUCT_INSTANCE_ARRAY_ARRAY = -1;

int STRUCT_VALIDATION_REF_ARRAY = -1;

// xsc-ignore: TopStrInit
string MOST_RECENT_ERROR = "";
// xsc-ignore: TopStrInit
string MOST_RECENT_ORIGIN = "";
bool MOST_RECENT_GET_FAILED = false;

int STRUCT_PRINT_BUFFER = -1;
int STRUCT_PRINT_BUFFER_POINTER = 0;

void clearPrintBuffer() {
    for(i = 0; < xsArrayGetSize(STRUCT_PRINT_BUFFER)) {
        xsArraySetString(STRUCT_PRINT_BUFFER, i, "");
    }
    STRUCT_PRINT_BUFFER_POINTER = 0;
}

bool buffer(string str = "") {
    if (STRUCT_PRINT_BUFFER_POINTER > (STRUCT_PRINT_BUFFER_SIZE - 1)) {
        MOST_RECENT_ERROR = "PRINT BUFFER FULL";
        return (false);
    }

    string existing = xsArrayGetString(STRUCT_PRINT_BUFFER, STRUCT_PRINT_BUFFER_POINTER);
    xsArraySetString(STRUCT_PRINT_BUFFER, STRUCT_PRINT_BUFFER_POINTER, existing + str);

    return (true);
}

bool bufferLine(string line = "") {
    bool success = buffer(line);
    if (success == false) {
        return (false);
    }

    STRUCT_PRINT_BUFFER_POINTER++;

    return (true);
}

void printBuffer() {
    string line = "";
    for(i = 0; < xsArrayGetSize(STRUCT_PRINT_BUFFER)) {
        line = xsArrayGetString(STRUCT_PRINT_BUFFER, i);
        if (line == "") {
            continue;
        }

        string prefix = "" + i;
        if (i < 10) {
            prefix = "0" + prefix;
        }

        xsChatData("|" + prefix + "| " + line);
    }

    clearPrintBuffer();
}

int findIndexString(int arrayId = -1, string match = "") {
    for(i = 0; < xsArrayGetSize(arrayId)) {
        if (xsArrayGetString(arrayId, i) == match) {
            return (i);
        }
    }

    return (-1);
}

int findIndexInt(int arrayId = -1, int match = -1) {
    for(i = 0; < xsArrayGetSize(arrayId)) {
        if (xsArrayGetInt(arrayId, i) == match) {
            return (i);
        }
    }

    return (-1);
}

int findStructIndex(string structName = "") {
    return (findIndexString(STRUCT_NAME_ARRAY, structName));
}

bool defineStruct(string name = "") {
    if (STRUCTS_INITIALIZED == false) {
        xsChatData("The `initializeStructsScript()` has to be called before defining a struct!");
        return (false);
    }

    if (findStructIndex(name) != -1) {
        MOST_RECENT_ERROR = "Struct with name ["+name+"] already exists";
        MOST_RECENT_ORIGIN = "defineStruct('"+name+"')";
        return (false);
    }

    int index = findStructIndex("");
    if (index == -1) {
        MOST_RECENT_ERROR = "No struct slot remaining";
        MOST_RECENT_ORIGIN = "defineStruct('"+name+"')";
        return (false);
    }

    xsArraySetString(STRUCT_NAME_ARRAY, index, name);

    return (true);
}

bool defineStructAttribute(string structName = "", string structAttribute = "", int structType = -1) {
    int structIndex = findStructIndex(structName);
    if (structIndex == -1) {
        MOST_RECENT_ERROR = "Unable to find struct for name ["+structName+"]";
        MOST_RECENT_ORIGIN = "defineStructAttribute('"+structName+"', '"+structAttribute+"')";
        return (false);
    }

    int attributesNameArray = xsArrayGetInt(STRUCT_ATTRIBUTE_NAMES_ARRAY_ARRAY, structIndex);
    if (findIndexString(attributesNameArray, structAttribute) != -1) {
        MOST_RECENT_ERROR = "Attribute ["+structAttribute+"] on ["+structName+"] already exists";
        MOST_RECENT_ORIGIN = "defineStructAttribute('"+structName+"', '"+structAttribute+"')";
        return (false);
    }

    int emptyAttrIndex = findIndexString(attributesNameArray, "");
    if (emptyAttrIndex == -1) {
        MOST_RECENT_ERROR = "No attribute slot remaining for ["+structName+"]";
        MOST_RECENT_ORIGIN = "defineStructAttribute('"+structName+"', '"+structAttribute+"')";
        return (false);
    }

    int attributesTypeArray = xsArrayGetInt(STRUCT_ATTRIBUTE_TYPES_ARRAY_ARRAY, structIndex);

    xsArraySetString(attributesNameArray, emptyAttrIndex, structAttribute);
    xsArraySetInt(attributesTypeArray, emptyAttrIndex, structType);

    return (true);
}

string getReadableType(int attributeType = -1) {
    switch (attributeType) {
        case TYPE_INT:{          return ("int"); }
        case TYPE_BOOL: {        return ("bool"); }
        case TYPE_FLOAT: {       return ("float"); }
        case TYPE_STRING: {      return ("string"); }
        case TYPE_VECTOR: {      return ("vector"); }
        case TYPE_STRUCT: {      return ("struct"); }
    }

    if (attributeType >= 100) {
        int arrType = (attributeType % 100);

        string type = "";
        switch (arrType) {
            case TYPE_INT: {    type = "int"; }
            case TYPE_BOOL: {   type = "bool"; }
            case TYPE_FLOAT: {  type = "flt"; }
            case TYPE_STRING: { type = "str"; }
            case TYPE_VECTOR: { type = "vec"; }
            case TYPE_STRUCT: { type = "strct"; }
        }

        while (attributeType >= 100) {
            type = type + "[]";
            attributeType = attributeType - 100;
        }

        return (type);
    }

    return ("");
}

string getInstanceReferenceAsString(vector v = cInvalidVector) {
    return ("ref[" + xsVectorGetX(v) + ", " + xsVectorGetY(v) + "]");
}

int createTypeArray(int attributeType = -1, string arrayName = "") {
    string type = getReadableType(attributeType);

    switch (attributeType) {
        case TYPE_INT: {
            return (xsArrayCreateInt(1, 0, "array"+type+arrayName));
        }
        case TYPE_BOOL: {
            return (xsArrayCreateBool(1, false, "array"+type+arrayName));
        }
        case TYPE_FLOAT: {
            return (xsArrayCreateFloat(1, 0.0, "array"+type+arrayName));
        }
        case TYPE_STRING: {
            return (xsArrayCreateString(1, "", "array"+type+arrayName));
        }
        case TYPE_VECTOR: {
            return (xsArrayCreateVector(1, vector(0, 0, 0), "array"+type+arrayName));
        }
        case TYPE_STRUCT: {
            // Same as vector
            return (xsArrayCreateVector(1, cInvalidVector, "array"+type+arrayName));
        }
    }

    if (attributeType >= 100) {
        // Array types: Same as int
        return (xsArrayCreateInt(1, -1, "array"+type+arrayName));
    }

    return (-1);
}

int getStructAttributeCount(int structIndex = -1) {
    int attributesNameArray = xsArrayGetInt(STRUCT_ATTRIBUTE_NAMES_ARRAY_ARRAY, structIndex);

    for(i = 0; < xsArrayGetSize(attributesNameArray)) {
        if (xsArrayGetString(attributesNameArray, i) == "") {
            return (i);
        }
    }

    return (xsArrayGetSize(attributesNameArray));
}

void printStructDefinition(string structName = "") {
    clearPrintBuffer();

    int structIndex = findStructIndex(structName);

    if (structIndex == -1) {
        xsChatData("Unable to find struct for name ["+structName+"]");
        return;
    }

    int attributeCount = getStructAttributeCount(structIndex);

    bufferLine(structName + ":");
    if (attributeCount == 0) {
        bufferLine("  < No attributes >");
        return;
    }

    int attributesNameArray = xsArrayGetInt(STRUCT_ATTRIBUTE_NAMES_ARRAY_ARRAY, structIndex);
    int attributesTypeArray = xsArrayGetInt(STRUCT_ATTRIBUTE_TYPES_ARRAY_ARRAY, structIndex);

    for(i = 0; < attributeCount) {
        string attribute = xsArrayGetString(attributesNameArray, i);
        string type = getReadableType(xsArrayGetInt(attributesTypeArray, i));

        bufferLine("  - "+attribute+": " + type);
    }

    printBuffer();
}

// This function exists so I don't have to repeat xsc-ignore :)
int toStructIndex(vector instance = cInvalidVector) {
    // xsc-ignore: NumDownCast
    int structIndex = xsVectorGetX(instance);

    return (structIndex);
}

// This function exists so I don't have to repeat xsc-ignore :)
int toInstanceIndex(vector instance = cInvalidVector) {
    // xsc-ignore: NumDownCast
    int instanceIndex = xsVectorGetY(instance);

    return (instanceIndex);
}

bool isValidInstance(vector instance = cInvalidVector) {
    int structIndex = toStructIndex(instance);
    int instanceIndex = toInstanceIndex(instance);

    string instanceRepr = "";

    if (structIndex < 0 || structIndex >= MAX_STRUCT_COUNT || instanceIndex < 0 || instanceIndex >= MAX_INSTANCE_PER_STRUCT) {
        instanceRepr = getInstanceReferenceAsString(instance);
        MOST_RECENT_ERROR = "INVALID INSTANCE REFERENCE ["+instanceRepr+"]";
        MOST_RECENT_ORIGIN = "validateInstance("+instanceRepr+")";
        return (false);
    }

    int instancesArray = xsArrayGetInt(STRUCT_INSTANCE_ARRAY_ARRAY, structIndex);
    int instanceRef = xsArrayGetInt(instancesArray, instanceIndex);
    if (instanceRef == -1) {
        instanceRepr = getInstanceReferenceAsString(instance);
        MOST_RECENT_ERROR = "INSTANCE REFERENCE TO EMPTY SLOT ["+instanceRepr+"]";
        MOST_RECENT_ORIGIN = "validateInstance("+instanceRepr+")";
        return (false);
    }

    return (true);
}

void printRecentError() {
    clearPrintBuffer();

    if (MOST_RECENT_ERROR == "") {
        bufferLine("No errors :)");
    } else {
        string error = "Error: " + MOST_RECENT_ERROR;
        if (MOST_RECENT_ORIGIN != "") {
            error = error + " - Occurred at: " + MOST_RECENT_ORIGIN;
        }
        bufferLine(error);
    }

    printBuffer();
}

mutable void printStructInstance(vector instance = cInvalidVector, string prefix = "") {
    // Overwritten later - Exists so this function and `printFromXsArray` can call each other recursively
    // XS needs functions to exist before the one you call them in.
}

mutable bool printFromXsArray(int valueRefArray = -1, int attributeType = -1, string prefix = "", int getIndex = 0) {
    if (valueRefArray == -1) {
        MOST_RECENT_ERROR = "INVALID VALUE REF ARRAY";
        return (false);
    }

    string str = "";
    switch (attributeType) {
        case TYPE_INT:    { str = "" + xsArrayGetInt(valueRefArray, getIndex); }
        case TYPE_BOOL:   {
            if (xsArrayGetBool(valueRefArray, getIndex)) {
                str = "true";
            } else {
                str = "false";
            }
        }
        case TYPE_FLOAT:  { str = "" + xsArrayGetFloat(valueRefArray, getIndex); }
        case TYPE_STRING: { str = "'" + xsArrayGetString(valueRefArray, getIndex) + "'"; }
        case TYPE_VECTOR: { str = "" + xsArrayGetVector(valueRefArray, getIndex); }
        case TYPE_STRUCT: {
            vector struct = xsArrayGetVector(valueRefArray, getIndex);
            if (isValidInstance(struct) == false) {
                return (true);
            }

            printStructInstance(struct, prefix + "    ");
            return (true);
        }
    }

    // Handle all array types (except struct, see above)
    if (attributeType >= 100) {
        int arr = xsArrayGetInt(valueRefArray, getIndex);

        int arrSize = xsArrayGetSize(arr);
        if (arrSize > 0) {
            bufferLine("[");
        } else {
            buffer("[");
        }

        for(i = 0; < arrSize) {
            buffer(prefix + "   " + i + ": ");
            printFromXsArray(arr, attributeType - 100, prefix + "  ", i);
            bufferLine();
        }
        bufferLine(prefix + "]");

        return (true);
    }

    buffer(str);

    return (true);
}

mutable void printStructInstance(vector instance = cInvalidVector, string prefix = "") {
    if (prefix == "") {
        // Prefix only used nested, and buffer shouldn't be cleared
        clearPrintBuffer();
    }

    int structIndex = toStructIndex(instance);
    int instanceIndex = toInstanceIndex(instance);

    string structName = xsArrayGetString(STRUCT_NAME_ARRAY, structIndex);

    int instancesArray = xsArrayGetInt(STRUCT_INSTANCE_ARRAY_ARRAY, structIndex);
    int instanceRef = xsArrayGetInt(instancesArray, instanceIndex);

    int attributeCount = getStructAttributeCount(structIndex);

    int attributesNameArray = xsArrayGetInt(STRUCT_ATTRIBUTE_NAMES_ARRAY_ARRAY, structIndex);
    int attributesTypeArray = xsArrayGetInt(STRUCT_ATTRIBUTE_TYPES_ARRAY_ARRAY, structIndex);

    bufferLine(structName + "():");

    for(i = 0; < attributeCount) {
        string attribute = xsArrayGetString(attributesNameArray, i);
        int attributeType = xsArrayGetInt(attributesTypeArray, i);

        int valueRefArray = xsArrayGetInt(instanceRef, i);

        buffer(prefix + "  - " + attribute + ": ");
        printFromXsArray(valueRefArray, attributeType, prefix + "  ");
        bufferLine();
    }

    if (attributeCount == 0) {
        bufferLine(prefix + "  < No attributes >");
    }

    if (prefix == "") {
        // Prefix only used nested, and buffer shouldn't be printed
        printBuffer();
    }
}

mutable vector new(string structName = "") {
    int structIndex = findStructIndex(structName);
    if (structIndex == -1) {
        MOST_RECENT_ERROR = "INVALID STRUCT NAME ["+structName+"]";
        MOST_RECENT_ORIGIN = "new('"+structName+"')";
        return (cInvalidVector);
    }

    int attributeCount = getStructAttributeCount(structIndex);

    int structTypesArray = xsArrayGetInt(STRUCT_ATTRIBUTE_TYPES_ARRAY_ARRAY, structIndex);

    int instancesArray = xsArrayGetInt(STRUCT_INSTANCE_ARRAY_ARRAY, structIndex);
    int emptyInstanceIndex = findIndexInt(instancesArray, -1);
    if (emptyInstanceIndex == -1) {
        MOST_RECENT_ERROR = "No instance slot remaining for ["+structName+"]";
        MOST_RECENT_ORIGIN = "new('"+structName+"')";
        return (cInvalidVector);
    }

    // Create values array
    int attributeValuesArray = xsArrayCreateInt(attributeCount, -1, "InstanceValues:"+structName+"+"+emptyInstanceIndex);
    xsArraySetInt(instancesArray, emptyInstanceIndex, attributeValuesArray);

    int attributeType = -1;
    int arr = -1;
    for(i = 0; < attributeCount) {
        attributeType = xsArrayGetInt(structTypesArray, i);
        arr = createTypeArray(attributeType, "InstanceValue:"+structName+"+"+emptyInstanceIndex+"+"+i);

        xsArraySetInt(attributeValuesArray, i, arr);
    }

    float structIndexF = structIndex;
    float instanceIndexF = emptyInstanceIndex;

    vector v = cInvalidVector;
    v = xsVectorSetX(v, structIndexF);
    v = xsVectorSetY(v, instanceIndexF);

    return (v);
}

bool deleteInstance(vector instance = cInvalidVector) {
    bool isValid = isValidInstance(instance);
    if (isValid == false) {
        MOST_RECENT_ORIGIN = "deleteInstance("+getInstanceReferenceAsString(instance)+")";
        return (false);
    }

    int structIndex = toStructIndex(instance);
    int instanceIndex = toInstanceIndex(instance);

    int instancesArray = xsArrayGetInt(STRUCT_INSTANCE_ARRAY_ARRAY, structIndex);
    xsArraySetInt(instancesArray, instanceIndex, -1);

    return (true);
}

bool isInstance(vector instance = cInvalidVector, string structType = "") {
    if (structType == "") {
        MOST_RECENT_ORIGIN = "isInstance("+getInstanceReferenceAsString(instance)+", '"+structType+"')";
        MOST_RECENT_ERROR = "Empty structType ["+structType+"]";
        return (false);
    }

    if (isValidInstance(instance) == false) {
        MOST_RECENT_ORIGIN = "isInstance("+getInstanceReferenceAsString(instance)+", '"+structType+"')";
        return (false);
    }

    int expectedStructIndex = findStructIndex(structType);
    int structIndex = toStructIndex(instance);

    if (expectedStructIndex == -1 || structIndex == -1) {
        return (false);
    }

    return (expectedStructIndex == structIndex);
}

string getStructName(vector instance = cInvalidVector) {
    if (isValidInstance(instance) == false) {
        MOST_RECENT_ORIGIN = "getStructName("+getInstanceReferenceAsString(instance)+")";
        return ("");
    }

    int structIndex = toStructIndex(instance);
    return (xsArrayGetString(STRUCT_NAME_ARRAY, structIndex));
}

bool validateInstanceAttribute(vector instance = cInvalidVector, string attrName = "", int attributeTypeMatch = -1) {
    bool isValid = isValidInstance(instance);
    if (isValid == false) {
        MOST_RECENT_ORIGIN = "validateInstanceAttribute("+getInstanceReferenceAsString(instance)+", '"+attrName+"', <type>)";
        return (false);
    }

    int structIndex = toStructIndex(instance);
    int instanceIndex = toInstanceIndex(instance);

    int structAttributeNamesArray = xsArrayGetInt(STRUCT_ATTRIBUTE_NAMES_ARRAY_ARRAY, structIndex);
    int structAttributeTypesArray = xsArrayGetInt(STRUCT_ATTRIBUTE_TYPES_ARRAY_ARRAY, structIndex);
    int attributeIndex = findIndexString(structAttributeNamesArray, attrName);

    if (attributeIndex == -1) {
        MOST_RECENT_ERROR = "INVALID ATTRIBUTE REFERENCE ["+attrName+"]";
        MOST_RECENT_ORIGIN = "validateInstanceAttribute("+getInstanceReferenceAsString(instance)+", '"+attrName+"', <type>)";
        return (false);
    }

    int attributeType = xsArrayGetInt(structAttributeTypesArray, attributeIndex);
    bool isVectorAlias = attributeType == TYPE_STRUCT && attributeTypeMatch == TYPE_VECTOR;
    bool isArrayAlias = attributeType >= 100 && attributeTypeMatch == TYPE_INT;

    if (attributeType != attributeTypeMatch && isVectorAlias == false && isArrayAlias == false) {
        string typeAsStr = getReadableType(attributeType);
        string expectedTypeAsStr = getReadableType(attributeTypeMatch);

        MOST_RECENT_ERROR = "INVALID ATTRIBUTE TYPE ["+typeAsStr+"] (Type ID: "+attributeType+"); Expected: ["+expectedTypeAsStr+"]";
        MOST_RECENT_ORIGIN = "validateInstanceAttribute("+getInstanceReferenceAsString(instance)+", '"+attrName+"', <type>)";
        return (false);
    }

    xsArraySetInt(STRUCT_VALIDATION_REF_ARRAY, 0, structIndex);
    xsArraySetInt(STRUCT_VALIDATION_REF_ARRAY, 1, instanceIndex);
    xsArraySetInt(STRUCT_VALIDATION_REF_ARRAY, 2, attributeIndex);

    return (true);
}

int getValueArrayRefAfterValidation() {
    int structIndex = xsArrayGetInt(STRUCT_VALIDATION_REF_ARRAY, 0);
    int instanceIndex = xsArrayGetInt(STRUCT_VALIDATION_REF_ARRAY, 1);
    int attributeIndex = xsArrayGetInt(STRUCT_VALIDATION_REF_ARRAY, 2);

    int instancesArray = xsArrayGetInt(STRUCT_INSTANCE_ARRAY_ARRAY, structIndex);
    int instanceRef = xsArrayGetInt(instancesArray, instanceIndex);

    return (xsArrayGetInt(instanceRef, attributeIndex));
}

string structGetString(vector instance = cInvalidVector, string attrName = "") {
    MOST_RECENT_GET_FAILED = false;

    bool success = validateInstanceAttribute(instance, attrName, TYPE_STRING);
    if (success == false) {
        MOST_RECENT_ORIGIN = "structGetString("+getInstanceReferenceAsString(instance)+", '"+attrName+"')";
        MOST_RECENT_GET_FAILED = true;
        return ("");
    }

    return (xsArrayGetString(getValueArrayRefAfterValidation(), 0));
}

bool structSetString(vector instance = cInvalidVector, string attrName = "", string value = "") {
    bool success = validateInstanceAttribute(instance, attrName, TYPE_STRING);
    if (success == false) {
        MOST_RECENT_ORIGIN = "structSetString("+getInstanceReferenceAsString(instance)+", '"+attrName+"', '"+value+"')";
        return (false);
    }

    xsArraySetString(getValueArrayRefAfterValidation(), 0, value);

    return (true);
}

int structGetInt(vector instance = cInvalidVector, string attrName = "") {
    MOST_RECENT_GET_FAILED = false;

    bool success = validateInstanceAttribute(instance, attrName, TYPE_INT);
    if (success == false ){
        MOST_RECENT_ORIGIN = "structGetInt("+getInstanceReferenceAsString(instance)+", '"+attrName+"')";
        MOST_RECENT_GET_FAILED = true;
        return (-1);
    }

    return (xsArrayGetInt(getValueArrayRefAfterValidation(), 0));
}

bool structSetInt(vector instance = cInvalidVector, string attrName = "", int value = -1) {
    bool success = validateInstanceAttribute(instance, attrName, TYPE_INT);
    if (success == false) {
        MOST_RECENT_ORIGIN = "structSetInt("+getInstanceReferenceAsString(instance)+", '"+attrName+"', "+value+")";
        return (false);
    }

    xsArraySetInt(getValueArrayRefAfterValidation(), 0, value);

    return (true);
}

float structGetFloat(vector instance = cInvalidVector, string attrName = "") {
    MOST_RECENT_GET_FAILED = false;

    bool success = validateInstanceAttribute(instance, attrName, TYPE_FLOAT);
    if (success == false) {
        MOST_RECENT_ORIGIN = "structGetFloat("+getInstanceReferenceAsString(instance)+", '"+attrName+"')";
        MOST_RECENT_GET_FAILED = true;
        return (-1.0);
    }

    return (xsArrayGetFloat(getValueArrayRefAfterValidation(), 0));
}

bool structSetFloat(vector instance = cInvalidVector, string attrName = "", float value = -1.0) {
    bool success = validateInstanceAttribute(instance, attrName, TYPE_FLOAT);
    if (success == false) {
        MOST_RECENT_ORIGIN = "structSetFloat("+getInstanceReferenceAsString(instance)+", '"+attrName+"', "+value+")";
        return (false);
    }

    xsArraySetFloat(getValueArrayRefAfterValidation(), 0, value);

    return (true);
}

bool structGetBool(vector instance = cInvalidVector, string attrName = "") {
    MOST_RECENT_GET_FAILED = false;

    bool success = validateInstanceAttribute(instance, attrName, TYPE_BOOL);
    if (success == false) {
        MOST_RECENT_ORIGIN = "structGetBool("+getInstanceReferenceAsString(instance)+", '"+attrName+"')";
        MOST_RECENT_GET_FAILED = true;
        return (false);
    }

    return (xsArrayGetBool(getValueArrayRefAfterValidation(), 0));
}

bool structSetBool(vector instance = cInvalidVector, string attrName = "", bool value = false) {
    bool success = validateInstanceAttribute(instance, attrName, TYPE_BOOL);
    if (success == false) {
        MOST_RECENT_ORIGIN = "structSetBool("+getInstanceReferenceAsString(instance)+", '"+attrName+"', "+value+")";
        return (false);
    }

    xsArraySetBool(getValueArrayRefAfterValidation(), 0, value);

    return (true);
}

vector structGetVector(vector instance = cInvalidVector, string attrName = "") {
    MOST_RECENT_GET_FAILED = false;

    bool success = validateInstanceAttribute(instance, attrName, TYPE_VECTOR);
    if (success == false) {
        MOST_RECENT_ORIGIN = "structGetVector("+getInstanceReferenceAsString(instance)+", '"+attrName+"')";
        MOST_RECENT_GET_FAILED = true;
        return (cInvalidVector);
    }

    return (xsArrayGetVector(getValueArrayRefAfterValidation(), 0));
}

bool structSetVector(vector instance = cInvalidVector, string attrName = "", vector value = cInvalidVector) {
    bool success = validateInstanceAttribute(instance, attrName, TYPE_VECTOR);
    if (success == false) {
        MOST_RECENT_ORIGIN = "structSetVector("+getInstanceReferenceAsString(instance)+", '"+attrName+"', "+value+")";
        return (false);
    }

    xsArraySetVector(getValueArrayRefAfterValidation(), 0, value);

    return (true);
}

mutable void initializeStructsScript() {
    if (STRUCTS_INITIALIZED == true) {
        return;
    }

    MOST_RECENT_ERROR = "";
    MOST_RECENT_ORIGIN = "";
    STRUCT_VALIDATION_REF_ARRAY = xsArrayCreateInt(3, -1, "xs_struct_validation_ref");
    STRUCT_PRINT_BUFFER = xsArrayCreateString(STRUCT_PRINT_BUFFER_SIZE, "", "xs_struct_print_buffer");

    STRUCT_NAME_ARRAY = xsArrayCreateString(MAX_STRUCT_COUNT, "", "xs_struct_names");
    STRUCT_ATTRIBUTE_NAMES_ARRAY_ARRAY = xsArrayCreateInt(MAX_STRUCT_COUNT, -1, "xs_struct_attributes");
    STRUCT_ATTRIBUTE_TYPES_ARRAY_ARRAY = xsArrayCreateInt(MAX_STRUCT_COUNT, -1, "xs_struct_types");
    STRUCT_INSTANCE_ARRAY_ARRAY = xsArrayCreateInt(MAX_STRUCT_COUNT, -1, "xs_struct_instances");

    int array = -1;
    for(i = 0; < MAX_STRUCT_COUNT) {
        array = xsArrayCreateString(MAX_STRUCT_ATTRIBUTES, "", "xs_struct_attribute_name_array_" + i);
        xsArraySetInt(STRUCT_ATTRIBUTE_NAMES_ARRAY_ARRAY, i, array);

        array = xsArrayCreateInt(MAX_STRUCT_ATTRIBUTES, -1, "xs_struct_attribute_type_array_" + i);
        xsArraySetInt(STRUCT_ATTRIBUTE_TYPES_ARRAY_ARRAY, i, array);

        array = xsArrayCreateInt(MAX_INSTANCE_PER_STRUCT, -1, "xs_struct_instance_array_" + i);
        xsArraySetInt(STRUCT_INSTANCE_ARRAY_ARRAY, i, array);
    }

    STRUCTS_INITIALIZED = true;
}

rule initializeStructsRule
    active
    runImmediately
    highFrequency
    priority 999999000
{
    initializeStructsScript();
    xsDisableSelf();
}
