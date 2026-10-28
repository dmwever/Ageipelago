---
name: ageipelago
description: >
  The Ageipelago / age2de Age of Empires II: DE Archipelago randomizer — a paired
  XS game mod and Python apworld that talk over binary .xsdat files.
  Use this whenever the task touches either half: Ageipelago, age2de, apworld,
  .xsdat, AP.xs, ItemHandler, Buildsanity, Techsanity, Unitsanity, mercenary seats,
  the AP pavilion or APavilion, SlotData.xs, TechData.xs, AP_Check_Location,
  AddLocations, the Attila or Joan scenario scripts, /install, /set_user_folder,
  /mercenaries, /scenarios, seed tags, Age2World, Age2ItemData, Age2ScenarioData,
  TechPool, LocalStart, rule_builder, Age2PlayerData, defeat rules, or any of the
  yaml options (techsanity, shuffle_ages, existing_techs, shuffle_buildings,
  local_start, market_trade, partner_trade).
  Also use it for questions about how the game and the client communicate, or when
  adding an item, location, scenario, option or packet field to this randomizer.
---

# Ageipelago / age2de

Skill revision: **2026-10-26a**

A randomizer in two halves that ship separately and must stay in step.

> **Age of Empires II has no copy/paste.** Nothing in the game can be selected or copied, not even
> the chat. Never ask the user to copy, paste or transcribe chat output. Any spike, probe or
> diagnostic whose result has to reach you writes it to an `.xsdat` file (`xsCreateFile` …
> `xsCloseFile`), which you then read off disk. `xsChatData` is only for progress and
> pass/fail at a glance. See `references/xs-mod.md` → *Getting data out of the game*.

## Where this lives

The canonical copy is `docs/agent/` in the Ageipelago repo — committed, reviewable, and the version
teammates get when they clone. Treat it as the source of truth.

`docs/agent/` is **not** an auto-discovered skill: Claude Code only loads skills from
`.claude/skills/`. To have it load on a machine, copy the tree there:

```
cp -r <path-to>/Ageipelago/docs/agent/. ~/.claude/skills/ageipelago/
```

That copy is a mirror, not the original. Before relying on it, confirm it has not drifted:

```
diff -rq ~/.claude/skills/ageipelago <path-to>/Ageipelago/docs/agent
```

No output means they match. Any output, or a revision stamp above that differs, means the mirror is
stale: say so before answering, treat `docs/agent/` as correct, and offer to recopy. A missing mirror
is the normal state on a machine where nobody has installed it.

## Where to look

| The question is about | Open |
|---|---|
| an `.xs` file, a rule, a struct, include order, linting, the pavilion, scenario scripts | `references/xs-mod.md` |
| writing a spike, probe or harness, map coordinates, getting a measurement out of the game | `references/xs-mod.md` |
| items, locations, enums, logic vs rules, regions, the client, handlers, generation, tests | `references/apworld.md` |
| a scenario's players, sides, trade access, main opponents, defeat rules | `references/apworld.md` -> *Players and defeats* |
| a scenario's resource counts, tiers, map object ids, gather amounts, terrain | `references/apworld.md` -> *Scenario resource scans* |
| adding a whole campaign, scenario triggers, the AP trigger block, what to ask the user | `references/adding-a-campaign.md` |
| a packet field, byte offsets, the `.xsdat` **packet** layout, seed tags, versioning, the item window | `references/protocol.md` |
| what a yaml option does on either side, or a bug that only shows with one on (caveman, techsanity, …) | `references/options/index.md`, then the one option's file |
| how to write it so it matches the codebase | `references/conventions/index.md` |

Engine-level questions — the exact signature of an `xs*` function, a constant's value, a unit or tech
id, how the tech state machine behaves — are **not** in this skill. They belong to the `aoe2-modding`
skill and its knowledge base. Do not answer them from here.

## Hard rules

1. **The two halves version together.** `archipelago.json`'s `world_version` is the single source of
   truth; `AP.xs` declares `worldMajor`/`worldMinor` and must match on major and minor. A slot_data
   shape change needs a minor bump. A test enforces it, but only when `AGEIPELAGO_PATH` is set.
2. **Never insert a packet field before `ScenarioId`.** It sits at byte offset 72 and
   `find_active_campaign` reaches it with a hardcoded `skip_int(fp, 18)`. New fields come out of the
   reserved block, which is down to 27 ints.
3. **`AP_Constants.xs` is the single home for `extern const`.** XS has no include guards, so the same
   constant in two included files is a build break.
4. **Include order is load-bearing.** `AP.xs` includes `AP_Constants.xs` first and that is what makes
   constants reachable downstream; several files use symbols they never include.
5. **`SlotData.xs` and `TechData.xs` in the repo are stubs.** `/install` writes the real ones per seed.
   Against tracked state, the game never emits a packet and techsanity does nothing.
