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

**Independent of `unitsanity`** - the only unit option that is. The game does not draw the
distinction, though: `SlotData.options()` promotes `AP_US_MODE` to `unit_line` when the villager is
shuffled and unitsanity is `none`, so the game asks one question, "is unitsanity on", and villagers
are just another thing it shuffles.

## Generation effect

The villager is **not** in the unitsanity pool - `UnitPool.includes` refuses it outright, so this
option owns it and the two cannot both claim the same location.

| | locations | items |
|---|---|---|
| `no` | 0 | 0 |
| `yes` | **2** | 1 |
| `include_professions` | **24** | **12** |

`yes` gives `Own Villager (Male) Line` and `Own Villager (Female) Line`. **Two, not one**, because
`VILLAGER_LINE` was split into `VILLAGER_MALE_LINE` (816) and `VILLAGER_FEMALE_LINE` (933) when
professions became items - with one unit per line there is no single entity left to check. Both
lines point at the **same** `Villager Line` item, so the split costs no items.

`include_professions` splits those lines the way `unitsanity: all` splits a unit line, and splits
by sex as well as by job: the two idle villagers become checks of their own, and each job is a check
per sex. The line locations are gone, not kept alongside. Splitting by sex costs nothing, because
the game already draws it - a female farmer and a male one are different unit ids.

Twelve jobs, so twenty-four members of `Age2VillagerJobData` - but **twenty-two job locations in a
Huns and Franks seed**, because the **Herder** works a Pasture and only the Gurjaras build one.
`UnitPool.job_possible` drops a job no civilisation in the seed can do, which is a pool question
rather than a logic one: a location belongs in the pool when somebody can reach it.

### The items

`Villager Line` is pooled in **every** `unitsanity_items` mode, because the villager carries no
upgrade tokens and letting the Town Center count as a producing building would put a
`Town Center Units` item in a seed shuffling no units. `UnitData.items_for` answers that before it
consults the mode at all, and `test_unit_item_agreement.py` holds the two sides together.

`include_professions` adds **one item per job, shared by both sexes** - `Lumberjack`, `Farmer`,
`Shepherd` and so on, ids 700-711. Eleven reach a Huns and Franks seed, the Herder being absent for
the same reason its locations are. The item name is the bare job name, and the pool deduplicates:
iterating the enum and appending `job.item` per member would pool every profession twice.

All the locations sit in the **Town Center** region, and they take that placement from the male
villager: `VILLAGER_FEMALE.buildings` is empty, because she is not separately trainable and no tech
tree names her. `UnitPool.root_unit_data` does the redirect; reading each location's own producing
building would silently drop half of them, and did once.

## Game effect

`Professions.xs`. A villager takes a different unit id for every job - 27 in all, two idle forms,
twelve jobs in both sexes, and the relic carrier - and those ids are a **task swap group**, unit
attribute 190 (`cTaskSwapGroup`). Group 1 holds the 14 male forms, group 2 the 13 female, and the
base villager is in the group alongside the jobs.

So a locked profession is one **stripped from its swap group**:

    xsEffectAmount(cSetAttribute, typeId, cTaskSwapGroup, 0.0, 1)

and its item puts it back. Measured in game: removal blocks the job, per sex, and re-adding restores
it. **The base villager, 83 and 293, is never touched** - pull that out and no villager can swap into
anything.

Two findings shaped the implementation:

- **Removing a form freezes whoever is standing in it.** A villager that was a Lumberjack when the
  form left the group stays a Lumberjack through building and fighting, and can never become
  anything else for the rest of the scenario. That is a gameplay fault, not just bookkeeping.
- **A granted villager can arrive mid-job, and the scenario binary does not say so.** Attila 1 places
  every villager as a base form under player 2; Bleda's side tasks them to chop and mine at runtime,
  before the handover. Reading the binaries - how the startup units and trigger grants were derived -
  would miss it entirely.

Together those force **evict-first**: `EvictProfessions` removes any villager standing in a locked
form and recreates it as the base villager. Eviction is once per unit, so it costs nothing after the
first pass. The swap-group assertion is event-driven, from init and from `GiveItem`.

Counting is the other half. `xsGetObjectCount(1, 83)` counts only **idle** villagers, so
`countOwned` sums the row's variants. `UnitVariants` holds an assert that every job id is a form the
villager actually takes; it exists because the two tables drifted once and the fisherman ids, 56 and
57, were missing - a villager out fishing counted as no villager at all.

**Relic carrying is deliberately not a job.** It is the one form with no female counterpart, and it
would have given the location "Own Monastery" next to the building's "Build Monastery".

## Interactions

`include_professions` leans on the building logic that already exists: a Farm requires a Mill, so
under `shuffle_buildings` those checks sit behind both items. `can_do_job_anywhere` ends
`& has_profession_item(job)`, which is `True_()` unless this option is `include_professions`.

Profession rows are `cavemanExempt` in the generated table, which matters more than it looks: their
type ids are villager variants, so without the flag `findUnit` would succeed and caveman would start
transforming farmers.

## Tests

`test_unit_pool.py` - `test_shuffle_villager_owns_the_villager_and_unitsanity_never_touches_it`,
`test_yes_checks_the_line_and_professions_split_it_by_sex`,
`test_professions_are_evenly_split_between_the_sexes`, `test_both_sexes_of_a_job_share_one_item`,
`test_the_villager_is_a_line_item_in_every_mode`,
`test_villager_locations_live_in_the_villager_line_region`.

`test_unit_rules.py` - `test_both_sexes_of_a_job_ask_the_same_thing`,
`test_the_resource_jobs_are_free_unless_a_scenario_says_otherwise`.

`test_unit_item_agreement.py` - `test_its_line_item_gates_it_in_every_item_mode`,
`test_villager_off_reports_none`, and the 27-combination sweep that caught the installer refusing
`include_professions` outright.
