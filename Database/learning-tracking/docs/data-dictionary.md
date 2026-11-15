# Learning Tracking — Data Dictionary

Current source: [learning-tracking-reviewed.dbml](../schema/schema.dbml), SHA-256 `38fb0d056882fe28948227a555f21be90631a9c40d65a4d137c9bd43b73da437`. Owner-adopted D-042, no ledger or programme transfer.

31 tables / 312 columns. This dictionary is an enriched source-derived specification, not a claim of deployed APIs. No cross-service FK.

Classification is conservative: even opaque identifiers/audit timestamps can be personal when linked. No legal retention duration or GDPR certification is inferred.

## training_program

School/category curriculum identity owning its immutable published versions.

Source model note: TrainingProgram aggregate identity. School/category are external domain references. No separate Course entity. Publication service permits at most one effective published version for this school/category/pathway.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id); UNIQUE(id,school_id,category_code) | Stable identifier within training_program ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); UNIQUE(id,school_id,category_code) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| category_code | varchar(16) | NOT NULL; default none | UNIQUE(id,school_id,category_code) | Category code belonging to training_program; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| name | varchar(200) | NOT NULL; default none | Non-key attribute | Name of training_program; generated/validated by this context, not an external identity key. | Operational/configuration metadata; restricted if linked to a person |
| created_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded created instant for training_program; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| revision | bigint | NOT NULL; default none | Non-key attribute | Positive version of this training_program consistency basis; handlers use exact expected revision/CAS, not CHECK alone. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- UNIQUE `(id, school_id, category_code)`.

**Row CHECKs:**

- `revision > 0` — program_revision_positive.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`, `created_at`.

## training_program_version

Complete versioned curriculum applicability, minute-unit policies and publication provenance; no automatic enrollment transfer.

Source model note: Owns the complete curriculum version. Draft editable; Published content and all curriculum children immutable; Retired retains content and historical applicability. No legal values are supplied. Retire/publish are audited. Effective retirement is not deletion or automatic enrollment transfer.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id); UNIQUE(id,school_id,program_id) | Stable identifier within training_program_version ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); UNIQUE(program_id,version,school_id); UNIQUE(id,school_id,program_id); local FK (program_id,school_id) → training_program(id,school_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| program_id | uuid | NOT NULL; default none | UNIQUE(program_id,version,school_id); UNIQUE(id,school_id,program_id); local FK (program_id,school_id) → training_program(id,school_id) | Stable identifier within training_program_version ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| version | int | NOT NULL; default none | UNIQUE(program_id,version,school_id) | Version belonging to training_program_version; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| status | lt_program_status | NOT NULL; default none | Non-key attribute | Lifecycle/evaluation state of training_program_version; enum/check vocabulary below; transition is not implied by a type alone. | Operational/configuration metadata; restricted if linked to a person |
| pathway_code | varchar(80) | NOT NULL; default none | Non-key attribute | Pathway code belonging to training_program_version; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| required_theory_minutes | int | NOT NULL; default none | Non-key attribute | Training-duration/configuration fact required_theory_minutes; owner programme/source basis applies. Demo values are not Lithuanian legal requirements. | Operational/configuration metadata; restricted if linked to a person |
| required_practical_minutes | int | NOT NULL; default none | Non-key attribute | Training-duration/configuration fact required_practical_minutes; owner programme/source basis applies. Demo values are not Lithuanian legal requirements. | Operational/configuration metadata; restricted if linked to a person |
| theory_minutes_per_unit | int | NOT NULL; default none | Non-key attribute | Training-duration/configuration fact theory_minutes_per_unit; owner programme/source basis applies. Demo values are not Lithuanian legal requirements. | Operational/configuration metadata; restricted if linked to a person |
| practical_minutes_per_unit | int | NOT NULL; default none | Non-key attribute | Training-duration/configuration fact practical_minutes_per_unit; owner programme/source basis applies. Demo values are not Lithuanian legal requirements. | Operational/configuration metadata; restricted if linked to a person |
| effective_from | date | NOT NULL; default none | Non-key attribute | Effective from belonging to training_program_version; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| effective_to | date | NULL; default none | Non-key attribute | Effective to belonging to training_program_version; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| legal_basis_verified | boolean | NOT NULL; default none | Non-key attribute | Legal basis verified belonging to training_program_version; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| created_by | uuid | NOT NULL; default none | Non-key attribute | Created by belonging to training_program_version; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| created_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded created instant for training_program_version; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| published_by | uuid | NULL; default none | Non-key attribute | Published by belonging to training_program_version; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| published_at | timestamptz | NULL; default none | Non-key attribute | Recorded published instant for training_program_version; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| retired_at | timestamptz | NULL; default none | Non-key attribute | Recorded retired instant for training_program_version; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| journal_checklist_version_id | uuid | NULL; default none | Non-key attribute | Stable identifier within training_program_version ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- UNIQUE `(program_id, version, school_id)`.
- UNIQUE `(id, school_id, program_id)`.

**Row CHECKs:**

- `version > 0` — program_version_positive.
- `required_theory_minutes >= 0 AND required_practical_minutes >= 0` — program_minutes_nonnegative.
- `theory_minutes_per_unit > 0 AND practical_minutes_per_unit > 0` — program_conversion_positive.
- `effective_to IS NULL OR effective_to >= effective_from` — program_effective_period.
- `(status = 'Draft' AND published_at IS NULL AND published_by IS NULL AND retired_at IS NULL) OR (status = 'Published' AND published_at IS NOT NULL AND published_by IS NOT NULL AND retired_at IS NULL AND legal_basis_verified) OR (status = 'Retired' AND published_at IS NOT NULL AND published_by IS NOT NULL AND retired_at IS NOT NULL AND retired_at >= published_at AND legal_basis_verified)` — program_publication_shape.
- `status = 'Draft' OR journal_checklist_version_id IS NOT NULL` — published_checklist.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`, `created_at`.

## program_rule_source

Version-owned rule source/edition/unit and applicability/verification evidence; URI alone proves no legal rule.

