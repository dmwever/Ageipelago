# `local_start`

## What the player sets

`LocalStart(Choice)`, display name "Local Start". `option_no = 0` (default), `option_base = 1`,
`option_guarantee_win_first_scenario = 2`, `option_both = 3`.

> Place the items needed for a playable opening in your own world.
>     No: Place nothing locally.
>     Base: Place the items needed to build a town centre locally.
>     Guarantee Win First Scenario: Place everything needed to beat one of your starting scenarios locally.
>     Both: Place both sets locally.

## Generation effect

`pre_fill` calls `LocalStart.apply(world)`, which runs before the main fill.

`choose_start_scenario` picks one scenario from `starting_campaigns` using `world.random.choice` over a
**sorted** list, so it is deterministic. `win_items` solves the chosen scenario's victory rule;
`base_items` solves `can_build_base() & scenario_base_rule(...)`, splitting the top-level `And` into
conjuncts and solving each, then re-minimizing the union. `solve` is a greedy minimizer: narrow to the
rule's declared item dependencies, verify, then drop items one at a time while the target still holds.
Placement is `Fill.fill_restrictive(..., lock=True, allow_partial=False)`.

## Game effect

None directly. The chosen items reach the game as ordinary item grants.

## Interactions

Depends on `starting_campaigns` for the candidate scenarios, and on the whole rule graph, so every
other option feeds it indirectly.

## Tests

`test_local_start.py` covers selection per campaign, determinism, the solver, and win and base item
sets for both campaigns.

## Notes

Best-effort by design. An unsolvable target or a `FillError` logs a warning and continues with a
smaller or empty set; it never fails generation.
