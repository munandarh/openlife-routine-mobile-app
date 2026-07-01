# OpenLife Routine — Design System

> **Product:** OpenLife Routine  
> **Design Concept:** Calm Daily Companion  
> **Platform:** Flutter mobile app  
> **Design System Version:** v1.0

---

## 1. Design System Purpose

This design system defines the visual language, components, interaction rules, and UI consistency standards for OpenLife Routine.

The app should feel like a calm, modern, friendly daily routine companion.

It should not look like:

- A hospital app
- A strict medical tracker
- A noisy gamified habit app
- A basic alarm app
- A corporate productivity dashboard

It should feel:

- Warm
- Simple
- Clean
- Rounded
- Friendly
- Premium
- Trustworthy
- Easy to use every day

---

## 2. Design Concept

## Calm Daily Companion

OpenLife Routine helps users complete daily routines without pressure.

The design should support the emotional goal:

> “I feel helped, not judged.”

### Brand sentence

> Build better days, one routine at a time.

### Indonesian brand sentence

> Bantu hidup lebih teratur, satu rutinitas setiap hari.

---

## 3. Design Principles

### 3.1 Calm, not noisy

Use soft surfaces, rounded cards, clean spacing, and gentle motion.

### 3.2 Helpful, not judgmental

Avoid language that makes users feel like they failed.

Bad:

> You failed today.

Good:

> Some routines were missed today. You can try again tomorrow.

### 3.3 Fast to use

The user should be able to:

- See today's routines in less than 3 seconds.
- Mark a routine as done in 1 tap.
- Create a simple routine in less than 1 minute.

### 3.4 Private by default

The interface should communicate trust:

- No login wall.
- Local-first messaging.
- Clear backup/export controls.
- No aggressive tracking language.

### 3.5 Motion with purpose

Animation should communicate state, progress, completion, or guidance.

---

## 4. Color System

The visual mood is **Sage Green + Warm Cream + Soft Sky + Amber Accent**.

The palette should feel calm and wellness-oriented without becoming medical.

## 4.1 Light Mode Tokens

```text
Background:        #F8F4EE
Surface:           #FFFFFF
Surface Soft:      #F0EAE2
Surface Elevated:  #FFFCF8
Primary:           #8EAA5E
Primary Dark:      #5F7A35
Primary Soft:      #DDE8C8
Secondary:         #7DA6C8
Secondary Soft:    #DDEBF5
Accent:            #F5C86A
Accent Soft:       #FFF1C8
Text Primary:      #202124
Text Secondary:    #77716B
Text Muted:        #A49B92
Border:            #E5DDD3
Divider:           #EFE7DE
Success:           #34C759
Warning:           #F0B429
Danger:            #E57373
Info:              #5DADEC
```

## 4.2 Dark Mode Tokens

```text
Background Dark:        #151A1E
Surface Dark:           #20272D
Surface Soft Dark:      #2A323A
Surface Elevated Dark:  #263039
Primary Dark Mode:      #A8C66C
Primary Soft Dark:      #344522
Secondary Dark Mode:    #8DB8D6
Accent Dark Mode:       #FFD166
Text Primary Dark:      #F6F4EF
Text Secondary Dark:    #B9B4AE
Text Muted Dark:        #85817C
Border Dark:            #323C44
Divider Dark:           #2A323A
```

## 4.3 Category Colors

| Category | Color Direction | Token Example | Usage |
|---|---|---|---|
| Meal | Warm orange | `MealAccent` | Meal icon, card accent |
| Water | Soft blue | `WaterAccent` | Hydration icon, progress |
| Vitamin | Amber/yellow | `VitaminAccent` | Supplement routines |
| Medicine | Soft red/pink | `MedicineAccent` | Medicine routines, but not alarming |
| Sleep | Purple/indigo | `SleepAccent` | Sleep routines |
| Exercise | Green | `ExerciseAccent` | Movement routines |
| Break | Soft sky | `BreakAccent` | Work break, eye rest |
| Custom | Neutral gray | `CustomAccent` | User-defined routines |

---

