# A. V18 repository audit

Audited source: `https://github.com/faryal1707/V18-WEB` and the V18 brief.

## File-by-file findings

| V18 file | Strong foundation retained | Production defect addressed in V19 |
|---|---|---|
| `index.html` | Navy/orange/off-white industrial palette, condensed display typography, “Move freight. Build momentum.”, Equipment/Capacity concepts | Placeholder `Client Login`, plan CTAs and sign-in links; unverified 24/7 claim; abstract What We Do flow; missing support/legal/auth pages |
| `services.html` | Concrete service categories | Converted to a substantive Solutions route with preserved service anchors |
| `carriers.html` | Owner Operator / Small Fleet segmentation | Expanded into three carrier profiles without unsupported proof claims |
| `availability.html` | Broker-facing capacity board and Send Load concept | Hard-coded capacity, non-working radius/date controls, simulated load send, custom dialog accessibility gaps |
| `styles.css` | Existing V18 tokens and small-radius industrial geometry | Orange/white normal-text contrast corrected by using dark text on bright orange; focus, responsive and reduced-motion states added |
| `script.js` | Progressive interaction patterns | Removed simulated send success, 4.2s workflow auto-advance, navigation-delay animation, string-only capacity filtering; added JS reduced-motion gate in V19 core |

## Confirmed V18 blockers

- `Client Login` and plan CTAs use placeholder destinations.
- Capacity origin is client-side substring matching against hard-coded card attributes; radius and date controls do not drive a server query.
- Send Load calls `preventDefault()`, changes the button to “Sent to Operations”, waits, then resets without persistence.
- What We Do auto-advances on a timer and only pauses on mouse hover, not focus.
- The custom modal closes on Escape but V18 does not establish the complete focus-management contract required for a modal dialog.
- V18 includes a 24/7/365 visible claim without a verified source in the supplied business configuration.

V19 therefore retains the visual language while replacing product promises with database-backed workflows.
