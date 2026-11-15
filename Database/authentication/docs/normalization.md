# Authentication Normalization

Each table represents a distinct record type or association. Repeating records are stored in related tables. Primary and unique keys identify records; foreign keys express relationships within this database.

1NF concerns the scalar/domain interpretation of each column. 2NF requires non-key attributes to depend on the whole candidate key. 3NF requires a nontrivial functional dependency to have a superkey determinant or a prime dependent attribute.

Nullable UNIQUE constraints and partial indexes apply to their defined non-null rows or predicates; they do not automatically establish a candidate key for every row. Captured historical values and security bindings must be explained separately from live source data.

The [data dictionary](data-dictionary.md) and [DBML](../schema/schema.dbml) define the actual keys and attributes. The model is not presented as universally strict 3NF where retained dependencies or unresolved semantics require qualification.

## Retained model choices

- `(identity_id) → login_email`. Retain exact security basis used by challenge, and invalidate rather than silently rewrite past challenge if future email-change support is adopted. This is a documented current-MVP FD, not a claim that historical snapshots always violate 3NF.
- `(link_session_id) → link_identity_id, purpose`. The lifecycle/protocol selector is deliberately materialized beside its exact structural-absence basis. Its CHECK/FK protects consistency; changing stored representation would affect owner lifecycle queries/DTOs/partial-index semantics.
- `(link_identity_id) → purpose`. The lifecycle/protocol selector is deliberately materialized beside its exact structural-absence basis. Its CHECK/FK protects consistency; changing stored representation would affect owner lifecycle queries/DTOs/partial-index semantics.
- `(session_id) → identity_id`. The guarded dependency is established only on its stated subrelation; its universal extension is not established. Preserve the guard and clarify NULL/source interpretation before treating the dependency as universal.
