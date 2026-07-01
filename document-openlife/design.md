# OpenLife Routine — Recommended Design Concept & Design System

> **Project:** OpenLife Routine  
> **Platform:** Flutter mobile app  
> **Design concept:** Calm Daily Companion  
> **Design direction:** Simple, modern, warm, vector-rich, animation-supported  
> **Animation engine:** Rive  
> **Primary goal:** Create a polished open-source portfolio app that feels useful, calm, and production-ready.

---

## 1. Recommended Design Concept

### Concept Name

**Calm Daily Companion**

OpenLife Routine should feel like a friendly personal companion that helps users complete daily routines without pressure.

The app should not feel like a hospital app, strict productivity tool, or noisy habit tracker. It should feel warm, simple, trustworthy, and easy to use every day.

### Main Feeling

The user should feel:

- Calm
- Helped
- Motivated
- Safe
- Not judged
- Not overwhelmed
- In control of their daily routine

### Brand Sentence

> Build better days, one routine at a time.

### Indonesian Brand Sentence

> Bantu hidup lebih teratur, satu rutinitas setiap hari.

---

## 2. Product Identity

OpenLife Routine is an **open-source, offline-first daily routine reminder app** for meals, water, vitamins, medicine, sleep, exercise, and lifestyle checklists.

The design must communicate:

- Privacy
- Simplicity
- Daily usefulness
- Wellness without medical stiffness
- Modern mobile product quality
- Open-source trust

---

## 3. Design Principles

### 3.1 Calm, Not Noisy

The interface should use soft backgrounds, clean spacing, rounded cards, and gentle motion. Avoid visual overload.

### 3.2 Helpful, Not Judgmental

The app should not shame users when they miss a routine.

Bad copy:

> You failed today.

Good copy:

> Some routines were missed today. You can try again tomorrow.

### 3.3 Fast to Use

A user should be able to:

- See today’s routines in less than 3 seconds
- Mark a routine as done in 1 tap
- Create a basic routine in less than 1 minute
- Understand progress without reading long text

### 3.4 Offline and Private by Default

No login wall on first launch. The app should feel trustworthy because it works locally first.

### 3.5 Animation with Purpose

Use Rive animation to support onboarding, empty states, progress, reminders, and completion moments. Do not animate everything.

---

## 4. Visual Direction

### Overall Style

Use a soft modern wellness design style:

- Large rounded cards
- Warm off-white background
- Gentle shadows
- Simple iconography
- Friendly vector illustrations
- Smooth Rive micro-animations
- Spacious layout
- Large touch targets
- Minimal text
- Strong but calm visual hierarchy

### Visual Keywords

- Warm
- Calm
- Clean
- Rounded
- Friendly
- Premium
- Minimal
- Lightweight
- Human
- Trustworthy

---

## 5. Recommended Color Concept

The reference images should be used for **layout structure and UX feel**, not exact colors.

Recommended palette: **Sage Green + Warm Cream + Soft Sky + Amber Accent**.

This palette gives a wellness feeling without looking too medical.

### Light Mode Tokens

```text
Background:        #F8F4EE
Surface:           #FFFFFF
Surface Soft:      #F0EAE2
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
Success:           #34C759
Warning:           #F0B429
Danger:            #E57373
Info:              #5DADEC
```

### Dark Mode Tokens

```text
Background Dark:        #151A1E
Surface Dark:           #20272D
Surface Soft Dark:      #2A323A
Primary Dark Mode:      #A8C66C
Primary Soft Dark:      #344522
Secondary Dark Mode:    #8DB8D6
Accent Dark Mode:       #FFD166
Text Primary Dark:      #F6F4EF
Text Secondary Dark:    #B9B4AE
Border Dark:            #323C44
```

### Category Colors

Each routine category can have its own accent color:

| Category | Color Direction | Usage |
|---|---|---|
| Meal | Warm orange | Meal routine icon/card accent |
| Water | Soft blue | Hydration routine |
| Vitamin | Yellow/amber | Supplement routine |
| Medicine | Soft red/pink | Medicine routine |
| Sleep | Purple/indigo | Sleep routine |
| Exercise | Green | Movement routine |
| Custom | Neutral gray | User-defined routine |

---

## 6. Typography

### Font Recommendation

Use **Plus Jakarta Sans** or **Inter**.

Reason:

- Clean and modern
- Good readability
- Professional for portfolio
- Works well for global users
- Looks good in both English and Indonesian

### Type Scale

