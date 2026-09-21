# `lock_techs`

## What the player sets

`LockTechs(Choice)`, display name "Lock Techs". `option_items = 0` (default), `option_effects = 1`.
Requires techsanity.

> What a shuffled technology's item unlocks. Requires Techsanity.
> Items: The technology is hidden until its item arrives.
> Effects: The technology is always researchable, but researching it does nothing until its item
> arrives. Researching still sends the check, so no check is ever locked behind its own item.

## Generation effect

`TechLogic.has_tech_items(tech)` returns `True_()` under `option_effects`, so the location needs no
item, only age reachability. Under `option_items` it requires `Has(tech.item.item_name)` plus the
prerequisite chain.

## Game effect

XS constant **`AP_TS_LOCK`**, default `UNSET`. Used in four places in `Techsanity.xs`, all testing
`== LOCK_ITEMS`:

- `initTech` disables the tech at scenario load
- `UnlockTech` discounts a vanilla-granted tech at startup, and reveals it
- `TechsanityUpdate` re-reveals owned techs each sweep

`LOCK_EFFECTS` is never compared; it is the implicit else, which leaves the tech enabled and
researchable while its effect stays stripped.

## Interactions

Interacts with `existing_techs` through `grantedByVanilla` and `discountTech` in `UnlockTech`.

## Tests

`test_tech_rules.py::TestLockTechs`: effects mode asks for no tech item but still asks for the age.
