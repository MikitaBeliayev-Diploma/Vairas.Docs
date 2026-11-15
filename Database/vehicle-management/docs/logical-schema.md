# Vehicle Management — Logical relational schema

Authority: Current reviewed proposed model, not deployed service. [Canonical DBML](../schema/schema.dbml).

The [Mermaid diagram](../schema/database-erd.md) shows keys/FKs and representative attributes; full attributes/defaults/classification are in data-dictionary.md. 

Physical count: 5 domain tables, 51 columns, 5 local FK declarations. EF migration history, where present, is technical metadata, not a new aggregate.

## Relationships and optionality

| Parent key | Child FK | Required? | Cardinality / integrity |
|---|---|---|---|
| vehicle(vehicle_id,school_id) | vehicle_supported_category(vehicle_id,school_id) | Yes | 0..N children per parent; restrict |
| vehicle(vehicle_id,school_id) | vehicle_teacher_assignment(vehicle_id,school_id) | Yes | 0..N children per parent; restrict |
| vehicle(vehicle_id,school_id) | maintenance(vehicle_id,school_id) | Yes | 0..N children per parent; restrict |
| vehicle(vehicle_id,school_id) | vehicle_operation(vehicle_id,school_id) | Yes | 0..N children per parent; restrict |
| maintenance(maintenance_id,vehicle_id,school_id) | vehicle_operation(maintenance_id,vehicle_id,school_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; restrict |

## Deployment/transaction source

[Install wrapper](../ddl/install.sql) is the only fresh-install entry. It references existing canonical SQL or the generated initial migration, not another service’s same-named schema.sql. [Security overlay](../security/database-roles.sql) follows schema creation; demo seeds run only under explicit test gates.

No previous production migration history was found/assumed. Reapplying raw initial DDL over a populated database is forbidden. Scheduling has a real EF migration/snapshot and no-op migration rerun check; other contexts use a fresh SQL baseline and require a separately reviewed differential upgrade if legacy data exists.

Current remote owner/API gaps do not by themselves invalidate relational design. They remain runtime/integration gates and cannot be proven by FK tests.

## Executable database rules beyond DBML

- maintenance.maintenance_pkey: `PRIMARY KEY (maintenance_id)`.
- maintenance.maintenance_vehicle_id_school_id_fkey: `FOREIGN KEY (vehicle_id, school_id) REFERENCES vehicle(vehicle_id, school_id) ON DELETE RESTRICT DEFERRABLE`.
- maintenance.vm_maintenance_lifecycle_shape: `CHECK ((((status = 'Scheduled'::vm_maintenance_status) AND (started_at IS NULL) AND (completed_at IS NULL) AND (cancelled_at IS NULL)) OR ((status = 'InProgress'::vm_maintenance_status) AND (started_at IS NOT NULL) AND (completed_at IS NULL) AND (cancelled_at IS NULL)) OR ((status = 'Completed'::vm_maintenance_status) AND (started_at IS NOT NULL) AND (completed_at IS NOT NULL) AND (cancelled_at IS NULL)) OR ((status = 'Cancelled'::vm_maintenance_status) AND (started_at IS NULL) AND (completed_at IS NULL) AND (cancelled_at IS NOT NULL))))`.
- maintenance.vm_maintenance_revision_time: `CHECK (((revision > 0) AND (updated_at >= created_at)))`.
- maintenance.vm_maintenance_time_order: `CHECK ((((started_at IS NULL) OR (started_at >= created_at)) AND ((completed_at IS NULL) OR (completed_at >= started_at)) AND ((cancelled_at IS NULL) OR (cancelled_at >= created_at))))`.
- maintenance.vm_maintenance_updated_time: `CHECK ((((started_at IS NULL) OR (updated_at >= started_at)) AND ((completed_at IS NULL) OR (updated_at >= completed_at)) AND ((cancelled_at IS NULL) OR (updated_at >= cancelled_at))))`.
- vehicle.vehicle_pkey: `PRIMARY KEY (vehicle_id)`.
- vehicle.vm_country_shape: `CHECK (((registration_country_code)::text ~ '^[A-Z]{2}$'::text))`.
- vehicle.vm_details_nonblank: `CHECK (((length(TRIM(BOTH FROM manufacturer)) > 0) AND (length(TRIM(BOTH FROM model)) > 0)))`.
- vehicle.vm_registration_shape: `CHECK (((length(TRIM(BOTH FROM registration_number)) > 0) AND ((registration_number)::text = upper(TRIM(BOTH FROM registration_number)))))`.
- vehicle.vm_revision_time: `CHECK (((revision > 0) AND (updated_at >= created_at)))`.
- vehicle.vm_year_storage_range: `CHECK (((manufacture_year >= 1886) AND (manufacture_year <= 9999)))`.
- vehicle_operation.vehicle_operation_maintenance_id_vehicle_id_school_id_fkey: `FOREIGN KEY (maintenance_id, vehicle_id, school_id) REFERENCES maintenance(maintenance_id, vehicle_id, school_id) ON DELETE RESTRICT DEFERRABLE`.
- vehicle_operation.vehicle_operation_pkey: `PRIMARY KEY (operation_id)`.
- vehicle_operation.vehicle_operation_vehicle_id_school_id_fkey: `FOREIGN KEY (vehicle_id, school_id) REFERENCES vehicle(vehicle_id, school_id) ON DELETE RESTRICT DEFERRABLE`.
- vehicle_operation.vm_confirmation_pair: `CHECK (((confirmation_id IS NULL) = (confirmed_at IS NULL)))`.
- vehicle_operation.vm_confirmation_time: `CHECK (((confirmed_at IS NULL) OR (confirmed_at <= recorded_at)))`.
- vehicle_operation.vm_mcp_confirmation: `CHECK (((channel <> 'MCP'::vm_channel) OR (confirmation_id IS NOT NULL)))`.
- vehicle_operation.vm_operation_actor: `CHECK ((((actor_user_id IS NOT NULL) AND (actor_service IS NULL)) OR ((actor_user_id IS NULL) AND (actor_service IS NOT NULL) AND (length(TRIM(BOTH FROM actor_service)) > 0) AND (channel = 'Internal'::vm_channel))))`.
- vehicle_operation.vm_operation_maintenance_shape: `CHECK ((((maintenance_id IS NULL) AND (expected_maintenance_revision IS NULL) AND (resulting_maintenance_revision IS NULL)) OR ((maintenance_id IS NOT NULL) AND (resulting_maintenance_revision IS NOT NULL) AND ((expected_maintenance_revision IS NULL) OR (expected_maintenance_revision > 0)))))`.
- vehicle_operation.vm_operation_revision_order: `CHECK ((((expected_vehicle_revision IS NULL) OR (resulting_vehicle_revision >= expected_vehicle_revision)) AND ((expected_maintenance_revision IS NULL) OR (resulting_maintenance_revision > expected_maintenance_revision))))`.
- vehicle_operation.vm_operation_revisions: `CHECK ((((expected_vehicle_revision IS NULL) OR (expected_vehicle_revision > 0)) AND (resulting_vehicle_revision > 0) AND ((resulting_maintenance_revision IS NULL) OR (resulting_maintenance_revision > 0))))`.
- vehicle_operation.vm_operation_shape: `CHECK (((length(TRIM(BOTH FROM command_name)) > 0) AND ((request_fingerprint)::text ~ '^[0-9a-f]{64}$'::text)))`.
- vehicle_supported_category.vehicle_supported_category_pkey: `PRIMARY KEY (vehicle_id, school_id, category_code)`.
- vehicle_supported_category.vehicle_supported_category_vehicle_id_school_id_fkey: `FOREIGN KEY (vehicle_id, school_id) REFERENCES vehicle(vehicle_id, school_id) ON DELETE RESTRICT DEFERRABLE`.
- vehicle_supported_category.vm_category_shape: `CHECK (((length(TRIM(BOTH FROM category_code)) > 0) AND ((category_code)::text = upper(TRIM(BOTH FROM category_code)))))`.
- vehicle_teacher_assignment.vehicle_teacher_assignment_pkey: `PRIMARY KEY (vehicle_id, school_id, teacher_id)`.
- vehicle_teacher_assignment.vehicle_teacher_assignment_vehicle_id_school_id_fkey: `FOREIGN KEY (vehicle_id, school_id) REFERENCES vehicle(vehicle_id, school_id) ON DELETE RESTRICT DEFERRABLE`.
