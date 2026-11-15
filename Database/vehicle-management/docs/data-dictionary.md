# Vehicle Management — Data Dictionary

Current source: [vehicle-management.dbml](../schema/schema.dbml), SHA-256 `b7586af9ca126a51d30c08638debf5e1a0f523707a72b98b6c6c39f1baa634c6`. Current reviewed proposed model, not deployed service.

5 tables / 51 columns. This dictionary is an enriched source-derived specification, not a claim of deployed APIs. No cross-service FK.

Classification is conservative: even opaque identifiers/audit timestamps can be personal when linked. No legal retention duration or GDPR certification is inferred.

## vehicle

Operational training vehicle identity and eligibility-relevant state.

Source model note: Vehicle root. At least one supported category at creation and thereafter; insert root and nonempty children atomically. Revision advances on every eligibility-relevant root/child change and maintenance start/finish. Year range is a technical bound, not a legal rule. Activation requires current school/branch authority; handlers enforce. No hard delete, tenant/branch move, implicit future bookings or automatic reactivation.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| vehicle_id | uuid | NOT NULL; default none | PK(vehicle_id); UNIQUE(vehicle_id,school_id) | Stable identifier within vehicle ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| school_id | uuid | NOT NULL; default none | UNIQUE(vehicle_id,school_id); UNIQUE(school_id,registration_country_code,registration_number) | External tenant owner; immutable. Resolve BranchId in this school through School Management. | Scoped identifier; linkability/access control required |
| branch_id | uuid | NOT NULL; default none | Non-key attribute | External School Management ID. Immutable in MVP; transfer requires a separate design. | Scoped identifier; linkability/access control required |
| registration_country_code | varchar(2) | NOT NULL; default none | UNIQUE(school_id,registration_country_code,registration_number) | Registration country code belonging to vehicle; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| registration_number | varchar(32) | NOT NULL; default none | UNIQUE(school_id,registration_country_code,registration_number) | Canonical uppercase value; approved country-specific normalization is a handler responsibility. Not VIN. | Operational/configuration metadata; restricted if linked to a person |
| manufacturer | varchar(100) | NOT NULL; default none | Non-key attribute | Manufacturer belonging to vehicle; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| model | varchar(100) | NOT NULL; default none | Non-key attribute | Model belonging to vehicle; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| manufacture_year | smallint | NOT NULL; default none | Non-key attribute | Manufacture year belonging to vehicle; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| transmission | vm_transmission | NOT NULL; default none | Non-key attribute | Transmission belonging to vehicle; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| status | vm_vehicle_status | NOT NULL; default Inactive | Non-key attribute | Lifecycle/evaluation state of vehicle; enum/check vocabulary below; transition is not implied by a type alone. | Operational/configuration metadata; restricted if linked to a person |
| revision | bigint | NOT NULL; default 1 | Non-key attribute | Positive version of this vehicle consistency basis; handlers use exact expected revision/CAS, not CHECK alone. | Operational/configuration metadata; restricted if linked to a person |
| created_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded created instant for vehicle; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| updated_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded updated instant for vehicle; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(vehicle_id)`.
- UNIQUE `(vehicle_id, school_id)`.
- UNIQUE `(school_id, registration_country_code, registration_number)`.
- INDEX `(school_id, branch_id, status)`.

**Row CHECKs:**

- `registration_country_code ~ '^[A-Z]{2}$'` — vm_country_shape.
- `length(trim(registration_number)) > 0 AND registration_number = upper(trim(registration_number))` — vm_registration_shape.
- `length(trim(manufacturer)) > 0 AND length(trim(model)) > 0` — vm_details_nonblank.
- `manufacture_year BETWEEN 1886 AND 9999` — vm_year_storage_range.
- `revision > 0 AND updated_at >= created_at` — vm_revision_time.

**Lifecycle / immutable / audit:** Inactive/Active/UnderMaintenance; create Inactive, start maintenance ->UnderMaintenance, complete ->Inactive, never auto-reactivate.

Immutable design attributes: `vehicle_id`, `school_id`, `branch_id`, `created_at`.

## vehicle_supported_category

Vehicle-owned nonempty set of supported external licence-category codes.

Source model note: Vehicle-owned nonempty collection; no independent lifecycle or revision. Removing the last category is rejected for every status; creation and category edits lock/CAS the parent and advance Vehicle.Revision. Collection cardinality and catalogue validity are handler invariants, not row CHECKs.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| vehicle_id | uuid | NOT NULL; default none | PK(vehicle_id,school_id,category_code); local FK (vehicle_id,school_id) → vehicle(vehicle_id,school_id) | Stable identifier within vehicle_supported_category ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| school_id | uuid | NOT NULL; default none | PK(vehicle_id,school_id,category_code); local FK (vehicle_id,school_id) → vehicle(vehicle_id,school_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| category_code | varchar(16) | NOT NULL; default none | PK(vehicle_id,school_id,category_code) | External DrivingLicenseCategory code, checked against authoritative catalogue; not a new programme/category owner. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(vehicle_id, school_id, category_code)`.

