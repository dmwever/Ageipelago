# `shuffle_unique_techs`

## What the player sets

`ShuffleUniqueTechs(Choice)`, display name "Shuffle Unique Techs". `option_unshuffled = 0` (default),
`option_shuffled = 1`, `option_shuffled_everywhere = 2`. Requires techsanity.

> Whether civilization unique technologies join the pool. Requires Techsanity.
> Unshuffled: Unique technologies behave as vanilla.
> Shuffled: Unique technologies are shuffled. A unique technology's effect only applies while you
> are playing a civilization that has it.
> Shuffled Everywhere: As above, but the effect applies to whichever civilization you are playing.
> No setting ever lets a civilization research another civilization's unique technology.

## Generation effect

`TechPool.is_unique_shuffled()` passes every non-unique tech, and passes a unique tech only when the
value is not `option_unshuffled`.

## Game effect

XS constant **`AP_TS_UNIQUES`**, default `UNSET`. Used once, in `Techsanity.xs::deferEffect()`:

```
if (AP_TS_UNIQUES == UNIQUES_UNSHUFFLED || AP_TS_UNIQUES == UNIQUES_SHUFFLED_EVERYWHERE) return false;
```

So "shuffled everywhere" is implemented purely as never deferring an effect because of a civ mismatch.

## Interactions

**Split-brain by design.** Python treats `shuffled` and `shuffled_everywhere` identically, both simply
"not unshuffled", and only the XS side distinguishes value 2. Generation decides whether a unique tech
is a location; the game decides whether its effect applies to the civ being played. Renumbering either
enum alone silently changes the meaning.

The promise that no civ can research another civ's unique tech is enforced elsewhere, by `TechPool`'s
researchable set built from `CIV_TO_TECHS`.

## Tests

`test_tech_pool.py::TestTechPool::test_uniques_join_only_when_shuffled`,
`test_tech_options.py::TestTechsanityWithUniquesShuffled`.
