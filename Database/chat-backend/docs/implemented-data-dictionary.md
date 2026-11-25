# Implemented data dictionary — chat-backend

Observed synthetic PostgreSQL database: `vairas_chat`. Exported from migrated local runtime on 2026-11-25. Schema-only evidence; no business rows are included.

Migrations in the owning service remain the schema evolution authority. Existing design dictionaries are preserved separately. Cross-service UUID references are not physical foreign keys unless listed below.

| Schema | Table | Column | PostgreSQL type | Nullable | Default | Maximum length |
|---|---|---|---|---|---|---|
| public | __EFMigrationsHistory | MigrationId | varchar | NO |  | 150 |
| public | __EFMigrationsHistory | ProductVersion | varchar | NO |  | 32 |
| public | action_confirmation | school_id | uuid | NO |  |  |
| public | action_confirmation | conversation_id | uuid | NO |  |  |
| public | action_confirmation | invocation_id | uuid | NO |  |  |
| public | action_confirmation | confirmed_by_user_id | uuid | NO |  |  |
| public | action_confirmation | confirmed_digest | bpchar | NO |  | 64 |
| public | action_confirmation | confirmed_at | timestamptz | NO |  |  |
| public | ai_model_deployment | id | uuid | NO |  |  |
| public | ai_model_deployment | provider | varchar | NO |  | 80 |
| public | ai_model_deployment | model_name | varchar | NO |  | 160 |
| public | ai_model_deployment | model_version | varchar | YES |  | 100 |
| public | ai_model_deployment | deployment_name | varchar | NO |  | 160 |
| public | ai_model_deployment | region | varchar | NO |  | 80 |
| public | ai_model_deployment | endpoint_config_key | varchar | NO |  | 200 |
| public | ai_model_deployment | credential_secret_ref | varchar | NO |  | 240 |
| public | ai_model_deployment | configuration_version | int4 | NO |  |  |
| public | ai_model_deployment | enabled | bool | NO | false |  |
| public | ai_model_deployment | created_at | timestamptz | NO |  |  |
| public | assistant_run | school_id | uuid | NO |  |  |
| public | assistant_run | conversation_id | uuid | NO |  |  |
| public | assistant_run | id | uuid | NO |  |  |
| public | assistant_run | trigger_message_id | uuid | NO |  |  |
| public | assistant_run | response_message_id | uuid | YES |  |  |
| public | assistant_run | attempt_no | int4 | NO |  |  |
| public | assistant_run | model_deployment_id | uuid | NO |  |  |
| public | assistant_run | prompt_version | varchar | NO |  | 100 |
| public | assistant_run | status | run_status | NO |  |  |
| public | assistant_run | revision | int8 | NO | 1 |  |
| public | assistant_run | input_tokens | int8 | YES |  |  |
| public | assistant_run | output_tokens | int8 | YES |  |  |
| public | assistant_run | error_code | varchar | YES |  | 80 |
| public | assistant_run | created_at | timestamptz | NO |  |  |
| public | assistant_run | started_at | timestamptz | YES |  |  |
| public | assistant_run | finished_at | timestamptz | YES |  |  |
| public | assistant_run | execution_profile | varchar | NO |  | 32 |
| public | assistant_run | deadline_at | timestamptz | NO |  |  |
| public | chat_message | school_id | uuid | NO |  |  |
| public | chat_message | conversation_id | uuid | NO |  |  |
| public | chat_message | id | uuid | NO |  |  |
| public | chat_message | sequence_no | int8 | NO |  |  |
| public | chat_message | role | message_role | NO |  |  |
| public | chat_message | content | text | NO |  |  |
| public | chat_message | client_request_id | uuid | YES |  |  |
| public | chat_message | created_at | timestamptz | NO |  |  |
| public | conversation | school_id | uuid | NO |  |  |
| public | conversation | id | uuid | NO |  |  |
| public | conversation | owner_user_id | uuid | NO |  |  |
| public | conversation | title | varchar | YES |  | 200 |
| public | conversation | status | conversation_status | NO |  |  |
| public | conversation | revision | int8 | NO | 1 |  |
| public | conversation | created_at | timestamptz | NO |  |  |
| public | conversation | archived_at | timestamptz | YES |  |  |
| public | conversation | creation_request_id | uuid | NO |  |  |
| public | conversation | access_stamp | varchar | NO |  | 64 |
| public | conversation | archive_expected_revision | int8 | YES |  |  |
| public | conversation | archive_request_id | uuid | YES |  |  |
| public | conversation | execution_profile | varchar | NO | 'PreviewOnlyV1'::character varying | 32 |
| public | tool_invocation | school_id | uuid | NO |  |  |
| public | tool_invocation | conversation_id | uuid | NO |  |  |
| public | tool_invocation | id | uuid | NO |  |  |
| public | tool_invocation | run_id | uuid | NO |  |  |
| public | tool_invocation | sequence_no | int4 | NO |  |  |
| public | tool_invocation | tool_name | varchar | NO |  | 120 |
| public | tool_invocation | tool_contract_version | varchar | NO |  | 80 |
| public | tool_invocation | effect | tool_effect | NO |  |  |
| public | tool_invocation | target_context | varchar | NO |  | 80 |
| public | tool_invocation | canonical_arguments | jsonb | NO |  |  |
| public | tool_invocation | preview | jsonb | YES |  |  |
| public | tool_invocation | expected_source_revisions | jsonb | YES |  |  |
| public | tool_invocation | action_digest | bpchar | YES |  | 64 |
| public | tool_invocation | expires_at | timestamptz | YES |  |  |
| public | tool_invocation | operation_id | uuid | NO |  |  |
| public | tool_invocation | status | invocation_status | NO |  |  |
| public | tool_invocation | revision | int8 | NO | 1 |  |
| public | tool_invocation | result_reference | varchar | YES |  | 240 |
| public | tool_invocation | result_summary | jsonb | YES |  |  |
| public | tool_invocation | error_code | varchar | YES |  | 80 |
| public | tool_invocation | created_at | timestamptz | NO |  |  |
| public | tool_invocation | started_at | timestamptz | YES |  |  |
| public | tool_invocation | finished_at | timestamptz | YES |  |  |
| public | tool_invocation | recovery_after | timestamptz | YES |  |  |

