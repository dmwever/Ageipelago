# XS conventions

Engine-level facts — signatures, constant values, silent-failure classes — live in the `aoe2-modding`
skill and its `XS_MEASURED_BEHAVIOR.md`. This file is house style only.

## Naming

- Public functions: `PascalCase` — `GiveItem`, `UnlockTech`, `InitAP`, `ReadMercenaryQueue`.
- Locals and internal helpers: `camelCase` — `itemId`, `techArray`, `clientPing`, `seatSpawned`.
- Constants: `SCREAMING_SNAKE_CASE`, declared `extern const`.
- One-shot item glue: `PascalCase()` setter plus `HasX()` getter. Older Attila-era entries in
  `ProgressionItems.xs` use `SCREAMING_SNAKE` names instead. Write new code the current way; leave the
  old names alone.

## `AP_Constants.xs` is the single home for `extern const`

There are no include guards, so a constant defined in two files that both reach one scenario is a
build break. `Tech_Constants.xs` existed separately and its constants were folded back into
`AP_Constants.xs`; keep it that way.

Constants are grouped under `/* Section */` headers with `//` sub-headers, mirroring the Python
`BuildingOption` tags. Comments carry the reasoning:

```
// cAttrSetState values. Float, because ints are not promoted in a call.
// Genie names mislead: 101 is "Middle Age" but grants Feudal.
```

## The one-shot flag pattern

```
bool joan5Refugee1 = false;
void Joan5Refugee1() { joan5Refugee1 = true; }
bool HasJoan5Refugee1() { return (joan5Refugee1); }
```

Dispatched from a single `switch(itemId)`. **None of the item switches has a `default`**, so an
unhandled id is silently dropped — safe only because the apworld never sends one.

## Rules

Declare `inactive`, enable explicitly with `xsEnableRule`, and for one-shot work call `xsDisableSelf()`
on **every** exit path including a failed file open. Long-lived pollers take `group <Subsystem>` and
either `highFrequency` or `minInterval 1 maxInterval 1`.

`ConnectAP` is the canonical bootstrap: poll until the client answers, do the one-time work, enable the
steady-state rule, disable itself.

A poller with no terminal state — `TechsanityUpdate`, `BuildsanityChecks`, `MercenarySpawnLoop` — runs
for the session. One with a terminal state — `ShuffleAgesUpdate` — self-disables.

## Shape of a file-touching function

Open, guard, work, close, with early returns:

```
bool opened = xsOpenFile("items");
if (opened == false) { xsDisableSelf(); return; }
...
xsCloseFile();
```

## Struct fields are strings

Spelled once in `defineStructAttribute`, then repeated verbatim at every access. They are matched at
runtime, case-sensitively, and a typo returns `-1` with no error. Grep every occurrence when renaming.

Prefer `1.0 * value` over `value * 1.0` when a float is needed — the first-operand type rule makes the
latter an int.

## Linting

```
./xs-check.exe -I . -- AP_Attila_1.xs
```

Dropping `-I` gives an `UnresolvedInclude` plus a cascade of `NameError`s, which reads like real
breakage; dropping only the `--` prints usage, because `-I` is variadic and eats the filename. See the
Linting section of `xs-mod.md` for the full table.

**Lint the twelve scenario entry points, not the library files.** Only an entry point pulls the whole
include chain; `ItemHandler.xs` alone reports 139 `NameError`s for constants that `AP.xs` includes one
level up. A clean entry point reports **0 errors and 3 warnings**, identical across all twelve, and
the warnings are all `DiscardedFn` from ignored return values.

`// xsc-ignore: <Rule>` is the escape hatch — smallest possible scope, always with a reason.

## Experiments

Spike in a throwaway file and gitignore it — `.gitignore` carries entries for several `TS_*Spike.xs`.
Do not experiment inside a live module.
