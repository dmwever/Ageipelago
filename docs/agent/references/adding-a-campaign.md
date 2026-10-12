# Adding a campaign

What a new vanilla campaign needs on both sides, in the order the dependencies allow. Attila the Hun
and Joan of Arc are complete and are the worked examples; Genghis Khan is partial and is not a
reference for anything not listed as done.

A campaign is finished when every chapter has: enums, resource counts, locations, items, an XS entry
point, triggers in the scenario binary calling those locations, logic, rules, and the bindings for
both. Missing any one of them fails somewhere that is not a compile error.

**Three things are the user's to decide, not the agent's.** They are marked
**[ask]** throughout and collected under *What needs user guidance*.

---

## Order of work

1. Scenario enums and ids — nothing else can reference the chapters until these exist.
2. Resource scans — independent of everything else, and the slowest to verify.
3. Locations and items — ids are a permanent contract with the XS and the client.
4. XS entry point and the item/mercenary dispatch.
5. Triggers in the scenario binaries.
6. Logic, rules, and their bindings.
7. Test edits.

Steps 3 and 5 land together for branching locations: `test_branching_install.py` asserts every
branching location has exactly one trigger in the scenario, so declaring one without authoring its
trigger leaves the suite red with no intermediate green state.

---

## Python

### Enums

| File | Entry |
|---|---|
| `locations/Campaigns.py` | `<NAME> = <n>, "<Display Name>", "AP <Display Name>"` |
| `locations/Scenarios.py` | one member per chapter; the id derives as `campaign.value * 100 + chapter`, so both stay in 1-99 |
| `locations/Civilizations.py` | the campaign's civ, if not already present; `game_id` must match the `(Civ)` techs already in `Age2TechData` |
| `locations/Locations.py` | at minimum one `VICTORY` location per chapter, id `scenario.id * 100` |

`Age2ScenarioData` members carry `file_stem`, `xsdat_write_name`, `civ` and `vanilla_age`.
`vanilla_age` is read off the re-saved scenario's `StartingAge` (2/3/4/5 → Dark/Feudal/Castle/Imperial).

A `VICTORY` location per chapter is not optional. `add_scenario_region` only creates the
`"Complete <scenario>"` event and the `"<scenario>: Unlock Next Scenario"` item for scenarios that
appear in `VICTORY_SCENARIO_LOCATIONS`, which is built purely from `VICTORY`-typed locations. Without
one the campaign does not chain.

### Locations

`Age2ScenarioLocationData.__init__` takes
`(id, location_name, scenario, type, trigger_call='', vanilla_item='')`.

| Type | In the pool when | Carries `trigger_call` |
|---|---|---|
| `VICTORY` | always | no |
| `OBJECTIVE`, `SIDE_QUEST` | always | no |
| `OBJECTIVE_BRANCHING_ANY` | `scenario_branching` is `any` (the default) | **yes** |
| `OBJECTIVE_BRANCHING_ALL` | `scenario_branching` is `all` | **yes** |

`trigger_call` is the XS wrapper name, and belongs **only** on branching rows.
`test_only_branching_locations_name_one` asserts every other location holds `""`. The field exists so
`InstallHandler.branching_triggers` can disable the unused half per seed; non-branching triggers are
never disabled, so they need no handle. Non-branching locations still have XS wrappers — the wrapper
name simply is not recorded in Python.

The two branching modes are disjoint: `any` pools only `_ANY` rows, `all` pools only `_ALL` rows.
Mutually exclusive outcomes are a normal `_ALL` case — `ScenarioBranching`'s docstring states `all`
may require playing a scenario more than once.

Alignment: `=` one space after the member name, then pad so the id starts at the column the
surrounding block uses (36 in the Joan and Genghis blocks, 40 in Attila), and the scenario reference
at column 88.

### Items

Bands are duplicated by hand between `items/Items.py` and the header comment in `ItemHandler.xs`.
Change both.

