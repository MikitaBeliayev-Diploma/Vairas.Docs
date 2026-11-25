# Implemented data dictionary — document-management

Observed synthetic PostgreSQL database: `vairas_document_management`. Exported from migrated local runtime on 2026-11-25. Schema-only evidence; no business rows are included.

Migrations in the owning service remain the schema evolution authority. Existing design dictionaries are preserved separately. Cross-service UUID references are not physical foreign keys unless listed below.

| Schema | Table | Column | PostgreSQL type | Nullable | Default | Maximum length |
|---|---|---|---|---|---|---|
| public | __EFMigrationsHistory | MigrationId | varchar | NO |  | 150 |
| public | __EFMigrationsHistory | ProductVersion | varchar | NO |  | 32 |
| public | contract_signed_copy | signed_copy_id | uuid | NO |  |  |
| public | contract_signed_copy | school_id | uuid | NO |  |  |
| public | contract_signed_copy | contract_id | uuid | NO |  |  |
| public | contract_signed_copy | copy_no | int4 | NO |  |  |
| public | contract_signed_copy | file_id | uuid | NO |  |  |
| public | contract_signed_copy | is_current | bool | NO |  |  |
| public | contract_signed_copy | declared_signed_at | timestamptz | NO |  |  |
| public | contract_signed_copy | recorded_at | timestamptz | NO |  |  |
| public | contract_signed_copy | recorded_by | uuid | NO |  |  |
| public | contract_signed_copy | basis | text | NO |  |  |
| public | document_job | id | uuid | NO |  |  |
| public | document_job | school_id | uuid | NO |  |  |
| public | document_job | enrollment_id | uuid | NO |  |  |
| public | document_job | actor_id | uuid | NO |  |  |
| public | document_job | identity_id | uuid | NO |  |  |
| public | document_job | session_id | uuid | NO |  |  |
| public | document_job | template_version_id | uuid | NO |  |  |
| public | document_job | snapshot_id | uuid | YES |  |  |
| public | document_job | replaces_contract_id | uuid | YES |  |  |
| public | document_job | source_snapshot_version | text | NO |  |  |
| public | document_job | kind | text | NO |  |  |
| public | document_job | status | text | NO |  |  |
| public | document_job | document_id | uuid | YES |  |  |
| public | document_job | error_code | text | YES |  |  |
| public | document_job | attempts | int4 | NO |  |  |
| public | document_job | next_attempt_at | timestamptz | NO |  |  |
| public | document_job | lease_until | timestamptz | YES |  |  |
| public | document_job | lease_id | uuid | YES |  |  |
| public | document_job | created_at | timestamptz | NO |  |  |
| public | document_job | missing_items_json | text | NO | '[]'::text |  |
| public | document_job | result_version_id | uuid | YES |  |  |
| public | document_review | id | uuid | NO |  |  |
| public | document_review | school_id | uuid | NO |  |  |
| public | document_review | document_version_id | uuid | NO |  |  |
| public | document_review | actor_id | uuid | NO |  |  |
| public | document_review | reviewed_at | timestamptz | NO |  |  |
| public | document_review | reason | text | NO |  |  |
| public | document_template | template_id | uuid | NO |  |  |
| public | document_template | school_id | uuid | NO |  |  |
| public | document_template | kind | varchar | NO |  |  |
| public | document_template | name | varchar | NO |  |  |
| public | document_template | active_version_id | uuid | YES |  |  |
| public | document_template | revision | int8 | NO |  |  |
| public | document_version | document_version_id | uuid | NO |  |  |
| public | document_version | school_id | uuid | NO |  |  |
| public | document_version | document_id | uuid | NO |  |  |
| public | document_version | enrollment_id | uuid | NO |  |  |
| public | document_version | version_no | int4 | NO |  |  |
| public | document_version | template_version_id | uuid | NO |  |  |
| public | document_version | evidence_snapshot_id | uuid | NO |  |  |
| public | document_version | dependency_revision | int8 | NO |  |  |
| public | document_version | evidence_status | varchar | NO |  |  |
| public | document_version | rendered_file_id | uuid | NO |  |  |
| public | document_version | basis_file_id | uuid | NO |  |  |
| public | document_version | basis_schema_version | varchar | NO |  |  |
| public | document_version | renderer_version | varchar | NO |  |  |
| public | document_version | state | varchar | NO |  |  |
| public | document_version | revision | int8 | NO |  |  |
| public | document_version | generated_by | uuid | NO |  |  |
| public | document_version | generated_at | timestamptz | NO |  |  |
| public | download_grant | id | uuid | NO |  |  |
| public | download_grant | school_id | uuid | NO |  |  |
| public | download_grant | actor_id | uuid | NO |  |  |
| public | download_grant | document_id | uuid | NO |  |  |
| public | download_grant | file_id | uuid | NO |  |  |
| public | download_grant | version_id | uuid | YES |  |  |
| public | download_grant | historical | bool | NO |  |  |
| public | download_grant | expires_at | timestamptz | NO |  |  |
| public | download_grant | signed_copy_id | uuid | YES |  |  |
| public | evidence_checkpoint | school_id | uuid | NO |  |  |
| public | evidence_checkpoint | enrollment_id | uuid | NO |  |  |
| public | evidence_checkpoint | dependency_revision | int8 | NO |  |  |
| public | evidence_checkpoint | last_change_id | uuid | NO |  |  |
| public | evidence_checkpoint | observed_at | timestamptz | NO |  |  |
| public | file_object | file_id | uuid | NO |  |  |
| public | file_object | school_id | uuid | NO |  |  |
| public | file_object | storage_key | varchar | NO |  |  |
| public | file_object | purpose | varchar | NO |  |  |
| public | file_object | sha256 | varchar | NO |  | 64 |
| public | file_object | byte_length | int8 | NO |  |  |
| public | file_object | media_type | varchar | NO |  |  |
| public | file_object | scan_status | varchar | NO |  |  |
| public | file_object | uploaded_by | uuid | NO |  |  |
| public | file_object | uploaded_at | timestamptz | NO |  |  |
| public | inbox_message | id | uuid | NO |  |  |
| public | inbox_message | school_id | uuid | NO |  |  |
| public | inbox_message | fingerprint | text | NO |  |  |
| public | inbox_message | processed_at | timestamptz | NO |  |  |
| public | operation_outcome | id | uuid | NO |  |  |
| public | operation_outcome | school_id | uuid | NO |  |  |
| public | operation_outcome | response_json | text | NO |  |  |
| public | operation_receipt | command_id | uuid | NO |  |  |
| public | operation_receipt | school_id | uuid | NO |  |  |
| public | operation_receipt | actor_id | uuid | NO |  |  |
| public | operation_receipt | template_id | uuid | YES |  |  |
| public | operation_receipt | template_version_id | uuid | YES |  |  |
| public | operation_receipt | operation | varchar | NO |  |  |
| public | operation_receipt | request_digest | varchar | NO |  | 64 |
| public | operation_receipt | status | varchar | NO |  |  |
| public | operation_receipt | contract_id | uuid | YES |  |  |
| public | operation_receipt | document_id | uuid | YES |  |  |
| public | operation_receipt | document_version_id | uuid | YES |  |  |
| public | operation_receipt | outcome_code | varchar | YES |  |  |
| public | operation_receipt | created_at | timestamptz | NO |  |  |
| public | operation_receipt | completed_at | timestamptz | YES |  |  |
| public | publication_decision | id | uuid | NO |  |  |
| public | publication_decision | school_id | uuid | NO |  |  |
| public | publication_decision | document_version_id | uuid | NO |  |  |
| public | publication_decision | actor_id | uuid | NO |  |  |
| public | publication_decision | identity_id | uuid | NO |  |  |
| public | publication_decision | session_id | uuid | NO |  |  |
| public | publication_decision | expected_revision | int8 | NO |  |  |
| public | publication_decision | expected_version_revision | int8 | NO |  |  |
| public | publication_decision | artifact_digest | text | NO |  |  |
| public | publication_decision | status | text | NO |  |  |
| public | publication_decision | reason | text | NO |  |  |
| public | publication_decision | created_at | timestamptz | NO |  |  |
| public | publication_decision | decided_at | timestamptz | YES |  |  |
| public | rendered_artifact | id | uuid | NO |  |  |
| public | rendered_artifact | school_id | uuid | NO |  |  |
| public | rendered_artifact | contract_id | uuid | YES |  |  |
| public | rendered_artifact | document_version_id | uuid | YES |  |  |
| public | rendered_artifact | file_id | uuid | NO |  |  |
| public | rendered_artifact | format | text | NO |  |  |
| public | state_event | event_id | uuid | NO |  |  |
| public | state_event | school_id | uuid | NO |  |  |
| public | state_event | template_id | uuid | YES |  |  |
| public | state_event | template_version_id | uuid | YES |  |  |
| public | state_event | signed_copy_id | uuid | YES |  |  |
| public | state_event | action | varchar | NO |  |  |
| public | state_event | contract_id | uuid | YES |  |  |
| public | state_event | document_id | uuid | YES |  |  |
| public | state_event | document_version_id | uuid | YES |  |  |
| public | state_event | sequence_no | int8 | NO |  |  |
| public | state_event | from_state | varchar | YES |  |  |
| public | state_event | to_state | varchar | NO |  |  |
| public | state_event | actor_id | uuid | NO |  |  |
| public | state_event | occurred_at | timestamptz | NO |  |  |
| public | state_event | reason | text | NO |  |  |
| public | state_event | command_id | uuid | NO |  |  |
| public | template_version | template_version_id | uuid | NO |  |  |
| public | template_version | school_id | uuid | NO |  |  |
| public | template_version | template_id | uuid | NO |  |  |
| public | template_version | version_no | int4 | NO |  |  |
| public | template_version | status | varchar | NO |  |  |
| public | template_version | file_id | uuid | NO |  |  |
| public | template_version | created_by | uuid | NO |  |  |
| public | template_version | created_at | timestamptz | NO |  |  |
| public | training_contract | contract_id | uuid | NO |  |  |
| public | training_contract | school_id | uuid | NO |  |  |
| public | training_contract | enrollment_id | uuid | NO |  |  |
| public | training_contract | student_id | uuid | NO |  |  |
| public | training_contract | template_version_id | uuid | NO |  |  |
| public | training_contract | generated_file_id | uuid | NO |  |  |
| public | training_contract | basis_file_id | uuid | NO |  |  |
| public | training_contract | basis_schema_version | varchar | NO |  |  |
| public | training_contract | status | varchar | NO |  |  |
| public | training_contract | replaces_contract_id | uuid | YES |  |  |
| public | training_contract | generated_by | uuid | NO |  |  |
| public | training_contract | generated_at | timestamptz | NO |  |  |
| public | training_contract | revision | int8 | NO |  |  |
| public | training_document | document_id | uuid | NO |  |  |
| public | training_document | school_id | uuid | NO |  |  |
| public | training_document | enrollment_id | uuid | NO |  |  |
| public | training_document | kind | varchar | NO |  |  |
| public | training_document | revision | int8 | NO |  |  |
| public | training_document | current_version_id | uuid | YES |  |  |

