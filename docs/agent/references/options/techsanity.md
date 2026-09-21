# `techsanity`

The gate for the whole technology feature. The other four tech options do nothing while this is `none`.

## What the player sets

`Techsanity(Choice)`, display name "Techsanity". `option_none = 0` (default), `option_units = 1`,
`option_generic = 2`, `option_all = 3`.

> Shuffles technologies. Researching a shuffled technology sends its check, and its item is what
> makes the technology available.
> None: Technologies behave as vanilla.
> Units: Only unit-line upgrades are shuffled, e.g. Man-At-Arms, Crossbowman, Elite Skirmisher.
> Generic: Every other technology is shuffled, e.g. Loom, Fletching, Wheelbarrow.
> All: Both.

## Generation effect

`TechPool.MODE_TO_OPTION` maps `units` to `TechOption.units`, `generic` to `TechOption.generic`, and
both `none` and `all` to no filter. `TechPool.includes()` returns `False` outright when the mode is
`none`.

`create_regions` builds a region per tech-capable building and a location per included tech.
`TechRules.set_rules` returns immediately when the mode is `none`.

## Game effect

XS constant **`AP_TS_MODE`**, the one techsanity default that is a real `0` rather than `UNSET`.

`Techsanity.xs::InitTechsanity()` returns immediately when it equals `TECHSANITY_NONE`, disabling the
entire subsystem: struct setup, the tech table, starting-state reconstruction and the polling rule.

**The game never distinguishes units from generic from all.** `TECHSANITY_UNITS`, `TECHSANITY_GENERIC`
and `TECHSANITY_ALL` exist in `AP_Constants.xs` but are never compared. That is deliberate: the
apworld's `TechPool` decides which techs exist as locations, so the game only needs on or off.

## Interactions

Gates `tech_behavior`, `lock_techs`, `shuffle_unique_techs` and `existing_techs`. Their slot_data
values are written regardless.

## Tests

`test_tech_pool.py`, `test_tech_options.py`, `test_installer.py::TestTechInstall`,
`test_slot_data_wire.py`.
