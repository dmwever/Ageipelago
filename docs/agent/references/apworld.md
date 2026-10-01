# age2de — the Archipelago apworld

Repo: the `Archipelago` fork — a **separate checkout** from the one this skill ships in, by convention
a sibling directory.
World: `worlds/age2de/`. All bare paths below are relative to that folder.

This half runs in Archipelago: it generates the multiworld and runs the client that drives the game
over `.xsdat` files. The game-side mod is a separate repo — see `xs-mod.md` and `protocol.md`.

## Layout

| Path | Holds |
|---|---|
| `__init__.py` | `Age2World`, `Age2Settings`, the client launcher registration |
| `Options.py` | `Age2Options` and every option class. One file per option in `options/` |
| `archipelago.json` | manifest: game name, `minimum_ap_version`, `world_version`, authors |
| `items/Items.py` | the payload dataclasses **and** the `Age2ItemData` table |
| `items/Events.py` | 10-line stub, imported by nothing. Reserved for scenario-completion and victory events |
| `locations/` | `Locations.py` (scenario objectives), `Ages.py`, `Buildings.py`, `Techs.py`, `Campaigns.py`, `Scenarios.py`, `Civilizations.py`, `Units.py`, `UnitLines.py`, `UnitLocations.py` |
| `locations/connections/` | `LocationMapping.py`, the civ matrices, the two late-binding modules, and the four unit binders (`UnitLineUnits`, `UnitBuildings`, `UnitTechs`, `UnitVariants`) |
| `logic/` | classes that *produce* rules. Per-scenario starting states in `attila/`, `joan/` |
| `rules/` | classes that *attach* rules to locations and entrances |
| `regions/` | `UnitRegions.py`. The rest of region building is still inline in `create_regions` |
| `client/` | `ApClient.py`, `GameClient.py`, `ApGui.py`, and `handlers/` |
| `campaign/` | `.aoe2campaign` binary read/write plus the `.xsdat` struct helpers |
| `generation/` | `Age2Pool` plus `pools/` (one per content group), and `Identity`, `WorldVersion`, `SlotData`, `LocalStart` |
| `test/` | 25 `test_*.py` modules, two base classes in `bases.py` |
| `AoE2ScenarioParser/`, `ordered_set/` | vendored. Do not edit piecemeal |

`rule_builder/` sits at the **repo root**, not in the world. It is a fork-level addition, not stock
upstream Archipelago, and supplies `CachedRuleBuilderWorld` plus the `Rule` DSL.

## `Age2World`

```python
AGE2_DE = "Age Of Empires II: Definitive Edition"

class Age2World(CachedRuleBuilderWorld):
    game = AGE2_DE
    options_dataclass = Age2Options
    topology_present = True
```

Lookup tables are built once at class-definition time from the module-level dicts in `Items.py` and
`LocationMapping.py`. `world_version` is **not** declared here — `AutoWorld`'s metaclass injects it
from `archipelago.json`, and raises if a world sets it manually.

Lifecycle, in call order:

1. `__init__` — nothing but `super()`. The seed's shape lives on the pool, not on the world.
2. `generate_early` — `inspect_options` (every `OptionError` and forced correction, including the
   random start a blank `starting_campaigns` asks for), `check_installable_name`, then
   `self.pool = Age2Pool(self)`. Everything after this reads the pool.
3. `create_regions`
4. `create_items`
5. `set_rules` — then the framework immediately calls `register_rule_builder_dependencies`, inherited
   from `CachedRuleBuilderWorld`.
6. `pre_fill` — `LocalStart.apply(self)`.
7. `fill_slot_data` — later, per slot, when multidata is written.

`Age2Settings` is a `settings.Group` with one field, `user_folder`, the AoE2 DE user directory.
At import, the module registers `Component("Age of Empires II: DE Client", …, Type.CLIENT)` so the
client appears in the Archipelago launcher.

### `create_regions`

It decides nothing about content. Every "which" question is the pool's; this builds regions and
places locations for what the pool says exists.

1. Origin (Menu) region.
2. One region per scenario, chained: Menu → scenario 1 → scenario 2 … per campaign, over
   `pool.scenarios.of(campaign)`. Locations come from `REGION_TO_LOCATIONS`, filtered by
   `pool.scenarios.includes_location`. Each scenario with a victory location also gets a hidden
   event location granting `"<scenario>: Unlock Next Scenario"`.