6. **Struct fields are runtime strings**, case-sensitive, and a typo returns `-1` silently. Grep every
   occurrence before renaming one.
7. **Id bands are duplicated by hand** between `ItemHandler.xs`'s header comment and `items/Items.py`.
   Change both. Two bands in those legends are dead: `30-199` (Civs) and `300-999` (Units) hold no
   `Age2ItemData` member and have no `GiveItem` branch. The `4000-4999` band is labelled "Mercenaries"
   in `ItemHandler.xs` and "Troops, Future Use" in `Items.py` — same range, stale name.
8. **The repo `age 2 files/` IS the live game folder.** They are the same files — verified by
   identical inodes for `AP.xs`, `Buildsanity.xs` and others — so editing the checkout writes
   straight into the game and nothing needs copying. The live path is
   `C:/Users/dmwev/Games/Age of Empires 2 DE/<steamid>/resources/_common/xs/`.
   **A git worktree breaks this**: a worktree is a separate, unlinked copy, so a file created there
   is invisible to the game and the scenario reports *"extern 1 failed to open <name>"*. Work in the
   primary checkout.

9. **Both repos store LF in the index**, and both set `core.autocrlf=true` locally, so working trees
   are CRLF and git normalizes on add. Neither repo has a `.gitattributes` eol rule, so the guarantee
   is that local config, not the repo: on a clone without `autocrlf`, a tool that writes CRLF does
   produce a whole-file diff.
10. **Lint entry points, not libraries.** `./xs-check.exe -I . -- AP_Attila_1.xs`. A library file linted
   alone reports errors for constants it never includes. Both halves of the invocation matter, and
   they fail differently — see the Linting section of `references/xs-mod.md`. Note the linter is
   gitignored and untracked: a fresh clone or worktree has no `xs-check.exe` at all. **Needs v0.2.30
   or later** — earlier preludes predate Update 185872 and report its functions as `NameError`.
11. **Verify before trusting any doc, including these.** `communication_protocol.md` and these
    references have all drifted from the code at least once. The code is the authority.

## Working in these repos

Use a **git worktree with its own branch** for anything non-trivial, and delete the worktree once the
branch is merged. Leftover worktrees are the main way an agent ends up editing dead code that looks
live — a merged worktree still has files on disk and a branch pointer that goes nowhere.

Clean up after experiments. XS spikes go in a throwaway file that `.gitignore` covers, never in a live
module, and get deleted once the answer is known. The same goes for one-off Python scripts used to
probe or regenerate something. `__pycache__` outlives the source that produced it, in both repos —
`Archipelago/worlds/age2de/__pycache__` currently holds bytecode for six top-level modules
(`World`, `Items`, `Locations`, `SlotData`, `Generation`, `Identity`) that no longer exist there, and
a stale `.pyc` is not evidence that a module is still live.

## Cross-repo workflows

Each of these touches both halves. Doing only one side is the usual failure.

### Adding an item

1. Add a member to `Age2ItemData` in `items/Items.py`, in the correct id band. The import-time asserts
   catch a duplicate id or name on any test run.
2. If the payload type is new, add it to `item_type_to_classification` and give `create_items` a branch
   — an unhandled type raises `ValueError`.
3. Decide pooled versus precollected in `create_items`.
4. On the game side, handle the id in `GiveItem`'s band dispatch in `ItemHandler.xs`, and add the case
   to the relevant `switch`. There is no `default`, so an unhandled id vanishes silently.
5. If the band itself changed, update the legend comment in `ItemHandler.xs` and in `items/Items.py`.
6. Client-only items are legitimate — 3000-3599 never reach the game. Say so if that is the intent.

### Adding a location

1. Add a member to `Age2ScenarioLocationData` in that scenario's id block, tagged with the right
   `Age2LocationType`.
2. Wire its rule in the scenario's `*Rules` class — or deliberately leave it unruled, which means the
   scenario's entrance gate is the whole requirement.
3. Extend that scenario's `AddLocations(idStart, idEnd)` range in its `AP_<Campaign>_<n>.xs`. The range
   is inclusive at both ends.
4. Add the wrapper function, `void <Name>() { AP_Check_Location(<id>); }`, in ascending id order.
5. Call that wrapper from the scenario's trigger data — it is in the `.aoe2scenario` binary, not in XS.

### Adding a scenario

1. `locations/Scenarios.py`: the id is derived as `campaign.value * 100 + chapter`, so both must stay
   within 1-99. Set `file_stem`, `xsdat_write_name`, `civ`, `vanilla_age`, `max_age` and
   `fixed_force`.
