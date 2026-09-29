# AI Usage Notes

This project was built with Claude Code (Anthropic's CLI agent) working
directly in this repo - writing code, running commands, and testing in a
real browser, not just generating snippets to paste in.

## Division of labor

- **I (the candidate) made the product/architecture decisions** when asked:
  Ruby on Rails + PostgreSQL for the backend, React for the frontend,
  current-salary-only (no history), a single seeded login (no multi-role
  auth), and how the finished repo would get to GitHub. Claude surfaced
  these as explicit questions rather than assuming defaults, before
  writing any code.
- **Claude Code planned the implementation** (data model, endpoints, git
  commit sequence, artifacts) as a written plan I approved before
  implementation started, then executed it commit-by-commit rather than
  as one large diff - each commit is a coherent, working slice (model,
  then auth, then CRUD endpoints, then stats, then seed data, then each
  frontend page, then tests, then Docker).
- **Claude Code wrote the requirements doc first**, before any code, per
  the assessment's own instructions to write a one-pager outlining goal,
  scope, and deliberate exclusions with reasoning.
- **Claude Code tested its own work continuously**: running the RSpec and
  Vitest suites after each change, and driving the actual app in a real
  browser (login, search/filter/sort/paginate the employee list, create/
  edit an employee, view the stats dashboard) rather than only relying on
  automated tests.

## A bug AI-assisted development caught (and one it introduced)

- **Caught**: the pay-analytics endpoint's first draft summed
  `salary_cents` across every employee regardless of currency, and
  averaged salary "by department" across all countries in that
  department at once. Both numbers were plausible-looking but wrong,
  since employees are paid in different local currencies. This was caught
  by inspection while building the frontend dashboard for it - before it
  shipped - and fixed by scoping every aggregate to a single currency
  (see `docs/design-notes.md`). It's a good example of why "the tests
  pass" isn't the same as "the numbers are right": nothing in the test
  suite at that point asserted currency-consistency, only that the
  arithmetic matched the (equally wrong) endpoint logic.
- **Introduced, then fixed**: while wiring `/api/stats` to return
  currency alongside each aggregate, an intermediate draft used
  `ActiveRecord#pluck` with several raw-SQL columns mixed with a plain
  column reference; Rails mis-cast the string `currency` column as `0`
  when plucked positionally alongside multiple aggregate expressions.
  Switched to named `SELECT ... AS alias` + hash-style row access, which
  types results correctly. Left as a design note in
  `docs/design-notes.md` since it's a non-obvious pitfall of `pluck`
  with many raw SQL columns.

## Where AI made mistakes worth naming

- The Docker Compose deployment didn't work on the first attempt: a
  leftover `production:` block in the generated `config/database.yml`
  silently overrode the working default credentials with a different,
  unset environment variable name; `faker` (needed by the seed script)
  was only installed in the dev/test Gemfile group and missing in the
  production image; and Rails' default `config.force_ssl = true`
  redirected the API to HTTPS, which this Compose setup doesn't
  terminate. All three were caught by actually running
  `docker compose up` and testing login/browsing in a real browser
  against the containers, not by reading the config and assuming it was
  right.