## Physical constraints

| Schema / table | Name | Definition |
|---|---|---|
| public.__EFMigrationsHistory | PK___EFMigrationsHistory | PRIMARY KEY ("MigrationId") |
| public.contract_signed_copy | contract_signed_copy_basis_check | CHECK ((length(TRIM(BOTH FROM basis)) > 0)) |
| public.contract_signed_copy | contract_signed_copy_check | CHECK ((declared_signed_at <= recorded_at)) |
| public.contract_signed_copy | contract_signed_copy_copy_no_check | CHECK ((copy_no > 0)) |
| public.contract_signed_copy | contract_signed_copy_pkey | PRIMARY KEY (signed_copy_id) |
| public.contract_signed_copy | contract_signed_copy_school_id_contract_id_fkey | FOREIGN KEY (school_id, contract_id) REFERENCES training_contract(school_id, contract_id) DEFERRABLE |
| public.contract_signed_copy | contract_signed_copy_school_id_file_id_fkey | FOREIGN KEY (school_id, file_id) REFERENCES file_object(school_id, file_id) DEFERRABLE |
| public.contract_signed_copy | dm_signed_audit | TRIGGER DEFERRABLE INITIALLY DEFERRED |
| public.contract_signed_copy | dm_signed_final | TRIGGER DEFERRABLE INITIALLY DEFERRED |
| public.document_job | dm_job_result_version | FOREIGN KEY (school_id, result_version_id) REFERENCES document_version(school_id, document_version_id) |
| public.document_job | document_job_attempts_check | CHECK ((attempts >= 0)) |
| public.document_job | document_job_kind_check | CHECK ((kind = ANY (ARRAY['TrainingContract'::text, 'PracticalJournal'::text, 'CompletionReport'::text]))) |
| public.document_job | document_job_pkey | PRIMARY KEY (id) |
| public.document_job | document_job_school_id_id_fkey | FOREIGN KEY (school_id, id) REFERENCES operation_receipt(school_id, command_id) |
| public.document_job | document_job_school_id_id_key | UNIQUE (school_id, id) |
| public.document_job | document_job_school_id_template_version_id_fkey | FOREIGN KEY (school_id, template_version_id) REFERENCES template_version(school_id, template_version_id) |
| public.document_job | document_job_status_check | CHECK ((status = ANY (ARRAY['Pending'::text, 'Generating'::text, 'Completed'::text, 'Failed'::text]))) |
| public.document_review | document_review_pkey | PRIMARY KEY (id) |
| public.document_review | document_review_school_id_document_version_id_fkey | FOREIGN KEY (school_id, document_version_id) REFERENCES document_version(school_id, document_version_id) |
| public.document_template | dm_template_audit | TRIGGER DEFERRABLE INITIALLY DEFERRED |
| public.document_template | dm_template_final | TRIGGER DEFERRABLE INITIALLY DEFERRED |
| public.document_template | document_template_kind_check | CHECK (((kind)::text = ANY ((ARRAY['TrainingContract'::character varying, 'PracticalJournal'::character varying, 'CompletionReport'::character varying])::text[]))) |
| public.document_template | document_template_name_check | CHECK ((length(TRIM(BOTH FROM name)) > 0)) |
| public.document_template | document_template_pkey | PRIMARY KEY (template_id) |
| public.document_template | document_template_revision_check | CHECK ((revision > 0)) |
| public.document_template | document_template_school_id_template_id_active_version_id_fkey | FOREIGN KEY (school_id, template_id, active_version_id) REFERENCES template_version(school_id, template_id, template_version_id) DEFERRABLE |
| public.document_version | dm_selection_child_final | TRIGGER DEFERRABLE INITIALLY DEFERRED |
| public.document_version | dm_version_audit | TRIGGER DEFERRABLE INITIALLY DEFERRED |
| public.document_version | document_version_check | CHECK ((((state)::text <> 'PublishedReady'::text) OR ((evidence_status)::text = 'Ready'::text))) |
| public.document_version | document_version_check1 | CHECK (((length(TRIM(BOTH FROM basis_schema_version)) > 0) AND (length(TRIM(BOTH FROM renderer_version)) > 0))) |
| public.document_version | document_version_dependency_revision_check | CHECK ((dependency_revision >= 0)) |
| public.document_version | document_version_evidence_status_check | CHECK (((evidence_status)::text = ANY ((ARRAY['Ready'::character varying, 'Incomplete'::character varying])::text[]))) |
| public.document_version | document_version_pkey | PRIMARY KEY (document_version_id) |
| public.document_version | document_version_revision_check | CHECK ((revision > 0)) |
| public.document_version | document_version_school_id_basis_file_id_fkey | FOREIGN KEY (school_id, basis_file_id) REFERENCES file_object(school_id, file_id) DEFERRABLE |
| public.document_version | document_version_school_id_document_id_enrollment_id_fkey | FOREIGN KEY (school_id, document_id, enrollment_id) REFERENCES training_document(school_id, document_id, enrollment_id) DEFERRABLE |
| public.document_version | document_version_school_id_rendered_file_id_fkey | FOREIGN KEY (school_id, rendered_file_id) REFERENCES file_object(school_id, file_id) DEFERRABLE |
| public.document_version | document_version_school_id_template_version_id_fkey | FOREIGN KEY (school_id, template_version_id) REFERENCES template_version(school_id, template_version_id) DEFERRABLE |
| public.document_version | document_version_state_check | CHECK (((state)::text = ANY ((ARRAY['Prepared'::character varying, 'Indeterminate'::character varying, 'PublishedReview'::character varying, 'PublishedReady'::character varying, 'Stale'::character varying, 'Withdrawn'::character varying])::text[]))) |
| public.document_version | document_version_version_no_check | CHECK ((version_no > 0)) |
| public.download_grant | dm_download_signed_copy | FOREIGN KEY (school_id, signed_copy_id) REFERENCES contract_signed_copy(school_id, signed_copy_id) |
| public.download_grant | dm_download_version | FOREIGN KEY (school_id, version_id) REFERENCES document_version(school_id, document_version_id) |
| public.download_grant | download_grant_pkey | PRIMARY KEY (id) |
| public.download_grant | download_grant_school_id_file_id_fkey | FOREIGN KEY (school_id, file_id) REFERENCES file_object(school_id, file_id) |
| public.evidence_checkpoint | dm_checkpoint_selection | TRIGGER DEFERRABLE INITIALLY DEFERRED |
| public.evidence_checkpoint | evidence_checkpoint_dependency_revision_check | CHECK ((dependency_revision >= 0)) |
| public.evidence_checkpoint | evidence_checkpoint_pkey | PRIMARY KEY (school_id, enrollment_id) |
| public.file_object | file_object_byte_length_check | CHECK ((byte_length > 0)) |
| public.file_object | file_object_check | CHECK (((length(TRIM(BOTH FROM storage_key)) > 0) AND (length(TRIM(BOTH FROM media_type)) > 0))) |
| public.file_object | file_object_pkey | PRIMARY KEY (file_id) |
| public.file_object | file_object_purpose_check | CHECK (((purpose)::text = ANY ((ARRAY['Template'::character varying, 'Rendered'::character varying, 'SignedCopy'::character varying, 'SourceBasis'::character varying])::text[]))) |
| public.file_object | file_object_scan_status_check | CHECK (((scan_status)::text = ANY ((ARRAY['Pending'::character varying, 'Clean'::character varying, 'Rejected'::character varying])::text[]))) |
| public.file_object | file_object_sha256_check | CHECK (((sha256)::text ~ '^[0-9a-f]{64}$'::text)) |
| public.inbox_message | inbox_message_pkey | PRIMARY KEY (id) |
| public.operation_outcome | operation_outcome_pkey | PRIMARY KEY (school_id, id) |
| public.operation_outcome | operation_outcome_school_id_id_fkey | FOREIGN KEY (school_id, id) REFERENCES operation_receipt(school_id, command_id) |
| public.operation_receipt | operation_receipt_check | CHECK (((((status)::text = ANY ((ARRAY['Pending'::character varying, 'Indeterminate'::character varying])::text[])) AND (completed_at IS NULL)) OR (((status)::text = ANY ((ARRAY['Succeeded'::character varying, 'Rejected'::character varying])::text[])) AND (completed_at IS NOT NULL)))) |
| public.operation_receipt | operation_receipt_check1 | CHECK (((completed_at IS NULL) OR (completed_at >= created_at))) |
| public.operation_receipt | operation_receipt_check2 | CHECK ((num_nonnulls(template_id, contract_id, document_id, document_version_id) <= 1)) |
| public.operation_receipt | operation_receipt_check3 | CHECK (((template_version_id IS NULL) OR (template_id IS NOT NULL))) |
| public.operation_receipt | operation_receipt_check4 | CHECK ((((status)::text <> ALL ((ARRAY['Succeeded'::character varying, 'Rejected'::character varying])::text[])) OR (outcome_code IS NOT NULL))) |
| public.operation_receipt | operation_receipt_check5 | CHECK (((length(TRIM(BOTH FROM operation)) > 0) AND ((outcome_code IS NULL) OR (length(TRIM(BOTH FROM outcome_code)) > 0)))) |
| public.operation_receipt | operation_receipt_pkey | PRIMARY KEY (command_id) |
| public.operation_receipt | operation_receipt_request_digest_check | CHECK (((request_digest)::text ~ '^[0-9a-f]{64}$'::text)) |
| public.operation_receipt | operation_receipt_school_id_contract_id_fkey | FOREIGN KEY (school_id, contract_id) REFERENCES training_contract(school_id, contract_id) DEFERRABLE |
| public.operation_receipt | operation_receipt_school_id_document_id_fkey | FOREIGN KEY (school_id, document_id) REFERENCES training_document(school_id, document_id) DEFERRABLE |
| public.operation_receipt | operation_receipt_school_id_document_version_id_fkey | FOREIGN KEY (school_id, document_version_id) REFERENCES document_version(school_id, document_version_id) DEFERRABLE |
| public.operation_receipt | operation_receipt_school_id_template_id_fkey | FOREIGN KEY (school_id, template_id) REFERENCES document_template(school_id, template_id) DEFERRABLE |
| public.operation_receipt | operation_receipt_school_id_template_id_template_version_i_fkey | FOREIGN KEY (school_id, template_id, template_version_id) REFERENCES template_version(school_id, template_id, template_version_id) DEFERRABLE |
| public.operation_receipt | operation_receipt_status_check | CHECK (((status)::text = ANY ((ARRAY['Pending'::character varying, 'Succeeded'::character varying, 'Rejected'::character varying, 'Indeterminate'::character varying])::text[]))) |
| public.publication_decision | publication_decision_pkey | PRIMARY KEY (id) |
| public.publication_decision | publication_decision_school_id_document_version_id_fkey | FOREIGN KEY (school_id, document_version_id) REFERENCES document_version(school_id, document_version_id) |
| public.publication_decision | publication_decision_school_id_id_fkey | FOREIGN KEY (school_id, id) REFERENCES operation_receipt(school_id, command_id) |
| public.publication_decision | publication_decision_status_check | CHECK ((status = ANY (ARRAY['Pending'::text, 'Accepted'::text, 'Rejected'::text, 'Stale'::text]))) |
| public.rendered_artifact | rendered_artifact_check | CHECK ((num_nonnulls(contract_id, document_version_id) = 1)) |
| public.rendered_artifact | rendered_artifact_format_check | CHECK ((format = ANY (ARRAY['pdf'::text, 'docx'::text]))) |
| public.rendered_artifact | rendered_artifact_pkey | PRIMARY KEY (id) |
| public.rendered_artifact | rendered_artifact_school_id_contract_id_fkey | FOREIGN KEY (school_id, contract_id) REFERENCES training_contract(school_id, contract_id) |
| public.rendered_artifact | rendered_artifact_school_id_document_version_id_fkey | FOREIGN KEY (school_id, document_version_id) REFERENCES document_version(school_id, document_version_id) |
| public.rendered_artifact | rendered_artifact_school_id_file_id_fkey | FOREIGN KEY (school_id, file_id) REFERENCES file_object(school_id, file_id) |
| public.state_event | state_event_action_check | CHECK ((length(TRIM(BOTH FROM action)) > 0)) |
| public.state_event | state_event_check | CHECK ((num_nonnulls(template_id, contract_id, document_id, document_version_id) = 1)) |
| public.state_event | state_event_check1 | CHECK (((template_version_id IS NULL) OR (template_id IS NOT NULL))) |
| public.state_event | state_event_check2 | CHECK (((signed_copy_id IS NULL) OR (contract_id IS NOT NULL))) |
| public.state_event | state_event_pkey | PRIMARY KEY (event_id) |
| public.state_event | state_event_reason_check | CHECK ((length(TRIM(BOTH FROM reason)) > 0)) |
| public.state_event | state_event_school_id_command_id_fkey | FOREIGN KEY (school_id, command_id) REFERENCES operation_receipt(school_id, command_id) DEFERRABLE |
| public.state_event | state_event_school_id_contract_id_fkey | FOREIGN KEY (school_id, contract_id) REFERENCES training_contract(school_id, contract_id) DEFERRABLE |
| public.state_event | state_event_school_id_contract_id_signed_copy_id_fkey | FOREIGN KEY (school_id, contract_id, signed_copy_id) REFERENCES contract_signed_copy(school_id, contract_id, signed_copy_id) DEFERRABLE |
| public.state_event | state_event_school_id_document_id_fkey | FOREIGN KEY (school_id, document_id) REFERENCES training_document(school_id, document_id) DEFERRABLE |
| public.state_event | state_event_school_id_document_version_id_fkey | FOREIGN KEY (school_id, document_version_id) REFERENCES document_version(school_id, document_version_id) DEFERRABLE |
| public.state_event | state_event_school_id_template_id_fkey | FOREIGN KEY (school_id, template_id) REFERENCES document_template(school_id, template_id) DEFERRABLE |
| public.state_event | state_event_school_id_template_id_template_version_id_fkey | FOREIGN KEY (school_id, template_id, template_version_id) REFERENCES template_version(school_id, template_id, template_version_id) DEFERRABLE |
| public.state_event | state_event_sequence_no_check | CHECK ((sequence_no > 0)) |
| public.template_version | dm_template_child_final | TRIGGER DEFERRABLE INITIALLY DEFERRED |
| public.template_version | template_version_pkey | PRIMARY KEY (template_version_id) |
| public.template_version | template_version_school_id_file_id_fkey | FOREIGN KEY (school_id, file_id) REFERENCES file_object(school_id, file_id) DEFERRABLE |
| public.template_version | template_version_school_id_template_id_fkey | FOREIGN KEY (school_id, template_id) REFERENCES document_template(school_id, template_id) DEFERRABLE |
| public.template_version | template_version_status_check | CHECK (((status)::text = ANY ((ARRAY['Draft'::character varying, 'Active'::character varying, 'Archived'::character varying])::text[]))) |
| public.template_version | template_version_version_no_check | CHECK ((version_no > 0)) |
| public.training_contract | dm_contract_audit | TRIGGER DEFERRABLE INITIALLY DEFERRED |
| public.training_contract | dm_contract_final | TRIGGER DEFERRABLE INITIALLY DEFERRED |
| public.training_contract | training_contract_basis_schema_version_check | CHECK ((length(TRIM(BOTH FROM basis_schema_version)) > 0)) |
| public.training_contract | training_contract_check | CHECK (((replaces_contract_id IS NULL) OR (replaces_contract_id <> contract_id))) |
| public.training_contract | training_contract_pkey | PRIMARY KEY (contract_id) |
| public.training_contract | training_contract_revision_check | CHECK ((revision > 0)) |
| public.training_contract | training_contract_school_id_basis_file_id_fkey | FOREIGN KEY (school_id, basis_file_id) REFERENCES file_object(school_id, file_id) DEFERRABLE |
| public.training_contract | training_contract_school_id_enrollment_id_replaces_contrac_fkey | FOREIGN KEY (school_id, enrollment_id, replaces_contract_id) REFERENCES training_contract(school_id, enrollment_id, contract_id) DEFERRABLE |
| public.training_contract | training_contract_school_id_generated_file_id_fkey | FOREIGN KEY (school_id, generated_file_id) REFERENCES file_object(school_id, file_id) DEFERRABLE |
| public.training_contract | training_contract_school_id_template_version_id_fkey | FOREIGN KEY (school_id, template_version_id) REFERENCES template_version(school_id, template_version_id) DEFERRABLE |
| public.training_contract | training_contract_status_check | CHECK (((status)::text = ANY ((ARRAY['Generated'::character varying, 'Signed'::character varying, 'Cancelled'::character varying])::text[]))) |
| public.training_document | dm_document_audit | TRIGGER DEFERRABLE INITIALLY DEFERRED |
| public.training_document | dm_selection_final | TRIGGER DEFERRABLE INITIALLY DEFERRED |
| public.training_document | training_document_kind_check | CHECK (((kind)::text = ANY ((ARRAY['PracticalJournal'::character varying, 'CompletionReport'::character varying])::text[]))) |
| public.training_document | training_document_pkey | PRIMARY KEY (document_id) |
| public.training_document | training_document_revision_check | CHECK ((revision > 0)) |
| public.training_document | training_document_school_id_document_id_current_version_id_fkey | FOREIGN KEY (school_id, document_id, current_version_id) REFERENCES document_version(school_id, document_id, document_version_id) DEFERRABLE |

