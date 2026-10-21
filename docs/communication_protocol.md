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
AP Joan of Arc Template.aoe2campaign           shipped source, read by /install, never written
AP Joan of Arc_<name>_b435aa86.aoe2campaign    installed by /install
AP Joan of Arc_<name>_b435aa86.xsdat           written by the game while playing
```

`crc32` deliberately, not Python's `hash()`, which is salted per process and would differ between
the generator and the client. Only the **campaign** name is tagged: playing a mission from a campaign
writes `<campaign>.xsdat`, so the scenario entries inside the bundle never affect the binding.

The player name is cosmetic — it is there so a player with several seeds installed can find
their own campaign in the in-game list without decoding hex. It carries no identity; the tag
still does all the binding. It sits **before** the tag so that the tag remains the last
segment, which is what `Identity.tag_of` matches on. Archipelago does not keep slot names
legal on disk, so `Identity.sanitize_player` strips the reserved characters first; a name that
survives as nothing is refused at generation, and a name that merely changes is warned about
at generation and again at `/install`.

Because the engine derives the `.xsdat` name from the installed campaign, this filename is not
decoration: `CampaignHandler.campaign_read_name` has to compose exactly the same stem, player
segment included, or the client never finds the active scenario.

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
game which other files to read. In `items.xsdat` the client writes a window of item ids addressed to
the game's own delivery cursor; the game applies it only if the address matches, then advances the
cursor.

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
|21|CompletedMercenaryId|int|A mercenary the game has finished spawning, `-1` when idle. Second of the reserved block. The game holds any others until this one is acknowledged; see *Mercenaries*|
|22|ConsumedQueueSerial|int|The serial of the `mercenary_queue.xsdat` this game has read, `-1` before it has read one. Third of the reserved block|
|23-49|Reserved|int*27|Reserved for future use, currently written as `0..26`|
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
|6|SeedHigh|int|High 16 bits of the client's seed tag, or `-1` before it has one|
|7|SeedLow|int|Low 16 bits of the same|
|8|SendItems|bool|If 1, the game reads `items.xsdat`|
|9|FreeLocations|bool|If 1, the game reads `locations.xsdat`|
|10|SendMercenaries|bool|If 1, the game reads `mercenary_queue.xsdat`. Set while the client's queue serial differs from `ConsumedQueueSerial`, so it clears on acknowledgement rather than on client state. Was `SendUnits`, which was never implemented and hardcoded to 0|
|11|SendMessages|bool|If 1, the game reads `messages.xsdat`|
|12|ScenarioCompleted|bool|Writes scenario-completion state *back into* the running game, which `AP_Write` then echoes out again|
|13|AckMercenaryId|int|Echoes `CompletedMercenaryId` back. The game drops that mercenary from its pending list and may then name the next one|

`AP_Read` validates in order — scenario, ping, version, slot, seed — and returns early on the
first failure, so no dispatch flag is acted on until the identity checks have passed.

### Mercenaries

A mercenary is spent the moment the game finishes spawning it, and that has to survive a reconnect,
so it crosses as a two-flag ledger in the same shape as scenario locations.

The game names one finished mercenary at a time in `CompletedMercenaryId`. The client acts on it and
echoes the id back in `AckMercenaryId`; the game then drops it from `MercenaryLedger.xs` and is free
to name the next. Only one id fits in the packet, so a second mercenary finishing before the first is
acknowledged waits — at most four can be pending, because a seat cannot be refilled until the client
sends a new queue.

Both sides send the same value repeatedly while an acknowledgement is in flight. That is deliberate:
the client's `Set` writes the whole spent mask with the server-side `replace` operation and the
game's `AckMercenary` ignores an id that is not at the head, so a repeat costs nothing and a dropped
tick is recovered on the next one.

`replace` rather than `or` because the client's `APData/mercenaries_<player>_<tag>.json` is
authoritative for what has been spent, and `or` is monotonic -- it can add a spend but never
correct one. The server remains authoritative for what has been *unlocked*. One consequence worth
knowing: two clients on the same slot would now clobber each other rather than merge.

### `items.xsdat`

Client -> Game

The game reads these items one at a time. Each item here will have a corresponding xsScript waiting for the itemId based on the type of item. If itemId1 is a tech, it will unlock that respective tech for the player that corresponds to that itemId.

A leading `WindowBase` names the cursor the window was written for, followed by the entries
themselves. The game applies the window only when `WindowBase` equals its own `AppliedItemCount`,
all of it or none, and then advances that count by what it read. A window addressed to any other
cursor is a leftover and is ignored, which is what makes re-reading the file harmless.

Entries the client has already paid out — a trap or a filler resource it has a record of
delivering, or a mercenary the pavilion has spawned — are replaced in place by `AP_ITEM_SKIP`
(`-2`). The window is positional, so they cannot simply be dropped: every later entry would shift
and the cursor would stop meaning what both sides think it means. `GiveItem` returns early on the
sentinel.

Variable length, at most `AP_ITEM_WINDOW` (64) entries.

|Name|Type|Purpose|
|---|---|---|
|WindowBase|int|The `AppliedItemCount` this window starts at|
|ItemIds (I)|int*I|Item ids, or `AP_ITEM_SKIP` for an entry already paid out|


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

### `techs.xsdat`

Client -> Game. Read by `ItemHandler.xs`.

Every unlocked technology item, rewritten whenever the unlocked set changes. `GiveStartupTechs`
re-reads it on each connect, so a reconnect cannot strand a technology.

|Name|Type|Purpose|
|---|---|---|
|ItemIds (I)|int*I|Item ids of every unlocked technology|

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

### `mercenary_queue.xsdat`

Client -> Game. Read by `MercenarySeats.xs`.

The four pavilion seats, **one record per seat in seat order**, so position is the seat and an
emptied seat does not shift the others. Each record is self-describing: the unit count is what tells
the reader where one seat ends and the next begins, so nothing has to be installed alongside it and
kept in agreement.

`NameStringId` and `IconId` are indices into the Ageipelago mod, which ships the matching string and
texture. The game holds no table to check them against -- a wrong one is a wrong name or picture on
the seat button, never an error.

|Name|Type|Purpose|
|---|---|---|
|Serial|int|Advances only when the seats change. Echoed back as `ConsumedQueueSerial`|
|MercenaryId|int|`-1` for an empty seat|
|NameStringId|int|Modded string id, applied with `cAttrSetName`. `-1` when the seat is empty|
|IconId|int|Modded tech icon index, applied with `cAttrSetIcon`. `-1` when the seat is empty|
|UnitCount (N)|int|Soldiers in this mercenary. `0` when the seat is empty|
|UnitIds|int*N|One id per soldier|
|...|...|Repeated four times, once per seat|

### `<SCENARIO_SHORTHAND>.xsdat`

Client -> Game. `ATT1`-`ATT6`, `JOAN1`-`JOAN6`.

Each scenario has a shorthand file containing found items to be sent at level start, as well as a completion status for the scenario. Read by `ReadScenarioItemFile`, whose name is hardcoded in each `AP_<Campaign>_<n>.xs`.

|Name|Type|Purpose|
|---|---|---|
|Completed|int|If 1, set the scenario global `completed = true`|
|ItemIds (I)|int*I|Id of item to unlock on level start|

### `SlotData.xs`

Client -> Game, but **not** an `.xsdat` file.

Written by `/install` into `resources/_common/xs/`, and `include`d by `AP.xs`. A default ships with
the mod so a fresh install fails with a legible in-game message rather than an unresolved-include
error. It declares `-1` for the identity fields — `AP_SLOT_ID`, `AP_SEED_HIGH`, `AP_SEED_LOW` — and
`0` for the option fields, so an install that `/install` has never touched reads as "no slot" and as
every option off, rather than as a valid option value.

```xs
extern const int AP_SLOT_ID = 2;
extern const int AP_SEED_HIGH = 46133;
extern const int AP_SEED_LOW = 43654;
```

|Name|Purpose|
|---|---|
|`AP_SLOT_ID`|The AP slot number. `-1` means this install was never set up. `AP_Write` writes it into the packet and `AP_Read` compares it|
|`AP_SEED_HIGH` / `AP_SEED_LOW`|The 32-bit seed tag as two 16-bit halves. The client sends the same two halves in the ping packet and `AP_Read` compares them, which is what catches an install from one seed being played against another — the slot id cannot, since every solo seed is slot 1|

The halves are split because an XS `int` cannot be initialised to a literal above `999_999_999`, and
is 32-bit signed besides; the full tag fits in neither. Reassemble as `(HIGH << 16) | LOW`.

One seed is armed at a time: `SlotData.xs` cannot be tagged, since `AP.xs` includes it by a fixed
name. Installing another seed re-arms it, and the previous seed's still-installed campaigns then
report a slot mismatch — which is the intended behaviour, not a bug.
