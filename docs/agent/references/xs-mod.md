# Ageipelago — the game-side XS mod

Repo: **this one**, `Ageipelago`. Paths are relative to its root.
XS source: `age 2 files/resources/_common/xs/`. All bare filenames below are in that folder.

This half runs inside Age of Empires II: DE. It owns no network code — it talks to the Archipelago
client only through binary files (see `protocol.md`). For exact `xs*` signatures and constant values,
use the `aoe2-modding` skill and its catalogs; this file does not restate them.

## Repo layout

| Path | Holds |
|---|---|
| `age 2 files/resources/_common/xs/` | 33 `.xs` files on disk — the 31 catalogued below plus `Test.xs` and `default0.xs` — and an untracked `xs-check.exe` |
| `age 2 files/resources/_common/scenario/` | 12 `.aoe2scenario` binaries: `AP_Attila_1..6` and `AP_Joan_1..6` |
| `age 2 files/resources/_common/campaign/` | 2 untagged `.aoe2campaign` template bundles |
| `age 2 files/mods/local/Ageipelago/` | local mod: mercenary seat names and tech icons |
| `docs/` | `communication_protocol.md` (authority for the wire format), `AP FAQ.md`, `Logic Requirements/` |

Only **Attila the Hun** and **Joan of Arc** are implemented — 12 scenarios. The 25 spreadsheets in
`docs/Logic Requirements/` are design artifacts for campaigns that mostly do not exist; nothing reads
them. There is no CI and no test suite in this repo.

## The files

| File | Lines | Purpose |
|---|---|---|
| `structs.xs` | 990 | vendored XsStructs 1.1.1. Do not audit or edit |
| `Unitsanity.xs` | 571 | **dead** — included by nothing, called by nothing. See Gotchas |
| `AP.xs` | 409 | the bridge: `AP_Write`/`AP_Read`, identity checks, `InitAP`, 7 rules |
| `Buildsanity.xs` | 371 | building unlocks and placement detection |
| `Techsanity.xs` | 356 | technology unlocks, the shadow-tech effect injector |
| `ProgressionItems.xs` | 293 | per-scenario one-shot flag items, ids 1000-1023 |
| `ResourceItems.xs` | 171 | filler and starting resources, ids 1-24 |
| `MercenarySeats.xs` | 168 | the four pavilion seats and the queue reader |
| `MercenaryItems.xs` | 155 | mercenary flag items, ids 4000-4011 |
| `ScenarioLocations.xs` | 147 | the location ledger |
| `AP_Constants.xs` | 186 | **every** shared `extern const` |
| `MercenarySpawn.xs` | 116 | area clearing, the per-soldier loop, the muster task |
| `ItemHandler.xs` | 98 | `GiveItem` band dispatcher, startup-file readers |
| `Ages.xs` | 70 | age shuffle |
| `MercenaryLedger.xs` | 55 | the pending completed-mercenary queue |
| `AP_Headers.xs` | 55 | the nine `mutable` stubs, each of which warns when it runs |
| `APavilion.xs` | 172 | creates the pavilion, hardens it, owns the victory flow and colour cycle |
| `SlotData.xs` | 9 | per-seed identity and options, written by `/install` |
| `TechData.xs` | 6 | per-seed tech table, written by `/install` |
| `AP_Attila_1..6.xs` | 41-93 | scenario entry points, ids 101-106 |
| `AP_Joan_1..6.xs` | 45-85 | scenario entry points, ids 201-206 |

There is no `Tech_Constants.xs`. Its constants were folded into `AP_Constants.xs`, which is now the
single home for every shared `extern const` — techsanity modes, tech-state write values, cost
attribute range, building ids, ages, and the mercenary seat constants.

## Include graph

