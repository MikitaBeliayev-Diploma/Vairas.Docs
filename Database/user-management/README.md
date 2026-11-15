# User Management Database

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

An administrator provisions roles with `security/bootstrap-roles.sql` and creates a separate empty database owned by `v_user_management_migration`. Provision passwords outside Git. Apply the schema and grants with migration credentials. The application uses `v_user_management_runtime`, which is defined as `NOSUPERUSER`.

From this directory, using a migration connection string supplied externally:

```sh
psql "$MIGRATION_DSN" -v ON_ERROR_STOP=1 -f ddl/install.sql
psql "$MIGRATION_DSN" -v ON_ERROR_STOP=1 -f security/database-roles.sql
psql "$MIGRATION_DSN" -v ON_ERROR_STOP=1 -c "SET vairas.demo = on" -f seeds/seed-demo.sql
```

Initial DDL is for an empty database. Run seeds only against an isolated demo database. Fixed vocabularies are defined by enums/CHECK constraints; synthetic business configuration is in the demo seed where applicable.

[Database overview](../README.md)
