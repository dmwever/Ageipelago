"""Generate TechData.xs (and an optional JSON mirror) from the AoE2:DE game files.
"""
import argparse
import glob
import io
import json
import os
import pickle
import struct
import sys
import zlib
from collections import Counter, defaultdict

TECH_SECTION_SEARCH_TAIL = 600_000
RGE_STRING_MARKER = 0x0A60
AGE_UP_TECHS = (101, 102, 103)

# Blank Technology 1180 is the Ageipelago Declare Victory tech (APavilion.xs:1).
VICTORY_TECH = 1180

# Verified by spike: rebinding a tech effect to effect 0 suppresses it.
NOOP_EFFECT = 0

TECH_NONE, TECH_UPGRADE, TECH_UNIQUE, TECH_AGEUP, TECH_NO_EFFECT = 0, 1, 2, 4, 8

CHRONICLES_CIVS = {"ACHAEMENIDS", "ATHENIANS", "SPARTANS"}

# players[1].starting_age of the 12 patched scenarios, measured with the v1.58
# parser. Parser enum is 2=Dark 3=Feudal 4=Castle 5=Imperial; stored here as the
# 0-based age index that the tech table age column uses.
SCENARIO_VANILLA_AGE = {
    101: 0, 102: 2, 103: 2, 104: 2, 105: 2, 106: 3,
    201: 2, 202: 1, 203: 1, 204: 2, 205: 3, 206: 2,
}


def decompress_dat(path):
    raw = open(path, "rb").read()
    data = zlib.decompress(raw, -15)
    if not data.startswith(b"VER "):
        raise SystemExit("%s: unexpected header %r" % (path, data[:8]))
    return data, data[:7].decode("ascii")


def parse_techs(data, start, count):
    """VER 8.9 tech record:

         55 bytes header, then 0x0A60 + uint16 len + name,
         then int8 repeatable, int16 location_count,
         then location_count * 9 bytes {int16 loc, int16 time, int8 button, int32 hotkey}

       Header (55 bytes):
         +0  int16 required_techs[6]
         +12 3 * {int16 type, int16 amount, int8 flag}
         +27 int16 required_tech_count
         +29 int16 civ
         +31 int16 full_tech_mode
         +33 int32 language_dll_name
         +37 int32 language_dll_description
         +41 int16 effect_id
         +43 int16 type
         +45 int16 icon_id
         +47 int32 language_dll_help
         +51 int32 language_dll_tech_tree
    """
    out = []
    o = start
    for i in range(count):
        req = struct.unpack_from("<6h", data, o)
        req_count = struct.unpack_from("<h", data, o + 27)[0]
        civ = struct.unpack_from("<h", data, o + 29)[0]
        effect = struct.unpack_from("<h", data, o + 41)[0]
        p = o + 55
        assert struct.unpack_from("<H", data, p)[0] == RGE_STRING_MARKER
        ln = struct.unpack_from("<H", data, p + 2)[0]
        name = data[p + 4:p + 4 + ln].decode("utf-8", "replace")
        p += 4 + ln
        p += 1                                          # repeatable
        loc_count = struct.unpack_from("<h", data, p)[0]
        p += 2
        locs = []
        for _ in range(loc_count):
            loc, time = struct.unpack_from("<hh", data, p)
            locs.append((loc, time, data[p + 4]))
            p += 9
        out.append(dict(id=i, name=name, civ=civ, effect=effect,
                        req=[r for r in req[:max(0, req_count)] if r >= 0],
                        locs=locs))
        o = p
    return out


def find_tech_section(data):
    limit = max(0, len(data) - TECH_SECTION_SEARCH_TAIL)
    for off in range(len(data) - 4, limit, -1):
        count = struct.unpack_from("<H", data, off)[0]
        if not 1000 <= count <= 4000:
            continue
        try:
            techs = parse_techs(data, off + 2, count)
        except (AssertionError, struct.error, IndexError, UnicodeDecodeError):
            continue
        return off, count, techs
    raise SystemExit("could not locate the tech section")


def read_civ_trees(directory):
    research, upgrade, have, civs = {}, {}, defaultdict(set), []
    files = sorted(glob.glob(os.path.join(directory, "*.json")))
    if not files:
        raise SystemExit("no CivTechTrees JSON found in %s" % directory)
    for path in files:
        civ = os.path.splitext(os.path.basename(path))[0]
        civs.append(civ)
        tree = json.load(io.open(path, encoding="utf-8-sig"))
        for node in tree["civ_techs_buildings"] + tree["civ_techs_units"]:
            pairs = []
            if node.get("Node Type") == "Research":
                pairs.append((node["Node ID"], research))
            if "Trigger Tech ID" in node:
                pairs.append((node["Trigger Tech ID"], upgrade))
            for tech_id, table in pairs:
                if tech_id is None or tech_id < 0:
                    continue
                table.setdefault(tech_id, (node["Name"], node["Age ID"] - 1))
                if node["Node Status"] != "NotAvailable":
                    have[tech_id].add(civ)

    info = {}
    for tech_id in set(research) | set(upgrade):
        name, age = research.get(tech_id) or upgrade[tech_id]
        info[tech_id] = dict(name=name, age=age, upgrade=tech_id in upgrade)
    return info, have, civs


