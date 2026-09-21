# `existing_techs`

The most cross-cutting option in the world. Requires techsanity.

## What the player sets

`ExistingTechs(Choice)`, display name "Existing Techs". `option_vanilla = 0` (default),
`option_find_items = 1`, `option_only_find_units = 2`, `option_start_in_dark_age = 3`.

> What happens to the technologies a scenario would normally start with. Requires Techsanity.
> Vanilla: A scenario starting in the Castle Age keeps every Dark and Feudal Age technology.
> Find Items: A technology the scenario would have started with is not applied on scenario start
> until the item is found. Once found, the tech costs nothing to research for its check.
> Only Find Units: Same as Find Items, but only units are hidden.
> Start In Dark Age: Every scenario opens in the Dark Age with nothing researched at all, ages
> included, so even the age-ups have to be earned back.

## Generation effect

- `TechPool.locked_at_start()` withholds always under `find_items` and `start_in_dark_age`, withholds
  only unit techs under `only_find_units`, and never under `vanilla`.
- `TechPool.reachable()` treats a locked-at-start tech as always reachable; otherwise it must be at or
  above `earliest_age`, since a scenario would auto-research it before any check exists.
- `create_regions` makes every age eligible for shuffling under `start_in_dark_age`, not just those
  above `earliest_age`.
- `TechLogic.can_research()` requires `can_reach_age` for a locked-at-start tech above its building's
  opening age.
- `InstallHandler` treats anything but `vanilla` as a rebase, which decides whether `/install` rewrites
  a scenario through `ScenarioParser.rebase_to_dark`. Under `start_in_dark_age`, `grant_age()` returns
  `None`, so nothing is granted back.

## Game effect

XS constant **`AP_TS_EXISTING`**, default `UNSET`. Consumed in
`Techsanity.xs::reconstructStartingState()`: return immediately under `EXISTING_START_IN_DARK_AGE`
(grant nothing); otherwise complete the vanilla age-up techs up to the scenario's vanilla age and grant
each lower tech the civ can research, except those withheld by `EXISTING_FIND_ITEMS` (location techs)
or `EXISTING_ONLY_FIND_UNITS` (upgrades).

`EXISTING_VANILLA` is never compared; it is the implicit default that grants everything.

## Interactions

Touches `shuffle_ages` (rebasing), `lock_techs` (the startup discount), `/install`'s scenario
rewriting, and each scenario's hardcoded `SetVanillaAge(...)` call.

## Tests

`test_tech_pool.py::TestScenarioReachability`, `test_tech_rules.py::TestExistingTechs`,
`test_tech_options.py`, `test_shuffle_ages.py` (dark-age rebase), `test_installer.py::TestTechInstall`.
