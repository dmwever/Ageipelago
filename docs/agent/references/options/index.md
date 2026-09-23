# Player options

Eighteen fields on `Age2Options` in `worlds/age2de/Options.py`. One file here per option.

**The yaml key is the dataclass field name** on `Age2Options` — not `display_name`, and not the
world's own `internal_name` attribute, which is not core Archipelago API and exists only so
`SlotData.OPTIONS` can name an option.

For any option wired into slot_data, `internal_name` **must equal the field name**: `fill_slot_data`
does `getattr(self.options, option_name)` with the internal name. All six currently match.

## Master table

| File | yaml key | Type | Default | slot_data | XS constant |
|---|---|---|---|---|---|
| [goal](goal.md) | `goal` | Choice | campaign_completion | — | — |
| [scenario-branching](scenario-branching.md) | `scenario_branching` | Choice | any | — | — |
| [local-start](local-start.md) | `local_start` | Choice | no | — | — |
| [shuffle-buildings](shuffle-buildings.md) | `shuffle_buildings` | OptionSet | Economy, Tech, Military | — | — |
| [starting-campaigns](starting-campaigns.md) | `starting_campaigns` | OptionSet | Attila the Hun | `<campaign>_unlocked` | — |
| [enabled-campaigns](enabled-campaigns.md) | `enabled_campaigns` | OptionSet | Attila the Hun | `<campaign>_unlocked` | — |
| [shuffle-ages](shuffle-ages.md) | `shuffle_ages` | Toggle | off | yes | `AP_SHUFFLE_AGES` |
| [techsanity](techsanity.md) | `techsanity` | Choice | none | yes | `AP_TS_MODE` |
| [tech-behavior](tech-behavior.md) | `tech_behavior` | Choice | must_research | yes | `AP_TS_BEHAVIOR` |
| [lock-techs](lock-techs.md) | `lock_techs` | Choice | items | yes | `AP_TS_LOCK` |
| [shuffle-unique-techs](shuffle-unique-techs.md) | `shuffle_unique_techs` | Choice | unshuffled | yes | `AP_TS_UNIQUES` |
| [existing-techs](existing-techs.md) | `existing_techs` | Choice | vanilla | yes | `AP_TS_EXISTING` |
| [unitsanity](unitsanity.md) | `unitsanity` | Choice | none | not yet | not yet |
| [unitsanity-items](unitsanity-items.md) | `unitsanity_items` | Choice | unit_line | not yet | not yet |
| [shuffle-villager](shuffle-villager.md) | `shuffle_villager` | Choice | no | not yet | not yet |
| [include-unique-units](include-unique-units.md) | `include_unique_units` | Choice | none | not yet | not yet |
| [caveman](caveman.md) | `caveman` | Toggle | off | not yet | not yet |
| [start-inventory-pool](start-inventory-pool.md) | `startInventoryPool` | core AP | — | — | — |

Only six options reach the game. The rest are generation-only: they shape the item pool, the location
set and the rules, and the game never learns about them.

## At defaults

```yaml
Age Of Empires II: Definitive Edition:
  goal: campaign_completion
  scenario_branching: any
  local_start: no
  shuffle_buildings: [Economy, Tech, Military]
  enabled_campaigns: [Attila the Hun]
  starting_campaigns: [Attila the Hun]
  shuffle_ages: false
  techsanity: none
  tech_behavior: must_research
  lock_techs: items
  shuffle_unique_techs: unshuffled
  existing_techs: vanilla
  unitsanity: none
  unitsanity_items: unit_line
  shuffle_villager: no
  include_unique_units: none
  caveman: false
```

`startInventoryPool` is core Archipelago's and takes its usual form. Note `startInventoryPool` is the
one camelCase key, because it comes from core AP rather than this world.

## Defaults on the wire

`SlotData.DEFAULTS` is what a seedless install reads. `AP_SLOT_ID`, `AP_SEED_HIGH` and `AP_SEED_LOW`
default to `UNSET` (-1), and so do `AP_TS_BEHAVIOR`, `AP_TS_LOCK`, `AP_TS_UNIQUES` and
`AP_TS_EXISTING`. But `AP_TS_MODE` and `AP_SHUFFLE_AGES` default to a real `0` — deliberately, so an
install that `/install` has never touched reads as "off" rather than as a valid mode.

## Interaction map

- `unitsanity` gates `unitsanity_items`, `include_unique_units` and `caveman`.
  `shuffle_villager` is independent of it.
- The five unit options are **generation-only for now**: none is in `SlotData.OPTIONS`, so the
  slot_data shape is unchanged and `world_version` stays `0.3.0`. Unitsanity is a 0.3.0
  feature, not a new version. They join the wire in Phase 13, with the XS constants.

- `enabled_campaigns` decides what exists; `starting_campaigns` decides what begins unlocked. The
  second must name at least one of the first.
- `techsanity` gates `tech_behavior`, `lock_techs`, `shuffle_unique_techs` and `existing_techs`
  entirely. Their slot_data values are written regardless of whether techsanity is on.
- `existing_techs = start_in_dark_age` rebases every scenario, which makes every age eligible for
  `shuffle_ages` and changes what `/install` writes.
- `local_start` depends on `starting_campaigns` and, through the rule graph, on everything else.
- `shuffle_buildings`'s Unique bucket depends on which civs the enabled campaigns bring in.

## OptionErrors

All raised from `worlds/age2de/__init__.py`:

| Trigger | Where |
|---|---|
| `enabled_campaigns` empty | `generate_early` |
| `starting_campaigns` empty | `generate_early` |
| `starting_campaigns` names no enabled campaign | `generate_early` |
| the player name sanitizes to nothing | `check_installable_name` |
| an included campaign has no scenarios | `create_regions` — currently unreachable |

## Two to know before reading further

`goal` has a single value, so it never varies. `tech_behavior` has no Python-side logic at all — it is
a pure pass-through to XS. Neither is an oversight; do not hunt for the missing branch.
