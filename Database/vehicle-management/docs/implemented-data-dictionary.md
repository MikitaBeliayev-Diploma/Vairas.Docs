# Implemented data dictionary — vehicle-management

Observed synthetic PostgreSQL database: `vairas_vehicle_management`. Exported from migrated local runtime on 2026-11-25. Schema-only evidence; no business rows are included.

Migrations in the owning service remain the schema evolution authority. Existing design dictionaries are preserved separately. Cross-service UUID references are not physical foreign keys unless listed below.

| Schema | Table | Column | PostgreSQL type | Nullable | Default | Maximum length |
|---|---|---|---|---|---|---|
| public | __EFMigrationsHistory | MigrationId | varchar | NO |  | 150 |
| public | __EFMigrationsHistory | ProductVersion | varchar | NO |  | 32 |
| public | command_request | request_id | uuid | NO |  |  |
| public | command_request | school_id | uuid | NO |  |  |
| public | command_request | actor_user_id | uuid | NO |  |  |
| public | command_request | idempotency_key | varchar | NO |  | 128 |
| public | command_request | command_name | varchar | NO |  | 80 |
| public | command_request | fingerprint | varchar | NO |  | 64 |
| public | command_request | vehicle_id | uuid | NO |  |  |
| public | command_request | response_json | text | YES |  |  |
| public | command_request | created_at | timestamptz | NO |  |  |
| public | maintenance | maintenance_id | uuid | NO |  |  |
| public | maintenance | school_id | uuid | NO |  |  |
| public | maintenance | vehicle_id | uuid | NO |  |  |
| public | maintenance | type | vm_maintenance_type | NO |  |  |
| public | maintenance | scheduled_at | timestamptz | NO |  |  |
| public | maintenance | started_at | timestamptz | YES |  |  |
| public | maintenance | completed_at | timestamptz | YES |  |  |
| public | maintenance | cancelled_at | timestamptz | YES |  |  |
| public | maintenance | status | vm_maintenance_status | NO | 'Scheduled'::vm_maintenance_status |  |
| public | maintenance | comment | text | YES |  |  |
| public | maintenance | revision | int8 | NO | 1 |  |
| public | maintenance | created_at | timestamptz | NO |  |  |
| public | maintenance | updated_at | timestamptz | NO |  |  |
| public | outbox_message | message_id | uuid | NO |  |  |
| public | outbox_message | school_id | uuid | NO |  |  |
| public | outbox_message | vehicle_id | uuid | NO |  |  |
| public | outbox_message | aggregate_version | int8 | NO |  |  |
| public | outbox_message | event_type | varchar | NO |  | 80 |
| public | outbox_message | payload_json | text | NO |  |  |
| public | outbox_message | correlation_id | varchar | NO |  | 128 |
| public | outbox_message | occurred_at | timestamptz | NO |  |  |
| public | outbox_message | next_attempt_at | timestamptz | NO |  |  |
| public | outbox_message | lease_token | uuid | YES |  |  |
| public | outbox_message | lease_until | timestamptz | YES |  |  |
| public | outbox_message | attempts | int4 | NO |  |  |
| public | outbox_message | published_at | timestamptz | YES |  |  |
| public | vehicle | vehicle_id | uuid | NO |  |  |
| public | vehicle | school_id | uuid | NO |  |  |
| public | vehicle | branch_id | uuid | NO |  |  |
| public | vehicle | registration_country_code | varchar | NO |  | 2 |
| public | vehicle | registration_number | varchar | NO |  | 32 |
| public | vehicle | manufacturer | varchar | NO |  | 100 |
| public | vehicle | model | varchar | NO |  | 100 |
| public | vehicle | manufacture_year | int2 | NO |  |  |
| public | vehicle | transmission | vm_transmission | NO |  |  |
| public | vehicle | status | vm_vehicle_status | NO | 'Inactive'::vm_vehicle_status |  |
| public | vehicle | revision | int8 | NO | 1 |  |
| public | vehicle | created_at | timestamptz | NO |  |  |
| public | vehicle | updated_at | timestamptz | NO |  |  |
| public | vehicle_operation | operation_id | uuid | NO |  |  |
| public | vehicle_operation | school_id | uuid | NO |  |  |
| public | vehicle_operation | vehicle_id | uuid | NO |  |  |
| public | vehicle_operation | maintenance_id | uuid | YES |  |  |
| public | vehicle_operation | actor_user_id | uuid | YES |  |  |
| public | vehicle_operation | actor_service | varchar | YES |  | 120 |
| public | vehicle_operation | channel | vm_channel | NO |  |  |
| public | vehicle_operation | command_name | varchar | NO |  | 80 |
| public | vehicle_operation | request_fingerprint | varchar | NO |  | 64 |
| public | vehicle_operation | expected_vehicle_revision | int8 | YES |  |  |
| public | vehicle_operation | expected_maintenance_revision | int8 | YES |  |  |
| public | vehicle_operation | resulting_vehicle_revision | int8 | NO |  |  |
| public | vehicle_operation | resulting_maintenance_revision | int8 | YES |  |  |
| public | vehicle_operation | reason | text | YES |  |  |
| public | vehicle_operation | confirmation_id | uuid | YES |  |  |
| public | vehicle_operation | confirmed_at | timestamptz | YES |  |  |
| public | vehicle_operation | recorded_at | timestamptz | NO |  |  |
| public | vehicle_state_change_operation | operation_id | uuid | NO |  |  |
| public | vehicle_state_change_operation | school_id | uuid | NO |  |  |
| public | vehicle_state_change_operation | vehicle_id | uuid | NO |  |  |
| public | vehicle_state_change_operation | actor_user_id | uuid | NO |  |  |
| public | vehicle_state_change_operation | branch_id | uuid | NO |  |  |
| public | vehicle_state_change_operation | operation_type | varchar | NO |  | 32 |
| public | vehicle_state_change_operation | status | varchar | NO |  | 32 |
| public | vehicle_state_change_operation | resume_status | varchar | NO |  | 32 |
| public | vehicle_state_change_operation | expected_vehicle_revision | int8 | NO |  |  |
| public | vehicle_state_change_operation | fingerprint | varchar | NO |  | 64 |
| public | vehicle_state_change_operation | reason | varchar | NO |  | 1000 |
| public | vehicle_state_change_operation | correlation_id | varchar | NO |  | 128 |
| public | vehicle_state_change_operation | block_id | uuid | YES |  |  |
| public | vehicle_state_change_operation | block_operation_id | uuid | YES |  |  |
| public | vehicle_state_change_operation | release_operation_id | uuid | NO |  |  |
| public | vehicle_state_change_operation | result_vehicle_status | vm_vehicle_status | YES |  |  |
| public | vehicle_state_change_operation | error_code | varchar | YES |  | 120 |
| public | vehicle_state_change_operation | attempts | int4 | NO |  |  |
| public | vehicle_state_change_operation | next_attempt_at | timestamptz | NO |  |  |
| public | vehicle_state_change_operation | lease_token | uuid | YES |  |  |
| public | vehicle_state_change_operation | lease_until | timestamptz | YES |  |  |
| public | vehicle_state_change_operation | created_at | timestamptz | NO |  |  |
| public | vehicle_state_change_operation | updated_at | timestamptz | NO |  |  |
| public | vehicle_supported_category | vehicle_id | uuid | NO |  |  |
| public | vehicle_supported_category | school_id | uuid | NO |  |  |
| public | vehicle_supported_category | category_code | varchar | NO |  | 16 |
| public | vehicle_teacher_assignment | vehicle_id | uuid | NO |  |  |
| public | vehicle_teacher_assignment | school_id | uuid | NO |  |  |
| public | vehicle_teacher_assignment | teacher_id | uuid | NO |  |  |
| public | vehicle_teacher_assignment | school_membership_id | uuid | NO |  |  |
| public | vehicle_teacher_assignment | assigned_at | timestamptz | NO |  |  |

