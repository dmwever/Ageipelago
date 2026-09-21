# `goal`

## What the player sets

`Goal(Choice)`, display name "Goal". One value: `option_campaign_completion = 0`, the default.

> Goal for this playthrough.
>     Win Selected Campaigns: Finish each campaign selected for victory.

## Generation effect

`Logic.has_goal()` returns `GoalLogic.completed_all_campaigns()` when the option is
`option_campaign_completion`, else `False_()`. That rule is set on the `"Victory"` event location.
`completed_all_campaigns()` requires `Has("<scenario>: Unlock Next Scenario")` for every scenario in
every included campaign.

## Game effect

None. Generation-only.

## Interactions

The seed's completion condition is **not** this option: `Rules.set_rules` hardcodes
`completion_condition[player] = lambda state: state.has("Victory", player)`. The option only decides
when the Victory item may be collected.

## Notes

Single-valued, so the `Choice` never varies and the `False_()` branch is unreachable. No tests cover it.
