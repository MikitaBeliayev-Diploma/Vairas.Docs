# Contract changelog

## 2026-11-22 — architecture alignment (design additions 0.2.0)

- Corrected implemented User Management response enums, transient export server origin, operation IDs, unknown-property rules and request constraints; added explicit examples. Current successful receipt code is APPLIED, not a resource representation.
- Added proposed Authentication, Chat Backend and operational specifications. Auth/School/Chat dependency views now have checked canonical provider counterparts.
- Added initial scheduling draft/submission/proposal/confirmation lifecycle, protected availability, manual moves/cancellation, theory lessons, repeated assessments, rule versions and operation reconciliation.
- Added practical facts/corrections/disputes, theory attendance, readiness decisions, assessment results, completion evidence/report and document download contracts.
- Corrected Notifications states to include Sending and DeliveryUnknown. Kept the optional maintenance-notification incompatibility visible in the audit.
- Supplied eight proposed MCP tools, exact-approval/security guidance, two integration tutorials, generated HTTP reference, architecture/coverage matrices.
- Corrected legacy malformed YAML response descriptions and missing path parameters. Event wire shapes remain v1; sender status now distinguishes implemented User Management from unverified consumers.

These changes do not deploy services, alter business database schemas, provision topics/subscriptions or migrate live consumers. New provider interfaces remain proposals. See [versioning policy](guides/versioning.md) before adopting them in a running system.

## G-01 amendment — 2026-11-22

- Added Scheduling actual interval and OLD-state history migration, constraints and runtime column grant.
- Aligned practical/theory completion, audited interval correction and complete source identities.
- Clarified completion-event reconciliation after correction, legacy unknown actuals and fresh Learning confirmations.
- Schema/contract change only; no provider or production migration is claimed.

## Documentation package cleanup

- Kept contracts, reference, architecture, database DDL/migrations, roles and synthetic seeds.
- Removed executable tests, validation/generation utilities, dependency manifests/caches, temporary provenance and the already-applied patch.
- Added the technical User Management outbox to DBML, ERD and the data dictionary.
- Indexed Database and Microservices expert requirements; implementation evidence remains separate.

## Final contract review ? 2026-11-23

- Corrected rejected-response examples, health/identity authorization descriptions and revision progression.
- Aligned group theory attendance, read/correction and teacher-confirmation interfaces with the existing immutable roster/version schema.
- Added historical membership lookup bounds and enrollment concurrency version; made practical correction CAS/reason mandatory.
- Updated MCP examples and preview idempotency hints, event credit semantics, all HTTP reference pages and review scope.
- These changes complete the documentation package; proposed service handlers, integration and deployment remain separate implementation work.
