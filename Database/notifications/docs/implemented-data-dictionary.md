# Implemented data dictionary — notifications

Observed synthetic PostgreSQL database: `vairas_notifications`. Exported from migrated local runtime on 2026-11-25. Schema-only evidence; no business rows are included.

Migrations in the owning service remain the schema evolution authority. Existing design dictionaries are preserved separately. Cross-service UUID references are not physical foreign keys unless listed below.

| Schema | Table | Column | PostgreSQL type | Nullable | Default | Maximum length |
|---|---|---|---|---|---|---|
| notifications | notification | school_id | uuid | NO |  |  |
| notifications | notification | notification_id | uuid | NO |  |  |
| notifications | notification | recipient_user_id | uuid | NO |  |  |
| notifications | notification | template_id | uuid | YES |  |  |
| notifications | notification | template_revision | int8 | YES |  |  |
| notifications | notification | notification_type | varchar | NO |  | 40 |
| notifications | notification | channel | varchar | NO | 'Email'::character varying | 12 |
| notifications | notification | subject | varchar | NO |  | 500 |
| notifications | notification | body | text | NO |  |  |
| notifications | notification | destination_address | varchar | NO |  | 254 |
| notifications | notification | contact_revision | varchar | NO |  | 100 |
| notifications | notification | source_context | varchar | NO |  | 40 |
| notifications | notification | source_id | uuid | NO |  |  |
| notifications | notification | source_revision | int8 | NO |  |  |
| notifications | notification | source_event_id | uuid | NO |  |  |
| notifications | notification | dispatch_key | varchar | NO |  | 200 |
| notifications | notification | scheduled_at | timestamptz | NO |  |  |
| notifications | notification | status | varchar | NO | 'Pending'::character varying | 20 |
| notifications | notification | revision | int8 | NO | 1 |  |
| notifications | notification | attempt_count | int4 | NO | 0 |  |
| notifications | notification | next_attempt_at | timestamptz | YES |  |  |
| notifications | notification | sent_at | timestamptz | YES |  |  |
| notifications | notification | cancelled_at | timestamptz | YES |  |  |
| notifications | notification | failure_code | varchar | YES |  | 80 |
| notifications | notification | created_at | timestamptz | NO |  |  |
| notifications | notification | updated_at | timestamptz | NO |  |  |
| notifications | notification | correlation_id | varchar | NO | 'legacy'::character varying | 128 |
| notifications | notification | content_purged_at | timestamptz | YES |  |  |
| notifications | notification_delivery_attempt | school_id | uuid | NO |  |  |
| notifications | notification_delivery_attempt | attempt_id | uuid | NO |  |  |
| notifications | notification_delivery_attempt | notification_id | uuid | NO |  |  |
| notifications | notification_delivery_attempt | attempt_no | int4 | NO |  |  |
| notifications | notification_delivery_attempt | provider_key | varchar | NO |  | 200 |
| notifications | notification_delivery_attempt | provider_message_id | varchar | YES |  | 200 |
| notifications | notification_delivery_attempt | status | varchar | NO | 'Started'::character varying | 12 |
| notifications | notification_delivery_attempt | started_at | timestamptz | NO |  |  |
| notifications | notification_delivery_attempt | finished_at | timestamptz | YES |  |  |
| notifications | notification_delivery_attempt | error_code | varchar | YES |  | 80 |
| notifications | notification_inbox | school_id | uuid | NO |  |  |
| notifications | notification_inbox | producer | varchar | NO |  | 40 |
| notifications | notification_inbox | event_id | uuid | NO |  |  |
| notifications | notification_inbox | payload_hash | varchar | NO |  | 64 |
| notifications | notification_inbox | source_id | uuid | NO |  |  |
| notifications | notification_inbox | source_revision | int8 | NO |  |  |
| notifications | notification_inbox | outcome | varchar | NO |  | 12 |
| notifications | notification_inbox | outcome_code | varchar | NO |  | 80 |
| notifications | notification_inbox | received_at | timestamptz | NO |  |  |
| notifications | notification_inbox | processed_at | timestamptz | NO |  |  |
| notifications | notification_operation | school_id | uuid | NO |  |  |
| notifications | notification_operation | operation_id | uuid | NO |  |  |
| notifications | notification_operation | actor_user_id | uuid | NO |  |  |
| notifications | notification_operation | channel | varchar | NO |  | 12 |
| notifications | notification_operation | command_name | varchar | NO |  | 80 |
| notifications | notification_operation | target_id | uuid | NO |  |  |
| notifications | notification_operation | request_hash | varchar | NO |  | 64 |
| notifications | notification_operation | authority_basis | text | NO |  |  |
| notifications | notification_operation | confirmation_id | uuid | YES |  |  |
| notifications | notification_operation | confirmed_at | timestamptz | YES |  |  |
| notifications | notification_operation | outcome | varchar | NO |  | 12 |
| notifications | notification_operation | outcome_code | varchar | NO |  | 80 |
| notifications | notification_operation | resulting_revision | int8 | YES |  |  |
| notifications | notification_operation | recorded_at | timestamptz | NO |  |  |
| notifications | notification_operation | response_json | jsonb | YES |  |  |
| notifications | notification_retention_run | run_id | uuid | NO |  |  |
| notifications | notification_retention_run | cutoff | timestamptz | NO |  |  |
| notifications | notification_retention_run | affected | int4 | NO |  |  |
| notifications | notification_retention_run | executed_at | timestamptz | NO |  |  |
| notifications | notification_retention_run | executed_by | text | NO |  |  |
| notifications | notification_retention_run | reason | varchar | NO |  | 500 |
| notifications | notification_template | school_id | uuid | NO |  |  |
| notifications | notification_template | template_id | uuid | NO |  |  |
| notifications | notification_template | notification_type | varchar | NO |  | 40 |
| notifications | notification_template | subject_template | varchar | NO |  | 500 |
| notifications | notification_template | body_template | text | NO |  |  |
| notifications | notification_template | status | varchar | NO | 'Active'::character varying | 12 |
| notifications | notification_template | revision | int8 | NO | 1 |  |
| notifications | notification_template | created_at | timestamptz | NO |  |  |
| notifications | notification_template | updated_at | timestamptz | NO |  |  |
| notifications | notification_work | school_id | uuid | NO |  |  |
| notifications | notification_work | notification_id | uuid | NO |  |  |
| notifications | notification_work | status | varchar | NO |  | 20 |
| notifications | notification_work | available_at | timestamptz | NO |  |  |
| notifications | notification_work | created_at | timestamptz | NO |  |  |
| notifications | schema_history | version | text | NO |  |  |
| notifications | schema_history | checksum | text | NO |  |  |
| notifications | schema_history | applied_at | timestamptz | NO | now() |  |

