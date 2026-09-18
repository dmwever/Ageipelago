extern const int MERCENARY_PENDING_MAX = 4;

int pendingMercenaries = -1;
int pendingMercenaryCount = 0;

void InitMercenaryLedger() {
    pendingMercenaries = xsArrayCreateInt(MERCENARY_PENDING_MAX, -1, "ap-mercenaries-pending");
    pendingMercenaryCount = 0;
}

bool IsMercenaryPending(int mercenaryId = -1) {
    for (i = 0; < pendingMercenaryCount) {
        if (xsArrayGetInt(pendingMercenaries, i) == mercenaryId) {
            return (true);
        }
    }
    return (false);
}

void MarkMercenaryComplete(int mercenaryId = -1) {
    if (mercenaryId == -1) {
        return;
    }
    if (IsMercenaryPending(mercenaryId)) {
        return;
    }
    if (pendingMercenaryCount >= MERCENARY_PENDING_MAX) {
        xsChatData("<RED>MarkMercenaryComplete: nothing left to hold " + mercenaryId + " in, so it was dropped.");
        return;
    }
    xsArraySetInt(pendingMercenaries, pendingMercenaryCount, mercenaryId);
    pendingMercenaryCount = pendingMercenaryCount + 1;
}

int PendingMercenary() {
    if (pendingMercenaryCount == 0) {
        return (-1);
    }
    return (xsArrayGetInt(pendingMercenaries, 0));
}

void AckMercenary(int mercenaryId = -1) {
    if (mercenaryId == -1) {
        return;
    }
    if (PendingMercenary() != mercenaryId) {
        return;
    }
    int last = pendingMercenaryCount - 1;
    for (i = 0; < last) {
        xsArraySetInt(pendingMercenaries, i, xsArrayGetInt(pendingMercenaries, i + 1));
    }
    xsArraySetInt(pendingMercenaries, last, -1);
    pendingMercenaryCount = last;
}
