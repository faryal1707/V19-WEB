# U. Staging, deployment, rollback

## Environments

Maintain separate development, staging and production databases, object storage, credentials, email/SMS provider keys, analytics IDs and secrets. Staging uses the same migrations as production, sandbox notifications, explicit DEMO labels, and `noindex`/access control.

## Recommended deploy sequence

1. Provision PostgreSQL with PostGIS and backups.
2. Configure production environment variables; never commit credentials.
3. Apply `001_init.sql` through the approved migration runner. Do **not** apply `002_seed_demo.sql` to production.
4. Deploy API and run `/healthz`.
5. Start notification worker and confirm queue retry behavior.
6. Deploy web assets/rewrite rules.
7. Smoke-test home, capacity search, test load request, Operations visibility, onboarding, auth, client tenant isolation, Admin capacity create→BOOKED→public disappearance, mobile and accessibility.
8. Verify sitemap/canonicals/robots and consent-gated analytics.
9. Complete stakeholder UAT.

## Rollback

- Keep the prior web artifact and API image immutable/tagged.
- If application deploy fails before schema dependency changes: redeploy prior web/API.
- If a migration is additive (V19 schema is designed to be additive), roll application back while keeping compatible columns/tables.
- For destructive future migrations, require a tested down/forward-fix strategy and a fresh database backup before applying.
- Restore database only when data corruption requires it; otherwise prefer a forward fix to avoid discarding legitimate load requests/onboarding submissions.

## Production content blockers

Final legal terms/privacy wording, verified Organization structured-data facts, approved plan commercial language, exact onboarding-document requirements, real Operations/Sales email addresses, production geocoder terms, storage provider, email provider keys, privileged-user MFA provisioning and authentic hero media require business/infrastructure configuration before launch.
