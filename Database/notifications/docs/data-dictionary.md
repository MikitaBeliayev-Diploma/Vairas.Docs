# Notifications — Data Dictionary

Current source: [notifications.dbml](../schema/schema.dbml), SHA-256 `2d0ea67416892a26bcf2484a4fd0005b497abfabe939e47461778674c0f22e8f`. Current proposed notification/delivery model.

5 tables / 69 columns. This dictionary is an enriched source-derived specification, not a claim of deployed APIs. No cross-service FK.

Classification is conservative: even opaque identifiers/audit timestamps can be personal when linked. No legal retention duration or GDPR certification is inferred.

## notification_template

School-owned reusable notification content template.

Source model note: Aggregate root. No Channel. Supplemental partial unique index: one Active template per school/type. Notification stores rendered snapshot and template revision.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| school_id | uuid | NOT NULL; default none | PK(school_id,template_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| template_id | uuid | NOT NULL; default none | PK(school_id,template_id) | Stable identifier within notification_template ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| notification_type | varchar(40) | NOT NULL; default none | Non-key attribute | One allowed domain-intent type, not a generated lookup-table foreign key. | Operational/configuration metadata; restricted if linked to a person |
| subject_template | varchar(500) | NOT NULL; default none | Non-key attribute | Unrendered subject; recipient-specific snapshot belongs to notification. | Operational/configuration metadata; restricted if linked to a person |
| body_template | text | NOT NULL; default none | Non-key attribute | Body template belonging to notification_template; Authorized school notification configuration. | Restricted free text/document/payload; may contain personal data |
| status | varchar(12) | NOT NULL; default Active | Non-key attribute | Lifecycle/evaluation state of notification_template; enum/check vocabulary below; transition is not implied by a type alone. | Operational/configuration metadata; restricted if linked to a person |
| revision | bigint | NOT NULL; default 1 | Non-key attribute | Template optimistic-concurrency/current-content revision. | Operational/configuration metadata; restricted if linked to a person |
| created_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded created instant for notification_template; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| updated_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded updated instant for notification_template; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(school_id, template_id)`.

**Row CHECKs:**

- `status IN ('Active','Archived')` — nt_status.
- `notification_type IN ('LessonScheduled','LessonRescheduled','LessonCancelled','LessonReminder','AssessmentPassed','AssessmentFailed')` — nt_type.
- `length(trim(subject_template)) > 0 AND length(trim(body_template)) > 0` — nt_content.
- `revision > 0 AND updated_at >= created_at` — nt_revision_time.

**Lifecycle / immutable / audit:** See the current context contract and local SQL companion; service-only rules are not falsely certified by row CHECKs.

Immutable design attributes: `school_id`, `template_id`, `created_at`.

## notification

One recipient/channel delivery intent with immutable rendered/source/contact snapshots.

Source model note: Aggregate root, one recipient/channel. Sent means provider acceptance, not inbox delivery/read. Rendered content, recipient, source and contact snapshot immutable. State transitions and attempt counters require handler transaction. No global user/school FK.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| school_id | uuid | NOT NULL; default none | PK(school_id,notification_id); UNIQUE(school_id,recipient_user_id,channel,dispatch_key); local FK (school_id,template_id) → notification_template(school_id,template_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| notification_id | uuid | NOT NULL; default none | PK(school_id,notification_id) | Stable identifier within notification ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| recipient_user_id | uuid | NOT NULL; default none | UNIQUE(school_id,recipient_user_id,channel,dispatch_key) | External UM UserId, not StudentId/TeacherId. | Pseudonymous personal/security identifier |
| template_id | uuid | NULL; default none | local FK (school_id,template_id) → notification_template(school_id,template_id) | Stable identifier within notification ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| template_revision | bigint | NULL; default none | Non-key attribute | Exact retained template_revision of referenced source/configuration; records provenance, not a permanent authorization permit. | Operational/configuration metadata; restricted if linked to a person |
| notification_type | varchar(40) | NOT NULL; default none | Non-key attribute | Notification type belonging to notification; Authorized Scheduling/LT event and trusted contact adapter. | Operational/configuration metadata; restricted if linked to a person |
| channel | varchar(12) | NOT NULL; default Email | UNIQUE(school_id,recipient_user_id,channel,dispatch_key) | Channel belonging to notification; Authorized Scheduling/LT event and trusted contact adapter. | Operational/configuration metadata; restricted if linked to a person |
| subject | varchar(500) | NOT NULL; default none | Non-key attribute | Subject belonging to notification; Authorized Scheduling/LT event and trusted contact adapter. | Operational/configuration metadata; restricted if linked to a person |
| body | text | NOT NULL; default none | Non-key attribute | Body belonging to notification; Authorized Scheduling/LT event and trusted contact adapter. | Restricted free text/document/payload; may contain personal data |
| destination_address | varchar(254) | NOT NULL; default none | Non-key attribute | Trusted contact snapshot; never arbitrary model/client address. | Operational/configuration metadata; restricted if linked to a person |
| contact_revision | varchar(100) | NOT NULL; default none | Non-key attribute | Exact retained contact_revision of referenced source/configuration; records provenance, not a permanent authorization permit. | Personal/contact |
| source_context | varchar(40) | NOT NULL; default none | Non-key attribute | Source context belonging to notification; Authorized Scheduling/LT event and trusted contact adapter. | Operational/configuration metadata; restricted if linked to a person |
| source_id | uuid | NOT NULL; default none | Non-key attribute | External Scheduling LessonId or LT-owned source ID, discriminated by source_context; no remote FK. | Scoped identifier; linkability/access control required |
| source_revision | bigint | NOT NULL; default none | Non-key attribute | Version of the authoritative source intent. | Operational/configuration metadata; restricted if linked to a person |
| source_event_id | uuid | NOT NULL; default none | Non-key attribute | Stable identifier within notification ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| dispatch_key | varchar(200) | NOT NULL; default none | UNIQUE(school_id,recipient_user_id,channel,dispatch_key) | Semantic delivery deduplication key, not provider API credential. | Operational/configuration metadata; restricted if linked to a person |
| scheduled_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded scheduled instant for notification; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| status | varchar(20) | NOT NULL; default Pending | Non-key attribute | Sent is provider acceptance only, not inbox delivery/read; DeliveryUnknown needs same-attempt reconciliation. | Operational/configuration metadata; restricted if linked to a person |
| revision | bigint | NOT NULL; default 1 | Non-key attribute | Positive version of this notification consistency basis; handlers use exact expected revision/CAS, not CHECK alone. | Operational/configuration metadata; restricted if linked to a person |
| attempt_count | integer | NOT NULL; default 0 | Non-key attribute | Attempt count belonging to notification; Authorized Scheduling/LT event and trusted contact adapter. | Operational/configuration metadata; restricted if linked to a person |
| next_attempt_at | timestamptz | NULL; default none | Non-key attribute | Recorded next attempt instant for notification; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| sent_at | timestamptz | NULL; default none | Non-key attribute | Recorded sent instant for notification; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| cancelled_at | timestamptz | NULL; default none | Non-key attribute | Recorded cancelled instant for notification; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| failure_code | varchar(80) | NULL; default none | Non-key attribute | Failure code belonging to notification; Authorized Scheduling/LT event and trusted contact adapter. | Operational/configuration metadata; restricted if linked to a person |
| created_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded created instant for notification; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| updated_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded updated instant for notification; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(school_id, notification_id)`.
- UNIQUE `(school_id, recipient_user_id, channel, dispatch_key)`.
- INDEX `(status, next_attempt_at, scheduled_at)`.
- INDEX `(school_id, recipient_user_id, created_at)`.
- INDEX `(school_id, source_context, source_id, source_revision)`.

**Row CHECKs:**

- `notification_type IN ('LessonScheduled','LessonRescheduled','LessonCancelled','LessonReminder','AssessmentPassed','AssessmentFailed')` — n_type.
- `channel = 'Email'` — n_channel.
- `status IN ('Pending','Sending','Sent','Failed','Cancelled','DeliveryUnknown')` — n_status.
- `(template_id IS NULL AND template_revision IS NULL) OR (template_id IS NOT NULL AND template_revision IS NOT NULL AND template_revision > 0)` — n_template_pair.
- `revision > 0 AND source_revision > 0 AND attempt_count >= 0` — n_revisions.
- `length(trim(subject)) > 0 AND length(trim(body)) > 0 AND length(trim(destination_address)) > 0 AND length(trim(contact_revision)) > 0 AND length(trim(dispatch_key)) > 0` — n_content.
- `source_context IN ('Scheduling','LearningTracking')` — n_source.
- `updated_at >= created_at AND scheduled_at >= created_at` — n_time.
- `(status = 'Sent') = (sent_at IS NOT NULL)` — n_sent_pair.
- `(status = 'Cancelled') = (cancelled_at IS NOT NULL)` — n_cancel_pair.
- `sent_at IS NULL OR sent_at >= created_at` — n_sent_time.
- `cancelled_at IS NULL OR cancelled_at >= created_at` — n_cancel_time.
- `next_attempt_at IS NULL OR (status = 'Pending' AND next_attempt_at >= created_at)` — n_retry_time.
- `status NOT IN ('Sending','Sent','DeliveryUnknown') OR attempt_count > 0` — n_attempt_required.

**Lifecycle / immutable / audit:** See the current context contract and local SQL companion; service-only rules are not falsely certified by row CHECKs.

Immutable design attributes: `school_id`, `notification_id`, `recipient_user_id`, `template_id`, `template_revision`, `notification_type`, `channel`, `subject`, `body`, `destination_address`, `contact_revision`, `source_context`, `source_id`, `source_revision`, `source_event_id`, `dispatch_key`, `scheduled_at`, `created_at`.

## notification_delivery_attempt

Notification-owned provider submission attempt and uncertain-result reconciliation.

Source model note: Notification-owned child, not a third root. One unresolved Started/Unknown attempt per notification (supplemental index). Provider idempotency support OPEN. Unknown requires reconciliation, never blind retry.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| school_id | uuid | NOT NULL; default none | PK(school_id,attempt_id); UNIQUE(school_id,notification_id,attempt_no); UNIQUE(school_id,provider_key); local FK (school_id,notification_id) → notification(school_id,notification_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| attempt_id | uuid | NOT NULL; default none | PK(school_id,attempt_id) | Stable identifier within notification_delivery_attempt ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| notification_id | uuid | NOT NULL; default none | UNIQUE(school_id,notification_id,attempt_no); local FK (school_id,notification_id) → notification(school_id,notification_id) | Stable identifier within notification_delivery_attempt ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| attempt_no | integer | NOT NULL; default none | UNIQUE(school_id,notification_id,attempt_no) | Attempt no belonging to notification_delivery_attempt; Notification dispatcher/provider adapter. | Operational/configuration metadata; restricted if linked to a person |
| provider_key | varchar(200) | NOT NULL; default none | UNIQUE(school_id,provider_key) | Stable exact submission identity for provider retry/reconciliation where supported. | Operational/configuration metadata; restricted if linked to a person |
| provider_message_id | varchar(200) | NULL; default none | Non-key attribute | Provider-returned receipt identifier, not proof of recipient delivery. | Scoped identifier; linkability/access control required |
| status | varchar(12) | NOT NULL; default Started | Non-key attribute | Lifecycle/evaluation state of notification_delivery_attempt; enum/check vocabulary below; transition is not implied by a type alone. | Operational/configuration metadata; restricted if linked to a person |
| started_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded started instant for notification_delivery_attempt; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| finished_at | timestamptz | NULL; default none | Non-key attribute | Recorded finished instant for notification_delivery_attempt; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| error_code | varchar(80) | NULL; default none | Non-key attribute | Bounded safe outcome code; no raw provider dump. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(school_id, attempt_id)`.
- UNIQUE `(school_id, notification_id, attempt_no)`.
- UNIQUE `(school_id, provider_key)`.

**Row CHECKs:**

- `attempt_no > 0 AND length(trim(provider_key)) > 0` — nda_identity.
- `status IN ('Started','Accepted','Rejected','Unknown')` — nda_status.
- `(status = 'Started') = (finished_at IS NULL)` — nda_finished.
- `finished_at IS NULL OR finished_at >= started_at` — nda_time.

**Lifecycle / immutable / audit:** See the current context contract and local SQL companion; service-only rules are not falsely certified by row CHECKs.

Immutable design attributes: `school_id`, `attempt_id`, `notification_id`, `attempt_no`, `provider_key`, `started_at`.

## notification_inbox

Immutable processed producer-event receipt for deduplication and atomic ACK outcomes.

Source model note: Infrastructure receipt. Completed processing outcome and all notifications/cancellations commit together, then transport ACK. Temporary authority outage rolls back without ACK. Permanent invalid input receives Rejected/quarantine outcome. Immutable.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| school_id | uuid | NOT NULL; default none | PK(school_id,producer,event_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| producer | varchar(40) | NOT NULL; default none | PK(school_id,producer,event_id) | Scheduling or LearningTracking; service authentication still required. | Operational/configuration metadata; restricted if linked to a person |
| event_id | uuid | NOT NULL; default none | PK(school_id,producer,event_id) | Stable identifier within notification_inbox ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| payload_hash | varchar(64) | NOT NULL; default none | Non-key attribute | Payload hash belonging to notification_inbox; Authenticated owner event consumer. | Restricted free text/document/payload; may contain personal data |
| source_id | uuid | NOT NULL; default none | Non-key attribute | Stable identifier within notification_inbox ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| source_revision | bigint | NOT NULL; default none | Non-key attribute | Exact retained source_revision of referenced source/configuration; records provenance, not a permanent authorization permit. | Operational/configuration metadata; restricted if linked to a person |
| outcome | varchar(12) | NOT NULL; default none | Non-key attribute | Applied/Ignored/Rejected permanent processing result; temporary authority failures do not receive fabricated ACK success. | Operational/configuration metadata; restricted if linked to a person |
| outcome_code | varchar(80) | NOT NULL; default none | Non-key attribute | Outcome code belonging to notification_inbox; Authenticated owner event consumer. | Operational/configuration metadata; restricted if linked to a person |
| received_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded received instant for notification_inbox; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| processed_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded processed instant for notification_inbox; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(school_id, producer, event_id)`.

**Row CHECKs:**

- `producer IN ('Scheduling','LearningTracking') AND source_revision > 0` — ni_source.
- `payload_hash ~ '^[0-9a-f]{64}$'` — ni_hash.
- `outcome IN ('Applied','Ignored','Rejected') AND length(trim(outcome_code)) > 0` — ni_outcome.
- `processed_at >= received_at` — ni_time.

**Lifecycle / immutable / audit:** See the current context contract and local SQL companion; service-only rules are not falsely certified by row CHECKs.

Immutable design attributes: `school_id`, `producer`, `event_id`, `payload_hash`, `source_id`, `source_revision`, `outcome`, `outcome_code`, `received_at`, `processed_at`.

## notification_operation

Immutable human-command outcome binding and MCP confirmation reference.

Source model note: Local human-command receipt. Applied outcome and mutation atomic. Exact replay compares actor/channel/command/target/payload and reauthorizes. Same UUID in another authorized school independent. Generic target handler-validated; no polymorphic FK. Immutable.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| school_id | uuid | NOT NULL; default none | PK(school_id,operation_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| operation_id | uuid | NOT NULL; default none | PK(school_id,operation_id) | Stable identifier within notification_operation ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| actor_user_id | uuid | NOT NULL; default none | Non-key attribute | UM UserId resolved from trusted actor context. | Pseudonymous personal/security identifier |
| channel | varchar(12) | NOT NULL; default none | Non-key attribute | Channel belonging to notification_operation; Authorized Notification command handlers. | Operational/configuration metadata; restricted if linked to a person |
| command_name | varchar(80) | NOT NULL; default none | Non-key attribute | Command name belonging to notification_operation; Authorized Notification command handlers. | Operational/configuration metadata; restricted if linked to a person |
| target_id | uuid | NOT NULL; default none | Non-key attribute | Stable identifier within notification_operation ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| request_hash | varchar(64) | NOT NULL; default none | Non-key attribute | Canonical-command comparison digest; authentic authorization/consent must still be verified. | Operational/configuration metadata; restricted if linked to a person |
| authority_basis | text | NOT NULL; default none | Non-key attribute | Minimal source-version basis, never a copied profile/credential. | Operational/configuration metadata; restricted if linked to a person |
| confirmation_id | uuid | NULL; default none | Non-key attribute | External exact-action consent reference, not permission. | Scoped identifier; linkability/access control required |
| confirmed_at | timestamptz | NULL; default none | Non-key attribute | Recorded confirmed instant for notification_operation; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| outcome | varchar(12) | NOT NULL; default none | Non-key attribute | Lifecycle/evaluation state of notification_operation; enum/check vocabulary below; transition is not implied by a type alone. | Operational/configuration metadata; restricted if linked to a person |
| outcome_code | varchar(80) | NOT NULL; default none | Non-key attribute | Outcome code belonging to notification_operation; Authorized Notification command handlers. | Operational/configuration metadata; restricted if linked to a person |
| resulting_revision | bigint | NULL; default none | Non-key attribute | Exact retained resulting_revision of referenced source/configuration; records provenance, not a permanent authorization permit. | Operational/configuration metadata; restricted if linked to a person |
| recorded_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded recorded instant for notification_operation; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(school_id, operation_id)`.

**Row CHECKs:**

- `channel IN ('Web','MCP') AND outcome IN ('Applied','Rejected')` — no_values.
- `request_hash ~ '^[0-9a-f]{64}$' AND length(trim(command_name)) > 0 AND length(trim(authority_basis)) > 0 AND length(trim(outcome_code)) > 0` — no_basis.
- `(confirmation_id IS NULL) = (confirmed_at IS NULL)` — no_confirmation_pair.
- `channel <> 'MCP' OR outcome <> 'Applied' OR confirmation_id IS NOT NULL` — no_mcp_confirmation.
- `resulting_revision IS NULL OR resulting_revision > 0` — no_revision.

**Lifecycle / immutable / audit:** See the current context contract and local SQL companion; service-only rules are not falsely certified by row CHECKs.

Immutable design attributes: `all attributes after committed terminal receipt`.

## Enum vocabulary

Native enums absent; status vocabularies are in exact CHECKs and current context contract.

Supplemental partial indexes, exclusion/trigger/function rules and deployed CHECK definitions are recorded in [logical schema](logical-schema.md) and verification. External IDs are owner API references, not permission grants.
