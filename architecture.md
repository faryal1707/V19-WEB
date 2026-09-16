# C. Architecture decision

## Option A — incremental V18 frontend + dedicated API **(selected)**

- Vite multi-page frontend, preserving V18 HTML/CSS/JS patterns.
- Fastify API.
- PostgreSQL + PostGIS.
- Server-side opaque sessions with Argon2id passwords and optional TOTP MFA for privileged users.
- S3-compatible document storage adapter (storage integration is a production configuration point).
- Durable notifications table + retry worker; Resend adapter supplied, SMS abstraction disabled unless configured.

**Why selected:** it minimizes unnecessary visual/frontend rewrite, keeps public pages fast and inspectable, supports protected portal/admin data through the API, keeps geospatial logic in PostgreSQL/PostGIS, and isolates operational domain logic from a single hosting/auth vendor.

## Option B — full-stack/serverless migration

- Next.js/SvelteKit/Remix-style framework.
- Managed PostgreSQL/PostGIS plus managed auth/storage/functions such as Supabase.
- Transactional email and optional SMS.

**Tradeoff:** attractive for consolidated deployment, but it creates a larger V18 frontend migration and stronger framework/vendor coupling than is needed to solve the current P0 defects.

## Hosting model

GitHub Pages is not sufficient for the complete V19 product because authenticated cookie sessions, protected API routes, background notification retries and database access require a backend. Static public assets can still be CDN-hosted, but production should deploy web + API behind HTTPS with stable app/API origins.

## Security model

- Session tokens are random opaque values. Only SHA-256 hashes are stored in PostgreSQL.
- Production session cookie uses the `__Host-` prefix, `Secure`, `HttpOnly`, `SameSite=Lax`, `Path=/`; CSRF uses a separate double-submit token plus the server session hash.
- Authorization is server-side. Portal requests check organization membership; unauthorized tenant IDs return not-found behavior.
- Privileged roles are distinct (`OPERATIONS`, `ADMIN`) and the data model supports TOTP MFA.
- Secrets remain environment variables; `.env.example` contains placeholders only.

Primary references: W3C WAI modal dialog guidance, OWASP Session Management guidance, PostGIS `ST_DWithin`, Google Search Central, and web.dev Core Web Vitals.