## Physical constraints

| Schema / table | Name | Definition |
|---|---|---|
| notifications.notification | n_attempt_required | CHECK ((((status)::text <> ALL ((ARRAY['Sending'::character varying, 'Sent'::character varying, 'DeliveryUnknown'::character varying])::text[])) OR (attempt_count > 0))) |
| notifications.notification | n_cancel_pair | CHECK ((((status)::text = 'Cancelled'::text) = (cancelled_at IS NOT NULL))) |
| notifications.notification | n_cancel_time | CHECK (((cancelled_at IS NULL) OR (cancelled_at >= created_at))) |
| notifications.notification | n_channel | CHECK (((channel)::text = 'Email'::text)) |
| notifications.notification | n_content | CHECK (((length(TRIM(BOTH FROM subject)) > 0) AND (length(TRIM(BOTH FROM body)) > 0) AND (length(TRIM(BOTH FROM destination_address)) > 0) AND (length(TRIM(BOTH FROM contact_revision)) > 0) AND (length(TRIM(BOTH FROM dispatch_key)) > 0))) |
| notifications.notification | n_retry_time | CHECK (((next_attempt_at IS NULL) OR (((status)::text = 'Pending'::text) AND (next_attempt_at >= created_at)))) |
| notifications.notification | n_revisions | CHECK (((revision > 0) AND (source_revision > 0) AND (attempt_count >= 0))) |
| notifications.notification | n_sent_pair | CHECK ((((status)::text = 'Sent'::text) = (sent_at IS NOT NULL))) |
| notifications.notification | n_sent_time | CHECK (((sent_at IS NULL) OR (sent_at >= created_at))) |
| notifications.notification | n_source | CHECK (((source_context)::text = ANY ((ARRAY['Scheduling'::character varying, 'LearningTracking'::character varying])::text[]))) |
| notifications.notification | n_status | CHECK (((status)::text = ANY ((ARRAY['Pending'::character varying, 'Sending'::character varying, 'Sent'::character varying, 'Failed'::character varying, 'Cancelled'::character varying, 'DeliveryUnknown'::character varying])::text[]))) |
| notifications.notification | n_template_pair | CHECK ((((template_id IS NULL) AND (template_revision IS NULL)) OR ((template_id IS NOT NULL) AND (template_revision IS NOT NULL) AND (template_revision > 0)))) |
| notifications.notification | n_time | CHECK (((updated_at >= created_at) AND (scheduled_at >= created_at))) |
| notifications.notification | n_type | CHECK (((notification_type)::text = ANY ((ARRAY['LessonScheduled'::character varying, 'LessonRescheduled'::character varying, 'LessonCancelled'::character varying, 'LessonReminder'::character varying, 'AssessmentPassed'::character varying, 'AssessmentFailed'::character varying])::text[]))) |
| notifications.notification | notification_pkey | PRIMARY KEY (school_id, notification_id) |
| notifications.notification | notification_school_id_template_id_fkey | FOREIGN KEY (school_id, template_id) REFERENCES notifications.notification_template(school_id, template_id) ON DELETE RESTRICT DEFERRABLE |
| notifications.notification_delivery_attempt | nda_finished | CHECK ((((status)::text = 'Started'::text) = (finished_at IS NULL))) |
| notifications.notification_delivery_attempt | nda_identity | CHECK (((attempt_no > 0) AND (length(TRIM(BOTH FROM provider_key)) > 0))) |
| notifications.notification_delivery_attempt | nda_status | CHECK (((status)::text = ANY ((ARRAY['Started'::character varying, 'Accepted'::character varying, 'Rejected'::character varying, 'Unknown'::character varying])::text[]))) |
| notifications.notification_delivery_attempt | nda_time | CHECK (((finished_at IS NULL) OR (finished_at >= started_at))) |
| notifications.notification_delivery_attempt | notification_delivery_attempt_pkey | PRIMARY KEY (school_id, attempt_id) |
| notifications.notification_delivery_attempt | notification_delivery_attempt_school_id_notification_id_fkey | FOREIGN KEY (school_id, notification_id) REFERENCES notifications.notification(school_id, notification_id) ON DELETE RESTRICT DEFERRABLE |
| notifications.notification_inbox | ni_hash | CHECK (((payload_hash)::text ~ '^[0-9a-f]{64}$'::text)) |
| notifications.notification_inbox | ni_outcome | CHECK ((((outcome)::text = ANY ((ARRAY['Applied'::character varying, 'Ignored'::character varying, 'Rejected'::character varying])::text[])) AND (length(TRIM(BOTH FROM outcome_code)) > 0))) |
| notifications.notification_inbox | ni_source | CHECK ((((producer)::text = ANY ((ARRAY['Scheduling'::character varying, 'LearningTracking'::character varying])::text[])) AND (source_revision > 0))) |
| notifications.notification_inbox | ni_time | CHECK ((processed_at >= received_at)) |
| notifications.notification_inbox | notification_inbox_pkey | PRIMARY KEY (school_id, producer, event_id) |
| notifications.notification_operation | no_basis | CHECK ((((request_hash)::text ~ '^[0-9a-f]{64}$'::text) AND (length(TRIM(BOTH FROM command_name)) > 0) AND (length(TRIM(BOTH FROM authority_basis)) > 0) AND (length(TRIM(BOTH FROM outcome_code)) > 0))) |
| notifications.notification_operation | no_confirmation_pair | CHECK (((confirmation_id IS NULL) = (confirmed_at IS NULL))) |
| notifications.notification_operation | no_mcp_confirmation | CHECK ((((channel)::text <> 'MCP'::text) OR ((outcome)::text <> 'Applied'::text) OR (confirmation_id IS NOT NULL))) |
| notifications.notification_operation | no_response | CHECK ((((outcome)::text <> 'Applied'::text) OR (response_json IS NOT NULL))) |
| notifications.notification_operation | no_revision | CHECK (((resulting_revision IS NULL) OR (resulting_revision > 0))) |
| notifications.notification_operation | no_values | CHECK ((((channel)::text = ANY ((ARRAY['Web'::character varying, 'MCP'::character varying])::text[])) AND ((outcome)::text = ANY ((ARRAY['Applied'::character varying, 'Rejected'::character varying])::text[])))) |
| notifications.notification_operation | notification_operation_pkey | PRIMARY KEY (school_id, operation_id) |
| notifications.notification_retention_run | notification_retention_run_affected_check | CHECK ((affected >= 0)) |
| notifications.notification_retention_run | notification_retention_run_pkey | PRIMARY KEY (run_id) |
| notifications.notification_retention_run | notification_retention_run_reason_check | CHECK ((length(TRIM(BOTH FROM reason)) > 0)) |
| notifications.notification_template | notification_template_pkey | PRIMARY KEY (school_id, template_id) |
| notifications.notification_template | nt_content | CHECK (((length(TRIM(BOTH FROM subject_template)) > 0) AND (length(TRIM(BOTH FROM body_template)) > 0))) |
| notifications.notification_template | nt_revision_time | CHECK (((revision > 0) AND (updated_at >= created_at))) |
| notifications.notification_template | nt_status | CHECK (((status)::text = ANY ((ARRAY['Active'::character varying, 'Archived'::character varying])::text[]))) |
| notifications.notification_template | nt_type | CHECK (((notification_type)::text = ANY ((ARRAY['LessonScheduled'::character varying, 'LessonRescheduled'::character varying, 'LessonCancelled'::character varying, 'LessonReminder'::character varying, 'AssessmentPassed'::character varying, 'AssessmentFailed'::character varying])::text[]))) |
| notifications.notification_work | notification_work_pkey | PRIMARY KEY (school_id, notification_id) |
| notifications.notification_work | notification_work_school_id_notification_id_fkey | FOREIGN KEY (school_id, notification_id) REFERENCES notifications.notification(school_id, notification_id) ON DELETE CASCADE |
| notifications.schema_history | schema_history_pkey | PRIMARY KEY (version) |

