# Design Notes

## Architecture

```
┌─────────────┐      HTTPS/JSON       ┌──────────────────┐      SQL      ┌────────────┐
│ React (Vite)│  ───────────────────▶ │ Rails API (JWT)  │ ─────────────▶│ PostgreSQL │
│  port 5173  │ ◀─────────────────── │   port 3000       │ ◀─────────────│            │
└─────────────┘                       └──────────────────┘                └────────────┘
```

- **Backend**: Rails 7.1, `--api` mode. No server-rendered views, no
  sessions/cookies - a stateless JSON API.
- **Frontend**: React (Vite) SPA, talking to the API over `fetch`/axios.
  React Router handles client-side routing; a small `AuthContext` holds the
  JWT in `localStorage`.
- **Auth**: `POST /api/login` issues a JWT (24h expiry) signed with Rails'
  `secret_key_base`. Every other `/api/*` endpoint requires
  `Authorization: Bearer <token>`, checked by the `Authenticatable`
  controller concern. Token-based rather than cookie sessions because the
  frontend and API are different origins in development (`:5173` vs
  `:3000`) and in general deployment.

## Data model

One table, `employees`, with a fixed set of countries and departments
defined as constants on the `Employee` model (`COUNTRIES`,
`DEPARTMENTS`, `COUNTRY_CURRENCIES`). Keeping these as an in-app
allowlist (rather than free-text or a separate `countries` table) means:

- Filtering/validation is trivial (`inclusion: { in: COUNTRIES }`).
- Every employee's currency is derivable from their country - there's
  never an employee with a currency that doesn't match where they're
  paid.
- The seed script can generate realistic, evenly-distributed data
  without needing a lookup table.

The trade-off: adding a country later means a code change + migration,
not a data-only change. Acceptable for this assessment's scope; a real
multi-tenant version would move this to a `countries` table.

Salary is stored as `salary_cents` (integer), not a float/decimal
dollars column, to avoid floating-point rounding on money. The model
exposes a `#salary`/`#salary=` pair that converts to/from decimal
dollars at the boundary, so the rest of the app (controllers, tests,
JSON) never has to think in cents.

## Why pay analytics never mixes currencies

Employees are paid in their own country's local currency - there is no
currency conversion in this app (see `docs/requirements.md`'s explicit
exclusions). That has a real consequence for `/api/stats`: you cannot
sum or average `salary_cents` across employees in different countries,
because 1 unit of INR and 1 unit of USD aren't the same thing. An
early draft of this endpoint did exactly that (summed every employee's
`salary_cents` into one "total payroll" figure, and averaged salary
by department across all countries at once) - both numbers were
silently wrong, just plausible-looking. It was caught by inspection
before shipping, not by a test (nothing asserted that the currencies
matched), which says something about the test coverage; the fix adds
that fields matches, e.g. an average is always alongside a `currency`
field, but future work should assert that the *underlying* aggregation
never crosses a currency boundary.

The fix: `by_country` groups by country alone (one currency per
country, so any aggregate within a row is valid); `by_department`
groups by **department and country together**, so a "Sales, France"
row is its own single-currency aggregate rather than folding France,
India, and the US into one meaningless "Sales" number. The frontend's
department view defaults to showing every (department, country) row,
with a department filter to narrow it down.

## Pagination and scale

The employee list is backed by Kaminari, with `per_page` capped at 100
to prevent an unbounded `?per_page=999999` from forcing a large table
scan. `country`, `department`, and `salary_cents` are indexed since
those are exactly the filter/sort columns used by `/api/employees`.
The seed script inserts 10,000 rows in 10 batches of 1,000 via
`Employee.insert_all`, rather than 10,000 individual `create!` calls,
which is the difference between seeding in ~3.5s and taking much
longer while generating 10,000 individual `INSERT` statements/AR
object instantiations.

## Frontend structure

- `api/client.js` - a single axios instance with a request interceptor
  that reads the JWT from `localStorage` on every call (rather than
  setting a default header from a `useEffect`, which raced the first
  page's data fetch on load - see git history) and a response
  interceptor that clears the token and bounces to `/login` on a 401.
- `auth/AuthContext.jsx` - login/logout and `isAuthenticated`, wrapping
  the whole app.
- `components/EmployeeForm.jsx` - shared between "add employee" and
  "edit employee", so the two flows can't drift apart.
- `pages/` - one file per route; each page owns its own data fetching
  (no global state library) since nothing here needs to be shared
  beyond the current page's props/state.

## Deployment

`docker-compose.yml` runs Postgres, the Rails API (from the existing
production `Dockerfile`), and the React build served via nginx - see
the README for how to run it. It's meant as a way to demonstrate the
whole stack running together locally; a real deployment would put a
TLS-terminating proxy/load balancer in front of the API (see the
comment on `config.force_ssl` in
`backend/config/environments/production.rb`) and use a managed
Postgres instance rather than a container with a local volume.
