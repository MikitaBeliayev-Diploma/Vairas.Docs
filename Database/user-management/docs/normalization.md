# User Management Normalization

Each table represents a distinct record type or association. Repeating records are stored in related tables. Primary and unique keys identify records; foreign keys express relationships within this database.

1NF concerns the scalar/domain interpretation of each column. 2NF requires non-key attributes to depend on the whole candidate key. 3NF requires a nontrivial functional dependency to have a superkey determinant or a prime dependent attribute.

Nullable UNIQUE constraints and partial indexes apply to their defined non-null rows or predicates; they do not automatically establish a candidate key for every row. Captured historical values and security bindings must be explained separately from live source data.

The [data dictionary](data-dictionary.md) and [DBML](../schema/schema.dbml) define the actual keys and attributes. The model is not presented as universally strict 3NF where retained dependencies or unresolved semantics require qualification.

## Technical outbox

`event_id` is the declared key of `outbox_message`; each event determines its immutable message metadata and mutable delivery state. No uniqueness is assumed for `aggregate_id`, `aggregate_version` or their pair. A single-column primary key has no proper-subset dependency, but this alone does not prove 3NF: any additional functional dependencies require domain justification.

`body` retains the exact outgoing JSON envelope/payload. It may intentionally repeat event and aggregate identifiers stored in relational routing columns. This is a documented delivery snapshot/denormalization, not a second editable source of profile data or an unconditional 3NF claim about JSON contents. The event body and routing metadata remain immutable after insertion; only delivery/lease fields can be updated by runtime grants.
