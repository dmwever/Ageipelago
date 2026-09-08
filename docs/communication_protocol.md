# Communication Protocol

Age of Empires II: Definitive Edition does not have a known way of reliably attaching to the game process and reading and writing data. Due to this, I long believed that there would be no way for communication to occur between AoE2 and AP.

However, thanks to the help of discord users @phaneros and @Epid, I was able to find a method to interact between the game client and AP using AoE2's built-in xs-scripts. The following is the client-game communication protocol, inspired loosely by phaneros' work [here for Warcraft III.](https://github.com/MatthewMarinets/war3-ap-maps/blob/main/doc/communication_protocol.md)

## .xsdat Formatting

`.xsdat` files can be injected by the client and read using xsScripts in the game.

.xsdat files are formatted as follows, and all reads are assumed to be the correct typing:

An `integer` is read FIFO into four bytes. So `222225` would be stored by AoE2 as `0x11 0x64 0x03 0x00`, and would be read back as `0x00 0x03 0x64 0x11`.

A `bool` occupies four bytes, not one — the client writes it as `<?xxx`. It is therefore
interchangeable with an `int` on the wire, and the XS side reads several of them with `xsReadInt`.

A `float` is stored into four bytes as well, as a 32-bit IEEE single. **Nothing in the protocol uses
one any more**, deliberately: exact equality on a 32-bit float is not safe for values that are not
representable, and the version field used to be a float for that reason. See *Versioning* below.

The same goes for `Vectors`, which are stored in 12 bytes, 4 for each component (X,Y,Z).

A `string` is stored with 4 bytes, FIFO, for the length, and the string is located immediately after, read left to right for the length in the first 4 bytes.

## Identity — which seed and which player

A playthrough is bound to the seed and slot it belongs to, so that a client for one seed cannot
attach to an install built for another. This happens in two places, because the two directions can
carry different things.

**Game → client: the filename.** `xsCreateFile` takes no filename — a scenario writes to the file in
`$USER\Games\Age of Empires 2 DE\$STEAM_PROFILE\profile` named after *the thing being played*. That
name is imposed by the engine, so it already carries identity, and the client installer seed-tags it:

```
tag = crc32("<seed_name>:<slot>")            8 lowercase hex digits
AP Joan of Arc_b435aa86.aoe2campaign         installed by /install
AP Joan of Arc_b435aa86.xsdat                written by the game while playing
```

`crc32` deliberately, not Python's `hash()`, which is salted per process and would differ between
the generator and the client. Only the **campaign** name is tagged: playing a mission from a campaign
writes `<campaign>.xsdat`, so the scenario entries inside the bundle never affect the binding.

**Client → game: `SlotData.xs`.** The files the client writes have fixed names on both ends, so a tag
cannot ride there. Instead the slot number is baked into an XS file that `AP.xs` includes, and
compared over the packet. See *SlotData.xs* below.

## Versioning

There is **one** version concept: the apworld's `world_version`, declared in
`age2de/archipelago.json` and nowhere else on the client side. The client derives `AP_WORLD_VERSION`
from it; `AP.xs` carries the only other copy (`worldMajor` / `worldMinor`), because the shipped mod
files are the thing whose version is being checked and so have to declare it. A test parses `AP.xs`
and fails if the two drift.

Two versions are compatible when **major and minor match**; build is free to differ. The same rule
covers both checks:

| Check | Compares |
|---|---|
| client ↔ seed | `world_version` in `slot_data` against the client's own. `/install` refuses on a mismatch |
| client ↔ installed files | `WorldMajor` / `WorldMinor` in the packet. A mismatch is reported once and stops the exchange |

The version travels as **two ints**, not a float. A stale install still writing the old float is
detected rather than misread: `6.5` and `7.0` reinterpreted as int32 are `1087373312` and
`1088421888`, neither of which can be confused with a real version.

Note the asymmetry in where the minor sits. In `AP.xsdat` the two are adjacent; in the game's own
packet the minor is the **first reserved int**, after `ScenarioId`. That is not arbitrary — inserting
a field before `ScenarioId` would move it off byte offset 72, which `find_active_campaign` reaches
with a hardcoded `skip_int(fp, 18)`.

## Client -> Game

A scenario can read an arbitrary number of `.xsdat` files from the `$USER\Games\Age of Empires 2 DE\$STEAM_PROFILE\profile` folder using `xsScript`. This allows different files to be used for different purposes on the client side, with each scenario sharing methods for common access.

For example, the client loads into `AP.xsdat` a current ping value and a set of flags telling the
game which other files to read. In `items.xsdat` the client writes a list of item ids; the game reads
each one and processes it.

These filenames are hardcoded on both sides and are **not** seed-tagged.

## Game -> Client

Each scenario writes to one location, and one location only: the file in `$USER\Games\Age of Empires 2 DE\$STEAM_PROFILE\profile` with the same name as the thing being played. Played from a campaign bundle, a mission writes `<campaign>.xsdat`; played as a loose scenario it writes `<scenario>.xsdat`. Fortunately, the workaround to this is not too unbearable. We simply write a scenario active flag and a current ping to the first few bytes.

When no scenario is opened, the Client scans the `.xsdat` files it expects — those carrying its own
seed tag — looking for an active flag. Once an active flag is found, the client connects to the
selected scenario. As long as the current ping is updated, the Client recognises that the scenario is running.

If the scenario becomes inactive due to the game closing or an extended pause, the Client sets the active flag to false, and begins checking that `.xsdat` file every second, while also occasionally checking each other unlocked scenario in case the user has changed scenarios.

If neither detector finds anything for several seconds, the client globs the profile folder and
compares tags, so that "the wrong seed is installed" can be told apart from "the game is not
running" — the two are otherwise indistinguishable from the client's side.

## Game -> Game

Each scenario can also read from its own file. I'm not sure what the use cases for this might be. There may be reasons the game will want to check its own state before unlocking certain things.

## Save and Load

The client/game handshake must be reestablished upon loading.

Items from the last save must be re-sent from the client. Many items, such as techs, are simply flags that are read by the game, but most filler items will need to be loaded upon client reconnection.

The game cannot persist anything across sessions — there is no save/load API — which is why its
identity has to be *built in* rather than remembered.

## Packets

### `<CAMPAIGN>_<tag>.xsdat` / `<SCENARIO>_<tag>.xsdat`

Game -> Client. Written by `AP_Write`, read by `Age2Packet`.

49 fixed fields (196 bytes), then a variable-length location list to EOF.

|#|Name|Type|Purpose|
|---|---|---|---|
|1|Active|bool|Whether the current scenario is running (0 or 1)|
|2|Ping|int|`xsGetGameTime()`, updated each rule tick while running and unpaused|
|3|WorldMajor|int|Major `world_version` of the installed Age2 files|
|4|SlotId|int|The AP slot this install was set up for, from `SlotData.xs`|
|5|LatestMessageId|int|The ID of the latest played message, assumes all previously sent messages have been played in order|
|6-17|ItemId1-ItemId12|int*12|The most recent item packet Ids received by the game|
|18|ScenarioCompleted|bool|Scenario global `completed`, 1 if the scenario has been completed|
|19|ScenarioId|int|The id of the scenario, used when the player is playing a campaign. **Byte offset 72** — `find_active_campaign` depends on this|
|20|WorldMinor|int|Minor `world_version`. First of the reserved block; see *Versioning*|
|21-49|Reserved|int*29|Reserved for future use, currently written as `0..28`|
|50+|Locations (L)|int*L|All locations checked that have not been confirmed by AP client|

`AP_Write` returns without creating the file at all while `AP_SLOT_ID` is `-1`, so the client never
sees a packet from an install that `/install` has not set up.

### `AP.xsdat`

Client -> Game. Written by `ping_game`, read by `AP_Read`.

Confirms that the client is still connected, and tells the game which other files to read.

|#|Name|Type|Purpose|
|---|---|---|---|
|1|ScenarioId|int|Echoed back so the scenario can confirm the packet is meant for it|
|2|Ping|int|Echoed from the game's own ping|
|3|WorldMajor|int|Major `world_version` of the client|
|4|WorldMinor|int|Minor `world_version` of the client|
|5|SlotId|int|The slot the client is connected as|
|6|SendItems|bool|If 1, the game reads `items.xsdat`|
|7|FreeItems|bool|If 1, the game reads `free_items.xsdat`|
|8|FreeLocations|bool|If 1, the game reads `locations.xsdat`|
|9|SendUnits|bool|If 1, the game reads `units.xsdat`. **Always 0** — see *units.xsdat* below|
|10|SendMessages|bool|If 1, the game reads `messages.xsdat`|
|11|ScenarioCompleted|bool|Writes scenario-completion state *back into* the running game, which `AP_Write` then echoes out again|

`AP_Read` validates in order — scenario, ping, version, slot — and returns early on the first
failure, so no dispatch flag is acted on until the identity checks have passed.

### `items.xsdat`

Client -> Game

The game reads these items one at a time. Each item here will have a corresponding xsScript waiting for the itemId based on the type of item. If itemId1 is a tech, it will unlock that respective tech for the player that corresponds to that itemId.

Variable length, **at most 12** — the client sends the window of items AP has granted that the game
has not yet acked, not a fixed twelve.

|Name|Type|Purpose|
|---|---|---|
|ItemIds (I)|int*I|Ids of up to 12 unacked items|

### `free_items.xsdat`

Client -> Game

The client echoes back the items that have been successfully received by the game. The game frees item slots in its local cache, allowing new items to be loaded into the game and activated.

|Name|Type|Purpose|
|---|---|---|
|ItemIds (I)|int*I|The non-empty entries of `ItemId1-12` from the last packet|

### `locations.xsdat`

Client -> Game

The game reads a location file that echoes back the locations sent in past packets from the scenario packet. These locations are freed from the game's memory so that they will not continue to be sent in future packets.

|Name|Type|Purpose|
|---|---|---|
|Locations (L)|int*L|Every location the client has checked|

### `startup.xsdat`

Client -> Game. Read by `ItemHandler.xs`.

Resource items to apply at scenario start, re-synced every tick so a reconnect cannot strand them.

|Name|Type|Purpose|
|---|---|---|
|ItemIds (I)|int*I|Starting-resource and town-centre-resource item ids|

### `buildings.xsdat`

Client -> Game. Read by `ItemHandler.xs`.

|Name|Type|Purpose|
|---|---|---|
|ItemIds (I)|int*I|Item ids of every unlocked building|

### `messages.xsdat`

Client -> Game

AP chat lines to display in game. The client will not overwrite this file while messages are still
unacknowledged; `LatestMessageId` in the scenario packet is the ack.

|Name|Type|Purpose|
|---|---|---|
|Count|int|How many messages follow|
|MessageId|int|Id of this message, compared against `LatestMessageId`|
|Message|string|Length-prefixed text, with characters the engine dislikes stripped|
|...|...|Repeated `Count` times|

### `units.xsdat` NOT IMPLEMENTED

Client -> Game

`SendUnits` is hardcoded to 0 in `ping_game` and the game's `units` flag is read and discarded, so
none of the following happens yet. The scenario packet has **no** unit-buffer fields — earlier
revisions of this document listed `CurrentUnitBufferId` and `CurrentUnitBufferRemaining` in the
layout, and they were never written.

The intent: units will be loaded into the game by spawning at a predetermined "safe" location via a "buffer". For example, if an item contains 1 Militia and 1 Scout, such as the transport troop from the Joan mission **Seige of Paris**, `units.xsdat` will be a queue-loaded buffer of unit ids, read one-by-one until the in-game unit buffer reaches zero. The client would wait to receive a 0 in `CurrentUnitBufferRemaining` before loading the next buffer item.

Implementing it needs two new fields in the scenario packet. Take them from the reserved block — do
**not** insert them before `ScenarioId`.

|Name|Type|Purpose|
|---|---|---|
|CurrentBufferItemId|int|Tells the game what the current buffer item is|
|NumberOfUnits|int|Tells the game how many units are in this item|
|UnitIds|int*NumberOfUnits|The ids of the units to be spawned in order|

### `<SCENARIO_SHORTHAND>.xsdat`

Client -> Game. `ATT1`-`ATT6`, `JOAN1`-`JOAN6`.

Each scenario has a shorthand file containing found items to be sent at level start, as well as a completion status for the scenario. Read by `ReadScenarioItemFile`, whose name is hardcoded in each `AP_<Campaign>_<n>.xs`.

|Name|Type|Purpose|
|---|---|---|
|Completed|int|If 1, set the scenario global `completed = true`|
|ItemIds (I)|int*I|Id of item to unlock on level start|

### `SlotData.xs`

Client -> Game, but **not** an `.xsdat` file.

Written by `/install` into `resources/_common/xs/`, and `include`d by `AP.xs`. A default shipping with
the mod declares `-1` for everything, so a fresh install fails with a legible in-game message rather
than an unresolved-include error.

```xs
extern const int AP_SLOT_ID = 2;
extern const int AP_SEED_HIGH = 46133;
extern const int AP_SEED_LOW = 43654;
```

|Name|Purpose|
|---|---|
|`AP_SLOT_ID`|The AP slot number. `-1` means this install was never set up. `AP_Write` writes it into the packet and `AP_Read` compares it|
|`AP_SEED_HIGH` / `AP_SEED_LOW`|The 32-bit seed tag as two 16-bit halves. **Diagnostics only** — the packet has no room for a seed, so these exist so the game can name the seed it belongs to|

The halves are split because an XS `int` cannot be initialised to a literal above `999_999_999`, and
is 32-bit signed besides; the full tag fits in neither. Reassemble as `(HIGH << 16) | LOW`.

One seed is armed at a time: `SlotData.xs` cannot be tagged, since `AP.xs` includes it by a fixed
name. Installing another seed re-arms it, and the previous seed's still-installed campaigns then
report a slot mismatch — which is the intended behaviour, not a bug.
