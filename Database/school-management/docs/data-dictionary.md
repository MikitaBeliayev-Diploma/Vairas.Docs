# School Management — Data Dictionary

Current source: [school-management.dbml](../schema/schema.dbml), SHA-256 `232ac64951a27fb63ace9e2c50a9a42dcede5bb3cb624895b6cc88a18abe6e5f`. D-045 plus explicitly proposed Round 2 refinements.

13 tables / 137 columns. This dictionary is an enriched source-derived specification, not a claim of deployed APIs. No cross-service FK.

Classification is conservative: even opaque identifiers/audit timestamps can be personal when linked. No legal retention duration or GDPR certification is inferred.

## school

Driving-school tenant organization and eligibility revision.

Source model note: School is the tenant and aggregate root. Immutable ID. Provisioning authority is OPEN. No person/contact profile copies.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| school_id | uuid | NOT NULL; default none | PK(school_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| name | varchar(200) | NOT NULL; default none | Non-key attribute | Name of school; generated/validated by this context, not an external identity key. | Operational/configuration metadata; restricted if linked to a person |
| status | sm_status | NOT NULL; default Active | Non-key attribute | Lifecycle/evaluation state of school; enum/check vocabulary below; transition is not implied by a type alone. | Operational/configuration metadata; restricted if linked to a person |
| revision | bigint | NOT NULL; default 1 | Non-key attribute | Positive version of this school consistency basis; handlers use exact expected revision/CAS, not CHECK alone. | Operational/configuration metadata; restricted if linked to a person |
| created_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded created instant for school; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| updated_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded updated instant for school; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(school_id)`.

**Row CHECKs:**

- `length(trim(name)) > 0` — school_name_nonempty.
- `revision > 0 AND updated_at >= created_at` — school_revision_time.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `school_id`, `created_at`.

## school_operation

School-scoped immutable command binding and recoverable local operation outcome; records coordination status without implementing a remote gate.

Source model note: Infrastructure metadata, not another domain root. Within the same (SchoolId, OperationId), different actor/channel/command/target/canonical payload including expected revision must reject. Same OperationId in another independently authorized school is a separate key; no global unique OperationId is claimed. coordination_required operations serialize per school using the native partial index. Pending/ReconciliationPending with resulting_school_revision set means local changes recorded but operational eligibility reads remain blocked until Scheduling gate acknowledgment and local finalization; no automatic rollback or gate expiry. Gate ID is the same scoped operation ID; no extra workflow identity. Immutable command metadata; outcome progresses to one terminal result. No command replay payload, durable-delivery or atomic remote-commit guarantee. Rejected unauthorized/foreign-tenant probes go to restricted security audit without FK to foreign objects; no untrusted tenant-derived insert. Exact MCP consent/current policy is handler work.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| operation_id | uuid | NOT NULL; default none | PK(operation_id,school_id) | School-scoped idempotency key. Logical uniqueness is (SchoolId, OperationId); physical composite PK order is unchanged. Same UUID in another authorized school is independent. | Scoped identifier; linkability/access control required |
| school_id | uuid | NOT NULL; default none | PK(operation_id,school_id); local FK (school_id) → school(school_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| command_name | varchar(80) | NOT NULL; default none | Non-key attribute | Command name belonging to school_operation; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| target_kind | varchar(60) | NOT NULL; default none | Non-key attribute | Target kind belonging to school_operation; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| target_id | uuid | NOT NULL; default none | Non-key attribute | Stable identifier within school_operation ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| expected_revision | bigint | NULL; default none | Non-key attribute | Exact retained expected_revision of referenced source/configuration; records provenance, not a permanent authorization permit. | Operational/configuration metadata; restricted if linked to a person |
| resulting_revision | bigint | NULL; default none | Non-key attribute | Exact retained resulting_revision of referenced source/configuration; records provenance, not a permanent authorization permit. | Operational/configuration metadata; restricted if linked to a person |
| coordination_required | boolean | NOT NULL; default false | Non-key attribute | Coordination required belonging to school_operation; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| expected_school_revision | bigint | NULL; default none | Non-key attribute | Exact retained expected_school_revision of referenced source/configuration; records provenance, not a permanent authorization permit. | Operational/configuration metadata; restricted if linked to a person |
| resulting_school_revision | bigint | NULL; default none | Non-key attribute | Exact retained resulting_school_revision of referenced source/configuration; records provenance, not a permanent authorization permit. | Operational/configuration metadata; restricted if linked to a person |
| actor_user_id | uuid | NOT NULL; default none | Non-key attribute | External User Management reference; Internal requires accountable actor/service authority. | Pseudonymous personal/security identifier |
| channel | sm_channel | NOT NULL; default none | Non-key attribute | Channel belonging to school_operation; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| status | sm_operation_status | NOT NULL; default none | Non-key attribute | Lifecycle/evaluation state of school_operation; enum/check vocabulary below; transition is not implied by a type alone. | Operational/configuration metadata; restricted if linked to a person |
| request_fingerprint | varchar(64) | NOT NULL; default none | Non-key attribute | Server-computed exact canonical command digest; compare on retry. Not a saved command payload. | Operational/configuration metadata; restricted if linked to a person |
| requested_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded requested instant for school_operation; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| resolved_at | timestamptz | NULL; default none | Non-key attribute | Recorded resolved instant for school_operation; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| reason | text | NULL; default none | Non-key attribute | Reason belonging to school_operation; set by the owning application command/source contract, constrained below. | Restricted free text/document/payload; may contain personal data |
| outcome_code | varchar(80) | NULL; default none | Non-key attribute | Outcome code belonging to school_operation; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| authority_basis | varchar(200) | NOT NULL; default none | Non-key attribute | Restricted reference/version to checked server authorization basis, not a bearer token. | Operational/configuration metadata; restricted if linked to a person |
| confirmation_id | uuid | NULL; default none | Non-key attribute | Stable identifier within school_operation ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| confirmed_at | timestamptz | NULL; default none | Non-key attribute | Recorded confirmed instant for school_operation; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(operation_id, school_id)`.
- INDEX `(school_id, target_kind, target_id, requested_at)`.

**Row CHECKs:**

- `expected_revision IS NULL OR expected_revision > 0` — operation_expected_revision.
- `resulting_revision IS NULL OR resulting_revision > 0` — operation_result_revision.
- `(coordination_required = false AND expected_school_revision IS NULL AND resulting_school_revision IS NULL) OR (coordination_required = true AND expected_school_revision IS NOT NULL AND expected_school_revision > 0 AND (resulting_school_revision IS NULL OR resulting_school_revision = expected_school_revision + 1))` — operation_coordination_revisions.
- `status <> 'Committed' OR coordination_required = false OR resulting_school_revision IS NOT NULL` — operation_coordinated_commit.
- `(confirmation_id IS NULL) = (confirmed_at IS NULL)` — operation_confirmation_pair.
- `status <> 'Committed' OR channel <> 'MCP' OR confirmation_id IS NOT NULL` — operation_mcp_confirmation.
- `(status IN ('Committed','Rejected') AND resolved_at IS NOT NULL) OR (status IN ('Pending','ReconciliationPending') AND resolved_at IS NULL)` — operation_resolution_shape.
- `resolved_at IS NULL OR resolved_at >= requested_at` — operation_resolution_time.
- `length(trim(command_name)) > 0 AND length(trim(authority_basis)) > 0 AND length(request_fingerprint) = 64` — operation_required_metadata.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `school_id`.

## branch

One school-owned organizational location; addresses are organizational data, not copied person profiles.

Source model note: Branch root. Address structure is PROPOSED, not verified legal registration fields. SchoolId immutable; no cascade deletion.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| branch_id | uuid | NOT NULL; default none | PK(branch_id,school_id) | Stable identifier within branch ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| school_id | uuid | NOT NULL; default none | PK(branch_id,school_id); local FK (school_id) → school(school_id); local FK (last_operation_id,school_id) → school_operation(operation_id,school_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| name | varchar(200) | NOT NULL; default none | Non-key attribute | Name of branch; generated/validated by this context, not an external identity key. | Operational/configuration metadata; restricted if linked to a person |
| address_line | varchar(300) | NULL; default none | Non-key attribute | Address line belonging to branch; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| city | varchar(120) | NULL; default none | Non-key attribute | City belonging to branch; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| postal_code | varchar(30) | NULL; default none | Non-key attribute | Postal code belonging to branch; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| country_code | varchar(2) | NULL; default none | Non-key attribute | Country code belonging to branch; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| status | sm_status | NOT NULL; default Active | Non-key attribute | Lifecycle/evaluation state of branch; enum/check vocabulary below; transition is not implied by a type alone. | Operational/configuration metadata; restricted if linked to a person |
| revision | bigint | NOT NULL; default 1 | Non-key attribute | Positive version of this branch consistency basis; handlers use exact expected revision/CAS, not CHECK alone. | Operational/configuration metadata; restricted if linked to a person |
| last_operation_id | uuid | NOT NULL; default none | local FK (last_operation_id,school_id) → school_operation(operation_id,school_id) | Stable identifier within branch ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(branch_id, school_id)`.

**Row CHECKs:**

- `length(trim(name)) > 0 AND revision > 0` — branch_name_revision.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `school_id`.

## school_membership

One effective role period for one global user in one school; distinct roles and nonoverlapping rejoin periods coexist.

Source model note: Root; roles may coexist. Native EXCLUDE rejects overlapping same school/user/role periods, including concurrent first inserts and updates; use the companion SQL. Distinct roles may coexist. Parent/dependency serialization remains handler work. No uniqueness across StudentId/enrollments is implied.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| membership_id | uuid | NOT NULL; default none | PK(membership_id,school_id) | Stable identifier within school_membership ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| school_id | uuid | NOT NULL; default none | PK(membership_id,school_id); local FK (school_id) → school(school_id); local FK (last_operation_id,school_id) → school_operation(operation_id,school_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| user_id | uuid | NOT NULL; default none | Non-key attribute | Logical user_id owned by User Management; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Pseudonymous personal/security identifier |
| role | sm_role | NOT NULL; default none | Non-key attribute | Role belonging to school_membership; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| started_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded started instant for school_membership; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| ended_at | timestamptz | NULL; default none | Non-key attribute | Recorded ended instant for school_membership; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| revision | bigint | NOT NULL; default 1 | Non-key attribute | Positive version of this school_membership consistency basis; handlers use exact expected revision/CAS, not CHECK alone. | Operational/configuration metadata; restricted if linked to a person |
| last_operation_id | uuid | NOT NULL; default none | local FK (last_operation_id,school_id) → school_operation(operation_id,school_id) | Stable identifier within school_membership ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(membership_id, school_id)`.
- INDEX `(school_id, user_id, role, started_at)`.

**Row CHECKs:**

- `ended_at IS NULL OR ended_at > started_at` — membership_period.
- `revision > 0` — membership_revision.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `school_id`.

## membership_permission_grant

Effective Assessor/SchoolRuleOwner permission period within a specific school membership; not proof of legal qualification.

Source model note: SchoolMembership child. Native EXCLUDE prevents duplicate overlapping same-membership/permission periods. Parent period containment and grants across distinct roles remain handler/policy work. Grant/revoke actor from operation. Assessor/SchoolRuleOwner grant-management policy remains OPEN; onboarding/bootstrap invitations use D-045, not these grants. Ending membership closes grants and coordinates readiness invalidation. Grants never infer legal qualification.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| grant_id | uuid | NOT NULL; default none | PK(grant_id,school_id) | Stable identifier within membership_permission_grant ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| school_id | uuid | NOT NULL; default none | PK(grant_id,school_id); local FK (membership_id,school_id) → school_membership(membership_id,school_id); local FK (granted_operation_id,school_id) → school_operation(operation_id,school_id); local FK (ended_operation_id,school_id) → school_operation(operation_id,school_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| membership_id | uuid | NOT NULL; default none | local FK (membership_id,school_id) → school_membership(membership_id,school_id) | Stable identifier within membership_permission_grant ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| permission | sm_permission | NOT NULL; default none | Non-key attribute | Permission belonging to membership_permission_grant; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| started_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded started instant for membership_permission_grant; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| ended_at | timestamptz | NULL; default none | Non-key attribute | Recorded ended instant for membership_permission_grant; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| granted_operation_id | uuid | NOT NULL; default none | local FK (granted_operation_id,school_id) → school_operation(operation_id,school_id) | Stable identifier within membership_permission_grant ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| ended_operation_id | uuid | NULL; default none | local FK (ended_operation_id,school_id) → school_operation(operation_id,school_id) | Stable identifier within membership_permission_grant ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(grant_id, school_id)`.
- INDEX `(membership_id, school_id, permission, started_at)`.

**Row CHECKs:**

- `ended_at IS NULL OR ended_at > started_at` — grant_period.
- `(ended_at IS NULL) = (ended_operation_id IS NULL)` — grant_end_evidence.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `school_id`.

## student_enrollment

School/category training relationship and lifecycle history for an externally identified student; no curriculum version or progress ownership.

Source model note: Root; concurrent enrollments allowed, including same category by default. No current programme/version, hours or progress column: assignment belongs to Learning Tracking. Category validity externally verified, not a legal category list invented here. Completed requires current external completion evidence. Round 2 Option A: immediate terminal transitions only. Server chooses one t_close inside local apply; ended_at=status_changed_at=t_close; same instant in history. Pending coordinated activation denies operational reads until acknowledgment. No future/backdated close or arbitrary status edits. Defaults/row CHECKs do not stop a privileged writer forging timestamps; trusted handler rejects client effective-time input and verifies the DB clock.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| enrollment_id | uuid | NOT NULL; default none | PK(enrollment_id,school_id); UNIQUE(enrollment_id) | Stable identifier within student_enrollment ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| school_id | uuid | NOT NULL; default none | PK(enrollment_id,school_id); local FK (school_id) → school(school_id); local FK (last_operation_id,school_id) → school_operation(operation_id,school_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| student_id | uuid | NOT NULL; default none | Non-key attribute | External stable User Management StudentId, validated through authorized owner API. | Pseudonymous personal/security identifier |
| category_code | varchar(20) | NOT NULL; default none | Non-key attribute | Category token whose authoritative catalogue remains an external OPEN decision; DEMO fixture is not a real legal category. | Operational/configuration metadata; restricted if linked to a person |
| started_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded started instant for student_enrollment; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| ended_at | timestamptz | NULL; default none | Non-key attribute | Recorded ended instant for student_enrollment; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| status | sm_enrollment_status | NOT NULL; default Active | Non-key attribute | Lifecycle/evaluation state of student_enrollment; enum/check vocabulary below; transition is not implied by a type alone. | Operational/configuration metadata; restricted if linked to a person |
| status_changed_at | timestamptz | NOT NULL; default clock_timestamp() | Non-key attribute | Server-chosen immediate lifecycle recording instant; terminal ended_at must equal it. | Operational/configuration metadata; restricted if linked to a person |
| revision | bigint | NOT NULL; default 1 | Non-key attribute | Positive version of this student_enrollment consistency basis; handlers use exact expected revision/CAS, not CHECK alone. | Operational/configuration metadata; restricted if linked to a person |
| last_operation_id | uuid | NOT NULL; default none | local FK (last_operation_id,school_id) → school_operation(operation_id,school_id) | Stable identifier within student_enrollment ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(enrollment_id, school_id)`.
- UNIQUE `(enrollment_id)`.
- INDEX `(school_id, student_id, status)`.

**Row CHECKs:**

- `length(trim(category_code)) > 0 AND revision > 0` — enrollment_category_revision.
- `ended_at IS NULL OR ended_at > started_at` — enrollment_period.
- `isfinite(started_at) AND isfinite(status_changed_at) AND (ended_at IS NULL OR isfinite(ended_at))` — enrollment_finite_lifecycle.
- `(status = 'Active' AND ended_at IS NULL) OR (status <> 'Active' AND ended_at IS NOT NULL AND ended_at = status_changed_at)` — enrollment_lifecycle_shape.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `school_id`.

## enrollment_status_history

Append-only creation/termination evidence for one exact enrollment revision and server-recorded immediate effective time.

Source model note: Append-only transition evidence. Record creation and every lifecycle transition; actor/time/reason via immutable operation. Creation row records initial Active basis; terminal history effective_at=recorded_at=current ended_at=status_changed_at from the same server t_close. Current row/history status/revision coherence and fresh authorized completion basis require the same handler transaction and external validation. No scheduled transition queue or future effective termination. No enrollment credit is stored.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| enrollment_id | uuid | NOT NULL; default none | PK(enrollment_id,school_id,enrollment_revision); local FK (enrollment_id,school_id) → student_enrollment(enrollment_id,school_id) | Stable identifier within enrollment_status_history ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| school_id | uuid | NOT NULL; default none | PK(enrollment_id,school_id,enrollment_revision); local FK (enrollment_id,school_id) → student_enrollment(enrollment_id,school_id); local FK (operation_id,school_id) → school_operation(operation_id,school_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| enrollment_revision | bigint | NOT NULL; default none | PK(enrollment_id,school_id,enrollment_revision) | Exact retained enrollment_revision of referenced source/configuration; records provenance, not a permanent authorization permit. | Operational/configuration metadata; restricted if linked to a person |
| from_status | sm_enrollment_status | NULL; default none | Non-key attribute | From status belonging to enrollment_status_history; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| to_status | sm_enrollment_status | NOT NULL; default none | Non-key attribute | To status belonging to enrollment_status_history; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| effective_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded effective instant for enrollment_status_history; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| recorded_at | timestamptz | NOT NULL; default clock_timestamp() | Non-key attribute | Recorded recorded instant for enrollment_status_history; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| operation_id | uuid | NOT NULL; default none | local FK (operation_id,school_id) → school_operation(operation_id,school_id) | Stable identifier within enrollment_status_history ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| completion_evidence_id | uuid | NULL; default none | Non-key attribute | External LT training evidence snapshot ID; required for Completed. | Scoped identifier; linkability/access control required |
| completion_dependency_revision | bigint | NULL; default none | Non-key attribute | Ordered temporal bound for enrollment_status_history under the authoritative source/period contract. | Operational/configuration metadata; restricted if linked to a person |
| completion_verified_at | timestamptz | NULL; default none | Non-key attribute | Recorded completion verified instant for enrollment_status_history; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(enrollment_id, school_id, enrollment_revision)`.

**Row CHECKs:**

- `enrollment_revision > 0` — enrollment_history_revision.
- `isfinite(effective_at) AND isfinite(recorded_at) AND (to_status = 'Active' OR effective_at = recorded_at)` — enrollment_history_immediate_terminal.
- `(from_status IS NULL AND to_status = 'Active') OR (from_status IS NOT NULL AND from_status = 'Active' AND to_status <> 'Active')` — enrollment_history_transition.
- `to_status <> 'Completed' OR (completion_evidence_id IS NOT NULL AND completion_dependency_revision IS NOT NULL AND completion_dependency_revision > 0 AND completion_verified_at IS NOT NULL)` — completion_basis_required.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `school_id`.

## training_group

School training-group organization and current roster-revision pointer; no programme ownership.

Source model note: Root. Branch/category optional. No programme ownership. membership_revision selects immutable full period-set basis; relevant roster still filtered for concrete lesson interval. Initial empty basis required by handler.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| group_id | uuid | NOT NULL; default none | PK(group_id,school_id) | Stable identifier within training_group ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| school_id | uuid | NOT NULL; default none | PK(group_id,school_id); local FK (school_id) → school(school_id); local FK (branch_id,school_id) → branch(branch_id,school_id); local FK (last_operation_id,school_id) → school_operation(operation_id,school_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| branch_id | uuid | NULL; default none | local FK (branch_id,school_id) → branch(branch_id,school_id) | Stable identifier within training_group ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| name | varchar(200) | NOT NULL; default none | Non-key attribute | Name of training_group; generated/validated by this context, not an external identity key. | Operational/configuration metadata; restricted if linked to a person |
| category_code | varchar(20) | NULL; default none | Non-key attribute | Category code belonging to training_group; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| started_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded started instant for training_group; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| ended_at | timestamptz | NULL; default none | Non-key attribute | Recorded ended instant for training_group; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| revision | bigint | NOT NULL; default 1 | Non-key attribute | Positive version of this training_group consistency basis; handlers use exact expected revision/CAS, not CHECK alone. | Operational/configuration metadata; restricted if linked to a person |
| membership_revision | bigint | NOT NULL; default 1 | Non-key attribute | Exact retained membership_revision of referenced source/configuration; records provenance, not a permanent authorization permit. | Operational/configuration metadata; restricted if linked to a person |
| last_operation_id | uuid | NOT NULL; default none | local FK (last_operation_id,school_id) → school_operation(operation_id,school_id) | Stable identifier within training_group ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(group_id, school_id)`.

**Row CHECKs:**

- `length(trim(name)) > 0 AND revision > 0 AND membership_revision > 0` — group_name_revisions.
- `ended_at IS NULL OR ended_at > started_at` — group_period.
- `category_code IS NULL OR length(trim(category_code)) > 0` — group_optional_category.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `school_id`.

## student_group_membership

Time-bounded enrollment-to-group association with verified historical pinned-programme basis.

Source model note: Root. Many simultaneous groups per enrollment. Rejoin creates new ID. Native EXCLUDE prevents duplicate enrollment/group period overlap. Same-school category/period containment and current pinned programme basis require handlers. No LT assignment ID/dependency revision is required by D-042. OPEN-GATE-01: target-aware AC-101 protocol is specified, but D-044 does not yet provide verified durable gate/floor/recovery integration. Association cannot activate on a prior availability read; unsupported integration rejects before effects,202 requires a real durable pending operation.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| membership_id | uuid | NOT NULL; default none | PK(membership_id,school_id); UNIQUE(membership_id,school_id,group_id,enrollment_id) | Stable identifier within student_group_membership ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| school_id | uuid | NOT NULL; default none | PK(membership_id,school_id); UNIQUE(membership_id,school_id,group_id,enrollment_id); local FK (enrollment_id,school_id) → student_enrollment(enrollment_id,school_id); local FK (group_id,school_id) → training_group(group_id,school_id); local FK (last_operation_id,school_id) → school_operation(operation_id,school_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| enrollment_id | uuid | NOT NULL; default none | UNIQUE(membership_id,school_id,group_id,enrollment_id); local FK (enrollment_id,school_id) → student_enrollment(enrollment_id,school_id) | Stable identifier within student_group_membership ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| group_id | uuid | NOT NULL; default none | UNIQUE(membership_id,school_id,group_id,enrollment_id); local FK (group_id,school_id) → training_group(group_id,school_id) | Stable identifier within student_group_membership ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| joined_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded joined instant for student_group_membership; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| left_at | timestamptz | NULL; default none | Non-key attribute | Recorded left instant for student_group_membership; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| association_program_version_id | uuid | NOT NULL; default none | Non-key attribute | Historical AC-004 evidence of the LT StudentTraining.program_version_id pinned for this EnrollmentId (D-042); no assignment identity or current programme ownership. | Scoped identifier; linkability/access control required |
| association_verified_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded association verified instant for student_group_membership; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| revision | bigint | NOT NULL; default 1 | Non-key attribute | Positive version of this student_group_membership consistency basis; handlers use exact expected revision/CAS, not CHECK alone. | Operational/configuration metadata; restricted if linked to a person |
| last_operation_id | uuid | NOT NULL; default none | local FK (last_operation_id,school_id) → school_operation(operation_id,school_id) | Stable identifier within student_group_membership ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(membership_id, school_id)`.
- UNIQUE `(membership_id, school_id, group_id, enrollment_id)`.
- INDEX `(school_id, group_id, joined_at)`.
- INDEX `(school_id, enrollment_id, joined_at)`.

**Row CHECKs:**

- `left_at IS NULL OR left_at > joined_at` — student_group_period.
- `revision > 0` — association_revision.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `school_id`.

## teacher_group_assignment

Time-bounded instructor-to-group assignment; lesson assignment/availability remains Scheduling-owned.

Source model note: Root. Verify teacher/user identity and effective school Teacher membership. No implied Assessor right, qualification or automatic lesson assignment. Native EXCLUDE rejects duplicate overlapping same-teacher/group periods; User/Teacher status and membership containment require handlers.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| assignment_id | uuid | NOT NULL; default none | PK(assignment_id,school_id) | Stable identifier within teacher_group_assignment ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| school_id | uuid | NOT NULL; default none | PK(assignment_id,school_id); local FK (group_id,school_id) → training_group(group_id,school_id); local FK (last_operation_id,school_id) → school_operation(operation_id,school_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| teacher_id | uuid | NOT NULL; default none | Non-key attribute | External User Management TeacherId. | Pseudonymous personal/security identifier |
| group_id | uuid | NOT NULL; default none | local FK (group_id,school_id) → training_group(group_id,school_id) | Stable identifier within teacher_group_assignment ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| assigned_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded assigned instant for teacher_group_assignment; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| ended_at | timestamptz | NULL; default none | Non-key attribute | Recorded ended instant for teacher_group_assignment; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| revision | bigint | NOT NULL; default 1 | Non-key attribute | Positive version of this teacher_group_assignment consistency basis; handlers use exact expected revision/CAS, not CHECK alone. | Operational/configuration metadata; restricted if linked to a person |
| last_operation_id | uuid | NOT NULL; default none | local FK (last_operation_id,school_id) → school_operation(operation_id,school_id) | Stable identifier within teacher_group_assignment ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(assignment_id, school_id)`.
- INDEX `(school_id, group_id, assigned_at)`.
- INDEX `(school_id, teacher_id, assigned_at)`.

**Row CHECKs:**

- `ended_at IS NULL OR ended_at > assigned_at` — teacher_assignment_period.
- `revision > 0` — teacher_assignment_revision.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `school_id`.

## group_roster_revision

Immutable full group-member period-set revision, including empty revisions.

Source model note: Immutable full membership-period-set revision, including empty roster. Append with group membership_revision in same transaction; no mutable current-participants counter. Consumers filter members for exact lesson interval; this is not a lesson roster or actual attendance.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| group_id | uuid | NOT NULL; default none | PK(group_id,school_id,membership_revision); local FK (group_id,school_id) → training_group(group_id,school_id) | Stable identifier within group_roster_revision ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| school_id | uuid | NOT NULL; default none | PK(group_id,school_id,membership_revision); local FK (group_id,school_id) → training_group(group_id,school_id); local FK (operation_id,school_id) → school_operation(operation_id,school_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| membership_revision | bigint | NOT NULL; default none | PK(group_id,school_id,membership_revision) | Exact retained membership_revision of referenced source/configuration; records provenance, not a permanent authorization permit. | Operational/configuration metadata; restricted if linked to a person |
| recorded_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded recorded instant for group_roster_revision; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| operation_id | uuid | NOT NULL; default none | local FK (operation_id,school_id) → school_operation(operation_id,school_id) | Stable identifier within group_roster_revision ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(group_id, school_id, membership_revision)`.

**Row CHECKs:**

- `membership_revision > 0` — roster_revision_positive.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `school_id`.

## group_roster_member

Immutable member/source-enrollment facts captured inside one organizational roster revision; not current learner or calendar authority.

Source model note: Immutable evidence of member periods and source enrollment state at revision; later termination never rewrites old basis. Membership composite FK prevents wrong group/enrollment linking. Handler verifies StudentId/category match exact enrollment revision. Snapshot is organizational evidence, not the complete authorization basis. Scheduling must additionally freeze exact membership, identity and eligibility references from the checked contract. No programme duplication: LT pinned programme resolved separately. Scheduled participant snapshot belongs to Scheduling.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| group_id | uuid | NOT NULL; default none | PK(group_id,school_id,membership_revision,membership_id); local FK (group_id,school_id,membership_revision) → group_roster_revision(group_id,school_id,membership_revision); local FK (membership_id,school_id,group_id,enrollment_id) → student_group_membership(membership_id,school_id,group_id,enrollment_id) | Stable identifier within group_roster_member ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| school_id | uuid | NOT NULL; default none | PK(group_id,school_id,membership_revision,membership_id); local FK (group_id,school_id,membership_revision) → group_roster_revision(group_id,school_id,membership_revision); local FK (membership_id,school_id,group_id,enrollment_id) → student_group_membership(membership_id,school_id,group_id,enrollment_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| membership_revision | bigint | NOT NULL; default none | PK(group_id,school_id,membership_revision,membership_id); local FK (group_id,school_id,membership_revision) → group_roster_revision(group_id,school_id,membership_revision) | Exact retained membership_revision of referenced source/configuration; records provenance, not a permanent authorization permit. | Operational/configuration metadata; restricted if linked to a person |
| membership_id | uuid | NOT NULL; default none | PK(group_id,school_id,membership_revision,membership_id); local FK (membership_id,school_id,group_id,enrollment_id) → student_group_membership(membership_id,school_id,group_id,enrollment_id) | Stable identifier within group_roster_member ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| enrollment_id | uuid | NOT NULL; default none | local FK (membership_id,school_id,group_id,enrollment_id) → student_group_membership(membership_id,school_id,group_id,enrollment_id) | Stable identifier within group_roster_member ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| student_id | uuid | NOT NULL; default none | Non-key attribute | Logical student_id owned by User Management; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Pseudonymous personal/security identifier |
| enrollment_revision | bigint | NOT NULL; default none | Non-key attribute | Exact retained enrollment_revision of referenced source/configuration; records provenance, not a permanent authorization permit. | Operational/configuration metadata; restricted if linked to a person |
| enrollment_status | sm_enrollment_status | NOT NULL; default none | Non-key attribute | Enrollment status belonging to group_roster_member; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| category_code | varchar(20) | NOT NULL; default none | Non-key attribute | Category code belonging to group_roster_member; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| enrollment_started_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded enrollment started instant for group_roster_member; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| enrollment_ended_at | timestamptz | NULL; default none | Non-key attribute | Recorded enrollment ended instant for group_roster_member; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| joined_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded joined instant for group_roster_member; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| left_at | timestamptz | NULL; default none | Non-key attribute | Recorded left instant for group_roster_member; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(group_id, school_id, membership_revision, membership_id)`.

**Row CHECKs:**

- `enrollment_revision > 0 AND length(trim(category_code)) > 0` — roster_enrollment_basis.
- `left_at IS NULL OR left_at > joined_at` — roster_membership_period.
- `enrollment_ended_at IS NULL OR enrollment_ended_at > enrollment_started_at` — roster_enrollment_period.
- `(enrollment_status = 'Active' AND enrollment_ended_at IS NULL) OR (enrollment_status <> 'Active' AND enrollment_ended_at IS NOT NULL)` — roster_enrollment_shape.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `school_id`.

## school_invitation

School-owned fixed-target onboarding invitation child, with exact issuer and accepted/revoked result references.

Source model note: D-045: one necessary School-owned onboarding entity, child of School, not a new root/service. InvitationId is not a bearer secret; only the authenticated target may accept. Status Pending with now >= expires_at is derived Expired/unusable. Immutable target/role/category/issuer/expiry; reissue a new invitation instead of editing them. Issuer actor comes from issued_operation. Application checks exact target, current issuer authority/status, category, result binding and state transitions. Accepted plus resulting rows and operation local result commit together; specified eligibility gate, once actually supported, may keep that result Pending/ReconciliationPending with no operational success until final acknowledgment. New enrollment/effective membership needs coordination; unchanged staff membership reuse is local. OPEN-GATE-01 is not implemented by this table; no fake202/ack is allowed. Reject/revoke races serialize under School then invitation row lock. SQL CHECKs do not implement access policy, expiry-at-now, outcome recovery or global status admission.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| invitation_id | uuid | NOT NULL; default none | PK(invitation_id,school_id) | Stable identifier within school_invitation ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| school_id | uuid | NOT NULL; default none | PK(invitation_id,school_id); UNIQUE(issued_operation_id,school_id); UNIQUE(accepted_operation_id,school_id); UNIQUE(revoked_operation_id,school_id); local FK (school_id) → school(school_id); local FK (issuer_membership_id,school_id) → school_membership(membership_id,school_id); local FK (issued_operation_id,school_id) → school_operation(operation_id,school_id); local FK (accepted_operation_id,school_id) → school_operation(operation_id,school_id); local FK (revoked_operation_id,school_id) → school_operation(operation_id,school_id); local FK (result_membership_id,school_id) → school_membership(membership_id,school_id); local FK (result_enrollment_id,school_id) → student_enrollment(enrollment_id,school_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| target_user_id | uuid | NOT NULL; default none | Non-key attribute | External existing User Management UserId; immutable target, never an email/name match. | Pseudonymous personal/security identifier |
| role | sm_role | NOT NULL; default none | Non-key attribute | Role belonging to school_invitation; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| category_code | varchar(20) | NULL; default none | Non-key attribute | Required only for Student admission; does not own the category catalogue. | Operational/configuration metadata; restricted if linked to a person |
| issuer_membership_id | uuid | NULL; default none | local FK (issuer_membership_id,school_id) → school_membership(membership_id,school_id) | Current school Administrator membership for school-issued Student/Teacher invitations; NULL only for deployment-configured platform operator. | Scoped identifier; linkability/access control required |
| status | sm_invitation_status | NOT NULL; default Pending | Non-key attribute | Lifecycle/evaluation state of school_invitation; enum/check vocabulary below; transition is not implied by a type alone. | Operational/configuration metadata; restricted if linked to a person |
| revision | bigint | NOT NULL; default 1 | Non-key attribute | Positive version of this school_invitation consistency basis; handlers use exact expected revision/CAS, not CHECK alone. | Operational/configuration metadata; restricted if linked to a person |
| created_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded created instant for school_invitation; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| expires_at | timestamptz | NOT NULL; default none | Non-key attribute | Server sets created_at + 24 hours in the selected MVP; expiry is checked at use, no cron transition needed. | Operational/configuration metadata; restricted if linked to a person |
| issued_operation_id | uuid | NOT NULL; default none | UNIQUE(issued_operation_id,school_id); local FK (issued_operation_id,school_id) → school_operation(operation_id,school_id) | Stable identifier within school_invitation ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| accepted_operation_id | uuid | NULL; default none | UNIQUE(accepted_operation_id,school_id); local FK (accepted_operation_id,school_id) → school_operation(operation_id,school_id) | Stable identifier within school_invitation ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| accepted_at | timestamptz | NULL; default none | Non-key attribute | Recorded accepted instant for school_invitation; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| result_membership_id | uuid | NULL; default none | local FK (result_membership_id,school_id) → school_membership(membership_id,school_id) | Stable identifier within school_invitation ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| result_enrollment_id | uuid | NULL; default none | local FK (result_enrollment_id,school_id) → student_enrollment(enrollment_id,school_id) | Stable identifier within school_invitation ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| revoked_operation_id | uuid | NULL; default none | UNIQUE(revoked_operation_id,school_id); local FK (revoked_operation_id,school_id) → school_operation(operation_id,school_id) | Stable identifier within school_invitation ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| revoked_at | timestamptz | NULL; default none | Non-key attribute | Recorded revoked instant for school_invitation; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(invitation_id, school_id)`.
- UNIQUE `(issued_operation_id, school_id)`.
- UNIQUE `(accepted_operation_id, school_id)`.
- UNIQUE `(revoked_operation_id, school_id)`.
- INDEX `(school_id, target_user_id, status, expires_at)`.

**Row CHECKs:**

- `revision > 0 AND isfinite(created_at) AND isfinite(expires_at) AND expires_at > created_at` — invitation_revision_expiry.
- `(role = 'Student' AND category_code IS NOT NULL AND length(trim(category_code)) > 0) OR (role <> 'Student' AND category_code IS NULL)` — invitation_category_shape.
- `role <> 'Administrator' OR issuer_membership_id IS NULL` — invitation_admin_platform_basis.
- `(status = 'Pending' AND accepted_operation_id IS NULL AND accepted_at IS NULL AND result_membership_id IS NULL AND result_enrollment_id IS NULL AND revoked_operation_id IS NULL AND revoked_at IS NULL) OR (status = 'Accepted' AND accepted_operation_id IS NOT NULL AND accepted_at IS NOT NULL AND result_membership_id IS NOT NULL AND revoked_operation_id IS NULL AND revoked_at IS NULL AND ((role = 'Student' AND result_enrollment_id IS NOT NULL) OR (role <> 'Student' AND result_enrollment_id IS NULL))) OR (status = 'Revoked' AND revoked_operation_id IS NOT NULL AND revoked_at IS NOT NULL AND accepted_operation_id IS NULL AND accepted_at IS NULL AND result_membership_id IS NULL AND result_enrollment_id IS NULL)` — invitation_state_shape.
- `accepted_at IS NULL OR (isfinite(accepted_at) AND accepted_at >= created_at AND accepted_at < expires_at)` — invitation_accept_time.
- `revoked_at IS NULL OR (isfinite(revoked_at) AND revoked_at >= created_at)` — invitation_revoke_time.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `school_id`, `created_at`.

## Enum vocabulary

- `sm_status`: Active, Inactive.
- `sm_role`: Student, Teacher, Administrator.
- `sm_permission`: Assessor, SchoolRuleOwner.
- `sm_enrollment_status`: Active, Completed, Withdrawn, Transferred, Cancelled.
- `sm_operation_status`: Pending, Committed, Rejected, ReconciliationPending.
- `sm_channel`: Web, MCP, Internal.
- `sm_invitation_status`: Pending, Accepted, Revoked.

Supplemental partial indexes, exclusion/trigger/function rules and deployed CHECK definitions are recorded in [logical schema](logical-schema.md) and verification. External IDs are owner API references, not permission grants.
