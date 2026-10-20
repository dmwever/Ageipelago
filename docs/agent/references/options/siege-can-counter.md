# `siege_can_counter`

Whether the logic may expect anti-unit siege micro of P1.

## What the player sets

`SiegeCanCounter(Toggle)`, display name "Siege Can Counter". Off by default.

> Whether the logic may expect mangonels, bombard cannons and rocket carts to counter a unit.
> Does not affect scorpions.
> Off: Mangonels, bombard cannons and rocket carts can only counter siege.
> On: Mangonels, bombard cannons and rocket carts can counter all units they are typically strong against.

## Generation effect

The anti-unit siege is `ANTI_UNIT_SIEGE` in `locations/connections/UnitRoles.py`: the Mangonel,
Bombard Cannon, Rocket Cart and Heavy Rocket Cart lines. Not the Scorpion, which is easy enough to
count as an ordinary counter, and not the Organ Gun.

The exception beside it, `SIEGE_TARGETS`, is the Battering Ram, Armored Elephant, Trebuchet,
Traction Trebuchet, Mounted Trebuchet, Bombard Cannon, Mangonel, Scorpion, Rocket Cart and Heavy
Rocket Cart lines. It is its own group, not `SIEGE` (the building breakers): the Fire Archer and
Petard lines are left out and count as armies, and so does the Organ Gun.

`ScenarioUnitLogic.can_counter` asks `_is_expected_counter(line, target)` of every entry in
`target.countered_by`. With the option off, an anti-unit-siege line is dropped as a counter of any
target outside `SIEGE_TARGETS`; against a siege target it counts as before. With it on, every
anti-unit-siege entry counts.

The ram sponge obeys it too. A ram-counter target (the archer lines, Ballista Elephant, Skirmisher) is
countered by a ram plus any military line, and the Mangonel and rocket cart lines are in the military
role. `can_sponge_for_military` asks `_is_expected_escort(line)` of each military line, so with the
option off anti-unit siege is no escort, since doing the ram's killing is fighting an army.

The filtering happens where counters are resolved. The counter table in `UnitCounters.py` carries no
option markers. Its `# should be for harder difficulty` comments on Mangonel and Bombard Cannon
entries are what this option now decides, except on siege-target rows, where the entries always
count. Mangonels and rocket carts do not counter the Bombard Cannon; the table has no such entries
and none were added. The rocket cart lines counter nothing in the table today, so for them the option
decides only whether they escort rams.

## Game effect

None. The option is not in `SlotData.OPTIONS`, not in slot data, and has no XS constant, so adding it
needed no world version bump. Siege trains and fights in game whatever it says.

## Interactions

None with other options. Off only narrows the counters, so a target whose one fieldable counter in a
scenario was anti-unit siege goes uncountered there until something else is fieldable.

## Tests

`test_military_rules.py::TestSiegeCanCounter` - off by default; off, the Mangonel line does not
counter the Archer line nor the Bombard Cannon line the Cannon Galleon line, but both still counter
siege targets; on, all count. The Scorpion counters the Archer line either way, and off the Mangonel
does not counter the Organ Gun. Off, a Battering Ram with a Mangonel or a Rocket Cart does not
counter the Archer line; on, a ram with a Rocket Cart does. The Fire Archer, Petard and Organ Gun
lines are checked to be outside `SIEGE_TARGETS`. It mocks `can_field` so the lines each test names
are all P1 fields.

`test_slot_data_wire.py::TestLogicOnlyOptionsStayOutOfTheGame` keeps it out of `SlotData.OPTIONS` and
slot data.
