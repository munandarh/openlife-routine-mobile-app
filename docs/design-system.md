# Design System — OpenLife Routine

> The tokens below are the ones in `lib/core/theme/`. If a value here and a
> value in code disagree, the code is right and this file is stale — fix it.

The visual direction is **calm, not clinical**: warm cream paper, sage green
as the single accent, and generous spacing. A routine app that shouts at you
has failed at its job (PRD §6.4).

---

## Color — `app_colors.dart`

### Light

| Token | Hex | Used for |
|---|---|---|
| `background` | `#F8F4EE` | App background, warm cream |
| `surface` | `#FFFFFF` | Cards, sheets, dialogs |
| `surfaceSoft` | `#F0EAE2` | Chips, inset panels |
| `surfaceVariant` | `#EAE1DA` | Pressed and secondary fills |
| `border` | `#E5DDD3` | Hairlines and unselected outlines |
| `primary` | `#4D6622` | Sage green — the only accent |
| `primarySoft` | `#DDE8C8` | Selected chip fill, hero tint |
| `secondary` | `#396281` | Informational, never a CTA |
| `secondarySoft` | `#DDEBF5` | Info card fills |
| `accentSoft` | `#FFF1C8` | Warm highlight |
| `textPrimary` | `#1F1B17` | Headings and body |
| `textSecondary` | `#44483C` | Supporting copy |

### Semantic

| Token | Hex | Meaning |
|---|---|---|
| `success` | `#34C759` | Completed |
| `warning` | `#C39B42` | Due now |
| `danger` | `#E57373` | Missed, destructive |
| `dangerSoft` | `#F7E0E0` | Missed badge ground |

Semantic colors are separate from the accent. Green in a status badge means
*done*, not *branded*.

### Dark

`backgroundDark #151A1E`, `surfaceDark #20272D`, `surfaceSoftDark #2A323A`,
`borderDark #323C44`, `textPrimaryDark #F6F4EF`, `textSecondaryDark #B9B4AE`.
Dark is not an inversion — the greens keep their hue and lift in luminance so
contrast holds on the darker ground.

## Type — `app_text_styles.dart`

Family: **Plus Jakarta Sans**.

| Style | Size / height / weight | Used for |
|---|---|---|
| `display` | 32 / 1.25 / 700 | Hero numbers, celebration |
| `pageTitle` | 28 / 1.28 / 700 | Screen titles |
| `sectionTitle` | 22 / 1.36 / 700 | Section headings |
| `cardTitle` | 17 / 1.41 / 700 | Card and list titles |
| `body` | 15 / 1.46 / 400 | Body copy |
| `bodyEmphasis` | 15 / 1.46 / 500 | Emphasised body |
| `label` | 12 / 1.33 / 600 | Badges, chips, meta |
| `button` | 15 / 1.33 / 600 | Button labels |

Stay on the scale. A one-off `fontSize:` in a widget is a smell — if a screen
needs a size that is not here, the scale is wrong and should be extended.

## Spacing — `app_spacing.dart`

`xxs 2 · xs 4 · sm 8 · md 12 · lg 16 · xl 24 · xxl 32 · xxxl 40`

`pageMargin 24` is the horizontal gutter on every screen. `cardGap 16` is the
vertical rhythm between cards. Prefer layout `gap` over per-child margins.

## Radius — `app_radius.dart`

`small 10 · medium 16 · large 24 · extraLarge 32 · pill 999`

`large` (24) is the default card radius, including the onboarding hero card.
`pill` is for chips and buttons. Mixing radii inside one card reads as an
accident.

## Elevation — `app_shadows.dart`

| Token | Value | Used for |
|---|---|---|
| `soft` | `0 8 20 rgba(0,0,0,.08)` | Resting cards |
| `floating` | `0 10 24 rgba(142,170,94,.12)` | Primary action, tinted green |

Shadows are soft and low-contrast. If a card needs to separate from a
same-toned background, add a hairline `border` rather than deepening the
shadow — this is what the onboarding hero card does, since the illustration's
cream backdrop is within a few points of the page background.

## Components

| Widget | Location | Notes |
|---|---|---|
| `PrimaryButton` | `shared/widgets/buttons/` | 56 high, pill, `isSecondary` for the soft variant, scales to 0.97 on press |
| `IconCircleButton` | `shared/widgets/buttons/` | Circular icon action |
| `RoutineCard` | `shared/widgets/cards/` | Icon tile, title, time and status badges, check circle, up to two inline text actions |
| `AppEmptyState` | `shared/widgets/empty_states/` | Illustration or icon, title, description, CTA |
| `ProgressRing` | `shared/widgets/progress/` | Daily completion |
| `WeekDateSelector` | `shared/widgets/forms/` | Day strip on Today |
| `OpenLifeRiveView` | `shared/widgets/rive/` | Rive → PNG → icon |

## Rules that keep it coherent

1. **One accent.** Sage green carries emphasis. Blue is informational, amber is
   attention, red is loss. A screen with three competing accents has none.
2. **Tokens, not literals.** No raw hex or magic padding in a widget.
3. **Tap targets ≥ 44×44**, including icon-only buttons (PRD §14.4).
4. **Icon-only controls need a semantic label** — a `Tooltip` or `Semantics`
   wrapper. The circular primary action in onboarding is the pattern.
5. **Left-align long-form copy.** Centering a title and a two-line description
   leaves the reader without an entry point; centre only short, single-line
   labels.
6. **Let the artwork fill its container.** An illustration boxed inside a
   frame inside another frame ends up at a fraction of its intended size.