## Indexes

| Schema / table | Index | Definition |
|---|---|---|
| public.__EFMigrationsHistory | PK___EFMigrationsHistory | CREATE UNIQUE INDEX "PK___EFMigrationsHistory" ON public."__EFMigrationsHistory" USING btree ("MigrationId") |
| public.contract_signed_copy | contract_signed_copy_pkey | CREATE UNIQUE INDEX contract_signed_copy_pkey ON public.contract_signed_copy USING btree (signed_copy_id) |
| public.contract_signed_copy | contract_signed_copy_school_id_contract_id_copy_no_idx | CREATE UNIQUE INDEX contract_signed_copy_school_id_contract_id_copy_no_idx ON public.contract_signed_copy USING btree (school_id, contract_id, copy_no) |
| public.contract_signed_copy | contract_signed_copy_school_id_contract_id_signed_copy_id_idx | CREATE UNIQUE INDEX contract_signed_copy_school_id_contract_id_signed_copy_id_idx ON public.contract_signed_copy USING btree (school_id, contract_id, signed_copy_id) |
| public.contract_signed_copy | contract_signed_copy_school_id_signed_copy_id_idx | CREATE UNIQUE INDEX contract_signed_copy_school_id_signed_copy_id_idx ON public.contract_signed_copy USING btree (school_id, signed_copy_id) |
| public.contract_signed_copy | dm_one_current_signed_copy | CREATE UNIQUE INDEX dm_one_current_signed_copy ON public.contract_signed_copy USING btree (school_id, contract_id) WHERE is_current |
| public.document_job | dm_due_jobs | CREATE INDEX dm_due_jobs ON public.document_job USING btree (next_attempt_at) WHERE (status = ANY (ARRAY['Pending'::text, 'Generating'::text])) |
| public.document_job | document_job_pkey | CREATE UNIQUE INDEX document_job_pkey ON public.document_job USING btree (id) |
| public.document_job | document_job_school_id_id_key | CREATE UNIQUE INDEX document_job_school_id_id_key ON public.document_job USING btree (school_id, id) |
| public.document_review | document_review_pkey | CREATE UNIQUE INDEX document_review_pkey ON public.document_review USING btree (id) |
| public.document_template | document_template_pkey | CREATE UNIQUE INDEX document_template_pkey ON public.document_template USING btree (template_id) |
| public.document_template | document_template_school_id_template_id_idx | CREATE UNIQUE INDEX document_template_school_id_template_id_idx ON public.document_template USING btree (school_id, template_id) |
| public.document_version | dm_evidence_versions | CREATE INDEX dm_evidence_versions ON public.document_version USING btree (school_id, enrollment_id, dependency_revision) |
| public.document_version | dm_version_template | CREATE INDEX dm_version_template ON public.document_version USING btree (school_id, template_version_id) |
| public.document_version | document_version_pkey | CREATE UNIQUE INDEX document_version_pkey ON public.document_version USING btree (document_version_id) |
| public.document_version | document_version_school_id_document_id_document_version_id_idx | CREATE UNIQUE INDEX document_version_school_id_document_id_document_version_id_idx ON public.document_version USING btree (school_id, document_id, document_version_id) |
| public.document_version | document_version_school_id_document_id_version_no_idx | CREATE UNIQUE INDEX document_version_school_id_document_id_version_no_idx ON public.document_version USING btree (school_id, document_id, version_no) |
| public.document_version | document_version_school_id_document_version_id_idx | CREATE UNIQUE INDEX document_version_school_id_document_version_id_idx ON public.document_version USING btree (school_id, document_version_id) |
| public.download_grant | download_grant_pkey | CREATE UNIQUE INDEX download_grant_pkey ON public.download_grant USING btree (id) |
| public.evidence_checkpoint | evidence_checkpoint_pkey | CREATE UNIQUE INDEX evidence_checkpoint_pkey ON public.evidence_checkpoint USING btree (school_id, enrollment_id) |
| public.file_object | file_object_pkey | CREATE UNIQUE INDEX file_object_pkey ON public.file_object USING btree (file_id) |
| public.file_object | file_object_school_id_file_id_idx | CREATE UNIQUE INDEX file_object_school_id_file_id_idx ON public.file_object USING btree (school_id, file_id) |
| public.file_object | file_object_school_id_storage_key_idx | CREATE UNIQUE INDEX file_object_school_id_storage_key_idx ON public.file_object USING btree (school_id, storage_key) |
| public.inbox_message | inbox_message_pkey | CREATE UNIQUE INDEX inbox_message_pkey ON public.inbox_message USING btree (id) |
| public.operation_outcome | operation_outcome_pkey | CREATE UNIQUE INDEX operation_outcome_pkey ON public.operation_outcome USING btree (school_id, id) |
| public.operation_receipt | operation_receipt_pkey | CREATE UNIQUE INDEX operation_receipt_pkey ON public.operation_receipt USING btree (command_id) |
| public.operation_receipt | operation_receipt_school_id_command_id_idx | CREATE UNIQUE INDEX operation_receipt_school_id_command_id_idx ON public.operation_receipt USING btree (school_id, command_id) |
| public.publication_decision | publication_decision_pkey | CREATE UNIQUE INDEX publication_decision_pkey ON public.publication_decision USING btree (id) |
| public.rendered_artifact | dm_contract_format | CREATE UNIQUE INDEX dm_contract_format ON public.rendered_artifact USING btree (school_id, contract_id, format) WHERE (contract_id IS NOT NULL) |
| public.rendered_artifact | dm_version_format | CREATE UNIQUE INDEX dm_version_format ON public.rendered_artifact USING btree (school_id, document_version_id, format) WHERE (document_version_id IS NOT NULL) |
| public.rendered_artifact | rendered_artifact_pkey | CREATE UNIQUE INDEX rendered_artifact_pkey ON public.rendered_artifact USING btree (id) |
| public.state_event | dm_event_command | CREATE INDEX dm_event_command ON public.state_event USING btree (school_id, command_id) |
| public.state_event | state_event_pkey | CREATE UNIQUE INDEX state_event_pkey ON public.state_event USING btree (event_id) |
| public.state_event | state_event_school_id_contract_id_sequence_no_idx | CREATE UNIQUE INDEX state_event_school_id_contract_id_sequence_no_idx ON public.state_event USING btree (school_id, contract_id, sequence_no) |
| public.state_event | state_event_school_id_document_id_sequence_no_idx | CREATE UNIQUE INDEX state_event_school_id_document_id_sequence_no_idx ON public.state_event USING btree (school_id, document_id, sequence_no) |
| public.state_event | state_event_school_id_document_version_id_sequence_no_idx | CREATE UNIQUE INDEX state_event_school_id_document_version_id_sequence_no_idx ON public.state_event USING btree (school_id, document_version_id, sequence_no) |
| public.state_event | state_event_school_id_event_id_idx | CREATE UNIQUE INDEX state_event_school_id_event_id_idx ON public.state_event USING btree (school_id, event_id) |
| public.state_event | state_event_school_id_template_id_sequence_no_idx | CREATE UNIQUE INDEX state_event_school_id_template_id_sequence_no_idx ON public.state_event USING btree (school_id, template_id, sequence_no) |
| public.template_version | dm_one_active_template | CREATE UNIQUE INDEX dm_one_active_template ON public.template_version USING btree (school_id, template_id) WHERE ((status)::text = 'Active'::text) |
| public.template_version | dm_template_file | CREATE INDEX dm_template_file ON public.template_version USING btree (school_id, file_id) |
| public.template_version | template_version_pkey | CREATE UNIQUE INDEX template_version_pkey ON public.template_version USING btree (template_version_id) |
| public.template_version | template_version_school_id_template_id_template_version_id_idx | CREATE UNIQUE INDEX template_version_school_id_template_id_template_version_id_idx ON public.template_version USING btree (school_id, template_id, template_version_id) |
| public.template_version | template_version_school_id_template_id_version_no_idx | CREATE UNIQUE INDEX template_version_school_id_template_id_version_no_idx ON public.template_version USING btree (school_id, template_id, version_no) |
| public.template_version | template_version_school_id_template_version_id_idx | CREATE UNIQUE INDEX template_version_school_id_template_version_id_idx ON public.template_version USING btree (school_id, template_version_id) |
| public.training_contract | training_contract_pkey | CREATE UNIQUE INDEX training_contract_pkey ON public.training_contract USING btree (contract_id) |
| public.training_contract | training_contract_school_id_contract_id_idx | CREATE UNIQUE INDEX training_contract_school_id_contract_id_idx ON public.training_contract USING btree (school_id, contract_id) |
| public.training_contract | training_contract_school_id_enrollment_id_contract_id_idx | CREATE UNIQUE INDEX training_contract_school_id_enrollment_id_contract_id_idx ON public.training_contract USING btree (school_id, enrollment_id, contract_id) |
| public.training_document | training_document_pkey | CREATE UNIQUE INDEX training_document_pkey ON public.training_document USING btree (document_id) |
| public.training_document | training_document_school_id_document_id_enrollment_id_idx | CREATE UNIQUE INDEX training_document_school_id_document_id_enrollment_id_idx ON public.training_document USING btree (school_id, document_id, enrollment_id) |
| public.training_document | training_document_school_id_document_id_idx | CREATE UNIQUE INDEX training_document_school_id_document_id_idx ON public.training_document USING btree (school_id, document_id) |
| public.training_document | training_document_school_id_enrollment_id_kind_idx | CREATE UNIQUE INDEX training_document_school_id_enrollment_id_kind_idx ON public.training_document USING btree (school_id, enrollment_id, kind) |

## Row-Level Security

| Schema / table | Enabled | Forced |
|---|---|---|
| public.__EFMigrationsHistory | False | False |
| public.document_job | True | False |
| public.document_template | True | False |
| public.template_version | True | False |
| public.file_object | True | False |
| public.training_contract | True | False |
| public.contract_signed_copy | True | False |
| public.training_document | True | False |
| public.document_version | True | False |
| public.state_event | True | False |
| public.operation_receipt | True | False |
| public.evidence_checkpoint | True | False |
| public.operation_outcome | True | False |
| public.rendered_artifact | True | False |
| public.publication_decision | True | False |
| public.download_grant | True | False |
| public.inbox_message | True | False |
| public.document_review | True | False |

Policy expressions and command/role restrictions are retained verbatim in `../schema/implemented-catalogue.json` and `../schema/implemented-schema.sql`. Schema DDL also contains functions and triggers enforcing integrity and audit invariants.