## Physical constraints

| Schema / table | Name | Definition |
|---|---|---|
| public.__EFMigrationsHistory | PK___EFMigrationsHistory | PRIMARY KEY ("MigrationId") |
| public.action_confirmation | action_confirmation_pkey | PRIMARY KEY (school_id, conversation_id, invocation_id) |
| public.action_confirmation | action_confirmation_school_id_conversation_id_invocation_i_fkey | FOREIGN KEY (school_id, conversation_id, invocation_id) REFERENCES tool_invocation(school_id, conversation_id, id) DEFERRABLE |
| public.action_confirmation | ai_confirmation_atomic | TRIGGER DEFERRABLE INITIALLY DEFERRED |
| public.action_confirmation | confirmation_digest_shape | CHECK ((confirmed_digest ~ '^[0-9a-f]{64}$'::text)) |
| public.action_confirmation | confirmation_finite_time | CHECK (isfinite(confirmed_at)) |
| public.ai_model_deployment | ai_model_deployment_pkey | PRIMARY KEY (id) |
| public.ai_model_deployment | deployment_finite_time | CHECK (isfinite(created_at)) |
| public.ai_model_deployment | deployment_version_positive | CHECK ((configuration_version > 0)) |
| public.assistant_run | assistant_run_check | CHECK ((isfinite(deadline_at) AND (deadline_at > created_at))) |
| public.assistant_run | assistant_run_execution_profile_check | CHECK (((execution_profile)::text = ANY ((ARRAY['PreviewOnlyV1'::character varying, 'ConfirmedLessonActionsV1'::character varying])::text[]))) |
| public.assistant_run | assistant_run_model_deployment_id_fkey | FOREIGN KEY (model_deployment_id) REFERENCES ai_model_deployment(id) DEFERRABLE |
| public.assistant_run | assistant_run_pkey | PRIMARY KEY (school_id, conversation_id, id) |
| public.assistant_run | assistant_run_school_id_conversation_id_fkey | FOREIGN KEY (school_id, conversation_id) REFERENCES conversation(school_id, id) DEFERRABLE |
| public.assistant_run | assistant_run_school_id_conversation_id_response_message_i_fkey | FOREIGN KEY (school_id, conversation_id, response_message_id) REFERENCES chat_message(school_id, conversation_id, id) DEFERRABLE |
| public.assistant_run | assistant_run_school_id_conversation_id_trigger_message_id_fkey | FOREIGN KEY (school_id, conversation_id, trigger_message_id) REFERENCES chat_message(school_id, conversation_id, id) DEFERRABLE |
| public.assistant_run | run_counters_positive | CHECK (((attempt_no > 0) AND (revision > 0))) |
| public.assistant_run | run_finished_shape | CHECK (((status = ANY (ARRAY['Completed'::run_status, 'Failed'::run_status, 'Cancelled'::run_status])) = (finished_at IS NOT NULL))) |
| public.assistant_run | run_finite_time | CHECK ((isfinite(created_at) AND ((started_at IS NULL) OR isfinite(started_at)) AND ((finished_at IS NULL) OR isfinite(finished_at)))) |
| public.assistant_run | run_response_shape | CHECK (((status = 'Completed'::run_status) = (response_message_id IS NOT NULL))) |
| public.assistant_run | run_time_order | CHECK ((((started_at IS NULL) OR (started_at >= created_at)) AND ((finished_at IS NULL) OR (finished_at >= COALESCE(started_at, created_at))))) |
| public.assistant_run | run_usage_nonnegative | CHECK ((((input_tokens IS NULL) OR (input_tokens >= 0)) AND ((output_tokens IS NULL) OR (output_tokens >= 0)))) |
| public.chat_message | chat_message_pkey | PRIMARY KEY (school_id, conversation_id, id) |
| public.chat_message | chat_message_school_id_conversation_id_fkey | FOREIGN KEY (school_id, conversation_id) REFERENCES conversation(school_id, id) DEFERRABLE |
| public.chat_message | message_finite_time | CHECK (isfinite(created_at)) |
| public.chat_message | message_request_role | CHECK (((role = 'User'::message_role) = (client_request_id IS NOT NULL))) |
| public.chat_message | message_sequence_positive | CHECK ((sequence_no > 0)) |
| public.conversation | conversation_access_stamp_check | CHECK (((access_stamp)::text ~ '^[0-9a-f]{64}$'::text)) |
| public.conversation | conversation_archive_request_ck | CHECK ((((archive_request_id IS NULL) AND (archive_expected_revision IS NULL)) OR ((archive_request_id IS NOT NULL) AND (archive_expected_revision IS NOT NULL) AND (archive_expected_revision > 0) AND (status = 'Archived'::conversation_status)))) |
| public.conversation | conversation_archive_shape | CHECK (((status = 'Archived'::conversation_status) = (archived_at IS NOT NULL))) |
| public.conversation | conversation_execution_profile_check | CHECK (((execution_profile)::text = ANY ((ARRAY['PreviewOnlyV1'::character varying, 'ConfirmedLessonActionsV1'::character varying])::text[]))) |
| public.conversation | conversation_finite_time | CHECK ((isfinite(created_at) AND ((archived_at IS NULL) OR isfinite(archived_at)))) |
| public.conversation | conversation_pkey | PRIMARY KEY (school_id, id) |
| public.conversation | conversation_revision_positive | CHECK ((revision > 0)) |
| public.conversation | conversation_time_order | CHECK (((archived_at IS NULL) OR (archived_at >= created_at))) |
| public.tool_invocation | invocation_counters_positive | CHECK (((sequence_no > 0) AND (revision > 0))) |
| public.tool_invocation | invocation_effect_shape | CHECK ((((effect = 'Write'::tool_effect) AND (preview IS NOT NULL) AND (expected_source_revisions IS NOT NULL) AND (action_digest IS NOT NULL) AND (action_digest ~ '^[0-9a-f]{64}$'::text) AND (expires_at IS NOT NULL) AND (expires_at > created_at)) OR ((effect = 'Read'::tool_effect) AND (preview IS NULL) AND (action_digest IS NULL) AND (expires_at IS NULL)))) |
| public.tool_invocation | invocation_effect_status | CHECK ((((effect = 'Read'::tool_effect) AND (status <> ALL (ARRAY['AwaitingConfirmation'::invocation_status, 'Confirmed'::invocation_status, 'Expired'::invocation_status]))) OR ((effect = 'Write'::tool_effect) AND (status <> 'Prepared'::invocation_status)))) |
| public.tool_invocation | invocation_finished_shape | CHECK (((status = ANY (ARRAY['Succeeded'::invocation_status, 'Rejected'::invocation_status, 'Failed'::invocation_status, 'Expired'::invocation_status, 'Cancelled'::invocation_status])) = (finished_at IS NOT NULL))) |
| public.tool_invocation | invocation_finite_time | CHECK ((isfinite(created_at) AND ((started_at IS NULL) OR isfinite(started_at)) AND ((finished_at IS NULL) OR isfinite(finished_at)) AND ((expires_at IS NULL) OR isfinite(expires_at)))) |
| public.tool_invocation | invocation_time_order | CHECK ((((started_at IS NULL) OR (started_at >= created_at)) AND ((finished_at IS NULL) OR (finished_at >= COALESCE(started_at, created_at))))) |
| public.tool_invocation | tool_invocation_pkey | PRIMARY KEY (school_id, conversation_id, id) |
| public.tool_invocation | tool_invocation_school_id_conversation_id_run_id_fkey | FOREIGN KEY (school_id, conversation_id, run_id) REFERENCES assistant_run(school_id, conversation_id, id) DEFERRABLE |

