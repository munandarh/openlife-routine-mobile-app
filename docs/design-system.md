# Design System

> The tokens and component rules OpenLife Routine actually ships. Every value
> here is defined in `lib/core/theme/` — treat that directory as the source of
> truth and this file as its documentation.

---

## 1. Direction

> A calm wellness app with soft vector illustrations and purposeful
> micro-animation. Warm, not clinical. Friendly, not childish.

Five rules the UI is held to:

1. **Warm neutral ground.** The app sits on cream, not white. White is reserved
   for cards, so surfaces read as objects on a surface.
2. **Sage green means progress.** The primary colour is used for completion,
   selection and the brand. It is never used to signal a problem.
3. **Generous radii.** Nothing sharp. Cards are 24, heroes 32, chips are pills.
4. **Status has a tone.** "Done" and "Missed" never share a colour.
5. **Motion is a response.** Animation confirms an action; it does not decorate
   an idle screen.

---

## 2. Colour

`lib/core/theme/app_colors.dart`

### Light

| Token | Value | Used for |
|---|---|---|
| `background` | `#F8F4EE` | App canvas |
| `surface` | `#FFFFFF` | Cards, sheets, nav bar |
| `surfaceSoft` | `#F0EAE2` | Inset chips, muted status |
| `surfaceVariant` | `#EAE1DA` | Secondary fills |
| `border` | `#E5DDD3` | Hairline card borders |
| `primary` | `#4D6622` | Brand, completion, selection |
| `primarySoft` | `#DDE8C8` | Selected chip fill, banners |
| `secondary` | `#396281` | Water / sleep / calm accents |
| `secondarySoft` | `#DDEBF5` | Secondary chip fill |
| `accentSoft` | `#FFF1C8` | Attention chip fill |
| `textPrimary` | `#1F1B17` | Titles and body |
| `textSecondary` | `#44483C` | Supporting copy |
| `success` | `#34C759` | Fully completed day |
| `warning` | `#C39B42` | Due now, missed |
| `danger` | `#E57373` | Destructive actions |

### Dark

Read colours through `context.palette` (an `AppPalette` theme extension), never
from `AppColors` directly — the constants below are light-theme values, and
referencing them in a widget is what made dark mode unreadable.

| Token | Value |
|---|---|
| `backgroundDark` | `#151A1E` |
| `surfaceDark` | `#20272D` |
| `surfaceSoftDark` | `#2A323A` |
| `borderDark` | `#323C44` |
| `textPrimaryDark` | `#F6F4EF` |
| `textSecondaryDark` | `#B9B4AE` |

Brand and semantic colours (`primary`, `success`, `warning`, `danger`) are
shared across both themes; only surfaces and text invert.

### Category palette

Each routine category has a fill and a foreground, resolved once in
`RoutineCategoryUi`:

| Category | Fill | Foreground |
|---|---|---|
| Meal | `#FFF1C8` | `warning` |
| Water | `#DDEBF5` | `secondary` |
| Vitamin | `#FFF1C8` | `warning` |
| Medicine | `#FFE0DF` | `danger` |
| Sleep | `#DDEBF5` | `secondary` |
| Exercise | `#DDEBF5` | `secondary` |
| Break | `surfaceSoft` | `primary` |
| Custom | `primarySoft` | `primary` |

Never inline these in a page. If a screen needs a category icon or tint, call
`RoutineCategoryUi`; that is the whole reason it exists.

---

## 3. Typography

`lib/core/theme/app_text_styles.dart` — Plus Jakarta Sans throughout.

| Style | Size / line-height | Weight | Used for |
|---|---|---|---|
| `display` | 32 / 1.25 | 700 | Metric numbers |
| `pageTitle` | 28 / 1.28 | 700 | Full-screen titles |
| `sectionTitle` | 22 / 1.36 | 700 | Greeting, section heads |
| `cardTitle` | 17 / 1.41 | 700 | Routine names |
| `body` | 15 / 1.46 | 400 | Descriptions |
| `bodyEmphasis` | 15 / 1.46 | 500 | Emphasised body |
| `label` | 12 / 1.33 | 600 | Chips, nav labels |
| `button` | 15 / 1.33 | 600 | Button labels |