| Band | Payload | Reaches the game via |
|---|---|---|
| 1000-2999 | `ScenarioItem` | `GiveProgressionItem` in `ProgressionItems.xs` |
| 3000-3499 | `ProgressiveScenario` (`chapters - 1`, asserted) | client only |
| 3500-3599 | `Campaign` (exactly one per campaign, asserted) | client only |
| 4000-4999 | `Mercenary` | `GiveMercenary` in `MercenaryItems.xs` |

`Mercenary(vanilla_scenario, [MercenaryUnit(unit, count), ...], icon_id=, name_string_id=, in_logic=)`.

- **Icon ids must be contiguous from 313** across all mercenaries sorted by id. The game loads tech
  icons as a dense array; a gap renders every icon above it blank.
- **Name string ids** start at 990001 and must be unique.
- Both must be below 2**24 — they reach XS through `xsEffectAmount`, which takes a float.
- Every mercenary needs at least one unit; a seat's research time is its unit count.
- Icons and strings are supplied by the mod in this repo. Nothing validates them at runtime.
- `in_logic` is a hand-maintained mirror of rule authorship. `test_mercenaries.py` walks the AST of
  `rules/` and `logic/` and asserts the declared set equals the referenced set.

Mercenary payloads list the units the scenario **transfers**, which is read from the join trigger's
`change_ownership` area, not from what is standing in the camp. Area-based `change_ownership` takes
only units; buildings and eye-candy stay put.

### Resource counts

`locations/connections/ScenarioResources.py` needs every scenario bound in every `Tier`, or the
module-level assert fails collection. See *Scenario resource scans* in `apworld.md` for the amounts
table, counting conventions, terrain reading and the tiering method. Tier assignment is **[ask]**.

Fixed-force scenarios declare all zeroes and join `FIXED_FORCE` in `test_scenario_resources.py`.

### Import-time asserts

Each fails collection rather than one test:

- `ScenarioStartupUnits.py` — an entry per scenario in `SCENARIO_TO_STARTUP_UNITS`; empty list is fine
- `ScenarioTriggerUnits.py` — an entry per scenario in `AUTHORED_TRIGGER_UNITS`; same
- `ScenarioResources.py` — every scenario in every tier

### Logic and rules

`logic/<campaign>/<campaign>_<n>.py` defines a `<Campaign><N>StartingState`;
`rules/<campaign>_rules/<campaign>_<n>.py` defines `<Campaign><N>Rules`. Rules are *defined* in
`logic/` and *attached* in `rules/`; nothing in `logic/` calls `set_rule`.

Every `ScenarioStartingState` field has a default. The minimum sets `self.logic` and
`self.is_unlocked`. Chapter 1 gates on the campaign-unlock item; chapters 2+ gate on the previous
chapter's `"<scenario>: Unlock Next Scenario"` plus `Has("Progressive <Campaign> Scenario", n)`.

Rules subclasses call `super().set_rules()` **and** set a rule on the `VICTORY` location and on
`"Complete <scenario name>"`. The base class does neither; all existing subclasses hand-set both.
Skipping it still generates and silently unlocks the next chapter for free.

Bind every chapter in both `locations/connections/ScenarioDataLogic.py` and `ScenarioDataRules.py`.
An unbound scenario leaves `.rules` as `None` and generation dies with
`TypeError: 'NoneType' object is not callable`.

### Tests that need editing

- `test_economy_rules.py` — `EconomyTestBase.campaigns`. Six tests iterate all of `Age2ScenarioData`
  and call `for_scenario`, which is a bare dict lookup over *enabled* scenarios only.
- `test_mercenaries.py` — `TestMercenariesTheSeedNeeds.campaigns`, once the campaign has mercenaries.
  `needs_mercenary` ignores whether the mercenary's scenario is in the seed, so a mercenary belonging
  to a campaign outside the seed is claimed as needed and can never be referenced.
- `test_scenario_resources.py` — `FIXED_FORCE`, and the hardcoded relic map.
- `test_tech_data.py` — `test_units_and_find_items_matches_the_measured_shape` hardcodes two counts
  derived from `SEED_CIVS`; a new civ shifts both.