## Indexes

| Schema / table | Index | Definition |
|---|---|---|
| public.__EFMigrationsHistory | PK___EFMigrationsHistory | CREATE UNIQUE INDEX "PK___EFMigrationsHistory" ON public."__EFMigrationsHistory" USING btree ("MigrationId") |
| public.action_confirmation | action_confirmation_pkey | CREATE UNIQUE INDEX action_confirmation_pkey ON public.action_confirmation USING btree (school_id, conversation_id, invocation_id) |
| public.ai_model_deployment | ai_model_deployment_pkey | CREATE UNIQUE INDEX ai_model_deployment_pkey ON public.ai_model_deployment USING btree (id) |
| public.assistant_run | assistant_run_pkey | CREATE UNIQUE INDEX assistant_run_pkey ON public.assistant_run USING btree (school_id, conversation_id, id) |
| public.assistant_run | assistant_run_school_id_conversation_id_response_message_id_idx | CREATE UNIQUE INDEX assistant_run_school_id_conversation_id_response_message_id_idx ON public.assistant_run USING btree (school_id, conversation_id, response_message_id) |
| public.assistant_run | assistant_run_school_id_conversation_id_trigger_message_id__idx | CREATE UNIQUE INDEX assistant_run_school_id_conversation_id_trigger_message_id__idx ON public.assistant_run USING btree (school_id, conversation_id, trigger_message_id, attempt_no) |
| public.assistant_run | one_active_run | CREATE UNIQUE INDEX one_active_run ON public.assistant_run USING btree (school_id, conversation_id) WHERE (status = ANY (ARRAY['Queued'::run_status, 'Running'::run_status, 'AwaitingConfirmation'::run_status])) |
| public.chat_message | chat_message_pkey | CREATE UNIQUE INDEX chat_message_pkey ON public.chat_message USING btree (school_id, conversation_id, id) |
| public.chat_message | chat_message_school_id_conversation_id_client_request_id_idx | CREATE UNIQUE INDEX chat_message_school_id_conversation_id_client_request_id_idx ON public.chat_message USING btree (school_id, conversation_id, client_request_id) |
| public.chat_message | chat_message_school_id_conversation_id_sequence_no_idx | CREATE UNIQUE INDEX chat_message_school_id_conversation_id_sequence_no_idx ON public.chat_message USING btree (school_id, conversation_id, sequence_no) |
| public.conversation | IX_conversation_owner_user_id_archive_request_id | CREATE UNIQUE INDEX "IX_conversation_owner_user_id_archive_request_id" ON public.conversation USING btree (owner_user_id, archive_request_id) |
| public.conversation | conversation_creation_key | CREATE UNIQUE INDEX conversation_creation_key ON public.conversation USING btree (owner_user_id, creation_request_id) |
| public.conversation | conversation_pkey | CREATE UNIQUE INDEX conversation_pkey ON public.conversation USING btree (school_id, id) |
| public.conversation | conversation_school_id_owner_user_id_created_at_idx | CREATE INDEX conversation_school_id_owner_user_id_created_at_idx ON public.conversation USING btree (school_id, owner_user_id, created_at) |
| public.tool_invocation | invocation_public_id | CREATE UNIQUE INDEX invocation_public_id ON public.tool_invocation USING btree (school_id, id) |
| public.tool_invocation | one_active_preview | CREATE UNIQUE INDEX one_active_preview ON public.tool_invocation USING btree (school_id, conversation_id) WHERE ((effect = 'Write'::tool_effect) AND (status = ANY (ARRAY['AwaitingConfirmation'::invocation_status, 'Confirmed'::invocation_status]))) |
| public.tool_invocation | pending_lesson_recovery | CREATE INDEX pending_lesson_recovery ON public.tool_invocation USING btree (recovery_after, started_at) WHERE ((effect = 'Write'::tool_effect) AND (status = ANY (ARRAY['Executing'::invocation_status, 'Unknown'::invocation_status]))) |
| public.tool_invocation | tool_invocation_pkey | CREATE UNIQUE INDEX tool_invocation_pkey ON public.tool_invocation USING btree (school_id, conversation_id, id) |
| public.tool_invocation | tool_invocation_school_id_conversation_id_run_id_sequence_n_idx | CREATE UNIQUE INDEX tool_invocation_school_id_conversation_id_run_id_sequence_n_idx ON public.tool_invocation USING btree (school_id, conversation_id, run_id, sequence_no) |
| public.tool_invocation | tool_invocation_school_id_operation_id_idx | CREATE UNIQUE INDEX tool_invocation_school_id_operation_id_idx ON public.tool_invocation USING btree (school_id, operation_id) |
| public.tool_invocation | tool_invocation_status_created_at_idx | CREATE INDEX tool_invocation_status_created_at_idx ON public.tool_invocation USING btree (status, created_at) |

## Row-Level Security

| Schema / table | Enabled | Forced |
|---|---|---|
| public.ai_model_deployment | False | False |
| public.__EFMigrationsHistory | False | False |
| public.conversation | True | False |
| public.chat_message | True | False |
| public.assistant_run | True | False |
| public.tool_invocation | True | False |
| public.action_confirmation | True | False |

Policy expressions and command/role restrictions are retained verbatim in `../schema/implemented-catalogue.json` and `../schema/implemented-schema.sql`. Schema DDL also contains functions and triggers enforcing integrity and audit invariants.
