"""Constants that have to agree across files, with nothing else enforcing it.

Every one of these has already gone wrong or is one edit away from it, and none of them fails
loudly in game: a mismatched coordinate puts the pavilion, and the spawn and muster points
derived from it, somewhere they were not meant to go, and a Script Call with arguments is
accepted and silently does nothing.

    py -3 Scripts\\check_drift.py

Exits non-zero on the first disagreement, so it can gate a build.
"""

import json
import os
import re
import sys

AGEIPELAGO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
XS = os.path.join(AGEIPELAGO, "age 2 files", "resources", "_common", "xs")
LOCATIONS = os.path.join(AGEIPELAGO, "Data", "VictoryPavilionLocations.json")

problems = []


def check_pavilion_placement() -> None:
    """Each scenario's SetPavilionLayout() against the JSON.

    The pavilion's own coordinate was never checked before, only the spawn and muster points
    derived from it -- which is how AP_Joan_2 came to sit a tile away from what the JSON said
    without anything noticing.
    """
    facing_for = {"SE": "PAVILION_FACE_SE", "NW": "PAVILION_FACE_NW",
                  "NE": "PAVILION_FACE_NE", "SW": "PAVILION_FACE_SW"}
    locations = json.load(open(LOCATIONS, encoding="utf-8"))
    for scenario, location in locations.items():
        path = os.path.join(XS, scenario + ".xs")
        if not os.path.isfile(path):
            problems.append(f"{scenario}.xs is missing, so its pavilion cannot be checked")
            continue
        source = open(path, encoding="utf-8").read()
        match = re.search(r"SetPavilionPlacement\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\w+)\s*\)", source)
        if not match:
            problems.append(f"{scenario}.xs has no SetPavilionLayout() override, so it would "
                            "create no pavilion, no victory button and no mercenary seats")
            continue
        found = (int(match.group(1)), int(match.group(2)), match.group(3))
        expected = (location["x"], location["y"], facing_for[location["direction"]])
        if found != expected:
            problems.append(
                f"{scenario}: SetPavilionPlacement says {found} but "
                f"VictoryPavilionLocations.json says {expected}.")


def check_script_calls_take_no_arguments() -> None:
    """A Script Call effect cannot pass arguments; the engine accepts it and does nothing.

    The scenarios are authored from these sources, so catching it here is the only place it is
    visible -- in game the symptom is a feature that quietly never runs.
    """
    for name in sorted(os.listdir(os.path.dirname(os.path.abspath(__file__)))):
        if not name.endswith(".py") or name == os.path.basename(__file__):
            continue
        source = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), name),
                      encoding="utf-8").read()
        for call in re.findall(r'script_call\(\s*(?:message\s*=\s*)?[\'"]([^\'"]+)[\'"]', source):
            inside = call[call.find("(") + 1:call.rfind(")")] if "(" in call else ""
            if inside.strip():
                problems.append(
                    f"{name}: script_call({call!r}) passes arguments. AoE2:DE accepts that and "
                    "silently does nothing -- give the scenario's .xs a no-argument wrapper and "
                    "call that instead.")


check_pavilion_placement()
check_script_calls_take_no_arguments()

if problems:
    for problem in problems:
        print("  " + problem)
    raise SystemExit(f"\n{len(problems)} disagreement(s).")

print("pavilion placement and script calls all agree.")
