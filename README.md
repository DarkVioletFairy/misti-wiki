# Mistique's Field Report

A fast, public wiki for Stella Sora game data and player-made guides. 

Public users can browse published content only. Administrative editing, templates, page drafts, publishing, and imported-data review are protected by Rails authorization.

## Tech Stack

- **Web:** Nuxt 3, Vue 3, and TypeScript with server-side rendering.
- **API:** Rails 8 API application.
- **Database:** PostgreSQL 17.
- **Assets:** Cloudflare R2 or compatible object storage behind a CDN in production.
- **Local services:** PostgreSQL installed on the development machine.
- **Package management:** pnpm for the Nuxt application and Bundler for Rails.

## Local Setup

### Prerequisites

- Node.js 24 or later and pnpm 12 or later.
- Ruby 4.0.5 and Bundler. The required version is recorded in `apps/api/.ruby-version`.
- PostgreSQL 17 or later, including `createuser` and `createdb`.

### 1. Configure environment variables

```sh
cp .env.example .env
set -a
source .env
set +a
```

The supplied values are for local development only. Do not commit `.env`.

### 2. Create local databases

```sh
createuser --createdb --login stella
createdb -O stella ss_info_development
createdb -O stella ss_info_test
```

If your local PostgreSQL role differs, update `POSTGRES_USER`, `POSTGRES_PASSWORD`, and the database names in `.env`. The configured role must be allowed to create the development and test databases.

### 3. Install dependencies

```sh
pnpm install
cd apps/api
bundle config set --local path vendor/bundle
bundle install
cd ../..
```

If `bundle` resolves to an incompatible Ruby through a version manager, activate the Ruby version in `apps/api/.ruby-version` before installing.

### 4. Prepare the database

```sh
set -a
source .env
set +a
pnpm db:prepare
pnpm db:seed
```

### 5. Create the first owner account

```sh
ADMIN_EMAIL=admin@example.test ADMIN_PASSWORD=replace-with-a-long-unique-password pnpm admin:create
```

This command can be run again to reset that owner's password. Keep the password out of shell history in production workflows.

### 6. Start the web and API applications

```sh
set -a
source .env
set +a
pnpm dev
```

- Public Nuxt application: `http://localhost:3000`
- Rails API health check: `http://localhost:3001/api/v1/health`

Run one process at a time with `pnpm dev:web` or `pnpm dev:api`.

## Common Commands

```sh
pnpm build
pnpm lint
pnpm test
pnpm db:migrate
pnpm db:seed
ADMIN_EMAIL=admin@example.test ADMIN_PASSWORD=your-password pnpm admin:create
```

`pnpm test` runs Nuxt unit tests and Rails tests. The first feature work should add tests for the behavior it introduces.


## Repository Layout

- `apps/web/`: Nuxt public wiki and protected admin UI.
- `apps/api/`: Rails API, jobs, imports, and database migrations.
- `assets/`: static assets and fixtures, excluding upstream game asset repositories.
- `tests/`: cross-application integration and end-to-end tests.
