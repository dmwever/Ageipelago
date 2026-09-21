# `scenario_branching`

## What the player sets

`ScenarioBranching(Choice)`, display name "Scenario Branching". `option_any = 0` (default),
`option_all = 1`.

> If a story quest has multiple routes you can take depending on your decisions;
>     Any: Any decision made will send the check for that story quest.
>     All: Every individual decision will send it's own check, potentially requiring you to play the same scenario multiple times.

## Generation effect

`Age2World.branching_option(location)` drops `OBJECTIVE_BRANCHING_ALL` locations unless the value is
`option_all`, and `OBJECTIVE_BRANCHING_ANY` locations unless it is `option_any`. Filtered locations are
never created, so nothing downstream has to know about them.

Three scenarios add extra per-route rules only under `option_all`: `Attila4Rules`, `joan_2` (the four
Orleans castles), `joan_3`.

## Game effect

None. The game still fires every underlying trigger; only the AP location set changes.

## Tests

`test_regions.py::TestScenarioRuleSetup` asserts no `OBJECTIVE_BRANCHING_ALL` location survives under
`"any"`.

## Notes

The yaml key was `scenarioBranching` until it was renamed to match its `internal_name`. Yamls using the
old spelling need updating.
