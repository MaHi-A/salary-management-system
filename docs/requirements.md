# Requirements — ACME Salary Management

## Goal
Replace ACME's spreadsheet-based salary tracking with a web app that lets the
HR Manager manage salary data for ACME's 10,000 employees and answer
questions about how the org pays people (e.g. average pay by country or
department, headcount, total payroll).

## User
Single persona: the HR Manager. No other roles are modeled.

## In scope
- **Employee directory**: list all employees with search (name/email),
  filter by country and department, sort by salary, and pagination (needed
  at 10,000 rows).
- **Employee record management**: view, create, edit, and remove an
  employee's details and current salary.
- **Pay analytics**: headcount, and average/median/min/max salary, broken
  down by country and by department, plus total payroll — this is what lets
  the HR Manager answer "how do we pay people" questions.
- **Login**: a single seeded HR Manager account gates access to the app.
- **Seed data**: a script that generates 10,000 realistic employee records
  across several countries, departments, and job titles, so the app can be
  exercised at real scale.

## Explicitly out of scope (and why)
- **Salary history / audit trail** — tracking every raise or promotion over
  time roughly doubles the data model and UI (a `salary_changes` table, a
  timeline view, historical analytics) for a feature the problem statement
  doesn't ask for. The HR Manager needs to know current pay, not its history.
  Left as a natural extension point.
- **Multiple roles / permissions (RBAC)** — the problem statement names one
  persona (HR Manager). Modeling employee self-service logins, manager
  approval chains, or granular permissions would be speculative scope with
  no stated requirement behind it.
- **Live currency conversion** — employees are paid in their country's local
  currency. Converting to a common currency for cross-country comparisons
  would require an exchange-rate feed (an external dependency and a source
  of non-determinism) for a "nice to have" rather than a stated requirement.
  Per-country breakdowns already answer the core pay-equity questions without it.
- **Org chart / manager hierarchy** — no reporting-line data is requested,
  and modeling it would add a self-referential association and tree-shaped
  UI with no requirement driving it.
- **Notifications / email** — nothing in the problem statement requires
  notifying anyone of changes; adding it would mean standing up mail
  infrastructure for a feature that isn't needed.
- **Password reset / multi-user account management** — with a single seeded
  HR account, self-service account flows aren't needed to satisfy the
  problem statement.

## Technical approach
- Backend: Ruby on Rails (API-only) + PostgreSQL.
- Frontend: React (Vite).
- Auth: single seeded HR user, token-based session.
- Fully seeded with 10,000 employees for realistic-scale testing of search,
  filtering, sorting, and pagination.
