# Animation Guidelines

> What moves in OpenLife Routine, what does not, and the honest current state of
> the Rive integration.

---

## 1. Principles

Animation in this app has one job: **confirm that something happened.** It is
feedback, not decoration.

| Do | Don't |
|---|---|
| Animate a state change the user caused | Animate on idle |
| Keep it under ~600 ms | Block input behind a transition |
| Reuse the same curve family | Loop anything indefinitely on a content screen |
| Give every animation an off switch | Ship a looping animation without a reduced-motion path |

Standard values used across the app:

| Purpose | Duration | Curve |
|---|---|---|
| Chip / card state | 250 ms | `easeOutCubic` |
| Check toggle | 300 ms | `easeOutBack` in, `easeInCubic` out |
| Progress ring / bar | 350–450 ms | `easeOutCubic` |
| Celebration entry | 600 ms | `easeOutBack` |
| Button press | 100 ms | `easeOutCubic` |
| Empty-state entry | 400 ms | `easeOutCubic` |

---

## 2. What is animated today

| Surface | Motion | Widget |
|---|---|---|
| Routine card | Border + fill tween on due-now; strikethrough tween on done | `RoutineCard` |
| Completion circle | Scale-switch between circle and check | `RoutineCard` |
| Daily progress | Ring sweeps to the new value | `ProgressRing` |
| Weekly chart | Bars grow from zero on load | `WeeklyBarChart` |
| Empty state | Fade + 5% rise on entry; icon pulses | `AppEmptyState` |
| Onboarding | Page slide, ring fills with step progress | `OnboardingPage` |
| All routines done | Scaled celebration card | `_CelebrationOverlay` |
| Primary button | Scale to 0.97 while pressed | `PrimaryButton` |
| Splash | Fade + rise | `SplashPage` |

Haptics pair with two of these: a light impact on completing a routine, a
medium impact when the last routine of the day lands.

---

## 3. Reduced motion

Settings → **Reduce motion** persists to `SettingsRepository.getReducedMotion()`
and is read by `SettingsBloc`.

Currently it suppresses the celebration overlay — the one animation that takes
over the screen. Haptic feedback still fires, because the confirmation should
not disappear along with the animation.

When adding a new animation, ask whether a user who turned this on would want
it. If the animation is large, looping, or covers content, gate it:

```dart
final bool reducedMotion =
    context.read<SettingsBloc?>()?.state.reducedMotion ?? false;
```

A short state tween on a control does not need gating. A full-screen celebration
does.

---

## 4. Rive: current state

**No `.riv` files ship in this repository yet.** This is the one item from
PRD §11.3 that is not implemented, and it is called out here rather than hidden.

What *is* in place:

- `rive: ^0.13.0` is a dependency.
- `OpenLifeRiveView` is a three-tier renderer: Rive artboard → PNG illustration
  → icon fallback.
- `OpenLifeAnimationAssets` declares the six MVP entries with their intended
  `assets/rive/*.riv` paths and per-entry fallback icons.
- Ten PNG illustrations in `assets/vector/` are wired through
  `AssetVectors` and render today.

So the app currently renders tier 2 (PNG) everywhere. Dropping real `.riv`
files into `assets/rive/`, registering that folder in `pubspec.yaml`, and
removing the early fallback guard in `OpenLifeRiveView.build` switches it to
tier 1 without touching any page.

### Planned assets (PRD §11.3)

| Asset | Screen | Purpose | States |
|---|---|---|---|
| `onboarding_build_better_days.riv` | Onboarding 1 | Introduce the app | idle, wave |
| `onboarding_private_by_default.riv` | Onboarding 3 | Privacy / local-first | idle, shieldPulse |
| `empty_no_routines.riv` | Today / Routines | Empty state | idle |
| `routine_done_check.riv` | Today | Completion check | playOnce |
| `daily_complete_celebration.riv` | Today | All routines complete | celebrate |
| `reminder_active_bell.riv` | Reminder card | Attention | idle, ring |

### Authoring rules for whoever builds them

- One artboard per file; name it after the file.
- State machine only when the animation reacts to app state. A play-once
  check does not need one.
- Keep each file under ~50 KB. These are illustrations, not scenes.
- Design at 1× against the palette in [`design-system.md`](design-system.md).
- Provide a sensible idle frame: it is what a paused animation shows.

---

## 5. Performance

- Nothing loops on a content screen. The only repeating animation is the empty
  state's icon pulse, and an empty screen has nothing to compete with.
- Animations are widget-level and short, so they stay off the raster critical
  path on mid-range Android hardware.
- Rive artboards, once added, must be paused when off-screen.
- `AnimatedContainer` and `TweenAnimationBuilder` are preferred over manual
  `AnimationController`s unless the animation needs to be driven or reversed.

---

## 6. Adding an animation

1. Name the state change it confirms. If you cannot, it does not belong.
2. Pick a duration and curve from the table in §1.
3. Decide whether reduced motion should suppress it.
4. Make sure the widget still renders correctly at its start and end frames —
   widget tests pump both.
5. If it needs artwork, add the entry to `OpenLifeAnimationAssets` with a
   fallback icon so the app degrades cleanly before the asset exists.
