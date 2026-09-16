# V. QA / release checklist

## P0 product
- [ ] Zero unintended `href="#"` (`npm run check:links`).
- [ ] Every internal route resolves on production rewrite host.
- [ ] Public capacity originates from PostgreSQL, not HTML fixtures.
- [ ] Origin geocodes; radius uses PostGIS; date/equipment filter server-side.
- [ ] BOOKED/HOLD/INACTIVE/EXPIRED capacity does not appear as public available.
- [ ] Send Load success shown only after API persistence; duplicate requests are idempotent.
- [ ] Operations sees persisted load requests even if email delivery fails.
- [ ] Onboarding returns persisted reference; optional marketing remains unchecked.
- [ ] Login, reset, invitation activation, logout and session expiry pass.
- [ ] Tenant isolation: Client A cannot fetch Client B organization routes by ID.
- [ ] Admin modifications produce audit rows.

## Accessibility — WCAG 2.2 AA target
- [ ] VoiceOver + Safari.
- [ ] NVDA + Chrome.
- [ ] Keyboard-only complete tasks.
- [ ] Native Send Load dialog: initial focus, trapped modal focus, Escape, focus return.
- [ ] 200% zoom, no lost controls/horizontal task-breaking scroll.
- [ ] 44x44 practical primary controls.
- [ ] Contrast tested for all states, especially orange actions.
- [ ] Reduced motion: CSS + JS; no auto-advance.
- [ ] Automated axe run in CI/staging.

## Responsive
- [ ] 320 / 360 / 390 / 430 / 768 / 1024 / 1280 / 1440 / 1920.
- [ ] iOS Safari and Android Chrome.
- [ ] On-screen keyboard does not hide active onboarding/load fields.
- [ ] Tables remain usable through responsive overflow rather than unreadable scaling.

## SEO / privacy
- [ ] Unique title/description/canonical on every public page.
- [ ] Social image returns 200.
- [ ] `sitemap.xml`, `robots.txt`, redirects validated.
- [ ] Portal/admin are noindex and excluded from sitemap.
- [ ] Organization JSON-LD is added only after verified public company facts are approved.
- [ ] Analytics fires only after real API success and excludes PII.

## Performance
- [ ] Production RUM tracks LCP ≤2.5 s, INP ≤200 ms, CLS ≤0.1 at p75.
- [ ] Hero media, when supplied, has mobile poster/reduced-motion handling and explicit dimensions.
- [ ] No production image/video exceeds agreed budgets without review.

## Security
- [ ] HTTPS/HSTS production.
- [ ] Secure/HttpOnly/SameSite session cookie confirmed.
- [ ] CSRF tests on mutating authenticated routes.
- [ ] Rate limits verified.
- [ ] Parameterized SQL only.
- [ ] File upload type/size/storage policy implemented before enabling uploads.
- [ ] Secrets scan.
- [ ] MFA enforced for privileged production accounts.
