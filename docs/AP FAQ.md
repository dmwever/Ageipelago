# AP FAQ

## Setup

Do this once per seed, in this order.

1. **Install the Ageipelago files** into your Age of Empires II: DE user folder — the one at
   `C:\Users\<you>\Games\Age of Empires 2 DE\<a long string of numbers>\`. You should end up with a
   `resources\_common\` containing `campaign`, `scenario` and `xs` folders alongside the `profile`
   folder that is already there.
2. **Start the Age of Empires II: DE client** from the Archipelago launcher and connect to your
   multiworld.
3. **`/set_user_folder`** — pick the `<long string of numbers>` folder. Not `resources`, not
   `profile`, the one above both.
4. **`/install`** — this sets your install up for *this* seed. It prints each file it wrote and
   finishes with `Installed slot <n>, seed tag <tag>.`
5. **Play the campaign named with your seed tag**, e.g. `AP Joan of Arc_b435aa86`. The plain
   `AP Joan of Arc` is the untagged source and will not talk to the client.

`/install` only writes the campaigns your yaml enabled, and it never touches the untagged originals
or the `scenario` folder — so re-running it is safe, and installing a second seed leaves the first
one's files in place.
### Things the client may tell you

| Message | What it means |
|---|---|
| `Set your Age2 user folder first with /set_user_folder.` | Step 3 has not been done |
| `Connect to your multiworld first, so the install knows your seed and slot.` | `/install` needs your slot number and seed name, which only arrive once connected |
| `Could not find AP Joan of Arc.aoe2campaign in ...` | Step 1 is missing or the folder from step 3 is wrong |
| `This seed was generated with Age2 X but this client is Y.` followed by `Nothing was written.` | Your apworld and the seed disagree. Update the apworld or regenerate the seed; nothing was changed |
| `This slot has no campaigns to install.` | Your yaml enabled no campaigns |
| `Found Age2 scenarios tagged <other>; this slot expects <mine>.` | Another seed's files are installed. Run `/install` again for the seed you actually want |

### Things the game may tell you

| Message | What it means |
|---|---|
| `Waiting for Client Connection` | Normal. The scenario is up and looking for the client |
| `This install has no Archipelago slot. Connect the client and run /install.` | You are playing the untagged source campaign, or step 4 was never done |
| `Unexpected Age2 version from Client` | The installed files and the client are different versions. Reinstall |
| `These scenarios belong to a different seed or player slot.` | You are playing another seed's campaign. Launch the one matching your tag |
| `AP Client disconnected.` | The client stopped pinging. Locations and items will not move until it is back |

## Global

- Victory must be received at the AP Victory Pavilion, which can be researched once that mission's vanilla-equivalent task has been achieved.
- Many triggers contain an extra condition that requires their AP item to be found. for example, Bleda's camp, normally unlocked when beating Bleda, now addiitonally requires the Bleda's Camp item. Items can be received after meeting all other conditions.
- Most units that can be found in a map now have items. These items unlock those units in their native scenario, and eventually will be able to be spwaned in in any scenario once.

## Attila

### Attila 1: The Scourge of God

- "Attila's Camp" and "Bleda's Camp" items must be found before the player can receive their respective camp after beating/blowing off Bleda.
- Attila's Camp is not given when the player receives Bleda's Camp.
- 10 horses can be brought to the Scythian flags even if defeated or an enemy. (As of 0.1.1, the scythian flags might not be accessible until after the cmap is received. This is a buge that will be fixed next update.)
- Roman Villagers and the Scythian Mangudai are now mercenary items that need to be unlocked.

### Attila 2: The Great Ride

- "Attila: The Great Ride: Villagers" item must be found before the player can obtain villagers from destroying Purple's houses.
- Freeing the Tarkans location is awarded by destroying the Cyan castle or destroying the Cyan TC.
- Defeat Rome check be given without needing a TC.

### Attila 3: The Walls of Constantinople

- Looting no longer sends gold, but instead "AP Gold", which enables victory once 10,000 has been accumulated.
- The exception is that destroying the Red and Green Town Centers gives 3,000 gold each, but the "Red Gold" and "Green Gold" items must first be found, respectively.

### Attila 4: A Barbarian Betrothal

- The player may build a Castle in Burugndy's base at any time for a check, even after Burgundy is defeated (UNIMPLEMENTED)

### Attila 6: the Fall of Rome

- Defeating a player also gives checks for each wonder they would have otherwise built. In theory, defeating Purple before they placed either wonder gives three checks.

## Joan of Arc

### Joan of Arc 1: An Unlikely Messiah
- To receive reinforcements, the player must have unlocked their respective item from the AP world, and then must bring Joan of Arc to those units.
- Most small camps of enemies have been turned into items. Just explore the main paths to find them all.
- You need to unlock Joan of Arc: An Unlikely Messiah: Transports to cross the river.
- Spoiler: Bertrand wants some venison. There are deer located just south of the Burgundian Village.

### Joan of Arc 2: The Maid of Orleans
- To complete this scenario, the player needs to first unlock Orleans and then defeat one castle.
- There are two ways to cross the river: receive the "Joan of Arc, The Maid of Orleans: Trade Carts" item and beat the bridge guards, or receive the "Joan of Arc, The Maid of Orleans: Dock" item and find the hidden dock.
- To unlock Orleans, the player needs "Joan of Arc, The Maid of Orleans: Orleans". Bring Joan of Arc outside the main gate by the bridge to receive the city.

### Joan of Arc 3: The Cleansing of the Loire
- To cross the river, the player needs either the Dock item and houses or "Joan of Arc, The Cleansing of the Loire: Transport Ships". If you have a dock, you can build your own transports, buddy!

### Joan of Arc 5:
- Each refugee has its own item and location. To receive a refugee, it needs to be visible and the player needs to have that refugee's item.
- You can build some stuff because I am lazy. Have fun.
