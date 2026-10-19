# `monks_can_counter`

Whether the logic may expect conversion micro of P1.

## What the player sets

`MonksCanCounter(Toggle)`, display name "Monks Can Counter". Off by default.

> Whether the logic may expect monks and missionaries to counter an army by converting it.
> Off: They still count against Battle Elephants, War Elephants and Elephant Archers, and
> against nothing else.
> On: They count against everything they convert well.
> Logic only: monks are trainable in game either way.

## Generation effect

The faith lines are `FAITH_LINES` in `locations/connections/UnitRoles.py`: the Monk and Missionary
lines. The elephant exception beside it, `FAITH_EXCEPTION_TARGETS`, is the Battle Elephant, War
Elephant and Elephant Archer lines.

`ScenarioUnitLogic.can_counter` asks `_is_expected_counter(line, target)` of every entry in
`target.countered_by`. With the option off, a faith line is dropped as a counter of any target
outside the elephant exception; against an elephant line it counts as before. With it on, every
faith-line entry counts.

The filtering happens where counters are resolved. The counter table in `UnitCounters.py` carries no
option markers. Its `# should be for harder difficulty` comments on faith-line entries are what this
option now decides, except on the three elephant rows, where the entries always count and the
comments are PR 18's judgement left as it was.

A faith line that is dropped is dropped entirely, Redemption or not: `counter_techs` only ever adds a
requirement to a counter that is still being considered.

## Game effect

None. The option is not in `SlotData.OPTIONS`, not in slot data, and has no XS constant, so adding it
needed no world version bump. Monks and missionaries train and convert in game whatever it says.

## Interactions

None with other options. Off only narrows the counters, so a target whose one fieldable counter in a
scenario was a faith line goes uncountered there until something else is fieldable.

## Tests

`test_military_rules.py::TestMonksCanCounter` - off by default; off, neither faith line counters the
Knight line but both counter each elephant line; on, both counter all four. It mocks `can_field` so
the faith line is the only thing P1 fields.

`test_slot_data_wire.py::TestLogicOnlyOptionsStayOutOfTheGame` keeps it out of `SlotData.OPTIONS` and
slot data.

`TestCounters::test_a_monk_converts_siege_only_with_redemption` builds with the option on, since it
needs monks to count against Knights.