def build_table(techs, info, have):
    rows, skipped = [], []
    for tech_id in sorted(info):
        owners = have[tech_id]
        name = info[tech_id]["name"]
        if not owners:
            skipped.append((tech_id, name, "no civ can research it"))
            continue
        if tech_id in AGE_UP_TECHS:
            skipped.append((tech_id, name, "age-up tech"))
            continue
        if tech_id >= len(techs):
            skipped.append((tech_id, name, "tech id beyond the .dat"))
            continue
        rec = techs[tech_id]
        if not any(l[0] > 0 for l in rec["locs"]):
            skipped.append((tech_id, name, "no research location"))
            continue
        flags = TECH_NONE
        if info[tech_id]["upgrade"]:
            flags |= TECH_UPGRADE
        if rec["civ"] >= 0:
            flags |= TECH_UNIQUE
        if rec["effect"] < 0:
            flags |= TECH_NO_EFFECT
        rows.append(dict(tech_id=tech_id,
                         effect_id=rec["effect"],
                         civ=rec["civ"],
                         flags=flags,
                         age=info[tech_id]["age"],
                         name=name,
                         dat_name=rec["name"],
                         required=rec["req"],
                         civ_count=len(owners),
                         chronicles_only=not (owners - CHRONICLES_CIVS)))
    return rows, skipped


def find_shadows(techs):
    out = []
    for t in techs:
        if not t["name"].strip().lower().startswith("blank technology"):
            continue
        if any(l[0] > 0 for l in t["locs"]):
            continue
        if t["id"] == VICTORY_TECH:
            continue
        out.append(t["id"])
    return out


def flag_expr(flags):
    if flags == 0:
        return "TECH_NONE"
    parts = []
    if flags & TECH_UPGRADE:
        parts.append("TECH_UPGRADE")
    if flags & TECH_UNIQUE:
        parts.append("TECH_UNIQUE")
    if flags & TECH_NO_EFFECT:
        parts.append("TECH_NO_EFFECT")
    return " + ".join(parts)


def render_xs(rows, shadows, dat_version, dat_name):
    ages = ("Dark", "Feudal", "Castle", "Imperial")
    width = max(len(flag_expr(r["flags"])) for r in rows)
    out = []
    out.append("/* GENERATED by Scripts/extract_techdata.py -- do not edit by hand.")
    out.append(" * source: %s (%s) + CivTechTrees" % (dat_name, dat_version))
    out.append(" * %d techs, %d shadow slots" % (len(rows), len(shadows)))
    out.append(" */")
    out.append("")
    out.append("const int TECH_COUNT = %d;" % len(rows))
    out.append("const int SHADOW_COUNT = %d;" % len(shadows))
    out.append("const int TECH_NOOP_EFFECT = %d;" % NOOP_EFFECT)
    out.append("")
    out.append("void LoadTechTable() {")
    for r in rows:
        out.append("    addTech(%5d, %5d, %3d, %s, %d);   // %-8s %s"
                   % (r["tech_id"], r["effect_id"], r["civ"],
                      flag_expr(r["flags"]).ljust(width), r["age"],
                      ages[r["age"]], r["name"]))
    out.append("}")
    out.append("")
    out.append("void LoadShadows() {")
    for sid in shadows:
        out.append("    addShadow(%d);" % sid)
    out.append("}")
    out.append("")
    out.append("int vanillaAgeFor(int scenarioId = -1) {")
    out.append("    switch(scenarioId) {")
    for scenario_id, age in sorted(SCENARIO_VANILLA_AGE.items()):
        out.append("        case %d: { return (%d); }" % (scenario_id, age))
    out.append("    }")
    out.append("    return (0);")
    out.append("}")
    out.append("")
    return "\n".join(out)


