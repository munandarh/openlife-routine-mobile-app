# OpenLife Routine — Animation Guidelines

> **Product:** OpenLife Routine  
> **Animation Engine:** Rive  
> **Design Concept:** Calm Daily Companion  
> **Animation Guidelines Version:** v1.0

---

## 1. Animation Purpose

Animation in OpenLife Routine should help the user understand state, progress, and completion.

Animation should not exist only for decoration.

The app should feel calm, warm, and alive, but never noisy or distracting.

Main animation goals:

1. Make onboarding more friendly.
2. Make empty states feel less cold.
3. Make routine completion satisfying.
4. Make reminders feel noticeable but not stressful.
5. Make daily progress feel visible.
6. Improve perceived product quality for portfolio presentation.

---

## 2. Animation Principles

### 2.1 Calm, not noisy

Use slow, soft motion. Avoid constant movement across the whole screen.

### 2.2 Purposeful, not decorative

Every animation must answer one of these questions:

- What changed?
- What should the user do next?
- What progress did the user make?
- What state is the routine in?

### 2.3 Lightweight, not heavy

Animations must not make the app feel slow.

### 2.4 Supportive, not childish

The app can feel friendly but should still look professional.

### 2.5 Safe fallback

Every Rive animation should have a static fallback.

---

## 3. Where to Use Rive

Rive should be used for high-value visual moments.

Recommended Rive usage:

| Area | Rive Usage | Priority |
|---|---|---|
| Onboarding | Main animated illustration | P0 |
| Empty state | Calm looping illustration | P0 |
| Mark as done | Check success animation | P0 |
| Daily complete | Celebration animation | P0 |
| Reminder active | Gentle bell/pulse animation | P1 |
| Privacy screen | Local-first trust illustration | P1 |
| Template detail | Category illustration | P2 |
| Loading state | Minimal breathing animation | P2 |

Do not use Rive for every icon or every card.

---

## 4. Where to Use Flutter Native Animation

Use Flutter native animation for small UI transitions.

Recommended Flutter animation usage:

- Button press scale.
- Card status transition.
- Progress ring update.
- Bottom navigation active tab.
- Form field focus.
- Snackbars.
- Page transitions.
- List item insert/remove.

This keeps the app performant and avoids unnecessary Rive complexity.

---

## 5. Rive Asset List

## 5.1 `onboarding_build_better_days.riv`

### Purpose

Introduce the main app value.

### Visual idea

A friendly character checking a daily routine board while soft elements like water, moon, and calendar float lightly.

### State machine

```text
StateMachine: OnboardingStateMachine
Inputs:
- start: Trigger
- next: Trigger
- mood: Number optional
```

### States

- idle_loop
- transition_next
- success

### Usage

Onboarding screen page 1.

---

## 5.2 `onboarding_private_by_default.riv`

### Purpose

Communicate privacy and local-first trust.

### Visual idea

Phone with a small lock, local storage icon, and calm shield shape.

### State machine

```text
StateMachine: PrivacyStateMachine
Inputs:
- start: Trigger
- lock: Trigger
```

### Usage

Onboarding screen page 2 and privacy settings screen.

---

## 5.3 `empty_no_routines.riv`

### Purpose

Make the empty Today screen feel friendly and guide users to create their first routine.

### Visual idea

A small calendar/card waiting to be filled, with a soft plant or sun animation.

### State machine

```text
StateMachine: EmptyRoutineStateMachine
Inputs:
- idle: Boolean
- encourage: Trigger
```

### Usage

Today screen when no routines exist.

---

## 5.4 `routine_done_check.riv`

### Purpose

Give satisfying feedback when user marks a routine as done.

### Visual idea

Checkmark draws itself inside a soft circular badge.

### State machine

```text
StateMachine: CheckDoneStateMachine
Inputs:
- done: Trigger
```

### Usage

Routine card done action.

---

## 5.5 `daily_complete_celebration.riv`

### Purpose

Celebrate when all routines for a day are completed.

### Visual idea

Soft confetti, gentle sparkles, small smiling calendar/checklist.

### State machine