3. A `"Can Build"` hub off Menu, with no entrance rule.
4. One building location in the hub per `pool.buildings.locations`.
5. One age location per `pool.ages.locations` — empty when `shuffle_ages` is off. `pool.ages.shuffled`
   is the list regardless of the toggle; `locations` is the gated one, and they are different
   questions.
6. One region per building where `pool.buildings.hosts_locations`, entered from `"Can Build"` by a
   ruleless entrance. For each tech in `pool.techs.by_building(building)`: if
   `pool.techs.host_building(tech)` is this building, create its location here; otherwise add a
   ruleless entrance `"<region> to <other building> Techs"` to the host's region — once per
   distinct target.
7. `UnitRegions.create()` — realisation is decided here, not in the pool: a line is realised when a
   building that got a region trains it, or a scenario in the seed hands it over. What gets placed
   is recorded as it is placed, and the unit items follow that record.
8. The `"Victory"` event on the origin region.

### `create_items`

Dispatch on the payload type of each `Age2ItemData`:

| Payload | Treatment |
|---|---|
| `Victory` | skipped — granted only as an event |
| `ScenarioItem`, `Mercenary` | pooled if the scenario is in `pool.scenarios.included` |
| `Campaign` | precollected if in `starting_campaigns`, else pooled |
| `ProgressiveScenario` | `num_additional_scenarios` copies pooled |
| `TCResources` | always pooled |
| `Age2AgeData` | pooled if in `pool.ages.locations`, else precollected |
| `Building` | `continue` in the dispatch — handled afterwards (see below) |
| `Tech` | `continue` in the dispatch — handled afterwards (see below) |
| `Resources`, `StartingResources` | skipped here; used for the filler top-up |
| anything else | `ValueError` |

**`Building` and `Tech` are not handled in the dispatch loop.** Both branches are a bare `continue`;
the work happens in two loops that run *after* it, and those iterate their own tables rather than
`Age2ItemData`: one over `Age2BuildingData`, pooling a building if it is in
`pool.buildings.locations` and precollecting it otherwise, and one over `pool.techs.shuffled`,
pooling each. Unit items come from `unit_regions.items()`, which is the record of what region
building actually placed. If you go editing the `Building` branch in the dispatch, you are editing
dead code.

`create_item` goes through **`Age2World.classification_for`**, not `Items.classification_for`
directly. A mercenary is the one item whose worth depends on the seed: progression where a scenario
objective names it (the declared `in_logic` flag) or where unitsanity turns one of the soldiers it
hands over into a location (`pool.units.becomes_a_location`). Six at default options, eleven once
the unit locations open.

Filler: `pool.resources.plan(needed)` owns the whole tail — bin-pack toward
`{WOOD:725, FOOD:850, GOLD:750, STONE:400}` halving whenever the worst case would overshoot the free
locations, spend part of the leftover padding on traps, give up that many resource items, and only
then tally `pool.resources.totals`. The tally is **after** the trim deliberately: counting before it
would credit resources that were never pooled, and `HasResourceAmount` prunes rules against that
count. Plain `Resources` filler fills whatever is left.

### `set_rules`

`Rules.__init__` builds `Logic`, then `BuildingRules`, `AgeRules`, `TechRules` — `TechRules` snapshots
the `"Can Build"` exits at construction. Then `Rules.set_rules()` in fixed order:

1. `completion_condition[player] = lambda state: state.has("Victory", player)` — set directly, outside
   the rule_builder machinery. This is the real seed gate.
2. The `"Victory"` event location's rule ← `logic.has_goal()`.
3. Construct each scenario's `ScenarioRules` subclass, then call each one's `set_rules()`.
4. `AgeRules` (no-op unless `shuffle_ages`), `BuildingRules`, `TechRules` (no-op if techsanity is off).

`TechRules` skips the `set_rule` call when a tech's rule resolves to bare `True_`, which is equivalent
to leaving it unset.

`AgeRules.py` also defines `TwoBuildingsRequirement(NestedRule["Age2World"])`, with its own
`Resolved._evaluate` and an `explain_json` override. It is the only hand-written `rule_builder`
`NestedRule` in the codebase — copy it rather than inventing a second pattern.

### `logic/` versus `rules/`

