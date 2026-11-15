# Document Management — Data Dictionary

Current source: [document-management.dbml](../schema/schema.dbml), SHA-256 `e25e4eddf9edb9f42513095f53438470807b4397765f3c4ac9736823797b6d18`. Current reviewed proposed model; LT owns evidence, DM files/publication.

10 tables / 105 columns. This dictionary is an enriched source-derived specification, not a claim of deployed APIs. No cross-service FK.

Classification is conservative: even opaque identifiers/audit timestamps can be personal when linked. No legal retention duration or GDPR certification is inferred.

## document_template

School-owned template identity/kind and selected active-version pointer.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| template_id | uuid | NOT NULL; default none | PK(template_id); UNIQUE(school_id,template_id); local FK (school_id,template_id,active_version_id) → template_version(school_id,template_id,template_version_id) | Stable identifier within document_template ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| school_id | uuid | NOT NULL; default none | UNIQUE(school_id,template_id); local FK (school_id,template_id,active_version_id) → template_version(school_id,template_id,template_version_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| kind | varchar | NOT NULL; default none | Non-key attribute | TrainingContract, PracticalJournal or CompletionReport; immutable per root. | Operational/configuration metadata; restricted if linked to a person |
| name | varchar | NOT NULL; default none | Non-key attribute | Name of document_template; generated/validated by this context, not an external identity key. | Operational/configuration metadata; restricted if linked to a person |
| active_version_id | uuid | NULL; default none | local FK (school_id,template_id,active_version_id) → template_version(school_id,template_id,template_version_id) | Own sole Active template child or NULL; not a remote model version. | Scoped identifier; linkability/access control required |
| revision | bigint | NOT NULL; default none | Non-key attribute | Positive version of this document_template consistency basis; handlers use exact expected revision/CAS, not CHECK alone. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(template_id)`.
- UNIQUE `(school_id, template_id)`.

**Row CHECKs:**

- `kind IN ('TrainingContract','PracticalJournal','CompletionReport')`.
- `revision > 0`.
- `length(trim(name)) > 0`.

**Lifecycle / immutable / audit:** See the current context contract and local SQL companion; service-only rules are not falsely certified by row CHECKs.

Immutable design attributes: `template_id`, `school_id`, `kind`.

## template_version

Immutable versioned template file with Draft/Active/Archived lifecycle.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| template_version_id | uuid | NOT NULL; default none | PK(template_version_id); UNIQUE(school_id,template_version_id); UNIQUE(school_id,template_id,template_version_id) | Stable identifier within template_version ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| school_id | uuid | NOT NULL; default none | UNIQUE(school_id,template_version_id); UNIQUE(school_id,template_id,version_no); UNIQUE(school_id,template_id,template_version_id); local FK (school_id,template_id) → document_template(school_id,template_id); local FK (school_id,file_id) → file_object(school_id,file_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| template_id | uuid | NOT NULL; default none | UNIQUE(school_id,template_id,version_no); UNIQUE(school_id,template_id,template_version_id); local FK (school_id,template_id) → document_template(school_id,template_id) | Stable identifier within template_version ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| version_no | integer | NOT NULL; default none | UNIQUE(school_id,template_id,version_no) | Immutable business version number within template; different from root Revision. | Operational/configuration metadata; restricted if linked to a person |
| status | varchar | NOT NULL; default none | Non-key attribute | Lifecycle/evaluation state of template_version; enum/check vocabulary below; transition is not implied by a type alone. | Operational/configuration metadata; restricted if linked to a person |
| file_id | uuid | NOT NULL; default none | local FK (school_id,file_id) → file_object(school_id,file_id) | Local clean Template-purpose file descriptor, not a path passed by AI. | Scoped identifier; linkability/access control required |
| created_by | uuid | NOT NULL; default none | Non-key attribute | Created by belonging to template_version; Template upload/activation using clean same-school file. | Operational/configuration metadata; restricted if linked to a person |
| created_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded created instant for template_version; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(template_version_id)`.
- UNIQUE `(school_id, template_version_id)`.
- UNIQUE `(school_id, template_id, version_no)`.
- UNIQUE `(school_id, template_id, template_version_id)`.

**Row CHECKs:**

- `status IN ('Draft','Active','Archived')`.
- `version_no > 0`.

**Lifecycle / immutable / audit:** See the current context contract and local SQL companion; service-only rules are not falsely certified by row CHECKs.

Immutable design attributes: `template_version_id`, `school_id`, `template_id`, `version_no`, `file_id`, `created_by`, `created_at`.

## file_object

Immutable physical-object descriptor after Pending scan resolves.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| file_id | uuid | NOT NULL; default none | PK(file_id); UNIQUE(school_id,file_id) | Stable identifier within file_object ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| school_id | uuid | NOT NULL; default none | UNIQUE(school_id,file_id); UNIQUE(school_id,storage_key) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| storage_key | varchar | NOT NULL; default none | UNIQUE(school_id,storage_key) | Opaque restricted same-service object key, never public capability URL. | Restricted free text/document/payload; may contain personal data |
| purpose | varchar | NOT NULL; default none | Non-key attribute | Template/Rendered/SignedCopy/SourceBasis use is verified by local file guards. | Operational/configuration metadata; restricted if linked to a person |
| sha256 | varchar(64) | NOT NULL; default none | Non-key attribute | Sha256 belonging to file_object; Trusted upload/object-store/scan adapter; bytes external to relational DB. | Operational/configuration metadata; restricted if linked to a person |
| byte_length | bigint | NOT NULL; default none | Non-key attribute | Byte length belonging to file_object; Trusted upload/object-store/scan adapter; bytes external to relational DB. | Operational/configuration metadata; restricted if linked to a person |
| media_type | varchar | NOT NULL; default none | Non-key attribute | Media type belonging to file_object; Trusted upload/object-store/scan adapter; bytes external to relational DB. | Operational/configuration metadata; restricted if linked to a person |
| scan_status | varchar | NOT NULL; default none | Non-key attribute | Pending -> Clean/Rejected; synthetic seed simulates shape only, not scanning. | Operational/configuration metadata; restricted if linked to a person |
| uploaded_by | uuid | NOT NULL; default none | Non-key attribute | Uploaded by belonging to file_object; Trusted upload/object-store/scan adapter; bytes external to relational DB. | Operational/configuration metadata; restricted if linked to a person |
| uploaded_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded uploaded instant for file_object; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(file_id)`.
- UNIQUE `(school_id, file_id)`.
- UNIQUE `(school_id, storage_key)`.

**Row CHECKs:**

- `purpose IN ('Template','Rendered','SignedCopy','SourceBasis')`.
- `scan_status IN ('Pending','Clean','Rejected')`.
- `byte_length > 0`.
- `sha256 ~ '^[0-9a-f]{64}$'`.
- `length(trim(storage_key)) > 0 AND length(trim(media_type)) > 0`.

**Lifecycle / immutable / audit:** See the current context contract and local SQL companion; service-only rules are not falsely certified by row CHECKs.

Immutable design attributes: `file_id`, `school_id`, `storage_key`, `purpose`, `sha256`, `byte_length`, `media_type`, `uploaded_by`, `uploaded_at`.

## training_contract

Enrollment-linked immutable generated contract and later signature/cancel lifecycle.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| contract_id | uuid | NOT NULL; default none | PK(contract_id); UNIQUE(school_id,contract_id); UNIQUE(school_id,enrollment_id,contract_id) | Stable identifier within training_contract ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| school_id | uuid | NOT NULL; default none | UNIQUE(school_id,contract_id); UNIQUE(school_id,enrollment_id,contract_id); local FK (school_id,generated_file_id) → file_object(school_id,file_id); local FK (school_id,basis_file_id) → file_object(school_id,file_id); local FK (school_id,template_version_id) → template_version(school_id,template_version_id); local FK (school_id,enrollment_id,replaces_contract_id) → training_contract(school_id,enrollment_id,contract_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| enrollment_id | uuid | NOT NULL; default none | UNIQUE(school_id,enrollment_id,contract_id); local FK (school_id,enrollment_id,replaces_contract_id) → training_contract(school_id,enrollment_id,contract_id) | External School-owned EnrollmentId; not StudentTraining identifier newly allocated by DM. | Scoped identifier; linkability/access control required |
| student_id | uuid | NOT NULL; default none | Non-key attribute | External UM StudentId retained as generation basis, not a person/profile table. | Pseudonymous personal/security identifier |
| template_version_id | uuid | NOT NULL; default none | local FK (school_id,template_version_id) → template_version(school_id,template_version_id) | Stable identifier within training_contract ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| generated_file_id | uuid | NOT NULL; default none | local FK (school_id,generated_file_id) → file_object(school_id,file_id) | Stable identifier within training_contract ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| basis_file_id | uuid | NOT NULL; default none | local FK (school_id,basis_file_id) → file_object(school_id,file_id) | Protected frozen source-basis object for regeneration/audit, not live owner DB access. | Scoped identifier; linkability/access control required |
| basis_schema_version | varchar | NOT NULL; default none | Non-key attribute | Exact retained basis_schema_version of referenced source/configuration; records provenance, not a permanent authorization permit. | Operational/configuration metadata; restricted if linked to a person |
| status | varchar | NOT NULL; default none | Non-key attribute | Lifecycle/evaluation state of training_contract; enum/check vocabulary below; transition is not implied by a type alone. | Operational/configuration metadata; restricted if linked to a person |
| replaces_contract_id | uuid | NULL; default none | local FK (school_id,enrollment_id,replaces_contract_id) → training_contract(school_id,enrollment_id,contract_id) | Already-existing same-enrollment predecessor; no overwriting. | Scoped identifier; linkability/access control required |
| generated_by | uuid | NOT NULL; default none | Non-key attribute | Generated by belonging to training_contract; Authorized generation from School/UM facts and local active template. | Operational/configuration metadata; restricted if linked to a person |
| generated_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded generated instant for training_contract; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| revision | bigint | NOT NULL; default none | Non-key attribute | Positive version of this training_contract consistency basis; handlers use exact expected revision/CAS, not CHECK alone. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(contract_id)`.
- UNIQUE `(school_id, contract_id)`.
- UNIQUE `(school_id, enrollment_id, contract_id)`.

**Row CHECKs:**

- `status IN ('Generated','Signed','Cancelled')`.
- `revision > 0`.
- `replaces_contract_id IS NULL OR replaces_contract_id <> contract_id`.
- `length(trim(basis_schema_version)) > 0`.

**Lifecycle / immutable / audit:** See the current context contract and local SQL companion; service-only rules are not falsely certified by row CHECKs.

Immutable design attributes: `contract_id`, `school_id`, `enrollment_id`, `student_id`, `template_version_id`, `generated_file_id`, `basis_file_id`, `basis_schema_version`, `replaces_contract_id`, `generated_by`, `generated_at`.

## contract_signed_copy

Retained signed-copy attachment history with one selected copy for Signed contract.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| signed_copy_id | uuid | NOT NULL; default none | PK(signed_copy_id); UNIQUE(school_id,signed_copy_id); UNIQUE(school_id,contract_id,signed_copy_id) | Stable identifier within contract_signed_copy ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| school_id | uuid | NOT NULL; default none | UNIQUE(school_id,signed_copy_id); UNIQUE(school_id,contract_id,signed_copy_id); UNIQUE(school_id,contract_id,copy_no); local FK (school_id,contract_id) → training_contract(school_id,contract_id); local FK (school_id,file_id) → file_object(school_id,file_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| contract_id | uuid | NOT NULL; default none | UNIQUE(school_id,contract_id,signed_copy_id); UNIQUE(school_id,contract_id,copy_no); local FK (school_id,contract_id) → training_contract(school_id,contract_id) | Stable identifier within contract_signed_copy ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| copy_no | integer | NOT NULL; default none | UNIQUE(school_id,contract_id,copy_no) | Copy no belonging to contract_signed_copy; Authorized external-copy attachment; legal signature validity not inferred. | Operational/configuration metadata; restricted if linked to a person |
| file_id | uuid | NOT NULL; default none | local FK (school_id,file_id) → file_object(school_id,file_id) | Stable identifier within contract_signed_copy ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| is_current | boolean | NOT NULL; default none | Non-key attribute | Only current selection can transition false; old copy cannot be reselected or edited. | Operational/configuration metadata; restricted if linked to a person |
| declared_signed_at | timestamptz | NOT NULL; default none | Non-key attribute | User-declared external signing time, not cryptographic timestamp proof. | Operational/configuration metadata; restricted if linked to a person |
| recorded_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded recorded instant for contract_signed_copy; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| recorded_by | uuid | NOT NULL; default none | Non-key attribute | Recorded by belonging to contract_signed_copy; Authorized external-copy attachment; legal signature validity not inferred. | Operational/configuration metadata; restricted if linked to a person |
| basis | text | NOT NULL; default none | Non-key attribute | Minimized declaration/evidence text, not a signature-verification certificate. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(signed_copy_id)`.
- UNIQUE `(school_id, signed_copy_id)`.
- UNIQUE `(school_id, contract_id, signed_copy_id)`.
- UNIQUE `(school_id, contract_id, copy_no)`.

**Row CHECKs:**

- `copy_no > 0`.
- `declared_signed_at <= recorded_at`.
- `length(trim(basis)) > 0`.

**Lifecycle / immutable / audit:** See the current context contract and local SQL companion; service-only rules are not falsely certified by row CHECKs.

Immutable design attributes: `signed_copy_id`, `school_id`, `contract_id`, `copy_no`, `file_id`, `declared_signed_at`, `recorded_at`, `recorded_by`, `basis`.

## training_document

Enrollment/kind journal or completion-report root and selected publication.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| document_id | uuid | NOT NULL; default none | PK(document_id); UNIQUE(school_id,document_id); UNIQUE(school_id,document_id,enrollment_id); local FK (school_id,document_id,current_version_id) → document_version(school_id,document_id,document_version_id) | Stable identifier within training_document ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| school_id | uuid | NOT NULL; default none | UNIQUE(school_id,document_id); UNIQUE(school_id,enrollment_id,kind); UNIQUE(school_id,document_id,enrollment_id); local FK (school_id,document_id,current_version_id) → document_version(school_id,document_id,document_version_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| enrollment_id | uuid | NOT NULL; default none | UNIQUE(school_id,enrollment_id,kind); UNIQUE(school_id,document_id,enrollment_id) | Logical enrollment_id owned by School Management; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Scoped identifier; linkability/access control required |
| kind | varchar | NOT NULL; default none | UNIQUE(school_id,enrollment_id,kind) | PracticalJournal or CompletionReport. No direct Regitra transmission. | Operational/configuration metadata; restricted if linked to a person |
| revision | bigint | NOT NULL; default none | Non-key attribute | Positive version of this training_document consistency basis; handlers use exact expected revision/CAS, not CHECK alone. | Operational/configuration metadata; restricted if linked to a person |
| current_version_id | uuid | NULL; default none | local FK (school_id,document_id,current_version_id) → document_version(school_id,document_id,document_version_id) | Own selected PublishedReview/PublishedReady nonstale version; not independent proof of remote readiness. | Scoped identifier; linkability/access control required |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(document_id)`.
- UNIQUE `(school_id, document_id)`.
- UNIQUE `(school_id, enrollment_id, kind)`.
- UNIQUE `(school_id, document_id, enrollment_id)`.

**Row CHECKs:**

- `kind IN ('PracticalJournal','CompletionReport')`.
- `revision > 0`.

**Lifecycle / immutable / audit:** See the current context contract and local SQL companion; service-only rules are not falsely certified by row CHECKs.

Immutable design attributes: `document_id`, `school_id`, `enrollment_id`, `kind`.

## document_version

Immutable rendered/basis artifact version pinned to LT evidence and dependency revision.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| document_version_id | uuid | NOT NULL; default none | PK(document_version_id); UNIQUE(school_id,document_version_id); UNIQUE(school_id,document_id,document_version_id) | Stable identifier within document_version ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| school_id | uuid | NOT NULL; default none | UNIQUE(school_id,document_version_id); UNIQUE(school_id,document_id,document_version_id); UNIQUE(school_id,document_id,version_no); local FK (school_id,document_id,enrollment_id) → training_document(school_id,document_id,enrollment_id); local FK (school_id,template_version_id) → template_version(school_id,template_version_id); local FK (school_id,rendered_file_id) → file_object(school_id,file_id); local FK (school_id,basis_file_id) → file_object(school_id,file_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| document_id | uuid | NOT NULL; default none | UNIQUE(school_id,document_id,document_version_id); UNIQUE(school_id,document_id,version_no); local FK (school_id,document_id,enrollment_id) → training_document(school_id,document_id,enrollment_id) | Stable identifier within document_version ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| enrollment_id | uuid | NOT NULL; default none | local FK (school_id,document_id,enrollment_id) → training_document(school_id,document_id,enrollment_id) | Logical enrollment_id owned by School Management; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Scoped identifier; linkability/access control required |
| version_no | integer | NOT NULL; default none | UNIQUE(school_id,document_id,version_no) | Version no belonging to document_version; Authorized LT evidence snapshot plus deterministic renderer. | Operational/configuration metadata; restricted if linked to a person |
| template_version_id | uuid | NOT NULL; default none | local FK (school_id,template_version_id) → template_version(school_id,template_version_id) | Stable identifier within document_version ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| evidence_snapshot_id | uuid | NOT NULL; default none | Non-key attribute | External LT-owned immutable evidence identity, not a local SQL FK. | Scoped identifier; linkability/access control required |
| dependency_revision | bigint | NOT NULL; default none | Non-key attribute | LT source dependency basis captured at generation; compared with checkpoint before publication. | Operational/configuration metadata; restricted if linked to a person |
| evidence_status | varchar | NOT NULL; default none | Non-key attribute | Captured Ready/Incomplete classification, not legal validity or current permit. | Operational/configuration metadata; restricted if linked to a person |
| rendered_file_id | uuid | NOT NULL; default none | local FK (school_id,rendered_file_id) → file_object(school_id,file_id) | Stable identifier within document_version ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| basis_file_id | uuid | NOT NULL; default none | local FK (school_id,basis_file_id) → file_object(school_id,file_id) | Stable identifier within document_version ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| basis_schema_version | varchar | NOT NULL; default none | Non-key attribute | Exact retained basis_schema_version of referenced source/configuration; records provenance, not a permanent authorization permit. | Operational/configuration metadata; restricted if linked to a person |
| renderer_version | varchar | NOT NULL; default none | Non-key attribute | Ordered temporal bound for document_version under the authoritative source/period contract. | Operational/configuration metadata; restricted if linked to a person |
| state | varchar | NOT NULL; default none | Non-key attribute | Artifact release/withdrawal/staleness lifecycle, distinct from remote educational state. | Operational/configuration metadata; restricted if linked to a person |
| revision | bigint | NOT NULL; default none | Non-key attribute | Positive version of this document_version consistency basis; handlers use exact expected revision/CAS, not CHECK alone. | Operational/configuration metadata; restricted if linked to a person |
| generated_by | uuid | NOT NULL; default none | Non-key attribute | Generated by belonging to document_version; Authorized LT evidence snapshot plus deterministic renderer. | Operational/configuration metadata; restricted if linked to a person |
| generated_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded generated instant for document_version; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(document_version_id)`.
- UNIQUE `(school_id, document_version_id)`.
- UNIQUE `(school_id, document_id, document_version_id)`.
- UNIQUE `(school_id, document_id, version_no)`.

**Row CHECKs:**

- `version_no > 0`.
- `dependency_revision >= 0`.
- `revision > 0`.
- `evidence_status IN ('Ready','Incomplete')`.
- `state IN ('Prepared','Indeterminate','PublishedReview','PublishedReady','Stale','Withdrawn')`.
- `state <> 'PublishedReady' OR evidence_status = 'Ready'`.
- `length(trim(basis_schema_version)) > 0 AND length(trim(renderer_version)) > 0`.

**Lifecycle / immutable / audit:** See the current context contract and local SQL companion; service-only rules are not falsely certified by row CHECKs.

Immutable design attributes: `document_version_id`, `school_id`, `document_id`, `enrollment_id`, `version_no`, `template_version_id`, `evidence_snapshot_id`, `dependency_revision`, `evidence_status`, `rendered_file_id`, `basis_file_id`, `basis_schema_version`, `renderer_version`, `generated_by`, `generated_at`.

## state_event

Append-only exact lifecycle/root-revision evidence linked to a command.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| event_id | uuid | NOT NULL; default none | PK(event_id); UNIQUE(school_id,event_id) | Stable identifier within state_event ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| school_id | uuid | NOT NULL; default none | UNIQUE(school_id,event_id); UNIQUE(school_id,template_id,sequence_no); UNIQUE(school_id,contract_id,sequence_no); UNIQUE(school_id,document_id,sequence_no); UNIQUE(school_id,document_version_id,sequence_no); local FK (school_id,contract_id) → training_contract(school_id,contract_id); local FK (school_id,document_version_id) → document_version(school_id,document_version_id); local FK (school_id,template_id) → document_template(school_id,template_id); local FK (school_id,template_id,template_version_id) → template_version(school_id,template_id,template_version_id); local FK (school_id,contract_id,signed_copy_id) → contract_signed_copy(school_id,contract_id,signed_copy_id); local FK (school_id,command_id) → operation_receipt(school_id,command_id); local FK (school_id,document_id) → training_document(school_id,document_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| template_id | uuid | NULL; default none | UNIQUE(school_id,template_id,sequence_no); local FK (school_id,template_id) → document_template(school_id,template_id); local FK (school_id,template_id,template_version_id) → template_version(school_id,template_id,template_version_id) | Stable identifier within state_event ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| template_version_id | uuid | NULL; default none | local FK (school_id,template_id,template_version_id) → template_version(school_id,template_id,template_version_id) | Stable identifier within state_event ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| signed_copy_id | uuid | NULL; default none | local FK (school_id,contract_id,signed_copy_id) → contract_signed_copy(school_id,contract_id,signed_copy_id) | Stable identifier within state_event ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| action | varchar | NOT NULL; default none | Non-key attribute | Action belonging to state_event; Same local transaction as mutation and operation receipt. | Operational/configuration metadata; restricted if linked to a person |
| contract_id | uuid | NULL; default none | UNIQUE(school_id,contract_id,sequence_no); local FK (school_id,contract_id) → training_contract(school_id,contract_id); local FK (school_id,contract_id,signed_copy_id) → contract_signed_copy(school_id,contract_id,signed_copy_id) | Stable identifier within state_event ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| document_id | uuid | NULL; default none | UNIQUE(school_id,document_id,sequence_no); local FK (school_id,document_id) → training_document(school_id,document_id) | TrainingDocument root audit target; from_state/to_state encode selected UUID or Unselected. | Scoped identifier; linkability/access control required |
| document_version_id | uuid | NULL; default none | UNIQUE(school_id,document_version_id,sequence_no); local FK (school_id,document_version_id) → document_version(school_id,document_version_id) | Stable identifier within state_event ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| sequence_no | bigint | NOT NULL; default none | UNIQUE(school_id,template_id,sequence_no); UNIQUE(school_id,contract_id,sequence_no); UNIQUE(school_id,document_id,sequence_no); UNIQUE(school_id,document_version_id,sequence_no) | Target revision matched by deferred audit trigger. | Operational/configuration metadata; restricted if linked to a person |
| from_state | varchar | NULL; default none | Non-key attribute | NULL only for creation where appropriate; document root selection uses UUID string or Unselected. | Operational/configuration metadata; restricted if linked to a person |
| to_state | varchar | NOT NULL; default none | Non-key attribute | Exact recorded state/selected pointer for this target revision. | Operational/configuration metadata; restricted if linked to a person |
| actor_id | uuid | NOT NULL; default none | Non-key attribute | Stable identifier within state_event ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| occurred_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded occurred instant for state_event; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| reason | text | NOT NULL; default none | Non-key attribute | Reason belonging to state_event; Same local transaction as mutation and operation receipt. | Restricted free text/document/payload; may contain personal data |
| command_id | uuid | NOT NULL; default none | local FK (school_id,command_id) → operation_receipt(school_id,command_id) | Local operation_receipt.command_id, not AI OperationId automatically. | Scoped identifier; linkability/access control required |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(event_id)`.
- UNIQUE `(school_id, event_id)`.
- UNIQUE `(school_id, template_id, sequence_no)`.
- UNIQUE `(school_id, contract_id, sequence_no)`.
- UNIQUE `(school_id, document_id, sequence_no)`.
- UNIQUE `(school_id, document_version_id, sequence_no)`.

**Row CHECKs:**

- `num_nonnulls(template_id, contract_id, document_id, document_version_id) = 1`.
- `template_version_id IS NULL OR template_id IS NOT NULL`.
- `signed_copy_id IS NULL OR contract_id IS NOT NULL`.
- `length(trim(action)) > 0`.
- `sequence_no > 0`.
- `length(trim(reason)) > 0`.

**Lifecycle / immutable / audit:** See the current context contract and local SQL companion; service-only rules are not falsely certified by row CHECKs.

Immutable design attributes: `all attributes`.

## operation_receipt

Durable immutable command identity and terminal outcome with at most one typed result root.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| command_id | uuid | NOT NULL; default none | PK(command_id); UNIQUE(school_id,command_id) | Stable identifier within operation_receipt ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| school_id | uuid | NOT NULL; default none | UNIQUE(school_id,command_id); local FK (school_id,contract_id) → training_contract(school_id,contract_id); local FK (school_id,document_version_id) → document_version(school_id,document_version_id); local FK (school_id,template_id) → document_template(school_id,template_id); local FK (school_id,template_id,template_version_id) → template_version(school_id,template_id,template_version_id); local FK (school_id,document_id) → training_document(school_id,document_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| actor_id | uuid | NOT NULL; default none | Non-key attribute | External trusted UserId, not arbitrary client IdentityId. | Scoped identifier; linkability/access control required |
| template_id | uuid | NULL; default none | local FK (school_id,template_id) → document_template(school_id,template_id); local FK (school_id,template_id,template_version_id) → template_version(school_id,template_id,template_version_id) | Stable identifier within operation_receipt ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| template_version_id | uuid | NULL; default none | local FK (school_id,template_id,template_version_id) → template_version(school_id,template_id,template_version_id) | Stable identifier within operation_receipt ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| operation | varchar | NOT NULL; default none | Non-key attribute | Operation belonging to operation_receipt; Authorized Document Management command transaction. | Operational/configuration metadata; restricted if linked to a person |
| request_digest | varchar(64) | NOT NULL; default none | Non-key attribute | Canonical request digest; does not grant permission. | Operational/configuration metadata; restricted if linked to a person |
| status | varchar | NOT NULL; default none | Non-key attribute | Pending/Succeeded/Rejected/Indeterminate; terminal outcome cannot be edited/rebound. | Operational/configuration metadata; restricted if linked to a person |
| contract_id | uuid | NULL; default none | local FK (school_id,contract_id) → training_contract(school_id,contract_id) | Stable identifier within operation_receipt ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| document_id | uuid | NULL; default none | local FK (school_id,document_id) → training_document(school_id,document_id) | Stable identifier within operation_receipt ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| document_version_id | uuid | NULL; default none | local FK (school_id,document_version_id) → document_version(school_id,document_version_id) | Stable identifier within operation_receipt ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| outcome_code | varchar | NULL; default none | Non-key attribute | Outcome code belonging to operation_receipt; Authorized Document Management command transaction. | Operational/configuration metadata; restricted if linked to a person |
| created_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded created instant for operation_receipt; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| completed_at | timestamptz | NULL; default none | Non-key attribute | Recorded completed instant for operation_receipt; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(command_id)`.
- UNIQUE `(school_id, command_id)`.

**Row CHECKs:**

- `status IN ('Pending','Succeeded','Rejected','Indeterminate')`.
- `request_digest ~ '^[0-9a-f]{64}$'`.
- `(status IN ('Pending','Indeterminate') AND completed_at IS NULL) OR (status IN ('Succeeded','Rejected') AND completed_at IS NOT NULL)`.
- `completed_at IS NULL OR completed_at >= created_at`.
- `num_nonnulls(template_id, contract_id, document_id, document_version_id) <= 1`.
- `template_version_id IS NULL OR template_id IS NOT NULL`.
- `status NOT IN ('Succeeded','Rejected') OR outcome_code IS NOT NULL`.
- `length(trim(operation)) > 0 AND (outcome_code IS NULL OR length(trim(outcome_code)) > 0)`.

**Lifecycle / immutable / audit:** See the current context contract and local SQL companion; service-only rules are not falsely certified by row CHECKs.

Immutable design attributes: `command_id`, `school_id`, `actor_id`, `operation`, `request_digest`, `created_at`, `all attributes after terminal result`.

## evidence_checkpoint

Monotonic last-known LT dependency watermark per school/enrollment.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| school_id | uuid | NOT NULL; default none | PK(school_id,enrollment_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| enrollment_id | uuid | NOT NULL; default none | PK(school_id,enrollment_id) | Logical enrollment_id owned by School Management; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Scoped identifier; linkability/access control required |
| dependency_revision | bigint | NOT NULL; default none | Non-key attribute | Strictly monotonic known watermark; does not claim distributed instantaneous freshness. | Operational/configuration metadata; restricted if linked to a person |
| last_change_id | uuid | NOT NULL; default none | Non-key attribute | External LT source-change/correlation identity; no new local event aggregate. | Scoped identifier; linkability/access control required |
| observed_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded observed instant for evidence_checkpoint; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(school_id, enrollment_id)`.

**Row CHECKs:**

- `dependency_revision >= 0`.

**Lifecycle / immutable / audit:** See the current context contract and local SQL companion; service-only rules are not falsely certified by row CHECKs.

Immutable design attributes: `school_id`, `enrollment_id`.

## Enum vocabulary

Native enums absent; status vocabularies are in exact CHECKs and current context contract.

Supplemental partial indexes, exclusion/trigger/function rules and deployed CHECK definitions are recorded in [logical schema](logical-schema.md) and verification. External IDs are owner API references, not permission grants.
