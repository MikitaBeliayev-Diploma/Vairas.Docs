# Scheduling implementation extension — 2026-11-24

D-044 remains the adopted original 17-table design. G-01 adds physical actual bounds. Migration 003 explicitly adds nine columns and six technical/workflow tables, producing 23 tables. The initial and G-01 SQL remain byte-identical; this extension does not relabel the alternative refined design as adopted.

## Added columns

| Table | Column | PostgreSQL type | Required |
|---|---|---|---|
| `scheduling_operation` | `fingerprint` | `varchar(64)` | True |
| `scheduling_operation` | `result_json` | `text` | True |
| `scheduling_operation` | `http_status` | `integer` | True |
| `scheduling_request` | `inputs_json` | `text` | True |
| `scheduling_request` | `basis_json` | `text` | True |
| `scheduling_request` | `school_revision` | `bigint` | True |
| `assessment_appointment` | `readiness_evaluation_id` | `uuid` | True |
| `assessment_appointment` | `revision` | `integer` | True |
| `lesson_participant` | `is_active` | `boolean` | True |

`inputs_json`, `basis_json`, `payload_json` and receipts are serialized text controlled by the application, not an alternative JSONB schema. Frozen command/owner evidence may contain personal identifiers; restrict access and apply the approved retention policy. Legacy added columns use migration defaults, not reconstructed authoritative evidence.

## Reliability tables

### gate_command

Immutable Vehicle command fingerprint and terminal receipt.

| Column | PostgreSQL type | Required | Key |
|---|---|---|---|
| `id` | `uuid` | True | PK |
| `school_id` | `uuid` | True |  |
| `fingerprint` | `text` | True |  |
| `kind` | `text` | True |  |
| `result_json` | `text` | True |  |
| `http_status` | `integer` | True |  |

### outbox_message

Transactional committed lesson event with recoverable publishing lease.

| Column | PostgreSQL type | Required | Key |
|---|---|---|---|
| `id` | `uuid` | True | PK |
| `school_id` | `uuid` | True |  |
| `aggregate_id` | `uuid` | True |  |
| `aggregate_version` | `integer` | True |  |
| `event_type` | `text` | True |  |
| `payload` | `text` | True |  |
| `occurred_at` | `timestamp with time zone` | True |  |
| `available_at` | `timestamp with time zone` | True |  |
| `lease_id` | `uuid` | False |  |
| `lease_until` | `timestamp with time zone` | False |  |
| `published_at` | `timestamp with time zone` | False |  |
| `attempts` | `integer` | True |  |

### school_barrier

One tenant revision floor and pending eligibility fence.

| Column | PostgreSQL type | Required | Key |
|---|---|---|---|
| `school_id` | `uuid` | True | PK |
| `revision_floor` | `bigint` | True |  |
| `pending_operation_id` | `uuid` | False |  |

### school_transition

Retained immutable School transition basis and recovery state.

| Column | PostgreSQL type | Required | Key |
|---|---|---|---|
| `id` | `uuid` | True | PK |
| `school_id` | `uuid` | True |  |
| `before_revision` | `bigint` | True |  |
| `after_revision` | `bigint` | True |  |
| `fingerprint` | `text` | True |  |
| `payload_json` | `text` | True |  |
| `status` | `text` | True |  |
| `created_at` | `timestamp with time zone` | True |  |

### vehicle_block

Exact independently releasable Vehicle booking protection.

| Column | PostgreSQL type | Required | Key |
|---|---|---|---|
| `id` | `uuid` | True | PK |
| `school_id` | `uuid` | True |  |
| `vehicle_id` | `uuid` | True |  |
| `operation_id` | `uuid` | True |  |
| `reason` | `text` | True |  |
| `status` | `text` | True |  |
| `created_at` | `timestamp with time zone` | True |  |

### vehicle_guard

Shared global Vehicle lock identity and owner-school binding.

| Column | PostgreSQL type | Required | Key |
|---|---|---|---|
| `vehicle_id` | `uuid` | True | PK |
| `school_id` | `uuid` | True |  |

Global reservation writes serialize on one transaction advisory lock; native exclusions remain the final conflict protection. Runtime is tenant-scoped with RLS; reservation authority and Outbox worker use distinct minimal roles/connections. All instances must share the same Scheduling database. No external owner table is joined through database credentials.

## Installation and upgrades

Provision the four roles as administrator, create the database as migration owner and apply `security/prepare-schema.sql`. Fresh raw SQL installations use `ddl/install.sql`; EF installations use the three migrations from Backend, followed by `security/database-roles.sql` and `security/reliability-grants.sql`. Use exactly one installation route. Migrations are never run by API startup.

Existing raw G-01 installations require reviewed insertion of the ActualInterval history entry after verifying their exact schema, then migration 003. Never reapply `initial.sql` or fabricate migration history for an unknown schema. Existing live migrations require backup/restore and staging review.

## Verified implementation and limits

ASP.NET Core 10/EF Core/Npgsql source implements planning, reservation, physical completion/correction, append-only evidence, outbox and School/Vehicle gates. Coverlet and real PostgreSQL 17 Testcontainers verification are recorded in Backend/Vairas.Scheduling/VALIDATION.md. Four actual Auth/UM/School/Scheduling pipelines were exercised using an in-process HTTP transport. Vehicle, Learning and Chat providers use doubles only in tests; live broker delivery and public production deployment were not performed. Learning still owns training minutes, attendance, confirmations and credit.
