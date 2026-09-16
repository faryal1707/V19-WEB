# H. Design system changes

V19 retains the observed V18 palette and geometry:

- `--navy-950 #080B12`
- `--orange #FF5A1F`
- `--paper #F3F0E8`
- `--font-display Big Shoulders Display`
- `--font-body Inter`
- `--radius 3px`

## Contrast correction

V18 used bright `#FF5A1F` with white normal-size text on `.btn-primary`. V19 keeps the brand orange but changes primary-button text to dark `#0B0E14`, preserving the recognizable accent while avoiding the known low-contrast pairing. A darker `--orange-deep` token is also available when white text is required.

## Motion

- Manual workflow tabs replace the timed What We Do auto-advance.
- JS exports a `reduceMotion` matchMedia flag.
- CSS disables nonessential transition/animation effects under `prefers-reduced-motion`.
- Navigation is immediate; no decorative 480 ms page-leave delay.

## Responsive acceptance widths

320, 360, 390, 430, 768, 1024, 1280, 1440, 1920, plus mobile landscape. The layout switches data-heavy interfaces to overflow-safe tables and single-column forms rather than shrinking controls below usable sizes.
