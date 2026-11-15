CREATE TYPE "vm_vehicle_status" AS ENUM (
  'Active',
  'Inactive',
  'UnderMaintenance'
);

CREATE TYPE "vm_transmission" AS ENUM (
  'Manual',
  'Automatic'
);

CREATE TYPE "vm_maintenance_type" AS ENUM (
  'Service',
  'Repair',
  'Inspection'
);

CREATE TYPE "vm_maintenance_status" AS ENUM (
  'Scheduled',
  'InProgress',
  'Completed',
  'Cancelled'
);

CREATE TYPE "vm_channel" AS ENUM (
  'Web',
  'MCP',
  'Internal'
);

CREATE TABLE "vehicle" (
  "vehicle_id" uuid PRIMARY KEY NOT NULL,
  "school_id" uuid NOT NULL,
  "branch_id" uuid NOT NULL,
  "registration_country_code" varchar(2) NOT NULL,
  "registration_number" varchar(32) NOT NULL,
  "manufacturer" varchar(100) NOT NULL,
  "model" varchar(100) NOT NULL,
  "manufacture_year" smallint NOT NULL,
  "transmission" vm_transmission NOT NULL,
  "status" vm_vehicle_status NOT NULL DEFAULT 'Inactive',
  "revision" bigint NOT NULL DEFAULT 1,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  CONSTRAINT "vm_country_shape" CHECK (registration_country_code ~ '^[A-Z]{2}$'),
  CONSTRAINT "vm_registration_shape" CHECK (length(trim(registration_number)) > 0 AND registration_number = upper(trim(registration_number))),
  CONSTRAINT "vm_details_nonblank" CHECK (length(trim(manufacturer)) > 0 AND length(trim(model)) > 0),
  CONSTRAINT "vm_year_storage_range" CHECK (manufacture_year BETWEEN 1886 AND 9999),
  CONSTRAINT "vm_revision_time" CHECK (revision > 0 AND updated_at >= created_at)
);

CREATE TABLE "vehicle_supported_category" (
  "vehicle_id" uuid NOT NULL,
  "school_id" uuid NOT NULL,
  "category_code" varchar(16) NOT NULL,
  CONSTRAINT "vm_category_shape" CHECK (length(trim(category_code)) > 0 AND category_code = upper(trim(category_code))),
  PRIMARY KEY ("vehicle_id", "school_id", "category_code")
);

CREATE TABLE "vehicle_teacher_assignment" (
  "vehicle_id" uuid NOT NULL,
  "school_id" uuid NOT NULL,
  "teacher_id" uuid NOT NULL,
  "school_membership_id" uuid NOT NULL,
  "assigned_at" timestamptz NOT NULL,
  PRIMARY KEY ("vehicle_id", "school_id", "teacher_id")
);

CREATE TABLE "maintenance" (
  "maintenance_id" uuid PRIMARY KEY NOT NULL,
  "school_id" uuid NOT NULL,
  "vehicle_id" uuid NOT NULL,
  "type" vm_maintenance_type NOT NULL,
  "scheduled_at" timestamptz NOT NULL,
  "started_at" timestamptz,
  "completed_at" timestamptz,
  "cancelled_at" timestamptz,
  "status" vm_maintenance_status NOT NULL DEFAULT 'Scheduled',
  "comment" text,
  "revision" bigint NOT NULL DEFAULT 1,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  CONSTRAINT "vm_maintenance_revision_time" CHECK (revision > 0 AND updated_at >= created_at),
  CONSTRAINT "vm_maintenance_lifecycle_shape" CHECK ((status = 'Scheduled' AND started_at IS NULL AND completed_at IS NULL AND cancelled_at IS NULL) OR (status = 'InProgress' AND started_at IS NOT NULL AND completed_at IS NULL AND cancelled_at IS NULL) OR (status = 'Completed' AND started_at IS NOT NULL AND completed_at IS NOT NULL AND cancelled_at IS NULL) OR (status = 'Cancelled' AND started_at IS NULL AND completed_at IS NULL AND cancelled_at IS NOT NULL)),
  CONSTRAINT "vm_maintenance_time_order" CHECK ((started_at IS NULL OR started_at >= created_at) AND (completed_at IS NULL OR completed_at >= started_at) AND (cancelled_at IS NULL OR cancelled_at >= created_at)),
  CONSTRAINT "vm_maintenance_updated_time" CHECK ((started_at IS NULL OR updated_at >= started_at) AND (completed_at IS NULL OR updated_at >= completed_at) AND (cancelled_at IS NULL OR updated_at >= cancelled_at))
);

