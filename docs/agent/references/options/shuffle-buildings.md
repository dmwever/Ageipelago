# `shuffle_buildings`

## What the player sets

`ShuffleBuildings(OptionSet)`, display name "Shuffle Buildings". `valid_keys` is the eight
`BuildingOption` tags — `Base`, `Economy`, `Tech`, `Military`, `Castle`, `Defense`, `Unique`,
`Wonder` — and nothing else, because it is what the WebHost options page draws as checkboxes.
Building item names (`NAME_TO_BUILDING`) are accepted too, by an overridden `verify_keys`. Default is
`{Economy, Tech, Military}`, so Town Center, House and Castle are not shuffled by default.

> Determines which buildings to shuffle.
>     Base: Shuffle the town center and houses. Local Start's Base places these in your own world.
>     Economy: Shuffle the market, resource buildings and farms. Includes dock.
>     Tech: Shuffle the blacksmith and university.
>     Military: Shuffle the barracks, archery range, stable, siege workshop and monastery. Includes dock.
>     Castle: Shuffle the castle, and with Unique the krepost, fortified church and donjon.
>     Defense: Shuffle walls, gates and towers.
>     Unique: Shuffle unique buildings, if applicable civilizations are in the pool. Other options apply to these buildings, e.g. if economy isn't shuffled, neither is folwark.
>     Wonder: The wonder, the wonder, the... NO!
> A building's own name also works and shuffles it whatever its category, e.g. [Military, Market].
> Keys ignore case.

`verify_keys` matches each key without case against `canonical_keys_by_casefold` (the categories
plus every building name), raises `OptionError` on anything unknown, then replaces `.value` with the
canonical spellings: `ARCHERY RANGE` is stored as `Archery Range`. The yaml is input only, so the
player's casing carries no meaning, and `BuildingPool` compares exact strings. Archipelago's
`WorldTestBase` builds options with `from_any` and never calls `verify`, so tests built that way must
use canonical keys.

`Castle` as a key is the category: the Castle building plus, behind the Unique gate, its stand-ins.
The class overrides `__eq__` so it compares equal to a plain `OptionSet`, `OptionList` or raw set.

## Generation effect

`BuildingPool._is_shuffled`, for each `Age2BuildingData`, in order:

1. Skip it if no civ in the seed builds it — this wins over everything, including a named key.
2. Shuffle it if its item name was given as a key. A name outranks the `Unique` gate.
3. Skip a unique building unless `Unique` is selected.
4. Shuffle it if any of its own tags (excluding `unique`) was selected — a union.

Selected buildings are `pool.buildings.shuffled`, which drives `BuildingRules` and whether the item
is pooled or precollected. A shuffled House is also an `early_items` entry (`__init__.py`).

## Game effect

**None. There is no XS counterpart.** `Buildsanity.xs::CreateBuildingLocations()` registers all 35
buildings unconditionally, so the game cannot know which were precollected. This is architecturally
unlike every Techsanity option and unlike `shuffle_ages`, both of which the game gates on an `AP_*`
constant.

## Interactions

The `Unique` bucket additionally depends on which civs are in the seed, i.e. on `enabled_campaigns`.

`local_start: base` places the items a base needs in the player's own world. Unless `Base` (or
`Town Center` / `House` by name) is shuffled, those two are precollected, so it places only the rest
of the base solve — scenario items such as Attila's Camp.

## Tests

`test_pools.py::TestBuildingPool` (categories, names, the Unique gate),
`test_building_options.py` (key validation, canonical spelling, the listed keys and the default), `test_item_pool.py`'s House tests, and
`test_regions.py::TestBuildingSelection`, a regression test that unique buildings are never shuffled
without the option.
