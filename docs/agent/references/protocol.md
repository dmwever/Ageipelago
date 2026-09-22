# The client ↔ game wire protocol

The authority is `Ageipelago/docs/communication_protocol.md`. This file carries the two layouts with
ordering constraints in full, one line for each of the others, and the traps.

**Verify field counts against the code, not against any summary — including this one.** The
authoritative doc has drifted from `AP.xs` before. The game side is `AP_Write` / `AP_Read` in
`AP.xs`; the client side is `Age2Packet` and `ping_game` in `client/GameClient.py`.

There is no socket and no process attach. Everything is small binary files in
`<user folder>/profile/`, polled.

## Encoding

| Type | On the wire |
|---|---|
| int | 4 bytes, little-endian signed (`<i`) |
| bool | **4 bytes** — 1 byte plus 3 pad (`<?xxx`), so an int read works on a bool field |
| string | 4-byte length prefix, then that many **bytes** of UTF-8 |
| float | 4 bytes IEEE single. Nothing in the protocol uses one, deliberately |

Exact equality on a 32-bit float is unsafe for values that are not representable, which is why the
version travels as two ints rather than one float.

## Game → client: the scenario packet

Written by `AP_Write`, read by `Age2Packet`. One file per thing being played — the engine picks the
name, so a mission played from a campaign bundle writes `<campaign>.xsdat`.

49 fixed ints, 196 bytes, then a variable-length location list to EOF.

| # | Field | Notes |
|---|---|---|
| 1 | Active | always written as 1; the *client* writes 0 to deactivate |
| 2 | Ping | `xsGetGameTime()`, moves each tick while running and unpaused |
| 3 | WorldMajor | |
| 4 | SlotId | from `SlotData.xs`; `AP_Write` returns without creating the file while this is -1 |
| 5 | LatestMessageId | the message ack |
| 6-17 | ItemId1-12 | the game's 12-slot ring; -1 means free |
| 18 | ScenarioCompleted | |
| 19 | ScenarioId | **byte offset 72** |
| 20 | WorldMinor | first of the reserved block |
| 21 | CompletedMercenaryId | a mercenary the game finished spawning, -1 when idle |
| 22 | ConsumedQueueSerial | the `mercenary_queue.xsdat` serial the game has read, -1 before it reads one |
| 23-49 | Reserved ×27 | currently written as the loop counter, 0..26 |
| 50+ | Locations | every location checked and not yet confirmed by the client |

**Never insert a field before `ScenarioId`.** `find_active_campaign` reaches it with a hardcoded
`skip_int(fp, 18)`, and a test pins it at byte offset 72. New fields come out of the reserved block.

Note the asymmetry: in `AP.xsdat` the two version ints are adjacent; here the minor sits after
`ScenarioId`, for exactly that reason.

## Client → game: `AP.xsdat`

Written by `ping_game`, read by `AP_Read`. The control file: it proves the client is alive and tells
the game which other files to read.

| # | Field | Notes |
|---|---|---|
| 1 | ScenarioId | echoed, so the scenario can confirm the packet is meant for it |
| 2 | Ping | echoed from the game's own ping |
| 3 | WorldMajor | |
| 4 | WorldMinor | |
| 5 | SlotId | |
| 6 | SendItems | read `items.xsdat` |
| 7 | FreeItems | read `free_items.xsdat` |
| 8 | FreeLocations | read `locations.xsdat` |
| 9 | SendMercenaries | read `mercenary_queue.xsdat`. Set while the client's serial differs from `ConsumedQueueSerial`, so it clears on acknowledgement rather than on client state |
| 10 | SendMessages | read `messages.xsdat` |
| 11 | ScenarioCompleted | written back into the running game, which then echoes it out again |
| 12 | AckMercenaryId | echoes `CompletedMercenaryId` back, so the game drops it from the ledger |

`AP_Read` validates in order — scenario, ping, version, slot — and returns on the first failure, so no
dispatch flag is acted on until identity checks pass. An unchanged ping also returns early.

Each flag arms a one-shot rule (`ReadItems`, `FreeItems`, `MarkServerLocations`, `ReadMercenaries`,
`ReadMessages`) that disables itself on every exit path, including a failed open.

## The other files

All client → game, all in the profile folder, all fixed names (no seed tag).

| File | Contents | Read by |
|---|---|---|
| `items.xsdat` | up to 12 unacked item ids | `ReadItems` |
| `free_items.xsdat` | echoed ids the client no longer has in flight | `FreeItems` |
| `locations.xsdat` | every location the client has checked | `MarkServerLocations` |
| `startup.xsdat` | starting-resource and town-centre-resource item ids, re-synced every pass | `ItemHandler.xs` |
| `buildings.xsdat` | item ids of every unlocked building | `ItemHandler.xs` |
| `techs.xsdat` | item ids of every unlocked technology | `ItemHandler.xs` |
| `messages.xsdat` | count, then id + length-prefixed text per message | `ReadMessages` |
| `mercenary_queue.xsdat` | a serial, then one fixed record per seat | `ReadMercenaryQueue` |
| `ATT1.xsdat` … `ATT6.xsdat`, `JOAN1.xsdat` … `JOAN6.xsdat` | a completed flag, then item ids to grant at level start | `ReadScenarioItemFile` |

An earlier `units.xsdat` was specified but never implemented. Its `SendUnits` flag became
`SendMercenaries`, and nothing on either side reads or writes a unit buffer now. The stale
`units.xsdat NOT IMPLEMENTED` section has since been removed from `communication_protocol.md`; only a
one-line mention under `SendMercenaries` remains.

