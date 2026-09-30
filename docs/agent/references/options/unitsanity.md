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

**Each unit line is a region, and each way of coming by one is an entrance.** A technology has
a single source, so a tech location can live with the building that researches it. A unit has
four - you train it, the scenario starts you with it, a trigger hands it over, or you convert
someone else's - and only the first is a building. So the entrances are `train` from the
producing building's region, `startup` and `trigger` from each granting scenario's region, and
`conversion`, which is a placeholder closed by `UnitRules` until that logic is real.

That is the same shape `TechRules` already uses when it rules the `Can Build` doors: entrances
admit, locations refine.

**A unit only a grant can supply is still a check, under `all`.** The live case is the Mangudai:
an Attila 1 mercenary muster spawns eighteen of them and no Hun can train one, so its line gets
a region with a trigger entrance and no training entrance at all. Under `unit_line` it is left
out, since an item unlocking a line you cannot train reads oddly.

**Heroes are checks under `all` too** - `Age2HeroData`, one region each, with an entrance per
granting scenario. Attila needs no special case for arriving by trigger in Attila 1 and on the
map in Attila 6; they are simply two entrances. No hero is ever an item.

With the two campaigns the world carries, `include_unique_units: none` gives **24 lines / 47
units**, and `both` gives **28 / 54**. `shuffle_villager` adds its own on top - 2 or 24.

## Game effect

`Unitsanity.xs` loads a per-seed `UnitData.xs` and hides every unit it names, the same
`cSetAttribute` / `cDisabledFlag` idiom `Buildsanity.xs` uses - which both hides a unit from its
building and prevents training it, hotkey included. The struct tracks `locked` itself, because
`xsIsObjectAvailable` reports a hidden-and-locked unit as **available** and must never be the test.

Unhiding clears the flag and, **only when the unit's age is already researched**, re-asserts
`cEnableObject`. Both halves were measured: clearing the flag alone leaves a unit greyed when it was
locked across an age boundary, and asserting the enable before its age hands the unit over an age
early. Because the engine's age-up pass skips anything whose `cDisabledFlag` is set, no
age-advancement rule is needed.

The row a unit carries names the **location its ownership completes** - its own under `all`, its
**line's** under `unit_line` - so every tier of a line shares one check and the check is idempotent.
Detection sums the row's variant ids, because a villager takes a different id per job and a Sicilian
Spearman at the Donjon is a different id from the one at the Barracks.

Five fields are on the wire - `AP_US_MODE`, `AP_US_ITEMS`, `AP_US_VILLAGER`, `AP_US_UNIQUES`,
`AP_US_CAVEMAN` - with mnemonics in `AP_Constants.xs`. `world_version` stays `0.3.0`: unitsanity is
a 0.3.0 feature rather than a new version, and 0.3.0 has not shipped, so adding fields breaks no
compatibility.

**One rule drives all three unit modes.** `rule UnitsanityChecks` enumerates the player's units once
with `xsGetPlayerUnitIds(1, -1)`, runs caveman and profession eviction, and only sends checks on a
tick where the owned count is unchanged and nothing was transformed. That ordering is what stops
`Own Tarkan` firing before caveman has turned the Tarkan into a Militia.

## Interactions

Gates `unitsanity_items`, `include_unique_units` and `caveman`. `shuffle_villager` is independent.

## Tests

`test_unit_pool.py` (pool and region topology), `test_unit_rules.py` (the four entrance kinds and
the per-location rules), `test_unit_data.py` (the generated table), `test_unit_handler.py`
(`units.xsdat`), and `test_unit_item_agreement.py`, which sweeps 27 option combinations and holds
`UnitData.items_for` against `UnitPool.items` - the coupling that nothing else guards.