## 5. Typography

## 5.1 Font Recommendation

Use **Plus Jakarta Sans** or **Inter**.

Recommended default:

```text
Primary font: Plus Jakarta Sans
Fallback: Inter, system sans-serif
```

Reason:

- Modern
- Clean
- Professional
- Readable in English and Indonesian
- Good for portfolio-quality UI

## 5.2 Type Scale

| Token | Size | Weight | Line Height | Usage |
|---|---:|---:|---:|---|
| Display | 32 | 700 | 40 | Onboarding title |
| Page Title | 28 | 700 | 36 | Today, New Routine, Insights |
| Section Title | 22 | 700 | 30 | Daily Routine, Templates |
| Card Title | 17 | 700 | 24 | Routine name |
| Body Large | 16 | 500 | 24 | Important body text |
| Body | 15 | 400 | 22 | Description, helper text |
| Caption | 12 | 400 | 18 | Time, metadata |
| Button | 15 | 600 | 20 | CTA and action buttons |
| Badge | 11 | 600 | 16 | Done, missed, snoozed |
| Tiny | 10 | 500 | 14 | Small labels |

## 5.3 Copywriting Tone

Use short, friendly, non-judgmental text.

Good examples:

- “Today’s routine”
- “Next reminder”
- “Small progress still counts”
- “You’re doing well today”
- “Try again tomorrow”
- “Mark as done”
- “Snooze for 10 minutes”
- “Private by default”

Avoid:

- “You failed”
- “Bad progress”
- “You are unhealthy”
- “You must do this”
- Any medical diagnosis wording

---

## 6. Spacing System

Use consistent spacing tokens.

```text
xxs: 2
xs:  4
sm:  8
md:  12
lg:  16
xl:  24
2xl: 32
3xl: 40
4xl: 48
```

### Layout usage

| Area | Recommended Spacing |
|---|---:|
| Screen horizontal padding | 20-24 |
| Section gap | 24-32 |
| Card internal padding | 16-20 |
| Routine card gap | 12-16 |
| Form field gap | 16 |
| Bottom navigation padding | 12-16 |

---

## 7. Radius System

The app should use a rounded, soft visual style.

```text
Radius XS:       8
Radius Small:   10
Radius Medium:  16
Radius Large:   24
Radius XL:      32
Radius Pill:    999
```

### Usage

| Component | Radius |
|---|---:|
| Small chip | Pill |
| Icon button | Pill |
| Text field | 16 |
| Routine card | 24 |
| Large promo card | 28-32 |
| Bottom navigation | 32 |
| Modal sheet | 28 top radius |

---

## 8. Shadow and Elevation

Use soft shadows only. Avoid heavy material shadows.

### Light shadow

```text
Blur: 20
Spread: 0
Opacity: 0.06
Offset: 0, 8
```

### Card shadow

```text
Blur: 24
Spread: 0
Opacity: 0.08
Offset: 0, 10
```

### Floating button shadow

```text
Blur: 24
Spread: 0
Opacity: 0.16
Offset: 0, 10
```

---

## 9. Iconography

### Style

Icons should be:

- Rounded
- Simple
- Friendly
- Stroke-based or soft filled
- Easy to recognize

### Recommended icon categories

| Category | Icon Ideas |
|---|---|
| Meal | plate, fork, bowl |
| Water | droplet, bottle |
| Vitamin | capsule, sun, pill bottle |
| Medicine | pill, medical cross but soft |
| Sleep | moon, bed, cloud |
| Exercise | walking, stretching, shoes |
| Break | eye, coffee, timer |
| Custom | star, circle, spark |

Avoid icons that feel too clinical, scary, or emergency-focused.

---

## 10. Illustration System

Illustrations should be vector-based and friendly.

### Style

- Flat vector
- Soft shapes
- Rounded characters
- Warm expressions
- Minimal detail
- Calm background elements
- No harsh medical imagery

### Illustration use cases

| Screen | Illustration Purpose |
|---|---|
| Onboarding | Explain daily routine value |
| Empty state | Help user start first routine |
| Template detail | Show theme of routine pack |
| Daily complete | Celebrate completion |
| Privacy screen | Communicate local-first trust |
| Backup screen | Show safe data ownership |