- `Options.py` — the `EnabledCampaigns` and `StartingCampaigns` docstrings list campaign names by
  hand. `valid_keys` and `default` are derived and need no edit.

Base classes default to `campaigns = ["Attila the Hun", "Joan of Arc"]` in `test/bases.py`; thirteen
classes override it.

---

## XS

### The per-scenario entry point

One `AP_<Campaign>_<n>.xs` per chapter, in `age 2 files/resources/_common/xs/`.

```c
include "./AP.xs";

void CavemanExemption() {
}

void InitScenarioLocations() {
  // Scenario-Specific - Not defeatsanity/relics
  AddLocations(<first id>, <last id>);
}

void GiveScenarioItems() {
  ReadScenarioItemFile("<XSDAT STEM>");
}

void SetScenarioAge() {
  SetVanillaAge(<AGE>_AGE);
}

void main() {
  SetScenarioId(<campaign * 100 + chapter>);
  InitAP();
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(<first id>);
}

void <WrapperName>() {
  AP_Check_Location(<id>);
}

void SetPavilionLayout() {
    SetPavilionPlacement(<x>, <y>, PAVILION_FACE_<NE|NW|SE|SW>);
}
```

- `AddLocations` is inclusive at both ends and spans the **whole** id range regardless of branching
  mode; the apworld decides which are pooled.
- `ReadScenarioItemFile` takes the stem of `xsdat_write_name` — `"GEN1"` for `GEN1.xsdat`.
- `Victory()` is the fixed wrapper name for the `VICTORY` location and is not recorded in Python.
- `SetScenarioAge` may also call `SetMaxAge`. Neither fixed-force chapter does.
- `CavemanExemption()` is empty in all twelve shipped entry points.
- Wrappers appear in ascending id order.
- Pavilion facing constants: `PAVILION_FACE_SE = 0` (+y), `NW = 1` (-y), `NE = 2` (+x), `SW = 3` (-x).
  Spawn and muster derive two and six tiles out along the facing, so both must be clear ground.

### Item and mercenary flags

Scenario items and mercenaries have the same XS shape — a backing bool, a setter, and a reader:

```c
// <Campaign> <n>
bool <campaign><n><Noun> = false;
void <Campaign><N><Noun>() {
    <campaign><n><Noun> = true;
}

bool Has<Campaign><N><Noun>() {
    return (<campaign><n><Noun>);
}
```

Scenario items live in `ProgressionItems.xs` with a case in `GiveProgressionItem`; mercenaries live in
`MercenaryItems.xs` with a case in `GiveMercenary`. Both switches have no `default`, so an unhandled
id vanishes silently.

The `Has…()` reader is consumed by a `SCRIPT_CALL` **condition** inside the scenario binary. A flag
with no reader sets and nothing happens.

### Linting

```
./xs-check.exe -I . -- AP_<Campaign>_<n>.xs
```

Run from the xs folder, against entry points only — a library file linted alone reports errors for
constants it never includes. A correct entry point reports **0 errors and 6 warnings**, all from
library files. Needs v0.2.30 or later. The linter is gitignored, so a fresh clone has none.

---

## Scenario triggers

The scenario binaries are the only place a location actually fires. Locations, items and XS can all
be complete and correct while nothing happens in game.

### The AP block

AP work is appended as a contiguous block at the end of the trigger list, introduced by empty
separator triggers:

```
"-- AP --"           empty, enabled
"AP <Thing>"         one per location
"-- AP Items --"     empty, enabled
"AP Give <Thing>"    one per item that hands something over
```

Across the twelve shipped scenarios: 182 added triggers — 107 location triggers, 33 item gates,
19 separators, the rest pre-staging.

### Trigger shapes

**Location.** Always enabled, not looping. Conditions are *duplicated* from the vanilla trigger that
marks the same deed; the AP trigger never hooks the vanilla one. A single `script_call` effect.

```
AP Green TC      C destroy_object {unit_object: 2705}
                 E script_call    {text: 'GreenTC();'}
```

Vanilla keeps its own trigger with the same condition. Attila 3 carries both
`[5] "[D3] Green TC Destroyed - 3000"` and `[35] "AP Green TC"`.

