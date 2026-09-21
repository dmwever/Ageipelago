# Mercenary unknowns — spike list

**Temporary.** Delete this once the questions below are settled and the answers have moved into the
code, `XS_PRINCIPLES.md`, or `communication_protocol.md`.

Everything in phases 1-8 is written and lints clean, but none of it has been run in the game. These
are the assumptions it rests on, worst first. Each says what is assumed, what breaks if the
assumption is wrong, and the cheapest way to find out.

Per `XS_PRINCIPLES.md` §15: state the competing models before probing, pick an observable that
counts, and include a control.

---

## 1. Does a seat technology complete more than once?

**Assumed:** `cAttrSetStacking 1.0` plus `cAttrSetStackingResearchCap` lets a seat tech be researched
again after a `Ready`-over-`Done` write, so the same four techs can serve every mercenary in the
seed.

**If wrong:** every seat works exactly once. The first four mercenaries spawn, and nothing after
that ever does — silently, because `OfferSeat` will look like it succeeded.

**Why it is open:** §19 of `XS_PRINCIPLES.md` says a tech cannot be un-researched and that writing
Ready over Done reverts it to researchable, but says nothing about whether the stacking cap is
consumed by that path or only by ordinary completions.

**Probe:** harden one seat, research it, write Ready over it, research it again. Observable: a
counting effect bound to the tech, or simply whether the button comes back. Control: a second seat
hardened *without* stacking, which should refuse the second research.

**This is the one to run first.** Everything else in phase 8 assumes it.

---

## 2. What does `xsCreateUnit` return when placement fails?

**Assumed:** `-1`. `SpawnNextSoldier` treats that as failure and retries next tick.

**If wrong:** a failed placement is read as a valid unit id, the soldier count advances, and the
mercenary is reported complete having spawned fewer soldiers than it owed.

**Why it is open:** the KB documents the return as "the created unit ID" and says nothing about
failure. `xsSetUnitPosition` by contrast has a documented `bool`.

**Probe:** call it on a tile known to be occupied by a building, with `checkCollision` true, and
print the return. Then the same call with `checkCollision` false. Control: a call on open ground.

**Note:** the current code passes `checkCollision = false` and relies on `ClearSpawnArea` instead. If
the failure return turns out to be usable, `true` plus a retry is the better shape.

---

## 3. Is trigger variable 90 free in all twelve scenarios?

**Assumed:** `MERCENARY_TASK_VARIABLE = 90` collides with nothing the shipped scenarios already use.
Attila 1 is known to use variable 2 for its horse counter.

**If wrong:** the muster trigger fires on somebody else's variable, or a scenario's own logic is
driven by mercenary spawns. Either is a gameplay bug with no error message.

**Cheapest check:** not a spike at all — enumerate the variables in all twelve `.aoe2scenario` files
with AoE2ScenarioParser and assert 90 is unused. Worth doing as a build-time check in
`Scripts/setup_pavilion.py` rather than a one-off, since new scenarios will keep arriving.

---

## 4. Does the muster trigger actually move a freshly spawned unit?

**Assumed:** `task_object` selecting a 3×3 area around the spawn tile will pick up a unit XS created
on that tile in the same tick, and send it to the muster point.

**If wrong:** soldiers pile on the spawn tile. Not fatal — `ClearSpawnArea` shoves them aside on the
next spawn — but the "troops march out of the pavilion" effect is lost.

**Open sub-questions:** whether a trigger sees a unit created by XS in the same tick, and whether
lowering the variable in the same trigger run cuts the task short.

**Probe:** the in-repo precedent is `Streaming Mangudai` in Attila 1, which does `CREATE_OBJECT` then
`TASK_OBJECT` from within one trigger. Compare behaviour against that — if the trigger-created unit
marches and the XS-created one does not, the answer is that XS creation is not visible to the trigger
in the same tick, and the variable should be raised a tick later.

---

## 5. Are the drafted spawn and muster points sane?

**Assumed:** spawn at pavilion + 2 tiles toward map centre, muster at + 6, per
`Data/VictoryPavilionLocations.json`. Derived from map size, not chosen by eye.

**If wrong:** troops appear in water, inside cliffs, or inside someone's base. Per-scenario and
visible immediately.

**Check:** open each scenario at the pavilion and look. Twelve scenarios, and the drafts are in the
JSON ready to be corrected.

---

## 6. Is `ClearSpawnArea` affordable?

**Assumed:** scanning nine players for `cObjectTypeCreatable` and `cObjectTypeBuilding` once per
spawned soldier is cheap enough, because it only runs while a mercenary is spawning.

**If wrong:** a frame hitch once a second during a spawn, worst on late-game maps with many units.

**Check:** spawn the Loyalist Troop (22 soldiers, so 22 scans) on the busiest available save and
watch for stutter. If it bites, the fix is to scan once when the seat starts running rather than per
soldier.

**Related:** `xsGetPlayerUnitIds` with a class id is assumed to accept `cObjectTypeCreatable` and
`cObjectTypeBuilding` as class filters. If it does not, the scan silently returns nothing and
blockers are never cleared.

---

## 7. Does the research clock actually line up with the spawns?

**Assumed:** research time in seconds equals unit count, one soldier per second, so the last soldier
lands as the research completes.

**Worth watching rather than probing:** the two are tracked separately on purpose — completion is
reported on the last *soldier*, not the last *tick* — so drift is tolerable. But a large mismatch
would mean the seat frees up long before or after the troops arrive, which will feel wrong.

The Loyalist Troop is the extreme case at 22 soldiers, so a 22-second research. Watch whether that
reads as deliberate or as broken.

---

## Not unknowns, but unfinished

- `Scripts/__init__.py` has never been run against the new trigger authoring. It rewrites all twelve
  `.aoe2scenario` files, so it wants running deliberately and with the originals in git.
- Nothing has verified that `MercenaryData.xs` as written by `/install` parses in game.
- The `Mercenaries` branch defines `NOOP_EFFECT` and the cost range in `AP_Constants.xs`; Techsanity
  defines the same names in `Tech_Constants.xs`. Merging the two branches needs one side removed —
  XS has no include guards, so it will not merge quietly.