2. Add its locations to `locations/Locations.py`.
3. Declare its players: an `Age2PlayerData` member in `locations/Players.py` per ally and enemy
   (slot, side, main opponent, market and dock access — ask the user for these), and an entry in
   `locations/connections/ScenarioPlayers.py` (`[]` for a fixed force).
4. Write a `*StartingState` in `logic/`, overriding `defeat_rules` for every player the victory
   rules name and every owner of a market or dock that opens once defeated, and a `*Rules` in
   `rules/` whose victory rules read `scenario_logic.player_logic.defeats(player)`. See *Players and
   defeats* in `references/apworld.md`.
5. **Bind both** in `locations/connections/ScenarioDataLogic.py` and `ScenarioDataRules.py`. A missed
   binding leaves `scenario.rules` as `None`, and `Rules.set_rules()` then calls `None(self)` —
   `TypeError: 'NoneType' object is not callable` at generation.
6. Create `AP_<Campaign>_<n>.xs` from the template in `xs-mod.md`: the stub overrides, `main()`,
   the wrappers, and `SetPavilionLayout()`.
7. Give `SetPavilionLayout()` the pavilion's tile and facing. Spawn and muster are derived from
   them, two and six tiles out along the facing, so there is nothing else to author and no
   tooling to run — `APavilion.xs` creates the building at run time.

### Adding a packet field

1. Take it from the **reserved block**. Never before `ScenarioId`.
2. Write it in `AP_Write` in `AP.xs`, and shrink the reserved loop count to match.
3. Read it in `Age2Packet` in `client/GameClient.py`, and shrink its `skip_int` to match.
4. If it is a client → game flag, add it to `ping_game` and to `AP_Read`'s ordered reads, and arm a
   rule that disables itself on every exit path.
5. Update the table in `docs/communication_protocol.md`.
6. Add a layout test. `test_mercenary_packet.py` is the model: pin the fixed-int count and
   `scenario_id` at byte offset 72.

## Running things

```
# apworld tests, run from the Archipelago root.
# AGEIPELAGO_PATH must point at this repo, or the two cross-repo checks silently skip.
AGEIPELAGO_PATH=/path/to/Ageipelago python -m pytest worlds/age2de/test

# XS lint, from the xs folder. Needs v0.2.30 or later for Update 185872.
./xs-check.exe -I . -- AP_Attila_1.xs
```

### Fuzzing the apworld

[Archipelago-fuzzer](https://github.com/Eijebong/Archipelago-fuzzer) generates random YAMLs and
fills them, many at once. A copy of its `fuzz.py` lives in the Archipelago checkout at
`worlds/age2de/fuzz/fuzz.py`, git-ignored next to the committed meta `age2de.yaml`; copy a new
release over it to update. Run it from that folder:

```
PYTHONHASHSEED=0 PYTHONPATH=../../.. python fuzz.py -r 1000 -j 18 -g age2de -n 1-3 -m age2de.yaml -t 90
```

- `-g` takes the apworld **module** name (`age2de`), not the display name. `-t 90`, not the
  default 15: the largest configurations take 20-50s to fill.
- `-m` is a meta file. An option named there is fixed to that value. `fuzz_constraints` adjust
  what was rolled: `if_selected` + `must_include` / `must_exclude`, `if_value` + `then` /
  `then_include` / `then_exclude`, `if_any_selected` + `requires_any`, `mutually_exclusive`,
  `ensure_any`, and the numeric caps (`max_count_of`, `max_remaining_from`, `sum_cap`). Put
  throwaway metas in `_*.yaml`, which the folder's `.gitignore` covers.
- `--hook module:Class` runs code around each generation (`setup_main`, `setup_worker`,
  `before_generate(args)`, `after_generate(multiworld, output_dir)`, `finalize`). Keep throwaway
  hooks in the ignored `bench/` folder. The vendored copy rejects a hook class that *does*
  subclass `fuzz.BaseHook` (its check is inverted), so write a plain class with those methods.
- `--skip-output` skips writing the multiworld, which is all a fill test needs.
- Failures land in `fuzz_output/error/age2de/<n>/` with the YAMLs and a log carrying `Seed:`.
- **Pairing runs**: two runs only roll the same YAMLs with `PYTHONHASHSEED=0` and a hook that seeds
  `random` in `setup_main` and sets `args.seed` in `before_generate`. Otherwise fuzz rates vary by
  several points between identical runs, so treat a difference under about 3 points as noise.

There is no Python tooling left in this repo — no `Scripts/`, no `Data/`. The pavilion is created
by `APavilion.xs` at run time, so nothing authors triggers any more and there is nothing to keep
in step across files.

The XS repo has no CI and no test suite. What protects it is the linter, the apworld's cross-repo
tests, and the `mutable` stubs in `AP_Headers.xs`: each one announces itself in red when it runs,
so a missing override says so in game instead of silently doing nothing.
