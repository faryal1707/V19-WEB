# D. V19 sitemap and route table

## Public

| Route | Static file | Purpose |
|---|---|---|
| `/` | `index.html` | Home |
| `/solutions` | `solutions.html` | Solutions overview + substantive anchors |
| `/carriers` | `carriers.html` | Owner Operators, Small Fleets, Growing Carriers |
| `/capacity` | `capacity.html` | Database-backed broker capacity search |
| `/plans` | `plans.html` | Core / Premium / Custom |
| `/reporting` | `reporting.html` | Public reporting explanation/formulas |
| `/onboarding` | `onboarding.html` | Five-step carrier application |
| `/contact` | `contact.html` | Sales / Operations / client access |
| `/login` | `login.html` | Authentication |
| `/forgot-password` | `forgot-password.html` | Reset request |
| `/reset-password` | `reset-password.html` | Reset completion |
| `/activate` | `activate.html` | Invitation/account activation |
| `/privacy` | `privacy.html` | Legal structure; counsel review blocker |
| `/terms` | `terms.html` | Legal structure; counsel review blocker |
| `/accessibility` | `accessibility.html` | Accessibility target + feedback path |
| `/404` | `404.html` | Not found |

`/availability` permanently redirects to `/capacity`.

## Protected client

`/portal/dashboard`, `/portal/loads`, `/portal/reports`, `/portal/documents`, `/portal/account`, `/portal/team`, `/portal/support`.

## Protected Operations/Admin

`/admin/capacity`, `/admin/load-requests`, `/admin/applications`, `/admin/clients`, `/admin/audit`.

Production host rewrite rules live in `apps/web/_redirects`; authenticated routes are disallowed in `robots.txt` and carry `noindex,nofollow` metadata.
