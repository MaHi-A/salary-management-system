# ACME Salary Management

A web app for ACME's HR Manager to manage salary data for the org's 10,000
employees and answer questions about how the org pays people.

- **Backend**: Ruby on Rails (API-only) + PostgreSQL — [backend/](backend)
- **Frontend**: React (Vite) — [frontend/](frontend)
- **Docs**: requirements, design notes, AI usage — [docs/](docs)

## Run it with Docker Compose (fastest)

```bash
docker compose up -d --build
docker compose exec backend bin/rails db:seed
```

- Frontend: http://localhost:8080
- Backend API: http://localhost:3000
- Login: `hr@acme.example` / `password123` (override via `HR_USER_EMAIL` /
  `HR_USER_PASSWORD` env vars)

The `db:seed` step is separate from `up` because it's idempotent but not
automatic on every boot - `docker compose exec` runs it once against the
already-running database. Re-running it is a no-op once 10,000 employees
exist.

## Run it locally without Docker

Requirements: Ruby 3.1, Node 20+, PostgreSQL running locally.

```bash
# Backend
cd backend
bundle install
bin/rails db:setup   # creates the db, loads the schema, seeds the HR user
bin/rails db:seed    # generates the 10,000 employees (idempotent)
bin/rails server -p 3000

# Frontend (separate terminal)
cd frontend
npm install
cp .env.example .env   # points VITE_API_URL at http://localhost:3000/api
npm run dev            # http://localhost:5173
```

## Tests

```bash
cd backend && bundle exec rspec      # 45 examples: models, auth, CRUD, stats
cd frontend && npm test              # component tests (login, list, stats)
```

## Deploying for real

The Docker Compose setup is meant to demonstrate the whole stack running
together, not as a production deployment: it uses a single Postgres
container with a local volume, no TLS termination, and a hardcoded default
login. A real deployment should:

- Put a TLS-terminating proxy/load balancer in front of the API and turn
  `config.force_ssl` back on (`backend/config/environments/production.rb`).
- Use a managed Postgres instance instead of the `db` container.
- Set `SECRET_KEY_BASE`, `HR_USER_EMAIL`, and `HR_USER_PASSWORD` to real
  values rather than the Compose defaults.
