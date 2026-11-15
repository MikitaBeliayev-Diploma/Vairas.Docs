# Notifications Normalization

Each table represents a distinct record type or association. Repeating records are stored in related tables. Primary and unique keys identify records; foreign keys express relationships within this database.

1NF concerns the scalar/domain interpretation of each column. 2NF requires non-key attributes to depend on the whole candidate key. 3NF requires a nontrivial functional dependency to have a superkey determinant or a prime dependent attribute.

Nullable UNIQUE constraints and partial indexes apply to their defined non-null rows or predicates; they do not automatically establish a candidate key for every row. Captured historical values and security bindings must be explained separately from live source data.

The [data dictionary](data-dictionary.md) and [DBML](../schema/schema.dbml) define the actual keys and attributes. The model is not presented as universally strict 3NF where retained dependencies or unresolved semantics require qualification.

## Retained model choices

- `∅ → channel`. Keep explicit channel in the existing delivery/idempotency/provider protocol; CHECK makes the redundant dimension consistent. Removing storage requires the documented compatibility proposal, not a second channel table.
- `(recipient_user_id, contact_revision) → destination_address`. Owner semantic clarification required; excluded from universal FD closure. No schema is changed on this assumption.
- `(school_id, source_context, source_event_id) → source_id, source_revision`. Owner semantic clarification required; excluded from universal FD closure. No schema is changed on this assumption.
