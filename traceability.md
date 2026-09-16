# W. Requirement traceability matrix

Status values: **Implemented**, **Implemented / config required**, **Pre-launch business input**, **P2**.

| Requirement area | File/component | Status | Acceptance evidence |
|---|---|---|---|
| Preserve V18 identity / hero | `assets/css/styles.css`, `index.html` | Implemented | Token review + visual QA |
| Remove placeholder CTAs | all public HTML + `scripts/link-check.mjs` | Implemented | `npm run check:links` |
| What We Do concrete 4-state workflow | `index.html`, `home.js` | Implemented | keyboard tab QA; no auto-advance |
| Reduced motion CSS + JS | `styles.css`, `core.js`, `home.js` | Implemented | reduced-motion manual test |
| Capacity database model | `001_init.sql` | Implemented | migration + DB tests |
| Origin/radius/date/equipment | `routes/capacity.js` | Implemented | API integration tests; PostGIS query review |
| Stale capacity | config + `routes/capacity.js`, `capacity.js` | Implemented | stale flag UI/API |
| Admin capacity CRUD/audit | `routes/admin.js`, `admin/capacity.html`, `admin.js` | Implemented | admin E2E |
| BOOKED stops appearing | public query status filter | Implemented | admin→public E2E |
| Send Load persistence/idempotency | `routes/load-requests.js`, `capacity.js` | Implemented | 201/200 replay/409 tests |
| DB source of truth / email retry | `notifications`, worker | Implemented | queue failure/retry test |
| Plans Core/Premium/Custom | `plans.html`, homepage | Implemented | route/link test |
| No invented price | copy/config | Implemented | content review |
| 5-step onboarding | `onboarding.html/js`, route | Implemented | E2E + duplicate MC test |
| Consent separation | onboarding UI + `consents` | Implemented | DB consent records; optional unchecked |
| Auth login/logout/reset/session | `routes/auth.js`, auth pages | Implemented | auth integration tests |
| Invitation/account activation | invitation table/routes, `activate.html` | Implemented | invite→activate E2E |
| MFA privileged accounts | TOTP validation on login | Implemented / config required | provision production MFA secrets and test |
| Client portal routes | `portal/*`, `routes/portal.js` | Implemented | tenant access tests |
| Defined reporting formulas | portal route + `metrics.js` | Implemented | unit tests |
| CSV export | report data contract | Implemented / UI enhancement pending | API data available; CSV button should be added before launch if required |
| PDF report export | report service | P2 | not required for P0 unless business changes priority |
| PostgreSQL entities/indexes/PostGIS | `001_init.sql` | Implemented | migration review |
| DEMO seed labeling | `002_seed_demo.sql`, query exclusion | Implemented | public query excludes `is_demo` |
| Email notifications | `notifications.js`, worker | Implemented / config required | configure provider; sandbox test |
| Optional SMS | schema/consent present | P2/config | provider disabled by default |
| Privacy/terms/accessibility routes | public pages | Implemented structure | legal/business review still required |
| Native accessible dialog | `capacity.html` `<dialog>` | Implemented | keyboard/SR manual QA |
| Contrast correction | `.btn-primary` dark text | Implemented | automated/manual contrast scan |
| Responsive breakpoints | CSS | Implemented | device matrix QA |
| SEO titles/canonicals/OG | public HTML | Implemented | metadata crawl |
| Sitemap/robots/redirects | web root | Implemented | validation/link crawl |
| JSON-LD Organization | intentionally withheld | Pre-launch business input | add only verified company facts |
| Analytics event contract | `core.js`, success events | Implemented / provider config required | PII review + consent QA |
| Core Web Vitals RUM | provider hook required | Implemented / config required | production p75 monitoring |
| Admin load requests/apps/audit | routes + admin pages | Implemented | RBAC E2E |
| Admin client listing/invites | API invitation/clients routes | Implemented | admin E2E |
| Automated unit tests | `test/metrics.test.js` | Implemented baseline | `npm test` |
| Link tests | `link-check.mjs` | Implemented | `npm run check:links` |
| API/E2E/axe CI | `.github/workflows/ci.yml` | Implemented / dependency install required | CI run |
| Staging/deploy/rollback | `deployment.md` | Implemented | release rehearsal |
| Authentic approved photography/video | asset slots / social graphic | Pre-launch business input | replace with approved media; media budget QA |
