# `caveman`

Every unit you are handed is dragged down to what you have actually unlocked.

## What the player sets

`Caveman(Toggle)`, display name "Caveman". Off by default.

> Every unit you are handed is downgraded until you find what it needs. Requires Unitsanity.
> A unit you did not train becomes the best tier of its own line you have unlocked, or a Militia
> if you have unlocked none of it, and climbs back as the line's items arrive - but never past
> what it started as. Units you trained yourself are untouched, as are villagers, heroes and
> mercenaries. Adapts to Techsanity, since an upgrade you have not researched is not unlocked.

## The rule

Each affected unit carries a **ceiling** - what it was before being downgraded:

    target = lineHasAnyUnlockedTier(line(original))
               ? min(highestUnlockedTier(line(original)), originalTier)
               : MILITIA

Downgrade and restore are the same computation at different times. An entry is **retired** once its
unit reaches its ceiling, so a later ordinary tech upgrade may carry it further.

A unit the player trained is never tracked, which is what makes the awkward case fall out for free:
train a second Knight after unlocking the line and it does **not** follow the first to Cavalier -
it upgrades only when Cavalier is researched, like any normal unit.

## Generation effect

Not yet wired.

## Game effect

None yet; Phase 14. What Phase 0 measured in game and this depends on:

- `xsGetPlayerUnitIds` works on creatable units, so individual units are addressable
- per-tick scanning is affordable, so the ledger can be maintained continuously
- **XS state survives a save and reload**, so the ledger needs no persistence through the client
- the unit id **changes** across `xsRemoveUnit` + `xsCreateUnit`, so the ledger key is rewritten on
  every transform

## Interactions

Requires `unitsanity`. Adapts to `techsanity`, because "unlocked" consults both unit items and
upgrade technologies. Scope is buildable unit lines only, so heroes, animals and scenery are exempt
without needing a rule; villagers and queue-spawned mercenaries are exempt deliberately.

## Tests

None yet.