def audit(rows, skipped, techs, reference):
    print("  techs emitted:          %d" % len(rows))
    print("  skipped from the tree:  %d" % len(skipped))
    print("    upgrades:             %d" % sum(1 for r in rows if r["flags"] & TECH_UPGRADE))
    print("    unique (civ >= 0):    %d" % sum(1 for r in rows if r["flags"] & TECH_UNIQUE))
    print("    chronicles-only:      %d" % sum(1 for r in rows if r["chronicles_only"]))
    print("    by age:               %s" % dict(sorted(Counter(r["age"] for r in rows).items())))
    bad = [r for r in rows if r["effect_id"] < 0]
    print("    TECH_NO_EFFECT:       %d %s"
          % (len(bad), [(r["tech_id"], r["name"]) for r in bad]))
    unshadowable = [r for r in bad if not r["flags"] & TECH_UPGRADE]
    print("      of which NOT unit upgrades (would be a real gap): %d %s"
          % (len(unshadowable), [r["tech_id"] for r in unshadowable]))

    ids = set(r["tech_id"] for r in rows)
    dat_loc = set(t["id"] for t in techs
                  if any(l[0] > 0 for l in t["locs"]) and t["id"] not in AGE_UP_TECHS)
    legacy = sorted(dat_loc - ids)
    print("  .dat has a research location but no civ exposes it: %d" % len(legacy))
    print("    e.g. %s" % [(i, techs[i]["name"][:22]) for i in legacy[:6]])

    if reference and os.path.isfile(reference):
        import re
        ref = {}
        for line in io.open(reference, encoding="utf-8", errors="replace"):
            m = re.match(r"\s*const int (ri_\w+)\s*=\s*(-?\d+);", line)
            if m:
                ref[m.group(1)] = int(m.group(2))
        ref_ids = set(v for v in ref.values() if v >= 0)
        print("  reference table: %d names, %d distinct ids" % (len(ref), len(ref_ids)))
        print("    placeholders (-1):       %s" % sorted(n for n, v in ref.items() if v < 0))
        for value, seen in Counter(ref.values()).items():
            if seen > 1 and value >= 0:
                print("    id %d used twice:        %s"
                      % (value, sorted(n for n, v in ref.items() if v == value)))
        missing = sorted(ref_ids - ids)
        print("    reference ids NOT emitted: %d %s" % (len(missing), missing[:14]))
        print("    emitted but not in ref:    %d" % len(ids - ref_ids))


def main(argv=None):
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--dat", default=os.environ.get("AOE2_DAT"),
                    help="path to empires2_x2_p1.dat (or set AOE2_DAT)")
    ap.add_argument("--civtrees", default=None,
                    help="CivTechTrees directory (default: <dat dir>/CivTechTrees)")
    ap.add_argument("--out", default=None, help="write TechData.xs here")
    ap.add_argument("--json", dest="json_out", default=None,
                    help="also write a machine-readable table for the APWorld")
    ap.add_argument("--reference", default=None,
                    help="hand table to audit against (a copy of the old Techsanity.xs)")
    ap.add_argument("--cache", default=None, help="cache the parsed .dat records here")
    args = ap.parse_args(argv)

    if not args.dat:
        ap.error("no .dat given: pass --dat or set AOE2_DAT")
    if not os.path.isfile(args.dat):
        ap.error("not a file: %s" % args.dat)
    civtrees = args.civtrees or os.path.join(os.path.dirname(args.dat), "CivTechTrees")

    if args.cache and os.path.isfile(args.cache):
        techs, version = pickle.load(open(args.cache, "rb"))
        print("cached .dat records: %d (%s)" % (len(techs), version))
    else:
        print("reading %s" % args.dat)
        data, version = decompress_dat(args.dat)
        off, count, techs = find_tech_section(data)
        print("  %s, %d bytes decompressed; %d tech records at offset %d"
              % (version, len(data), count, off + 2))
        if args.cache:
            pickle.dump((techs, version), open(args.cache, "wb"))

    info, have, civs = read_civ_trees(civtrees)
    print("read %d civ tech trees; %d distinct tech ids referenced" % (len(civs), len(info)))

    rows, skipped = build_table(techs, info, have)
    shadows = find_shadows(techs)
    print("audit:")
    audit(rows, skipped, techs, args.reference)

    text = render_xs(rows, shadows, version, os.path.basename(args.dat))
    if args.out:
        io.open(args.out, "w", encoding="utf-8", newline="\n").write(text)
        print("wrote %s (%d lines)" % (args.out, len(text.splitlines())))
    else:
        print(text[:1200])

    if args.json_out:
        votes = defaultdict(Counter)
        for r in rows:
            if r["civ"] >= 0 and r["civ_count"] == 1:
                votes[r["civ"]][next(iter(have[r["tech_id"]]))] += 1
        payload = dict(dat_version=version,
                       tech_count=len(rows),
                       shadows=shadows,
                       noop_effect=NOOP_EFFECT,
                       civ_ids=dict((c, v.most_common(1)[0][0]) for c, v in votes.items()),
                       techs=rows)
        io.open(args.json_out, "w", encoding="utf-8", newline="\n").write(
            json.dumps(payload, indent=1))
        print("wrote %s (%d civ ids resolved)" % (args.json_out, len(payload["civ_ids"])))
    return 0


if __name__ == "__main__":
    sys.exit(main())
