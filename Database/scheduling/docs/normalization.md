# Scheduling Normalization

Each table represents a distinct record type or association. Repeating records are stored in related tables. Primary and unique keys identify records; foreign keys express relationships within this database.

1NF concerns the scalar/domain interpretation of each column. 2NF requires non-key attributes to depend on the whole candidate key. 3NF requires a nontrivial functional dependency to have a superkey determinant or a prime dependent attribute.

Nullable UNIQUE constraints and partial indexes apply to their defined non-null rows or predicates; they do not automatically establish a candidate key for every row. Captured historical values and security bindings must be explained separately from live source data.

The [data dictionary](data-dictionary.md) and [DBML](../schema/schema.dbml) define the actual keys and attributes. The model is not presented as universally strict 3NF where retained dependencies or unresolved semantics require qualification.

## Retained model choices

- `(id) → school_id`. Same-tenant/version composite references intentionally repeat an owner attribute. Retain integrity and reviewed identity semantics instead of adding an identity service/table.
- `(enrollment_id) → student_id`. The guarded dependency is established only on its stated subrelation; its universal extension is not established. Preserve the guard and clarify NULL/source interpretation before treating the dependency as universal.
- `(enrollment_id) → category_code`. The guarded dependency is established only on its stated subrelation; its universal extension is not established. Preserve the guard and clarify NULL/source interpretation before treating the dependency as universal.
- `(enrollment_id) → training_program_version_id`. The guarded dependency is established only on its stated subrelation; its universal extension is not established. Preserve the guard and clarify NULL/source interpretation before treating the dependency as universal.
- `(training_program_version_id) → category_code`. Owner semantic clarification required; excluded from universal FD closure. No schema is changed on this assumption.
- `(source_kind) → override_policy`. Keep current explicit protocol/policy dimension under its exact CHECK for MVP; deriving it in persistence would require coordinated EF/rule/DTO compatibility work, proposed below.
- `(override_policy) → source_kind`. Keep current explicit protocol/policy dimension under its exact CHECK for MVP; deriving it in persistence would require coordinated EF/rule/DTO compatibility work, proposed below.
- `(rule_id) → source_kind, school_id`. Owner semantic clarification required; excluded from universal FD closure. No schema is changed on this assumption.
- `(enrollment_id) → student_id, category_code`. The guarded dependency is established only on its stated subrelation; its universal extension is not established. Preserve the guard and clarify NULL/source interpretation before treating the dependency as universal.
- `(candidate_lesson_id) → membership_revision`. Owner semantic clarification required; excluded from universal FD closure. No schema is changed on this assumption.
- `(weekdays) → frequency`. The lifecycle/protocol selector is deliberately materialized beside its exact structural-absence basis. Its CHECK/FK protects consistency; changing stored representation would affect owner lifecycle queries/DTOs/partial-index semantics.
- `(enrollment_id) → school_id, student_id, category_code`. The guarded dependency is established only on its stated subrelation; its universal extension is not established. Preserve the guard and clarify NULL/source interpretation before treating the dependency as universal.
- `(series_id) → school_id, kind`. The guarded dependency is established only on its stated subrelation; its universal extension is not established. Preserve the guard and clarify NULL/source interpretation before treating the dependency as universal.
- `(lesson_id) → membership_revision`. Owner semantic clarification required; excluded from universal FD closure. No schema is changed on this assumption.
- `(request_id) → school_id`. The guarded dependency is established only on its stated subrelation; its universal extension is not established. Preserve the guard and clarify NULL/source interpretation before treating the dependency as universal.
- `(request_id, request_revision) → school_id`. The guarded dependency is established only on its stated subrelation; its universal extension is not established. Preserve the guard and clarify NULL/source interpretation before treating the dependency as universal.
- `(target_lesson_id) → school_id`. The guarded dependency is established only on its stated subrelation; its universal extension is not established. Preserve the guard and clarify NULL/source interpretation before treating the dependency as universal.
- `(result_lesson_id) → school_id`. The guarded dependency is established only on its stated subrelation; its universal extension is not established. Preserve the guard and clarify NULL/source interpretation before treating the dependency as universal.
- `(target_appointment_id) → school_id`. The guarded dependency is established only on its stated subrelation; its universal extension is not established. Preserve the guard and clarify NULL/source interpretation before treating the dependency as universal.
- `(result_appointment_id) → school_id`. The guarded dependency is established only on its stated subrelation; its universal extension is not established. Preserve the guard and clarify NULL/source interpretation before treating the dependency as universal.
- `(operation_id) → school_id`. Same-tenant/version composite references intentionally repeat an owner attribute. Retain integrity and reviewed identity semantics instead of adding an identity service/table.
- `(operation_id, lesson_id) → starts_at, ends_at`. Owner semantic clarification required; excluded from universal FD closure. No schema is changed on this assumption.
- `(lesson_id) → school_id`. Same-tenant/version composite references intentionally repeat an owner attribute. Retain integrity and reviewed identity semantics instead of adding an identity service/table.
- `(operation_id) → school_id`. Same-tenant/version composite references intentionally repeat an owner attribute. Retain integrity and reviewed identity semantics instead of adding an identity service/table.
- `(enrollment_id) → school_id, student_id`. Every valid appointment is bound to the immutable owner-validated enrollment school/student. Category immutability remains separately proposed.
- `(enrollment_id) → category_code`. Owner semantic clarification required; excluded from universal FD closure. No schema is changed on this assumption.