**Item gate.** A `script_call` condition reading `Has…()`, **paired with a state condition** — never
`Has…()` alone — and the reward as the effect.

```
AP Give Boats           C script_call     {xs_function: 'HasJoan3Boats();'}
                        C object_visible  {unit_object: 679}
                        E change_ownership {target_player: 1, area: [...]}

AP Give Green TC Gold   C destroy_object  {unit_object: 2705}
                        C script_call     {xs_function: 'HasAttila3GreenGold();'}
                        E tribute         {quantity: 3000, source_player: 3, target_player: 1}
```

Effects observed: `change_ownership` (25), `tribute` (2), `create_object` (2), and combinations with
`activate_trigger` / `deactivate_trigger`.

Condition order does not matter; `destroy_object` and the like stay true once satisfied, so the gate
fires whenever the later of the two arrives.

**Pre-staging.** `AP Set Scene` / `AP Setup` / `AP Startup` — no conditions, a `change_ownership` that
parks objects with a holding player until an item releases them.

### Counting deeds

Cumulative locations ("destroy one castle", "destroy two castles") read a count rather than a list of
specific objects:

```
AP Destroy One Castle    own_fewer_objects {object_list: 82, quantity: 3, source_player: 3}
AP Destroy Two Castles   own_fewer_objects {object_list: 82, quantity: 2, source_player: 3}
```

Where no object count tracks the deed, scenarios count with a variable: a `change_variable` effect on
each contributing trigger and a `variable_value` condition on the threshold trigger. Genghis 1's
vanilla sheep tally uses 21 looping triggers, each `own_objects {object_list: 594, quantity: N}` →
`change_variable {variable: 1, operation: set, quantity: N}`, read by `variable_value >= 20`.

### Resources and tributes

Scenarios start the player with **0 of every resource**; `StartingResources` items replace the
starting pile and `Resources` filler covers the rest.

Vanilla tributes are stripped and split in two:

1. the vanilla trigger keeps (or gains) a `change_variable` so objectives and victory counters still
   track, and
2. an `AP Give …` trigger delivers the resource, gated on the item.

Attila 3 went from 14 tributes to 2 this way.

*Deviation, not a pattern:* only Attila 1, Joan 1, Joan 2 and Genghis 1 currently ship with the
starting pile zeroed. The other fourteen carry vanilla values. Nothing zeroes resources at install
(`ScenarioParser` has only `rebase_to_dark` and `disable_triggers`) or at runtime in `InitAP`.

### Editing a scenario binary

The repo's `age 2 files/` **is** the live game folder. Edits land in the game immediately.

- **To read, use `kit`.** It handles 1.58 and 1.59, and every `AP_*` scenario is one of those. It is
  much faster than the vendored parser and needs no subprocess discipline. `kit scen field
  <field.path> --root <dir>` reads one field across a whole folder.
- **The vendored `AoE2ScenarioParser` is for writing, and for vanilla.** Shipped vanilla campaign
  bundles are 1.55, which `kit` rejects.
- **One scenario per Python subprocess** when using the parser. `_initialise_version_dependencies`
  mutates module-level dicts, so reading a 1.59 then a 1.58 file in one process commits the second
  with the first's schema. The `AP_*` scenarios are a mix of 1.58 and 1.59.
- `write_to_file` stamps `DataHeader.filename` from the output basename, so the name a file embeds
  is whatever basename it was last written under. Write to a temp file named after the scenario's
  **current embedded** filename and `os.replace` onto the real path, or the stamp changes as a side
  effect. Nine 1.58 files embed `….aoe2scenario.migrating`, left from the 1.55 migration:
  `AP_Attila_2`, `AP_Attila_5`, `AP_Attila_6` and all six `AP_Joan_*`.
- Add a condition with `trigger.new_condition.script_call(xs_function="HasFoo();")`. Set the bare
  string; the parser handles the trailing `\x00`.
- Match stored call strings with a regex such as `^\s*([A-Za-z_]\w*)\s*\(\s*\)\s*;?\s*$`, not
  `.rstrip(';')`, and assert the rewrite count.