```
AP_<Campaign>_<N>.xs   (12 entry points, one main() each)
└── AP.xs
    ├── AP_Constants.xs          every shared extern const
    ├── SlotData.xs              AP_SLOT_ID, AP_SEED_*, AP_TS_*, AP_SHUFFLE_AGES
    ├── ItemHandler.xs
    │   ├── ProgressionItems.xs
    │   ├── MercenaryItems.xs
    │   ├── ResourceItems.xs
    │   ├── Buildsanity.xs
    │   │   └── AP_Headers.xs
    │   │       ├── structs.xs
    │   │       └── ScenarioLocations.xs
    │   ├── Ages.xs              ← contains no include statements at all
    │   └── Techsanity.xs
    │       └── TechData.xs
    ├── MercenaryLedger.xs
    ├── MercenarySeats.xs
    ├── MercenarySpawn.xs
    └── APavilion.xs
```

**Include order is still load-bearing, and there are still no include guards.** `AP.xs` now includes
`AP_Constants.xs` first, which is what makes the constants reachable everywhere downstream —
`Ages.xs`, `Techsanity.xs` and the mercenary files all use constants they never include. That is far
less fragile than it was, but reordering `AP.xs`'s first three includes still breaks the build, and
adding an include to a file that already receives a symbol duplicates every definition in it.

## Entry points

There is no single `main()`. Each of the twelve scenario files is compiled independently as that
scenario's script and defines its own:

```xs
include "./AP.xs";

void InitScenarioLocations() {
  // Scenario-Specific - Not defeatsanity/relics
  AddLocations(10500, 10503);
}

void GiveScenarioItems() {
  ReadScenarioItemFile("ATT5");
}

void SetScenarioAge() {
  SetVanillaAge(CASTLE_AGE);
}

void main() {
  SetScenarioId(105);
  InitAP();
}

// Scenario-specific locations
void Victory() {
  GiveVictory();
  AP_Check_Location(10500);
}

void DefeatRomans() {
  AP_Check_Location(10501);
}

...

void SetPavilionLayout() {
    SetPavilionPlacement(127, 169, PAVILION_FACE_NW);
}
```

Both comment lines appear verbatim in all twelve files. `Victory()` is always
`GiveVictory(); AP_Check_Location(<idStart>);` and is always the first wrapper. `SetPavilionLayout()`
is last, and all twelve have one.

The wrapper functions are called from `script_call` effects baked into the `.aoe2scenario` binary, not
from XS. So a wrapper with no caller looks dead in a grep of the `xs/` folder and is not. Note that
AoE2 silently ignores arguments passed through `script_call`, which is why every wrapper called that
way takes none.

| Scenario | id | Locations | Vanilla age |
|---|---|---|---|
| Attila 1-6 | 101-106 | 10100-10116, 10200-10208, 10300-10315, 10400-10407, 10500-10503, 10600-10611 | Dark, Castle, Castle, Castle, Castle, Imperial |
| Joan 1-6 | 201-206 | 20100-20111, 20200-20211, 20300-20308, 20400-20405, 20500-20514, 20600-20604 | Castle, Feudal, Feudal, Castle, Imperial, Castle |

Location id = `scenarioId * 100 + offset`; offset 0 is always Victory. `AP.xs` recovers the scenario
from a location with `locationId / 10 / 10`. Scenario ids 107-200 are unused headroom;
`MIN_SCENARIO_ID = 101`. In every file the wrapper count equals the registered id count exactly.

## The `mutable` stub pattern

`AP_Headers.xs` declares nine `mutable` functions. This is the mod's only polymorphism: a later
plain definition replaces the stub, and every call site binds to the last definition — which is also
what lets a file call something defined in a file included *after* it, as `MercenarySpawn.xs` does
with the pavilion points.

| Stub | Overridden by |
|---|---|
| `AP_Check_Location(int locationId)` | `AP.xs`, once, shared |
| `addTech(...)` 9 params | `Techsanity.xs`, once, shared |
| `HasPavilionPlacement()` | `APavilion.xs`, once, shared |
| `PavilionSpawnPoint()` | `APavilion.xs`, once, shared |
| `PavilionMusterPoint()` | `APavilion.xs`, once, shared |
| `InitScenarioLocations()` | each of the 12 scenario files |
| `GiveScenarioItems()` | each of the 12 scenario files |
| `SetScenarioAge()` | each of the 12 scenario files |
| `SetPavilionLayout()` | each of the 12 scenario files |