| Token | Size | Weight | Usage |
|---|---:|---:|---|
| Display | 32 | 700 | Onboarding headline |
| Page Title | 28 | 700 | Today, New Routine, Insights |
| Section Title | 22 | 700 | Daily Routine, Templates |
| Card Title | 17 | 700 | Routine name |
| Body | 15 | 400/500 | Description, helper text |
| Caption | 12 | 400 | Time, metadata |
| Button | 15 | 600 | CTA and action buttons |
| Badge | 11 | 600 | Done, Missed, Snoozed |

### Copywriting Tone

Use short, friendly, non-judgmental copy.

Examples:

- “Today’s routine”
- “Next reminder”
- “You are doing well today”
- “Small progress still counts”
- “Try again tomorrow”
- “Mark as done”
- “Snooze for 10 minutes”

---

## 7. Layout System

### Spacing Tokens

```text
xs: 4
sm: 8
md: 12
lg: 16
xl: 24
2xl: 32
3xl: 40
```

### Radius Tokens

```text
Small: 10
Medium: 16
Large: 24
Extra Large: 32
Pill: 999
```

### Card Rules

Cards should use:

- Radius 20–28
- Subtle shadow
- White or near-white background
- Clear icon/title/time/status hierarchy
- Minimum height 80 px for routine cards
- Comfortable horizontal padding

---

## 8. Information Architecture

### Main Navigation

Use a rounded bottom navigation with 4 main tabs:

1. **Today**
2. **Routines**
3. **Insights**
4. **Settings**

Optional future tab:

5. **Templates**

For MVP, Templates are accessed from the Routines flow, not from the main bottom navigation.

### Navigation Style

- Floating rounded bottom navigation
- Selected item uses primary color background
- Icons only or icons + labels depending screen width
- Center floating add button is allowed, but do not make layout too crowded

---

## 9. Core Screens

## 9.1 Onboarding

### Purpose

Introduce the app quickly and communicate privacy-first value.

### Screen Structure

- Large Rive/vector illustration
- Short headline
- Short description
- Primary CTA
- Optional secondary CTA: “Skip”

### Onboarding Slides

#### Slide 1 — Plan Your Day

Headline:

> Build better days

Description:

> Create simple routines for meals, water, vitamins, medicine, sleep, and daily habits.

Rive idea:

- Character organizing a daily checklist
- Calendar cards softly moving

#### Slide 2 — Get Gentle Reminders

Headline:

> Never miss what matters

Description:

> Receive calm reminders and mark routines as done, skipped, or snoozed.

Rive idea:

- Bell icon with soft pulse
- Notification card appearing

#### Slide 3 — Private by Default

Headline:

> Your routine stays yours

Description:

> OpenLife Routine works offline first. No account required to start.

Rive idea:

- Phone with lock icon and local storage symbol

---

## 9.2 Today Dashboard

### Purpose

This is the most important screen. It should help users know what to do next.

### Structure

Top area:

- Greeting
- Notification icon
- More/menu icon

Week selector:

- Horizontal date selector
- Selected date as rounded vertical pill
- Small status dot on completed days

Progress area:

- Daily progress ring or progress card
- Text: “6 of 10 completed”
- Next reminder card

Routine list:

- Section title: “Daily routine”
- “See all” action
- Routine cards

Floating action:

- Add routine button

### Routine Card Content

Each routine card contains:

- Category icon/illustration
- Routine name
- Repeat label
- Time
- Status badge
- Progress indicator or completion state
- Quick action button

Example:

```text
[Icon] Breakfast
       Repeat every day
       07:00
                         [Done]
```

### Routine States

| State | Visual Treatment |
|---|---|
| Upcoming | Neutral card, time visible |
| Due Now | Soft primary highlight |
| Done | Success badge/check animation |
| Snoozed | Warning badge |
| Missed | Muted card + soft danger indicator |
| Skipped | Neutral muted state |

---

## 9.3 New Routine Screen

### Purpose

Allow users to create a routine quickly without feeling overwhelmed.

### Structure

- Page title: “New routine”
- Close button
- Rive/vector illustration at top
- Routine name input
- Category selector
- Time picker
- Repeat days selector
- Reminder behavior
- Color/icon selector
- Save button fixed near bottom

### Form Priority

Required fields:

1. Routine name
2. Category
3. Time
4. Repeat days

Advanced options should be collapsed:

- Reminder repeat if not answered
- Snooze options
- Dependent routine
- Notes

### UX Rule

The basic form must be short. Advanced scheduling should not block simple routine creation.

---

## 9.4 Routine Detail Screen

### Purpose

Show routine status, schedule, history, and settings.

### Structure