## Physical constraints

| Schema / table | Name | Definition |
|---|---|---|
| public.__EFMigrationsHistory | PK___EFMigrationsHistory | PRIMARY KEY ("MigrationId") |
| public.command_request | command_request_fingerprint_check | CHECK (((fingerprint)::text ~ '^[0-9a-f]{64}$'::text)) |
| public.command_request | command_request_idempotency_key_check | CHECK (((length((idempotency_key)::text) >= 8) AND (length((idempotency_key)::text) <= 128))) |
| public.command_request | command_request_pkey | PRIMARY KEY (request_id) |
| public.command_request | command_request_school_id_actor_user_id_command_name_idempo_key | UNIQUE (school_id, actor_user_id, command_name, idempotency_key) |
| public.command_request | command_request_vehicle_id_school_id_fkey | FOREIGN KEY (vehicle_id, school_id) REFERENCES vehicle(vehicle_id, school_id) ON DELETE RESTRICT |
| public.maintenance | maintenance_pkey | PRIMARY KEY (maintenance_id) |
| public.maintenance | maintenance_vehicle_id_school_id_fkey | FOREIGN KEY (vehicle_id, school_id) REFERENCES vehicle(vehicle_id, school_id) ON DELETE RESTRICT DEFERRABLE |
| public.maintenance | vm_maintenance_lifecycle_shape | CHECK ((((status = 'Scheduled'::vm_maintenance_status) AND (started_at IS NULL) AND (completed_at IS NULL) AND (cancelled_at IS NULL)) OR ((status = 'InProgress'::vm_maintenance_status) AND (started_at IS NOT NULL) AND (completed_at IS NULL) AND (cancelled_at IS NULL)) OR ((status = 'Completed'::vm_maintenance_status) AND (started_at IS NOT NULL) AND (completed_at IS NOT NULL) AND (cancelled_at IS NULL)) OR ((status = 'Cancelled'::vm_maintenance_status) AND (started_at IS NULL) AND (completed_at IS NULL) AND (cancelled_at IS NOT NULL)))) |
| public.maintenance | vm_maintenance_revision_time | CHECK (((revision > 0) AND (updated_at >= created_at))) |
| public.maintenance | vm_maintenance_time_order | CHECK ((((started_at IS NULL) OR (started_at >= created_at)) AND ((completed_at IS NULL) OR (completed_at >= started_at)) AND ((cancelled_at IS NULL) OR (cancelled_at >= created_at)))) |
| public.maintenance | vm_maintenance_updated_time | CHECK ((((started_at IS NULL) OR (updated_at >= started_at)) AND ((completed_at IS NULL) OR (updated_at >= completed_at)) AND ((cancelled_at IS NULL) OR (updated_at >= cancelled_at)))) |
| public.outbox_message | outbox_message_aggregate_version_check | CHECK ((aggregate_version > 0)) |
| public.outbox_message | outbox_message_attempts_check | CHECK ((attempts >= 0)) |
| public.outbox_message | outbox_message_check | CHECK (((lease_token IS NULL) = (lease_until IS NULL))) |
| public.outbox_message | outbox_message_check1 | CHECK (((published_at IS NULL) OR (published_at >= occurred_at))) |
| public.outbox_message | outbox_message_event_type_check | CHECK (((event_type)::text = ANY ((ARRAY['VehicleActivated'::character varying, 'VehicleDeactivated'::character varying])::text[]))) |
| public.outbox_message | outbox_message_pkey | PRIMARY KEY (message_id) |
| public.outbox_message | outbox_message_vehicle_id_school_id_fkey | FOREIGN KEY (vehicle_id, school_id) REFERENCES vehicle(vehicle_id, school_id) ON DELETE RESTRICT |
| public.vehicle | vehicle_pkey | PRIMARY KEY (vehicle_id) |
| public.vehicle | vm_country_shape | CHECK (((registration_country_code)::text ~ '^[A-Z]{2}$'::text)) |
| public.vehicle | vm_details_nonblank | CHECK (((length(TRIM(BOTH FROM manufacturer)) > 0) AND (length(TRIM(BOTH FROM model)) > 0))) |
| public.vehicle | vm_registration_shape | CHECK (((length(TRIM(BOTH FROM registration_number)) > 0) AND ((registration_number)::text = upper(TRIM(BOTH FROM registration_number))))) |
| public.vehicle | vm_revision_time | CHECK (((revision > 0) AND (updated_at >= created_at))) |
| public.vehicle | vm_year_storage_range | CHECK (((manufacture_year >= 1886) AND (manufacture_year <= 9999))) |
| public.vehicle_operation | vehicle_operation_maintenance_id_vehicle_id_school_id_fkey | FOREIGN KEY (maintenance_id, vehicle_id, school_id) REFERENCES maintenance(maintenance_id, vehicle_id, school_id) ON DELETE RESTRICT DEFERRABLE |
| public.vehicle_operation | vehicle_operation_pkey | PRIMARY KEY (operation_id) |
| public.vehicle_operation | vehicle_operation_vehicle_id_school_id_fkey | FOREIGN KEY (vehicle_id, school_id) REFERENCES vehicle(vehicle_id, school_id) ON DELETE RESTRICT DEFERRABLE |
| public.vehicle_operation | vm_confirmation_pair | CHECK (((confirmation_id IS NULL) = (confirmed_at IS NULL))) |
| public.vehicle_operation | vm_confirmation_time | CHECK (((confirmed_at IS NULL) OR (confirmed_at <= recorded_at))) |
| public.vehicle_operation | vm_mcp_confirmation | CHECK (((channel <> 'MCP'::vm_channel) OR (confirmation_id IS NOT NULL))) |
| public.vehicle_operation | vm_operation_actor | CHECK ((((actor_user_id IS NOT NULL) AND (actor_service IS NULL)) OR ((actor_user_id IS NULL) AND (actor_service IS NOT NULL) AND (length(TRIM(BOTH FROM actor_service)) > 0) AND (channel = 'Internal'::vm_channel)))) |
| public.vehicle_operation | vm_operation_maintenance_shape | CHECK ((((maintenance_id IS NULL) AND (expected_maintenance_revision IS NULL) AND (resulting_maintenance_revision IS NULL)) OR ((maintenance_id IS NOT NULL) AND (resulting_maintenance_revision IS NOT NULL) AND ((expected_maintenance_revision IS NULL) OR (expected_maintenance_revision > 0))))) |
| public.vehicle_operation | vm_operation_revision_order | CHECK ((((expected_vehicle_revision IS NULL) OR (resulting_vehicle_revision >= expected_vehicle_revision)) AND ((expected_maintenance_revision IS NULL) OR (resulting_maintenance_revision > expected_maintenance_revision)))) |
| public.vehicle_operation | vm_operation_revisions | CHECK ((((expected_vehicle_revision IS NULL) OR (expected_vehicle_revision > 0)) AND (resulting_vehicle_revision > 0) AND ((resulting_maintenance_revision IS NULL) OR (resulting_maintenance_revision > 0)))) |
| public.vehicle_operation | vm_operation_shape | CHECK (((length(TRIM(BOTH FROM command_name)) > 0) AND ((request_fingerprint)::text ~ '^[0-9a-f]{64}$'::text))) |
| public.vehicle_state_change_operation | vehicle_state_change_operation_attempts_check | CHECK ((attempts >= 0)) |
| public.vehicle_state_change_operation | vehicle_state_change_operation_check | CHECK ((updated_at >= created_at)) |
| public.vehicle_state_change_operation | vehicle_state_change_operation_check1 | CHECK (((lease_token IS NULL) = (lease_until IS NULL))) |
| public.vehicle_state_change_operation | vehicle_state_change_operation_check2 | CHECK (((block_id IS NULL) = (block_operation_id IS NULL))) |
| public.vehicle_state_change_operation | vehicle_state_change_operation_expected_vehicle_revision_check | CHECK ((expected_vehicle_revision > 0)) |
| public.vehicle_state_change_operation | vehicle_state_change_operation_fingerprint_check | CHECK (((fingerprint)::text ~ '^[0-9a-f]{64}$'::text)) |
| public.vehicle_state_change_operation | vehicle_state_change_operation_operation_type_check | CHECK (((operation_type)::text = ANY ((ARRAY['Deactivate'::character varying, 'Reactivate'::character varying])::text[]))) |
| public.vehicle_state_change_operation | vehicle_state_change_operation_pkey | PRIMARY KEY (operation_id) |
| public.vehicle_state_change_operation | vehicle_state_change_operation_reason_check | CHECK ((length(TRIM(BOTH FROM reason)) > 0)) |
| public.vehicle_state_change_operation | vehicle_state_change_operation_resume_status_check | CHECK (((resume_status)::text = ANY ((ARRAY['Pending'::character varying, 'Blocking'::character varying, 'SchedulingBlocked'::character varying, 'ApplyingVehicleState'::character varying, 'ReleasingBlock'::character varying, 'Completed'::character varying, 'Rejected'::character varying, 'NeedsRecovery'::character varying])::text[]))) |
| public.vehicle_state_change_operation | vehicle_state_change_operation_status_check | CHECK (((status)::text = ANY ((ARRAY['Pending'::character varying, 'Blocking'::character varying, 'SchedulingBlocked'::character varying, 'ApplyingVehicleState'::character varying, 'ReleasingBlock'::character varying, 'Completed'::character varying, 'Rejected'::character varying, 'NeedsRecovery'::character varying])::text[]))) |
| public.vehicle_state_change_operation | vehicle_state_change_operation_vehicle_id_school_id_fkey | FOREIGN KEY (vehicle_id, school_id) REFERENCES vehicle(vehicle_id, school_id) ON DELETE RESTRICT |
| public.vehicle_supported_category | vehicle_supported_category_pkey | PRIMARY KEY (vehicle_id, school_id, category_code) |
| public.vehicle_supported_category | vehicle_supported_category_vehicle_id_school_id_fkey | FOREIGN KEY (vehicle_id, school_id) REFERENCES vehicle(vehicle_id, school_id) ON DELETE RESTRICT DEFERRABLE |
| public.vehicle_supported_category | vm_category_shape | CHECK (((length(TRIM(BOTH FROM category_code)) > 0) AND ((category_code)::text = upper(TRIM(BOTH FROM category_code))))) |
| public.vehicle_teacher_assignment | vehicle_teacher_assignment_pkey | PRIMARY KEY (vehicle_id, school_id, teacher_id) |
| public.vehicle_teacher_assignment | vehicle_teacher_assignment_vehicle_id_school_id_fkey | FOREIGN KEY (vehicle_id, school_id) REFERENCES vehicle(vehicle_id, school_id) ON DELETE RESTRICT DEFERRABLE |

