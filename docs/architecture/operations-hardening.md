# Operations and Hardening

## Security
- JWT access + refresh tokens with separate secrets.
- `helmet` enabled on API for baseline HTTP hardening.
- Rate limiting enabled with Nest throttler.
- Tenant-scoped endpoints and JWT guards on protected routes.

## Observability
- API contract exposed at `/docs` (OpenAPI).
- Worker health endpoint at `/`.
- Domain event outbox persisted for async traceability.
- Audit log stream persisted in `AuditLog`.

## Performance Baselines
- Queue-oriented worker pipeline for OCR + scoring off the request path.
- Offline-first mobile local storage to reduce network dependency.
- Sync pull endpoint uses incremental `updatedAt` cursor.

## Verification
- Run `npm run verify` before release.
- Run `npm run security:audit` for vulnerability checks.
- Run integration smoke flow:
  - Register + login
  - Create tenant workspace
  - Create task + update status
  - Capture session creation
  - Worker simulation endpoint