**Every stub announces itself in red when it runs.** A stub still holding the floor means the real
definition never arrived — a scenario forgot an override, or an include moved and a library one is
out of reach — and the symptom would otherwise be a feature that quietly never happens. There is no
once-only guard, so the ones reached from rules repeat; a broken build is meant to be loud. This is
what replaced the build-time drift checks.

## Item id bands

The legend lives in `ItemHandler.xs`'s header comment and must stay in step with `items/Items.py`.
`GiveItem(itemId)` dispatches by range:

| Band | Handler | Live in XS |
|---|---|---|
| 1-24 | `GiveResource` | yes |
| 25-29 | `UnlockAge` | yes |
| 200-299 | `UnlockBuilding(itemId - 200)` | yes, indices 0-34 populated |
| 1000-2999 | `GiveProgressionItem` | yes, cases 1000-1023 |
| 3600-3999 | `UnlockTech(itemId - TECH_ITEM_OFFSET)` | yes |
| 4000-4999 | `GiveMercenary` | yes, cases 4000-4011 |
| 0, 30-199, 300-999, 3000-3599 | none | no — the apworld never sends these to the game |

`GiveItem` has no else branch and none of the three item switches has a `default`, so an id outside a
live band is dropped with no output. That is safe only because the Python side never emits one.

## Subsystems

### Location ledger — `ScenarioLocations.xs`

A flat array of `Location` structs (`"id"`, `"scenarioComplete"`, `"serverComplete"`), capacity 1024,
appended in registration order and searched by linear scan. Two independent flags per location: the
game sets `scenarioComplete`, the client's ack sets `serverComplete`.

`FilterCompletedNotSent()` collects everything scenario-complete but not server-complete into a reused
scratch array and reports the count through the `extern int filteredCount` global — the standard XS
workaround for having no second return value. **Read exactly `filteredCount` entries**; the scratch
array keeps stale trailing entries from any earlier, longer call.

`AddLocations(idStart, idEnd)` is inclusive at both ends. It returns an array of the handles it
created and all twelve callers discard it; the ledger side effect is the real output.

### Buildsanity — `Buildsanity.xs`

Registers 35 buildings, each with a name, genie id, exact resource cost and location id (200-234),
then detects placement by watching `xsPlayerAttribute(1, cAttributeValueCurrentBuildings)` from a
`highFrequency` rule:

1. total dropped → resync and return (a building was lost, not built)
2. `cAttributeTotalCastlesBuilt` rose → Castle check, return
3. `cAttributeTotalWondersBuilt` rose → Wonder check, return
4. total unchanged → refresh baselines, return
5. otherwise match the delta against every building's exact cost, and for each candidate confirm with
   a live object count above its stored `playerCount` before firing the check

Castles and Wonders are pulled out into steps 2 and 3 because the engine counts them separately, in
`cAttributeTotalCastlesBuilt` and `cAttributeTotalWondersBuilt`. Costs collide heavily among the rest
— Castle and Feitoria both cost 650, six buildings cost 100, five cost 175 — so the cost match alone
is ambiguous by design and the object-count confirmation in step 5 is what actually disambiguates.
`highFrequency` polling is what keeps two completions from landing in one sample.

Building identity inside this file is dispatched entirely on the name string, in three separate places
(`Built`, `updateCosts`, `checkPrerequisites`). Renaming a building in `createLocationLock(...)`
silently breaks its special case with no compiler error.

`checkPrerequisites` hardcodes the tech-tree gates: Farm needs a Mill; Stable and Archery Range need a
Barracks plus Feudal; Blacksmith needs Feudal; Market needs a Mill plus Feudal; Siege Workshop needs a
Blacksmith plus Castle age; Monastery, University and Castle need Castle age.

