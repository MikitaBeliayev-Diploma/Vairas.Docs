# School Management Normalization

Each table represents a distinct record type or association. Repeating records are stored in related tables. Primary and unique keys identify records; foreign keys express relationships within this database.

1NF concerns the scalar/domain interpretation of each column. 2NF requires non-key attributes to depend on the whole candidate key. 3NF requires a nontrivial functional dependency to have a superkey determinant or a prime dependent attribute.

Nullable UNIQUE constraints and partial indexes apply to their defined non-null rows or predicates; they do not automatically establish a candidate key for every row. Captured historical values and security bindings must be explained separately from live source data.

The [data dictionary](data-dictionary.md) and [DBML](../schema/schema.dbml) define the actual keys and attributes. The model is not presented as universally strict 3NF where retained dependencies or unresolved semantics require qualification.

## Retained model choices

- `(status, status_changed_at) → ended_at`. Retain explicit lifecycle instant/end with CHECK equality; dependent is a derived duplicate, not a second enrollment lifecycle.
- `(to_status) → from_status`. Retain explicit from/to transition evidence as self-contained audit history. Same CHECK protects the deterministic previous-state shape.
- `(enrollment_id) → school_id`. Same-tenant/version composite references intentionally repeat an owner attribute. Retain integrity and reviewed identity semantics instead of adding an identity service/table.
- `(enrollment_id) → association_program_version_id`. Historical verified programme-binding evidence is intentionally repeated across group membership intervals; no programme transfer is allowed. School stores evidence, not authoritative current programme.
- `(enrollment_id) → student_id, category_code`. Frozen organizational snapshot keeps source identity/category for historical interpretation; School handler checks exact EnrollmentId/revision. No current profile/name is copied.
- `(enrollment_id, enrollment_revision) → student_id, category_code, enrollment_status, enrollment_started_at, enrollment_ended_at`. Do not derive captured status/end from EnrollmentId alone: they change across revisions. Preserve the exact captured version and prevent conflicting snapshot contents in handler.
- `(accepted_at, revoked_at) → status`. The lifecycle/protocol selector is deliberately materialized beside its exact structural-absence basis. Its CHECK/FK protects consistency; changing stored representation would affect owner lifecycle queries/DTOs/partial-index semantics.
- `(accepted_operation_id, revoked_operation_id) → status`. The lifecycle/protocol selector is deliberately materialized beside its exact structural-absence basis. Its CHECK/FK protects consistency; changing stored representation would affect owner lifecycle queries/DTOs/partial-index semantics.
- `(created_at) → expires_at`. Owner semantic clarification required; excluded from universal FD closure. No schema is changed on this assumption.
