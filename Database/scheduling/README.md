# Scheduling Database

| Material | File |
|---|---|
| Logical schema and relationships | [Logical schema](docs/logical-schema.md) |
| Visual schema | [Mermaid diagram](schema/database-erd.md) |
| Editable source | [DBML](schema/schema.dbml) |
| Columns, types, keys and constraints | [Data dictionary](docs/data-dictionary.md) |
| Normalization | [1NF, 2NF and 3NF](docs/normalization.md) |
| Indexes and database rules | [Database optimizations](docs/database-optimizations.md) |
| Access roles and isolation | [Database security](docs/database-security.md) |
| DDL entry point | [Install SQL](ddl/install.sql) |
| Role definitions | [Bootstrap](security/bootstrap-roles.sql) |
| Grants and policies | [Database roles](security/database-roles.sql) |
| Synthetic test data | [Demo seed](seeds/seed-demo.sql) |

## Installation and filling with demo data

An administrator provisions roles with `security/bootstrap-roles.sql` and creates a separate empty database owned by `v_scheduling_migration`, then applies `security/prepare-schema.sql` before schema installation. Provision passwords outside Git. Apply the schema and grants with migration credentials. The application uses `v_scheduling_runtime`, which is defined as `NOSUPERUSER`.

From this directory, using a migration connection string supplied externally:

```sh
psql "$MIGRATION_DSN" -v ON_ERROR_STOP=1 -f ddl/install.sql
psql "$MIGRATION_DSN" -v ON_ERROR_STOP=1 -f security/database-roles.sql
psql "$MIGRATION_DSN" -v ON_ERROR_STOP=1 -f security/reliability-grants.sql
psql "$MIGRATION_DSN" -v ON_ERROR_STOP=1 -c "SET vairas.demo = on" -f seeds/seed-demo.sql
```

Initial DDL is for an empty database. Run seeds only against an isolated demo database. Fixed vocabularies are defined by enums/CHECK constraints; synthetic business configuration is in the demo seed where applicable.

[Database overview](../README.md)

## Actual lesson interval

[G-01 schema amendment, upgrade and service rules](docs/actual-interval.md) separates Scheduling physical time from Learning Tracking credited minutes. Fresh installation includes migrations 002 and 003; existing databases must apply it separately. The provider and transactional Outbox are implemented in Backend; live broker delivery and external deployment remain unverified. See the [implementation extension](docs/implementation.md).

[Design review](docs/validation-g01.md) records the amendment scope and remaining implementation gates.

## Reliability implementation

[Migration 003 and current storage/security boundaries](docs/implementation.md) extend the retained D-044/G-01 baseline. Apply both security overlays after schema installation.
