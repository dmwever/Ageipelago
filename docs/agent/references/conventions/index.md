# House style

House conventions for both repos, stated as rules. Each file carries the evidence.

Counter-examples are labelled as counter-examples. Do not "fix" them without asking — several are
deliberate, and the ones that are not are recorded as deviations rather than as patterns.

| File | Covers |
|---|---|
| [data-tables.md](data-tables.md) | how to read the canonical tables, and where new data goes |
| [python.md](python.md) | enums, the logic/rules split, handlers, typing, imports |
| [xs.md](xs.md) | naming, constants, rules, structs, linting |
| [testing.md](testing.md) | the two base classes, naming, and the anti-drift tests |

## The short list

1. Index the canonical tables with `[]`. Never `.get()`.
2. New items, locations, techs, buildings and scenarios go straight into the central `IntEnum`, in
   their id band. Never a side dict.
3. Import a name from the module that defines it, never through a sibling that happens to import it.
4. `AP_Constants.xs` is the single home for `extern const`. XS has no include guards.
5. Rules are *defined* in `logic/` and *attached* in `rules/`. Nothing in `logic/` calls `set_rule`.
6. Anything that can fail silently gets a test, because the compiler and the linter will not catch it.
7. Both repos are LF. A careless Python write flips them to CRLF.
