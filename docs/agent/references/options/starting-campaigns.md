# `starting_campaigns`

## What the player sets

`StartingCampaigns(OptionSet)`, display name "Starting Campaigns". Valid keys are the campaign names
(`Attila the Hun`, `Joan of Arc`). Default `{Attila the Hun}`.

> Determines which vanilla campaigns will start unlocked for the player.

## Generation effect

`generate_early` builds `world.starting_campaigns` from the intersection with the included campaigns,
raising `OptionError` if this set is empty, or if it names no enabled campaign.

In `create_items`, a campaign-unlock item is `push_precollected` when its campaign is a starting
campaign, and pooled otherwise. `LocalStart.choose_start_scenario` picks from this set.

## Game effect

Indirect. `fill_slot_data` emits `"<campaign name>_unlocked": bool` per included campaign. The Python
client reads it in `CampaignHandler.setup_victory_requirements`. There is no XS constant.

## Interactions

Must intersect `enabled_campaigns`. The client uses the **presence** of the `_unlocked` key to decide a
campaign is included and must be beaten; the boolean itself says whether it starts unlocked.

## Tests

`test_local_start.py::TestSelectionOptionErrors`, `test_determinism.py::TestCampaignOrder`,
`test_client_victory.py`, `test_installer.py::TestIncludedCampaigns`.
