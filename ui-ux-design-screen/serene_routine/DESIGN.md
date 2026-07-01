---
name: Serene Routine
colors:
  surface: '#FFFFFF'
  surface-dim: '#e1d9d1'
  surface-bright: '#fff8f3'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#fbf2ea'
  surface-container: '#f5ece5'
  surface-container-high: '#efe7df'
  surface-container-highest: '#eae1da'
  on-surface: '#1f1b17'
  on-surface-variant: '#44483c'
  inverse-surface: '#34302b'
  inverse-on-surface: '#f8efe8'
  outline: '#75796a'
  outline-variant: '#c5c8b7'
  surface-tint: '#4d6622'
  primary: '#4d6622'
  on-primary: '#ffffff'
  primary-container: '#8eaa5e'
  on-primary-container: '#283d00'
  inverse-primary: '#b3d180'
  secondary: '#396281'
  on-secondary: '#ffffff'
  secondary-container: '#b0d9fd'
  on-secondary-container: '#355f7e'
  tertiary: '#795900'
  on-tertiary: '#ffffff'
  tertiary-container: '#c39b42'
  on-tertiary-container: '#493400'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#cfed9a'
  primary-fixed-dim: '#b3d180'
  on-primary-fixed: '#131f00'
  on-primary-fixed-variant: '#374e0b'
  secondary-fixed: '#cbe6ff'
  secondary-fixed-dim: '#a2cbef'
  on-secondary-fixed: '#001e30'
  on-secondary-fixed-variant: '#1e4a68'
  tertiary-fixed: '#ffdea1'
  tertiary-fixed-dim: '#edc063'
  on-tertiary-fixed: '#261900'
  on-tertiary-fixed-variant: '#5c4300'
  background: '#F8F4EE'
  on-background: '#1f1b17'
  surface-variant: '#eae1da'
  surface-soft: '#F0EAE2'
  primary-soft: '#DDE8C8'
  secondary-soft: '#DDEBF5'
  accent-soft: '#FFF1C8'
  border: '#E5DDD3'
  success: '#34C759'
  danger: '#E57373'
  sleep-purple: '#9B86BD'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
  title-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 17px
    fontWeight: '700'
    lineHeight: 24px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 15px
    fontWeight: '500'
    lineHeight: 22px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 22px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  badge-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 14px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 12px
  lg: 16px
  xl: 24px
  2xl: 32px
  3xl: 40px
  page-margin: 24px
  card-gap: 16px
---

## Brand & Style

The design system is anchored in a philosophy of "Calm Productivity." It departs from the clinical rigidity of traditional health apps and the frantic energy of standard task managers. Instead, it positions itself as a supportive wellness companion. The target audience seeks structure without stress, valuing privacy, high-quality aesthetics, and a non-judgmental user experience.

The visual style is **Modern Organic**. It blends the clean lines of contemporary SaaS with the warmth of tactile, lifestyle-oriented design. The interface relies on generous whitespace (breathability), exceptionally large corner radii to evoke a sense of safety and friendliness, and a sophisticated color palette that feels grounded in nature. Interactions are designed to be "soft," avoiding sharp transitions or aggressive feedback in favor of purposeful, fluid motion that rewards user progress.

## Colors

The palette is a carefully balanced "Nature-Informed" set. The primary **Sage Green** serves as the anchor for growth and routine completion, while **Warm Cream** provides a soft, eye-friendly canvas that feels more premium and less sterile than pure white.

### Functional Application
- **Primary (Sage):** Used for main actions, active states, and successful completion.
- **Secondary (Soft Sky):** Used for informational elements and secondary category types (e.g., hydration).
- **Tertiary (Amber):** Reserved for high-attention accents, "snoozed" states, and vitamin/supplement routines.
- **Background:** The `#F8F4EE` cream is the default page surface to reduce blue-light strain and enhance the "wellness" feel.
- **Semantic Accents:** Use the specific category colors (Purple for Sleep, Red for Medicine) sparingly to aid mental mapping without cluttering the visual field.

## Typography

This design system uses **Plus Jakarta Sans** across all levels to maintain a cohesive, friendly, and modern tone. Its soft curves complement the large rounded shapes of the UI.

### Hierarchy Rules
- **Display & Headlines:** Use heavy weights (700) with slight negative letter-spacing to create a confident, grounded "Editorial" look for greetings and progress stats.
- **Body Text:** Use Medium (500) for interactive labels and Regular (400) for descriptive text to ensure maximum legibility.
- **Labels & Badges:** Use Semi-Bold or Bold weights at smaller sizes to ensure status information (like "Done" or "Missed") is immediately scannable despite the small footprint.

## Layout & Spacing

The layout follows a **Fluid Content** model with fixed horizontal margins. On mobile, the standard container margin is 24px to give the large cards room to breathe and avoid a cramped appearance.

### Spacing Rhythm
- **8px (sm) / 12px (md):** Used for internal component spacing, such as the gap between an icon and text within a card.
- **16px (lg):** The standard gutter between vertical cards in a list.
- **24px (xl) / 32px (2xl):** Used for section breaks (e.g., separating "Morning" routines from "Afternoon" routines) to provide clear visual hierarchy through "No Grid" whitespace-driven separation.

## Elevation & Depth

This design system eschews heavy drop shadows in favor of **Tonal Layering** and **Ambient Depth**. 

### Depth Principles
- **Surface Tiering:** The background (`#F8F4EE`) acts as the lowest level. Content cards sit on top using pure white (`#FFFFFF`). Secondary containers or "pressed" states use the `surface-soft` tint to create a sunken effect.
- **Shadow Character:** When shadows are necessary (specifically for the Floating Action Button and the Bottom Navigation), use an extra-diffused, low-opacity shadow tinted with the primary color: `0px 8px 24px rgba(142, 170, 94, 0.12)`.
- **Outlines:** Use soft, low-contrast strokes (`#E5DDD3`) rather than shadows for routine cards to maintain a clean, flat aesthetic that feels modern and lightweight.

## Shapes

The shape language is the primary driver of the "friendly" brand personality. 

### Corner Radii
- **Base Cards:** Use a generous 24px radius (`rounded-lg`) as the standard for all routine cards and input containers.
- **Hero/Onboarding Cards:** Use 32px (`rounded-xl`) for large modal surfaces or hero sections to maximize the "soft" feel.
- **Interactive Elements:** Buttons and chips use "Pill" shapes (999px) to clearly differentiate them from informational cards and to signify high interactability.

## Components

### Buttons
- **Primary:** Pill-shaped, `primary` background with white text. No shadow; high-contrast enough to stand out against the cream background.
- **Secondary:** Pill-shaped, `primary-soft` background with `primary` text. Provides a gentler alternative for less critical actions.

### Cards (The Core Component)
- **Routine Cards:** White background, 24px radius, subtle `border` stroke. Minimum height of 80px to ensure a large touch target.
- **Progress Card:** Uses a large `primary-soft` container with 32px radius to house the Rive-animated progress ring.

### Input Fields
- **Text Inputs:** 24px rounded corners, `surface` background, and `border` stroke. Focus state switches the border to `primary` with a 1px weight.

### Chips & Badges
- **Status Chips:** Pill-shaped with semi-transparent backgrounds of their status color (e.g., `success` at 15% opacity for "Done").
- **Time Badges:** Small, `surface-soft` containers with `neutral` text to indicate routine times without drawing focus away from the task name.

### Interactive Feedback (Rive)
- All checkmarks and completion toggles must trigger a Rive-based "playOnce" animation that feels liquid and rewarding. Idle states for the bell or mascot should use subtle "floating" loops.