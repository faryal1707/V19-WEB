# East West Logistics V19

V19 preserves V18's navy/orange/off-white industrial identity while replacing placeholder UX with real routes, database-backed capacity, persisted load requests, onboarding, authentication, client reporting, Operations/Admin workflows, accessibility fixes, SEO infrastructure, and production deployment documentation.

## Architecture

- **Web:** Vite multi-page app using semantic HTML, shared CSS tokens, and small ES modules. This deliberately avoids a React rewrite so the strongest V18 design language can be retained with minimum churn.
- **API:** Fastify REST API.
- **Database:** PostgreSQL + PostGIS.
- **Auth:** Server-side sessions in PostgreSQL using random opaque tokens stored only as hashes; HttpOnly/Secure/SameSite cookies; RBAC and tenant checks on the server. Privileged accounts support TOTP MFA.
- **Notifications:** Durable `notifications` rows + worker/retry abstraction. Email is never the source of truth.
- **Geocoding:** Provider adapter; production must configure a provider with terms suitable for commercial use.

## Run locally

1. Copy `.env.example` to `.env` and set local values.
2. Provision PostgreSQL with PostGIS.
3. Apply `apps/api/sql/001_init.sql`, then optional demo fixtures from `002_seed_demo.sql`.
4. `npm install`
5. Run API: `npm run dev:api`
6. Run web: `npm run dev:web`

## Production blockers requiring business configuration

The code intentionally does **not** fabricate pricing, legal language, physical office address, onboarding-document requirements, customer proof, performance claims, or production capacity. Configure and approve these before launch. Demo records are explicitly marked `is_demo=true` and public capacity excludes demo records by default.

See `docs/` for the audit, architecture decision, routes, ERD, deployment, QA, accessibility, and traceability matrix.
