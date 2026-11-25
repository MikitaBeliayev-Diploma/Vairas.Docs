# Implemented data dictionary — user-management

Observed synthetic PostgreSQL database: `vairas_user_management`. Exported from migrated local runtime on 2026-11-25. Schema-only evidence; no business rows are included.

Migrations in the owning service remain the schema evolution authority. Existing design dictionaries are preserved separately. Cross-service UUID references are not physical foreign keys unless listed below.

| Schema | Table | Column | PostgreSQL type | Nullable | Default | Maximum length |
|---|---|---|---|---|---|---|
| public | __EFMigrationsHistory | MigrationId | varchar | NO |  | 150 |
| public | __EFMigrationsHistory | ProductVersion | varchar | NO |  | 32 |
| public | administrator_profile | administrator_id | uuid | NO |  |  |
| public | administrator_profile | user_id | uuid | NO |  |  |
| public | administrator_profile | created_at | timestamptz | NO |  |  |
| public | outbox_message | event_id | uuid | NO |  |  |
| public | outbox_message | aggregate_id | uuid | NO |  |  |
| public | outbox_message | aggregate_version | int8 | NO |  |  |
| public | outbox_message | event_type | varchar | NO |  | 80 |
| public | outbox_message | body | jsonb | NO |  |  |
| public | outbox_message | correlation_id | varchar | NO |  | 128 |
| public | outbox_message | trace_parent | varchar | YES |  | 128 |
| public | outbox_message | occurred_at | timestamptz | NO |  |  |
| public | outbox_message | next_attempt_at | timestamptz | NO |  |  |
| public | outbox_message | published_at | timestamptz | YES |  |  |
| public | outbox_message | lease_id | uuid | YES |  |  |
| public | outbox_message | leased_until | timestamptz | YES |  |  |
| public | outbox_message | attempts | int4 | NO |  |  |
| public | outbox_message | last_error_code | varchar | YES |  | 80 |
| public | profile_operation | operation_id | uuid | NO |  |  |
| public | profile_operation | actor_user_id | uuid | YES |  |  |
| public | profile_operation | actor_service | varchar | YES |  | 120 |
| public | profile_operation | requesting_school_id | uuid | YES |  |  |
| public | profile_operation | authority_basis | varchar | NO |  | 250 |
| public | profile_operation | channel | um_channel | NO |  |  |
| public | profile_operation | command_name | varchar | NO |  | 80 |
| public | profile_operation | target_kind | varchar | NO |  | 80 |
| public | profile_operation | target_id | uuid | NO |  |  |
| public | profile_operation | expected_revision | int8 | YES |  |  |
| public | profile_operation | resulting_revision | int8 | YES |  |  |
| public | profile_operation | request_fingerprint | varchar | NO |  | 64 |
| public | profile_operation | outcome | um_operation_outcome | NO |  |  |
| public | profile_operation | outcome_code | varchar | NO |  | 80 |
| public | profile_operation | recorded_at | timestamptz | NO |  |  |
| public | profile_operation | reason | text | YES |  |  |
| public | profile_operation | confirmation_id | uuid | YES |  |  |
| public | profile_operation | confirmed_at | timestamptz | YES |  |  |
| public | student_profile | student_id | uuid | NO |  |  |
| public | student_profile | user_id | uuid | NO |  |  |
| public | student_profile | created_at | timestamptz | NO |  |  |
| public | teacher_profile | teacher_id | uuid | NO |  |  |
| public | teacher_profile | user_id | uuid | NO |  |  |
| public | teacher_profile | created_at | timestamptz | NO |  |  |
| public | user_profile | user_id | uuid | NO |  |  |
| public | user_profile | identity_id | uuid | NO |  |  |
| public | user_profile | first_name | varchar | NO |  | 100 |
| public | user_profile | last_name | varchar | NO |  | 100 |
| public | user_profile | email_address | varchar | YES |  | 254 |
| public | user_profile | phone_number | varchar | YES |  | 32 |
| public | user_profile | status | um_user_status | NO | 'Active'::um_user_status |  |
| public | user_profile | revision | int8 | NO | 1 |  |
| public | user_profile | created_at | timestamptz | NO |  |  |
| public | user_profile | updated_at | timestamptz | NO |  |  |

## Physical constraints

