# User Management — Data Dictionary

Current source: [user-management.dbml](../schema/schema.dbml), SHA-256 `1eced6a31d159393db9c06dcbd3a3987e62cfc17de2a26094bde7d81f9598699`. D-043 / D-045 global profiles.

5 tables / 37 columns. This dictionary is an enriched source-derived specification, not a claim of deployed APIs. No cross-service FK.

Classification is conservative: even opaque identifiers/audit timestamps can be personal when linked. No legal retention duration or GDPR certification is inferred.

## user_profile

Global account-linked personal profile and Active/Inactive operational admission state; no tenant memberships or login credentials.

Source model note: UserProfile root. Active/Inactive is global account-linked operational status, not physical identity verification or a school membership. Ordinary edits cannot change IDs/binding/status. D-045 global deactivation requires an active deployment-allowlisted platform operator; school exclusion remains School Management. History retained. No public hard delete or account rebind in MVP.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| user_id | uuid | NOT NULL; default none | PK(user_id) | Stable identifier within user_profile ownership/relationship; source is the local aggregate unless explicitly marked external. | Pseudonymous personal/security identifier |
| identity_id | uuid | NOT NULL; default none | UNIQUE(identity_id) | External Authentication IdentityId from validated JWT subject resolution; not UserId. | Pseudonymous personal/security identifier |
| first_name | varchar(100) | NOT NULL; default none | Non-key attribute | First name belonging to user_profile; set by the owning application command/source contract, constrained below. | Personal/contact |
| last_name | varchar(100) | NOT NULL; default none | Non-key attribute | Last name belonging to user_profile; set by the owning application command/source contract, constrained below. | Personal/contact |
| email_address | varchar(254) | NULL; default none | Non-key attribute | Optional nonunique business contact, not Authentication login email. | Personal/contact |
| phone_number | varchar(32) | NULL; default none | Non-key attribute | Optional contact; not identity proof. | Personal/contact |
| status | um_user_status | NOT NULL; default Active | Non-key attribute | Global Active/Inactive admission, independent of school membership/security Enabled/Disabled. | Operational/configuration metadata; restricted if linked to a person |
| revision | bigint | NOT NULL; default 1 | Non-key attribute | Positive version of this user_profile consistency basis; handlers use exact expected revision/CAS, not CHECK alone. | Operational/configuration metadata; restricted if linked to a person |
| created_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded created instant for user_profile; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| updated_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded updated instant for user_profile; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(user_id)`.
- UNIQUE `(identity_id)`.

**Row CHECKs:**

- `length(trim(first_name)) > 0 AND length(trim(last_name)) > 0` — um_nonblank_name.
- `email_address IS NULL OR length(trim(email_address)) > 0` — um_nonblank_email.
- `phone_number IS NULL OR length(trim(phone_number)) > 0` — um_nonblank_phone.
- `revision > 0 AND updated_at >= created_at` — um_profile_revision_time.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `user_id`, `created_at`.

## student_profile

Stable student identity for one existing global user, reused across all school enrollments; no physical-person deduplication.

Source model note: StudentProfile root; immutable ID/UserId binding, one per user. No identity-verification state, redirect or merge. Multiple accounts for the same physical person may still create duplicates; uniqueness proves only one StudentProfile per UserProfile. No mutable student fields, so no redundant revision token.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| student_id | uuid | NOT NULL; default none | PK(student_id) | Existing stable User Management ID, D-032; never regenerated for a new school. | Pseudonymous personal/security identifier |
| user_id | uuid | NOT NULL; default none | UNIQUE(user_id); local FK (user_id) → user_profile(user_id) | Stable identifier within student_profile ownership/relationship; source is the local aggregate unless explicitly marked external. | Pseudonymous personal/security identifier |
| created_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded created instant for student_profile; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(student_id)`.
- UNIQUE `(user_id)`.

**Row CHECKs:**

- No additional DBML row CHECK; enum/key/nullability and companion rules still apply.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `student_id`, `created_at`.

## teacher_profile

Stable instructor role-profile binding; a profile alone confers neither school authority nor qualifications.