---

## 11. Component Library

## 11.1 App Scaffold

### Rules

- Warm off-white background.
- Horizontal padding 20-24.
- Page title near top.
- Rounded top action buttons.
- Content should feel breathable.

## 11.2 Page Header

### Anatomy

- Large title
- Optional subtitle
- Optional right actions
- Optional back button

### Example

```text
Today
Small progress still counts
[notification button] [menu button]
```

---

## 11.3 Week Date Selector

Inspired by the reference structure, but customized for OpenLife Routine.

### Anatomy

- Horizontal row of 7 days.
- Each day has weekday label.
- Date number inside rounded vertical pill.
- Selected day uses primary color.
- Small dot indicates routine availability or completion.

### States

- Default
- Selected
- Completed
- Today
- Disabled/future optional

---

## 11.4 Routine Card

The routine card is the most important component.

### Anatomy

- Category icon or small illustration
- Routine title
- Repeat/time subtitle
- Status badge
- Progress ring or status icon
- Optional quick actions

### Example

```text
[icon] Breakfast
       Every day • 07:00
       Done
                         [100% ring]
```

### States

| State | Visual Treatment |
|---|---|
| Pending | Neutral card, primary action visible |
| Done | Success badge, soft green accent |
| Skipped | Muted card, neutral badge |
| Missed | Soft warning, not aggressive |
| Snoozed | Amber badge, reminder time shown |
| Disabled | Reduced opacity |

### Actions

- Mark done
- Snooze
- Skip
- Open detail

Primary interaction should be one-tap completion.

---

## 11.5 Progress Ring

### Usage

- Daily completion percentage.
- Routine-specific progress.
- Weekly summary.

### Rules

- Animate progress changes smoothly.
- Use primary color for daily progress.
- Use category color for routine-specific progress.
- Always show percentage or completion count nearby.

---

## 11.6 Floating Add Button

### Rules

- Positioned bottom-right above bottom navigation.
- Circular or rounded square.
- Primary color.
- Soft shadow.
- Plus icon.

### Action

Opens New Routine screen or modal.

---

## 11.7 Bottom Navigation

### Tabs

1. Today
2. Routines
3. Insights
4. Settings

`Templates` is part of the Routines flow for MVP, not a primary bottom-nav tab.

### Style

- Rounded pill container.
- White surface.
- Soft shadow.
- Active tab uses primary circle or pill.
- Icons with optional labels.

---

## 11.8 New Routine Form

### Structure

1. Header: “New Routine”
2. Rive/vector illustration
3. Routine name input
4. Category selector
5. Repeat days selector
6. Reminder time picker
7. Optional goal or notes
8. Save Routine CTA fixed near bottom

### Form rules

- Keep fields large.
- Avoid dense layouts.
- Show validation gently.
- Save button should be obvious.

---

## 11.9 Routine Detail Screen

### Sections

- Header illustration/icon
- Routine title and category
- Schedule
- Reminder behavior
- Recent history
- Actions: edit, disable, delete

---

## 11.10 Insights Screen

### Components

- Weekly completion card
- Progress chart
- Streak card
- Most missed routine card
- Supportive summary

### Tone

Insights should help users understand patterns, not judge them.

---

## 11.11 Template Card

### Anatomy

- Illustration or icon
- Template title
- Short description
- Number of routines
- CTA: Use template

### Template examples

- Basic Healthy Routine
- Hydration Routine
- Vitamin Routine
- Sleep Routine
- Programmer Break Routine

---

## 11.12 Empty State

### Anatomy

- Rive/vector illustration
- Short title
- Supportive description
- Primary CTA

### Example

```text
No routines yet
Start with one small routine for today.
[Create Routine]
```

---

## 11.13 Dialog and Bottom Sheet

### Usage

- Confirm delete.
- Choose skip reason.
- Snooze duration.
- Import/export confirmation.

### Rules

