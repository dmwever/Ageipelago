# `caveman`

Every unit you are handed is dragged down to what you have actually unlocked.

## What the player sets

`Caveman(Toggle)`, display name "Caveman". Off by default.

> Every unit you are handed is downgraded until you find what it needs. Requires Unitsanity.
> A unit you did not train becomes the best tier of its own line you have unlocked, or a Militia
> if you have unlocked none of it, and climbs back as the line's items arrive - but never past
> what it started as. Units you trained yourself are untouched, as are villagers, heroes and
> mercenaries. Adapts to Techsanity, since an upgrade you have not researched is not unlocked.

## The rule

Each affected unit carries a **ceiling** - what it was before being downgraded:

    target = lineHasAnyUnlockedTier(line(original))
               ? min(highestUnlockedTier(line(original)), originalTier)
               : MILITIA

Downgrade and restore are the same computation at different times. An entry is **retired** once its
unit reaches its ceiling, so a later ordinary tech upgrade may carry it further.

A unit the player trained is never tracked, which is what makes the awkward case fall out for free:
train a second Knight after unlocking the line and it does **not** follow the first to Cavalier -
it upgrades only when Cavalier is researched, like any normal unit. The implementation gets this
without a special case, by treating an **untracked unit's current type as its own ceiling**: a
Knight you trained has ceiling Knight, so the sweep is a no-op on it.

## Generation effect

Caveman narrows how a unit can be owned. `can_own_anywhere` is:

    can_train | (is_granted & (NOT_CAVEMAN | can_restore)) | can_convert

with `NOT_CAVEMAN = OptionFilter(Caveman, Caveman.option_false)`. Being handed a unit is no longer
enough on its own, because what you are handed is immediately downgraded.

**But a granted unit is still ownable** - it just needs its own item first. Caveman turns a granted
Mangudai into a Militia and finding the Mangudai's item turns it back, so the rule is item-gated
rather than trainability-gated:

    can_restore(unit) = has_unit_items(unit)
                        & logic.techs.has_tech_item(unit.upgrade_tech)

`has_tech_item` rather than `has_tech`, deliberately: caveman cares that the technology **item**
arrived, not that it is researched, instant or age-appropriate.

That forces one change in the pool. A line no included civilisation can train normally pools no
item - there is no building to unlock it at - but under caveman that item is the only way to restore
a granted unit, so `UnitPool.items` pools it when caveman is on. Without it, `unit_line` + caveman
left `Own Mangudai` with a rule no item could satisfy.

Caveman also **forces the dark-age rebase**. `scenario_needs_age_up()` returns true whenever caveman
is on, independent of techsanity, so `/install` rebases the scenario to the Dark Age and XS climbs
back - see below.

## Game effect

`Caveman.xs`, driven entirely by `rule UnitsanityChecks` in `Unitsanity.xs`.

**The ledger** is two parallel int arrays keyed by unit id, capacity 400, `MercenaryLedger.xs`'s
shape. It has to be a ledger rather than a field on the `Unit` struct, because that struct is per
**type** and caveman is per **instance**. XS state survives a save and reload, so it needs no
persistence through the client.

**A transform is `xsRemoveUnit` + `xsCreateUnit`.** There is no per-instance type change exposed to
XS - the engine has `cUpgradeUnit` (player-wide, which cannot express this) and `cGaiaUpgradeUnit`,
and no `cReplaceObject`. Position carries across; garrison, orders, veterancy and hit points do not.
The unit id **changes**, so the ledger key is rewritten on every transform.

**The removed id is tombstoned, not released.** `transformUnit` writes `CAVEMAN_REMOVED` into the
ledger for the old id and `ApplyCaveman` skips anything carrying it, reaped by `removeDeadCavemen`
once `xsDoesUnitExist` agrees. Without it, a removed unit re-enumerated before the engine retires it
looks untracked and is downgraded a second time - which showed up in play as cavemen doubling on the
way down and never on the way back, since a leftover Militia is already at its target.

**Militia is hardcoded**, `CAVEMAN_MILITIA = 74`, and the dark-age rebase is what makes it honest.
The engine applies researched upgrades to anything you create, so in a Feudal scenario
`xsCreateUnit(74, ...)` hands back a Man-at-Arms - and the sweep then loops, recomputing 74 forever.
`ClimbToVanillaAge()` in `Ages.xs` restores the age after the rebase while
`reconstructStartingState` withholds **every** unit upgrade under caveman:

    if (AP_US_CAVEMAN == 1 && structGetBool(tech, "isUpgrade")) {
        grant = false;
    }

Withholding all upgrades rather than the militia line specifically needs no new data - the unit
table does not exist yet at `InitTechsanity` time - and is truer to the feature. The Militia line
still turns out Militia, being tier 0 with no upgrade tech.

**Exemption is a struct field**, `Unit.cavemanExempt`, set by the installer rather than kept as a
hand-written list in XS. Heroes, escorts and villager jobs are emitted as rows so their locations
reach the game at all, and the flag is what stops `findUnit` succeeding on them and caveman
transforming Attila. `is_caveman_exempt` knows only about the villager line, so a future
non-cavemanable line needs a line there.

**Variant ids resolve to their canonical unit.** `canonicalTypeOf` maps a Stable Tarkan (886) to the
Castle Tarkan (755) before the sweep looks at it, so a unit trained at its alternate building is
downgraded and restored as its row - and is no longer invisible to caveman while still completing
its line's check, which `countOwned` summing variants had made possible.

**Techsanity adaptation is item-only.** `tierUnlocked` is the unitsanity lock, and then - only when
`AP_TS_MODE != TECHSANITY_NONE` - whether the tier's upgrade technology **item** has arrived, read
off the Tech struct's `hasItem` through the existing `techByItem` index.

**Mercenaries split by how they arrive.** A **scenario** mercenary item releases map-escrowed units
handed over by an `AP Give ...` trigger; those are ordinary units and caveman treats them so. A
**pavilion** mercenary is spawned fresh by `MercenarySpawn.SpawnNextSoldier`, which calls
`MarkCavemanImmune(created)`. So immunity is **per unit id, never per type** - the same Tarkan type
arrives both ways.

`CavemanExemption()` is a per-scenario `mutable` no-arg hook beside the other three stubs, for a
scenario that must spare a unit type that is in the table. It has no users today.

## Interactions

Requires `unitsanity`. Adapts to `techsanity`. Forces the dark-age rebase, so it changes what
`/install` writes even with `existing_techs: vanilla`.

Villagers, heroes, escorts and villager jobs are exempt through `cavemanExempt`; animals and map
scenery never enter the unit table at all, so they need no rule. Queue-spawned mercenaries are
exempt by id.

## Tests

`test_installer.py` - `test_caveman_rebases_on_its_own`,
`test_caveman_rebases_where_vanilla_techs_would_not`.

`test_unit_pool.py` and `test_unit_rules.py` cover the narrowed `can_own` and the granted-line item,
verified across all six combinations of the three item modes and caveman on/off with zero
unreachable locations.

**Nothing tests the XS half**, which is where every caveman bug of Phase 14 lived - four of them,
all found in play and none visible to `xs-check`.