## The 12-item window

The only part of the protocol with real handshake semantics.

1. The client writes a window of up to 12 unacked item ids to `items.xsdat`, but only when every one
   of the 12 echoed slots reads -1, and only if the window differs from what it already sent.
2. The game takes an item into slot `i` only if slot `i` is free, calls `GiveItem`, and echoes the
   full ring back in the next packet.
3. `ack_items` walks the in-flight list against the echoed ids, removing **one occurrence per id** and
   stopping at the first in-flight id not echoed. Per-occurrence matching is deliberate: several
   copies of the same filler id in one window would otherwise be collapsed into a single ack.
4. `free_items` lists every echoed id the client no longer holds in flight, which the game then clears
   from its ring. Because an id leaves the in-flight list when it is acked, freeing lags the ack by
   one pass; ids from a previous session are freed by the same path. In the steady state this file is
   written empty.

## The mercenary queue

Client → game, `mercenary_queue.xsdat`: a serial, then one fixed record per seat **in seat order**, so
emptying a seat does not shift the others.

```
Serial          int
per seat ×4:
  MercenaryId   int    -1 when empty
  NameStringId  int    -1 when empty
  IconId        int    -1 when empty
  UnitCount N   int    0 when empty
  UnitIds       int×N  one entry per soldier
```

The record is self-describing: the game takes the squad's name, icon and unit ids straight off the
wire and keeps no table of its own.

Acknowledgement runs both ways at once:

- The client bumps `Serial` only when the seat bytes actually change, and raises `SendMercenaries`
  while its serial differs from the `ConsumedQueueSerial` the game reports. The flag therefore clears
  on the game's acknowledgement, not on client state.
- The game publishes a finished mercenary as `CompletedMercenaryId` every tick until the client echoes
  it back in `AckMercenaryId`, at which point it pops the ledger and may name the next one. The ledger
  holds at most four, one per seat.

Both sides repeat the same value while an acknowledgement is outstanding, deliberately, so a dropped
tick self-heals.

## Identity

Two directions, two mechanisms, because the game cannot choose its own output filename.

**Game → client: the filename.** `xsCreateFile` takes no name — the engine names the file after what
is being played. So `/install` seed-tags the installed campaign:

```
tag = crc32("<seed_name>:<slot>")              8 lowercase hex digits
AP Joan of Arc Template.aoe2campaign           shipped source; read by /install, never written
AP Joan of Arc_<name>_<tag>.aoe2campaign       installed
AP Joan of Arc_<name>_<tag>.xsdat              written by the game while playing
```

`crc32`, not Python's `hash()`, which is salted per process and would differ between the generator and
the client. The player name is cosmetic and sits **before** the tag so the tag stays the last segment,
which is what `TAGGED_XSDAT` (`^AP[ _].*_([0-9a-f]{8})\.xsdat$`) and `Identity.tag_of` match on. Only
the campaign name is tagged: playing a mission from a bundle writes `<campaign>.xsdat`, so the
scenarios inside never affect the binding.

**Client → game: `SlotData.xs`.** The client's own files have fixed names, so no tag can ride there.
Instead `/install` writes `resources/_common/xs/SlotData.xs`, which `AP.xs` includes, carrying the slot
number and the seed halves. One seed is armed at a time — the include name is fixed — so installing
another seed re-arms it and the previous seed's campaigns then report a slot mismatch. That is
intended, not a bug.

`AP_SEED_HIGH` / `AP_SEED_LOW` are the 32-bit tag split into 16-bit halves, because an XS int cannot
hold a literal above 999,999,999 and is 32-bit signed besides. Reassemble as `(HIGH << 16) | LOW`.
They are diagnostics only — the packet has no room for a seed — except that `TechData.xs` carries the
same halves and `InitTechsanity` refuses to run if the two disagree.

## Versioning

One concept: `world_version` in `archipelago.json`. The client derives its copy; `AP.xs` declares
`worldMajor` / `worldMinor` because the shipped mod files are the thing being version-checked. A test
parses `AP.xs` and fails if they drift — but it skips unless `AGEIPELAGO_PATH` is set.

Compatible means **major and minor match**; build is free.

| Check | Compares |
|---|---|
| client ↔ seed | `world_version` in slot_data against the client's own; `/install` refuses on mismatch |
| client ↔ installed files | `WorldMajor` / `WorldMinor` in the packet; reported once, then the exchange stops |

A stale install still writing the old float version is detected rather than misread: `6.5` and `7.0`
reinterpreted as int32 are `1087373312` and `1088421888`, neither of which resembles a version.

## Traps

- **Nothing is atomic on either side.** A reader polling a file its writer rewrites every tick can see
  a torn read. Do not assume a whole record.
- **A zero-length file reads as empty, not as absent.** A non-zero first byte is not proof of a valid
  payload; test the value or check the size.
- **A missing file just returns false from the open**, which is what makes poll-until-it-appears the
  standard pattern here.
- **Reading a malformed length-prefixed string can crash the game outright.** `ReadMessages` keeps a
  commented-out defensive block for hunting exactly that, with a warning not to delete it.
  `MessageHandler._parse_evil_characters` also rewrites `%` and `è` in outgoing text.
- **There is no save/load API**, so identity has to be built into the install rather than remembered.
  On load, the client re-sends everything.
- Client-side write failures are swallowed by `except Exception: print(ex)`, and `print` does not
  reach the client's GUI log panel.
