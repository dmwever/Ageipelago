# `shuffle_buildings`

## What the player sets

`ShuffleBuildings(OptionSet)`, display name "Shuffle Buildings". Valid keys are the `BuildingOption`
tags: `Economy`, `Tech`, `Military`, `Defense`, `Unique`, `Wonder`. Default is
`{Economy, Tech, Military}`.

> Determines which buildings to shuffle.
>     Economy: Shuffle houses, TC, market, resource buildings, farms. Includes dock.
>     Tech: Shuffle blacksmith, university, monastery.
>     Military: Shuffle military buildings. Includes dock and castle.
>     Defense: Shuffle defensive buildings. Includes castle.
>     Unique: Shuffle unique buildings, if applicable civilizations are in the pool. Other options apply to these buildings, e.g. if economy isn't shuffled, neither is folwark.
>     Wonder: The wonder, the wonder, the... NO!

The class overrides `__eq__` so it compares equal to a plain `OptionSet`, `OptionList` or raw set.

## Generation effect

In `create_regions`, for each `Age2BuildingData`: skip if no included civ can build it; skip a unique
building unless `Unique` is selected *and* an included civ actually has it; otherwise create the
location if any of the building's own tags (excluding `unique`) intersects the selection. Selected
buildings accumulate in `world.shuffled_buildings`, which drives `BuildingRules` and whether the item
is pooled or precollected.

## Game effect

**None. There is no XS counterpart.** `Buildsanity.xs::CreateBuildingLocations()` registers all 35
buildings unconditionally, so the game cannot know which were precollected. This is architecturally
unlike every Techsanity option and unlike `shuffle_ages`, both of which the game gates on an `AP_*`
constant.

## Interactions

The `Unique` bucket additionally depends on which civs are in the seed, i.e. on `enabled_campaigns`.

## Tests

`test_regions.py::TestBuildingSelection`, including a regression test that unique buildings are never
shuffled without the option.