## Indexes

| Schema / table | Index | Definition |
|---|---|---|
| notifications.notification | notification_pkey | CREATE UNIQUE INDEX notification_pkey ON notifications.notification USING btree (school_id, notification_id) |
| notifications.notification | notification_school_id_recipient_user_id_channel_dispatch_k_idx | CREATE UNIQUE INDEX notification_school_id_recipient_user_id_channel_dispatch_k_idx ON notifications.notification USING btree (school_id, recipient_user_id, channel, dispatch_key) |
| notifications.notification | notification_school_id_recipient_user_id_created_at_idx | CREATE INDEX notification_school_id_recipient_user_id_created_at_idx ON notifications.notification USING btree (school_id, recipient_user_id, created_at) |
| notifications.notification | notification_school_id_source_context_source_id_source_revi_idx | CREATE INDEX notification_school_id_source_context_source_id_source_revi_idx ON notifications.notification USING btree (school_id, source_context, source_id, source_revision) |
| notifications.notification | notification_status_next_attempt_at_scheduled_at_idx | CREATE INDEX notification_status_next_attempt_at_scheduled_at_idx ON notifications.notification USING btree (status, next_attempt_at, scheduled_at) |
| notifications.notification_delivery_attempt | nda_one_unresolved | CREATE UNIQUE INDEX nda_one_unresolved ON notifications.notification_delivery_attempt USING btree (school_id, notification_id) WHERE ((status)::text = ANY ((ARRAY['Started'::character varying, 'Unknown'::character varying])::text[])) |
| notifications.notification_delivery_attempt | notification_delivery_attempt_pkey | CREATE UNIQUE INDEX notification_delivery_attempt_pkey ON notifications.notification_delivery_attempt USING btree (school_id, attempt_id) |
| notifications.notification_delivery_attempt | notification_delivery_attempt_school_id_notification_id_att_idx | CREATE UNIQUE INDEX notification_delivery_attempt_school_id_notification_id_att_idx ON notifications.notification_delivery_attempt USING btree (school_id, notification_id, attempt_no) |
| notifications.notification_delivery_attempt | notification_delivery_attempt_school_id_provider_key_idx | CREATE UNIQUE INDEX notification_delivery_attempt_school_id_provider_key_idx ON notifications.notification_delivery_attempt USING btree (school_id, provider_key) |
| notifications.notification_inbox | notification_inbox_pkey | CREATE UNIQUE INDEX notification_inbox_pkey ON notifications.notification_inbox USING btree (school_id, producer, event_id) |
| notifications.notification_operation | notification_operation_pkey | CREATE UNIQUE INDEX notification_operation_pkey ON notifications.notification_operation USING btree (school_id, operation_id) |
| notifications.notification_retention_run | notification_retention_run_pkey | CREATE UNIQUE INDEX notification_retention_run_pkey ON notifications.notification_retention_run USING btree (run_id) |
| notifications.notification_template | notification_template_pkey | CREATE UNIQUE INDEX notification_template_pkey ON notifications.notification_template USING btree (school_id, template_id) |
| notifications.notification_template | nt_one_active | CREATE UNIQUE INDEX nt_one_active ON notifications.notification_template USING btree (school_id, notification_type) WHERE ((status)::text = 'Active'::text) |
| notifications.notification_work | notification_work_pkey | CREATE UNIQUE INDEX notification_work_pkey ON notifications.notification_work USING btree (school_id, notification_id) |
| notifications.notification_work | nw_due | CREATE INDEX nw_due ON notifications.notification_work USING btree (available_at, school_id, notification_id) |
| notifications.schema_history | schema_history_pkey | CREATE UNIQUE INDEX schema_history_pkey ON notifications.schema_history USING btree (version) |

## Row-Level Security

| Schema / table | Enabled | Forced |
|---|---|---|
| notifications.notification_template | True | True |
| notifications.schema_history | False | False |
| notifications.notification_operation | True | True |
| notifications.notification | True | True |
| notifications.notification_work | False | False |
| notifications.notification_retention_run | False | False |
| notifications.notification_delivery_attempt | True | True |
| notifications.notification_inbox | True | True |

Policy expressions and command/role restrictions are retained verbatim in `../schema/implemented-catalogue.json` and `../schema/implemented-schema.sql`. Schema DDL also contains functions and triggers enforcing integrity and audit invariants.
