# Release 0.3.0 - The Sanity Update

> **Not compatible with 0.2.x seeds.** Slot data, the packet layout and the way campaign files reach
> your install have all changed. Regenerate the seed, update both halves, and run the new `/install`
> before playing.

## What's Changed

### New Campaign: Genghis Khan

- All 6 scenarios from the original base game: Crucible, A Life of Revenge, Into China, The Horde
  Rides West, The Promise, and Pax Mongolica.

### New Setting: Techsanity

- Technologies are shuffled. A shuffled technology stays researchable; researching it sends its
  check, and the item is what applies the effect, depending on tech behavior (below).
- 4 modes:

 1. _None:_ technologies behave as vanilla.
 2. _Units:_ only unit-line upgrades are shuffled, e.g. Man-At-Arms, Crossbowman, Elite Skirmisher.
 3. _Generic:_ every other technology is shuffled, e.g. Loom, Fletching, Wheelbarrow.
 4. _All:_ both.

### New Setting: Tech Behavior

- **Requires Techsanity.** When a shuffled technology's effect is applied.

 1. _Must Research:_ a technology's effect lands once the tech is researched in-game and the item arrives.
 2. _Instant:_ the item applies the effect immediately, for free.

- Unit-line upgrades always behave as Must Research, so that an item can never make a unit inaccessible.

### New Setting: Shuffle Unique Techs

- **Requires Techsanity.** Whether civilization unique technologies join the pool.

 1. _Unshuffled:_ unique technologies behave as vanilla.
 2. _Shuffled:_ unique technologies are shuffled.
 3. _Shuffled Everywhere:_ unique technologies are shuffled, and with _instant_ tech behavior they apply
    across civilizations. With _must research_, this setting behaves as _shuffled_.

### New Setting: Existing Techs

- **Requires Techsanity.** What happens to the technologies a scenario would normally start with.

 1. _Vanilla:_ a scenario starting in the Castle Age keeps every Dark and Feudal Age technology.
 2. _Find Items:_ a technology the scenario would have started with is not applied until its item is
    found. Once found, it is free to research in that scenario.
 3. _Only Find Units:_ the same, but only units are hidden.
 4. _Start In Dark Age:_ every scenario opens in the Dark Age with nothing researched at all. Very difficult.

### New Setting: Unitsanity

- Units are shuffled. Owning a unit sends its check, and items are what let you train one.

 1. _None:_ units behave as vanilla.
 2. _Unit Line:_ a whole upgrade line is one location and one item, e.g. the Knight line.
 3. _All:_ lines are still what you unlock, but owning any single unit is its own check, e.g. Own Knight, Own
 Cavalier, etc. Includes scenario-only units, such as Horse, Attila the Hun, or units that only appear via triggers.

### New Setting: Unitsanity Items

- **Requires Unitsanity.** What a unitsanity item actually is.

 1. _Unit Line:_ one item per line, e.g. Militia Line, Archer Line.
 2. _Upgrades:_ units need the equipment they are known for, so a Knight wants a Horse, a Sword and a
    Shield while an Archer only wants a Bow. A unit becomes trainable once it has all of its own.
    Adapts to techsanity.
 3. _Buildings:_ one item per producing building, e.g. Barracks Units, Archery Range Units. These items
 are separate from building unlocks.

### New Setting: Include Unique Units

- **Requires Unitsanity.** Which civilization-restricted units join the pool.

 1. _None:_ only units (almost) every civilization can train are shuffled.
 2. _Regional:_ also shuffle units a handful of civilizations share, e.g. the Eagle, Camel and Steppe
    Lancer lines.
 3. _Unique:_ also shuffle units one civilization has, e.g. the Tarkan or the Longboat.
 4. _Both:_ shuffle unique and regional units alike.

- A unit is only ever obtainable while you are playing a civilization that has it.

### New Setting: Shuffle Villager

- **Independent of Unitsanity** - it works with Unitsanity off. Whether the villager is shuffled.

 1. _No:_ villagers behave as vanilla.
 2. _Yes:_ the villager is an item and a location.
 3. _Include Professions:_ each of the 12 jobs a villager can do is its own location - Fisherman,
    Builder, Forager, Hunter, Lumberjack, Stone Miner, Repairer, Farmer, Gold Miner, Shepherd, Herder
    and Oyster Gatherer. Very difficult.

