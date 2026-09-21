# Python conventions

## Enums carry their own data

Every data table is an `IntEnum` with a custom `__new__` that sets the int value and an `__init__` that
stores the rest:

```python
def __new__(cls, id: int, *args, **kwargs):
    obj = int.__new__(cls, id)
    obj._value_ = id
    return obj

def __init__(self, id, location_name, item, age, tech_options, buildings, prerequisite):
    ...
```

- Members are `SCREAMING_SNAKE_CASE`, with `=` column-aligned so the table scans as a table.
- Id bands are announced by a comment inside the enum body.
- Forward references are stored as **strings** and resolved by a lazy property — `Age2TechData`'s
  `_prerequisite` string becomes `Age2TechData[self._prerequisite]` in the `prerequisite` property.
- Option-tag holders (`BuildingOption`, `TechOption`) are plain classes of string constants, not enums,
  because they are list contents rather than lookup keys.

## Late binding through a side-effect import

`Age2ScenarioData` members declare `rules` and `logic` as `None`; two modules assign the **classes**,
and importers say why the import looks unused:

```python
# Imported for its side effect: binds Age2ScenarioData.<member>.rules, used in set_rules below.
from ..locations.connections import ScenarioDataRules  # noqa: F401
```

## `logic/` defines rules, `rules/` attaches them

Nothing in `logic/` touches `CollectionState` or calls `set_rule`; every public method returns a `Rule`.
Naming: `has_x` for possession, `can_x` for capability, `counters_x` in `MilitaryLogic`,
`start_with_x` / `start_past_x` in `ScenarioLogic`.

```python
def can_build_building(self, building: Age2BuildingData) -> Rule:
    can_build: Rule = (self.buildings.has_building(building)
                       & self.buildings.has_prerequisites(building))
    return can_build & self.has_vils() & self.can_reach_age(building.age)
```

Every `*StartingState` subclass takes the shared `Logic` and assigns it to `self.logic` — uniform
across all twelve.

**A new `ScenarioRules` subclass must set `self.scenario_logic` itself.** The base only declares it,
and `ScenarioRules.set_rules()` calls it.

## Per-instance state, never per-class

The comment in `rules/ScenarioRules.py` is there because this was a real bug:

```python
# Per instance, not per class: as a class attribute every scenario's rule
# object shared one location dict, across slots as well as scenarios.
self.locations = {}
```

## Handlers

A `Managed*` dataclass per tracked thing, a dict of them, `unlock_x` to mutate, `try_sync_x` as the
public entry point that writes the file, all wrapped so a write failure never kills the poll loop:

```python
@dataclass
class ManagedTech:
    data: Age2TechData
    item: Age2ItemData
    unlocked: bool = False
```

Note the client's existing handlers report failures with `print`, which does not reach the GUI log
panel; `logger` does. New code should prefer `logger`.

## Imports

**Import from the module that defines the name.** Several files imported `Age2BuildingData` through an
unrelated sibling that merely imported it too; when that intermediate import was cleaned up, 19 test
modules failed to collect. Import from `locations.Buildings`, `locations.Scenarios`, and so on.

- `from __future__ import annotations` in behaviour modules; the data-enum modules instead use PEP 695
  `type X = A | B` and string forward references.
- `TYPE_CHECKING`-guarded imports for circular types.

## General

- Dataclasses for payload and value objects; f-strings for formatting.
- Line length depends on the file's job: data tables run long and column-aligned, behaviour modules
  stay conventional.
- Comments explain **why**, not what — the id-band banners, the per-instance note, the `noqa` note.
- Both repos are **LF**. Writing a file with Python's default newline handling flips it to CRLF and
  produces a whole-file diff. Use an editor tool, or pass `newline="\n"` explicitly.
