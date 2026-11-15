# Database Schemas and Data

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