```text
StateMachine: DailyCompleteStateMachine
Inputs:
- celebrate: Trigger
```

### Usage

Daily complete modal/screen.

---

## 5.6 `reminder_active_bell.riv`

### Purpose

Show an active reminder without creating stress.

### Visual idea

Small bell with gentle pulse and soft wave.

### State machine

```text
StateMachine: ReminderBellStateMachine
Inputs:
- active: Boolean
- snoozed: Boolean
- urgentLevel: Number
```

### Usage

Next reminder card and reminder detail.

---

## 5.7 `template_wellness_pack.riv`

### Purpose

Decorate template detail screens.

### Visual idea

Routine board, water bottle, moon, walking shoes, vitamin capsule.

### State machine

```text
StateMachine: TemplateStateMachine
Inputs:
- idle: Boolean
```

### Usage

Templates screen and template detail.

---

## 6. Animation Naming Convention

Use predictable names for all Rive assets.

```text
feature_context_state.riv
```

Examples:

```text
onboarding_build_better_days.riv
onboarding_private_by_default.riv
empty_no_routines.riv
routine_done_check.riv
daily_complete_celebration.riv
reminder_active_bell.riv
template_wellness_pack.riv
```

---

## 7. Rive Artboard Convention

Use PascalCase for artboards.

Examples:

```text
BuildBetterDays
PrivateByDefault
EmptyNoRoutines
RoutineDoneCheck
DailyCompleteCelebration
ReminderActiveBell
TemplateWellnessPack
```

---

## 8. Rive State Machine Convention

Use clear state machine names.

Examples:

```text
BuildBetterDaysStateMachine
PrivacyStateMachine
EmptyRoutineStateMachine
CheckDoneStateMachine
DailyCompleteStateMachine
ReminderBellStateMachine
TemplateStateMachine
```

---

## 9. Motion Timing

### General timing

| Motion | Duration |
|---|---:|
| Button press | 80-120ms |
| Card state change | 180-250ms |
| Screen transition | 250-350ms |
| Progress ring update | 500-800ms |
| Check done animation | 600-1000ms |
| Daily complete celebration | 1200-2000ms |
| Empty state loop | 3-6 seconds |
| Onboarding ambient loop | 4-8 seconds |

### Easing

Use soft easing:

```text
easeOutCubic
easeInOutCubic
easeOutBack only for small celebration
```

Avoid harsh linear movements.

---

## 10. Animation Intensity Levels

Define animation intensity to prevent overuse.

## Level 1 — Micro

Used for buttons, icons, small state changes.

Examples:

- Button scale.
- Icon fade.
- Checkbox tick.

## Level 2 — Component

Used inside cards or sections.

Examples:

- Progress ring.
- Routine card completed transition.
- Reminder bell pulse.

## Level 3 — Moment

Used for important moments.

Examples:

- Onboarding illustration.
- Empty state.
- Daily complete celebration.

Rule:

> Only one Level 3 animation should be visible on a screen at a time.

---

## 11. Screen-Level Animation Plan

## 11.1 Onboarding

### Animation

Rive illustration at the top.

### Behavior

- Starts when screen appears.
- Loops softly.
- Changes or triggers transition when user taps next.

### Avoid

- Too much movement in background.
- Long animation before user can continue.

---

## 11.2 Today Screen

### Animation

- Progress ring animates on load.
- Routine card status animates when done.
- Empty state Rive if no routines.
- Reminder bell if next reminder is close.

### Behavior

- Do not animate every routine card continuously.
- Only animate state changes.

---

## 11.3 New Routine Screen

### Animation

- Static vector or simple Rive calendar illustration.
- Field focus uses native Flutter animation.

### Behavior

- Save button can show loading then success check.

---

## 11.4 Routine Detail Screen

### Animation

- Category illustration optional.
- Reminder state can use subtle Rive.

### Behavior

- Keep screen mostly static for readability.

---

## 11.5 Insights Screen

### Animation

- Charts animate once on page load.
- Streak badge can gently pop.

### Behavior

- Avoid animated chart loops.

---

## 11.6 Templates Screen

### Animation