### New Setting: Caveman

- **Requires Unitsanity, and Techsanity Units/All.** OOOK ONK. Must get unit item. Not for weak heart man. (Very difficult.)
- Every unit you are handed is dragged down to the best tier of its own line you have unlocked, or to
  a Militia if you have unlocked none of it, and climbs back as the line's items arrive - but never
  past what it started as.
- Units you trained yourself are untouched, as are villagers, heroes and mercenaries.
- Adapts to techsanity, since an upgrade you have not researched is not unlocked.

### New Setting: Shuffle Ages

- Advancing to the Feudal, Castle and Imperial Ages becomes three items in the pool.

### New Setting: Local Start

- Place the items needed for a playable opening in your own world.

 1. _No:_ place nothing locally.
 2. _Base:_ place the items needed to build a town centre locally.
 3. _Guarantee Win First Scenario:_ place everything needed to beat one of your starting scenarios
    locally.
 4. _Both:_ place both sets locally.

### New Setting: Market Trade

- Whether the logic may expect you to buy and sell resources at your own market. Heavily biased in logic.

 1. _Off:_ the market is never needed to afford anything.
 2. _On:_ a market with a steady supply of wood or food to sell can stand in for any resource.

### New Setting: Partner Trade

- Whether the logic may expect you to run trade carts and trade cogs to another player's market or
  dock, and to whose.

 1. _None:_ trade with other players is never needed to afford anything.
 2. _Allies:_ only an ally's market or dock, and only where the scenario's ally keeps one usable.
 3. _Allies And Enemies:_ an enemy's too, once you can defeat its owner, straight away if it is
    undefended, or once you can guard the route to it.

### New Setting: Monks Can Counter

- Whether the logic may expect monks and missionaries to counter a unit. Heavily biased in logic. Very difficult.

 1. _Off:_ monks are only considered a counter to elephants.
 2. _On:_ they can counter valuable unit-lines such as heavy cavalry and siege (with redemption).

### New Setting: Siege Can Counter

- Whether the logic may expect mangonels, bombard cannons and rocket carts to counter a unit. Does not
  affect scorpions either way. Difficult.

 1. _Off:_ they can only counter siege.
 2. _On:_ they can counter all units they are typically strong against.

### New Feature: Traps

- Three settings drive them:

 1. _Trap Difficulty:_ No Traps, Easiest, Standard, Medium, Hard or Legendary. Scales how much each
    trap takes; No Traps keeps them out of the item pool entirely.
 2. _Trap Percentage:_ the share of leftover filler slots to replace with traps. Starting resources
    are always funded first, so a seed with no room to spare produces no traps whatever this is set to.
 3. _Trap Distribution:_ the relative chance of each trap, 0 to 1000, every trap defaulting to 100. A
    trap on 200 is twice as likely as one on 100, and 0 disables that trap outright.

- **Trap Percentage and Trap Distribution both require Trap Difficulty to be above No Traps.** Setting
  every weight in Trap Distribution to 0 also produces no traps, whatever Trap Percentage says.
- 9 traps:

 1. _Wololo Trap_
 2. _Nobody Expects the Spanish Inquisition Trap_
 3. _Long Time, No Siege Trap_
 4. _Ooh Ahh Trap_
 5. _Theologians Trap_
 6. _I'd Really Like To See That Trap_
 7. _Flemish Revolution Trap_
 8. _Raiding Party Trap_
 9. _Give Me Your Extra Resources Trap_

### New Feature: Mercenaries

- Troops that are normally found in a given scenario can now be spawned in _any_ scenario as a one-time bonus.
For example, if you find the Scythian Troop, you will unlock the Scythian Manguadi that spawn in Attila 1, but
in addition, you will be able to spawn in those mangudai one time into _any_ scenario.

### New Feature: /install

- `/install` sets your Age2 install up for the seed and slot you are connected to: a seed-tagged copy
  of every campaign your yaml enabled.
- Play the campaign carrying your own name and seed tag, e.g. `AP Joan of Arc_<name>_b435aa86`.
- Re-running it is safe. It never touches the untagged originals, and installing a second seed leaves
  the first seed's files in place. `/install full` rebuilds every campaign from scratch.
- The client and the game both name what they expected when something is off - see the new Setup
  section of the AP FAQ for the full table of messages.

### New Feature: Ageipelago UI Mod