## Indexes

| Schema / table | Index | Definition |
|---|---|---|
| public.__EFMigrationsHistory | PK___EFMigrationsHistory | CREATE UNIQUE INDEX "PK___EFMigrationsHistory" ON public."__EFMigrationsHistory" USING btree ("MigrationId") |
| public.command_request | command_request_pkey | CREATE UNIQUE INDEX command_request_pkey ON public.command_request USING btree (request_id) |
| public.command_request | command_request_school_id_actor_user_id_command_name_idempo_key | CREATE UNIQUE INDEX command_request_school_id_actor_user_id_command_name_idempo_key ON public.command_request USING btree (school_id, actor_user_id, command_name, idempotency_key) |
| public.maintenance | maintenance_maintenance_id_vehicle_id_school_id_idx | CREATE UNIQUE INDEX maintenance_maintenance_id_vehicle_id_school_id_idx ON public.maintenance USING btree (maintenance_id, vehicle_id, school_id) |
| public.maintenance | maintenance_pkey | CREATE UNIQUE INDEX maintenance_pkey ON public.maintenance USING btree (maintenance_id) |
| public.maintenance | maintenance_school_id_vehicle_id_status_idx | CREATE INDEX maintenance_school_id_vehicle_id_status_idx ON public.maintenance USING btree (school_id, vehicle_id, status) |
| public.maintenance | vm_one_inprogress_per_vehicle | CREATE UNIQUE INDEX vm_one_inprogress_per_vehicle ON public.maintenance USING btree (vehicle_id, school_id) WHERE (status = 'InProgress'::vm_maintenance_status) |
| public.outbox_message | outbox_message_pkey | CREATE UNIQUE INDEX outbox_message_pkey ON public.outbox_message USING btree (message_id) |
| public.outbox_message | vm_outbox_due | CREATE INDEX vm_outbox_due ON public.outbox_message USING btree (next_attempt_at, lease_until) WHERE (published_at IS NULL) |
| public.vehicle | vehicle_pkey | CREATE UNIQUE INDEX vehicle_pkey ON public.vehicle USING btree (vehicle_id) |
| public.vehicle | vehicle_school_id_branch_id_status_idx | CREATE INDEX vehicle_school_id_branch_id_status_idx ON public.vehicle USING btree (school_id, branch_id, status) |
| public.vehicle | vehicle_school_id_registration_country_code_registration_nu_idx | CREATE UNIQUE INDEX vehicle_school_id_registration_country_code_registration_nu_idx ON public.vehicle USING btree (school_id, registration_country_code, registration_number) |
| public.vehicle | vehicle_vehicle_id_school_id_idx | CREATE UNIQUE INDEX vehicle_vehicle_id_school_id_idx ON public.vehicle USING btree (vehicle_id, school_id) |
| public.vehicle_operation | vehicle_operation_pkey | CREATE UNIQUE INDEX vehicle_operation_pkey ON public.vehicle_operation USING btree (operation_id) |
| public.vehicle_operation | vehicle_operation_school_id_vehicle_id_recorded_at_idx | CREATE INDEX vehicle_operation_school_id_vehicle_id_recorded_at_idx ON public.vehicle_operation USING btree (school_id, vehicle_id, recorded_at) |
| public.vehicle_state_change_operation | vehicle_state_change_operation_pkey | CREATE UNIQUE INDEX vehicle_state_change_operation_pkey ON public.vehicle_state_change_operation USING btree (operation_id) |
| public.vehicle_state_change_operation | vm_one_live_state_change | CREATE UNIQUE INDEX vm_one_live_state_change ON public.vehicle_state_change_operation USING btree (school_id, vehicle_id) WHERE ((status)::text <> ALL ((ARRAY['Completed'::character varying, 'Rejected'::character varying])::text[])) |
| public.vehicle_state_change_operation | vm_saga_due | CREATE INDEX vm_saga_due ON public.vehicle_state_change_operation USING btree (next_attempt_at, lease_until) WHERE ((status)::text <> ALL ((ARRAY['Completed'::character varying, 'Rejected'::character varying])::text[])) |
| public.vehicle_supported_category | vehicle_supported_category_pkey | CREATE UNIQUE INDEX vehicle_supported_category_pkey ON public.vehicle_supported_category USING btree (vehicle_id, school_id, category_code) |
| public.vehicle_teacher_assignment | vehicle_teacher_assignment_pkey | CREATE UNIQUE INDEX vehicle_teacher_assignment_pkey ON public.vehicle_teacher_assignment USING btree (vehicle_id, school_id, teacher_id) |
| public.vehicle_teacher_assignment | vehicle_teacher_assignment_school_id_school_membership_id_idx | CREATE INDEX vehicle_teacher_assignment_school_id_school_membership_id_idx ON public.vehicle_teacher_assignment USING btree (school_id, school_membership_id) |
| public.vehicle_teacher_assignment | vehicle_teacher_assignment_school_id_teacher_id_idx | CREATE INDEX vehicle_teacher_assignment_school_id_teacher_id_idx ON public.vehicle_teacher_assignment USING btree (school_id, teacher_id) |

## Row-Level Security

| Schema / table | Enabled | Forced |
|---|---|---|
| public.__EFMigrationsHistory | False | False |
| public.vehicle | True | False |
| public.vehicle_supported_category | True | False |
| public.vehicle_teacher_assignment | True | False |
| public.maintenance | True | False |
| public.vehicle_operation | True | False |
| public.command_request | True | False |
| public.vehicle_state_change_operation | True | False |
| public.outbox_message | True | False |

Policy expressions and command/role restrictions are retained verbatim in `../schema/implemented-catalogue.json` and `../schema/implemented-schema.sql`. Schema DDL also contains functions and triggers enforcing integrity and audit invariants.
