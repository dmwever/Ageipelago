# `include_unique_units`

Which civilization-restricted units join the pool.

## What the player sets

`IncludeUniqueUnits(Choice)`, display name "Include Unique Units". `option_none = 0` (default),
`option_unique = 1`, `option_regional = 2`, `option_both = 3`.

> Which civilization-restricted units join the pool. Requires Unitsanity.
> None: Only units every civilization can train are shuffled.
> Unique: Also shuffle units one civilization has, e.g. the Tarkan or the Longboat.
> Regional: Also shuffle units a handful of civilizations share, e.g. the Eagle, Camel and
> Steppe Lancer lines.
> Both: Shuffle unique and regional units alike.

The unique/regional split is the game's own, read from `Age2UnitData.unit_type` - `UniqueUnit` and
`RegionalUnit` come straight from the civilization tech trees. Regional units behave much more like
generic ones in logic, since several civilizations share them, which is why they can be included
separately.

## Generation effect

`UnitPool.is_unit_type_included` reads `Age2UnitData.unit_type`, so `unique` admits
`UniqueUnit` and `regional` admits `RegionalUnit`; a unit every civilization trains is never
held back. `CIV_TO_UNITS` is applied first, so a civilization never sees another's unique even
under `both`.

With Huns and Franks, `none` gives 24 lines / 47 units and `both` gives 28 / 54 - the four
added lines are the Tarkan, Throwing Axeman, Mounted Crossbowman and Dromon.

## Game effect

None, directly. This option decides which units get rows in the generated `UnitData.xs`, and the
game locks and checks whatever it is given - it never reads `AP_US_UNIQUES` to make a decision of
its own. The constant is on the wire for completeness.

## Interactions

Requires `unitsanity`. Whatever this admits, a unit is still only obtainable while playing a
civilization that has it - with Huns and Franks the two civilizations in play, that means the Tarkan
and Throwing Axeman lines, and the Mounted Crossbowman line the Franks gained.

## Tests

`test_unit_pool.py` sweeps the four values and checks what each admits. `test_unit_data.py` refuses
a unit location no civilisation in the seed can field, which is how an over-admitting setting would
surface - loudly at `/install` rather than as a silent unreachable location.