| Schema / table | Name | Definition |
|---|---|---|
| public.__EFMigrationsHistory | PK___EFMigrationsHistory | PRIMARY KEY ("MigrationId") |
| public.administrator_profile | administrator_profile_pkey | PRIMARY KEY (administrator_id) |
| public.administrator_profile | administrator_profile_user_id_fkey | FOREIGN KEY (user_id) REFERENCES user_profile(user_id) ON DELETE RESTRICT DEFERRABLE |
| public.administrator_profile | administrator_profile_user_id_key | UNIQUE (user_id) |
| public.outbox_message | outbox_lease | CHECK (((lease_id IS NULL) = (leased_until IS NULL))) |
| public.outbox_message | outbox_message_pkey | PRIMARY KEY (event_id) |
| public.outbox_message | outbox_version | CHECK (((aggregate_version > 0) AND (attempts >= 0))) |
| public.profile_operation | profile_operation_pkey | PRIMARY KEY (operation_id) |
| public.profile_operation | um_accountable_actor | CHECK (((actor_user_id IS NOT NULL) OR ((actor_service IS NOT NULL) AND (length(TRIM(BOTH FROM actor_service)) > 0)))) |
| public.profile_operation | um_confirmation_pair | CHECK (((confirmation_id IS NULL) = (confirmed_at IS NULL))) |
| public.profile_operation | um_expected_revision | CHECK (((expected_revision IS NULL) OR (expected_revision > 0))) |
| public.profile_operation | um_mcp_write_confirmation | CHECK (((channel <> 'MCP'::um_channel) OR (outcome <> 'Applied'::um_operation_outcome) OR (confirmation_id IS NOT NULL))) |
| public.profile_operation | um_operation_basis | CHECK (((length((request_fingerprint)::text) = 64) AND (length(TRIM(BOTH FROM authority_basis)) > 0) AND (length(TRIM(BOTH FROM command_name)) > 0) AND (length(TRIM(BOTH FROM target_kind)) > 0) AND (length(TRIM(BOTH FROM outcome_code)) > 0))) |
| public.profile_operation | um_result_revision | CHECK (((resulting_revision IS NULL) OR (resulting_revision > 0))) |
| public.student_profile | student_profile_pkey | PRIMARY KEY (student_id) |
| public.student_profile | student_profile_user_id_fkey | FOREIGN KEY (user_id) REFERENCES user_profile(user_id) ON DELETE RESTRICT DEFERRABLE |
| public.student_profile | student_profile_user_id_key | UNIQUE (user_id) |
| public.teacher_profile | teacher_profile_pkey | PRIMARY KEY (teacher_id) |
| public.teacher_profile | teacher_profile_user_id_fkey | FOREIGN KEY (user_id) REFERENCES user_profile(user_id) ON DELETE RESTRICT DEFERRABLE |
| public.teacher_profile | teacher_profile_user_id_key | UNIQUE (user_id) |
| public.user_profile | um_nonblank_email | CHECK (((email_address IS NULL) OR (length(TRIM(BOTH FROM email_address)) > 0))) |
| public.user_profile | um_nonblank_name | CHECK (((length(TRIM(BOTH FROM first_name)) > 0) AND (length(TRIM(BOTH FROM last_name)) > 0))) |
| public.user_profile | um_nonblank_phone | CHECK (((phone_number IS NULL) OR (length(TRIM(BOTH FROM phone_number)) > 0))) |
| public.user_profile | um_profile_revision_time | CHECK (((revision > 0) AND (updated_at >= created_at))) |
| public.user_profile | user_profile_identity_id_key | UNIQUE (identity_id) |
| public.user_profile | user_profile_pkey | PRIMARY KEY (user_id) |

## Indexes

| Schema / table | Index | Definition |
|---|---|---|
| public.__EFMigrationsHistory | PK___EFMigrationsHistory | CREATE UNIQUE INDEX "PK___EFMigrationsHistory" ON public."__EFMigrationsHistory" USING btree ("MigrationId") |
| public.administrator_profile | administrator_profile_pkey | CREATE UNIQUE INDEX administrator_profile_pkey ON public.administrator_profile USING btree (administrator_id) |
| public.administrator_profile | administrator_profile_user_id_key | CREATE UNIQUE INDEX administrator_profile_user_id_key ON public.administrator_profile USING btree (user_id) |
| public.outbox_message | IX_outbox_message_next_attempt_at_occurred_at | CREATE INDEX "IX_outbox_message_next_attempt_at_occurred_at" ON public.outbox_message USING btree (next_attempt_at, occurred_at) WHERE (published_at IS NULL) |
| public.outbox_message | outbox_message_pkey | CREATE UNIQUE INDEX outbox_message_pkey ON public.outbox_message USING btree (event_id) |
| public.profile_operation | profile_operation_pkey | CREATE UNIQUE INDEX profile_operation_pkey ON public.profile_operation USING btree (operation_id) |
| public.profile_operation | profile_operation_target_kind_target_id_recorded_at_idx | CREATE INDEX profile_operation_target_kind_target_id_recorded_at_idx ON public.profile_operation USING btree (target_kind, target_id, recorded_at) |
| public.student_profile | student_profile_pkey | CREATE UNIQUE INDEX student_profile_pkey ON public.student_profile USING btree (student_id) |
| public.student_profile | student_profile_user_id_key | CREATE UNIQUE INDEX student_profile_user_id_key ON public.student_profile USING btree (user_id) |
| public.teacher_profile | teacher_profile_pkey | CREATE UNIQUE INDEX teacher_profile_pkey ON public.teacher_profile USING btree (teacher_id) |
| public.teacher_profile | teacher_profile_user_id_key | CREATE UNIQUE INDEX teacher_profile_user_id_key ON public.teacher_profile USING btree (user_id) |
| public.user_profile | user_profile_identity_id_key | CREATE UNIQUE INDEX user_profile_identity_id_key ON public.user_profile USING btree (identity_id) |
| public.user_profile | user_profile_pkey | CREATE UNIQUE INDEX user_profile_pkey ON public.user_profile USING btree (user_id) |

## Row-Level Security

| Schema / table | Enabled | Forced |
|---|---|---|
| public.__EFMigrationsHistory | False | False |
| public.user_profile | False | False |
| public.student_profile | False | False |
| public.teacher_profile | False | False |
| public.administrator_profile | False | False |
| public.profile_operation | False | False |
| public.outbox_message | False | False |

Policy expressions and command/role restrictions are retained verbatim in `../schema/implemented-catalogue.json` and `../schema/implemented-schema.sql`. Schema DDL also contains functions and triggers enforcing integrity and audit invariants.