- Use rounded top corners.
- Keep copy short.
- Use clear primary and secondary actions.

---

## 12. Interaction States

Every interactive component should define:

- Default
- Pressed
- Disabled
- Loading
- Success
- Error

### Button states

| State | Treatment |
|---|---|
| Default | Primary fill |
| Pressed | Slight scale down or darker fill |
| Disabled | Muted opacity |
| Loading | Spinner or subtle progress |
| Success | Check icon transition |

---

## 13. Motion Rules

Motion should be soft and short.

| Interaction | Duration |
|---|---:|
| Button press | 80-120ms |
| Card state change | 180-250ms |
| Progress ring update | 500-800ms |
| Screen transition | 250-350ms |
| Completion celebration | 1200-2000ms |
| Rive empty state loop | Slow ambient loop |

---

## 14. Accessibility

### Minimum requirements

- Tap targets at least 44x44.
- Text contrast must be readable.
- Do not rely only on color.
- Add semantic labels for icons.
- Support text scaling.
- Avoid animation that flashes rapidly.
- Provide reduced motion fallback later.

### Examples

Icon-only button should have semantic label:

```text
Notification settings
Add new routine
Mark breakfast as done
```

---

## 15. Responsive Rules

### Small phones

- Reduce vertical spacing slightly.
- Avoid hiding core actions.
- Routine cards remain readable.
- Bottom CTA should not overlap keyboard.

### Large phones

- Keep max content width.
- Avoid stretching cards too much.
- Use more whitespace.

### Tablets later

- Two-column layout possible for Today + Detail.

---

## 16. Screen Blueprint

## 16.1 Onboarding

```text
[Large Rive illustration]
[Headline]
[Short supportive copy]
[Page indicators]
[Primary CTA]
[Skip]
```

## 16.2 Today Dashboard

```text
[Header: Today + actions]
[Week date selector]
[Daily progress card]
[Next reminder card]
[Daily routine section]
[Routine cards]
[Floating add button]
[Bottom navigation]
```

## 16.3 New Routine

```text
[Header: New Routine + close]
[Rive/vector illustration]
[Name input]
[Category chips]
[Repeat days]
[Reminder time]
[Snooze option]
[Save Routine button]
```

## 16.4 Insights

```text
[Header: Insights]
[Weekly completion card]
[Simple chart]
[Streak card]
[Most missed routine]
[Supportive summary]
```

## 16.5 Templates

```text
[Header: Templates]
[Search optional]
[Template categories]
[Template cards]
```

## 16.6 Settings

```text
[Header: Settings]
[Theme]
[Language]
[Notifications]
[Backup/export]
[Privacy]
[Open source]
[About]
```

---

## 17. Flutter Implementation Notes

### Recommended token files

```text
lib/core/theme/app_colors.dart
lib/core/theme/app_spacing.dart
lib/core/theme/app_radius.dart
lib/core/theme/app_text_styles.dart
lib/core/theme/app_shadows.dart
```

### Recommended component folders

```text
lib/shared/widgets/buttons/
lib/shared/widgets/cards/
lib/shared/widgets/progress/
lib/shared/widgets/navigation/
lib/shared/widgets/forms/
lib/shared/widgets/empty_states/
lib/shared/widgets/rive/
```

---

## 18. Design QA Checklist

Before merging a UI screen:

- [ ] Uses design tokens.
- [ ] Uses correct spacing.
- [ ] Uses rounded cards consistently.
- [ ] Has empty state.
- [ ] Has loading state if needed.
- [ ] Has error state if needed.
- [ ] Works in dark mode.
- [ ] Works on small screen.
- [ ] Has accessible labels.
- [ ] Does not feel medical or stressful.
- [ ] Animation is useful and not excessive.

---

## 19. Design System Summary

OpenLife Routine should look and feel like a modern wellness companion:

- Warm background.
- Large rounded cards.
- Friendly vector illustrations.
- Soft progress visuals.
- Calm Rive animations.
- Simple navigation.
- Supportive language.
- Privacy-first trust cues.

The design should be polished enough for portfolio screenshots and simple enough for real daily use.