- Header with icon/illustration
- Routine name
- Category badge
- Today status
- Schedule card
- Reminder behavior card
- Recent history
- Edit button
- Disable/delete actions

### Recommended Detail Sections

1. Overview
2. Schedule
3. Reminder settings
4. History
5. Notes

---

## 9.5 Insights Screen

### Purpose

Give simple progress feedback without overwhelming the user.

### Structure

- Weekly completion chart
- Completion percentage
- Best streak
- Most completed routine
- Most missed routine
- Gentle weekly summary

### Copy Example

> You completed 72% of your routines this week. Your best routine was hydration. Sleep routine needs more attention.

### Visual Style

- Use simple rounded charts
- Avoid dense analytics
- Use cards and short explanations

---

## 9.6 Templates Screen

### Purpose

Help new users start quickly.

### Template Categories

- Morning Routine
- Hydration Routine
- Vitamin Routine
- Medication Reminder
- Sleep Routine
- Programmer Break
- Family Care
- Ramadan Routine

### Template Card Content

- Illustration/icon
- Template name
- Short description
- Number of routines inside
- CTA: “Use template”

---

## 9.7 Settings Screen

### Purpose

Give user control over app behavior and data.

### Sections

- Profile/local identity
- Language
- Theme
- Notification settings
- Backup/export
- Import data
- Privacy
- Open-source project
- About

### Open Source Section

Include:

- GitHub repository link
- License
- Contribute button
- Report issue button

---

## 10. Component System

### 10.1 Week Date Selector

Used on Today screen.

Component rules:

- Horizontal row
- Day letter on top
- Date number inside rounded vertical pill
- Selected date uses primary color
- Completed date shows small dot
- Today should be visually clear

### 10.2 Routine Card

Main repeated component in the app.

Variants:

- Compact
- Expanded
- Due now
- Done
- Missed
- Snoozed

### 10.3 Progress Ring

Use for:

- Daily completion
- Routine completion
- Weekly summary

Animation:

- Smooth progress transition
- Use native Flutter animation for simple rings
- Rive optional for celebration state

### 10.4 Primary Button

Rules:

- Full width on forms
- Rounded radius 16–20
- Height 52–56
- Primary color
- Clear label

### 10.5 Floating Add Button

Rules:

- Bottom right or centered above bottom nav
- Primary color
- Rounded/circle
- Soft shadow
- Plus icon

### 10.6 Empty State

Used when:

- No routines yet
- No insights yet
- No templates loaded

Structure:

- Rive/vector illustration
- Friendly title
- Short description
- CTA

---

## 11. Rive Animation Plan

Rive should be used to make the app feel alive, but not heavy.

### 11.1 Rive Usage Areas

| Area | Rive Animation | Purpose |
|---|---|---|
| Onboarding | Character + routine cards | Introduce concept |
| Empty state | Calm character/checklist | Reduce blank-state feeling |
| Reminder due | Bell pulse/card glow | Show importance |
| Mark as done | Checkmark animation | Reward completion |
| Daily complete | Small celebration | Positive feedback |
| Privacy screen | Lock/local storage | Communicate trust |

### 11.2 Rive Files

Recommended files:

```text
assets/rive/onboarding_plan_day.riv
assets/rive/onboarding_reminder.riv
assets/rive/onboarding_privacy.riv
assets/rive/empty_routine.riv
assets/rive/check_done.riv
assets/rive/reminder_bell.riv
assets/rive/daily_complete.riv
```

### 11.3 Rive State Machines

#### check_done.riv

States:

- idle
- checked
- success

Inputs:

```text
trigger_check
is_completed
```

#### reminder_bell.riv

States:

- idle
- pulse
- urgent

Inputs:

```text
is_due
is_snoozed
urgency_level
```

#### daily_complete.riv

States:

- idle
- celebrate

Inputs:

```text
trigger_celebrate
completion_percent
```

### 11.4 Animation Rules

- Keep animation short: 300–1200ms for micro interactions
- Loop only on calm idle animations
- Avoid aggressive bouncing
- Avoid heavy particle effects
- Use celebration only when meaningful
- Respect reduced motion accessibility setting

---

## 12. Illustration Direction

### Style

- Flat vector
- Rounded shapes
- Soft gradients
- Minimal facial details
- Friendly human figures
- Warm lifestyle objects

### Illustration Subjects

- Calendar
- Checklist
- Water bottle
- Meal plate
- Vitamin capsule
- Medicine box
- Moon/sleep
- Walking shoes
- Bell notification
- Lock/privacy
- Plant/growth metaphor

### Avoid

