# `tech_behavior`

## What the player sets

`TechBehavior(Choice)`, display name "Tech Behavior". `option_must_research = 0` (default),
`option_instant = 1`. Requires techsanity.

> When a shuffled technology's effect is applied. Requires Techsanity.
> Must Research: The item makes the technology available; you still pay for it and research it.
> Instant: The item applies the effect immediately, for free.
> Unit-line upgrades always behave as Must Research, since an upgrade you did not pay for would
> rewrite an army you already have.

## Generation effect

**None.** No Python code branches on this option. It appears only in `Options.py` and in
`SlotData.OPTIONS`. Do not go looking for the missing generation logic.

## Game effect

XS constant **`AP_TS_BEHAVIOR`**, default `UNSET`. In `Techsanity.xs::tryApplyEffect()`:

```
bool mustResearch = (AP_TS_BEHAVIOR == BEHAVIOR_MUST_RESEARCH) || structGetBool(tech, "isUpgrade");
```

That `||` is where the docstring's promise about unit-line upgrades is enforced: an upgrade requires
real research whatever the option says. `BEHAVIOR_INSTANT` is never compared; it is the implicit else.

## Tests

Wire level only: `test_slot_data_wire.py`, `test_installer.py`, `test_campaign_bundle.py`. The
behaviour itself lives in XS and has no Python coverage.
