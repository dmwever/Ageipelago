# `partner_trade`

Whether the logic may expect P1 to run trade carts and trade cogs to another player's market or
dock, and to whose.

## What the player sets

`PartnerTrade(Choice)`, display name "Partner Trade". Default `allies`.

> Whether the logic may expect you to run trade carts and trade cogs to another player's market or
> dock, and to whose.
> None: Trade with other players is never needed to afford anything.
> Allies: Only an ally's market or dock, and only where the scenario's ally keeps one usable.
> Allies And Enemies: An enemy's too, once you can defeat its owner, or straight away if it is
> undefended. A main opponent's only if undefended.

| Value | Number |
|---|---|
| `none` | 0 |
| `allies` | 1 |
| `allies_and_enemies` | 2 |

One option covers carts and cogs together.

## Generation effect

`ScenarioPlayerLogic.can_reach_partner(building)` (`scenario_logic.players`) is the gate, for `MARKET` (carts) or `DOCK`
(cogs): an OR of one gate per partner. At `none` it is `False_()`. At `allies` the partners are the
allies; at `allies_and_enemies` the enemies too. Each player's gate comes from its access to that
building: `OPEN` is `True_()` (an ally's, or Joan 3's undefended English dock), `ONCE_DEFEATED` is
`ScenarioPlayerLogic.has_defeated(player)`, `CLOSED` drops out. With no gate left it is `False_()`.

### Defeat events

`has_defeated(player)` is `Has("<scenario>: Can Defeat <player>")`, an event item, never the defeat
rule itself: a defeat asks for an army, the army asks `can_pay`, `can_pay` asks the easy sources, and
easy gold and wood ask trade. Reading `defeats(player)` inline made `ScenarioHasEasyResource` ask
itself (`RecursionError` at `set_rules`) for any defeat that costs resources. The sweep settles the
cycle instead.

Only at `allies_and_enemies`, `add_scenario_region` adds one event per player with
`trades_once_defeated` (hidden from the spoiler, like "Complete <scenario>"), and
`ScenarioRules.set_defeat_event_rules` gives it `defeats(player)` as its rule. At the other values
the region graph is unchanged. The name is `Age2PlayerData.defeat_event(scenario_name)`; "Can Defeat",
not "Defeat", because "Defeat Metz" and the like are real objective locations.

Two rules read the gate:

- `can_earn_gold_by_partner_trade` - carts to a partner market, or cogs to a partner dock; Feudal Age,
  some gold to seed it, and P1's own Market or Dock and the trader's unit items.
- `can_earn_wood_by_partner_trade` - cogs only: a sea route brings wood home, a cart does not.

Each returns `False_()` outright when no partner building is open, so a scenario without one never
builds the rest of the rule. `ScenarioHasEasyResource` ORs the gold rule into easy gold, and
`_can_get_wood_easily` ORs the wood rule into easy wood.

### Player records

Usability is hard-coded per player on `Age2PlayerData` (`locations/Players.py`): one member per ally
and enemy of each scenario, id = scenario id then slot, with columns for name, slot, `Side`, main
opponent, and a `TradeAccess` for the market and the dock - `CLOSED`, `OPEN` (an ally's, or an
undefended enemy's, like Joan 3's English dock) or `ONCE_DEFEATED`. `connections/ScenarioPlayers.py`
routes them to scenarios (`SCENARIO_TO_PLAYERS`, copied onto `Age2ScenarioData.players`). Fixed-force
scenarios (Joan 1, Joan 5) have none. Defeat rules are keyed by these members.

`ScenarioPlayerLogic.has_trading_ally()` is true when any ally keeps a market or dock `OPEN`, read straight
off the players. No starting state overrides it.

The access values come from PR 19's judged flags and the design rulings. The flags mean usability,
not existence: never correct one from a scenario scan.

It replaces the old `ALLY_TRADE` module constant; the constant is gone.

## Game effect

None. The option is not in `SlotData.OPTIONS`, not in slot data, and has no XS constant, so adding it
needed no world version bump. Trade carts and cogs work in game whatever it says.

## Interactions

`market_trade`: easy wood from partner trade is something the market can sell.
`shuffle_buildings` and `unitsanity`: the Market, the Dock and the trader's unit items can each be
items the rule waits on.

## Tests

`test_economy_rules.py::TestPartnerTrade` - allies by default; `none` false everywhere; `allies`
opens gold exactly in Attila 1, Attila 5, Attila 6 and Joan 2, never an enemy's (Genghis 5); carts
ask the Market, cogs the Dock; every scenario's easy sources resolve with no question left open, at
`allies` and at `allies_and_enemies`.

`test_economy_rules.py::TestPartnerTradeWithEnemies` - `allies` waits on no defeat and creates no
event; `allies_and_enemies` waits on exactly the defended owners of each building no partner keeps
open, never a main opponent; each event's rule is its owner's defeat; Genghis 5's gold waits on the
Polish and the Germans; Joan 3's English dock needs no defeat, and stays closed at `allies`.

`test_defeat_rules.py` - every player with a `ONCE_DEFEATED` building has a defeat rule;
`TestDefeatAndTradeTerminate` builds every defeat and trade rule at `allies_and_enemies`.

`test_player_records.py` - every scenario is routed and every player belongs to one; ids, slots,
sides, absent neutral slots, main opponents and access follow the rulings and agree with the judged
flags; the Kipchaks are never a trade partner; `has_trading_ally` follows the players.

`test_slot_data_wire.py::TestLogicOnlyOptionsStayOutOfTheGame` keeps it out of `SlotData.OPTIONS` and
slot data.
