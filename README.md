# Delego Monorepo

Delego is a cross-platform operations task platform with:

- Flutter mobile frontend (`apps/mobile`)
- NestJS API (`apps/api`)
- NestJS worker pipeline (`apps/worker`)

## Quick Start

1. Install dependencies:
  - `npm install`
2. Configure environment variables:
  - copy `apps/api/.env.example` to `apps/api/.env`
  - copy `apps/worker/.env.example` to `apps/worker/.env`
3. Start infrastructure:
  - `docker compose -f infra/docker/docker-compose.yml up -d`
4. Run database migrations:
  - `npm run prisma:migrate --workspace apps/api`
5. Start backend services:
  - `npm run dev:api`
  - `npm run dev:worker`

## Architecture

See `docs/architecture/architecture.md`.