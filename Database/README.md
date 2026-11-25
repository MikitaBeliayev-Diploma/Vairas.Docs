# Database Schemas and Data

## Observed implementation catalogue

The 2026-11-25 local migrated PostgreSQL exports are stored per context as `schema/implemented-schema.sql`, `schema/implemented-catalogue.json` and `docs/implemented-data-dictionary.md`. They include actual columns, constraints, indexes, functions/triggers and RLS policy definitions, with no business rows. Reproduce from Backend using `py -3 local/tools/export_schema_evidence.py --container <synthetic-postgres-container>`. Migrations remain authoritative. Adopted design schemas below are preserved and may differ from implemented storage.

Chat Backend has a ninth database: [implemented dictionary](chat-backend/docs/implemented-data-dictionary.md). Gateway and MCP Server are stateless and have no invented database. Authentication and User Management catalogue exports contain no RLS policies; their global identity/profile data is protected by role grants and server authorization. Tenant-owned business databases have the observed per-table policies recorded in their catalogues.

Expert: Aleksei Khariukov, aleksei.khariukov@esdc.lt. The expert will send the table of available review slots.

Each service directory contains its schema, data dictionary, normalization explanation, DDL, access-role definitions and synthetic demo seed.

| Database | Files |
|---|---|
| Authentication | [Open](authentication/README.md) |
| Document Management | [Open](document-management/README.md) |
| Learning Tracking | [Open](learning-tracking/README.md) |
| Notifications | [Open](notifications/README.md) |
| Scheduling | [Open](scheduling/README.md) |
| School Management | [Open](school-management/README.md) |
| User Management | [Open](user-management/README.md) |
| Vehicle Management | [Open](vehicle-management/README.md) |

Diagrams are editable Mermaid in Markdown and DBML source. SQL scripts define tables, constraints, functions, grants and seed records. Migration and runtime roles are distinct; the application must use its non-superuser runtime role.

Fixed status/type vocabularies are created through enum/CHECK definitions. Context-specific synthetic configuration is included in demo seeds; there is no separate global reference-table seed.

## Expert review requirements

| Requirement | Material in each service directory |
|---|---|
| Data dictionary and logical database schema | `docs/data-dictionary.md`, `docs/logical-schema.md`, `schema/schema.dbml`, `schema/database-erd.md` |
| DDL or migrations in Git | `ddl/install.sql` and the SQL files it includes |
| Normalization through 3NF, keys and constraints | `docs/normalization.md`, the schema and DDL; documented exceptions must be justified |
| Access roles; application does not use a superuser | `security/bootstrap-roles.sql`, `security/database-roles.sql`, `docs/database-security.md` |
| Test data and reference-data population | `seeds/seed-demo.sql`; fixed vocabularies are defined in DDL |
| Higher-grade features: indexes, views, triggers or procedures, personal-data masking | `docs/database-optimizations.md`, DDL and security documentation; availability differs by service |

DDL, migrations, role/bootstrap SQL and seed scripts are submission materials and remain here. Executable test suites, validation utilities and their dependencies are maintained outside the documentation repository. A documented schema or role definition is not proof that a live application uses it; the expert demonstration must show the installed schema and restricted runtime identity. Synthetic data avoids real personal data in examples; it is not production masking.