Sizes are logical pixels *before* the OS text scale is applied. Nothing may
assume its rendered height — see §7.

---

## 4. Spacing and radius

`app_spacing.dart` · `app_radius.dart`

| Spacing | Value | | Radius | Value |
|---|---|---|---|---|
| `xxs` | 2 | | `small` | 10 |
| `xs` | 4 | | `medium` | 16 |
| `sm` | 8 | | `large` | 24 |
| `md` | 12 | | `extraLarge` | 32 |
| `lg` | 16 | | `pill` | 999 |
| `xl` | 24 | | | |
| `xxl` | 32 | | | |
| `xxxl` | 40 | | | |
| `pageMargin` | 24 | | | |
| `cardGap` | 16 | | | |

`pageMargin` is the horizontal gutter on every screen. `cardGap` is the vertical
gap between stacked cards. Both are aliases so the two can diverge later without
a find-and-replace.

---

## 5. Elevation

`app_shadows.dart`

| Token | Shadow | Used for |
|---|---|---|
| `soft` | `#00000014`, blur 20, y+8 | Hero cards, raised panels |
| `floating` | `#8EAA5E1F`, blur 24, y+10 | FAB, primary circular action |

Most cards use a hairline `border` and no shadow at all. Elevation is for
things that float above content, not for every container.

---

## 6. Components

### Card

Surface fill, `AppRadius.large`, 1px `border`, `AppSpacing.lg` padding. This is
the default container for anything list-shaped.

### `RoutineCard`

The workhorse of Today and Routines.

```text
[ category icon ]  Title                                 [ ○ ]
                   [time] [status] [action] [action]
```

- **Status chip** takes a `RoutineCardTone`: `positive` (primary), `attention`
  (warm amber, for due-now and missed), `muted` (grey, for skipped and
  snoozed). Passing the wrong tone is how a missed routine ends up looking like
  a win.
- **Action chips** are a list, not a single slot, because an open routine
  offers both Skip and Snooze.
- The completion circle and each action chip are their own semantics node, so a
  screen reader can reach them individually.

### `PrimaryButton`

Pill, `minHeight: 56`, full width. Two variants: filled (`primary`) and
secondary (`primarySoft` fill, primary text). The label is `Flexible` so it
wraps instead of clipping at large text scales.

### `AppEmptyState`

Illustration or pulsing icon, title, description, one action. Every empty state
in the app goes through it, and every host page wraps it in a scroll view.

### Chips

Pill or `AppRadius.small`, `label` type, `sm`/`xs` padding. Selected state is
`primarySoft` fill + `primary` border + a 7px dot.

---

## 7. Accessibility

These are enforced by `test/accessibility/text_scaling_test.dart`, not just
recommended.

- **Tap targets ≥ 44×44.** Completion circle, repeat-day chips and icon
  options are all explicitly sized.
- **Text scaling to 2.0×.** Every screen is pumped at 1.3× and 2.0× on a
  360×720 canvas and must produce no overflow. Practically this means: labels
  in a `Row` are `Flexible` or `Expanded`, containers use `minHeight` rather
  than a fixed `height`, and any centred column that can grow lives in a
  `SingleChildScrollView`.
- **Icon-only controls carry a label.** `RoutineCard.checkSemanticLabel`,
  button tooltips, `Semantics(label:)` on chips.
- **Colour is never the only signal.** Status chips carry words; chart bars
  carry a semantic percentage.
- **Reduced motion.** The Settings toggle suppresses the celebration overlay.

---

## 8. Adding to the system

1. Reach for an existing token first. A new hex value in a page is a bug.
2. If a value is genuinely new, add it to `lib/core/theme/` and document it
   here in the same change.
3. Anything drawn on more than one screen belongs in `lib/shared/widgets/`.
4. Any new user-facing string goes in both ARB files — the localization test
   will fail otherwise.
5. Pump any new screen through the accessibility suite before calling it done.