The two disable mechanisms are not interchangeable: `UnlockBuilding` clears the disabled flag with
`cSetAttribute`, and `checkPrerequisites` separately fires `cEnableObject`. Clearing the flag does not
restore tech-tree gating.

### Techsanity — `Techsanity.xs`

Off entirely unless `AP_TS_MODE != TECHSANITY_NONE`, then refuses to run unless
`TS_SEED_HIGH`/`TS_SEED_LOW` from `TechData.xs` match `AP_SEED_HIGH`/`AP_SEED_LOW` from `SlotData.xs`.

`InitTechsanity()` in order: mode gate → seed gate → define the `Tech` struct and allocate `techArray`
and `techByItem` (both `TECH_CAPACITY` = 400) → `LoadTechTable()` → bail with a `<RED>` "run /install"
line if nothing loaded → `hardenShadow()` → `reconstructStartingState(apVanillaAge)` → `initTech` over
every location tech the civ can research → enable `TechsanityUpdate`.

The effect injector: each real tech has its effect stripped to `NOOP_EFFECT`, and effects are applied
through one donor, `TECH_SHADOW = 1181`, hardened once with time 0, all four costs 0, location -1, no
button, stacking on and a research cap of `TECH_CAPACITY`. `applyViaShadow` then writes
`STATE_ENABLE`, rebinds `cAttrSetEffect` to the real tech's effect id, and writes `STATE_DONE` to fire
it. Background and hazards: the `xs_blank_tech_effect_injector` recipe in the `aoe2-modding` KB.

`TechsanityUpdate` polls `cAttributeResearchCount` every tick and only sweeps the table when it rises.
It never self-disables, because research has no terminal state.

Of the option enums, only `TECHSANITY_NONE`, `BEHAVIOR_MUST_RESEARCH`, `LOCK_ITEMS`,
`UNIQUES_UNSHUFFLED`, `UNIQUES_SHUFFLED_EVERYWHERE`, `EXISTING_START_IN_DARK_AGE`,
`EXISTING_FIND_ITEMS` and `EXISTING_ONLY_FIND_UNITS` are ever compared. The rest are the implicit
else, deliberately: the apworld's `TechPool` decides which techs exist, so the game only needs on or
off. Upgrades always require real research regardless of `AP_TS_BEHAVIOR`.

### Mercenaries — `MercenarySeats.xs`, `MercenarySpawn.xs`, `MercenaryLedger.xs`

A mercenary is a unit squad delivered as an item (ids 4000-4011). Receiving it does not spawn
anything: it offers the squad in one of four **seats** on the pavilion, and the player takes it by
researching that seat's tech. Research time in seconds equals the squad size, and soldiers appear one
per second while it runs.

Constants, all in `AP_Constants.xs`: `MERCENARY_SEAT_COUNT = 4`, `MERCENARY_SEAT_TECH_FIRST = 1182`
(1180 is victory, 1181 is the techsanity donor), `MERCENARY_SEAT_BUTTON_FIRST = 11`,
`PAVILION_BUILDING = 624`, `MERCENARY_SEAT_RESEARCH_CAP = 1000`, `MERCENARY_TASK_VARIABLE = 90`.
`MercenaryLedger.xs` adds `MERCENARY_PENDING_MAX = 4`; `MercenarySeats.xs` adds `SEAT_EMPTY`,
`SEAT_OFFERED`, `SEAT_RUNNING`.

A `Seat` struct per seat — `"mercenaryId"`, `"unitCount"`, `"state"`, `"units"` — in a vector array,
with `SeatAt(seat)` as the single bounds-checked index-to-instance conversion.

**Harden once**, per seat at init: disable the tech, zero all four costs, bind `cAttrSetEffect` to
`NOOP_EFFECT`, stacking on, research cap to `MERCENARY_SEAT_RESEARCH_CAP`, location to
`PAVILION_BUILDING`, and the seat's button. Skipped with a red warning if the tech reads
`cTechStateInvalid`.