CREATE TABLE "vehicle_operation" (
  "operation_id" uuid PRIMARY KEY NOT NULL,
  "school_id" uuid NOT NULL,
  "vehicle_id" uuid NOT NULL,
  "maintenance_id" uuid,
  "actor_user_id" uuid,
  "actor_service" varchar(120),
  "channel" vm_channel NOT NULL,
  "command_name" varchar(80) NOT NULL,
  "request_fingerprint" varchar(64) NOT NULL,
  "expected_vehicle_revision" bigint,
  "expected_maintenance_revision" bigint,
  "resulting_vehicle_revision" bigint NOT NULL,
  "resulting_maintenance_revision" bigint,
  "reason" text,
  "confirmation_id" uuid,
  "confirmed_at" timestamptz,
  "recorded_at" timestamptz NOT NULL,
  CONSTRAINT "vm_operation_shape" CHECK (length(trim(command_name)) > 0 AND request_fingerprint ~ '^[0-9a-f]{64}$'),
  CONSTRAINT "vm_operation_revisions" CHECK ((expected_vehicle_revision IS NULL OR expected_vehicle_revision > 0) AND resulting_vehicle_revision > 0 AND (resulting_maintenance_revision IS NULL OR resulting_maintenance_revision > 0)),
  CONSTRAINT "vm_operation_actor" CHECK ((actor_user_id IS NOT NULL AND actor_service IS NULL) OR (actor_user_id IS NULL AND actor_service IS NOT NULL AND length(trim(actor_service)) > 0 AND channel = 'Internal')),
  CONSTRAINT "vm_operation_maintenance_shape" CHECK ((maintenance_id IS NULL AND expected_maintenance_revision IS NULL AND resulting_maintenance_revision IS NULL) OR (maintenance_id IS NOT NULL AND resulting_maintenance_revision IS NOT NULL AND (expected_maintenance_revision IS NULL OR expected_maintenance_revision > 0))),
  CONSTRAINT "vm_operation_revision_order" CHECK ((expected_vehicle_revision IS NULL OR resulting_vehicle_revision >= expected_vehicle_revision) AND (expected_maintenance_revision IS NULL OR resulting_maintenance_revision > expected_maintenance_revision)),
  CONSTRAINT "vm_confirmation_pair" CHECK ((confirmation_id IS NULL) = (confirmed_at IS NULL)),
  CONSTRAINT "vm_mcp_confirmation" CHECK (channel <> 'MCP' OR confirmation_id IS NOT NULL),
  CONSTRAINT "vm_confirmation_time" CHECK (confirmed_at IS NULL OR confirmed_at <= recorded_at)
);

CREATE UNIQUE INDEX ON "vehicle" ("vehicle_id", "school_id");

CREATE UNIQUE INDEX ON "vehicle" ("school_id", "registration_country_code", "registration_number");

CREATE INDEX ON "vehicle" ("school_id", "branch_id", "status");

CREATE INDEX ON "vehicle_teacher_assignment" ("school_id", "teacher_id");

CREATE INDEX ON "vehicle_teacher_assignment" ("school_id", "school_membership_id");

CREATE UNIQUE INDEX ON "maintenance" ("maintenance_id", "vehicle_id", "school_id");

CREATE INDEX ON "maintenance" ("school_id", "vehicle_id", "status");

CREATE INDEX ON "vehicle_operation" ("school_id", "vehicle_id", "recorded_at");































ALTER TABLE "vehicle_supported_category" ADD FOREIGN KEY ("vehicle_id", "school_id") REFERENCES "vehicle" ("vehicle_id", "school_id") ON DELETE RESTRICT DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "vehicle_teacher_assignment" ADD FOREIGN KEY ("vehicle_id", "school_id") REFERENCES "vehicle" ("vehicle_id", "school_id") ON DELETE RESTRICT DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "maintenance" ADD FOREIGN KEY ("vehicle_id", "school_id") REFERENCES "vehicle" ("vehicle_id", "school_id") ON DELETE RESTRICT DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "vehicle_operation" ADD FOREIGN KEY ("vehicle_id", "school_id") REFERENCES "vehicle" ("vehicle_id", "school_id") ON DELETE RESTRICT DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "vehicle_operation" ADD FOREIGN KEY ("maintenance_id", "vehicle_id", "school_id") REFERENCES "maintenance" ("maintenance_id", "vehicle_id", "school_id") ON DELETE RESTRICT DEFERRABLE INITIALLY IMMEDIATE;
