# Document Management Normalization

Each table represents a distinct record type or association. Repeating records are stored in related tables. Primary and unique keys identify records; foreign keys express relationships within this database.

1NF concerns the scalar/domain interpretation of each column. 2NF requires non-key attributes to depend on the whole candidate key. 3NF requires a nontrivial functional dependency to have a superkey determinant or a prime dependent attribute.

Nullable UNIQUE constraints and partial indexes apply to their defined non-null rows or predicates; they do not automatically establish a candidate key for every row. Captured historical values and security bindings must be explained separately from live source data.

The [data dictionary](data-dictionary.md) and [DBML](../schema/schema.dbml) define the actual keys and attributes. The model is not presented as universally strict 3NF where retained dependencies or unresolved semantics require qualification.

## Retained model choices

- `(template_id) → school_id`. Same-tenant/version composite references intentionally repeat an owner attribute. Retain integrity and reviewed identity semantics instead of adding an identity service/table.
- `(file_id) → school_id`. Same-tenant/version composite references intentionally repeat an owner attribute. Retain integrity and reviewed identity semantics instead of adding an identity service/table.
- `(storage_key) → school_id, sha256, byte_length, media_type`. Owner semantic clarification required; excluded from universal FD closure. No schema is changed on this assumption.
- `(enrollment_id) → school_id, student_id`. Frozen contract-party binding and tenant integrity; source owner must verify original binding. Not locally enforced by remote FK.
- `(generated_file_id) → school_id`. Same-tenant/version composite references intentionally repeat an owner attribute. Retain integrity and reviewed identity semantics instead of adding an identity service/table.
- `(basis_file_id) → school_id`. Same-tenant/version composite references intentionally repeat an owner attribute. Retain integrity and reviewed identity semantics instead of adding an identity service/table.
- `(template_version_id) → school_id`. Same-tenant/version composite references intentionally repeat an owner attribute. Retain integrity and reviewed identity semantics instead of adding an identity service/table.
- `(contract_id) → school_id`. Same-tenant/version composite references intentionally repeat an owner attribute. Retain integrity and reviewed identity semantics instead of adding an identity service/table.
- `(file_id) → school_id`. Same-tenant/version composite references intentionally repeat an owner attribute. Retain integrity and reviewed identity semantics instead of adding an identity service/table.
- `(enrollment_id) → school_id`. Same-tenant/version composite references intentionally repeat an owner attribute. Retain integrity and reviewed identity semantics instead of adding an identity service/table.
- `(evidence_snapshot_id) → school_id, enrollment_id, dependency_revision, evidence_status`. Historical LT snapshot is globally keyed and immutable; DM intentionally preserves its original authority tuple. This is documented owner-design semantics, not locally enforced remote integrity. Owner acceptance/current-use verification remains OPEN.
- `(document_id) → school_id, enrollment_id`. Same-tenant/version composite references intentionally repeat an owner attribute. Retain integrity and reviewed identity semantics instead of adding an identity service/table.
- `(enrollment_id) → school_id`. Same-tenant/version composite references intentionally repeat an owner attribute. Retain integrity and reviewed identity semantics instead of adding an identity service/table.
- `(template_version_id) → school_id`. Same-tenant/version composite references intentionally repeat an owner attribute. Retain integrity and reviewed identity semantics instead of adding an identity service/table.
- `(rendered_file_id) → school_id`. Same-tenant/version composite references intentionally repeat an owner attribute. Retain integrity and reviewed identity semantics instead of adding an identity service/table.
- `(basis_file_id) → school_id`. Same-tenant/version composite references intentionally repeat an owner attribute. Retain integrity and reviewed identity semantics instead of adding an identity service/table.
- `(command_id) → actor_id`. Exact audit attribution is intentionally repeated and checked against the reserved command. A command can have multiple events, so command_id is not an event key.
- `(command_id) → school_id`. Same-tenant/version composite references intentionally repeat an owner attribute. Retain integrity and reviewed identity semantics instead of adding an identity service/table.
- `(contract_id) → school_id`. The guarded dependency is established only on its stated subrelation; its universal extension is not established. Preserve the guard and clarify NULL/source interpretation before treating the dependency as universal.
- `(document_version_id) → school_id`. The guarded dependency is established only on its stated subrelation; its universal extension is not established. Preserve the guard and clarify NULL/source interpretation before treating the dependency as universal.
- `(template_id) → school_id`. The guarded dependency is established only on its stated subrelation; its universal extension is not established. Preserve the guard and clarify NULL/source interpretation before treating the dependency as universal.
- `(template_version_id) → school_id, template_id`. The guarded dependency is established only on its stated subrelation; its universal extension is not established. Preserve the guard and clarify NULL/source interpretation before treating the dependency as universal.
- `(school_id, template_version_id) → template_id`. The guarded dependency is established only on its stated subrelation; its universal extension is not established. Preserve the guard and clarify NULL/source interpretation before treating the dependency as universal.
- `(document_id) → school_id`. The guarded dependency is established only on its stated subrelation; its universal extension is not established. Preserve the guard and clarify NULL/source interpretation before treating the dependency as universal.
