# Vouch design system

Built on Astryx (facebook/astryx): its token values, and its design
conventions (`docs/design/*.md`). Icons are Lucide (`lucide_icons_flutter`).
The type is Geist and Geist Mono.

Import everything through `package:vouch_flutter/app/theme.dart` (re-exports `design/design.dart`).

## Palette

| Role | Colour | Token |
|---|---|---|
| Brand (chrome only) | Dusty Grape `#6457A6` | `brand`, `brandSoft` |
| Allowed / verified / live | Tropical Mint `#23F0C7` | `success*` |
| Denied / blocked | Light Coral `#EF767A` | `error*` |
| T1 recognised voice | Soft Periwinkle `#7D7ABC` | `t1*` |
| T2 owner approval / pending | Mustard `#FFE347` | `t2*` |
| T0 anyone | Grape-grey | `t0*` |

Each hue comes as a `VTone` (fg, bg, text), picked together (colour-emphasis DR1).

## Rules

1. Colour is information. Hue appears only for tiers and outcomes. Grape
   is reserved for chrome (the mark, nav selection, focus, text selection) and
   never touches data, so it can't be mistaken for a tier.
2. The primary action is inverted (near-white on dark). There is one per
   local group (colour-emphasis DR3).
3. Tiers never rely on colour alone. TierChip shapes: T0 hollow ring, T1
   dot, T2 square.
4. Denials use a 2px coral rail on the leading edge instead of a full red surface.
5. Data uses monospace with tabular figures: tiers, confidence, countdowns,
   action names, timestamps.
6. Surfaces use a hairline border, not a shadow
   (elevation DR3). Radii follow role: 4 inner · 8 element · 12 container.
7. Gaps grow with grouping level: 8 local, 16 group,
   32 section (spatial DR2/DR3).
8. Icons are Lucide outlines, chosen by meaning (see `icons.dart`). Sizes
   follow role: 12 indicator, 16 control, 20 prominent, 24 display.

## Motion

Durations come from Astryx's fast (175ms), medium (410ms) and slow (975ms)
bands. Easing is `VMotion.standard` = `cubic-bezier(0.24, 1, 0.4, 1)`, with no
bounce.

- Motion must explain something. Allowed uses: entrance (`FadeSlideIn`,
  staggered 45ms), continuity (the sliding nav pill), state (countdown ring,
  meters, expand/collapse) and liveness (`PulseDot`, `ListeningRings` only
  while a command is in flight).
- Every animation checks `VMotion.reduced(context)` and collapses to an
  instant change.
- Looping motion obeys `VMotion.ambientEnabled`, which widget tests turn off
  (`test/flutter_test_config.dart`).
- Do not delay an animation with `Future.delayed`. Staggers live inside the
  controller as an `Interval`, so no timer outlives the widget.