- A local mod ships alongside the game files, carrying the names and pictures for the mercenary
  buttons. Enable it in the Mod Centre under Local.
- Without it the buttons still work but come up blank and with no names.

### Bugfix: Victory Threats

- AP scenarios do not win or lose on the vanilla victory conditions. As a result, in 0.2.x, wonders
were no longer a threat to the player.
- When an enemy begins a Wonder you are told and its foundation is revealed. Completing it starts a
  countdown you must beat by destroying it. An enemy holding every relic starts the same countdown.
- The countdown scales with the size of the map.

### Updated Setting: Shuffle Buildings

- The buckets have been redrawn:

 1. _Base:_ the town center and houses. New, and paired with Local Start's Base. **New**.
 2. _Economy:_ the market, resource buildings and farms. Includes dock.
 3. _Tech:_ the blacksmith and university. The monastery has moved out of this bucket.
 4. _Military:_ the barracks, archery range, stable, siege workshop and monastery. Includes dock.
 5. _Castle:_ the castle, and with Unique the krepost, fortified church and donjon (eventually). **New**.
 6. _Defense:_ walls, gates and towers.
 7. _Unique:_ unique buildings, if applicable civilizations are in the pool. Other options apply to
    these buildings, e.g. if economy isn't shuffled, neither is folwark.
 8. _Wonder:_ the wonder, the wonder, the... NO!
 9. _Building Name_: Any building can be selectively shuffled using its name as a key, such as "Market" or "Barracks".
 Case insensitive.

### Updated Settings: Enabled Campaigns / Starting Campaigns

- Leave Starting Campaigns blank for a random start: one of your enabled campaigns is chosen for you.

### Changed Defaults

- **A default yaml is a very different seed than it was in 0.2.x.** The new shuffles are on out of the
  box, so read this section before reusing an old yaml.
- _Enabled Campaigns_ and _Starting Campaigns_ now default to **Genghis Khan**, where 0.2.x defaulted
  to Attila the Hun.
- _Techsanity_ defaults to **All** and _Shuffle Unique Techs_ to **Shuffled**: every technology is in
  the pool unless you turn it off.
- _Shuffle Ages_ is **on**: Feudal, Castle and Imperial are items.
- _Unitsanity_ defaults to **Unit Line**, _Unitsanity Items_ to **Unit Line**, and _Include Unique
  Units_ to **Both**.
- _Trap Difficulty_ defaults to **Standard** and _Trap Percentage_ to **20**, so a default seed carries
  traps. Set Trap Difficulty to No Traps to keep them out entirely.
- _Partner Trade_ defaults to **Allies**, so an ally's market or dock can be expected to afford things.
- Off by default: _Existing Techs_ (Vanilla), _Tech Behavior_ (Must Research), _Shuffle Villager_,
  _Caveman_, _Local Start_, _Market Trade_, _Monks Can Counter_ and _Siege Can Counter_.
- _Shuffle Buildings_ still defaults to `[Economy, Tech, Military]`, but those three buckets hold
  different buildings now - see above.

### QOL

- `/mercenaries` lists this seed's mercenaries and whether each is Missing, Unlocked, In-Pavilion or
  Used. `/scenarios` does the same for scenarios, down to which one is Active.
- Universal Tracker's `/explain` is supported: it answers how a location can be had, where, and what
  is short, one block per route and one line per campaign, however many scenarios the seed has.
- AP locations are listed in the objectives panel across all three campaigns.
- Scenarios can be swapped in quick succession without desyncing from the client.
- The world has an icon in the launcher and tracker.
- Starting resources are written into the spoiler log.

### Bugfixes

- Buildings could stop being buildable after an age-up.
- A scenario resumed from a mid-scenario save never saw items that arrived while another scenario was
  running. Delivery state now lives in the game rather than in client memory, so items, ages and
  mercenaries all survive a save, a load and a reconnect.
- Loading a save into a different scenario printed install and version errors for the whole recovery
  window, and the real identity checks never ran.
- The first scenario of a session could be paid its starting resources twice.
- The AP Pavilion could be destroyed. It is now untargettable.
- Attila 2: freeing the Tarkans now requires destroying Cyan's Town Center **and** Castle, not either.

**Full Changelog**: <https://github.com/dmwever/Ageipelago/compare/v0.2.3...0.3.0>