Source model note: TeacherProfile root. Created by target self with a current school-authorized Teacher onboarding invitation. Immutable binding; not qualification, school membership, assignment or Assessor permission. Global status comes from UserProfile.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| teacher_id | uuid | NOT NULL; default none | PK(teacher_id) | Stable identifier within teacher_profile ownership/relationship; source is the local aggregate unless explicitly marked external. | Pseudonymous personal/security identifier |
| user_id | uuid | NOT NULL; default none | UNIQUE(user_id); local FK (user_id) → user_profile(user_id) | Stable identifier within teacher_profile ownership/relationship; source is the local aggregate unless explicitly marked external. | Pseudonymous personal/security identifier |
| created_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded created instant for teacher_profile; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(teacher_id)`.
- UNIQUE `(user_id)`.

**Row CHECKs:**

- No additional DBML row CHECK; enum/key/nullability and companion rules still apply.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `teacher_id`, `created_at`.

## administrator_profile

Stable administrator role-profile binding; not a school/global permission grant.

Source model note: AdministratorProfile root. Target accepts explicitly authorized school-admin onboarding; first administrator uses a trusted platform bootstrap operation. Immutable binding; existence grants no school or global platform permission.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| administrator_id | uuid | NOT NULL; default none | PK(administrator_id) | Stable identifier within administrator_profile ownership/relationship; source is the local aggregate unless explicitly marked external. | Pseudonymous personal/security identifier |
| user_id | uuid | NOT NULL; default none | UNIQUE(user_id); local FK (user_id) → user_profile(user_id) | Stable identifier within administrator_profile ownership/relationship; source is the local aggregate unless explicitly marked external. | Pseudonymous personal/security identifier |
| created_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded created instant for administrator_profile; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(administrator_id)`.
- UNIQUE `(user_id)`.

**Row CHECKs:**

- No additional DBML row CHECK; enum/key/nullability and companion rules still apply.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `administrator_id`, `created_at`.

## profile_operation

Restricted local exact-operation outcome/idempotency audit for profile commands; not a distributed workflow.