`logic/` classes return unresolved `Rule` objects and never touch state or call `set_rule`. `rules/`
classes are the only code that wires rules onto locations and entrances. Method naming in `logic/`:
`has_x` for possession, `can_x` for capability, `counters_x` in `MilitaryLogic`,
`start_with_x` / `start_past_x` in `ScenarioLogic`.

```python
def can_build_building(self, building: Age2BuildingData) -> Rule:
    can_build: Rule = (self.buildings.has_building(building)
                       & self.buildings.has_prerequisites(building))
    return can_build & self.has_vils() & self.can_reach_age(building.age)
```

Each scenario has a `*StartingState` dataclass subclass (`logic/attila/attila_1.py` …) declaring
`is_unlocked`, `has_vils`, `has_base`, `age_playable`, `starts_with_building`, `has_water_access`,
`fixed_force`, every field with its own `default_factory`. It is instantiated inside the matching
`*Rules.__init__` and wrapped in a `ScenarioLogic`.

**A new `ScenarioRules` subclass must set `self.scenario_logic` itself.** The base class only declares
it as an annotation, and `ScenarioRules.set_rules()` calls `self.scenario_logic.is_unlocked()`. All 12
existing subclasses assign it right after `super().__init__(...)`; forgetting it is an `AttributeError`
at rule time.

**A location with no explicit `set_rule` is deliberate**, not an omission: it means being in the
scenario is the whole requirement, and the scenario's entrance rule already gates it.

## Data tables

Everything is a hand-authored `IntEnum` with a custom `__new__`/`__init__` carrying extra fields. Ids
are literal, hand-assigned, with no `base_id` offset — the numbers in the table are the network ids.

The payload dataclasses — `Resources`, `TCResources`, `Victory`, `Building`, `Tech`, `ScenarioItem`,
`Mercenary`, `ProgressiveScenario`, `Campaign`, `StartingResources` — are all defined at the top of
`items/Items.py`. They are **not** in `items/Events.py`.

```python
TOWN_CENTER = 202, "Town Center", Building(621, 375.0, Age2AgeData.DARK, {...})
TECH_LOOM   = 3616, "Loom", Tech(22, 22, -1, Age2AgeData.DARK, False, False)
```

### Id bands

| Band | Contents | Count | Game-side handler |
|---|---|---|---|
| 0 | Victory | 1 | — event only |
| 1-24 | `Resources` ×12, `StartingResources` ×12 | 24 | `GiveResource` |
| 25-29 | ages (26, 27, 28 used) | 3 | `UnlockAge` |
| 30-199 | Civs | 0 | — |
| 200-299 | buildings | 35 | `UnlockBuilding` |
| 300-548 | units | 249 | none yet — locations only |
| 800-926 | unit lines | 127 | none yet |
| 1000-2999 | `TCResources` ×2, `ScenarioItem` ×22 | 24 | `GiveProgressionItem` |
| 3000-3499 | progressive scenarios | 2 | none — client-side only |
| 3500-3599 | campaign unlocks | 2 | none — client-side only |
| 3600-3999 | techs | 293 | `UnlockTech` |
| 4000-4999 | mercenaries | 12 | `GiveMercenary` |

The 3000-3499 and 3500-3599 items are progression but are never delivered into the running game: they
drive which campaigns and scenarios the *client* unlocks and installs.

The 4000-4999 band holds the twelve mercenaries. Six are flagged `in_logic` — see *Mercenaries*.

These bands must stay in step with the legend in `ItemHandler.xs`.

### Derived dicts

Every derived dict is built by iterating the enum at import time; none is hand-populated. `Items.py`
is the only one that asserts:

```python
for item in Age2ItemData:
    assert item.item_name not in item_name_to_id, f"Duplicate item name: {item.item_name}"
    assert item.id not in item_id_to_name, f"Duplicate item ID: {item.id}"
```

`CivilizationTechs.py` asserts no tech is both included and excluded for a civ. The rest
(`Locations.py`, `Buildings.py`, `Techs.py`, `Scenarios.py`, `Campaigns.py`) assert nothing.

`LocationMapping.py` is the single place the four location-bearing sources are concatenated, in this
order: `Age2ScenarioLocationData` → `SHUFFLED_AGES` (not all of `Age2AgeData`; Dark is excluded) →
`Age2BuildingData` → `Age2TechData`. Its one assert compares dict length to list length, so it catches
duplicate **names** only. Nothing checks id uniqueness across the four bands — an overlap would
silently overwrite a dict key.

