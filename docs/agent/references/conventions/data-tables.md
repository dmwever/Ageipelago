# Data tables

## 1. Index canonical tables with `[]`, never `.get()`

A missing key is a bug and should raise `KeyError` immediately, not read as `None` and travel.

```python
item = Items.NAME_TO_ITEM[name]                 # __init__.py, create_item
item_data = Items.ID_TO_ITEM[received_item.item]  # client/ApClient.py
Items.CATEGORY_TO_ITEMS[Items.StartingResources]  # __init__.py
Age2TechData[self._prerequisite]                  # locations/Techs.py
```

Canonical means: `Age2ItemData`, `Age2TechData`, `Age2BuildingData`, `Age2ScenarioData`, `Age2UnitData`
and every dict derived from them — `NAME_TO_ITEM`, `ID_TO_ITEM`, `item_name_to_id`,
`CATEGORY_TO_ITEMS`, `SCENARIO_TO_ITEMS`, `BUILDING_TO_TECHS`, `CIV_TO_TECHS`.

`.get()` is for genuinely optional runtime data: slot_data, command arguments, handler-local state,
`REGION_TO_LOCATIONS.get(scenario_name, ())` for a scenario with no locations yet.

**One deviation on a canonical table:** `locations/Ages.py:18` does `ID_TO_ITEM.get(self.id)` because
the Dark Age has no item, and `SHUFFLED_AGES` filters on `age.item is not None`. It is the only one.
Flag it; do not copy it.

## 2. Guard membership when the key came from outside

Handler style, for ids arriving from the game or the server:

```python
if tech not in self._techs:
    print(f"Tech data not found ... Could not unlock tech {tech.name}.")
    return
```

`client/handlers/TechHandler.py`, mirrored in `BuildingHandler.py` and `MercenaryHandler.py`.

## 3. New data goes into the central enum

Add a member to the right `IntEnum` in its id band. Never a parallel dict, and never a per-feature
registry — every derived dict is built by iterating the enum at import time:

```python
for item in Age2ItemData:
    assert item.item_name not in item_name_to_id, f"Duplicate item name: {item.item_name}"
    assert item.id not in item_id_to_name, f"Duplicate item ID: {item.id}"
    NAME_TO_ITEM[item.item_name] = item
    ...
```

Those asserts in `items/Items.py` are the anti-drift guard: a copy-pasted id fails at import, on any
test run, rather than during generation. `CivilizationTechs.py` has the other one — no tech may be
both included and excluded for a civ.

The other tables assert nothing. `LocationMapping.py` checks duplicate location **names** only;
nothing checks id uniqueness across the four concatenated sources, so correctness rests on the bands
never overlapping.

## 4. Keep the two id legends in step

`ItemHandler.xs`'s header comment mirrors the band comments in `items/Items.py`. They are maintained by
hand. Change one, change the other.

## 5. Three id spaces, easily confused

- **Item and location ids** — 1-4999 for items, 10100+ for scenario objectives, 200-234 for buildings,
  3600-3892 for techs, 25-28 for ages.
- **`Age2ScenarioData` ids** — 101-106 and 201-206, computed as `campaign.value * 100 + chapter`.
- **In-game genie ids** — inside the payloads: `Building.game_id`, `Tech.game_id`, `effect_id`,
  `Age2UnitData.game_id`.

A tech's `Age2TechData` id and its `Tech.game_id` are different numbers. So are a building's location
id and its genie id.
