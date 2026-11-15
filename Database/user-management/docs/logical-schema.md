# User Management — Logical relational schema

Authority: D-043 / D-045 global profiles. [Canonical DBML](../schema/schema.dbml).

The [Mermaid diagram](../schema/database-erd.md) shows keys/FKs and representative attributes; full attributes/defaults/classification are in data-dictionary.md. 

Physical count: 5 domain tables, 37 columns, 3 local FK declarations. EF migration history, where present, is technical metadata, not a new aggregate.

## Relationships and optionality

| Parent key | Child FK | Required? | Cardinality / integrity |
|---|---|---|---|
| user_profile(user_id) | student_profile(user_id) | Yes | 0..1 child per parent; restrict |
| user_profile(user_id) | teacher_profile(user_id) | Yes | 0..1 child per parent; restrict |
| user_profile(user_id) | administrator_profile(user_id) | Yes | 0..1 child per parent; restrict |

## Deployment/transaction source

[Install wrapper](../ddl/install.sql) is the only fresh-install entry. It references existing canonical SQL or the generated initial migration, not another service’s same-named schema.sql. [Security overlay](../security/database-roles.sql) follows schema creation; demo seeds run only under explicit test gates.

No previous production migration history was found/assumed. Reapplying raw initial DDL over a populated database is forbidden. Scheduling has a real EF migration/snapshot and no-op migration rerun check; other contexts use a fresh SQL baseline and require a separately reviewed differential upgrade if legacy data exists.

Current remote owner/API gaps do not by themselves invalidate relational design. They remain runtime/integration gates and cannot be proven by FK tests.

## Executable database rules beyond DBML

- administrator_profile.administrator_profile_pkey: `PRIMARY KEY (administrator_id)`.
- administrator_profile.administrator_profile_user_id_fkey: `FOREIGN KEY (user_id) REFERENCES user_profile(user_id) ON DELETE RESTRICT DEFERRABLE`.
- administrator_profile.administrator_profile_user_id_key: `UNIQUE (user_id)`.
- profile_operation.profile_operation_pkey: `PRIMARY KEY (operation_id)`.
- profile_operation.um_accountable_actor: `CHECK (((actor_user_id IS NOT NULL) OR ((actor_service IS NOT NULL) AND (length(TRIM(BOTH FROM actor_service)) > 0))))`.
- profile_operation.um_confirmation_pair: `CHECK (((confirmation_id IS NULL) = (confirmed_at IS NULL)))`.
- profile_operation.um_expected_revision: `CHECK (((expected_revision IS NULL) OR (expected_revision > 0)))`.
- profile_operation.um_mcp_write_confirmation: `CHECK (((channel <> 'MCP'::um_channel) OR (outcome <> 'Applied'::um_operation_outcome) OR (confirmation_id IS NOT NULL)))`.
- profile_operation.um_operation_basis: `CHECK (((length((request_fingerprint)::text) = 64) AND (length(TRIM(BOTH FROM authority_basis)) > 0) AND (length(TRIM(BOTH FROM command_name)) > 0) AND (length(TRIM(BOTH FROM target_kind)) > 0) AND (length(TRIM(BOTH FROM outcome_code)) > 0)))`.
- profile_operation.um_result_revision: `CHECK (((resulting_revision IS NULL) OR (resulting_revision > 0)))`.
- student_profile.student_profile_pkey: `PRIMARY KEY (student_id)`.
- student_profile.student_profile_user_id_fkey: `FOREIGN KEY (user_id) REFERENCES user_profile(user_id) ON DELETE RESTRICT DEFERRABLE`.
- student_profile.student_profile_user_id_key: `UNIQUE (user_id)`.
- teacher_profile.teacher_profile_pkey: `PRIMARY KEY (teacher_id)`.
- teacher_profile.teacher_profile_user_id_fkey: `FOREIGN KEY (user_id) REFERENCES user_profile(user_id) ON DELETE RESTRICT DEFERRABLE`.
- teacher_profile.teacher_profile_user_id_key: `UNIQUE (user_id)`.
- user_profile.um_nonblank_email: `CHECK (((email_address IS NULL) OR (length(TRIM(BOTH FROM email_address)) > 0)))`.
- user_profile.um_nonblank_name: `CHECK (((length(TRIM(BOTH FROM first_name)) > 0) AND (length(TRIM(BOTH FROM last_name)) > 0)))`.
- user_profile.um_nonblank_phone: `CHECK (((phone_number IS NULL) OR (length(TRIM(BOTH FROM phone_number)) > 0)))`.
- user_profile.um_profile_revision_time: `CHECK (((revision > 0) AND (updated_at >= created_at)))`.
- user_profile.user_profile_identity_id_key: `UNIQUE (identity_id)`.
- user_profile.user_profile_pkey: `PRIMARY KEY (user_id)`.