**Row CHECKs:**

- `length(trim(category_code)) > 0 AND category_code = upper(trim(category_code))` — vm_category_shape.

**Lifecycle / immutable / audit:** See the current context contract and local SQL companion; service-only rules are not falsely certified by row CHECKs.

Immutable design attributes: `membership changes require parent CAS/revision`.

## vehicle_teacher_assignment

Current vehicle/instructor assignment under one exact School membership.

Source model note: Vehicle-owned current assignments, several teachers permitted. Verify active UserProfile, TeacherId-to-UserId binding and exact same-school Teacher membership/authority for the whole lesson interval. SchoolMembershipEnded invalidates matching membership-based assignments at effective end; cleanup removes only still-matching links under parent lock/CAS. Current source validation denies use even before cleanup. No auto-restoration on rejoin. Receipt is audit, not assignment history or reservation.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| vehicle_id | uuid | NOT NULL; default none | PK(vehicle_id,school_id,teacher_id); local FK (vehicle_id,school_id) → vehicle(vehicle_id,school_id) | Stable identifier within vehicle_teacher_assignment ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| school_id | uuid | NOT NULL; default none | PK(vehicle_id,school_id,teacher_id); local FK (vehicle_id,school_id) → vehicle(vehicle_id,school_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| teacher_id | uuid | NOT NULL; default none | PK(vehicle_id,school_id,teacher_id) | External User Management TeacherId; profile existence grants no school permission or qualification. | Pseudonymous personal/security identifier |
| school_membership_id | uuid | NOT NULL; default none | Non-key attribute | Logical reference to the exact School-owned Teacher membership authorizing this current assignment. No external FK. A later membership requires explicit reassignment. | Scoped identifier; linkability/access control required |
| assigned_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded assigned instant for vehicle_teacher_assignment; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(vehicle_id, school_id, teacher_id)`.
- INDEX `(school_id, teacher_id)`.
- INDEX `(school_id, school_membership_id)`.

**Row CHECKs:**

- No additional DBML row CHECK; enum/key/nullability and companion rules still apply.

**Lifecycle / immutable / audit:** See the current context contract and local SQL companion; service-only rules are not falsely certified by row CHECKs.

Immutable design attributes: `current assignment identity; replace/remove only by authorized parent transaction`.

## maintenance

Operational maintenance record with planned instant and actual lifecycle times.

Source model note: Maintenance root. Scheduled->InProgress->Completed; Scheduled->Cancelled. No cancellation after start. Start atomically sets Vehicle UnderMaintenance; finish sets Inactive. Lock vehicle first, maintenance second, check both expected revisions and no other InProgress record, then commit both roots and receipt together. Companion partial unique index enforces single InProgress row; it does not enforce matching vehicle status or allowed transitions. ScheduledAt is not a downtime interval.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| maintenance_id | uuid | NOT NULL; default none | PK(maintenance_id); UNIQUE(maintenance_id,vehicle_id,school_id) | Stable identifier within maintenance ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| school_id | uuid | NOT NULL; default none | UNIQUE(maintenance_id,vehicle_id,school_id); local FK (vehicle_id,school_id) → vehicle(vehicle_id,school_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| vehicle_id | uuid | NOT NULL; default none | UNIQUE(maintenance_id,vehicle_id,school_id); local FK (vehicle_id,school_id) → vehicle(vehicle_id,school_id) | Stable identifier within maintenance ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| type | vm_maintenance_type | NOT NULL; default none | Non-key attribute | Type belonging to maintenance; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| scheduled_at | timestamptz | NOT NULL; default none | Non-key attribute | Planned instant only; no duration/calendar blocking guarantee. | Operational/configuration metadata; restricted if linked to a person |
| started_at | timestamptz | NULL; default none | Non-key attribute | Recorded started instant for maintenance; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| completed_at | timestamptz | NULL; default none | Non-key attribute | Recorded completed instant for maintenance; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| cancelled_at | timestamptz | NULL; default none | Non-key attribute | Recorded cancelled instant for maintenance; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| status | vm_maintenance_status | NOT NULL; default Scheduled | Non-key attribute | Lifecycle/evaluation state of maintenance; enum/check vocabulary below; transition is not implied by a type alone. | Operational/configuration metadata; restricted if linked to a person |
| comment | text | NULL; default none | Non-key attribute | Comment belonging to maintenance; set by the owning application command/source contract, constrained below. | Restricted free text/document/payload; may contain personal data |
| revision | bigint | NOT NULL; default 1 | Non-key attribute | Positive version of this maintenance consistency basis; handlers use exact expected revision/CAS, not CHECK alone. | Operational/configuration metadata; restricted if linked to a person |
| created_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded created instant for maintenance; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| updated_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded updated instant for maintenance; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(maintenance_id)`.
- UNIQUE `(maintenance_id, vehicle_id, school_id)`.
- INDEX `(school_id, vehicle_id, status)`.

**Row CHECKs:**

- `revision > 0 AND updated_at >= created_at` — vm_maintenance_revision_time.
- `(status = 'Scheduled' AND started_at IS NULL AND completed_at IS NULL AND cancelled_at IS NULL) OR (status = 'InProgress' AND started_at IS NOT NULL AND completed_at IS NULL AND cancelled_at IS NULL) OR (status = 'Completed' AND started_at IS NOT NULL AND completed_at IS NOT NULL AND cancelled_at IS NULL) OR (status = 'Cancelled' AND started_at IS NULL AND completed_at IS NULL AND cancelled_at IS NOT NULL)` — vm_maintenance_lifecycle_shape.
- `(started_at IS NULL OR started_at >= created_at) AND (completed_at IS NULL OR completed_at >= started_at) AND (cancelled_at IS NULL OR cancelled_at >= created_at)` — vm_maintenance_time_order.
- `(started_at IS NULL OR updated_at >= started_at) AND (completed_at IS NULL OR updated_at >= completed_at) AND (cancelled_at IS NULL OR updated_at >= cancelled_at)` — vm_maintenance_updated_time.

**Lifecycle / immutable / audit:** Scheduled->InProgress->Completed or Scheduled->Cancelled; one InProgress per vehicle is companion SQL.

Immutable design attributes: `maintenance_id`, `vehicle_id`, `school_id`, `created_at`, `terminal lifecycle content per handlers`.

## vehicle_operation

Immutable successful command receipt committed with vehicle/maintenance mutation.

Source model note: Retained MVP successful-command receipt, not a domain root, event store, inbox, outbox or full before/after history. Mutation and immutable receipt commit together. Fingerprint covers versioned canonical command, all targets/changes, both expected revisions and source/confirmation basis. Compare fingerprint plus actor/service/school/channel/command/target and reauthorize retries before returning original result; never rerun against newer state. Serialize operation-ID claims; reject mismatched reuse. AddVehicle and new Maintenance have NULL expected revision for the created root; handlers enforce exact command shape. Maintenance-only planning may leave VehicleRevision unchanged. Rejected commands use security logs. Authentic exact MCP consent and audit immutability require handlers/privileges, not non-null fields.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| operation_id | uuid | NOT NULL; default none | PK(operation_id) | Stable identifier within vehicle_operation ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| school_id | uuid | NOT NULL; default none | local FK (vehicle_id,school_id) → vehicle(vehicle_id,school_id); local FK (maintenance_id,vehicle_id,school_id) → maintenance(maintenance_id,vehicle_id,school_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| vehicle_id | uuid | NOT NULL; default none | local FK (vehicle_id,school_id) → vehicle(vehicle_id,school_id); local FK (maintenance_id,vehicle_id,school_id) → maintenance(maintenance_id,vehicle_id,school_id) | Stable identifier within vehicle_operation ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| maintenance_id | uuid | NULL; default none | local FK (maintenance_id,vehicle_id,school_id) → maintenance(maintenance_id,vehicle_id,school_id) | Optional local maintenance target; composite FK preserves same vehicle and school. | Scoped identifier; linkability/access control required |
| actor_user_id | uuid | NULL; default none | Non-key attribute | External authenticated/delegated UserId for human commands, including MCP. | Pseudonymous personal/security identifier |
| actor_service | varchar(120) | NULL; default none | Non-key attribute | Authenticated service principal for automated internal cleanup; exclusive with actor_user_id. No fabricated human actor. | Operational/configuration metadata; restricted if linked to a person |
| channel | vm_channel | NOT NULL; default none | Non-key attribute | Channel belonging to vehicle_operation; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| command_name | varchar(80) | NOT NULL; default none | Non-key attribute | Command name belonging to vehicle_operation; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| request_fingerprint | varchar(64) | NOT NULL; default none | Non-key attribute | Request fingerprint belonging to vehicle_operation; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| expected_vehicle_revision | bigint | NULL; default none | Non-key attribute | Exact retained expected_vehicle_revision of referenced source/configuration; records provenance, not a permanent authorization permit. | Operational/configuration metadata; restricted if linked to a person |
| expected_maintenance_revision | bigint | NULL; default none | Non-key attribute | Exact retained expected_maintenance_revision of referenced source/configuration; records provenance, not a permanent authorization permit. | Operational/configuration metadata; restricted if linked to a person |
| resulting_vehicle_revision | bigint | NOT NULL; default none | Non-key attribute | Exact retained resulting_vehicle_revision of referenced source/configuration; records provenance, not a permanent authorization permit. | Operational/configuration metadata; restricted if linked to a person |
| resulting_maintenance_revision | bigint | NULL; default none | Non-key attribute | Exact retained resulting_maintenance_revision of referenced source/configuration; records provenance, not a permanent authorization permit. | Operational/configuration metadata; restricted if linked to a person |
| reason | text | NULL; default none | Non-key attribute | Reason belonging to vehicle_operation; set by the owning application command/source contract, constrained below. | Restricted free text/document/payload; may contain personal data |
| confirmation_id | uuid | NULL; default none | Non-key attribute | Stable identifier within vehicle_operation ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| confirmed_at | timestamptz | NULL; default none | Non-key attribute | Recorded confirmed instant for vehicle_operation; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| recorded_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded recorded instant for vehicle_operation; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(operation_id)`.
- INDEX `(school_id, vehicle_id, recorded_at)`.

**Row CHECKs:**

- `length(trim(command_name)) > 0 AND request_fingerprint ~ '^[0-9a-f]{64}$'` — vm_operation_shape.
- `(expected_vehicle_revision IS NULL OR expected_vehicle_revision > 0) AND resulting_vehicle_revision > 0 AND (resulting_maintenance_revision IS NULL OR resulting_maintenance_revision > 0)` — vm_operation_revisions.
- `(actor_user_id IS NOT NULL AND actor_service IS NULL) OR (actor_user_id IS NULL AND actor_service IS NOT NULL AND length(trim(actor_service)) > 0 AND channel = 'Internal')` — vm_operation_actor.
- `(maintenance_id IS NULL AND expected_maintenance_revision IS NULL AND resulting_maintenance_revision IS NULL) OR (maintenance_id IS NOT NULL AND resulting_maintenance_revision IS NOT NULL AND (expected_maintenance_revision IS NULL OR expected_maintenance_revision > 0))` — vm_operation_maintenance_shape.
- `(expected_vehicle_revision IS NULL OR resulting_vehicle_revision >= expected_vehicle_revision) AND (expected_maintenance_revision IS NULL OR resulting_maintenance_revision > expected_maintenance_revision)` — vm_operation_revision_order.
- `(confirmation_id IS NULL) = (confirmed_at IS NULL)` — vm_confirmation_pair.
- `channel <> 'MCP' OR confirmation_id IS NOT NULL` — vm_mcp_confirmation.
- `confirmed_at IS NULL OR confirmed_at <= recorded_at` — vm_confirmation_time.

**Lifecycle / immutable / audit:** See the current context contract and local SQL companion; service-only rules are not falsely certified by row CHECKs.

Immutable design attributes: `all successful receipt fields`.

## Enum vocabulary

- `vm_vehicle_status`: Active, Inactive, UnderMaintenance.
- `vm_transmission`: Manual, Automatic.
- `vm_maintenance_type`: Service, Repair, Inspection.
- `vm_maintenance_status`: Scheduled, InProgress, Completed, Cancelled.
- `vm_channel`: Web, MCP, Internal.

Supplemental partial indexes, exclusion/trigger/function rules and deployed CHECK definitions are recorded in [logical schema](logical-schema.md) and verification. External IDs are owner API references, not permission grants.