Beware a name trap: `Locations.py` also defines `location_from_id`, `location_name_to_id` and
`location_id_to_name` scoped to scenario locations alone. Those three are dead. The canonical ones the
World uses are the identically-named dicts in `LocationMapping.py`.

### Three separate id spaces

Easy to conflate: item and location ids (1-4999 for items, 10100+ for scenario objectives),
`Age2ScenarioData` ids (101-106, 201-206, computed as `campaign.value * 100 + chapter`), and the
in-game genie ids carried inside the payloads (`Building.game_id`, `Tech.game_id`, `effect_id`).

### Late binding

`Age2ScenarioData` members declare `rules` and `logic` as `None`, and two modules assign the **classes**
(not instances) as an import side effect:

```python
Age2ScenarioData.AP_ATTILA_1.rules = Attila1Rules   # ScenarioDataRules.py
Age2ScenarioData.AP_ATTILA_1.logic = Attila1StartingState   # ScenarioDataLogic.py
```

Consumers call the attribute as a constructor: `scenario.rules(self)`. `Rules.py` imports
`ScenarioDataRules` purely for the side effect, marked `# noqa: F401`. A missed binding leaves the
attribute as `None`, and `Rules.set_rules()` then calls `None(self)` — the symptom is
`TypeError: 'NoneType' object is not callable` at generation time, not a `None` flowing onward.

Other enum-attribute monkey-patching: `CivilizationTechs.py` and `CivilizationBuildings.py` assign
`included_techs` / `excluded_techs` / `excluded_buildings` onto `Age2CivData` members, then
`CivilizationTechs.py` derives `CIV_TO_TECHS`. There is no `CIV_TO_BUILDINGS` counterpart — building
eligibility per civ is computed ad hoc in `create_regions`. Note `Age2CivData.included_buildings`
defaults to `[]` and is **never assigned anywhere**; only `excluded_buildings` is ever populated.

## Units and unit lines

Added for unitsanity. **Units are locations, never items** - 16 of 21 upgraded unit names are
already tech item names (Arbalester, Champion, Paladin, Cavalier, Pikeman, Halberdier, Hussar...),
because the upgrade tech is named after the unit it produces, and `Items.py` asserts item-name
uniqueness at import. Location names are verb-prefixed, so "Train Arbalester" and "Research
Arbalester" coexist.

- **`Age2UnitData`** (`locations/Units.py`) - 249 members, ids **300-548**, ordered by `game_id`.
  Literal fields: `id, location_name, unit_name, game_id, age, is_unique, tier`.
- **`Age2UnitLineData`** (`locations/UnitLines.py`) - 127 members, ids **800-926**. A unit with no
  upgrades is still a line of one. `head` is a real `Age2UnitData` reference; `units` returns the
  tiers in order.
- Four **connections** modules bind the cross-enum attributes, split one per connected type the way
  `CivilizationBuildings` and `CivilizationTechs` are:

| module | map | binds |
|---|---|---|
| `UnitLineUnits.py` | `LINE_TO_UNITS` | `unit.line` |
| `UnitBuildings.py` | `BUILDING_TO_UNITS` | `unit.buildings` |
| `UnitTechs.py` | `UNIT_TO_UPGRADE_TECH` | `unit.upgrade_tech` |
| `UnitVariants.py` | `UNIT_TO_VARIANT_IDS` | `unit.variant_game_ids` |

`UnitLineUnits` asserts at import that every unit has a line, because a missed binding otherwise
surfaces far from its cause - the same trap as `Age2ScenarioData.rules`.

### Tiers, and why the upgrade graph is not a chain

An upgrade tech carries an edge from **every** lower tier, not just the one below: researching
Champion converts Militia, Man-at-Arms, Long Swordsman and Two-Handed at once. So **a tech's source
count is its tier index** - Man-at-Arms 1, Long Swordsman 2, Two-Handed 3, Champion 4. And one tech
can drive **parallel lines**: "Pikeman" upgrades Spearman to Pikeman *and* Donjon Spearman to Donjon
Pikeman, so the unit of work is a `(tech, target)` step, not a tech. Modelling it per tech silently
drops the entire Spearman line.

Lines branch, and branches share a tier: Knight, Cavalier, then {Paladin, Savar}; and
Militia ... {Legionary, Two-Handed}, Champion. Savar is Persian-only and Legionary Roman-only, so no
civ sees both and the civ disambiguates.