- Template cards should not all animate at once.
- Use static vector thumbnails or very subtle Rive only on detail.

---

## 11.7 Daily Complete Celebration

### Animation

- Rive celebration animation.
- Soft confetti.
- Completion message.

### Behavior

- Trigger only when all routines are completed for the first time that day.
- Do not repeat aggressively.

---

## 12. Flutter Integration Guidelines

## 12.1 Rive wrapper

Create a shared wrapper:

```text
lib/shared/widgets/rive/openlife_rive_view.dart
```

Responsibilities:

- Load Rive asset.
- Select artboard.
- Initialize state machine.
- Expose triggers.
- Handle errors.
- Show fallback widget.

## 12.2 Asset registry

Create an asset constants file:

```text
lib/shared/animations/openlife_rive_assets.dart
```

Example:

```text
class OpenLifeRiveAssets {
  static const onboardingBuildBetterDays = 'assets/rive/onboarding_build_better_days.riv';
  static const emptyNoRoutines = 'assets/rive/empty_no_routines.riv';
  static const routineDoneCheck = 'assets/rive/routine_done_check.riv';
  static const dailyCompleteCelebration = 'assets/rive/daily_complete_celebration.riv';
}
```

## 12.3 Fallback requirement

Every Rive widget must have fallback:

- Static SVG
- Icon
- Empty container with fixed height
- Text placeholder for development

Never allow a broken Rive asset to crash the screen.

---

## 13. Performance Guidelines

### Rules

- Avoid multiple heavy Rive animations on one screen.
- Use static SVG thumbnails in lists.
- Use Rive mainly for hero areas or special moments.
- Keep animation file sizes small.
- Avoid unnecessary nested animations.
- Pause offscreen animations.
- Do not animate when app is in background.

### Target

The app should feel smooth on mid-range Android devices.

Recommended target:

- 60 FPS for normal UI.
- No visible jank on Today screen.
- Rive assets optimized before commit.

---

## 14. Accessibility and Reduced Motion

### Accessibility rules

- Do not use flashing animation.
- Avoid rapid pulsing.
- Animation should not be required to understand the UI.
- Important state changes must also be shown with text/icon.
- Provide reduced motion option in future.

### Reduced motion behavior

If reduced motion is enabled later:

- Replace Rive loop with static SVG.
- Disable confetti.
- Keep simple fade transitions.
- Keep progress value updates without heavy motion.

---

## 15. Sound and Haptics

MVP should not include sound by default.

Haptic feedback can be used lightly:

| Action | Haptic |
|---|---|
| Mark routine done | Light impact |
| Daily complete | Medium impact optional |
| Error validation | No haptic or very soft |
| Delete confirmation | No haptic |

Keep haptics subtle.

---

## 16. Animation QA Checklist

Before merging an animation:

- [ ] Animation has clear purpose.
- [ ] Animation is not distracting.
- [ ] File size is acceptable.
- [ ] Fallback UI exists.
- [ ] Does not crash if asset fails.
- [ ] Does not loop aggressively.
- [ ] Works in light and dark mode.
- [ ] Does not block user interaction.
- [ ] Works on small screen.
- [ ] Does not cause performance jank.

---

## 17. Rive Asset Production Checklist

For each `.riv` asset:

- [ ] Correct file name.
- [ ] Correct artboard name.
- [ ] Correct state machine name.
- [ ] Inputs documented.
- [ ] No unused heavy objects.
- [ ] Uses app color direction.
- [ ] Works on transparent or warm background.
- [ ] Has static fallback SVG/PNG.
- [ ] Tested in Flutter.

---

## 18. Recommended First Animation Set

For MVP, create only these first:

1. `onboarding_build_better_days.riv`
2. `empty_no_routines.riv`
3. `routine_done_check.riv`
4. `daily_complete_celebration.riv`

These four give enough polish without overwhelming development.

---

## 19. Animation Summary

OpenLife Routine should use Rive to create a calm, polished, and emotionally supportive experience.

Animation should make the app feel alive, but the app must remain fast, readable, and useful.

The best animation strategy is:

> Use Rive for meaningful moments, and use Flutter native animation for small UI interactions.
