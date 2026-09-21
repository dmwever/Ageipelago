# `shuffle_ages`

## What the player sets

`ShuffleAges(Toggle)`, display name "Shuffle Ages". Off by default.

> Shuffles the ability to advance to the Feudal, Castle and Imperial Ages into the item pool.
> Reaching each age is its own check. Advancing still costs resources and still requires the
> usual buildings; the item only permits it. A scenario that starts above the Dark Age keeps
> the ages it starts with.

## Generation effect

`create_regions` computes `world.shuffled_ages`: the ages in `SHUFFLED_AGES` (Feudal, Castle, Imperial
— Dark has no item) above `earliest_age`, or all three when `existing_techs` is `start_in_dark_age`.
**That list is computed whether or not the option is on**; the option decides whether age *locations*
are created in "Can Build".

`create_items` pools an age item when the option is on and the age is in `shuffled_ages`, else
precollects it. `AgeLogic.has_age` returns `True_()` unless both conditions hold. `AgeRules.set_rules`
is a no-op when the option is off.

## Game effect

XS constant **`AP_SHUFFLE_AGES`**, default `0` in `DEFAULTS` — deliberately not `UNSET`, so a seedless
install reads as off rather than as a valid mode.

`Ages.xs::InitAges()` always calls `SetScenarioAge()` first, then returns immediately unless the
constant is 1. When shuffling, it registers a location per age, disables the three age-up techs, and
enables `ShuffleAgesUpdate`, which polls their state and self-disables once all three are reached.

## Interactions

`existing_techs == start_in_dark_age` makes every age shuffleable by rebasing every scenario to Dark.
Age reachability also gates most tech rules.

## Tests

`test_shuffle_ages.py` (the largest single-option suite), `test_tech_options.py::TestShuffledAges*`,
`test_slot_data_wire.py`, `test_campaign_bundle.py::TestSlotDataFile`.
