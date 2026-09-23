# `unitsanity`

The gate for the whole unit feature. The other unit options do nothing while this is `none`.

## What the player sets

`Unitsanity(Choice)`, display name "Unitsanity". `option_none = 0` (default), `option_unit_line = 1`,
`option_all = 2`.

> Shuffles units. Owning a unit sends its check, and items are what let you train one.
> None: Units behave as vanilla.
> Unit Line: A whole upgrade line is one location and one item, e.g. the Knight line.
> All: Lines are still what you unlock, but owning any single unit is its own check.

Note the verb: a location fires on **owning** a unit, not on training one, so a unit handed over by
a scenario trigger or taken by conversion counts.

## Generation effect

`generation/UnitPool.py` answers which units a seed shuffles, the way `TechPool` does for
technologies, and `create_regions` places their locations.

Under `unit_line` a whole line is one location; under `all` each unit is its own and **the line
location is gone rather than doubled up** - owning an Archer and owning the Archer line would
otherwise be two checks for one event. Either way the items are still line-shaped, because a
line is what you unlock.

A unit location sits in **the region of the building that trains it**, exactly as a tech
location does. A unit trained at two buildings - a Donjon spearman, a Stable Tarkan - is placed
at the first in its own `buildings` order and the others get a ruleless entrance to it, so
reaching either building reaches the check. Its own order matters: sorting by the building enum
instead would move the Tarkan to the Stable.

With the two campaigns the world carries, `include_unique_units: none` gives **24 lines / 47
units**, and `both` gives **28 / 54**. `shuffle_villager` adds its own on top - 1 or 26.

## Game effect

None yet. The game side is Phases 11-13. `AP_Constants.xs` has no unitsanity mnemonics and
`SlotData.OPTIONS` is untouched, so the slot_data shape is unchanged and `world_version` stays
`0.3.0` - unitsanity is a 0.3.0 feature rather than a new version.

## Interactions

Gates `unitsanity_items`, `include_unique_units` and `caveman`. `shuffle_villager` is independent.

## Tests

None yet.