### One unit, several game ids

A unit trained at a different building keeps a **different genie id**, and a villager takes a new id
for **every job** - 27 of them. Counting one id undercounts badly; anything that counts owned units
must sum `game_id` and `variant_game_ids`.

| canonical unit | alternate building | extra id |
|---|---|---|
| Spearman / Pikeman / Halberdier | Donjon (Sicilians) | 1786 / 1787 / 1788 |
| Serjeant / Elite Serjeant | Donjon | 1660 / 1661 |
| Konnik / Elite Konnik | Krepost (Bulgarians) | 1254 / 1255 |
| Tarkan / Elite Tarkan | Stable (Huns, via Marauders) | 886 / 887 |
| Huskarl / Elite Huskarl | Barracks (Goths) | 759 / 761 |

**Stable Tarkan matters for Attila**, which is the Huns campaign and whose mercenary items reference
`TARKAN`.

### Known limits

- `is_unique` means "trains at Castle, Krepost or Donjon" - a proxy, with Trebuchet and Petard
  excluded by hand. It does **not** catch civ-uniques trained elsewhere (Longboat, Turtle Ship,
  Genitour, Battle Elephant, Steppe Lancer), which matters as soon as civ availability is derived.
- 16 units at tier > 0 have **no** `upgrade_tech`: Camel Rider, which upgrades automatically on
  reaching the Castle Age, and 15 Return of Rome units this world does not model. Treat a missing
  `upgrade_tech` as *ungated*, not *unreachable*.
- 20 units have no `buildings` - the Return of Rome naval units train at antiquity docks absent from
  `Age2BuildingData`, and `VILLAGER_FEMALE` and `JEAN_BUREAU` are carried only because mercenary
  items reference them.
- DE consolidates several game techs behind one tech-tree button: Fast Fire Ship, Galleon and
  Carrack are all **Heavy Warships**. `UnitTechs` names the tech the player researches.

## Mercenaries

```python
@dataclass
class MercenaryUnit:
    unit: Age2UnitData
    count: int

@dataclass
class Mercenary:
    vanilla_scenario: Age2ScenarioData
    units: list[MercenaryUnit]
    icon_id: int
    name_string_id: int
    in_logic: bool = False
```

`unit_ids` expands the squad to one id per soldier, which is the wire format; `unit_count` sums it.
`Age2UnitData` in `locations/Units.py` — see *Units and unit lines* below. Mercenary payloads read `.game_id`, never the member value.

Twelve mercenaries, ids 4000-4011, icons 313-324, string ids 990001-990012, supplied by the local mod
in the Ageipelago repo. Six carry `in_logic=True`.

**Classification is driven by `in_logic`.** `item_type_to_classification[Mercenary]` is
`PseudoClassification.progression_if_needed`, and `classification_for()` resolves it to `progression`
when the flag is set, else `useful`. The flag is a hand-maintained mirror of rule authorship, kept
honest by `test_mercenaries.py`: it walks the AST of every file under `rules/` and `logic/`, collects
each `Age2ItemData.<NAME>` reference, and asserts that set equals the declared `in_logic` set. Add a
rule that mentions a mercenary without flipping the flag and only that test will catch it.

`MercenaryHandler` owns the four seats and the queue: `_enqueue_unlocked` appends newly unlocked,
unused, unqueued mercenaries in arrival order; `_fill_seats` pops the queue head into the lowest free
seat; `_write_queue` serializes and bumps the serial only when the bytes change. The serial lives in
the handler instance, so it resets each session and the first sync after connect always bumps it —
deliberately, so the game reads the queue at least once per connection.

**Spent state lives in two places.** `DataStorage` packs one bit per mercenary, indexed by position in
the seed-filtered, id-sorted roster, into the server key `"{team}_{slot}_mercenaries_used"`.
`StorageHandler` keeps a local `APData/mercenaries_<player>_<tag>.json` with a record for every
mercenary, not only spent ones. `reconcile_spent` gives **local priority**: with no local file it
adopts the server, otherwise local wins and is pushed if it disagrees. A union was rejected
deliberately — it would make an under-informed and an over-informed local file indistinguishable, and
nothing could ever be un-spent. Two clients on one slot would clobber each other.

