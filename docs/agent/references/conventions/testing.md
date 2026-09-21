# Testing conventions

Tests live in `worlds/age2de/test/`. The XS repo has none.

```
python -m pytest worlds/age2de/test
AGEIPELAGO_PATH=/path/to/Ageipelago python -m pytest worlds/age2de/test
```

**Set `AGEIPELAGO_PATH`** to the Ageipelago checkout. Two cross-repo tests default to a hardcoded path
from the original author's machine and are wrapped in `skipUnless`, so without it they pass by not
running.

## Two base classes

- `Age2TestBase(WorldTestBase)` — full generation, for pool and region tests. Mutes logging and clears
  kivy's logger between cases.
- `Age2RuleTestBase(unittest.TestCase)` — drives `generate_early → create_regions → create_items →
  set_rules` by hand and skips fill. Helpers: `state_without`, `can_reach`, `item_requirements`. Its
  docstring records why a `CollectionState` must `sweep_for_advancements` first.

## Naming and docstrings

Test names are full sentences, not `test_<function>_<case>`:

```
test_the_default_is_unset_with_techsanity_off
test_junk_after_the_name_terminator_survives
test_free_items_releases_orphans_from_a_previous_session
```

Module docstrings record **the bug the test exists for**, not what the code does. `test_xsdat.py`
explains that `write_vector` raised on any call and nothing noticed because nothing called it.

## Test what cannot fail loudly

The suite's real job is the silent-failure classes. Three patterns:

1. **Cross-repo drift** — parse the other repo's source and compare. `test_world_version.py` regexes
   `worldMajor` / `worldMinor` out of `AP.xs` and checks them against `archipelago.json`;
   `test_campaign_bundle.py` round-trips the real campaign bundles byte for byte. Both skip unless the
   checkout is present.
2. **Source-scanning invariants** — `test_mercenaries.py` walks the AST of every file under `rules/`
   and `logic/`, collects each `Age2ItemData.<NAME>` reference, and asserts that set equals the
   mercenaries declared `in_logic=True`. A hand-maintained flag that mirrors code elsewhere needs a
   test like this, because nothing else couples them.
3. **Refactor pinning** — `test_world_version.py` uses `inspect.getsource` to assert `fill_slot_data`
   still reads `self.world_version` and no longer mentions the old field names.

Use `subTest` when iterating fixtures.

## What a new feature needs

If it crosses the wire, pin the layout (`test_mercenary_packet.py` pins the 49-int header and
`scenario_id` at byte offset 72). If it has a hand-maintained mirror of something else, add a scanning
test. If it writes a file the game reads, assert the exact bytes.
