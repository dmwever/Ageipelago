# `enabled_campaigns`

## What the player sets

`EnabledCampaigns(OptionSet)`, display name "Enabled Campaigns". Valid keys are the campaign names.
Default `{Attila the Hun}`.

> Determines which vanilla campaigns will be unlocked for the player.

The docstring nearly duplicates `starting_campaigns`'. The real distinction: this decides which
campaigns exist in the seed at all; `starting_campaigns` decides which of those begin unlocked.

## Generation effect

`generate_early` sets `world.included_campaigns`, raising `OptionError` if empty. Everything downstream
derives from it: regions and scenario chains, `included_civs`, `earliest_age`, the `TechPool`, and
which scenario, mercenary, campaign and progressive-scenario items are pooled at all.

## Game effect

Indirect, through the same `"<campaign name>_unlocked"` slot_data keys. No XS constant.

## Interactions

Constrains `starting_campaigns`. A campaign with no scenarios raises `OptionError` in `create_regions`,
currently unreachable since both campaigns have six.

## Tests

`test_local_start.py::TestSelectionOptionErrors`, `test_regions.py::TestCivilizationCollection` and
`TestEmptyCampaign`, `test_determinism.py`, `test_client_victory.py`.