Source model note: Local append-only outcome/idempotency record, not domain root or distributed workflow. Mutation and Applied outcome commit together; rejected authenticated command may record Rejected without mutation. Concurrent unique operation-ID claims serialize. Compare actor/service/school/channel/command/target/exact canonical payload on retry and reauthorize replay. No Pending, Coordinating or ReconciliationPending here. No remote write is performed inside this transaction. Generic target is handler-checked; unknown-ID denials need no target FK. School-visible audit is a restricted projection, not this global table. Immutable-role creation has NULL expected/result revisions.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| operation_id | uuid | NOT NULL; default none | PK(operation_id) | Stable identifier within profile_operation ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| actor_user_id | uuid | NULL; default none | Non-key attribute | Logical actor reference, no FK. System/bootstrap actor instead identifies accountable service. | Pseudonymous personal/security identifier |
| actor_service | varchar(120) | NULL; default none | Non-key attribute | Actor service belonging to profile_operation; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| requesting_school_id | uuid | NULL; default none | Non-key attribute | Optional external authority context, not global profile ownership. Required for invitation-scoped role provisioning. | Scoped identifier; linkability/access control required |
| authority_basis | varchar(250) | NOT NULL; default none | Non-key attribute | Restricted subject/permission/invitation reference; not bearer token or raw invitation. | Operational/configuration metadata; restricted if linked to a person |
| channel | um_channel | NOT NULL; default none | Non-key attribute | Channel belonging to profile_operation; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| command_name | varchar(80) | NOT NULL; default none | Non-key attribute | Command name belonging to profile_operation; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| target_kind | varchar(80) | NOT NULL; default none | Non-key attribute | Target kind belonging to profile_operation; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| target_id | uuid | NOT NULL; default none | Non-key attribute | Stable identifier within profile_operation ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| expected_revision | bigint | NULL; default none | Non-key attribute | Exact retained expected_revision of referenced source/configuration; records provenance, not a permanent authorization permit. | Operational/configuration metadata; restricted if linked to a person |
| resulting_revision | bigint | NULL; default none | Non-key attribute | Exact retained resulting_revision of referenced source/configuration; records provenance, not a permanent authorization permit. | Operational/configuration metadata; restricted if linked to a person |
| request_fingerprint | varchar(64) | NOT NULL; default none | Non-key attribute | Request fingerprint belonging to profile_operation; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| outcome | um_operation_outcome | NOT NULL; default none | Non-key attribute | Lifecycle/evaluation state of profile_operation; enum/check vocabulary below; transition is not implied by a type alone. | Operational/configuration metadata; restricted if linked to a person |
| outcome_code | varchar(80) | NOT NULL; default none | Non-key attribute | Outcome code belonging to profile_operation; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| recorded_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded recorded instant for profile_operation; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| reason | text | NULL; default none | Non-key attribute | Reason belonging to profile_operation; set by the owning application command/source contract, constrained below. | Restricted free text/document/payload; may contain personal data |
| confirmation_id | uuid | NULL; default none | Non-key attribute | Stable identifier within profile_operation ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| confirmed_at | timestamptz | NULL; default none | Non-key attribute | Recorded confirmed instant for profile_operation; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(operation_id)`.
- INDEX `(target_kind, target_id, recorded_at)`.

**Row CHECKs:**

- `actor_user_id IS NOT NULL OR (actor_service IS NOT NULL AND length(trim(actor_service)) > 0)` — um_accountable_actor.
- `expected_revision IS NULL OR expected_revision > 0` — um_expected_revision.
- `resulting_revision IS NULL OR resulting_revision > 0` — um_result_revision.
- `length(request_fingerprint) = 64 AND length(trim(authority_basis)) > 0 AND length(trim(command_name)) > 0 AND length(trim(target_kind)) > 0 AND length(trim(outcome_code)) > 0` — um_operation_basis.
- `(confirmation_id IS NULL) = (confirmed_at IS NULL)` — um_confirmation_pair.
- `channel <> 'MCP' OR outcome <> 'Applied' OR confirmation_id IS NOT NULL` — um_mcp_write_confirmation.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `operation_id`.

## Technical outbox metadata

The backend adds `outbox_message`; it is not a profile aggregate or a substitute for `profile_operation`.

| Column | PostgreSQL type | Null / key | Meaning |
|---|---|---|---|
| event_id | uuid | NOT NULL; PK | Stable outgoing event and broker MessageId |
| aggregate_id | uuid | NOT NULL; logical reference, no FK | UserId of the event subject |
| aggregate_version | bigint | NOT NULL; > 0 | Committed aggregate revision; not independently unique |
| event_type | varchar(80) | NOT NULL | Versioned event name |
| body | jsonb | NOT NULL | Immutable exact envelope/payload; apply the same restricted access as the event's profile identifiers |
| correlation_id | varchar(128) | NOT NULL | Diagnostic context, never authorization |
| trace_parent | varchar(128) | NULL | Optional W3C trace context |
| occurred_at | timestamptz | NOT NULL | Event occurrence time |
| next_attempt_at | timestamptz | NOT NULL | Next eligible send time |
| published_at | timestamptz | NULL | Send acknowledgment time |
| lease_id | uuid | NULL; paired with leased_until | Current delivery claim identity |
| leased_until | timestamptz | NULL; paired with lease_id | Claim expiry |
| attempts | integer | NOT NULL; >= 0 | Delivery attempt count |
| last_error_code | varchar(80) | NULL | Safe transport error code; no credentials or raw exception body |

Runtime can select/insert rows and update only delivery fields. No automatic cleanup is implemented. The initial business schema remains five tables/37 columns; the outbox adds 14 technical columns. DDL: `../ddl/002-outbox.sql`.

## Enum vocabulary

- `um_user_status`: Active, Inactive.
- `um_operation_outcome`: Applied, Rejected.
- `um_channel`: Web, MCP, Internal.

Supplemental partial indexes, exclusion/trigger/function rules and deployed CHECK definitions are recorded in [logical schema](logical-schema.md) and verification. External IDs are owner API references, not permission grants.
