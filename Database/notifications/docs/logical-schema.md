# Notifications — Logical relational schema

Authority: Current proposed notification/delivery model. [Canonical DBML](../schema/schema.dbml).

The [Mermaid diagram](../schema/database-erd.md) shows keys/FKs and representative attributes; full attributes/defaults/classification are in data-dictionary.md. 

Physical count: 5 domain tables, 69 columns, 2 local FK declarations. EF migration history, where present, is technical metadata, not a new aggregate.

## Relationships and optionality

| Parent key | Child FK | Required? | Cardinality / integrity |
|---|---|---|---|
| notification_template(school_id,template_id) | notification(school_id,template_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; restrict |
| notification(school_id,notification_id) | notification_delivery_attempt(school_id,notification_id) | Yes | 0..N children per parent; restrict |

## Deployment/transaction source

[Install wrapper](../ddl/install.sql) is the only fresh-install entry. It references existing canonical SQL or the generated initial migration, not another service’s same-named schema.sql. [Security overlay](../security/database-roles.sql) follows schema creation; demo seeds run only under explicit test gates.

No previous production migration history was found/assumed. Reapplying raw initial DDL over a populated database is forbidden. Scheduling has a real EF migration/snapshot and no-op migration rerun check; other contexts use a fresh SQL baseline and require a separately reviewed differential upgrade if legacy data exists.

Current remote owner/API gaps do not by themselves invalidate relational design. They remain runtime/integration gates and cannot be proven by FK tests.

## Executable database rules beyond DBML

- notification.n_attempt_required: `CHECK ((((status)::text <> ALL ((ARRAY['Sending'::character varying, 'Sent'::character varying, 'DeliveryUnknown'::character varying])::text[])) OR (attempt_count > 0)))`.
- notification.n_cancel_pair: `CHECK ((((status)::text = 'Cancelled'::text) = (cancelled_at IS NOT NULL)))`.
- notification.n_cancel_time: `CHECK (((cancelled_at IS NULL) OR (cancelled_at >= created_at)))`.
- notification.n_channel: `CHECK (((channel)::text = 'Email'::text))`.
- notification.n_content: `CHECK (((length(TRIM(BOTH FROM subject)) > 0) AND (length(TRIM(BOTH FROM body)) > 0) AND (length(TRIM(BOTH FROM destination_address)) > 0) AND (length(TRIM(BOTH FROM contact_revision)) > 0) AND (length(TRIM(BOTH FROM dispatch_key)) > 0)))`.
- notification.n_retry_time: `CHECK (((next_attempt_at IS NULL) OR (((status)::text = 'Pending'::text) AND (next_attempt_at >= created_at))))`.
- notification.n_revisions: `CHECK (((revision > 0) AND (source_revision > 0) AND (attempt_count >= 0)))`.
- notification.n_sent_pair: `CHECK ((((status)::text = 'Sent'::text) = (sent_at IS NOT NULL)))`.
- notification.n_sent_time: `CHECK (((sent_at IS NULL) OR (sent_at >= created_at)))`.
- notification.n_source: `CHECK (((source_context)::text = ANY ((ARRAY['Scheduling'::character varying, 'LearningTracking'::character varying])::text[])))`.
- notification.n_status: `CHECK (((status)::text = ANY ((ARRAY['Pending'::character varying, 'Sending'::character varying, 'Sent'::character varying, 'Failed'::character varying, 'Cancelled'::character varying, 'DeliveryUnknown'::character varying])::text[])))`.
- notification.n_template_pair: `CHECK ((((template_id IS NULL) AND (template_revision IS NULL)) OR ((template_id IS NOT NULL) AND (template_revision IS NOT NULL) AND (template_revision > 0))))`.
- notification.n_time: `CHECK (((updated_at >= created_at) AND (scheduled_at >= created_at)))`.
- notification.n_type: `CHECK (((notification_type)::text = ANY ((ARRAY['LessonScheduled'::character varying, 'LessonRescheduled'::character varying, 'LessonCancelled'::character varying, 'LessonReminder'::character varying, 'AssessmentPassed'::character varying, 'AssessmentFailed'::character varying])::text[])))`.
- notification.notification_pkey: `PRIMARY KEY (school_id, notification_id)`.
- notification.notification_school_id_template_id_fkey: `FOREIGN KEY (school_id, template_id) REFERENCES notification_template(school_id, template_id) ON DELETE RESTRICT DEFERRABLE`.
- notification_delivery_attempt.nda_finished: `CHECK ((((status)::text = 'Started'::text) = (finished_at IS NULL)))`.
- notification_delivery_attempt.nda_identity: `CHECK (((attempt_no > 0) AND (length(TRIM(BOTH FROM provider_key)) > 0)))`.
- notification_delivery_attempt.nda_status: `CHECK (((status)::text = ANY ((ARRAY['Started'::character varying, 'Accepted'::character varying, 'Rejected'::character varying, 'Unknown'::character varying])::text[])))`.
- notification_delivery_attempt.nda_time: `CHECK (((finished_at IS NULL) OR (finished_at >= started_at)))`.
- notification_delivery_attempt.notification_delivery_attempt_pkey: `PRIMARY KEY (school_id, attempt_id)`.
- notification_delivery_attempt.notification_delivery_attempt_school_id_notification_id_fkey: `FOREIGN KEY (school_id, notification_id) REFERENCES notification(school_id, notification_id) ON DELETE RESTRICT DEFERRABLE`.
- notification_inbox.ni_hash: `CHECK (((payload_hash)::text ~ '^[0-9a-f]{64}$'::text))`.
- notification_inbox.ni_outcome: `CHECK ((((outcome)::text = ANY ((ARRAY['Applied'::character varying, 'Ignored'::character varying, 'Rejected'::character varying])::text[])) AND (length(TRIM(BOTH FROM outcome_code)) > 0)))`.
- notification_inbox.ni_source: `CHECK ((((producer)::text = ANY ((ARRAY['Scheduling'::character varying, 'LearningTracking'::character varying])::text[])) AND (source_revision > 0)))`.
- notification_inbox.ni_time: `CHECK ((processed_at >= received_at))`.
- notification_inbox.notification_inbox_pkey: `PRIMARY KEY (school_id, producer, event_id)`.
- notification_operation.no_basis: `CHECK ((((request_hash)::text ~ '^[0-9a-f]{64}$'::text) AND (length(TRIM(BOTH FROM command_name)) > 0) AND (length(TRIM(BOTH FROM authority_basis)) > 0) AND (length(TRIM(BOTH FROM outcome_code)) > 0)))`.
- notification_operation.no_confirmation_pair: `CHECK (((confirmation_id IS NULL) = (confirmed_at IS NULL)))`.
- notification_operation.no_mcp_confirmation: `CHECK ((((channel)::text <> 'MCP'::text) OR ((outcome)::text <> 'Applied'::text) OR (confirmation_id IS NOT NULL)))`.
- notification_operation.no_revision: `CHECK (((resulting_revision IS NULL) OR (resulting_revision > 0)))`.
- notification_operation.no_values: `CHECK ((((channel)::text = ANY ((ARRAY['Web'::character varying, 'MCP'::character varying])::text[])) AND ((outcome)::text = ANY ((ARRAY['Applied'::character varying, 'Rejected'::character varying])::text[]))))`.
- notification_operation.notification_operation_pkey: `PRIMARY KEY (school_id, operation_id)`.
- notification_template.notification_template_pkey: `PRIMARY KEY (school_id, template_id)`.
- notification_template.nt_content: `CHECK (((length(TRIM(BOTH FROM subject_template)) > 0) AND (length(TRIM(BOTH FROM body_template)) > 0)))`.
- notification_template.nt_revision_time: `CHECK (((revision > 0) AND (updated_at >= created_at)))`.
- notification_template.nt_status: `CHECK (((status)::text = ANY ((ARRAY['Active'::character varying, 'Archived'::character varying])::text[])))`.
- notification_template.nt_type: `CHECK (((notification_type)::text = ANY ((ARRAY['LessonScheduled'::character varying, 'LessonRescheduled'::character varying, 'LessonCancelled'::character varying, 'LessonReminder'::character varying, 'AssessmentPassed'::character varying, 'AssessmentFailed'::character varying])::text[])))`.