- Diff against a **no-op round trip**, not the original, unless a no-op round trip is confirmed
  byte-identical for that file.
- Verify after writing: trigger count unchanged, effects unchanged, `invariant_ok=true`, and the
  embedded filename intact.

### Extracting vanilla scenarios

Vanilla campaign bundles live in
`…/AoE2DE/resources/_common/campaign/`. `campaign/CampaignReader.py` reads them:

| Bundle | Campaign |
|---|---|
| `xcam1` | Attila the Hun |
| `xcam2` | El Cid |
| `xcam3` | Montezuma |
| `cam2` | Joan of Arc |

Diffing an AP scenario against its vanilla original by trigger name is how the AP block is identified.

---

## What needs user guidance

These are **[ask]** items. They are judgement calls about the map and the design, and are not
derivable from the files.

**Which deeds become locations.** Trigger lists show what the scenario tracks; which of those are
worth a check, and whether a deed is `SIDE_QUEST`, `OBJECTIVE` or branching, is a design decision.
Whether to author the `_ALL` set alongside the `_ANY` set is likewise.

**Resource tier assignment.** `BASE` / `OPEN` / `ALLY` / `ENEMY` for every pile on every map. The
totals are checkable against the map; the split is not. Cluster decomposition narrows it — a tier
that matches a cluster exactly is usually right — but the answer is the user's.

**The shore / deep fish split.** `shore_fish_count` is food a fisherman on land can reach;
`deep_fish_count` needs a boat. It is positional, not by species: a shore fish stranded in open water
counts as deep, a salmon against a beach counts as shore. **It is not mechanically derivable.**
Measured against the scenarios whose fish totals are sound, a pure species rule reproduces 3 of 11, a
distance-to-land threshold peaks at 5, and species-with-adjacency-promotion peaks at 5; the
deviations run in both directions. Treat the totals as authoritative and confirm the split.

**Chapter display names.** Scenarios carry only string-id references; the bundle carries filenames,
and `key-value-strings-utf8.txt` holds no mission titles. They cannot be read from the files.

**Anything near a cliff.** Cliffs are their own object class, absent from both the unit list and the
terrain ids. A resource can be unreachable from the player's side with nothing in any scan to show it.

**Pavilion placement.** The tile and facing.

---

## Pitfalls

**Id bands**

- The 1000-2999 band holds `TCResources` members parked among the `ScenarioItem` rows
  (`STARTING_VILLAGER_FOOD` at 1024). Derive the next free id from `Age2ItemData`, never from the
  last `ScenarioItem` row.
- Three separate id spaces resolve through `unit_location()`: `Age2UnitData` (300-598),
  `Age2VillagerJobData` (560-583), `Age2HeroData` (584-595), `Age2EscortUnitData` (600-601),
  `Age2UnitLineData` (800-934). A collision shows up as "<unit> waits for an item the seed never
  contains".

**Silent failures**

- A `SCRIPT_CALL` condition naming a function that does not exist never errors, logs or warns. It
  simply never fires. `test_branching_install.py::test_every_condition_resolves_to_an_xs_reader` is
  the only automated check.
- `GiveProgressionItem` and `GiveMercenary` have no `default` case.
- Struct field names are runtime strings; a typo returns `-1`.
- Mercenary icon and string ids are unvalidated indices into the mod.

**Tests that encode counts**

`BRANCHING_SCENARIOS` in `test_branching_install.py` is derived from the branching locations. Other
hand-maintained lists are not: the `campaigns` lists in the test bases, the relic maps in
`test_scenario_resources.py` and `test_economy_rules.py`, and the shape counts in `test_tech_data.py`.

**Scenario data**

- Difficulty-conditional triggers change what is on the map. Genghis 1's "Hard Difficulty" trigger
  removes a relic and spawns two extra enemy units. Difficulty is the player's to set at any time.
- A map-wide `kill_object` fired by `player_defeated` can delete a faction's units before the player
  reaches them.
- Join triggers that hand a faction over are disabled at scenario start and armed by a separate
  request trigger.
