# Delego Architecture

## Core Modules

- IdentityAccessModule
- TenantOrgModule
- TaskModule
- CaptureIntakeModule
- AssignmentDispatchModule
- NotificationModule
- AuditComplianceModule
- SyncModule
- AnalyticsEventModule

## Runtime Topology

- `apps/api`: sync APIs, auth, tenancy, RBAC, realtime gateway.
- `apps/worker`: async OCR/scoring/notification fanout.
- PostgreSQL: primary system of record.
- Redis: queues, cache, and realtime fanout helpers.

## Design Principles

- Tenant-scoped data access everywhere.
- Contract-first APIs with OpenAPI.
- Outbox + domain events for asynchronous work.
- Offline-first mobile synchronization with idempotent endpoints.