**Offer** (`OfferSeat`, from `SyncSeat`, from `ReadMercenaryQueue`): disable → `cAttrSetTime` = unit
count → `cAttrSetName` → `cAttrSetIcon` → enable, then record the mercenary and `SEAT_OFFERED`.

**Run**: `MercenarySpawnLoop` promotes an offered seat to `SEAT_RUNNING` once `IsSeatResearching`, then
`RunSeat` places one soldier per game-second. `ClearSpawnArea` runs once per seat activation, sweeping
five building classes across all nine players and removing anything within 1.5 tiles of the spawn
point, because `xsCreateUnit` runs with collision checking off.

XS cannot order a unit to move, only teleport it, so each spawn raises trigger variable 90 and a
looping "AP Mercenary Muster" trigger tasks the new unit from a 3×3 box around the spawn point to the
muster point, then resets the variable.

**Complete**: `MarkMercenaryComplete` pushes the id onto the ledger (max 4), `ClearSeat` disables the
tech and resets the struct. `AP_Write` republishes the ledger head every tick until the client's ack
pops it.

### Ages — `Ages.xs`

`InitAges()` always calls `SetScenarioAge()` first, then returns immediately unless
`AP_SHUFFLE_AGES == 1`. When shuffling, it registers a location per age and disables the three age-up
techs (101 Feudal, 102 Castle, 103 Imperial — the genie names mislead, they are named for the age they
are researched *in*). `ShuffleAgesUpdate` polls all three and self-disables once all are reached. It
re-checks already-done ages every tick and relies on `SetScenarioLocationComplete` being idempotent.

### Items

`ProgressionItems.xs` and `MercenaryItems.xs` are one-shot flags: a private `bool`, a setter named for
the item, a `HasX()` getter, dispatched from one `switch`. `ResourceItems.xs` grants resources through
`cModResource`.

## Rules

| Rule | File | Shape | Ends |
|---|---|---|---|
| `ConnectAP` | `AP.xs` | inactive, 1/1 | hands off to `ReadAP`, then `xsDisableSelf` |
| `ReadAP` | `AP.xs` | inactive, 2/4 | runs for the session |
| `ReadItems`, `FreeItems`, `MarkServerLocations`, `ReadMessages`, `ReadMercenaries` | `AP.xs` | inactive, 1/1 | `xsDisableSelf` on every path |
| `BuildsanityChecks` | `Buildsanity.xs` | inactive, group Buildsanity, highFrequency | runs for the session |
| `TechsanityUpdate` | `Techsanity.xs` | inactive, group Techsanity, 1/1 | runs for the session |
| `MercenarySpawnLoop` | `MercenarySpawn.xs` | inactive, group Mercenaries, highFrequency | runs for the session |
| `ShuffleAgesUpdate` | `Ages.xs` | inactive, group Ages, 1/1 | `xsDisableSelf` once all three ages are reached |
| `initializeStructsRule` | `structs.xs` | vendored, runs immediately | — |

The five one-shot readers are armed by `AP_Read` when the client raises the matching flag in
`AP.xsdat`, and disarm themselves whether or not the file opened. `ConnectAP` is the canonical
bootstrap: poll until the client answers, grant startup items once, wait for the scenario's own item
file, then enable `ReadAP` and disable itself.

## The AP pavilion

`APavilion.xs` owns it end to end. There is no tooling and no coordinate file: each scenario's
`SetPavilionLayout()` passes a tile and a facing to `SetPavilionPlacement(x, y, facing)`, and
`InitPavilion()` — called from `InitAP()` — creates the building with `xsCreateUnit` and keeps the
id it returns. Nothing searches the map for a pavilion; a scenario that already has one of its own
would be found first and then renamed, recoloured and made indestructible.

Spawn and muster are **derived**, not authored: two and six tiles out from the pavilion along its
facing. That held in all twelve scenarios when it was checked, which is why the JSON that used to
carry them is gone.

