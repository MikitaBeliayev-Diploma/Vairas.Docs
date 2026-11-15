# Document Management — Logical relational schema

Authority: Current reviewed proposed model; LT owns evidence, DM files/publication. [Canonical DBML](../schema/schema.dbml).

The [Mermaid diagram](../schema/database-erd.md) shows keys/FKs and representative attributes; full attributes/defaults/classification are in data-dictionary.md. 

Physical count: 10 domain tables, 105 columns, 26 local FK declarations. EF migration history, where present, is technical metadata, not a new aggregate.

## Relationships and optionality

| Parent key | Child FK | Required? | Cardinality / integrity |
|---|---|---|---|
| document_template(school_id,template_id) | template_version(school_id,template_id) | Yes | 0..N children per parent; default NO ACTION |
| template_version(school_id,template_id,template_version_id) | document_template(school_id,template_id,active_version_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..1 child per parent; default NO ACTION |
| file_object(school_id,file_id) | template_version(school_id,file_id) | Yes | 0..N children per parent; default NO ACTION |
| file_object(school_id,file_id) | training_contract(school_id,generated_file_id) | Yes | 0..N children per parent; default NO ACTION |
| file_object(school_id,file_id) | training_contract(school_id,basis_file_id) | Yes | 0..N children per parent; default NO ACTION |
| template_version(school_id,template_version_id) | training_contract(school_id,template_version_id) | Yes | 0..N children per parent; default NO ACTION |
| training_contract(school_id,enrollment_id,contract_id) | training_contract(school_id,enrollment_id,replaces_contract_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| training_contract(school_id,contract_id) | contract_signed_copy(school_id,contract_id) | Yes | 0..N children per parent; default NO ACTION |
| file_object(school_id,file_id) | contract_signed_copy(school_id,file_id) | Yes | 0..N children per parent; default NO ACTION |
| training_document(school_id,document_id,enrollment_id) | document_version(school_id,document_id,enrollment_id) | Yes | 0..N children per parent; default NO ACTION |
| template_version(school_id,template_version_id) | document_version(school_id,template_version_id) | Yes | 0..N children per parent; default NO ACTION |
| file_object(school_id,file_id) | document_version(school_id,rendered_file_id) | Yes | 0..N children per parent; default NO ACTION |
| file_object(school_id,file_id) | document_version(school_id,basis_file_id) | Yes | 0..N children per parent; default NO ACTION |
| training_contract(school_id,contract_id) | state_event(school_id,contract_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| document_version(school_id,document_version_id) | state_event(school_id,document_version_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| training_contract(school_id,contract_id) | operation_receipt(school_id,contract_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| document_version(school_id,document_version_id) | operation_receipt(school_id,document_version_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| document_version(school_id,document_id,document_version_id) | training_document(school_id,document_id,current_version_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..1 child per parent; default NO ACTION |
| document_template(school_id,template_id) | state_event(school_id,template_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| template_version(school_id,template_id,template_version_id) | state_event(school_id,template_id,template_version_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| contract_signed_copy(school_id,contract_id,signed_copy_id) | state_event(school_id,contract_id,signed_copy_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| operation_receipt(school_id,command_id) | state_event(school_id,command_id) | Yes | 0..N children per parent; default NO ACTION |
| document_template(school_id,template_id) | operation_receipt(school_id,template_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| template_version(school_id,template_id,template_version_id) | operation_receipt(school_id,template_id,template_version_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| training_document(school_id,document_id) | state_event(school_id,document_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| training_document(school_id,document_id) | operation_receipt(school_id,document_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |

## Deployment/transaction source

[Install wrapper](../ddl/install.sql) is the only fresh-install entry. It references existing canonical SQL or the generated initial migration, not another service’s same-named schema.sql. [Security overlay](../security/database-roles.sql) follows schema creation; demo seeds run only under explicit test gates.

No previous production migration history was found/assumed. Reapplying raw initial DDL over a populated database is forbidden. Scheduling has a real EF migration/snapshot and no-op migration rerun check; other contexts use a fresh SQL baseline and require a separately reviewed differential upgrade if legacy data exists.

Current remote owner/API gaps do not by themselves invalidate relational design. They remain runtime/integration gates and cannot be proven by FK tests.

## Executable database rules beyond DBML

- contract_signed_copy.contract_signed_copy_basis_check: `CHECK ((length(TRIM(BOTH FROM basis)) > 0))`.
- contract_signed_copy.contract_signed_copy_check: `CHECK ((declared_signed_at <= recorded_at))`.
- contract_signed_copy.contract_signed_copy_copy_no_check: `CHECK ((copy_no > 0))`.
- contract_signed_copy.contract_signed_copy_pkey: `PRIMARY KEY (signed_copy_id)`.
- contract_signed_copy.contract_signed_copy_school_id_contract_id_fkey: `FOREIGN KEY (school_id, contract_id) REFERENCES training_contract(school_id, contract_id) DEFERRABLE`.
- contract_signed_copy.contract_signed_copy_school_id_file_id_fkey: `FOREIGN KEY (school_id, file_id) REFERENCES file_object(school_id, file_id) DEFERRABLE`.
- contract_signed_copy.dm_signed_audit: `TRIGGER DEFERRABLE INITIALLY DEFERRED`.
- contract_signed_copy.dm_signed_final: `TRIGGER DEFERRABLE INITIALLY DEFERRED`.
- document_template.dm_template_audit: `TRIGGER DEFERRABLE INITIALLY DEFERRED`.
- document_template.dm_template_final: `TRIGGER DEFERRABLE INITIALLY DEFERRED`.
- document_template.document_template_kind_check: `CHECK (((kind)::text = ANY ((ARRAY['TrainingContract'::character varying, 'PracticalJournal'::character varying, 'CompletionReport'::character varying])::text[])))`.
- document_template.document_template_name_check: `CHECK ((length(TRIM(BOTH FROM name)) > 0))`.
- document_template.document_template_pkey: `PRIMARY KEY (template_id)`.
- document_template.document_template_revision_check: `CHECK ((revision > 0))`.
- document_template.document_template_school_id_template_id_active_version_id_fkey: `FOREIGN KEY (school_id, template_id, active_version_id) REFERENCES template_version(school_id, template_id, template_version_id) DEFERRABLE`.
- document_version.dm_selection_child_final: `TRIGGER DEFERRABLE INITIALLY DEFERRED`.
- document_version.dm_version_audit: `TRIGGER DEFERRABLE INITIALLY DEFERRED`.
- document_version.document_version_check: `CHECK ((((state)::text <> 'PublishedReady'::text) OR ((evidence_status)::text = 'Ready'::text)))`.
- document_version.document_version_check1: `CHECK (((length(TRIM(BOTH FROM basis_schema_version)) > 0) AND (length(TRIM(BOTH FROM renderer_version)) > 0)))`.
- document_version.document_version_dependency_revision_check: `CHECK ((dependency_revision >= 0))`.
- document_version.document_version_evidence_status_check: `CHECK (((evidence_status)::text = ANY ((ARRAY['Ready'::character varying, 'Incomplete'::character varying])::text[])))`.
- document_version.document_version_pkey: `PRIMARY KEY (document_version_id)`.
- document_version.document_version_revision_check: `CHECK ((revision > 0))`.
- document_version.document_version_school_id_basis_file_id_fkey: `FOREIGN KEY (school_id, basis_file_id) REFERENCES file_object(school_id, file_id) DEFERRABLE`.
- document_version.document_version_school_id_document_id_enrollment_id_fkey: `FOREIGN KEY (school_id, document_id, enrollment_id) REFERENCES training_document(school_id, document_id, enrollment_id) DEFERRABLE`.
- document_version.document_version_school_id_rendered_file_id_fkey: `FOREIGN KEY (school_id, rendered_file_id) REFERENCES file_object(school_id, file_id) DEFERRABLE`.
- document_version.document_version_school_id_template_version_id_fkey: `FOREIGN KEY (school_id, template_version_id) REFERENCES template_version(school_id, template_version_id) DEFERRABLE`.
- document_version.document_version_state_check: `CHECK (((state)::text = ANY ((ARRAY['Prepared'::character varying, 'Indeterminate'::character varying, 'PublishedReview'::character varying, 'PublishedReady'::character varying, 'Stale'::character varying, 'Withdrawn'::character varying])::text[])))`.
- document_version.document_version_version_no_check: `CHECK ((version_no > 0))`.
- evidence_checkpoint.dm_checkpoint_selection: `TRIGGER DEFERRABLE INITIALLY DEFERRED`.
- evidence_checkpoint.evidence_checkpoint_dependency_revision_check: `CHECK ((dependency_revision >= 0))`.
- evidence_checkpoint.evidence_checkpoint_pkey: `PRIMARY KEY (school_id, enrollment_id)`.
- file_object.file_object_byte_length_check: `CHECK ((byte_length > 0))`.
- file_object.file_object_check: `CHECK (((length(TRIM(BOTH FROM storage_key)) > 0) AND (length(TRIM(BOTH FROM media_type)) > 0)))`.
- file_object.file_object_pkey: `PRIMARY KEY (file_id)`.
- file_object.file_object_purpose_check: `CHECK (((purpose)::text = ANY ((ARRAY['Template'::character varying, 'Rendered'::character varying, 'SignedCopy'::character varying, 'SourceBasis'::character varying])::text[])))`.
- file_object.file_object_scan_status_check: `CHECK (((scan_status)::text = ANY ((ARRAY['Pending'::character varying, 'Clean'::character varying, 'Rejected'::character varying])::text[])))`.
- file_object.file_object_sha256_check: `CHECK (((sha256)::text ~ '^[0-9a-f]{64}$'::text))`.
- operation_receipt.operation_receipt_check: `CHECK (((((status)::text = ANY ((ARRAY['Pending'::character varying, 'Indeterminate'::character varying])::text[])) AND (completed_at IS NULL)) OR (((status)::text = ANY ((ARRAY['Succeeded'::character varying, 'Rejected'::character varying])::text[])) AND (completed_at IS NOT NULL))))`.
- operation_receipt.operation_receipt_check1: `CHECK (((completed_at IS NULL) OR (completed_at >= created_at)))`.
- operation_receipt.operation_receipt_check2: `CHECK ((num_nonnulls(template_id, contract_id, document_id, document_version_id) <= 1))`.
- operation_receipt.operation_receipt_check3: `CHECK (((template_version_id IS NULL) OR (template_id IS NOT NULL)))`.
- operation_receipt.operation_receipt_check4: `CHECK ((((status)::text <> ALL ((ARRAY['Succeeded'::character varying, 'Rejected'::character varying])::text[])) OR (outcome_code IS NOT NULL)))`.
- operation_receipt.operation_receipt_check5: `CHECK (((length(TRIM(BOTH FROM operation)) > 0) AND ((outcome_code IS NULL) OR (length(TRIM(BOTH FROM outcome_code)) > 0))))`.
- operation_receipt.operation_receipt_pkey: `PRIMARY KEY (command_id)`.
- operation_receipt.operation_receipt_request_digest_check: `CHECK (((request_digest)::text ~ '^[0-9a-f]{64}$'::text))`.
- operation_receipt.operation_receipt_school_id_contract_id_fkey: `FOREIGN KEY (school_id, contract_id) REFERENCES training_contract(school_id, contract_id) DEFERRABLE`.
- operation_receipt.operation_receipt_school_id_document_id_fkey: `FOREIGN KEY (school_id, document_id) REFERENCES training_document(school_id, document_id) DEFERRABLE`.
- operation_receipt.operation_receipt_school_id_document_version_id_fkey: `FOREIGN KEY (school_id, document_version_id) REFERENCES document_version(school_id, document_version_id) DEFERRABLE`.
- operation_receipt.operation_receipt_school_id_template_id_fkey: `FOREIGN KEY (school_id, template_id) REFERENCES document_template(school_id, template_id) DEFERRABLE`.
- operation_receipt.operation_receipt_school_id_template_id_template_version_i_fkey: `FOREIGN KEY (school_id, template_id, template_version_id) REFERENCES template_version(school_id, template_id, template_version_id) DEFERRABLE`.
- operation_receipt.operation_receipt_status_check: `CHECK (((status)::text = ANY ((ARRAY['Pending'::character varying, 'Succeeded'::character varying, 'Rejected'::character varying, 'Indeterminate'::character varying])::text[])))`.
- state_event.state_event_action_check: `CHECK ((length(TRIM(BOTH FROM action)) > 0))`.
- state_event.state_event_check: `CHECK ((num_nonnulls(template_id, contract_id, document_id, document_version_id) = 1))`.
- state_event.state_event_check1: `CHECK (((template_version_id IS NULL) OR (template_id IS NOT NULL)))`.
- state_event.state_event_check2: `CHECK (((signed_copy_id IS NULL) OR (contract_id IS NOT NULL)))`.
- state_event.state_event_pkey: `PRIMARY KEY (event_id)`.
- state_event.state_event_reason_check: `CHECK ((length(TRIM(BOTH FROM reason)) > 0))`.
- state_event.state_event_school_id_command_id_fkey: `FOREIGN KEY (school_id, command_id) REFERENCES operation_receipt(school_id, command_id) DEFERRABLE`.
- state_event.state_event_school_id_contract_id_fkey: `FOREIGN KEY (school_id, contract_id) REFERENCES training_contract(school_id, contract_id) DEFERRABLE`.
- state_event.state_event_school_id_contract_id_signed_copy_id_fkey: `FOREIGN KEY (school_id, contract_id, signed_copy_id) REFERENCES contract_signed_copy(school_id, contract_id, signed_copy_id) DEFERRABLE`.
- state_event.state_event_school_id_document_id_fkey: `FOREIGN KEY (school_id, document_id) REFERENCES training_document(school_id, document_id) DEFERRABLE`.
- state_event.state_event_school_id_document_version_id_fkey: `FOREIGN KEY (school_id, document_version_id) REFERENCES document_version(school_id, document_version_id) DEFERRABLE`.
- state_event.state_event_school_id_template_id_fkey: `FOREIGN KEY (school_id, template_id) REFERENCES document_template(school_id, template_id) DEFERRABLE`.
- state_event.state_event_school_id_template_id_template_version_id_fkey: `FOREIGN KEY (school_id, template_id, template_version_id) REFERENCES template_version(school_id, template_id, template_version_id) DEFERRABLE`.
- state_event.state_event_sequence_no_check: `CHECK ((sequence_no > 0))`.
- template_version.dm_template_child_final: `TRIGGER DEFERRABLE INITIALLY DEFERRED`.
- template_version.template_version_pkey: `PRIMARY KEY (template_version_id)`.
- template_version.template_version_school_id_file_id_fkey: `FOREIGN KEY (school_id, file_id) REFERENCES file_object(school_id, file_id) DEFERRABLE`.
- template_version.template_version_school_id_template_id_fkey: `FOREIGN KEY (school_id, template_id) REFERENCES document_template(school_id, template_id) DEFERRABLE`.
- template_version.template_version_status_check: `CHECK (((status)::text = ANY ((ARRAY['Draft'::character varying, 'Active'::character varying, 'Archived'::character varying])::text[])))`.
- template_version.template_version_version_no_check: `CHECK ((version_no > 0))`.
- training_contract.dm_contract_audit: `TRIGGER DEFERRABLE INITIALLY DEFERRED`.
- training_contract.dm_contract_final: `TRIGGER DEFERRABLE INITIALLY DEFERRED`.
- training_contract.training_contract_basis_schema_version_check: `CHECK ((length(TRIM(BOTH FROM basis_schema_version)) > 0))`.
- training_contract.training_contract_check: `CHECK (((replaces_contract_id IS NULL) OR (replaces_contract_id <> contract_id)))`.
- training_contract.training_contract_pkey: `PRIMARY KEY (contract_id)`.
- training_contract.training_contract_revision_check: `CHECK ((revision > 0))`.
- training_contract.training_contract_school_id_basis_file_id_fkey: `FOREIGN KEY (school_id, basis_file_id) REFERENCES file_object(school_id, file_id) DEFERRABLE`.
- training_contract.training_contract_school_id_enrollment_id_replaces_contrac_fkey: `FOREIGN KEY (school_id, enrollment_id, replaces_contract_id) REFERENCES training_contract(school_id, enrollment_id, contract_id) DEFERRABLE`.
- training_contract.training_contract_school_id_generated_file_id_fkey: `FOREIGN KEY (school_id, generated_file_id) REFERENCES file_object(school_id, file_id) DEFERRABLE`.
- training_contract.training_contract_school_id_template_version_id_fkey: `FOREIGN KEY (school_id, template_version_id) REFERENCES template_version(school_id, template_version_id) DEFERRABLE`.
- training_contract.training_contract_status_check: `CHECK (((status)::text = ANY ((ARRAY['Generated'::character varying, 'Signed'::character varying, 'Cancelled'::character varying])::text[])))`.
- training_document.dm_document_audit: `TRIGGER DEFERRABLE INITIALLY DEFERRED`.
- training_document.dm_selection_final: `TRIGGER DEFERRABLE INITIALLY DEFERRED`.
- training_document.training_document_kind_check: `CHECK (((kind)::text = ANY ((ARRAY['PracticalJournal'::character varying, 'CompletionReport'::character varying])::text[])))`.
- training_document.training_document_pkey: `PRIMARY KEY (document_id)`.
- training_document.training_document_revision_check: `CHECK ((revision > 0))`.
- training_document.training_document_school_id_document_id_current_version_id_fkey: `FOREIGN KEY (school_id, document_id, current_version_id) REFERENCES document_version(school_id, document_id, document_version_id) DEFERRABLE`.