- Hospital bed visuals
- Doctor-heavy imagery
- Fear-based health imagery
- Overly childish mascot
- Overly corporate SaaS illustration

---

## 13. UX Flow

### 13.1 First Launch Flow

```text
Splash
→ Onboarding
→ Choose language
→ Choose starter template or start blank
→ Today Dashboard
```

### 13.2 Create Routine Flow

```text
Today Dashboard
→ Tap Add
→ New Routine
→ Fill basic fields
→ Save
→ Routine appears on Today Dashboard
```

### 13.3 Complete Routine Flow

```text
Reminder appears
→ User opens app or taps notification
→ Routine card highlighted
→ User taps Mark as Done
→ Check animation plays
→ Daily progress updates
```

### 13.4 Missed Routine Flow

```text
Reminder due
→ User does not respond
→ Reminder repeats based on setting
→ If still not completed, status becomes Missed
→ App shows gentle summary later
```

---

## 14. Accessibility Rules

The design must support:

- Large tap targets, minimum 44x44
- Good color contrast
- Clear text labels
- No color-only status communication
- Reduced motion option
- Dynamic text scaling
- Screen reader labels for routine actions
- Simple language

Status should use color + icon + text.

Example:

- Green + check icon + “Done”
- Amber + clock icon + “Snoozed”
- Red + exclamation icon + “Missed”

---

## 15. Flutter Implementation Notes

### Recommended Packages

```yaml
flutter_bloc: state management
rive: Rive animations
flutter_svg: SVG icons and illustrations
sqflite or drift: local database
flutter_local_notifications: local reminders
go_router: navigation
intl: localization/date formatting
freezed: immutable models
json_serializable: serialization
```

### Design Token Structure

Recommended folder:

```text
lib/core/theme/
  app_colors.dart
  app_spacing.dart
  app_radius.dart
  app_text_styles.dart
  app_shadows.dart
  app_theme.dart
```

### Component Folder

```text
lib/shared/widgets/
  app_button.dart
  app_card.dart
  routine_card.dart
  week_date_selector.dart
  progress_ring.dart
  empty_state.dart
  rive_animation_view.dart
```

### Asset Folder

```text
assets/
  icons/
  illustrations/
  rive/
  images/
```

---

## 16. MVP Design Scope

For the first public version, design these screens first:

1. Splash screen
2. Onboarding screen
3. Today Dashboard
4. New Routine screen
5. Routine Detail screen
6. Insights screen
7. Templates screen
8. Settings screen
9. Empty states
10. Notification permission screen

Do not design payment, cloud sync, family mode, or B2B dashboard in MVP.

---

## 17. Long-Term Design Scope

Future design expansion:

- Family/caregiver mode
- Multi-profile dashboard
- Cloud sync setup
- Premium templates
- Advanced insights
- Web dashboard
- Coach/clinic dashboard
- Wearable companion
- Home screen widgets

---

## 18. Design Do and Don’t

### Do

- Use rounded cards
- Use calm colors
- Use friendly vector illustrations
- Use meaningful animation
- Make actions easy to tap
- Keep copy short
- Make offline/privacy visible
- Make the app feel premium but simple

### Don’t

- Do not make it look like a hospital app
- Do not use scary medical language
- Do not overuse animations
- Do not require login at start
- Do not hide basic routine creation behind too many steps
- Do not make analytics too complex
- Do not copy reference colors exactly
- Do not copy reference illustrations exactly

---

## 19. AI Design Prompt

Use this prompt when generating UI design concepts:

```text
Create a clean, modern, calm mobile app design for OpenLife Routine, an open-source offline-first daily routine reminder app.

Design concept: Calm Daily Companion.

The app helps users manage meals, water, vitamins, medicine, sleep, exercise, and lifestyle checklists. Use a warm wellness UI style with large rounded cards, soft shadows, breathable spacing, friendly vector illustrations, simple icons, smooth Rive animation areas, weekly date selector, today progress, routine cards, floating add button, rounded bottom navigation, and a simple New Routine form.

Do not make it look medical, corporate, childish, or noisy. Make it feel premium, friendly, private, calm, and easy to use every day.

Create screens: Onboarding, Today Dashboard, New Routine, Routine Detail, Insights, Templates, Settings, and Empty State.
```

---

## 20. Final Design Direction Summary

OpenLife Routine should look and feel like:

> A calm, modern, open-source wellness routine app that helps users complete daily routines with gentle reminders, friendly vector visuals, and smooth Rive animations.

The design should be simple enough for daily use, polished enough for an international portfolio, and flexible enough to support future monetization through cloud sync, family mode, premium templates, and B2B services.