`SetupPavilion()` does the building — `xsSetUnitName`, `cInvulnerabilityLevel` via
`xsEffectAmount(cSetUnitAttribute, ...)`, and `cUnitDeletable` off. `SetupVictory()` does tech 1180
— location, button, icon, state, then `xsSetTechName` and `xsSetTechDescription`, which take literal
strings and so need no entry in the local mod.

`AnnounceVictory()` runs once when the scenario's objective completes. It is called directly from
each of the three places `AP.xs` writes `completed` — `GiveVictory`, `AP_Read` and
`ReadScenarioItemFile` — and guarded by `pavilionVictoryShown`, so there is no watcher rule. It
flips the victory tech to enabled, moves the view, flashes the building, prints the instruction, and
arms the two rules below.

| Rule | Armed by | What it does |
|---|---|---|
| `PavilionColorCycle` | `AnnounceVictory()` | one colour per second through `cUnitColorId`, six-colour loop |
| `PavilionDeclareWatch` | `AnnounceVictory()` | polls tech 1180; on `cTechStateDone`, `xsDeclareVictory(1, true)` and disables itself |

Pass `xsDeclareVictory`'s second argument explicitly — left off, it **defeats** the player.

Two values in `AP_Constants.xs` are assumptions, not documented facts: the `cUnitColorId` base
(0-based here, one lower than the editor's list) and `cUnitDeletable`'s polarity. The guide
documents the Unit Property constants with a templating artifact and gives no value ranges. Read
them back with `xsGetUnitProperty` if either behaves oddly.

What remains in the `.aoe2scenario` binaries: `-- AP --`, the looping `AP Ping` whose effect is
`script_call(message="AP_Write();")`, `AP Victory`, and the ~140 per-location triggers. Everything
else the old tooling authored — eleven triggers per scenario, plus the placed pavilion unit — was
removed once, by a migration that is no longer in the repo.

## Linting

```
./xs-check.exe -I . -- AP_Attila_1.xs
```

Both halves of that invocation matter, and dropping either fails in a different way:

| Invocation | What happens |
|---|---|
| `./xs-check.exe -I . -- AP_Attila_1.xs` | correct |
| `./xs-check.exe AP_Attila_1.xs` (no `-I`) | 1 `UnresolvedInclude` + 25 `NameError` — it cannot find `./AP.xs`. **Not** a usage banner; it looks like real breakage |
| `./xs-check.exe -I . AP_Attila_1.xs` (no `--`) | prints usage. `-I`/`--include-dirs` is variadic, so it swallows the filename and no positional filepath is left |

The linter is **not vendored** — `xs-check.exe` is gitignored (`.gitignore:208-216`) and untracked, so
a fresh clone or a new worktree has none. The only copy in this repo is in the `xs/` folder. A second,
unrelated copy ships inside the venv at
`.venv/Lib/site-packages/AoE2ScenarioParser/dependencies/xs-check/`; it is pip-managed, the parser
pins the version range it accepts, and nothing in this project invokes it. Leave it alone.

**Lint the twelve scenario entry points, not the library files.** Only an entry point pulls in the
whole include chain. A clean entry point reports **0 errors and 3 warnings** (identical across all
twelve, all `DiscardedFn`); linting `ItemHandler.xs` on its own reports 139 `NameError`s, because the
constants it uses are included by `AP.xs` one level above it.

The version matters. **Update 185872 needs `xs-check` v0.2.30 or later** — v0.2.29's prelude predates
the patch and knows none of `xsSetUnitName`, `xsSetUnitProperty`, `xsGetUnitProperty`, `xsTaskUnits`,
`xsSetViewPosition`, `xsFlashUnit`, `xsSetTechName`, `xsSetTechDescription`, `cInvulnerabilityLevel`,
`cUnitColorId`, `cUnitDeletable` or `cActionTypeMove`, so every call to one reads as a `NameError`.
If you are stuck on an older build, `-e, --extra-prelude-path` takes an additional prelude file: a
few stub declarations with defaulted parameters is enough to quiet it.

What the linter cannot catch here: a misspelled struct field-name string, a missing `extern`, an empty
function body, a `switch` with no `default`, a mistyped rule name in `xsEnableRule`. See
`XS_MEASURED_BEHAVIOR.md` in the `aoe2-modding` KB.

## Gotchas

- **`Test.xs` and `default0.xs` are not part of the mod.** `Test.xs` (6 lines) is a scratch file whose
  `include "./BuildsanityItems.xs"` points at a file that exists nowhere in the repo — never build or
  lint it. `default0.xs` (3 lines) is engine-generated boilerplate. Neither appears in the file table
  below; an `ls *.xs` will show them anyway.
- **`Unitsanity.xs` is dead.** Nothing includes it, nothing calls any of its twelve functions, and it
  uses `defineStruct`/`new` without including `structs.xs`, so it would not resolve on its own if it
  were included. Its `Unit`/`Unitsanity` structs mirror Buildsanity's but the driver was never written.
- **`SlotData.xs` and `TechData.xs` in the repo are stubs.** `/install` overwrites them per seed. With
  the tracked versions, `AP_SLOT_ID` is -1 so `AP_Write` never creates a packet, and `LoadTechTable()`
  is empty so techsanity bails. The identity fields ship as -1 and the option fields as 0, so an
  untouched install reads as no slot and every option off rather than as a valid option value.
- **Struct fields are runtime strings, case-sensitive, and fail to `-1` silently.** A past bug was
  exactly this: `"CastlesBuilt"` versus `"castlesBuilt"`, fixed in `31eecd4`. Grep every string
  occurrence when renaming a field.
- **`MarkServerLocations` contains the only `continue` in project XS.** Whether `continue` skips a
  `for` loop's increment is unresolved; if it does, that loop never terminates. First suspect if the
  rule ever hangs.
- **`UnlockBuilding(index)` does not bounds-check.** Item ids 200-299 map to indices 0-99 but only
  0-34 are populated, so an id of 235 or higher would read an unset slot and write with id -1. Latent
  only: the apworld emits 200-234.
- **A rejected mercenary seat is dropped permanently.** `OfferSeat` returns without writing the struct
  when `unitCount < 1`, but `ReadMercenaryQueue` advances the consumed serial regardless, so the client
  stops re-sending and that mercenary can never be seated again. Only a Python-side assertion that
  `unit_count > 0` keeps it from happening.
- **A mercenary seat that cannot place units stalls silently.** When `xsCreateUnit` returns -1,
  `SpawnNextSoldier` returns false with no chat, unlike the adjacent unknown-unit branch. Nothing
  checks the return, so the seat retries every game-second forever, never completing.
- **`spawnAreaScan` is never initialized** despite its comment pointing at `InitMercenarySpawn`.
- **`ReadItems` fills a fixed 12-slot ring by position.** An item is only taken if slot `i` is free.
- **`AP_Write` always writes the active flag as 1.** The client decides a scenario has gone inactive.
- **The disconnect warning repeats** on every pass once the ping stops moving, by design.
  `ReportMismatch` in the same file deliberately fires once instead.
- **`DeclareVictory()` in `APavilion.xs` has no XS caller.** Expected to be invoked from scenario
  trigger data, which is binary and not greppable; unverified.
- **"Defeatsanity"** in old branches means the per-player-colour defeat checks removed in `78f1409`.

## Untested in game

The mercenary feature is merged but has never been run. Open, worst first: whether a seat tech really
re-researches under stacking plus a raised cap (if not, only the first four mercenaries ever spawn,
silently); what `xsCreateUnit` returns on failure; whether trigger variable 90 is free in all twelve
scenarios (Attila 1 is known to use variable 2); whether a unit created this tick is visible to a
`task_object` trigger in the same tick; whether the spawn and muster points are right; and whether the
one-second research clock reads well against the spawn cadence.