Source model note: Version-owned provenance and applicability. Explicit source/edition/unit/effective dates; a publication or regulated claim requires complete verified applicable rules. A URI is provenance, not proof of verification.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id) | Stable identifier within program_rule_source ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); local FK (program_version_id,school_id) → training_program_version(id,school_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| program_version_id | uuid | NOT NULL; default none | local FK (program_version_id,school_id) → training_program_version(id,school_id) | Stable identifier within program_rule_source ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| rule_code | varchar(80) | NOT NULL; default none | Non-key attribute | Rule code belonging to program_rule_source; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| source_uri | text | NOT NULL; default none | Non-key attribute | Source uri belonging to program_rule_source; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| source_edition | varchar(200) | NOT NULL; default none | Non-key attribute | Source edition belonging to program_rule_source; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| applicability | text | NOT NULL; default none | Non-key attribute | Applicability belonging to program_rule_source; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| verified_by | uuid | NULL; default none | Non-key attribute | Verified by belonging to program_rule_source; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| verified_at | timestamptz | NULL; default none | Non-key attribute | Recorded verified instant for program_rule_source; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| effective_from | date | NOT NULL; default none | Non-key attribute | Effective from belonging to program_rule_source; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| effective_to | date | NULL; default none | Non-key attribute | Effective to belonging to program_rule_source; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| unit_description | varchar(120) | NOT NULL; default none | Non-key attribute | Unit description belonging to program_rule_source; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.

**Row CHECKs:**

- `(verified_by IS NULL) = (verified_at IS NULL)` — rule_verification_pair.
- `effective_to IS NULL OR effective_to >= effective_from` — rule_effective_period.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`.

## training_topic

Version-owned topic catalogue used by practical records and assessments.

Source model note: Version-owned topic catalogue shared by practical records and assessment definitions. topic_key is stable within the programme lineage; changing a published title requires a new programme version.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id); UNIQUE(id,school_id,program_version_id) | Stable identifier within training_topic ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); UNIQUE(program_version_id,topic_key,school_id); UNIQUE(id,school_id,program_version_id); local FK (program_version_id,school_id) → training_program_version(id,school_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| program_version_id | uuid | NOT NULL; default none | UNIQUE(program_version_id,topic_key,school_id); UNIQUE(id,school_id,program_version_id); local FK (program_version_id,school_id) → training_program_version(id,school_id) | Stable identifier within training_topic ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| topic_key | varchar(80) | NOT NULL; default none | UNIQUE(program_version_id,topic_key,school_id) | Topic key belonging to training_topic; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| name | varchar(200) | NOT NULL; default none | Non-key attribute | Name of training_topic; generated/validated by this context, not an external identity key. | Operational/configuration metadata; restricted if linked to a person |
| description | text | NULL; default none | Non-key attribute | Description of training_topic; generated/validated by this context, not an external identity key. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- UNIQUE `(program_version_id, topic_key, school_id)`.
- UNIQUE `(id, school_id, program_version_id)`.

**Row CHECKs:**

- No additional DBML row CHECK; enum/key/nullability and companion rules still apply.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`.

## assessment_definition

Stable assessment identity/code within a programme; content is separately versioned.

Source model note: Stable identity only, owned by TrainingProgram; compatible with Scheduling.assessment_definition_id. Editable assessment content lives in assessment_definition_version. This is not an independent aggregate root.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id); UNIQUE(id,school_id,program_id) | Stable identifier within assessment_definition ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); UNIQUE(program_id,code,school_id); UNIQUE(id,school_id,program_id); local FK (program_id,school_id) → training_program(id,school_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| program_id | uuid | NOT NULL; default none | UNIQUE(program_id,code,school_id); UNIQUE(id,school_id,program_id); local FK (program_id,school_id) → training_program(id,school_id) | Stable identifier within assessment_definition ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| code | varchar(80) | NOT NULL; default none | UNIQUE(program_id,code,school_id) | Code of assessment_definition; generated/validated by this context, not an external identity key. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- UNIQUE `(program_id, code, school_id)`.
- UNIQUE `(id, school_id, program_id)`.

**Row CHECKs:**

- No additional DBML row CHECK; enum/key/nullability and companion rules still apply.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`.

## assessment_definition_version

One versioned assessment scale/stage/content record inside the exact programme version.

Source model note: Version-owned definition. Entire numeric scale/threshold frozen with curriculum. Topic marks use this scale and never determine overall outcome. Final prerequisites exclude the future assessment itself and its uncompleted duration.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id); UNIQUE(id,school_id,program_version_id); UNIQUE(id,school_id,definition_id) | Stable identifier within assessment_definition_version ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); UNIQUE(definition_id,program_version_id,school_id); UNIQUE(id,school_id,program_version_id); UNIQUE(id,school_id,definition_id); local FK (definition_id,school_id,program_id) → assessment_definition(id,school_id,program_id); local FK (program_version_id,school_id,program_id) → training_program_version(id,school_id,program_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| definition_id | uuid | NOT NULL; default none | UNIQUE(definition_id,program_version_id,school_id); UNIQUE(id,school_id,definition_id); local FK (definition_id,school_id,program_id) → assessment_definition(id,school_id,program_id) | Stable identifier within assessment_definition_version ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| program_id | uuid | NOT NULL; default none | local FK (definition_id,school_id,program_id) → assessment_definition(id,school_id,program_id); local FK (program_version_id,school_id,program_id) → training_program_version(id,school_id,program_id) | Stable identifier within assessment_definition_version ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| program_version_id | uuid | NOT NULL; default none | UNIQUE(definition_id,program_version_id,school_id); UNIQUE(id,school_id,program_version_id); local FK (program_version_id,school_id,program_id) → training_program_version(id,school_id,program_id) | Stable identifier within assessment_definition_version ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| name | varchar(200) | NOT NULL; default none | Non-key attribute | Name of assessment_definition_version; generated/validated by this context, not an external identity key. | Operational/configuration metadata; restricted if linked to a person |
| training_kind | lt_training_kind | NOT NULL; default none | Non-key attribute | Training kind belonging to assessment_definition_version; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| stage | lt_assessment_stage | NOT NULL; default none | Non-key attribute | Stage belonging to assessment_definition_version; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| minimum_mark | int | NOT NULL; default none | Non-key attribute | Minimum mark belonging to assessment_definition_version; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| maximum_mark | int | NOT NULL; default none | Non-key attribute | Maximum mark belonging to assessment_definition_version; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| passing_mark | int | NOT NULL; default none | Non-key attribute | Passing mark belonging to assessment_definition_version; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| required_for_completion | boolean | NOT NULL; default none | Non-key attribute | Required for completion belonging to assessment_definition_version; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- UNIQUE `(definition_id, program_version_id, school_id)`.
- UNIQUE `(id, school_id, program_version_id)`.
- UNIQUE `(id, school_id, definition_id)`.

**Row CHECKs:**

- `minimum_mark < maximum_mark AND passing_mark >= minimum_mark AND passing_mark <= maximum_mark` — assessment_scale.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`.

## assessment_topic

Association selecting a programme topic for a specific assessment-definition version.

Source model note: Selected programme topics for one assessment definition version; not an independent topic catalogue.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id); UNIQUE(id,school_id,definition_version_id) | Stable identifier within assessment_topic ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); UNIQUE(definition_version_id,topic_id,school_id); UNIQUE(id,school_id,definition_version_id); local FK (definition_version_id,school_id,program_version_id) → assessment_definition_version(id,school_id,program_version_id); local FK (topic_id,school_id,program_version_id) → training_topic(id,school_id,program_version_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| definition_version_id | uuid | NOT NULL; default none | UNIQUE(definition_version_id,topic_id,school_id); UNIQUE(id,school_id,definition_version_id); local FK (definition_version_id,school_id,program_version_id) → assessment_definition_version(id,school_id,program_version_id) | Stable identifier within assessment_topic ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| program_version_id | uuid | NOT NULL; default none | local FK (definition_version_id,school_id,program_version_id) → assessment_definition_version(id,school_id,program_version_id); local FK (topic_id,school_id,program_version_id) → training_topic(id,school_id,program_version_id) | Stable identifier within assessment_topic ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| topic_id | uuid | NOT NULL; default none | UNIQUE(definition_version_id,topic_id,school_id); local FK (topic_id,school_id,program_version_id) → training_topic(id,school_id,program_version_id) | Stable identifier within assessment_topic ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- UNIQUE `(definition_version_id, topic_id, school_id)`.
- UNIQUE `(id, school_id, definition_version_id)`.

**Row CHECKs:**

- No additional DBML row CHECK; enum/key/nullability and companion rules still apply.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`.

## admission_requirement

One typed formal prerequisite directly owned by an assessment-definition version; no shared M:N requirement catalogue.

Source model note: One independently identifiable, version-owned requirement belongs to exactly one assessment_definition_version; no M:N sharing across assessments. The curriculum version is frozen by the composite FK to assessment_definition_version. Duplicate requirement codes within one definition version are rejected, but different definitions may use the same code. Four typed conditions are conjunctive. Service validates prerequisite graph, mark scale, published programme and same-version applicability.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id); UNIQUE(id,school_id,definition_version_id) | Stable identifier within admission_requirement ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); UNIQUE(definition_version_id,code,school_id); UNIQUE(id,school_id,definition_version_id); local FK (definition_version_id,school_id,program_version_id) → assessment_definition_version(id,school_id,program_version_id); local FK (prerequisite_definition_version_id,school_id,program_version_id) → assessment_definition_version(id,school_id,program_version_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| definition_version_id | uuid | NOT NULL; default none | UNIQUE(definition_version_id,code,school_id); UNIQUE(id,school_id,definition_version_id); local FK (definition_version_id,school_id,program_version_id) → assessment_definition_version(id,school_id,program_version_id) | Stable identifier within admission_requirement ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| program_version_id | uuid | NOT NULL; default none | local FK (definition_version_id,school_id,program_version_id) → assessment_definition_version(id,school_id,program_version_id); local FK (prerequisite_definition_version_id,school_id,program_version_id) → assessment_definition_version(id,school_id,program_version_id) | Stable identifier within admission_requirement ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| code | varchar(80) | NOT NULL; default none | UNIQUE(definition_version_id,code,school_id) | Code of admission_requirement; generated/validated by this context, not an external identity key. | Operational/configuration metadata; restricted if linked to a person |
| kind | lt_requirement_kind | NOT NULL; default none | Non-key attribute | Kind belonging to admission_requirement; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| minimum_minutes | int | NULL; default none | Non-key attribute | Training-duration/configuration fact minimum_minutes; owner programme/source basis applies. Demo values are not Lithuanian legal requirements. | Operational/configuration metadata; restricted if linked to a person |
| prerequisite_definition_version_id | uuid | NULL; default none | local FK (prerequisite_definition_version_id,school_id,program_version_id) → assessment_definition_version(id,school_id,program_version_id) | Stable identifier within admission_requirement ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| minimum_mark | int | NULL; default none | Non-key attribute | Minimum mark belonging to admission_requirement; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- UNIQUE `(definition_version_id, code, school_id)`.
- UNIQUE `(id, school_id, definition_version_id)`.

**Row CHECKs:**

- `(kind IN ('MinimumTheoryMinutes','MinimumPracticalMinutes') AND minimum_minutes IS NOT NULL AND minimum_minutes >= 0 AND prerequisite_definition_version_id IS NULL AND minimum_mark IS NULL) OR (kind = 'AssessmentPassed' AND minimum_minutes IS NULL AND prerequisite_definition_version_id IS NOT NULL AND minimum_mark IS NULL) OR (kind = 'MinimumMark' AND minimum_minutes IS NULL AND prerequisite_definition_version_id IS NOT NULL AND minimum_mark IS NOT NULL)` — requirement_typed_shape.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`.

## student_training

EnrollmentId-backed learning aggregate with initially nullable then pinned programme binding and dependency revision; current credit remains derived.

Source model note: StudentTraining aggregate: id IS external EnrollmentId (not a new enrollment identity). Student/category are verified scoped references, not identity ownership. program_version_id is assigned once after verified enrollment/group/programme applicability; it is pinned for the enrollment. Unassigned initialization is allowed but cannot earn credit, approve readiness or submit Scheduling requests. No reassignment/transfer after assignment: reject instead of silently recalculating credit, results or legal basis. program_assigned_by/at record the initial binding. dependency_revision invalidates derived decisions/snapshots; no stored/editable credited-hour totals or percentage column. Deduplicated progress is derived from current eligible practical/theory facts.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id); UNIQUE(id,school_id,category_code); UNIQUE(id,school_id,student_id); UNIQUE(id,school_id,program_version_id) | External School Management EnrollmentId reused as StudentTraining business identity; not a new TrainingId. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); UNIQUE(id,school_id,category_code); UNIQUE(id,school_id,student_id); UNIQUE(id,school_id,program_version_id); local FK (program_version_id,school_id) → training_program_version(id,school_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| student_id | uuid | NOT NULL; default none | UNIQUE(id,school_id,student_id) | Logical student_id owned by User Management; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Pseudonymous personal/security identifier |
| category_code | varchar(16) | NOT NULL; default none | UNIQUE(id,school_id,category_code) | Category code belonging to student_training; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| program_version_id | uuid | NULL; default none | UNIQUE(id,school_id,program_version_id); local FK (program_version_id,school_id) → training_program_version(id,school_id) | Initially unassigned or exactly one pinned LT curriculum version; no programme transfer in current MVP. | Scoped identifier; linkability/access control required |
| program_assigned_by | uuid | NULL; default none | Non-key attribute | Program assigned by belonging to student_training; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| program_assigned_at | timestamptz | NULL; default none | Non-key attribute | Recorded program assigned instant for student_training; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| dependency_revision | bigint | NOT NULL; default none | Non-key attribute | Local learning dependency/concurrency basis, not source lesson revision or a cached progress total. | Operational/configuration metadata; restricted if linked to a person |
| created_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded created instant for student_training; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- UNIQUE `(id, school_id, category_code)`.
- UNIQUE `(id, school_id, student_id)`.
- UNIQUE `(id, school_id, program_version_id)`.

**Row CHECKs:**

- `dependency_revision > 0` — training_dependency_positive.
- `(program_version_id IS NULL AND program_assigned_by IS NULL AND program_assigned_at IS NULL) OR (program_version_id IS NOT NULL AND program_assigned_by IS NOT NULL AND program_assigned_at IS NOT NULL)` — program_initial_assignment_pair.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`, `created_at`.

## lesson_source_snapshot

Immutable Scheduling-source version evidence; invalidation/non-completion may have null actual times and cannot award credit.

Source model note: Immutable verified copy of Scheduling physical state and version, not lesson ownership. Theory GroupId + MembershipRevision identify the source roster basis but no local participant projection is kept. As-of lesson roster is verified from Scheduling/School Management before teacher confirmation; complete immutable student attendance rows are retained on each theory record version. If historical roster cannot be verified, fail closed. lesson_revision is source optimistic revision, not an invented remote CompletionFactId; non-completion/invalidation may have NULL current actual times; prior actual intervals are preserved only on preceding immutable snapshots. First-seen invalidation needs no synthetic times. Only verified completed-and-valid sources can contribute hours.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id); UNIQUE(id,school_id,lesson_id) | Stable identifier within lesson_source_snapshot ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); UNIQUE(lesson_id,lesson_revision,school_id); UNIQUE(id,school_id,lesson_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| lesson_id | uuid | NOT NULL; default none | UNIQUE(lesson_id,lesson_revision,school_id); UNIQUE(id,school_id,lesson_id) | Logical lesson_id owned by Scheduling; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Scoped identifier; linkability/access control required |
| lesson_revision | int | NOT NULL; default none | UNIQUE(lesson_id,lesson_revision,school_id) | Exact retained lesson_revision of referenced source/configuration; records provenance, not a permanent authorization permit. | Operational/configuration metadata; restricted if linked to a person |
| kind | lt_training_kind | NOT NULL; default none | Non-key attribute | Kind belonging to lesson_source_snapshot; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| instructor_id | uuid | NOT NULL; default none | Non-key attribute | Stable identifier within lesson_source_snapshot ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| enrollment_id | uuid | NULL; default none | Non-key attribute | Logical enrollment_id owned by School Management; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Scoped identifier; linkability/access control required |
| student_id | uuid | NULL; default none | Non-key attribute | Logical student_id owned by User Management; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Pseudonymous personal/security identifier |
| vehicle_id | uuid | NULL; default none | Non-key attribute | Logical vehicle_id owned by Vehicle Management; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Scoped identifier; linkability/access control required |
| group_id | uuid | NULL; default none | Non-key attribute | Logical group_id owned by School Management; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Scoped identifier; linkability/access control required |
| membership_revision | bigint | NULL; default none | Non-key attribute | Exact retained membership_revision of referenced source/configuration; records provenance, not a permanent authorization permit. | Operational/configuration metadata; restricted if linked to a person |
| actual_start | timestamptz | NULL; default none | Non-key attribute | Ordered temporal bound for lesson_source_snapshot under the authoritative source/period contract. | Operational/configuration metadata; restricted if linked to a person |
| actual_end | timestamptz | NULL; default none | Non-key attribute | Ordered temporal bound for lesson_source_snapshot under the authoritative source/period contract. | Operational/configuration metadata; restricted if linked to a person |
| physically_completed | boolean | NOT NULL; default none | Non-key attribute | Physically completed belonging to lesson_source_snapshot; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| source_valid | boolean | NOT NULL; default none | Non-key attribute | Source valid belonging to lesson_source_snapshot; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| captured_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded captured instant for lesson_source_snapshot; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| source_event_id | uuid | NULL; default none | Non-key attribute | Stable identifier within lesson_source_snapshot ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- UNIQUE `(lesson_id, lesson_revision, school_id)`.
- UNIQUE `(id, school_id, lesson_id)`.

**Row CHECKs:**

- `lesson_revision > 0` — source_revision_positive.
- `(actual_start IS NULL AND actual_end IS NULL) OR (actual_start IS NOT NULL AND actual_end IS NOT NULL AND actual_end > actual_start)` — source_actual_interval.
- `NOT (physically_completed AND source_valid) OR (actual_start IS NOT NULL AND actual_end IS NOT NULL)` — completed_source_requires_actuals.
- `(kind = 'Practical' AND enrollment_id IS NOT NULL AND student_id IS NOT NULL AND vehicle_id IS NOT NULL AND group_id IS NULL AND membership_revision IS NULL) OR (kind = 'Theory' AND enrollment_id IS NULL AND student_id IS NULL AND vehicle_id IS NULL AND group_id IS NOT NULL AND membership_revision IS NOT NULL AND membership_revision > 0)` — source_kind_shape.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`.

## lesson_source_state

One mutable current source-snapshot/freshness pointer per school lesson; never a copied authoritative lesson aggregate.

Source model note: Keep as a separate mutable pointer/freshness projection: immutable source snapshots must not be rewritten. Unique lesson per school; only verified authoritative evidence can advance pointer, with monotonically nondecreasing lesson revision and exact comparisons of significant typed source fields (no derived checksum field). An equal revision with different fields is a source conflict: keep the trusted pointer, set ReconciliationPending, audit and re-verify against Scheduling; a repeated identical version is a no-op. Late/replayed events cannot restore older snapshots. Current means last authoritative verification, not a timeless freshness guarantee; critical commands recheck source.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id) | Stable identifier within lesson_source_state ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); UNIQUE(lesson_id,school_id); local FK (current_snapshot_id,school_id,lesson_id) → lesson_source_snapshot(id,school_id,lesson_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| lesson_id | uuid | NOT NULL; default none | UNIQUE(lesson_id,school_id); local FK (current_snapshot_id,school_id,lesson_id) → lesson_source_snapshot(id,school_id,lesson_id) | Logical lesson_id owned by Scheduling; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Scoped identifier; linkability/access control required |
| current_snapshot_id | uuid | NOT NULL; default none | local FK (current_snapshot_id,school_id,lesson_id) → lesson_source_snapshot(id,school_id,lesson_id) | Stable identifier within lesson_source_state ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| freshness | lt_freshness | NOT NULL; default none | Non-key attribute | Freshness belonging to lesson_source_state; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| last_verified_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded last verified instant for lesson_source_state; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| reason | text | NULL; default none | Non-key attribute | Reason belonging to lesson_source_state; set by the owning application command/source contract, constrained below. | Restricted free text/document/payload; may contain personal data |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- UNIQUE `(lesson_id, school_id)`.

**Row CHECKs:**

- No additional DBML row CHECK; enum/key/nullability and companion rules still apply.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`.

## practical_training_record

One current-version identity/revision per lesson/enrollment practical journal record.

Source model note: PracticalTrainingRecord aggregate; one authoritative record per lesson/enrollment. Current pointer set atomically; Revision is local command concurrency, distinct from Scheduling lesson revision and fact version number.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id); UNIQUE(id,school_id,enrollment_id,lesson_id); local FK (current_version_id,school_id,id) → practical_record_version(id,school_id,record_id) | Stable identifier within practical_training_record ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); UNIQUE(lesson_id,enrollment_id,school_id); UNIQUE(id,school_id,enrollment_id,lesson_id); local FK (enrollment_id,school_id) → student_training(id,school_id); local FK (current_version_id,school_id,id) → practical_record_version(id,school_id,record_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| lesson_id | uuid | NOT NULL; default none | UNIQUE(lesson_id,enrollment_id,school_id); UNIQUE(id,school_id,enrollment_id,lesson_id) | Logical lesson_id owned by Scheduling; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Scoped identifier; linkability/access control required |
| enrollment_id | uuid | NOT NULL; default none | UNIQUE(lesson_id,enrollment_id,school_id); UNIQUE(id,school_id,enrollment_id,lesson_id); local FK (enrollment_id,school_id) → student_training(id,school_id) | Logical enrollment_id owned by School Management; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Scoped identifier; linkability/access control required |
| current_version_id | uuid | NULL; default none | local FK (current_version_id,school_id,id) → practical_record_version(id,school_id,record_id) | Stable identifier within practical_training_record ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| revision | bigint | NOT NULL; default none | Non-key attribute | Positive version of this practical_training_record consistency basis; handlers use exact expected revision/CAS, not CHECK alone. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- UNIQUE `(lesson_id, enrollment_id, school_id)`.
- UNIQUE `(id, school_id, enrollment_id, lesson_id)`.
- INDEX `(school_id, enrollment_id)` — idx_practical_by_enrollment.

**Row CHECKs:**

- `revision > 0` — practical_revision_positive.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`.

## practical_record_version

Immutable material practical fact version with exact source/programme basis, duration/distance and correction reason.

Source model note: Immutable material facts: source, training minutes, distance and selected topics. Valid requires physically completed authoritative source, required checklist fields/topics, nonnegative distance and 0 < training_minutes <= actual interval minus breaks. Shorter duration requires explanation. New version after dispute even if material facts unchanged. Current eligibility derived from validation, source and exact-version response history.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id); UNIQUE(id,school_id,record_id); UNIQUE(id,school_id,program_version_id); UNIQUE(id,school_id,enrollment_id) | Stable identifier within practical_record_version ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); UNIQUE(record_id,version,school_id); UNIQUE(id,school_id,record_id); UNIQUE(id,school_id,program_version_id); UNIQUE(id,school_id,enrollment_id); local FK (record_id,school_id,enrollment_id,lesson_id) → practical_training_record(id,school_id,enrollment_id,lesson_id); local FK (enrollment_id,school_id,program_version_id) → student_training(id,school_id,program_version_id); local FK (source_snapshot_id,school_id,lesson_id) → lesson_source_snapshot(id,school_id,lesson_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| record_id | uuid | NOT NULL; default none | UNIQUE(record_id,version,school_id); UNIQUE(id,school_id,record_id); local FK (record_id,school_id,enrollment_id,lesson_id) → practical_training_record(id,school_id,enrollment_id,lesson_id) | Stable identifier within practical_record_version ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| enrollment_id | uuid | NOT NULL; default none | UNIQUE(id,school_id,enrollment_id); local FK (record_id,school_id,enrollment_id,lesson_id) → practical_training_record(id,school_id,enrollment_id,lesson_id); local FK (enrollment_id,school_id,program_version_id) → student_training(id,school_id,program_version_id) | Logical enrollment_id owned by School Management; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Scoped identifier; linkability/access control required |
| lesson_id | uuid | NOT NULL; default none | local FK (record_id,school_id,enrollment_id,lesson_id) → practical_training_record(id,school_id,enrollment_id,lesson_id); local FK (source_snapshot_id,school_id,lesson_id) → lesson_source_snapshot(id,school_id,lesson_id) | Logical lesson_id owned by Scheduling; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Scoped identifier; linkability/access control required |
| program_version_id | uuid | NOT NULL; default none | UNIQUE(id,school_id,program_version_id); local FK (enrollment_id,school_id,program_version_id) → student_training(id,school_id,program_version_id) | Stable identifier within practical_record_version ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| version | int | NOT NULL; default none | UNIQUE(record_id,version,school_id) | Version belonging to practical_record_version; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| source_snapshot_id | uuid | NOT NULL; default none | local FK (source_snapshot_id,school_id,lesson_id) → lesson_source_snapshot(id,school_id,lesson_id) | Stable identifier within practical_record_version ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| training_minutes | int | NULL; default none | Non-key attribute | Training-duration/configuration fact training_minutes; owner programme/source basis applies. Demo values are not Lithuanian legal requirements. | Operational/configuration metadata; restricted if linked to a person |
| duration_explanation | text | NULL; default none | Non-key attribute | Duration explanation belonging to practical_record_version; set by the owning application command/source contract, constrained below. | Restricted free text/document/payload; may contain personal data |
| distance_km | numeric(10,3) | NULL; default none | Non-key attribute | Distance km belonging to practical_record_version; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| validation | lt_validation | NOT NULL; default none | Non-key attribute | Validation belonging to practical_record_version; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| validation_reason | text | NULL; default none | Non-key attribute | Validation reason belonging to practical_record_version; set by the owning application command/source contract, constrained below. | Restricted free text/document/payload; may contain personal data |
| created_by | uuid | NOT NULL; default none | Non-key attribute | Created by belonging to practical_record_version; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| created_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded created instant for practical_record_version; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| correction_reason | text | NULL; default none | Non-key attribute | Correction reason belonging to practical_record_version; set by the owning application command/source contract, constrained below. | Restricted free text/document/payload; may contain personal data |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- UNIQUE `(record_id, version, school_id)`.
- UNIQUE `(id, school_id, record_id)`.
- UNIQUE `(id, school_id, program_version_id)`.
- UNIQUE `(id, school_id, enrollment_id)`.

**Row CHECKs:**

- `version > 0` — practical_version_positive.
- `training_minutes IS NULL OR training_minutes > 0` — practical_minutes.
- `distance_km IS NULL OR distance_km >= 0` — practical_distance.
- `validation <> 'Valid' OR (training_minutes IS NOT NULL AND distance_km IS NOT NULL)` — practical_valid_shape.
- `version = 1 OR (correction_reason IS NOT NULL AND length(trim(correction_reason)) > 0)` — practical_correction_reason.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`, `created_at`.

## practical_record_topic

Selected version-owned programme topics for a whole practical fact; no artificial minute allocation by topic.

Source model note: Multiple programme topics; minutes/distance belong to whole record, never apportioned per topic.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id) | Stable identifier within practical_record_topic ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); UNIQUE(record_version_id,topic_id,school_id); local FK (record_version_id,school_id,program_version_id) → practical_record_version(id,school_id,program_version_id); local FK (topic_id,school_id,program_version_id) → training_topic(id,school_id,program_version_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| record_version_id | uuid | NOT NULL; default none | UNIQUE(record_version_id,topic_id,school_id); local FK (record_version_id,school_id,program_version_id) → practical_record_version(id,school_id,program_version_id) | Stable identifier within practical_record_topic ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| program_version_id | uuid | NOT NULL; default none | local FK (record_version_id,school_id,program_version_id) → practical_record_version(id,school_id,program_version_id); local FK (topic_id,school_id,program_version_id) → training_topic(id,school_id,program_version_id) | Stable identifier within practical_record_topic ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| topic_id | uuid | NOT NULL; default none | UNIQUE(record_version_id,topic_id,school_id); local FK (topic_id,school_id,program_version_id) → training_topic(id,school_id,program_version_id) | Stable identifier within practical_record_topic ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- UNIQUE `(record_version_id, topic_id, school_id)`.

**Row CHECKs:**

- No additional DBML row CHECK; enum/key/nullability and companion rules still apply.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`.

## practical_record_response

Append-only exact-version instructor/student confirmation/dispute evidence with idempotent command key.

Source model note: Append-only confirmations/disputes. Actor must be assigned instructor or enrolled student from authoritative source. Confirm is accepted once per role/current version; exact retries return prior response via command_id. A later dispute is allowed after both confirmations and permanently closes this version for credit; resolution requires a new version. Administrator cannot sign for either participant.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id); UNIQUE(id,school_id,record_version_id) | Stable identifier within practical_record_response ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); UNIQUE(record_id,sequence,school_id); UNIQUE(command_id,school_id); UNIQUE(id,school_id,record_version_id); local FK (record_version_id,school_id,record_id) → practical_record_version(id,school_id,record_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| record_id | uuid | NOT NULL; default none | UNIQUE(record_id,sequence,school_id); local FK (record_version_id,school_id,record_id) → practical_record_version(id,school_id,record_id) | Stable identifier within practical_record_response ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| record_version_id | uuid | NOT NULL; default none | UNIQUE(id,school_id,record_version_id); local FK (record_version_id,school_id,record_id) → practical_record_version(id,school_id,record_id) | Stable identifier within practical_record_response ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| sequence | bigint | NOT NULL; default none | UNIQUE(record_id,sequence,school_id) | Sequence belonging to practical_record_response; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| actor_id | uuid | NOT NULL; default none | Non-key attribute | Stable identifier within practical_record_response ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| actor_role | lt_response_role | NOT NULL; default none | Non-key attribute | Actor role belonging to practical_record_response; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| response | lt_response_kind | NOT NULL; default none | Non-key attribute | Response belonging to practical_record_response; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| responded_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded responded instant for practical_record_response; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| reason | text | NULL; default none | Non-key attribute | Reason belonging to practical_record_response; set by the owning application command/source contract, constrained below. | Restricted free text/document/payload; may contain personal data |
| command_id | uuid | NOT NULL; default none | UNIQUE(command_id,school_id) | Stable identifier within practical_record_response ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- UNIQUE `(record_id, sequence, school_id)`.
- UNIQUE `(command_id, school_id)`.
- UNIQUE `(id, school_id, record_version_id)`.
- INDEX `(record_version_id, actor_role, response)` — idx_practical_response_eligibility.

**Row CHECKs:**

- `sequence > 0` — response_sequence.
- `response <> 'Dispute' OR (reason IS NOT NULL AND length(trim(reason)) > 0)` — dispute_reason.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`.

## theory_training_record

Current-version identity/revision for one theory lesson; teacher-reviewed roster required for credit.

Source model note: TheoryTrainingRecord aggregate for one group lesson. Teacher explicitly reviews the full frozen participant roster and absent exceptions before confirming; no automatic credit on lesson completion.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id); UNIQUE(id,school_id,lesson_id); local FK (current_version_id,school_id,id) → theory_record_version(id,school_id,record_id) | Stable identifier within theory_training_record ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); UNIQUE(lesson_id,school_id); UNIQUE(id,school_id,lesson_id); local FK (current_version_id,school_id,id) → theory_record_version(id,school_id,record_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| lesson_id | uuid | NOT NULL; default none | UNIQUE(lesson_id,school_id); UNIQUE(id,school_id,lesson_id) | Logical lesson_id owned by Scheduling; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Scoped identifier; linkability/access control required |
| current_version_id | uuid | NULL; default none | local FK (current_version_id,school_id,id) → theory_record_version(id,school_id,record_id) | Stable identifier within theory_training_record ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| revision | bigint | NOT NULL; default none | Non-key attribute | Positive version of this theory_training_record consistency basis; handlers use exact expected revision/CAS, not CHECK alone. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- UNIQUE `(lesson_id, school_id)`.
- UNIQUE `(id, school_id, lesson_id)`.

**Row CHECKs:**

- `revision > 0` — theory_revision_positive.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`.

## theory_record_version

Immutable theory duration/source facts and teacher confirmation, owning the full frozen attendance roster.

Source model note: Version owns full immutable Present/Absent roster, now the ONLY local persisted per-enrollment theory participant list. Before teacher confirmation, verify exact as-of lesson roster for source GroupId/MembershipRevision from Scheduling/School Management; reject omitted, extra, duplicate, cross-tenant, wrong-student or unavailable participants. Instructor, source revision and study duration are checked; 0 < study minutes <= actual interval. Corrections create new versions. Present gets full minutes, Absent zero; partial attendance not supported. Student confirmation not required.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id); UNIQUE(id,school_id,record_id); UNIQUE(id,school_id,lesson_id) | Stable identifier within theory_record_version ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); UNIQUE(record_id,version,school_id); UNIQUE(id,school_id,record_id); UNIQUE(id,school_id,lesson_id); local FK (record_id,school_id,lesson_id) → theory_training_record(id,school_id,lesson_id); local FK (source_snapshot_id,school_id,lesson_id) → lesson_source_snapshot(id,school_id,lesson_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| record_id | uuid | NOT NULL; default none | UNIQUE(record_id,version,school_id); UNIQUE(id,school_id,record_id); local FK (record_id,school_id,lesson_id) → theory_training_record(id,school_id,lesson_id) | Stable identifier within theory_record_version ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| lesson_id | uuid | NOT NULL; default none | UNIQUE(id,school_id,lesson_id); local FK (record_id,school_id,lesson_id) → theory_training_record(id,school_id,lesson_id); local FK (source_snapshot_id,school_id,lesson_id) → lesson_source_snapshot(id,school_id,lesson_id) | Logical lesson_id owned by Scheduling; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Scoped identifier; linkability/access control required |
| version | int | NOT NULL; default none | UNIQUE(record_id,version,school_id) | Version belonging to theory_record_version; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| source_snapshot_id | uuid | NOT NULL; default none | local FK (source_snapshot_id,school_id,lesson_id) → lesson_source_snapshot(id,school_id,lesson_id) | Stable identifier within theory_record_version ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| training_minutes | int | NOT NULL; default none | Non-key attribute | Training-duration/configuration fact training_minutes; owner programme/source basis applies. Demo values are not Lithuanian legal requirements. | Operational/configuration metadata; restricted if linked to a person |
| duration_explanation | text | NULL; default none | Non-key attribute | Duration explanation belonging to theory_record_version; set by the owning application command/source contract, constrained below. | Restricted free text/document/payload; may contain personal data |
| validation | lt_validation | NOT NULL; default none | Non-key attribute | Validation belonging to theory_record_version; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| created_by | uuid | NOT NULL; default none | Non-key attribute | Created by belonging to theory_record_version; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| created_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded created instant for theory_record_version; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| confirmed_by | uuid | NULL; default none | Non-key attribute | Confirmed by belonging to theory_record_version; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| confirmed_at | timestamptz | NULL; default none | Non-key attribute | Recorded confirmed instant for theory_record_version; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| correction_reason | text | NULL; default none | Non-key attribute | Correction reason belonging to theory_record_version; set by the owning application command/source contract, constrained below. | Restricted free text/document/payload; may contain personal data |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- UNIQUE `(record_id, version, school_id)`.
- UNIQUE `(id, school_id, record_id)`.
- UNIQUE `(id, school_id, lesson_id)`.

**Row CHECKs:**

- `version > 0 AND training_minutes > 0` — theory_positive.
- `(confirmed_by IS NULL) = (confirmed_at IS NULL)` — theory_confirmation_pair.
- `confirmed_at IS NULL OR validation = 'Valid'` — theory_confirmed_valid.
- `version = 1 OR (correction_reason IS NOT NULL AND length(trim(correction_reason)) > 0)` — theory_correction_reason.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`, `created_at`.

## theory_attendance

One exact-version Present/Absent result for one eligible enrollment/student; no separate duplicate source-participant ledger.

Source model note: Single authoritative local frozen participant roster: one Present/Absent row per eligible as-of Scheduling group member for this teacher-confirmed theory record version. Service compares the complete set to trusted historical as-of membership at lesson revision; no separate lesson_source_participant copy. Present contributes once only when current, Valid, teacher-confirmed and source verified; Absent/superseded rows contribute zero. All fields scoped to SchoolId/EnrollmentId; no credit ledger.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id); UNIQUE(id,school_id,enrollment_id) | Stable identifier within theory_attendance ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); UNIQUE(id,school_id,enrollment_id); UNIQUE(record_version_id,enrollment_id,school_id); local FK (record_version_id,school_id) → theory_record_version(id,school_id); local FK (enrollment_id,school_id,student_id) → student_training(id,school_id,student_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| record_version_id | uuid | NOT NULL; default none | UNIQUE(record_version_id,enrollment_id,school_id); local FK (record_version_id,school_id) → theory_record_version(id,school_id) | Stable identifier within theory_attendance ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| enrollment_id | uuid | NOT NULL; default none | UNIQUE(id,school_id,enrollment_id); UNIQUE(record_version_id,enrollment_id,school_id); local FK (enrollment_id,school_id,student_id) → student_training(id,school_id,student_id) | Logical enrollment_id owned by School Management; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Scoped identifier; linkability/access control required |
| student_id | uuid | NOT NULL; default none | local FK (enrollment_id,school_id,student_id) → student_training(id,school_id,student_id) | Logical student_id owned by User Management; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Pseudonymous personal/security identifier |
| attendance | lt_attendance | NOT NULL; default none | Non-key attribute | Ordered temporal bound for theory_attendance under the authoritative source/period contract. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- UNIQUE `(id, school_id, enrollment_id)`.
- UNIQUE `(record_version_id, enrollment_id, school_id)`.
- INDEX `(school_id, enrollment_id, record_version_id)` — idx_theory_attendance_by_enrollment.

**Row CHECKs:**

- No additional DBML row CHECK; enum/key/nullability and companion rules still apply.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`.

## assessment_readiness

Current evaluation/decision pointers for one enrollment/pinned-programme/Final-definition readiness aggregate.

Source model note: AssessmentReadiness aggregate for enrollment/pinned programme version/selected Final definition. Formal prerequisites and human decision remain separate. No calendar expiry. Source/rule/fact/permission changes invalidate affected approvals via one-time decision terminal metadata plus append-only audit; new evaluation never revives a terminally invalidated approval.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id); UNIQUE(id,school_id,enrollment_id); UNIQUE(id,school_id,definition_version_id); UNIQUE(id,school_id,enrollment_id,definition_version_id); local FK (current_evaluation_id,school_id,id) → readiness_evaluation(id,school_id,readiness_id); local FK (current_decision_id,school_id,id) → readiness_decision(id,school_id,readiness_id) | Stable identifier within assessment_readiness ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); UNIQUE(enrollment_id,program_version_id,definition_version_id,school_id); UNIQUE(id,school_id,enrollment_id); UNIQUE(id,school_id,definition_version_id); UNIQUE(id,school_id,enrollment_id,definition_version_id); local FK (enrollment_id,school_id,program_version_id) → student_training(id,school_id,program_version_id); local FK (definition_version_id,school_id,program_version_id) → assessment_definition_version(id,school_id,program_version_id); local FK (current_evaluation_id,school_id,id) → readiness_evaluation(id,school_id,readiness_id); local FK (current_decision_id,school_id,id) → readiness_decision(id,school_id,readiness_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| enrollment_id | uuid | NOT NULL; default none | UNIQUE(enrollment_id,program_version_id,definition_version_id,school_id); UNIQUE(id,school_id,enrollment_id); UNIQUE(id,school_id,enrollment_id,definition_version_id); local FK (enrollment_id,school_id,program_version_id) → student_training(id,school_id,program_version_id) | Logical enrollment_id owned by School Management; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Scoped identifier; linkability/access control required |
| program_version_id | uuid | NOT NULL; default none | UNIQUE(enrollment_id,program_version_id,definition_version_id,school_id); local FK (enrollment_id,school_id,program_version_id) → student_training(id,school_id,program_version_id); local FK (definition_version_id,school_id,program_version_id) → assessment_definition_version(id,school_id,program_version_id) | Stable identifier within assessment_readiness ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| definition_version_id | uuid | NOT NULL; default none | UNIQUE(enrollment_id,program_version_id,definition_version_id,school_id); UNIQUE(id,school_id,definition_version_id); UNIQUE(id,school_id,enrollment_id,definition_version_id); local FK (definition_version_id,school_id,program_version_id) → assessment_definition_version(id,school_id,program_version_id) | Stable identifier within assessment_readiness ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| current_evaluation_id | uuid | NULL; default none | local FK (current_evaluation_id,school_id,id) → readiness_evaluation(id,school_id,readiness_id) | Stable identifier within assessment_readiness ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| current_decision_id | uuid | NULL; default none | local FK (current_decision_id,school_id,id) → readiness_decision(id,school_id,readiness_id) | Stable identifier within assessment_readiness ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| revision | bigint | NOT NULL; default none | Non-key attribute | Positive version of this assessment_readiness consistency basis; handlers use exact expected revision/CAS, not CHECK alone. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- UNIQUE `(enrollment_id, program_version_id, definition_version_id, school_id)`.
- UNIQUE `(id, school_id, enrollment_id)`.
- UNIQUE `(id, school_id, definition_version_id)`.
- UNIQUE `(id, school_id, enrollment_id, definition_version_id)`.

**Row CHECKs:**

- `revision > 0` — readiness_revision_positive.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`.

## readiness_evaluation

Immutable formal prerequisite evaluation against one observed dependency revision.

Source model note: Immutable evaluation of all directly owned pre-assessment requirements. Unverified source/legal applicability never satisfies a mandatory condition. Consolidated readiness_evidence_basis rows retain exact contributing current practical-record versions, theory attendance rows and result versions as observed at evaluation; no stored credit ledger. Material fact, source or applicable legal-rule changes force current revalidation; publishing a new programme version alone does not reassign learners.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id); UNIQUE(id,school_id,readiness_id); UNIQUE(id,school_id,enrollment_id); UNIQUE(id,school_id,definition_version_id) | Stable identifier within readiness_evaluation ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); UNIQUE(id,school_id,readiness_id); UNIQUE(id,school_id,enrollment_id); UNIQUE(id,school_id,definition_version_id); local FK (readiness_id,school_id,enrollment_id) → assessment_readiness(id,school_id,enrollment_id); local FK (readiness_id,school_id,definition_version_id) → assessment_readiness(id,school_id,definition_version_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| readiness_id | uuid | NOT NULL; default none | UNIQUE(id,school_id,readiness_id); local FK (readiness_id,school_id,enrollment_id) → assessment_readiness(id,school_id,enrollment_id); local FK (readiness_id,school_id,definition_version_id) → assessment_readiness(id,school_id,definition_version_id) | Stable identifier within readiness_evaluation ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| enrollment_id | uuid | NOT NULL; default none | UNIQUE(id,school_id,enrollment_id); local FK (readiness_id,school_id,enrollment_id) → assessment_readiness(id,school_id,enrollment_id) | Logical enrollment_id owned by School Management; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Scoped identifier; linkability/access control required |
| definition_version_id | uuid | NOT NULL; default none | UNIQUE(id,school_id,definition_version_id); local FK (readiness_id,school_id,definition_version_id) → assessment_readiness(id,school_id,definition_version_id) | Stable identifier within readiness_evaluation ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| dependency_revision | bigint | NOT NULL; default none | Non-key attribute | Positive version of this readiness_evaluation consistency basis; handlers use exact expected revision/CAS, not CHECK alone. | Operational/configuration metadata; restricted if linked to a person |
| formal_status | lt_formal_status | NOT NULL; default none | Non-key attribute | Formal status belonging to readiness_evaluation; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| evaluated_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded evaluated instant for readiness_evaluation; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| evaluated_by | uuid | NOT NULL; default none | Non-key attribute | Evaluated by belonging to readiness_evaluation; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| explanation | text | NOT NULL; default none | Non-key attribute | Explanation belonging to readiness_evaluation; set by the owning application command/source contract, constrained below. | Restricted free text/document/payload; may contain personal data |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- UNIQUE `(id, school_id, readiness_id)`.
- UNIQUE `(id, school_id, enrollment_id)`.
- UNIQUE `(id, school_id, definition_version_id)`.

**Row CHECKs:**

- `dependency_revision > 0` — evaluation_dependency_positive.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`.

## readiness_requirement_result

One immutable observed prerequisite result within an exact definition/evaluation, nullable observations mean unavailable/not applicable.

Source model note: One immutable result per requirement owned by the evaluated assessment definition version. Two composite FKs enforce that the requirement and evaluation refer to that exact definition version (and school); no M:N membership lookup. NULL observations mean not applicable or unavailable, not zero.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id) | Stable identifier within readiness_requirement_result ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); UNIQUE(evaluation_id,requirement_id,school_id); local FK (evaluation_id,school_id,definition_version_id) → readiness_evaluation(id,school_id,definition_version_id); local FK (requirement_id,school_id,definition_version_id) → admission_requirement(id,school_id,definition_version_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| evaluation_id | uuid | NOT NULL; default none | UNIQUE(evaluation_id,requirement_id,school_id); local FK (evaluation_id,school_id,definition_version_id) → readiness_evaluation(id,school_id,definition_version_id) | Stable identifier within readiness_requirement_result ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| definition_version_id | uuid | NOT NULL; default none | local FK (evaluation_id,school_id,definition_version_id) → readiness_evaluation(id,school_id,definition_version_id); local FK (requirement_id,school_id,definition_version_id) → admission_requirement(id,school_id,definition_version_id) | Stable identifier within readiness_requirement_result ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| requirement_id | uuid | NOT NULL; default none | UNIQUE(evaluation_id,requirement_id,school_id); local FK (requirement_id,school_id,definition_version_id) → admission_requirement(id,school_id,definition_version_id) | Stable identifier within readiness_requirement_result ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| status | lt_formal_status | NOT NULL; default none | Non-key attribute | Lifecycle/evaluation state of readiness_requirement_result; enum/check vocabulary below; transition is not implied by a type alone. | Operational/configuration metadata; restricted if linked to a person |
| observed_minutes | int | NULL; default none | Non-key attribute | Training-duration/configuration fact observed_minutes; owner programme/source basis applies. Demo values are not Lithuanian legal requirements. | Operational/configuration metadata; restricted if linked to a person |
| observed_mark | int | NULL; default none | Non-key attribute | Observed mark belonging to readiness_requirement_result; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| explanation | text | NOT NULL; default none | Non-key attribute | Explanation belonging to readiness_requirement_result; set by the owning application command/source contract, constrained below. | Restricted free text/document/payload; may contain personal data |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- UNIQUE `(evaluation_id, requirement_id, school_id)`.

**Row CHECKs:**

- `observed_minutes IS NULL OR observed_minutes >= 0` — observed_minutes_nonnegative.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`.

## readiness_evidence_basis

Immutable typed lesson/result basis frozen at evaluation, never reused as current credit authority.

Source model note: Immutable evaluation-time evidence shared by minute and assessment prerequisites, NOT current credit authority. One row has exactly one typed source: a current valid dual-confirmed practical version, a Present attendance row of a current verified teacher-confirmed theory version, or an eligible current assessment result version. Lesson rows freeze positive observed_minutes and lesson_id; assessment rows have neither. Unique per evaluation/lesson and per evaluation/result prevents duplicate evidence. Enforce exact school/enrollment/lesson/pinned-programme identity and currentness in application, not DBML. Never re-sum these frozen rows as current progress.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id) | Stable identifier within readiness_evidence_basis ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); UNIQUE(evaluation_id,lesson_id,school_id); UNIQUE(evaluation_id,result_version_id,school_id); local FK (evaluation_id,school_id,enrollment_id) → readiness_evaluation(id,school_id,enrollment_id); local FK (practical_record_version_id,school_id,enrollment_id) → practical_record_version(id,school_id,enrollment_id); local FK (theory_attendance_id,school_id,enrollment_id) → theory_attendance(id,school_id,enrollment_id); local FK (result_version_id,school_id,enrollment_id) → assessment_result_version(id,school_id,enrollment_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| evaluation_id | uuid | NOT NULL; default none | UNIQUE(evaluation_id,lesson_id,school_id); UNIQUE(evaluation_id,result_version_id,school_id); local FK (evaluation_id,school_id,enrollment_id) → readiness_evaluation(id,school_id,enrollment_id) | Stable identifier within readiness_evidence_basis ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| enrollment_id | uuid | NOT NULL; default none | local FK (evaluation_id,school_id,enrollment_id) → readiness_evaluation(id,school_id,enrollment_id); local FK (practical_record_version_id,school_id,enrollment_id) → practical_record_version(id,school_id,enrollment_id); local FK (theory_attendance_id,school_id,enrollment_id) → theory_attendance(id,school_id,enrollment_id); local FK (result_version_id,school_id,enrollment_id) → assessment_result_version(id,school_id,enrollment_id) | Logical enrollment_id owned by School Management; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Scoped identifier; linkability/access control required |
| lesson_id | uuid | NULL; default none | UNIQUE(evaluation_id,lesson_id,school_id) | Logical lesson_id owned by Scheduling; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Scoped identifier; linkability/access control required |
| practical_record_version_id | uuid | NULL; default none | local FK (practical_record_version_id,school_id,enrollment_id) → practical_record_version(id,school_id,enrollment_id) | Stable identifier within readiness_evidence_basis ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| theory_attendance_id | uuid | NULL; default none | local FK (theory_attendance_id,school_id,enrollment_id) → theory_attendance(id,school_id,enrollment_id) | Stable identifier within readiness_evidence_basis ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| result_version_id | uuid | NULL; default none | UNIQUE(evaluation_id,result_version_id,school_id); local FK (result_version_id,school_id,enrollment_id) → assessment_result_version(id,school_id,enrollment_id) | Stable identifier within readiness_evidence_basis ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| observed_minutes | int | NULL; default none | Non-key attribute | Training-duration/configuration fact observed_minutes; owner programme/source basis applies. Demo values are not Lithuanian legal requirements. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- UNIQUE `(evaluation_id, lesson_id, school_id)`.
- UNIQUE `(evaluation_id, result_version_id, school_id)`.
- INDEX `(school_id, enrollment_id, evaluation_id)` — idx_readiness_evidence_scope.

**Row CHECKs:**

- `((practical_record_version_id IS NOT NULL)::int + (theory_attendance_id IS NOT NULL)::int + (result_version_id IS NOT NULL)::int) = 1` — readiness_evidence_source_xor.
- `((practical_record_version_id IS NOT NULL OR theory_attendance_id IS NOT NULL) AND lesson_id IS NOT NULL AND observed_minutes IS NOT NULL AND observed_minutes > 0) OR (result_version_id IS NOT NULL AND lesson_id IS NULL AND observed_minutes IS NULL)` — readiness_evidence_typed_shape.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`.

## readiness_decision

Human assessment-approval decision with optional one-time terminal invalidation metadata; not automatically revived.

Source model note: One immutable human decision with optional one-time TERMINAL invalidation metadata for Approved only. Original evaluation, actor, time, outcome, reason, authority basis and command identity must never change. On relevant dependency/source/policy/permission change, atomically set all invalidation fields once, advance dependency revision, and append a restricted learning_audit_event under the same transaction. Do not let an approval become active again by clearing metadata or merely moving a current pointer. A PostgreSQL trigger / controlled write path is needed to prohibit editing or clearing terminal fields; DBML CHECK alone cannot enforce one-way changes. Current use also requires matching dependency_revision, current verified sources and permissions; null invalidated_at alone never proves readiness. invalidation_scope distinguishes prospective-only effects from potential retroactive defects. invalidation_effective_at records known effective time; NULL is allowed ONLY for HistoricalReviewRequired when the effective time is unresolved and forces review/hold. Historical performed assessment results are not automatically annulled by a later prospective-only change. NotApproved stays historical without invalidation.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id); UNIQUE(id,school_id,readiness_id); UNIQUE(id,school_id,enrollment_id) | Stable identifier within readiness_decision ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); UNIQUE(command_id,school_id); UNIQUE(id,school_id,readiness_id); UNIQUE(id,school_id,enrollment_id); local FK (evaluation_id,school_id,readiness_id) → readiness_evaluation(id,school_id,readiness_id); local FK (evaluation_id,school_id,enrollment_id) → readiness_evaluation(id,school_id,enrollment_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| readiness_id | uuid | NOT NULL; default none | UNIQUE(id,school_id,readiness_id); local FK (evaluation_id,school_id,readiness_id) → readiness_evaluation(id,school_id,readiness_id) | Stable identifier within readiness_decision ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| evaluation_id | uuid | NOT NULL; default none | local FK (evaluation_id,school_id,readiness_id) → readiness_evaluation(id,school_id,readiness_id); local FK (evaluation_id,school_id,enrollment_id) → readiness_evaluation(id,school_id,enrollment_id) | Stable identifier within readiness_decision ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| actor_id | uuid | NOT NULL; default none | Non-key attribute | Stable identifier within readiness_decision ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| decided_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded decided instant for readiness_decision; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| decision | lt_decision | NOT NULL; default none | Non-key attribute | Decision belonging to readiness_decision; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| reason | text | NOT NULL; default none | Non-key attribute | Reason belonging to readiness_decision; set by the owning application command/source contract, constrained below. | Restricted free text/document/payload; may contain personal data |
| authority_basis | text | NOT NULL; default none | Non-key attribute | Authority basis belonging to readiness_decision; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| command_id | uuid | NOT NULL; default none | UNIQUE(command_id,school_id) | Stable identifier within readiness_decision ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| invalidated_at | timestamptz | NULL; default none | Non-key attribute | Recorded invalidated instant for readiness_decision; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| invalidated_by | uuid | NULL; default none | Non-key attribute | Invalidated by belonging to readiness_decision; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| invalidation_reason | text | NULL; default none | Non-key attribute | Invalidation reason belonging to readiness_decision; set by the owning application command/source contract, constrained below. | Restricted free text/document/payload; may contain personal data |
| invalidation_dependency_revision | bigint | NULL; default none | Non-key attribute | Ordered temporal bound for readiness_decision under the authoritative source/period contract. | Operational/configuration metadata; restricted if linked to a person |
| invalidation_scope | lt_invalidation_scope | NULL; default none | Non-key attribute | Invalidation scope belonging to readiness_decision; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| invalidation_effective_at | timestamptz | NULL; default none | Non-key attribute | Recorded invalidation effective instant for readiness_decision; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| enrollment_id | uuid | NOT NULL; default none | UNIQUE(id,school_id,enrollment_id); local FK (evaluation_id,school_id,enrollment_id) → readiness_evaluation(id,school_id,enrollment_id) | Logical enrollment_id owned by School Management; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Scoped identifier; linkability/access control required |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- UNIQUE `(command_id, school_id)`.
- UNIQUE `(id, school_id, readiness_id)`.
- UNIQUE `(id, school_id, enrollment_id)`.

**Row CHECKs:**

- `decision <> 'NotApproved' OR length(trim(reason)) > 0` — decline_reason.
- `(invalidated_at IS NULL AND invalidated_by IS NULL AND invalidation_reason IS NULL AND invalidation_dependency_revision IS NULL AND invalidation_scope IS NULL AND invalidation_effective_at IS NULL) OR (decision = 'Approved' AND invalidated_at IS NOT NULL AND invalidated_by IS NOT NULL AND invalidation_reason IS NOT NULL AND length(trim(invalidation_reason)) > 0 AND invalidation_dependency_revision IS NOT NULL AND invalidation_dependency_revision > 0 AND invalidated_at >= decided_at AND invalidation_scope IS NOT NULL AND (invalidation_scope = 'HistoricalReviewRequired' OR (invalidation_scope = 'ProspectiveOnly' AND invalidation_effective_at IS NOT NULL AND invalidation_effective_at >= decided_at)))` — decision_terminal_invalidation_shape.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`.

## assessment

One performed assessment attempt; appointment remains external Scheduling identity and results are append-only versions.

Source model note: Assessment aggregate = one performed attempt, not a calendar booking. Immutable result versions are ordered by version; the current result is the version with MAX(version) for this (assessment_id,school_id). No mutable current_result_version_id, eligibility enum or reason projection. Access to the current result requires fresh status, school/enrollment/definition and Final readiness-basis validation, and fails closed when unverifiable. Assessor corrections/annulments append a new version under locked attempt and optimistic revision, never overwrite old versions.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id); UNIQUE(id,school_id,enrollment_id); UNIQUE(id,school_id,definition_version_id); UNIQUE(id,school_id,enrollment_id,definition_version_id) | Stable identifier within assessment ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); UNIQUE(enrollment_id,definition_version_id,attempt_number,school_id); UNIQUE(id,school_id,enrollment_id); UNIQUE(id,school_id,definition_version_id); UNIQUE(id,school_id,enrollment_id,definition_version_id); local FK (enrollment_id,school_id,program_version_id) → student_training(id,school_id,program_version_id); local FK (definition_version_id,school_id,program_version_id) → assessment_definition_version(id,school_id,program_version_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| enrollment_id | uuid | NOT NULL; default none | UNIQUE(enrollment_id,definition_version_id,attempt_number,school_id); UNIQUE(id,school_id,enrollment_id); UNIQUE(id,school_id,enrollment_id,definition_version_id); local FK (enrollment_id,school_id,program_version_id) → student_training(id,school_id,program_version_id) | Logical enrollment_id owned by School Management; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Scoped identifier; linkability/access control required |
| program_version_id | uuid | NOT NULL; default none | local FK (enrollment_id,school_id,program_version_id) → student_training(id,school_id,program_version_id); local FK (definition_version_id,school_id,program_version_id) → assessment_definition_version(id,school_id,program_version_id) | Stable identifier within assessment ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| definition_version_id | uuid | NOT NULL; default none | UNIQUE(enrollment_id,definition_version_id,attempt_number,school_id); UNIQUE(id,school_id,definition_version_id); UNIQUE(id,school_id,enrollment_id,definition_version_id); local FK (definition_version_id,school_id,program_version_id) → assessment_definition_version(id,school_id,program_version_id) | Stable identifier within assessment ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| attempt_number | int | NOT NULL; default none | UNIQUE(enrollment_id,definition_version_id,attempt_number,school_id) | Attempt number belonging to assessment; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| appointment_id | uuid | NULL; default none | Non-key attribute | Stable identifier within assessment ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| revision | bigint | NOT NULL; default none | Non-key attribute | Positive version of this assessment consistency basis; handlers use exact expected revision/CAS, not CHECK alone. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- UNIQUE `(enrollment_id, definition_version_id, attempt_number, school_id)`.
- UNIQUE `(id, school_id, enrollment_id)`.
- UNIQUE `(id, school_id, definition_version_id)`.
- UNIQUE `(id, school_id, enrollment_id, definition_version_id)`.

**Row CHECKs:**

- `attempt_number > 0 AND revision > 0` — assessment_attempt_positive.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`.

## assessment_result_version

Immutable result/correction/annulment version; current result is highest version per attempt, not a mutable pass flag.

Source model note: Append-only result version, with exact definition_version_id for tenant-safe linking to attempt, Final readiness and optional topic marks. Current version = highest version per attempt. Only version=1 may be initially Recorded; corrections/annulments are version>1 with required correction_reason. Unique command_id per school enables idempotent retry when combined with exact-payload verification. Annulled version keeps the historical mark/outcome as an explicit historical value but is never a current prerequisite. Current result status may be Recorded, ReviewRequired or Annulled. A Final approval revoked AFTER assessed_at for a prospectively effective reason does not annul that previously lawful attempt. Retrospective/unknown impact returns ReviewRequired unless an authorized later Recorded version explicitly references the reviewed invalidation timestamp; when invalidity is confirmed, append Annulled. A decision invalidated before assessed_at NEVER authorizes that examination. For new actions terminally invalidated approval remains unusable. Unknown/unverified evidence blocks release; a status query is not a stored eligibility flag. Stale historical versions remain FK-referenced as evidence but never current. Validate mark range, derived outcome, exact Final stage and authority in the service/transaction.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id); UNIQUE(id,school_id,assessment_id); UNIQUE(id,school_id,enrollment_id); UNIQUE(id,school_id,definition_version_id) | Stable identifier within assessment_result_version ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); UNIQUE(assessment_id,version,school_id); UNIQUE(command_id,school_id); UNIQUE(id,school_id,assessment_id); UNIQUE(id,school_id,enrollment_id); UNIQUE(id,school_id,definition_version_id); local FK (assessment_id,school_id,enrollment_id,definition_version_id) → assessment(id,school_id,enrollment_id,definition_version_id); local FK (readiness_id,school_id,enrollment_id,definition_version_id) → assessment_readiness(id,school_id,enrollment_id,definition_version_id); local FK (readiness_decision_id,school_id,readiness_id) → readiness_decision(id,school_id,readiness_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| assessment_id | uuid | NOT NULL; default none | UNIQUE(assessment_id,version,school_id); UNIQUE(id,school_id,assessment_id); local FK (assessment_id,school_id,enrollment_id,definition_version_id) → assessment(id,school_id,enrollment_id,definition_version_id) | Stable identifier within assessment_result_version ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| enrollment_id | uuid | NOT NULL; default none | UNIQUE(id,school_id,enrollment_id); local FK (assessment_id,school_id,enrollment_id,definition_version_id) → assessment(id,school_id,enrollment_id,definition_version_id); local FK (readiness_id,school_id,enrollment_id,definition_version_id) → assessment_readiness(id,school_id,enrollment_id,definition_version_id) | Logical enrollment_id owned by School Management; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Scoped identifier; linkability/access control required |
| definition_version_id | uuid | NOT NULL; default none | UNIQUE(id,school_id,definition_version_id); local FK (assessment_id,school_id,enrollment_id,definition_version_id) → assessment(id,school_id,enrollment_id,definition_version_id); local FK (readiness_id,school_id,enrollment_id,definition_version_id) → assessment_readiness(id,school_id,enrollment_id,definition_version_id) | Stable identifier within assessment_result_version ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| version | int | NOT NULL; default none | UNIQUE(assessment_id,version,school_id) | Version belonging to assessment_result_version; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| command_id | uuid | NOT NULL; default none | UNIQUE(command_id,school_id) | Stable identifier within assessment_result_version ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| status | lt_result_status | NOT NULL; default none | Non-key attribute | Lifecycle/evaluation state of assessment_result_version; enum/check vocabulary below; transition is not implied by a type alone. | Operational/configuration metadata; restricted if linked to a person |
| assessor_id | uuid | NOT NULL; default none | Non-key attribute | Stable identifier within assessment_result_version ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| assessed_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded assessed instant for assessment_result_version; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| recorded_by | uuid | NOT NULL; default none | Non-key attribute | Recorded by belonging to assessment_result_version; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| recorded_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded recorded instant for assessment_result_version; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| mark | int | NOT NULL; default none | Non-key attribute | Mark belonging to assessment_result_version; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| outcome | lt_outcome | NOT NULL; default none | Non-key attribute | Lifecycle/evaluation state of assessment_result_version; enum/check vocabulary below; transition is not implied by a type alone. | Operational/configuration metadata; restricted if linked to a person |
| readiness_id | uuid | NULL; default none | local FK (readiness_id,school_id,enrollment_id,definition_version_id) → assessment_readiness(id,school_id,enrollment_id,definition_version_id); local FK (readiness_decision_id,school_id,readiness_id) → readiness_decision(id,school_id,readiness_id) | Stable identifier within assessment_result_version ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| readiness_decision_id | uuid | NULL; default none | local FK (readiness_decision_id,school_id,readiness_id) → readiness_decision(id,school_id,readiness_id) | Stable identifier within assessment_result_version ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| comment | text | NULL; default none | Non-key attribute | Comment belonging to assessment_result_version; set by the owning application command/source contract, constrained below. | Restricted free text/document/payload; may contain personal data |
| correction_reason | text | NULL; default none | Non-key attribute | Correction reason belonging to assessment_result_version; set by the owning application command/source contract, constrained below. | Restricted free text/document/payload; may contain personal data |
| reviewed_invalidation_at | timestamptz | NULL; default none | Non-key attribute | Recorded reviewed invalidation instant for assessment_result_version; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- UNIQUE `(assessment_id, version, school_id)`.
- UNIQUE `(command_id, school_id)`.
- UNIQUE `(id, school_id, assessment_id)`.
- UNIQUE `(id, school_id, enrollment_id)`.
- UNIQUE `(id, school_id, definition_version_id)`.

**Row CHECKs:**

- `version > 0` — assessment_result_version_positive.
- `recorded_at >= assessed_at` — assessment_result_time.
- `(version = 1 AND status = 'Recorded' AND correction_reason IS NULL) OR (version > 1 AND correction_reason IS NOT NULL AND length(trim(correction_reason)) > 0)` — assessment_result_reason.
- `(readiness_id IS NULL) = (readiness_decision_id IS NULL)` — result_readiness_pair.
- `(status = 'ReviewRequired' AND version > 1 AND reviewed_invalidation_at IS NOT NULL) OR (status <> 'ReviewRequired')` — result_review_pending_shape.
- `reviewed_invalidation_at IS NULL OR (version > 1 AND recorded_at >= reviewed_invalidation_at)` — result_review_timestamp.
- `reviewed_invalidation_at IS NULL OR readiness_decision_id IS NOT NULL` — result_review_requires_decision.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`.

## assessment_topic_result

Optional informational marks for topics selected by the same definition version as the overall result.

Source model note: Optional versioned topic marks. Two composite tenant-scoped FKs enforce topic and result refer to the SAME definition version, not merely the same school; mark bounds use the versioned assessment scale. Informational only, not an independent pass/fail decision.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id) | Stable identifier within assessment_topic_result ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); UNIQUE(result_version_id,assessment_topic_id,school_id); local FK (result_version_id,school_id,definition_version_id) → assessment_result_version(id,school_id,definition_version_id); local FK (assessment_topic_id,school_id,definition_version_id) → assessment_topic(id,school_id,definition_version_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| result_version_id | uuid | NOT NULL; default none | UNIQUE(result_version_id,assessment_topic_id,school_id); local FK (result_version_id,school_id,definition_version_id) → assessment_result_version(id,school_id,definition_version_id) | Stable identifier within assessment_topic_result ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| definition_version_id | uuid | NOT NULL; default none | local FK (result_version_id,school_id,definition_version_id) → assessment_result_version(id,school_id,definition_version_id); local FK (assessment_topic_id,school_id,definition_version_id) → assessment_topic(id,school_id,definition_version_id) | Stable identifier within assessment_topic_result ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| assessment_topic_id | uuid | NOT NULL; default none | UNIQUE(result_version_id,assessment_topic_id,school_id); local FK (assessment_topic_id,school_id,definition_version_id) → assessment_topic(id,school_id,definition_version_id) | Stable identifier within assessment_topic_result ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| mark | int | NOT NULL; default none | Non-key attribute | Mark belonging to assessment_topic_result; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| comment | text | NULL; default none | Non-key attribute | Comment belonging to assessment_topic_result; set by the owning application command/source contract, constrained below. | Restricted free text/document/payload; may contain personal data |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- UNIQUE `(result_version_id, assessment_topic_id, school_id)`.

**Row CHECKs:**

- No additional DBML row CHECK; enum/key/nullability and companion rules still apply.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`.

## training_evidence_snapshot

Immutable journal/completion-report checklist evaluation for one enrollment and dependency basis; Ready must be revalidated before release.

Source model note: Immutable Journal/CompletionReport evaluation. All checklist decisions live in training_evidence_check as normalized rows with a typed outcome; no JSON/JSONB. Historical Ready is not current Ready: revalidate dependency revision/source, legal checklist and permissions before release. Ready requires verified checklist, verified source and ALL applicable check rows Satisfied. Completeness and cross-row Ready shape need transaction-time trigger/service validation; DBML row CHECK cannot enforce child-row completeness. Document-version linking belongs to Document Management.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id); UNIQUE(id,school_id,enrollment_id) | Stable identifier within training_evidence_snapshot ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); UNIQUE(id,school_id,enrollment_id); local FK (enrollment_id,school_id,program_version_id) → student_training(id,school_id,program_version_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| enrollment_id | uuid | NOT NULL; default none | UNIQUE(id,school_id,enrollment_id); local FK (enrollment_id,school_id,program_version_id) → student_training(id,school_id,program_version_id) | Logical enrollment_id owned by School Management; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Scoped identifier; linkability/access control required |
| program_version_id | uuid | NOT NULL; default none | local FK (enrollment_id,school_id,program_version_id) → student_training(id,school_id,program_version_id) | Stable identifier within training_evidence_snapshot ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| kind | lt_evidence_kind | NOT NULL; default none | Non-key attribute | Kind belonging to training_evidence_snapshot; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| status | lt_evidence_status | NOT NULL; default none | Non-key attribute | Lifecycle/evaluation state of training_evidence_snapshot; enum/check vocabulary below; transition is not implied by a type alone. | Operational/configuration metadata; restricted if linked to a person |
| checklist_version_id | uuid | NULL; default none | Non-key attribute | External verified policy checklist version, logical integration ID; no cross-service FK | Scoped identifier; linkability/access control required |
| dependency_revision | bigint | NOT NULL; default none | Non-key attribute | Positive version of this training_evidence_snapshot consistency basis; handlers use exact expected revision/CAS, not CHECK alone. | Operational/configuration metadata; restricted if linked to a person |
| prepared_by | uuid | NOT NULL; default none | Non-key attribute | Prepared by belonging to training_evidence_snapshot; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| prepared_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded prepared instant for training_evidence_snapshot; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| source_verified_at | timestamptz | NULL; default none | Non-key attribute | Recorded source verified instant for training_evidence_snapshot; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- UNIQUE `(id, school_id, enrollment_id)`.

**Row CHECKs:**

- `dependency_revision > 0` — evidence_dependency_positive.
- `status <> 'Ready' OR (checklist_version_id IS NOT NULL AND source_verified_at IS NOT NULL)` — ready_evidence_basis.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`.

## training_evidence_item

One typed frozen journal/report evidence item; captured minutes/response sequence are historical, not current credit.

Source model note: Immutable journal/report evidence, NOT current credit authority. Exactly one source per row: practical record version, concrete theory attendance row, assessment result version or readiness decision. For lesson evidence record lesson_id and frozen credited_minutes_at_snapshot (zero for pending/disputed/absent). For practical evidence capture response sequence as-of snapshot. Ensure distinct lessons and exact tenant/enrollment/programme/currentness during preparation. Historical snapshot values do not re-credit lessons after correction.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id); UNIQUE(id,school_id,snapshot_id) | Stable identifier within training_evidence_item ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); UNIQUE(id,school_id,snapshot_id); UNIQUE(snapshot_id,lesson_id,school_id); local FK (snapshot_id,school_id,enrollment_id) → training_evidence_snapshot(id,school_id,enrollment_id); local FK (practical_record_version_id,school_id,enrollment_id) → practical_record_version(id,school_id,enrollment_id); local FK (result_version_id,school_id,enrollment_id) → assessment_result_version(id,school_id,enrollment_id); local FK (theory_attendance_id,school_id,enrollment_id) → theory_attendance(id,school_id,enrollment_id); local FK (readiness_decision_id,school_id,enrollment_id) → readiness_decision(id,school_id,enrollment_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| snapshot_id | uuid | NOT NULL; default none | UNIQUE(id,school_id,snapshot_id); UNIQUE(snapshot_id,lesson_id,school_id); local FK (snapshot_id,school_id,enrollment_id) → training_evidence_snapshot(id,school_id,enrollment_id) | Stable identifier within training_evidence_item ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| enrollment_id | uuid | NOT NULL; default none | local FK (snapshot_id,school_id,enrollment_id) → training_evidence_snapshot(id,school_id,enrollment_id); local FK (practical_record_version_id,school_id,enrollment_id) → practical_record_version(id,school_id,enrollment_id); local FK (result_version_id,school_id,enrollment_id) → assessment_result_version(id,school_id,enrollment_id); local FK (theory_attendance_id,school_id,enrollment_id) → theory_attendance(id,school_id,enrollment_id); local FK (readiness_decision_id,school_id,enrollment_id) → readiness_decision(id,school_id,enrollment_id) | Logical enrollment_id owned by School Management; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Scoped identifier; linkability/access control required |
| lesson_id | uuid | NULL; default none | UNIQUE(snapshot_id,lesson_id,school_id) | Logical lesson_id owned by Scheduling; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Scoped identifier; linkability/access control required |
| practical_record_version_id | uuid | NULL; default none | local FK (practical_record_version_id,school_id,enrollment_id) → practical_record_version(id,school_id,enrollment_id) | Stable identifier within training_evidence_item ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| theory_attendance_id | uuid | NULL; default none | local FK (theory_attendance_id,school_id,enrollment_id) → theory_attendance(id,school_id,enrollment_id) | Stable identifier within training_evidence_item ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| result_version_id | uuid | NULL; default none | local FK (result_version_id,school_id,enrollment_id) → assessment_result_version(id,school_id,enrollment_id) | Stable identifier within training_evidence_item ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| readiness_decision_id | uuid | NULL; default none | local FK (readiness_decision_id,school_id,enrollment_id) → readiness_decision(id,school_id,enrollment_id) | Stable identifier within training_evidence_item ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| record_response_sequence | bigint | NULL; default none | Non-key attribute | Record response sequence belonging to training_evidence_item; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| credited_minutes_at_snapshot | int | NULL; default none | Non-key attribute | Training-duration/configuration fact credited_minutes_at_snapshot; owner programme/source basis applies. Demo values are not Lithuanian legal requirements. | Operational/configuration metadata; restricted if linked to a person |
| observed_state | varchar(80) | NOT NULL; default none | Non-key attribute | Observed state belonging to training_evidence_item; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| explanation | text | NOT NULL; default none | Non-key attribute | Explanation belonging to training_evidence_item; set by the owning application command/source contract, constrained below. | Restricted free text/document/payload; may contain personal data |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- UNIQUE `(id, school_id, snapshot_id)`.
- UNIQUE `(snapshot_id, lesson_id, school_id)`.

**Row CHECKs:**

- `(practical_record_version_id IS NOT NULL)::int + (theory_attendance_id IS NOT NULL)::int + (result_version_id IS NOT NULL)::int + (readiness_decision_id IS NOT NULL)::int = 1` — evidence_item_one_source.
- `((practical_record_version_id IS NOT NULL OR theory_attendance_id IS NOT NULL) AND lesson_id IS NOT NULL AND credited_minutes_at_snapshot IS NOT NULL) OR ((practical_record_version_id IS NULL AND theory_attendance_id IS NULL) AND lesson_id IS NULL AND credited_minutes_at_snapshot IS NULL)` — evidence_item_lesson_shape.
- `credited_minutes_at_snapshot IS NULL OR credited_minutes_at_snapshot >= 0` — evidence_item_minutes_nonnegative.
- `record_response_sequence IS NULL OR (practical_record_version_id IS NOT NULL AND record_response_sequence >= 0)` — evidence_response_shape.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`.

## training_evidence_check

One normalized checklist outcome per snapshot/optional exact item and symbolic field; null-safe uniqueness requires SQL.

Source model note: Normalized immutable checklist result, with strict local FK to evidence snapshot and optional exact evidence item from SAME snapshot. Snapshot checks have evidence_item_id NULL, item-specific checks must reference an item. No untyped polymorphic subject_id and no JSONB. Enforce uniqueness of (snapshot, check_code, field_code, evidence_item_id NULLS NOT DISTINCT) with PostgreSQL 15+ UNIQUE NULLS NOT DISTINCT (or two partial unique indexes); DBML cannot express that property reliably. A Ready snapshot requires ALL mandatory policy checks Satisfied, checked in a deferred constraint trigger/service transaction; row-level CHECK cannot enforce completeness. The policy/checklist registry is external and therefore has no cross-service SQL FK.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id) | Stable identifier within training_evidence_check ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); local FK (snapshot_id,school_id,enrollment_id) → training_evidence_snapshot(id,school_id,enrollment_id); local FK (evidence_item_id,school_id,snapshot_id) → training_evidence_item(id,school_id,snapshot_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| snapshot_id | uuid | NOT NULL; default none | local FK (snapshot_id,school_id,enrollment_id) → training_evidence_snapshot(id,school_id,enrollment_id); local FK (evidence_item_id,school_id,snapshot_id) → training_evidence_item(id,school_id,snapshot_id) | Stable identifier within training_evidence_check ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| enrollment_id | uuid | NOT NULL; default none | local FK (snapshot_id,school_id,enrollment_id) → training_evidence_snapshot(id,school_id,enrollment_id) | Logical enrollment_id owned by School Management; receive from authenticated/owner-validated contract, never cross-service SQL FK. | Scoped identifier; linkability/access control required |
| check_code | varchar(100) | NOT NULL; default none | Non-key attribute | Check code belonging to training_evidence_check; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| check_scope | lt_check_scope | NOT NULL; default none | Non-key attribute | Check scope belonging to training_evidence_check; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| evidence_item_id | uuid | NULL; default none | local FK (evidence_item_id,school_id,snapshot_id) → training_evidence_item(id,school_id,snapshot_id) | Stable identifier within training_evidence_check ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| field_code | varchar(100) | NOT NULL; default none | Non-key attribute | Use a stable symbolic field name; use * for a whole-snapshot or whole-item check | Operational/configuration metadata; restricted if linked to a person |
| outcome | lt_check_outcome | NOT NULL; default none | Non-key attribute | Lifecycle/evaluation state of training_evidence_check; enum/check vocabulary below; transition is not implied by a type alone. | Operational/configuration metadata; restricted if linked to a person |
| explanation | text | NOT NULL; default none | Non-key attribute | Explanation belonging to training_evidence_check; set by the owning application command/source contract, constrained below. | Restricted free text/document/payload; may contain personal data |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- INDEX `(snapshot_id, school_id, enrollment_id)` — idx_check_snapshot_tenant.
- INDEX `(evidence_item_id, school_id, snapshot_id)` — idx_check_item_target.

**Row CHECKs:**

- `(check_scope = 'Snapshot' AND evidence_item_id IS NULL) OR (check_scope = 'EvidenceItem' AND evidence_item_id IS NOT NULL)` — evidence_check_scope_shape.
- `length(trim(check_code)) > 0 AND length(trim(field_code)) > 0` — evidence_check_codes_nonblank.
- `length(trim(explanation)) > 0` — evidence_check_explanation_nonblank.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`.

## reporting_declaration

Append-only human declaration of manual external reporting; not an integration acknowledgement or Regitra transmission.

Source model note: User-recorded declaration of manual external reporting only. Snapshot must be a currently ready CompletionReport at declaration. Never Regitra transmission, compatible import or external acknowledgement. Append-only; corrections are new audited declarations.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id) | Stable identifier within reporting_declaration ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); UNIQUE(command_id,school_id); local FK (snapshot_id,school_id) → training_evidence_snapshot(id,school_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| snapshot_id | uuid | NOT NULL; default none | local FK (snapshot_id,school_id) → training_evidence_snapshot(id,school_id) | Stable identifier within reporting_declaration ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| actor_id | uuid | NOT NULL; default none | Non-key attribute | Stable identifier within reporting_declaration ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| declared_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded declared instant for reporting_declaration; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| statement | text | NOT NULL; default none | Non-key attribute | Statement belonging to reporting_declaration; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| command_id | uuid | NOT NULL; default none | UNIQUE(command_id,school_id) | Stable identifier within reporting_declaration ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.
- UNIQUE `(command_id, school_id)`.

**Row CHECKs:**

- No additional DBML row CHECK; enum/key/nullability and companion rules still apply.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`.

## learning_audit_event

Restricted append-only learning action/source/decision audit metadata; no secrets, prompts or copied personal payloads.

Source model note: Append-only restricted audit, not an outbox/transport. Actor can be an identified service principal for Integration/System. Include initial programme binding, confirmations, corrections, decisions/one-time terminal invalidations, declarations and MCP attempts/denials. Invalidation audit append and decision terminal-field update must commit atomically. No secrets, prompts or unnecessary personal data. Application must use exact-payload idempotency and Web-equivalent MCP checks; storage alone cannot prove consent.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| id | uuid | NOT NULL; default none | PK(id); UNIQUE(id,school_id) | Stable identifier within learning_audit_event ownership/relationship; source is the local aggregate unless explicitly marked external. | Operational/configuration metadata; restricted if linked to a person |
| school_id | uuid | NOT NULL; default none | UNIQUE(id,school_id); local FK (source_snapshot_id,school_id) → lesson_source_snapshot(id,school_id) | Tenant owner SchoolId; validated by School Management. A UUID or local FK is not authorization. | Scoped identifier; linkability/access control required |
| actor_id | uuid | NOT NULL; default none | Non-key attribute | Stable identifier within learning_audit_event ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| occurred_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded occurred instant for learning_audit_event; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| channel | lt_channel | NOT NULL; default none | Non-key attribute | Channel belonging to learning_audit_event; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| action | varchar(100) | NOT NULL; default none | Non-key attribute | Action belonging to learning_audit_event; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| target_type | varchar(80) | NOT NULL; default none | Non-key attribute | Target type belonging to learning_audit_event; set by the owning application command/source contract, constrained below. | Operational/configuration metadata; restricted if linked to a person |
| target_id | uuid | NOT NULL; default none | Non-key attribute | Stable identifier within learning_audit_event ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| target_version | bigint | NULL; default none | Non-key attribute | Exact retained target_version of referenced source/configuration; records provenance, not a permanent authorization permit. | Operational/configuration metadata; restricted if linked to a person |
| outcome | varchar(80) | NOT NULL; default none | Non-key attribute | Lifecycle/evaluation state of learning_audit_event; enum/check vocabulary below; transition is not implied by a type alone. | Operational/configuration metadata; restricted if linked to a person |
| correlation_id | uuid | NOT NULL; default none | Non-key attribute | Stable identifier within learning_audit_event ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| command_id | uuid | NULL; default none | Non-key attribute | Stable identifier within learning_audit_event ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| reason | text | NULL; default none | Non-key attribute | Reason belonging to learning_audit_event; set by the owning application command/source contract, constrained below. | Restricted free text/document/payload; may contain personal data |
| source_snapshot_id | uuid | NULL; default none | local FK (source_snapshot_id,school_id) → lesson_source_snapshot(id,school_id) | Stable identifier within learning_audit_event ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| dependency_revision | bigint | NULL; default none | Non-key attribute | Positive version of this learning_audit_event consistency basis; handlers use exact expected revision/CAS, not CHECK alone. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(id)`.
- UNIQUE `(id, school_id)`.

**Row CHECKs:**

- No additional DBML row CHECK; enum/key/nullability and companion rules still apply.

**Lifecycle / immutable / audit:** Domain design only unless an actual companion trigger or restricted writer test demonstrates enforcement; a CHECK does not enforce history.

Immutable design attributes: `id`, `school_id`.

## Enum vocabulary

- `lt_program_status`: Draft, Published, Retired.
- `lt_training_kind`: Theory, Practical.
- `lt_assessment_stage`: Midterm, Final.
- `lt_requirement_kind`: MinimumTheoryMinutes, MinimumPracticalMinutes, AssessmentPassed, MinimumMark.
- `lt_validation`: Incomplete, Valid, Invalid.
- `lt_freshness`: Current, ReconciliationPending, Unavailable.
- `lt_response_role`: Instructor, Student.
- `lt_response_kind`: Confirm, Dispute.
- `lt_attendance`: Present, Absent.
- `lt_formal_status`: Incomplete, Satisfied, Unverified.
- `lt_decision`: Approved, NotApproved.
- `lt_result_status`: Recorded, ReviewRequired, Annulled.
- `lt_invalidation_scope`: ProspectiveOnly, HistoricalReviewRequired.
- `lt_outcome`: Passed, Failed.
- `lt_evidence_kind`: Journal, CompletionReport.
- `lt_evidence_status`: Ready, Incomplete.
- `lt_check_outcome`: Satisfied, Unsatisfied, Unverified.
- `lt_check_scope`: Snapshot, EvidenceItem.
- `lt_channel`: Web, MCP, Integration, System.

Supplemental partial indexes, exclusion/trigger/function rules and deployed CHECK definitions are recorded in [logical schema](logical-schema.md) and verification. External IDs are owner API references, not permission grants.
