# E. Data model / ERD

```mermaid
erDiagram
  ORGANIZATIONS ||--o{ ORGANIZATION_USERS : has
  USERS ||--o{ ORGANIZATION_USERS : belongs
  USERS ||--o{ SESSIONS : creates
  ORGANIZATIONS ||--o{ TRUCKS : owns
  TRUCKS ||--o{ CAPACITY : publishes
  CAPACITY ||--o{ LOAD_REQUESTS : receives
  ONBOARDING_APPLICATIONS ||--o{ CONSENTS : records
  ORGANIZATIONS ||--o{ LOADS : has
  TRUCKS ||--o{ LOADS : hauls
  LOADS ||--o{ LOAD_EVENTS : timeline
  LOADS ||--o{ DOCUMENTS : has
  ORGANIZATIONS ||--o{ DOCUMENTS : owns
  ORGANIZATIONS ||--o{ REPORTS : has
  USERS ||--o{ AUDIT_LOGS : acts
  ORGANIZATIONS ||--o{ AUDIT_LOGS : scopes
  ORGANIZATIONS ||--o{ USER_INVITATIONS : invites
  NOTIFICATIONS }o--|| LOAD_REQUESTS : may_reference
  NOTIFICATIONS }o--|| ONBOARDING_APPLICATIONS : may_reference
```

The canonical schema is `apps/api/sql/001_init.sql`; `002_seed_demo.sql` is explicitly DEMO-only and public capacity excludes demo records unless a non-production flag is enabled.
