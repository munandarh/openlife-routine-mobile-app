# Animation Guidelines — OpenLife Routine

> Motion in this app exists to confirm and to reassure. It never entertains,
> and it never blocks. See [ADR 0003](adr/0003-choose-rive-for-animation.md)
> for why Rive is the tool for the few big moments.

---

## When motion earns its place

Use it for exactly four jobs:

1. **Confirmation** — a routine flips to done, a chip becomes selected.
2. **Orientation** — a page transition, a progress ring moving to a new value.
3. **Delight, sparingly** — the all-done celebration, once per day.
4. **Explanation** — an onboarding hero that shows what the app does.

If a movement does none of these, remove it. A reminder app that animates on
every rebuild feels restless, which is the opposite of the product's promise
(PRD §6.4).

## Duration and curve

The values already in `lib/`:

| Duration | Applies to |
|---|---|
| 100 ms | Button press scale |
| 180 ms | Selection state on a chip or card |
| 200–250 ms | The default for state changes; most common in the codebase |
| 300 ms | Check-circle and strikethrough |
| 350 ms | Progress ring on the primary action |
| 600–900 ms | Celebration sequence beats |

`Curves.easeOutCubic` is the house curve — sixteen of the twenty curve usages
in the app. Fast out of the gate, gentle at rest.

`Curves.easeOutBack` is reserved for a completion that should feel earned: the
check mark and the celebration. Its overshoot is the point, so do not use it
for routine state changes.

`Curves.easeInCubic` is for exits only.

Anything over one second must be interruptible, and the user must be able to
dismiss it.

## Implementation

Prefer the implicit widgets — they are cheap, they interrupt correctly, and
they need no controller lifecycle:

- `AnimatedContainer` for colour, border and size.
- `AnimatedSwitcher` with a `ScaleTransition` for swapping an icon.
- `TweenAnimationBuilder` for a value that animates to a target, such as the
  progress ring.
- `AnimatedScale` and `AnimatedOpacity` for press and reveal.

Reach for an `AnimationController` only when you need to sequence, reverse, or
drive several properties from one timeline.

Never animate inside `build()` without a stable `Tween` target — a value
recomputed on every frame animates to itself and burns frames for nothing.

## Rive

`OpenLifeRiveView` resolves artwork in three layers: a `.riv` animation, then
a static PNG from `assets/vector/`, then an icon. Every call site must pass a
`fallbackIcon`, so a missing or corrupt asset degrades instead of crashing.

Keep Rive for the moments that carry meaning:

| Moment | Intent |
|---|---|
| Onboarding heroes | Show the value of the app in one glance |
| Empty states | Make an empty screen feel intentional |
| Completion check | Confirm the tap |
| Daily celebration | Reward finishing the day |

Constraints: keep artboards small, prefer a single state machine per file, do
not loop an ambient animation on a screen the user will sit on, and never put
a Rive file on the critical path of a first paint.

## Haptics

Paired with the visual confirmation, never on their own:

| Feedback | Used for |
|---|---|
| `lightImpact` | Marking a routine done |
| `selectionClick` | Selecting a chip, snoozing |
| `mediumImpact` | Completing the whole day |

## Accessibility

Honour the platform's reduce-motion preference
(`MediaQuery.disableAnimationsOf(context)`): fall back to a cross-fade or to
no transition at all. Motion must never be the only way a state change is
communicated — the done state also changes colour, adds a badge and strikes
through the title, so it survives with animation switched off entirely.
