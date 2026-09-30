# `unitsanity_items`

What a unitsanity item actually is. Three different economies over the same locations.

## What the player sets

`UnitsanityItems(Choice)`, display name "Unitsanity Items". `option_unit_line = 0` (default),
`option_upgrades = 1`, `option_buildings = 2`.

> What a unitsanity item is. Requires Unitsanity.
> Unit Line: One item per line, e.g. Militia Line, Archer Line.
> Upgrades: Units need the equipment they are known for, so a Knight wants a Horse, a Sword and
> a Shield while an Archer only wants a Bow. A unit becomes trainable once it has all of its own.
> Buildings: One item per producing building, e.g. Barracks Units, Archery Range Units.

The three modes differ wildly in pool size: 135 line items, a couple of dozen equipment tokens, or
11 building items. `Upgrades` is the only mode whose items are not derived from the game data - the
equipment each unit needs is a design decision, not something the dat records.

## Generation effect

All three modes' items exist in `Age2ItemData` at once, the way buildings and techs do; the
option picks which get pooled. The `Units` band is carved up to hold them:

| ids | items | n |
|---|---|---|
| 300 - 499 | `UNIT_LINE_*`, one per `Age2UnitLineData` member | 132 |
| 500 - 599 | `UPGRADE_*`, the equipment vocabulary | 26 |
| 600 - 699 | `BUILDING_UNITS_*`, one per producing building | 11 |

`Age2UnitLineData` gained an `.item` field, mirroring `Age2BuildingData` and `Age2TechData`.

133 lines share 132 items: `VILLAGER_MALE_LINE` and `VILLAGER_FEMALE_LINE` both point at the one
`Villager Line` item, which is what kept the villager split from costing an item. A fourth band,
**700 - 799**, holds the twelve `PROFESSION_*` items and belongs to `shuffle_villager` rather than
to this option - `UNIT_ITEM_SPAN` is 500 so all four sit inside `GiveItem`'s single unit branch.

## The equipment vocabulary

Twenty-six tokens: club, sword, shield, spear, bow, gun, sling, elephant, horse, gunpowder,
bolas, camel, torch, siegeworks, stone, rocket, bolt, cannon, bible, axe, cart, boat, chakram,
dart, mace, whip.
`gun` is a handheld firearm, `cannon` is artillery, and `gunpowder` is the propellant both need -
so a Hand Cannoneer wants `gun` + `gunpowder` and a Bombard Cannon `siegeworks` + `cannon` +
`gunpowder`.

`locations/connections/UnitUpgradeTokens.py` binds `Age2UnitData.upgrade_tokens`. Two things
about it are load-bearing:

- **Tokens attach per unit, not per line.** A Militia needs a Club; a Man-at-Arms needs that Club
  plus a Sword and a Shield.
- **They accumulate down a line.** A tier that adds nothing carries its predecessor's set and is
  gated by its upgrade technology alone - which is every Elite tier, and Long Swordsman through
  Champion.

Scope is the 119 lines an Age of Empires II civilisation can train, 229 units. The villager is
the one trainable unit with no tokens, because `shuffle_villager` governs it separately; an
import-time assert holds that line.

One row is deliberately not the whole truth: a **trade cart wants `cart` and `horse`**, but a
meso-american civilisation has no horses and still trains them. The table states the general
case and the exception lives in `can_train_unit`, the way `CIV_TO_UNITS` rather than this file
decides what a civilisation may train. Neither Huns nor Franks are affected.

## Game effect

**None, directly** - and that is the design. `/install` resolves each unit's requirement to a list of
item ids at generation time and writes them into `UnitData.xs` as `addUnitItem` calls, so
`Unitsanity.xs` never branches on this option: it only ever asks whether the ids a row lists have
arrived. `GiveItem` covers all four bands in one branch for the same reason.

A row with no items is unlocked at init, which is why `refreshUnitLocks` runs once there as well as
on receipt.

## Interactions

Requires `unitsanity`. Under `buildings`, `BUILDING_TO_UNITS` is the grouping, and a unit trained at
two buildings - a Donjon spearman, a Stable Tarkan - appears under both.

## Tests

`test_unit_data.py` resolves each of the three modes to the right ids and refuses a unit needing
more than `MAX_ITEMS`. `test_unit_item_agreement.py` holds `items_for` against `UnitPool.items`
across every option combination - it caught the Spearman waiting on `Donjon Units` in a seed no
civilisation builds a Donjon for, and the villager being gated by nothing under `upgrades`.