Two commands. `/mercenaries` prints **Used** → **In-Pavilion** → **Unlocked** → **Missing** in that
precedence; `/scenarios` prints **Active** → **Completed** → **Available** → **Unlocked** →
**Campaign Locked** → **Missing**.

## The client

Two halves. `Age2Context` (in `ApClient.py`) faces the Archipelago server; `Age2GameContext` (in
`GameClient.py`) faces the game. `Age2Context` implements three of the four `APClientInterface`
callbacks — `on_location_received`, `on_scenario_completion`, `on_goal`. The fourth,
`fetch_locations_collected`, is declared but called by nothing.

`status_loop` runs every 0.5s (2s when idle), in this order per pass: write `startup.xsdat`, sync each
unlocked scenario's own item file, write `locations.xsdat`, `buildings.xsdat`, `techs.xsdat`,
`messages.xsdat`; find the active campaign or scenario by peeking the leading active byte of each
candidate `.xsdat`; read the scenario packet; classify it; handle location updates, item acks and
sends; handle completion; write `free_items.xsdat`; write `AP.xsdat`; check victory.

`Age2Packet` parses the packet the game writes. Its field order and its 29-int reserved block match
`AP_Write` in `AP.xs` exactly. `scenario_id` sits at byte offset 72 and a test pins it there.

The 12-item in-flight window:

- `send_items` — writes nothing while any of the 12 echoed slots is still occupied; otherwise writes
  the next window of up to 12 unacked items, and only if it differs from what is already in flight.
- `ack_items` — matches echoed ids against `in_flight` **one occurrence at a time**, stopping at the
  first in-flight id not echoed. Matching per-occurrence rather than per-slot is deliberate; duplicate
  filler ids in one window would otherwise over-count.
- `free_items` — any echoed id not in `in_flight` is an orphan from a previous session and is written
  to `free_items.xsdat` so the game releases the slot.

Handlers — eight files in `client/handlers/`: `FolderHandler` (base, holds the profile folder),
`BuildingHandler` → `buildings.xsdat`, `TechHandler` → `techs.xsdat`, `MessageHandler` →
`messages.xsdat` (with an ack-gated queue), `CampaignHandler` (unlock tracking, active-file discovery,
per-scenario item files, victory), `InstallHandler` (`/install`), `MercenaryHandler` →
`mercenary_queue.xsdat`, and `StorageHandler` (server data storage, plus the module-level
`reconcile_spent(local, server)`). The last two are covered in the Mercenaries section below.

`/install` writes, in order: the retagged `.aoe2campaign` bundles that are not already installed,
then always `SlotData.xs`, then always `TechData.xs`. It rewrites scenarios through `ScenarioParser`
only to force `starting_age` to Dark, and only when techsanity requires it.

Nearly every file-write path is wrapped in `except Exception as ex: print(ex)`. Because that is
`print` and not `logging`, those failures do not reach the client's GUI log panel.

## generation/

- **`Identity.py`** — `seed_tag(seed_name, slot)` is `crc32("<seed>:<slot>")` as 8 lowercase hex.
  `file_stem(stem, tag, player)` puts the player name *before* the tag so the tag stays the last
  segment, which is what `TAGGED_XSDAT` (`^AP[ _].*_([0-9a-f]{8})\.xsdat$`) and `tag_of` match on.
  Do not confuse it with `source_campaign_stem`, which only appends `" Template"` for the shipped
  bundle and has nothing to do with tag placement. `sanitize_player` strips characters that are
  illegal in filenames.
- **`WorldVersion.py`** — `compatible(seed, client)` compares major and minor only; build is free.
- **`SlotData.py`** — `OPTIONS` maps six options to their XS constant names; `render` emits
  `extern const int NAME = value;` lines. `DEFAULTS` is `-1` for the identity fields and for four
  techsanity options, but `0` for `AP_TS_MODE` and `AP_SHUFFLE_AGES`, so a seedless install reads as
  off rather than as a valid mode. `seed_halves` splits the 32-bit tag because an XS int literal
  cannot hold it.
