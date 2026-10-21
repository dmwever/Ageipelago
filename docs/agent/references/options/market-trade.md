# `market_trade`

Whether the logic may expect P1 to buy and sell at its own market.

## What the player sets

`MarketTrade(Toggle)`, display name "Market Trade". Off by default.

> Whether the logic may expect you to buy and sell resources at your own market.
> Off: The market is never needed to afford anything.
> On: A market with a steady supply of wood or food to sell can stand in for any resource.

## Generation effect

`ScenarioResourceLogic.can_trade_at_market` is the rule. With the option off it is `False_()`.
With it on it is the scenario's Market and either easy wood (`_can_get_wood_easily`: gathering it,
or partner trade for it) or `endless_food`. The rule is written against the leaf gatherers, not the
`ScenarioHasEasyResource` aggregate, so asking for wood never asks the market which asks for wood.

`endless_food` itself needs easy wood, since farms and fish traps are rebuilt in wood, so in practice
the rule comes down to a Market and easy wood. The food branch is kept as written.

`ScenarioHasEasyResource.answer` ORs `can_trade_at_market` into every resource's easy source, so
on, a market that has something to sell makes every resource easy in that scenario.

It replaces the old `MARKET_ECONOMY` module constant one for one; the constant is gone.

## Game effect

None. The option is not in `SlotData.OPTIONS`, not in slot data, and has no XS constant, so adding it
needed no world version bump. The market buys and sells in game whatever it says.

## Interactions

`shuffle_buildings`: with Economy shuffled the Market is an item, and the rule waits on it unless
the scenario starts with one. Building one also needs the Mill. Partner trade for wood (see
[partner-trade](partner-trade.md)) is one way the rule finds wood to sell.

## Tests

`test_economy_rules.py::TestMarketTrade` - off by default; off, `can_trade_at_market` resolves false
in every scenario; on, it depends on the Market item, fails with neither wood nor endless food, and
holds with wood. `TestMarketTrade::test_the_market_rule_terminates_when_switched_on` resolves every easy
source with the option on and checks no shared question is left open.

`test_slot_data_wire.py::TestLogicOnlyOptionsStayOutOfTheGame` keeps it out of `SlotData.OPTIONS` and
slot data.
