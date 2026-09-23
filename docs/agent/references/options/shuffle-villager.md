# `shuffle_villager`

Whether the villager is part of the shuffle, and how finely.

## What the player sets

`ShuffleVillager(Choice)`, display name "Shuffle Villager". `option_no = 0` (default),
`option_yes = 1`, `option_include_professions = 2`.

> Whether the villager is shuffled. Independent of Unitsanity.
> No: Villagers behave as vanilla.
> Yes: The villager is an item and a location.
> Include Professions: Each job a villager can do is its own location, per sex, because the game
> gives a villager a different unit for every task. These are not free checks: a Farmer needs a
> Farm, which needs a Mill, and a Gold Miner needs a Mining Camp.

**Independent of `unitsanity`** - the only unit option that is.

## Generation effect

The villager is **not** part of the unitsanity pool at all - `UnitPool.includes` refuses it
outright, so this option owns it and the two cannot both claim the same location.

`yes` makes **one** location, the Villager line.

`include_professions` splits that line the way `unitsanity: all` splits a unit line, and it
splits it **by sex as well as by job**: the two idle villagers become checks of their own, and
each of the twelve jobs is a check per sex. **Twenty-six locations, thirteen each.** The line
location is gone, not kept alongside. Splitting by sex costs nothing, because the game already
draws the distinction - there is a separate unit id for a female farmer and a male one.

However many locations it makes, it is **one item**: `Villager Line`, whatever
`unitsanity_items` says. The villager carries no upgrade tokens, and letting the Town Center
count as a producing building would put a `Town Center Units` item in a seed shuffling no units.

All twenty-six sit in the **Town Center** region, and they have to take that placement from the
male villager: `VILLAGER_FEMALE.buildings` is empty, because she is not separately trainable and
so no tech tree names her. Reading each location's own producing building would silently drop
half of them.

## Game effect

None yet, but the game-side consequence is already known and is the reason this option can exist at
all: **a villager takes a different unit id for every job it does**, 27 in total - two idle forms,
twelve jobs in both sexes, and the relic carrier. `UnitVariants` records them against
`VILLAGER_MALE` and `VILLAGER_FEMALE`. Counting only the base id counts idle villagers alone, so
under `no` and `yes` the ids must be summed, and under `include_professions` they are what makes
each job separately observable.

`Age2VillagerJobData` names the twelve jobs, and an assert in `UnitVariants` holds every job id to
be a form the villager actually takes. That assert exists because the two tables drifted once: the
fisherman ids, 56 and 57, were missing from the variant lists, so a villager out fishing counted as
no villager at all. **Relic carrying is deliberately not a job** - it is the one form with no
female counterpart, and carrying a relic is not work.

## Interactions

`include_professions` leans on the building logic that already exists: a Farm requires a Mill, so
under `shuffle_buildings` those checks sit behind both items.

## Tests

None yet.