- **`Age2Pool.py` and `pools/`** — the seed's shape, built from the world in `generate_early` and
  read by region building, item creation and rule building alike. One pool per group of content:
  `campaigns`, `scenarios`, `civs`, `ages`, `buildings`, `techs`, `units`, `resources`.
  **A pool owns "is this in the seed". It never owns "what shape is the rule"** — `goal`,
  `lock_techs`, `tech_behavior` and `local_start` decide how a rule is written rather than what
  exists, and `test_pools.py` fails if a pool ever reads one. The pool takes the world, so it draws
  on the same seeded `random` and cannot drift from the multiworld.
  - `TechPool` decides whether a tech is a location: techsanity on, some included civ can research
    it, it matches the mode filter, uniques are shuffled if it is unique, and it is reachable given
    the earliest age. `host_building` places a shared tech under the first building that names it,
    and `shuffled` is the locations in that order.
  - `UnitPool` holds unit content — `line_locations`, the include predicates, the grants. It does
    **not** decide realisation: whether a line has somewhere to come from depends on which regions
    exist, so `UnitRegions` decides that and records what it placed.
  - `ResourcePool.plan(n)` owns build → roll traps → trim → tally in one method, because the tally
    has to come after the trim.
  - Two `OptionFilter` rule constants live in `AgePool.py` beside the data: `DARK_START` and
    `VANILLA_AGE_START`. They stay `OptionFilter`s deliberately — they are resolved inside the rule
    tree, and collapsing them at build time would change `item_dependencies` and so change the fill.
- **`LocalStart.py`** — best-effort. Picks a start scenario deterministically, greedily solves a
  minimal item set against the target rule, and places it with `fill_restrictive`. Every failure path
  logs a warning and continues with a smaller or empty set; it never fails generation.

## Tests

```
python -m pytest worlds/age2de/test
AGEIPELAGO_PATH=/path/to/Ageipelago python -m pytest worlds/age2de/test
```

25 modules, 451 tests, 4950 subtests. Two base classes in `test/bases.py`: `Age2TestBase(WorldTestBase)` for
pool and generation tests, and `Age2RuleTestBase` which drives
`generate_early → create_regions → create_items → set_rules` by hand and skips fill.

**Set `AGEIPELAGO_PATH` to the Ageipelago checkout, or two tests silently skip.** They default to a
hardcoded path from the original author's machine (`C:/Users/dmwev/...`) and are wrapped in
`skipUnless`, so on any other machine they pass by not running. They are the cross-repo anti-drift checks:
`AP.xs`'s `worldMajor`/`worldMinor` against `archipelago.json`, and a byte-identical round trip of the
real campaign bundles.

Other tests worth knowing: `test_item_delivery.py` drives a `FakeGame` through the ack/free protocol,
`test_slot_data_wire.py` checks every wired option name is real, and `test_world_version.py` uses
`inspect.getsource` to pin a completed refactor.

## Conventions and gotchas

- **Adding an item**: a new member in the right id band in `Age2ItemData`. The import-time asserts
  catch a duplicate id or name immediately. Add a branch in `create_items` if the payload type is new,
  and keep `ItemHandler.xs`'s band comment in step.
- **Adding a scenario**: define it in `Scenarios.py` (id is derived, so campaign and chapter must stay
  within 1-99), add its locations, write a `*StartingState` and a `*Rules`, and bind **both** in
  `ScenarioDataLogic.py` and `ScenarioDataRules.py`.
- **Version discipline**: `archipelago.json`'s `world_version` is the single source of truth. Any
  slot_data shape change needs a minor bump, and `AP.xs` must declare the same major and minor.
- **File naming is load-bearing.** Everything in `client/` depends on `Identity`'s exact output shape;
  changing it breaks the client's ability to tell its own seed's files from another's.
- `re-exported imports are a trap`: several modules import a name through an unrelated sibling rather
  than from its defining module. Import from the real source — `locations.Buildings`,
  `locations.Scenarios` — or a later cleanup of the intermediate module breaks the importer.
- `rule_builder`'s resolved-rule cache is a process-global `ClassVar` keyed partly by player. It is
  never cleared, so it persists across generations within one process, including a test run.
- `Age2World` holds no seed-shape attributes at all any more — they are on `world.pool`. The one
  exception is `unit_regions`, which is the record of what region building placed.
- An **item-link group world** is a real `Age2World` that never runs `generate_early`, yet core calls
  `create_item` on it. `create_group` is overridden to give it a pool, or any pool read there is an
  `AttributeError` that only reproduces for players using `item_links`.
- `player_name` is assigned *after* `create_group` returns, so nothing built inside that override may
  touch it. That is one reason option validation lives in `inspect_options` rather than in a pool.
