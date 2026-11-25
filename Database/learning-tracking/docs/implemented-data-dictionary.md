# Implemented data dictionary — learning-tracking

Observed synthetic PostgreSQL database: `vairas_learning_tracking`. Exported from migrated local runtime on 2026-11-25. Schema-only evidence; no business rows are included.

Migrations in the owning service remain the schema evolution authority. Existing design dictionaries are preserved separately. Cross-service UUID references are not physical foreign keys unless listed below.

| Schema | Table | Column | PostgreSQL type | Nullable | Default | Maximum length |
|---|---|---|---|---|---|---|
| public | __EFMigrationsHistory | MigrationId | varchar | NO |  | 150 |
| public | __EFMigrationsHistory | ProductVersion | varchar | NO |  | 32 |
| public | admission_requirement | id | uuid | NO |  |  |
| public | admission_requirement | school_id | uuid | NO |  |  |
| public | admission_requirement | definition_version_id | uuid | NO |  |  |
| public | admission_requirement | program_version_id | uuid | NO |  |  |
| public | admission_requirement | code | varchar | NO |  | 80 |
| public | admission_requirement | kind | lt_requirement_kind | NO |  |  |
| public | admission_requirement | minimum_minutes | int4 | YES |  |  |
| public | admission_requirement | prerequisite_definition_version_id | uuid | YES |  |  |
| public | admission_requirement | minimum_mark | int4 | YES |  |  |
| public | assessment | id | uuid | NO |  |  |
| public | assessment | school_id | uuid | NO |  |  |
| public | assessment | enrollment_id | uuid | NO |  |  |
| public | assessment | program_version_id | uuid | NO |  |  |
| public | assessment | definition_version_id | uuid | NO |  |  |
| public | assessment | attempt_number | int4 | NO |  |  |
| public | assessment | appointment_id | uuid | YES |  |  |
| public | assessment | revision | int8 | NO |  |  |
| public | assessment_definition | id | uuid | NO |  |  |
| public | assessment_definition | school_id | uuid | NO |  |  |
| public | assessment_definition | program_id | uuid | NO |  |  |
| public | assessment_definition | code | varchar | NO |  | 80 |
| public | assessment_definition_version | id | uuid | NO |  |  |
| public | assessment_definition_version | school_id | uuid | NO |  |  |
| public | assessment_definition_version | definition_id | uuid | NO |  |  |
| public | assessment_definition_version | program_id | uuid | NO |  |  |
| public | assessment_definition_version | program_version_id | uuid | NO |  |  |
| public | assessment_definition_version | name | varchar | NO |  | 200 |
| public | assessment_definition_version | training_kind | lt_training_kind | NO |  |  |
| public | assessment_definition_version | stage | lt_assessment_stage | NO |  |  |
| public | assessment_definition_version | minimum_mark | int4 | NO |  |  |
| public | assessment_definition_version | maximum_mark | int4 | NO |  |  |
| public | assessment_definition_version | passing_mark | int4 | NO |  |  |
| public | assessment_definition_version | required_for_completion | bool | NO |  |  |
| public | assessment_readiness | id | uuid | NO |  |  |
| public | assessment_readiness | school_id | uuid | NO |  |  |
| public | assessment_readiness | enrollment_id | uuid | NO |  |  |
| public | assessment_readiness | program_version_id | uuid | NO |  |  |
| public | assessment_readiness | definition_version_id | uuid | NO |  |  |
| public | assessment_readiness | current_evaluation_id | uuid | YES |  |  |
| public | assessment_readiness | current_decision_id | uuid | YES |  |  |
| public | assessment_readiness | revision | int8 | NO |  |  |
| public | assessment_result_version | id | uuid | NO |  |  |
| public | assessment_result_version | school_id | uuid | NO |  |  |
| public | assessment_result_version | assessment_id | uuid | NO |  |  |
| public | assessment_result_version | enrollment_id | uuid | NO |  |  |
| public | assessment_result_version | definition_version_id | uuid | NO |  |  |
| public | assessment_result_version | version | int4 | NO |  |  |
| public | assessment_result_version | command_id | uuid | NO |  |  |
| public | assessment_result_version | status | lt_result_status | NO |  |  |
| public | assessment_result_version | assessor_id | uuid | NO |  |  |
| public | assessment_result_version | assessed_at | timestamptz | NO |  |  |
| public | assessment_result_version | recorded_by | uuid | NO |  |  |
| public | assessment_result_version | recorded_at | timestamptz | NO |  |  |
| public | assessment_result_version | mark | int4 | NO |  |  |
| public | assessment_result_version | outcome | lt_outcome | NO |  |  |
| public | assessment_result_version | readiness_id | uuid | YES |  |  |
| public | assessment_result_version | readiness_decision_id | uuid | YES |  |  |
| public | assessment_result_version | comment | text | YES |  |  |
| public | assessment_result_version | correction_reason | text | YES |  |  |
| public | assessment_result_version | reviewed_invalidation_at | timestamptz | YES |  |  |
| public | assessment_topic | id | uuid | NO |  |  |
| public | assessment_topic | school_id | uuid | NO |  |  |
| public | assessment_topic | definition_version_id | uuid | NO |  |  |
| public | assessment_topic | program_version_id | uuid | NO |  |  |
| public | assessment_topic | topic_id | uuid | NO |  |  |
| public | assessment_topic_result | id | uuid | NO |  |  |
| public | assessment_topic_result | school_id | uuid | NO |  |  |
| public | assessment_topic_result | result_version_id | uuid | NO |  |  |
| public | assessment_topic_result | definition_version_id | uuid | NO |  |  |
| public | assessment_topic_result | assessment_topic_id | uuid | NO |  |  |
| public | assessment_topic_result | mark | int4 | NO |  |  |
| public | assessment_topic_result | comment | text | YES |  |  |
| public | document_release_decision | id | uuid | NO |  |  |
| public | document_release_decision | school_id | uuid | NO |  |  |
| public | document_release_decision | enrollment_id | uuid | NO |  |  |
| public | document_release_decision | actor_id | uuid | NO |  |  |
| public | document_release_decision | fingerprint | text | NO |  |  |
| public | document_release_decision | status | text | NO |  |  |
| public | document_release_decision | evaluated_revision | int8 | NO |  |  |
| public | document_release_decision | decided_at | timestamptz | NO |  |  |
| public | document_release_decision | reason | text | NO |  |  |
| public | enrollment_source_state | id | uuid | NO |  |  |
| public | enrollment_source_state | school_id | uuid | NO |  |  |
| public | enrollment_source_state | revision | int8 | NO |  |  |
| public | enrollment_source_state | status | text | NO |  |  |
| public | enrollment_source_state | verified_at | timestamptz | NO |  |  |
| public | inbox_message | id | uuid | NO |  |  |
| public | inbox_message | school_id | uuid | NO |  |  |
| public | inbox_message | producer | text | NO |  |  |
| public | inbox_message | event_type | text | NO |  |  |
| public | inbox_message | aggregate_id | uuid | NO |  |  |
| public | inbox_message | aggregate_version | int8 | NO |  |  |
| public | inbox_message | fingerprint | text | NO |  |  |
| public | inbox_message | processed_at | timestamptz | NO |  |  |
| public | learning_audit_event | id | uuid | NO |  |  |
| public | learning_audit_event | school_id | uuid | NO |  |  |
| public | learning_audit_event | actor_id | uuid | NO |  |  |
| public | learning_audit_event | occurred_at | timestamptz | NO |  |  |
| public | learning_audit_event | channel | lt_channel | NO |  |  |
| public | learning_audit_event | action | varchar | NO |  | 100 |
| public | learning_audit_event | target_type | varchar | NO |  | 80 |
| public | learning_audit_event | target_id | uuid | NO |  |  |
| public | learning_audit_event | target_version | int8 | YES |  |  |
| public | learning_audit_event | outcome | varchar | NO |  | 80 |
| public | learning_audit_event | correlation_id | uuid | NO |  |  |
| public | learning_audit_event | command_id | uuid | YES |  |  |
| public | learning_audit_event | reason | text | YES |  |  |
| public | learning_audit_event | source_snapshot_id | uuid | YES |  |  |
| public | learning_audit_event | dependency_revision | int8 | YES |  |  |
| public | learning_operation | id | uuid | NO |  |  |
| public | learning_operation | school_id | uuid | NO |  |  |
| public | learning_operation | actor_id | uuid | NO |  |  |
| public | learning_operation | fingerprint | text | NO |  |  |
| public | learning_operation | command | text | NO |  |  |
| public | learning_operation | result_json | text | NO |  |  |
| public | learning_operation | result_id | uuid | NO |  |  |
| public | learning_operation | applied_at | timestamptz | NO |  |  |
| public | lesson_planning_policy | id | uuid | NO |  |  |
| public | lesson_planning_policy | school_id | uuid | NO |  |  |
| public | lesson_planning_policy | program_version_id | uuid | NO |  |  |
| public | lesson_planning_policy | kind | lt_training_kind | NO |  |  |
| public | lesson_planning_policy | lesson_minutes | int4 | NO |  |  |
| public | lesson_planning_policy | allow_short_final_lesson | bool | NO |  |  |
| public | lesson_planning_policy | minimum_final_lesson_minutes | int4 | NO |  |  |
| public | lesson_source_snapshot | id | uuid | NO |  |  |
| public | lesson_source_snapshot | school_id | uuid | NO |  |  |
| public | lesson_source_snapshot | lesson_id | uuid | NO |  |  |
| public | lesson_source_snapshot | lesson_revision | int4 | NO |  |  |
| public | lesson_source_snapshot | kind | lt_training_kind | NO |  |  |
| public | lesson_source_snapshot | instructor_id | uuid | NO |  |  |
| public | lesson_source_snapshot | enrollment_id | uuid | YES |  |  |
| public | lesson_source_snapshot | student_id | uuid | YES |  |  |
| public | lesson_source_snapshot | vehicle_id | uuid | YES |  |  |
| public | lesson_source_snapshot | group_id | uuid | YES |  |  |
| public | lesson_source_snapshot | membership_revision | int8 | YES |  |  |
| public | lesson_source_snapshot | actual_start | timestamptz | YES |  |  |
| public | lesson_source_snapshot | actual_end | timestamptz | YES |  |  |
| public | lesson_source_snapshot | physically_completed | bool | NO |  |  |
| public | lesson_source_snapshot | source_valid | bool | NO |  |  |
| public | lesson_source_snapshot | captured_at | timestamptz | NO |  |  |
| public | lesson_source_snapshot | source_event_id | uuid | YES |  |  |
| public | lesson_source_state | id | uuid | NO |  |  |
| public | lesson_source_state | school_id | uuid | NO |  |  |
| public | lesson_source_state | lesson_id | uuid | NO |  |  |
| public | lesson_source_state | current_snapshot_id | uuid | NO |  |  |
| public | lesson_source_state | freshness | lt_freshness | NO |  |  |
| public | lesson_source_state | last_verified_at | timestamptz | NO |  |  |
| public | lesson_source_state | reason | text | YES |  |  |
| public | outbox_message | id | uuid | NO |  |  |
| public | outbox_message | school_id | uuid | NO |  |  |
| public | outbox_message | aggregate_id | uuid | NO |  |  |
| public | outbox_message | aggregate_version | int8 | NO |  |  |
| public | outbox_message | event_type | text | NO |  |  |
| public | outbox_message | payload | text | NO |  |  |
| public | outbox_message | correlation_id | text | NO |  |  |
| public | outbox_message | occurred_at | timestamptz | NO |  |  |
| public | outbox_message | sent_at | timestamptz | YES |  |  |
| public | outbox_message | lease_id | uuid | YES |  |  |
| public | outbox_message | lease_until | timestamptz | YES |  |  |
| public | outbox_message | attempts | int4 | NO |  |  |
| public | outbox_message | next_attempt_at | timestamptz | NO |  |  |
| public | policy_attestation | id | uuid | NO |  |  |
| public | policy_attestation | school_id | uuid | NO |  |  |
| public | policy_attestation | checksum | text | NO |  |  |
| public | policy_attestation | attested_at | timestamptz | NO |  |  |
| public | practical_record_response | id | uuid | NO |  |  |
| public | practical_record_response | school_id | uuid | NO |  |  |
| public | practical_record_response | record_id | uuid | NO |  |  |
| public | practical_record_response | record_version_id | uuid | NO |  |  |
| public | practical_record_response | sequence | int8 | NO |  |  |
| public | practical_record_response | actor_id | uuid | NO |  |  |
| public | practical_record_response | actor_role | lt_response_role | NO |  |  |
| public | practical_record_response | response | lt_response_kind | NO |  |  |
| public | practical_record_response | responded_at | timestamptz | NO |  |  |
| public | practical_record_response | reason | text | YES |  |  |
| public | practical_record_response | command_id | uuid | NO |  |  |
| public | practical_record_topic | id | uuid | NO |  |  |
| public | practical_record_topic | school_id | uuid | NO |  |  |
| public | practical_record_topic | record_version_id | uuid | NO |  |  |
| public | practical_record_topic | program_version_id | uuid | NO |  |  |
| public | practical_record_topic | topic_id | uuid | NO |  |  |
| public | practical_record_version | id | uuid | NO |  |  |
| public | practical_record_version | school_id | uuid | NO |  |  |
| public | practical_record_version | record_id | uuid | NO |  |  |
| public | practical_record_version | enrollment_id | uuid | NO |  |  |
| public | practical_record_version | lesson_id | uuid | NO |  |  |
| public | practical_record_version | program_version_id | uuid | NO |  |  |
| public | practical_record_version | version | int4 | NO |  |  |
| public | practical_record_version | source_snapshot_id | uuid | NO |  |  |
| public | practical_record_version | training_minutes | int4 | YES |  |  |
| public | practical_record_version | duration_explanation | text | YES |  |  |
| public | practical_record_version | distance_km | numeric | YES |  |  |
| public | practical_record_version | validation | lt_validation | NO |  |  |
| public | practical_record_version | validation_reason | text | YES |  |  |
| public | practical_record_version | created_by | uuid | NO |  |  |
| public | practical_record_version | created_at | timestamptz | NO |  |  |
| public | practical_record_version | correction_reason | text | YES |  |  |
| public | practical_training_record | id | uuid | NO |  |  |
| public | practical_training_record | school_id | uuid | NO |  |  |
| public | practical_training_record | lesson_id | uuid | NO |  |  |
| public | practical_training_record | enrollment_id | uuid | NO |  |  |
| public | practical_training_record | current_version_id | uuid | YES |  |  |
| public | practical_training_record | revision | int8 | NO |  |  |
| public | program_rule_source | id | uuid | NO |  |  |
| public | program_rule_source | school_id | uuid | NO |  |  |
| public | program_rule_source | program_version_id | uuid | NO |  |  |
| public | program_rule_source | rule_code | varchar | NO |  | 80 |
| public | program_rule_source | source_uri | text | NO |  |  |
| public | program_rule_source | source_edition | varchar | NO |  | 200 |
| public | program_rule_source | applicability | text | NO |  |  |
| public | program_rule_source | verified_by | uuid | YES |  |  |
| public | program_rule_source | verified_at | timestamptz | YES |  |  |
| public | program_rule_source | effective_from | date | NO |  |  |
| public | program_rule_source | effective_to | date | YES |  |  |
| public | program_rule_source | unit_description | varchar | NO |  | 120 |
| public | readiness_decision | id | uuid | NO |  |  |
| public | readiness_decision | school_id | uuid | NO |  |  |
| public | readiness_decision | readiness_id | uuid | NO |  |  |
| public | readiness_decision | evaluation_id | uuid | NO |  |  |
| public | readiness_decision | actor_id | uuid | NO |  |  |
| public | readiness_decision | decided_at | timestamptz | NO |  |  |
| public | readiness_decision | decision | lt_decision | NO |  |  |
| public | readiness_decision | reason | text | NO |  |  |
| public | readiness_decision | authority_basis | text | NO |  |  |
| public | readiness_decision | command_id | uuid | NO |  |  |
| public | readiness_decision | invalidated_at | timestamptz | YES |  |  |
| public | readiness_decision | invalidated_by | uuid | YES |  |  |
| public | readiness_decision | invalidation_reason | text | YES |  |  |
| public | readiness_decision | invalidation_dependency_revision | int8 | YES |  |  |
| public | readiness_decision | invalidation_scope | lt_invalidation_scope | YES |  |  |
| public | readiness_decision | invalidation_effective_at | timestamptz | YES |  |  |
| public | readiness_decision | enrollment_id | uuid | NO |  |  |
| public | readiness_evaluation | id | uuid | NO |  |  |
| public | readiness_evaluation | school_id | uuid | NO |  |  |
| public | readiness_evaluation | readiness_id | uuid | NO |  |  |
| public | readiness_evaluation | enrollment_id | uuid | NO |  |  |
| public | readiness_evaluation | definition_version_id | uuid | NO |  |  |
| public | readiness_evaluation | dependency_revision | int8 | NO |  |  |
| public | readiness_evaluation | formal_status | lt_formal_status | NO |  |  |
| public | readiness_evaluation | evaluated_at | timestamptz | NO |  |  |
| public | readiness_evaluation | evaluated_by | uuid | NO |  |  |
| public | readiness_evaluation | explanation | text | NO |  |  |
| public | readiness_evidence_basis | id | uuid | NO |  |  |
| public | readiness_evidence_basis | school_id | uuid | NO |  |  |
| public | readiness_evidence_basis | evaluation_id | uuid | NO |  |  |
| public | readiness_evidence_basis | enrollment_id | uuid | NO |  |  |
| public | readiness_evidence_basis | lesson_id | uuid | YES |  |  |
| public | readiness_evidence_basis | practical_record_version_id | uuid | YES |  |  |
| public | readiness_evidence_basis | theory_attendance_id | uuid | YES |  |  |
| public | readiness_evidence_basis | result_version_id | uuid | YES |  |  |
| public | readiness_evidence_basis | observed_minutes | int4 | YES |  |  |
| public | readiness_requirement_result | id | uuid | NO |  |  |
| public | readiness_requirement_result | school_id | uuid | NO |  |  |
| public | readiness_requirement_result | evaluation_id | uuid | NO |  |  |
| public | readiness_requirement_result | definition_version_id | uuid | NO |  |  |
| public | readiness_requirement_result | requirement_id | uuid | NO |  |  |
| public | readiness_requirement_result | status | lt_formal_status | NO |  |  |
| public | readiness_requirement_result | observed_minutes | int4 | YES |  |  |
| public | readiness_requirement_result | observed_mark | int4 | YES |  |  |
| public | readiness_requirement_result | explanation | text | NO |  |  |
| public | reporting_declaration | id | uuid | NO |  |  |
| public | reporting_declaration | school_id | uuid | NO |  |  |
| public | reporting_declaration | snapshot_id | uuid | NO |  |  |
| public | reporting_declaration | actor_id | uuid | NO |  |  |
| public | reporting_declaration | declared_at | timestamptz | NO |  |  |
| public | reporting_declaration | statement | text | NO |  |  |
| public | reporting_declaration | command_id | uuid | NO |  |  |
| public | school_source_state | id | uuid | NO |  |  |
| public | school_source_state | school_id | uuid | NO |  |  |
| public | school_source_state | revision | int8 | NO |  |  |
| public | school_source_state | last_verified_at | timestamptz | NO |  |  |
| public | student_training | id | uuid | NO |  |  |
| public | student_training | school_id | uuid | NO |  |  |
| public | student_training | student_id | uuid | NO |  |  |
| public | student_training | category_code | varchar | NO |  | 16 |
| public | student_training | program_version_id | uuid | YES |  |  |
| public | student_training | program_assigned_by | uuid | YES |  |  |
| public | student_training | program_assigned_at | timestamptz | YES |  |  |
| public | student_training | dependency_revision | int8 | NO |  |  |
| public | student_training | created_at | timestamptz | NO |  |  |
| public | theory_attendance | id | uuid | NO |  |  |
| public | theory_attendance | school_id | uuid | NO |  |  |
| public | theory_attendance | record_version_id | uuid | NO |  |  |
| public | theory_attendance | enrollment_id | uuid | NO |  |  |
| public | theory_attendance | student_id | uuid | NO |  |  |
| public | theory_attendance | attendance | lt_attendance | NO |  |  |
| public | theory_record_version | id | uuid | NO |  |  |
| public | theory_record_version | school_id | uuid | NO |  |  |
| public | theory_record_version | record_id | uuid | NO |  |  |
| public | theory_record_version | lesson_id | uuid | NO |  |  |
| public | theory_record_version | version | int4 | NO |  |  |
| public | theory_record_version | source_snapshot_id | uuid | NO |  |  |
| public | theory_record_version | training_minutes | int4 | NO |  |  |
| public | theory_record_version | duration_explanation | text | YES |  |  |
| public | theory_record_version | validation | lt_validation | NO |  |  |
| public | theory_record_version | created_by | uuid | NO |  |  |
| public | theory_record_version | created_at | timestamptz | NO |  |  |
| public | theory_record_version | confirmed_by | uuid | YES |  |  |
| public | theory_record_version | confirmed_at | timestamptz | YES |  |  |
| public | theory_record_version | correction_reason | text | YES |  |  |
| public | theory_training_record | id | uuid | NO |  |  |
| public | theory_training_record | school_id | uuid | NO |  |  |
| public | theory_training_record | lesson_id | uuid | NO |  |  |
| public | theory_training_record | current_version_id | uuid | YES |  |  |
| public | theory_training_record | revision | int8 | NO |  |  |
| public | training_evidence_check | id | uuid | NO |  |  |
| public | training_evidence_check | school_id | uuid | NO |  |  |
| public | training_evidence_check | snapshot_id | uuid | NO |  |  |
| public | training_evidence_check | enrollment_id | uuid | NO |  |  |
| public | training_evidence_check | check_code | varchar | NO |  | 100 |
| public | training_evidence_check | check_scope | lt_check_scope | NO |  |  |
| public | training_evidence_check | evidence_item_id | uuid | YES |  |  |
| public | training_evidence_check | field_code | varchar | NO |  | 100 |
| public | training_evidence_check | outcome | lt_check_outcome | NO |  |  |
| public | training_evidence_check | explanation | text | NO |  |  |
| public | training_evidence_item | id | uuid | NO |  |  |
| public | training_evidence_item | school_id | uuid | NO |  |  |
| public | training_evidence_item | snapshot_id | uuid | NO |  |  |
| public | training_evidence_item | enrollment_id | uuid | NO |  |  |
| public | training_evidence_item | lesson_id | uuid | YES |  |  |
| public | training_evidence_item | practical_record_version_id | uuid | YES |  |  |
| public | training_evidence_item | theory_attendance_id | uuid | YES |  |  |
| public | training_evidence_item | result_version_id | uuid | YES |  |  |
| public | training_evidence_item | readiness_decision_id | uuid | YES |  |  |
| public | training_evidence_item | record_response_sequence | int8 | YES |  |  |
| public | training_evidence_item | credited_minutes_at_snapshot | int4 | YES |  |  |
| public | training_evidence_item | observed_state | varchar | NO |  | 80 |
| public | training_evidence_item | explanation | text | NO |  |  |
| public | training_evidence_snapshot | id | uuid | NO |  |  |
| public | training_evidence_snapshot | school_id | uuid | NO |  |  |
| public | training_evidence_snapshot | enrollment_id | uuid | NO |  |  |
| public | training_evidence_snapshot | program_version_id | uuid | NO |  |  |
| public | training_evidence_snapshot | kind | lt_evidence_kind | NO |  |  |
| public | training_evidence_snapshot | status | lt_evidence_status | NO |  |  |
| public | training_evidence_snapshot | checklist_version_id | uuid | YES |  |  |
| public | training_evidence_snapshot | dependency_revision | int8 | NO |  |  |
| public | training_evidence_snapshot | prepared_by | uuid | NO |  |  |
| public | training_evidence_snapshot | prepared_at | timestamptz | NO |  |  |
| public | training_evidence_snapshot | source_verified_at | timestamptz | YES |  |  |
| public | training_program | id | uuid | NO |  |  |
| public | training_program | school_id | uuid | NO |  |  |
| public | training_program | category_code | varchar | NO |  | 16 |
| public | training_program | name | varchar | NO |  | 200 |
| public | training_program | created_at | timestamptz | NO |  |  |
| public | training_program | revision | int8 | NO |  |  |
| public | training_program_version | id | uuid | NO |  |  |
| public | training_program_version | school_id | uuid | NO |  |  |
| public | training_program_version | program_id | uuid | NO |  |  |
| public | training_program_version | version | int4 | NO |  |  |
| public | training_program_version | status | lt_program_status | NO |  |  |
| public | training_program_version | pathway_code | varchar | NO |  | 80 |
| public | training_program_version | required_theory_minutes | int4 | NO |  |  |
| public | training_program_version | required_practical_minutes | int4 | NO |  |  |
| public | training_program_version | theory_minutes_per_unit | int4 | NO |  |  |
| public | training_program_version | practical_minutes_per_unit | int4 | NO |  |  |
| public | training_program_version | effective_from | date | NO |  |  |
| public | training_program_version | effective_to | date | YES |  |  |
| public | training_program_version | legal_basis_verified | bool | NO |  |  |
| public | training_program_version | created_by | uuid | NO |  |  |
| public | training_program_version | created_at | timestamptz | NO |  |  |
| public | training_program_version | published_by | uuid | YES |  |  |
| public | training_program_version | published_at | timestamptz | YES |  |  |
| public | training_program_version | retired_at | timestamptz | YES |  |  |
| public | training_program_version | journal_checklist_version_id | uuid | YES |  |  |
| public | training_topic | id | uuid | NO |  |  |
| public | training_topic | school_id | uuid | NO |  |  |
| public | training_topic | program_version_id | uuid | NO |  |  |
| public | training_topic | topic_key | varchar | NO |  | 80 |
| public | training_topic | name | varchar | NO |  | 200 |
| public | training_topic | description | text | YES |  |  |

## Physical constraints

| Schema / table | Name | Definition |
|---|---|---|
| public.__EFMigrationsHistory | PK___EFMigrationsHistory | PRIMARY KEY ("MigrationId") |
| public.admission_requirement | admission_requirement_definition_version_id_school_id_prog_fkey | FOREIGN KEY (definition_version_id, school_id, program_version_id) REFERENCES assessment_definition_version(id, school_id, program_version_id) DEFERRABLE |
| public.admission_requirement | admission_requirement_pkey | PRIMARY KEY (id) |
| public.admission_requirement | admission_requirement_prerequisite_definition_version_id_s_fkey | FOREIGN KEY (prerequisite_definition_version_id, school_id, program_version_id) REFERENCES assessment_definition_version(id, school_id, program_version_id) DEFERRABLE |
| public.admission_requirement | requirement_typed_shape | CHECK ((((kind = ANY (ARRAY['MinimumTheoryMinutes'::lt_requirement_kind, 'MinimumPracticalMinutes'::lt_requirement_kind])) AND (minimum_minutes IS NOT NULL) AND (minimum_minutes >= 0) AND (prerequisite_definition_version_id IS NULL) AND (minimum_mark IS NULL)) OR ((kind = 'AssessmentPassed'::lt_requirement_kind) AND (minimum_minutes IS NULL) AND (prerequisite_definition_version_id IS NOT NULL) AND (minimum_mark IS NULL)) OR ((kind = 'MinimumMark'::lt_requirement_kind) AND (minimum_minutes IS NULL) AND (prerequisite_definition_version_id IS NOT NULL) AND (minimum_mark IS NOT NULL)))) |
| public.assessment | assessment_attempt_positive | CHECK (((attempt_number > 0) AND (revision > 0))) |
| public.assessment | assessment_definition_version_id_school_id_program_version_fkey | FOREIGN KEY (definition_version_id, school_id, program_version_id) REFERENCES assessment_definition_version(id, school_id, program_version_id) DEFERRABLE |
| public.assessment | assessment_enrollment_id_school_id_program_version_id_fkey | FOREIGN KEY (enrollment_id, school_id, program_version_id) REFERENCES student_training(id, school_id, program_version_id) DEFERRABLE |
| public.assessment | assessment_pkey | PRIMARY KEY (id) |
| public.assessment_definition | assessment_definition_pkey | PRIMARY KEY (id) |
| public.assessment_definition | assessment_definition_program_id_school_id_fkey | FOREIGN KEY (program_id, school_id) REFERENCES training_program(id, school_id) DEFERRABLE |
| public.assessment_definition_version | assessment_definition_version_definition_id_school_id_prog_fkey | FOREIGN KEY (definition_id, school_id, program_id) REFERENCES assessment_definition(id, school_id, program_id) DEFERRABLE |
| public.assessment_definition_version | assessment_definition_version_pkey | PRIMARY KEY (id) |
| public.assessment_definition_version | assessment_definition_version_program_version_id_school_id_fkey | FOREIGN KEY (program_version_id, school_id, program_id) REFERENCES training_program_version(id, school_id, program_id) DEFERRABLE |
| public.assessment_definition_version | assessment_scale | CHECK (((minimum_mark < maximum_mark) AND (passing_mark >= minimum_mark) AND (passing_mark <= maximum_mark))) |
| public.assessment_readiness | assessment_readiness_current_decision_id_school_id_id_fkey | FOREIGN KEY (current_decision_id, school_id, id) REFERENCES readiness_decision(id, school_id, readiness_id) DEFERRABLE |
| public.assessment_readiness | assessment_readiness_current_evaluation_id_school_id_id_fkey | FOREIGN KEY (current_evaluation_id, school_id, id) REFERENCES readiness_evaluation(id, school_id, readiness_id) DEFERRABLE |
| public.assessment_readiness | assessment_readiness_definition_version_id_school_id_progr_fkey | FOREIGN KEY (definition_version_id, school_id, program_version_id) REFERENCES assessment_definition_version(id, school_id, program_version_id) DEFERRABLE |
| public.assessment_readiness | assessment_readiness_enrollment_id_school_id_program_versi_fkey | FOREIGN KEY (enrollment_id, school_id, program_version_id) REFERENCES student_training(id, school_id, program_version_id) DEFERRABLE |
| public.assessment_readiness | assessment_readiness_pkey | PRIMARY KEY (id) |
| public.assessment_readiness | readiness_revision_positive | CHECK ((revision > 0)) |
| public.assessment_result_version | assessment_result_reason | CHECK ((((version = 1) AND (status = 'Recorded'::lt_result_status) AND (correction_reason IS NULL)) OR ((version > 1) AND (correction_reason IS NOT NULL) AND (length(TRIM(BOTH FROM correction_reason)) > 0)))) |
| public.assessment_result_version | assessment_result_time | CHECK ((recorded_at >= assessed_at)) |
| public.assessment_result_version | assessment_result_version_assessment_id_school_id_enrollme_fkey | FOREIGN KEY (assessment_id, school_id, enrollment_id, definition_version_id) REFERENCES assessment(id, school_id, enrollment_id, definition_version_id) DEFERRABLE |
| public.assessment_result_version | assessment_result_version_pkey | PRIMARY KEY (id) |
| public.assessment_result_version | assessment_result_version_positive | CHECK ((version > 0)) |
| public.assessment_result_version | assessment_result_version_readiness_decision_id_school_id__fkey | FOREIGN KEY (readiness_decision_id, school_id, readiness_id) REFERENCES readiness_decision(id, school_id, readiness_id) DEFERRABLE |
| public.assessment_result_version | assessment_result_version_readiness_id_school_id_enrollmen_fkey | FOREIGN KEY (readiness_id, school_id, enrollment_id, definition_version_id) REFERENCES assessment_readiness(id, school_id, enrollment_id, definition_version_id) DEFERRABLE |
| public.assessment_result_version | result_readiness_pair | CHECK (((readiness_id IS NULL) = (readiness_decision_id IS NULL))) |
| public.assessment_result_version | result_review_pending_shape | CHECK ((((status = 'ReviewRequired'::lt_result_status) AND (version > 1) AND (reviewed_invalidation_at IS NOT NULL)) OR (status <> 'ReviewRequired'::lt_result_status))) |
| public.assessment_result_version | result_review_requires_decision | CHECK (((reviewed_invalidation_at IS NULL) OR (readiness_decision_id IS NOT NULL))) |
| public.assessment_result_version | result_review_timestamp | CHECK (((reviewed_invalidation_at IS NULL) OR ((version > 1) AND (recorded_at >= reviewed_invalidation_at)))) |
| public.assessment_topic | assessment_topic_definition_version_id_school_id_program_v_fkey | FOREIGN KEY (definition_version_id, school_id, program_version_id) REFERENCES assessment_definition_version(id, school_id, program_version_id) DEFERRABLE |
| public.assessment_topic | assessment_topic_pkey | PRIMARY KEY (id) |
| public.assessment_topic | assessment_topic_topic_id_school_id_program_version_id_fkey | FOREIGN KEY (topic_id, school_id, program_version_id) REFERENCES training_topic(id, school_id, program_version_id) DEFERRABLE |
| public.assessment_topic_result | assessment_topic_result_assessment_topic_id_school_id_defi_fkey | FOREIGN KEY (assessment_topic_id, school_id, definition_version_id) REFERENCES assessment_topic(id, school_id, definition_version_id) DEFERRABLE |
| public.assessment_topic_result | assessment_topic_result_pkey | PRIMARY KEY (id) |
| public.assessment_topic_result | assessment_topic_result_result_version_id_school_id_defini_fkey | FOREIGN KEY (result_version_id, school_id, definition_version_id) REFERENCES assessment_result_version(id, school_id, definition_version_id) DEFERRABLE |
| public.document_release_decision | document_release_decision_evaluated_revision_check | CHECK ((evaluated_revision >= 0)) |
| public.document_release_decision | document_release_decision_pkey | PRIMARY KEY (id) |
| public.document_release_decision | document_release_decision_status_check | CHECK ((status = ANY (ARRAY['Accepted'::text, 'Rejected'::text]))) |
| public.enrollment_source_state | enrollment_source_state_pkey | PRIMARY KEY (id) |
| public.enrollment_source_state | enrollment_source_state_revision_check | CHECK ((revision > 0)) |
| public.inbox_message | inbox_message_aggregate_version_check | CHECK ((aggregate_version > 0)) |
| public.inbox_message | inbox_message_pkey | PRIMARY KEY (id) |
| public.learning_audit_event | learning_audit_event_pkey | PRIMARY KEY (id) |
| public.learning_audit_event | learning_audit_event_source_snapshot_id_school_id_fkey | FOREIGN KEY (source_snapshot_id, school_id) REFERENCES lesson_source_snapshot(id, school_id) DEFERRABLE |
| public.learning_operation | learning_operation_pkey | PRIMARY KEY (school_id, id) |
| public.lesson_planning_policy | lesson_planning_policy_check | CHECK (((minimum_final_lesson_minutes > 0) AND (minimum_final_lesson_minutes <= lesson_minutes))) |
| public.lesson_planning_policy | lesson_planning_policy_lesson_minutes_check | CHECK ((lesson_minutes > 0)) |
| public.lesson_planning_policy | lesson_planning_policy_pkey | PRIMARY KEY (id) |
| public.lesson_planning_policy | lesson_planning_policy_program_version_id_school_id_fkey | FOREIGN KEY (program_version_id, school_id) REFERENCES training_program_version(id, school_id) DEFERRABLE |
| public.lesson_planning_policy | lesson_planning_policy_school_id_program_version_id_kind_key | UNIQUE (school_id, program_version_id, kind) |
| public.lesson_source_snapshot | completed_source_requires_actuals | CHECK (((NOT (physically_completed AND source_valid)) OR ((actual_start IS NOT NULL) AND (actual_end IS NOT NULL)))) |
| public.lesson_source_snapshot | lesson_source_snapshot_pkey | PRIMARY KEY (id) |
| public.lesson_source_snapshot | source_actual_interval | CHECK ((((actual_start IS NULL) AND (actual_end IS NULL)) OR ((actual_start IS NOT NULL) AND (actual_end IS NOT NULL) AND (actual_end > actual_start)))) |
| public.lesson_source_snapshot | source_kind_shape | CHECK ((((kind = 'Practical'::lt_training_kind) AND (enrollment_id IS NOT NULL) AND (student_id IS NOT NULL) AND (vehicle_id IS NOT NULL) AND (group_id IS NULL) AND (membership_revision IS NULL)) OR ((kind = 'Theory'::lt_training_kind) AND (enrollment_id IS NULL) AND (student_id IS NULL) AND (vehicle_id IS NULL) AND (group_id IS NOT NULL) AND (membership_revision IS NOT NULL) AND (membership_revision > 0)))) |
| public.lesson_source_snapshot | source_revision_positive | CHECK ((lesson_revision > 0)) |
| public.lesson_source_state | lesson_source_state_current_snapshot_id_school_id_lesson_i_fkey | FOREIGN KEY (current_snapshot_id, school_id, lesson_id) REFERENCES lesson_source_snapshot(id, school_id, lesson_id) DEFERRABLE |
| public.lesson_source_state | lesson_source_state_pkey | PRIMARY KEY (id) |
| public.outbox_message | outbox_message_aggregate_version_check | CHECK ((aggregate_version > 0)) |
| public.outbox_message | outbox_message_attempts_check | CHECK ((attempts >= 0)) |
| public.outbox_message | outbox_message_check | CHECK (((lease_id IS NULL) = (lease_until IS NULL))) |
| public.outbox_message | outbox_message_pkey | PRIMARY KEY (id) |
| public.policy_attestation | policy_attestation_pkey | PRIMARY KEY (school_id, id) |
| public.practical_record_response | dispute_reason | CHECK (((response <> 'Dispute'::lt_response_kind) OR ((reason IS NOT NULL) AND (length(TRIM(BOTH FROM reason)) > 0)))) |
| public.practical_record_response | practical_record_response_pkey | PRIMARY KEY (id) |
| public.practical_record_response | practical_record_response_record_version_id_school_id_reco_fkey | FOREIGN KEY (record_version_id, school_id, record_id) REFERENCES practical_record_version(id, school_id, record_id) DEFERRABLE |
| public.practical_record_response | response_sequence | CHECK ((sequence > 0)) |
| public.practical_record_topic | practical_record_topic_pkey | PRIMARY KEY (id) |
| public.practical_record_topic | practical_record_topic_record_version_id_school_id_program_fkey | FOREIGN KEY (record_version_id, school_id, program_version_id) REFERENCES practical_record_version(id, school_id, program_version_id) DEFERRABLE |
| public.practical_record_topic | practical_record_topic_topic_id_school_id_program_version__fkey | FOREIGN KEY (topic_id, school_id, program_version_id) REFERENCES training_topic(id, school_id, program_version_id) DEFERRABLE |
| public.practical_record_version | practical_correction_reason | CHECK (((version = 1) OR ((correction_reason IS NOT NULL) AND (length(TRIM(BOTH FROM correction_reason)) > 0)))) |
| public.practical_record_version | practical_distance | CHECK (((distance_km IS NULL) OR (distance_km >= (0)::numeric))) |
| public.practical_record_version | practical_minutes | CHECK (((training_minutes IS NULL) OR (training_minutes > 0))) |
| public.practical_record_version | practical_record_version_enrollment_id_school_id_program_v_fkey | FOREIGN KEY (enrollment_id, school_id, program_version_id) REFERENCES student_training(id, school_id, program_version_id) DEFERRABLE |
| public.practical_record_version | practical_record_version_pkey | PRIMARY KEY (id) |
| public.practical_record_version | practical_record_version_record_id_school_id_enrollment_id_fkey | FOREIGN KEY (record_id, school_id, enrollment_id, lesson_id) REFERENCES practical_training_record(id, school_id, enrollment_id, lesson_id) DEFERRABLE |
| public.practical_record_version | practical_record_version_source_snapshot_id_school_id_less_fkey | FOREIGN KEY (source_snapshot_id, school_id, lesson_id) REFERENCES lesson_source_snapshot(id, school_id, lesson_id) DEFERRABLE |
| public.practical_record_version | practical_valid_shape | CHECK (((validation <> 'Valid'::lt_validation) OR ((training_minutes IS NOT NULL) AND (distance_km IS NOT NULL)))) |
| public.practical_record_version | practical_version_positive | CHECK ((version > 0)) |
| public.practical_training_record | practical_revision_positive | CHECK ((revision > 0)) |
| public.practical_training_record | practical_training_record_current_version_id_school_id_id_fkey | FOREIGN KEY (current_version_id, school_id, id) REFERENCES practical_record_version(id, school_id, record_id) DEFERRABLE |
| public.practical_training_record | practical_training_record_enrollment_id_school_id_fkey | FOREIGN KEY (enrollment_id, school_id) REFERENCES student_training(id, school_id) DEFERRABLE |
| public.practical_training_record | practical_training_record_pkey | PRIMARY KEY (id) |
| public.program_rule_source | program_rule_source_pkey | PRIMARY KEY (id) |
| public.program_rule_source | program_rule_source_program_version_id_school_id_fkey | FOREIGN KEY (program_version_id, school_id) REFERENCES training_program_version(id, school_id) DEFERRABLE |
| public.program_rule_source | rule_effective_period | CHECK (((effective_to IS NULL) OR (effective_to >= effective_from))) |
| public.program_rule_source | rule_verification_pair | CHECK (((verified_by IS NULL) = (verified_at IS NULL))) |
| public.readiness_decision | decision_terminal_invalidation_shape | CHECK ((((invalidated_at IS NULL) AND (invalidated_by IS NULL) AND (invalidation_reason IS NULL) AND (invalidation_dependency_revision IS NULL) AND (invalidation_scope IS NULL) AND (invalidation_effective_at IS NULL)) OR ((decision = 'Approved'::lt_decision) AND (invalidated_at IS NOT NULL) AND (invalidated_by IS NOT NULL) AND (invalidation_reason IS NOT NULL) AND (length(TRIM(BOTH FROM invalidation_reason)) > 0) AND (invalidation_dependency_revision IS NOT NULL) AND (invalidation_dependency_revision > 0) AND (invalidated_at >= decided_at) AND (invalidation_scope IS NOT NULL) AND ((invalidation_scope = 'HistoricalReviewRequired'::lt_invalidation_scope) OR ((invalidation_scope = 'ProspectiveOnly'::lt_invalidation_scope) AND (invalidation_effective_at IS NOT NULL) AND (invalidation_effective_at >= decided_at)))))) |
| public.readiness_decision | decline_reason | CHECK (((decision <> 'NotApproved'::lt_decision) OR (length(TRIM(BOTH FROM reason)) > 0))) |
| public.readiness_decision | readiness_decision_evaluation_id_school_id_enrollment_id_fkey | FOREIGN KEY (evaluation_id, school_id, enrollment_id) REFERENCES readiness_evaluation(id, school_id, enrollment_id) DEFERRABLE |
| public.readiness_decision | readiness_decision_evaluation_id_school_id_readiness_id_fkey | FOREIGN KEY (evaluation_id, school_id, readiness_id) REFERENCES readiness_evaluation(id, school_id, readiness_id) DEFERRABLE |
| public.readiness_decision | readiness_decision_pkey | PRIMARY KEY (id) |
| public.readiness_evaluation | evaluation_dependency_positive | CHECK ((dependency_revision > 0)) |
| public.readiness_evaluation | readiness_evaluation_pkey | PRIMARY KEY (id) |
| public.readiness_evaluation | readiness_evaluation_readiness_id_school_id_definition_ver_fkey | FOREIGN KEY (readiness_id, school_id, definition_version_id) REFERENCES assessment_readiness(id, school_id, definition_version_id) DEFERRABLE |
| public.readiness_evaluation | readiness_evaluation_readiness_id_school_id_enrollment_id_fkey | FOREIGN KEY (readiness_id, school_id, enrollment_id) REFERENCES assessment_readiness(id, school_id, enrollment_id) DEFERRABLE |
| public.readiness_evidence_basis | readiness_evidence_basis_evaluation_id_school_id_enrollmen_fkey | FOREIGN KEY (evaluation_id, school_id, enrollment_id) REFERENCES readiness_evaluation(id, school_id, enrollment_id) DEFERRABLE |
| public.readiness_evidence_basis | readiness_evidence_basis_pkey | PRIMARY KEY (id) |
| public.readiness_evidence_basis | readiness_evidence_basis_practical_record_version_id_schoo_fkey | FOREIGN KEY (practical_record_version_id, school_id, enrollment_id) REFERENCES practical_record_version(id, school_id, enrollment_id) DEFERRABLE |
| public.readiness_evidence_basis | readiness_evidence_basis_result_version_id_school_id_enrol_fkey | FOREIGN KEY (result_version_id, school_id, enrollment_id) REFERENCES assessment_result_version(id, school_id, enrollment_id) DEFERRABLE |
| public.readiness_evidence_basis | readiness_evidence_basis_theory_attendance_id_school_id_en_fkey | FOREIGN KEY (theory_attendance_id, school_id, enrollment_id) REFERENCES theory_attendance(id, school_id, enrollment_id) DEFERRABLE |
| public.readiness_evidence_basis | readiness_evidence_source_xor | CHECK ((((((practical_record_version_id IS NOT NULL))::integer + ((theory_attendance_id IS NOT NULL))::integer) + ((result_version_id IS NOT NULL))::integer) = 1)) |
| public.readiness_evidence_basis | readiness_evidence_typed_shape | CHECK (((((practical_record_version_id IS NOT NULL) OR (theory_attendance_id IS NOT NULL)) AND (lesson_id IS NOT NULL) AND (observed_minutes IS NOT NULL) AND (observed_minutes > 0)) OR ((result_version_id IS NOT NULL) AND (lesson_id IS NULL) AND (observed_minutes IS NULL)))) |
| public.readiness_requirement_result | observed_minutes_nonnegative | CHECK (((observed_minutes IS NULL) OR (observed_minutes >= 0))) |
| public.readiness_requirement_result | readiness_requirement_result_evaluation_id_school_id_defin_fkey | FOREIGN KEY (evaluation_id, school_id, definition_version_id) REFERENCES readiness_evaluation(id, school_id, definition_version_id) DEFERRABLE |
| public.readiness_requirement_result | readiness_requirement_result_pkey | PRIMARY KEY (id) |
| public.readiness_requirement_result | readiness_requirement_result_requirement_id_school_id_defi_fkey | FOREIGN KEY (requirement_id, school_id, definition_version_id) REFERENCES admission_requirement(id, school_id, definition_version_id) DEFERRABLE |
| public.reporting_declaration | reporting_declaration_pkey | PRIMARY KEY (id) |
| public.reporting_declaration | reporting_declaration_snapshot_id_school_id_fkey | FOREIGN KEY (snapshot_id, school_id) REFERENCES training_evidence_snapshot(id, school_id) DEFERRABLE |
| public.school_source_state | PK_school_source_state | PRIMARY KEY (id) |
| public.school_source_state | school_source_identity | CHECK (((id = school_id) AND (revision > 0))) |
| public.student_training | program_initial_assignment_pair | CHECK ((((program_version_id IS NULL) AND (program_assigned_by IS NULL) AND (program_assigned_at IS NULL)) OR ((program_version_id IS NOT NULL) AND (program_assigned_by IS NOT NULL) AND (program_assigned_at IS NOT NULL)))) |
| public.student_training | student_training_pkey | PRIMARY KEY (id) |
| public.student_training | student_training_program_version_id_school_id_fkey | FOREIGN KEY (program_version_id, school_id) REFERENCES training_program_version(id, school_id) DEFERRABLE |
| public.student_training | training_dependency_positive | CHECK ((dependency_revision > 0)) |
| public.theory_attendance | theory_attendance_enrollment_id_school_id_student_id_fkey | FOREIGN KEY (enrollment_id, school_id, student_id) REFERENCES student_training(id, school_id, student_id) DEFERRABLE |
| public.theory_attendance | theory_attendance_pkey | PRIMARY KEY (id) |
| public.theory_attendance | theory_attendance_record_version_id_school_id_fkey | FOREIGN KEY (record_version_id, school_id) REFERENCES theory_record_version(id, school_id) DEFERRABLE |
| public.theory_record_version | theory_confirmation_pair | CHECK (((confirmed_by IS NULL) = (confirmed_at IS NULL))) |
| public.theory_record_version | theory_confirmed_valid | CHECK (((confirmed_at IS NULL) OR (validation = 'Valid'::lt_validation))) |
| public.theory_record_version | theory_correction_reason | CHECK (((version = 1) OR ((correction_reason IS NOT NULL) AND (length(TRIM(BOTH FROM correction_reason)) > 0)))) |
| public.theory_record_version | theory_positive | CHECK (((version > 0) AND (training_minutes > 0))) |
| public.theory_record_version | theory_record_version_pkey | PRIMARY KEY (id) |
| public.theory_record_version | theory_record_version_record_id_school_id_lesson_id_fkey | FOREIGN KEY (record_id, school_id, lesson_id) REFERENCES theory_training_record(id, school_id, lesson_id) DEFERRABLE |
| public.theory_record_version | theory_record_version_source_snapshot_id_school_id_lesson__fkey | FOREIGN KEY (source_snapshot_id, school_id, lesson_id) REFERENCES lesson_source_snapshot(id, school_id, lesson_id) DEFERRABLE |
| public.theory_training_record | theory_revision_positive | CHECK ((revision > 0)) |
| public.theory_training_record | theory_training_record_current_version_id_school_id_id_fkey | FOREIGN KEY (current_version_id, school_id, id) REFERENCES theory_record_version(id, school_id, record_id) DEFERRABLE |
| public.theory_training_record | theory_training_record_pkey | PRIMARY KEY (id) |
| public.training_evidence_check | evidence_check_codes_nonblank | CHECK (((length(TRIM(BOTH FROM check_code)) > 0) AND (length(TRIM(BOTH FROM field_code)) > 0))) |
| public.training_evidence_check | evidence_check_explanation_nonblank | CHECK ((length(TRIM(BOTH FROM explanation)) > 0)) |
| public.training_evidence_check | evidence_check_scope_shape | CHECK ((((check_scope = 'Snapshot'::lt_check_scope) AND (evidence_item_id IS NULL)) OR ((check_scope = 'EvidenceItem'::lt_check_scope) AND (evidence_item_id IS NOT NULL)))) |
| public.training_evidence_check | training_evidence_check_evidence_item_id_school_id_snapsho_fkey | FOREIGN KEY (evidence_item_id, school_id, snapshot_id) REFERENCES training_evidence_item(id, school_id, snapshot_id) DEFERRABLE |
| public.training_evidence_check | training_evidence_check_pkey | PRIMARY KEY (id) |
| public.training_evidence_check | training_evidence_check_snapshot_id_school_id_enrollment_i_fkey | FOREIGN KEY (snapshot_id, school_id, enrollment_id) REFERENCES training_evidence_snapshot(id, school_id, enrollment_id) DEFERRABLE |
| public.training_evidence_item | evidence_item_lesson_shape | CHECK (((((practical_record_version_id IS NOT NULL) OR (theory_attendance_id IS NOT NULL)) AND (lesson_id IS NOT NULL) AND (credited_minutes_at_snapshot IS NOT NULL)) OR ((practical_record_version_id IS NULL) AND (theory_attendance_id IS NULL) AND (lesson_id IS NULL) AND (credited_minutes_at_snapshot IS NULL)))) |
| public.training_evidence_item | evidence_item_minutes_nonnegative | CHECK (((credited_minutes_at_snapshot IS NULL) OR (credited_minutes_at_snapshot >= 0))) |
| public.training_evidence_item | evidence_item_one_source | CHECK (((((((practical_record_version_id IS NOT NULL))::integer + ((theory_attendance_id IS NOT NULL))::integer) + ((result_version_id IS NOT NULL))::integer) + ((readiness_decision_id IS NOT NULL))::integer) = 1)) |
| public.training_evidence_item | evidence_response_shape | CHECK (((record_response_sequence IS NULL) OR ((practical_record_version_id IS NOT NULL) AND (record_response_sequence >= 0)))) |
| public.training_evidence_item | training_evidence_item_pkey | PRIMARY KEY (id) |
| public.training_evidence_item | training_evidence_item_practical_record_version_id_school__fkey | FOREIGN KEY (practical_record_version_id, school_id, enrollment_id) REFERENCES practical_record_version(id, school_id, enrollment_id) DEFERRABLE |
| public.training_evidence_item | training_evidence_item_readiness_decision_id_school_id_enr_fkey | FOREIGN KEY (readiness_decision_id, school_id, enrollment_id) REFERENCES readiness_decision(id, school_id, enrollment_id) DEFERRABLE |
| public.training_evidence_item | training_evidence_item_result_version_id_school_id_enrollm_fkey | FOREIGN KEY (result_version_id, school_id, enrollment_id) REFERENCES assessment_result_version(id, school_id, enrollment_id) DEFERRABLE |
| public.training_evidence_item | training_evidence_item_snapshot_id_school_id_enrollment_id_fkey | FOREIGN KEY (snapshot_id, school_id, enrollment_id) REFERENCES training_evidence_snapshot(id, school_id, enrollment_id) DEFERRABLE |
| public.training_evidence_item | training_evidence_item_theory_attendance_id_school_id_enro_fkey | FOREIGN KEY (theory_attendance_id, school_id, enrollment_id) REFERENCES theory_attendance(id, school_id, enrollment_id) DEFERRABLE |
| public.training_evidence_snapshot | evidence_dependency_positive | CHECK ((dependency_revision > 0)) |
| public.training_evidence_snapshot | lt_evidence_ready | TRIGGER DEFERRABLE INITIALLY DEFERRED |
| public.training_evidence_snapshot | ready_evidence_basis | CHECK (((status <> 'Ready'::lt_evidence_status) OR ((checklist_version_id IS NOT NULL) AND (source_verified_at IS NOT NULL)))) |
| public.training_evidence_snapshot | training_evidence_snapshot_enrollment_id_school_id_program_fkey | FOREIGN KEY (enrollment_id, school_id, program_version_id) REFERENCES student_training(id, school_id, program_version_id) DEFERRABLE |
| public.training_evidence_snapshot | training_evidence_snapshot_pkey | PRIMARY KEY (id) |
| public.training_program | program_revision_positive | CHECK ((revision > 0)) |
| public.training_program | training_program_pkey | PRIMARY KEY (id) |
| public.training_program_version | program_conversion_positive | CHECK (((theory_minutes_per_unit > 0) AND (practical_minutes_per_unit > 0))) |
| public.training_program_version | program_effective_period | CHECK (((effective_to IS NULL) OR (effective_to >= effective_from))) |
| public.training_program_version | program_minutes_nonnegative | CHECK (((required_theory_minutes >= 0) AND (required_practical_minutes >= 0))) |
| public.training_program_version | program_publication_shape | CHECK ((((status = 'Draft'::lt_program_status) AND (published_at IS NULL) AND (published_by IS NULL) AND (retired_at IS NULL)) OR ((status = 'Published'::lt_program_status) AND (published_at IS NOT NULL) AND (published_by IS NOT NULL) AND (retired_at IS NULL) AND legal_basis_verified) OR ((status = 'Retired'::lt_program_status) AND (published_at IS NOT NULL) AND (published_by IS NOT NULL) AND (retired_at IS NOT NULL) AND (retired_at >= published_at) AND legal_basis_verified))) |
| public.training_program_version | program_version_positive | CHECK ((version > 0)) |
| public.training_program_version | published_checklist | CHECK (((status = 'Draft'::lt_program_status) OR (journal_checklist_version_id IS NOT NULL))) |
| public.training_program_version | training_program_version_pkey | PRIMARY KEY (id) |
| public.training_program_version | training_program_version_program_id_school_id_fkey | FOREIGN KEY (program_id, school_id) REFERENCES training_program(id, school_id) DEFERRABLE |
| public.training_topic | training_topic_pkey | PRIMARY KEY (id) |
| public.training_topic | training_topic_program_version_id_school_id_fkey | FOREIGN KEY (program_version_id, school_id) REFERENCES training_program_version(id, school_id) DEFERRABLE |

## Indexes

| Schema / table | Index | Definition |
|---|---|---|
| public.__EFMigrationsHistory | PK___EFMigrationsHistory | CREATE UNIQUE INDEX "PK___EFMigrationsHistory" ON public."__EFMigrationsHistory" USING btree ("MigrationId") |
| public.admission_requirement | admission_requirement_definition_version_id_code_school_id_idx | CREATE UNIQUE INDEX admission_requirement_definition_version_id_code_school_id_idx ON public.admission_requirement USING btree (definition_version_id, code, school_id) |
| public.admission_requirement | admission_requirement_id_school_id_definition_version_id_idx | CREATE UNIQUE INDEX admission_requirement_id_school_id_definition_version_id_idx ON public.admission_requirement USING btree (id, school_id, definition_version_id) |
| public.admission_requirement | admission_requirement_id_school_id_idx | CREATE UNIQUE INDEX admission_requirement_id_school_id_idx ON public.admission_requirement USING btree (id, school_id) |
| public.admission_requirement | admission_requirement_pkey | CREATE UNIQUE INDEX admission_requirement_pkey ON public.admission_requirement USING btree (id) |
| public.assessment | assessment_enrollment_id_definition_version_id_attempt_numb_idx | CREATE UNIQUE INDEX assessment_enrollment_id_definition_version_id_attempt_numb_idx ON public.assessment USING btree (enrollment_id, definition_version_id, attempt_number, school_id) |
| public.assessment | assessment_id_school_id_definition_version_id_idx | CREATE UNIQUE INDEX assessment_id_school_id_definition_version_id_idx ON public.assessment USING btree (id, school_id, definition_version_id) |
| public.assessment | assessment_id_school_id_enrollment_id_definition_version_id_idx | CREATE UNIQUE INDEX assessment_id_school_id_enrollment_id_definition_version_id_idx ON public.assessment USING btree (id, school_id, enrollment_id, definition_version_id) |
| public.assessment | assessment_id_school_id_enrollment_id_idx | CREATE UNIQUE INDEX assessment_id_school_id_enrollment_id_idx ON public.assessment USING btree (id, school_id, enrollment_id) |
| public.assessment | assessment_id_school_id_idx | CREATE UNIQUE INDEX assessment_id_school_id_idx ON public.assessment USING btree (id, school_id) |
| public.assessment | assessment_pkey | CREATE UNIQUE INDEX assessment_pkey ON public.assessment USING btree (id) |
| public.assessment_definition | assessment_definition_id_school_id_idx | CREATE UNIQUE INDEX assessment_definition_id_school_id_idx ON public.assessment_definition USING btree (id, school_id) |
| public.assessment_definition | assessment_definition_id_school_id_program_id_idx | CREATE UNIQUE INDEX assessment_definition_id_school_id_program_id_idx ON public.assessment_definition USING btree (id, school_id, program_id) |
| public.assessment_definition | assessment_definition_pkey | CREATE UNIQUE INDEX assessment_definition_pkey ON public.assessment_definition USING btree (id) |
| public.assessment_definition | assessment_definition_program_id_code_school_id_idx | CREATE UNIQUE INDEX assessment_definition_program_id_code_school_id_idx ON public.assessment_definition USING btree (program_id, code, school_id) |
| public.assessment_definition_version | assessment_definition_version_definition_id_program_version_idx | CREATE UNIQUE INDEX assessment_definition_version_definition_id_program_version_idx ON public.assessment_definition_version USING btree (definition_id, program_version_id, school_id) |
| public.assessment_definition_version | assessment_definition_version_id_school_id_definition_id_idx | CREATE UNIQUE INDEX assessment_definition_version_id_school_id_definition_id_idx ON public.assessment_definition_version USING btree (id, school_id, definition_id) |
| public.assessment_definition_version | assessment_definition_version_id_school_id_idx | CREATE UNIQUE INDEX assessment_definition_version_id_school_id_idx ON public.assessment_definition_version USING btree (id, school_id) |
| public.assessment_definition_version | assessment_definition_version_id_school_id_program_version__idx | CREATE UNIQUE INDEX assessment_definition_version_id_school_id_program_version__idx ON public.assessment_definition_version USING btree (id, school_id, program_version_id) |
| public.assessment_definition_version | assessment_definition_version_pkey | CREATE UNIQUE INDEX assessment_definition_version_pkey ON public.assessment_definition_version USING btree (id) |
| public.assessment_readiness | assessment_readiness_enrollment_id_program_version_id_defin_idx | CREATE UNIQUE INDEX assessment_readiness_enrollment_id_program_version_id_defin_idx ON public.assessment_readiness USING btree (enrollment_id, program_version_id, definition_version_id, school_id) |
| public.assessment_readiness | assessment_readiness_id_school_id_definition_version_id_idx | CREATE UNIQUE INDEX assessment_readiness_id_school_id_definition_version_id_idx ON public.assessment_readiness USING btree (id, school_id, definition_version_id) |
| public.assessment_readiness | assessment_readiness_id_school_id_enrollment_id_definition__idx | CREATE UNIQUE INDEX assessment_readiness_id_school_id_enrollment_id_definition__idx ON public.assessment_readiness USING btree (id, school_id, enrollment_id, definition_version_id) |
| public.assessment_readiness | assessment_readiness_id_school_id_enrollment_id_idx | CREATE UNIQUE INDEX assessment_readiness_id_school_id_enrollment_id_idx ON public.assessment_readiness USING btree (id, school_id, enrollment_id) |
| public.assessment_readiness | assessment_readiness_id_school_id_idx | CREATE UNIQUE INDEX assessment_readiness_id_school_id_idx ON public.assessment_readiness USING btree (id, school_id) |
| public.assessment_readiness | assessment_readiness_pkey | CREATE UNIQUE INDEX assessment_readiness_pkey ON public.assessment_readiness USING btree (id) |
| public.assessment_result_version | assessment_result_version_assessment_id_version_school_id_idx | CREATE UNIQUE INDEX assessment_result_version_assessment_id_version_school_id_idx ON public.assessment_result_version USING btree (assessment_id, version, school_id) |
| public.assessment_result_version | assessment_result_version_command_id_school_id_idx | CREATE UNIQUE INDEX assessment_result_version_command_id_school_id_idx ON public.assessment_result_version USING btree (command_id, school_id) |
| public.assessment_result_version | assessment_result_version_id_school_id_assessment_id_idx | CREATE UNIQUE INDEX assessment_result_version_id_school_id_assessment_id_idx ON public.assessment_result_version USING btree (id, school_id, assessment_id) |
| public.assessment_result_version | assessment_result_version_id_school_id_definition_version_i_idx | CREATE UNIQUE INDEX assessment_result_version_id_school_id_definition_version_i_idx ON public.assessment_result_version USING btree (id, school_id, definition_version_id) |
| public.assessment_result_version | assessment_result_version_id_school_id_enrollment_id_idx | CREATE UNIQUE INDEX assessment_result_version_id_school_id_enrollment_id_idx ON public.assessment_result_version USING btree (id, school_id, enrollment_id) |
| public.assessment_result_version | assessment_result_version_id_school_id_idx | CREATE UNIQUE INDEX assessment_result_version_id_school_id_idx ON public.assessment_result_version USING btree (id, school_id) |
| public.assessment_result_version | assessment_result_version_pkey | CREATE UNIQUE INDEX assessment_result_version_pkey ON public.assessment_result_version USING btree (id) |
| public.assessment_topic | assessment_topic_definition_version_id_topic_id_school_id_idx | CREATE UNIQUE INDEX assessment_topic_definition_version_id_topic_id_school_id_idx ON public.assessment_topic USING btree (definition_version_id, topic_id, school_id) |
| public.assessment_topic | assessment_topic_id_school_id_definition_version_id_idx | CREATE UNIQUE INDEX assessment_topic_id_school_id_definition_version_id_idx ON public.assessment_topic USING btree (id, school_id, definition_version_id) |
| public.assessment_topic | assessment_topic_id_school_id_idx | CREATE UNIQUE INDEX assessment_topic_id_school_id_idx ON public.assessment_topic USING btree (id, school_id) |
| public.assessment_topic | assessment_topic_pkey | CREATE UNIQUE INDEX assessment_topic_pkey ON public.assessment_topic USING btree (id) |
| public.assessment_topic_result | assessment_topic_result_id_school_id_idx | CREATE UNIQUE INDEX assessment_topic_result_id_school_id_idx ON public.assessment_topic_result USING btree (id, school_id) |
| public.assessment_topic_result | assessment_topic_result_pkey | CREATE UNIQUE INDEX assessment_topic_result_pkey ON public.assessment_topic_result USING btree (id) |
| public.assessment_topic_result | assessment_topic_result_result_version_id_assessment_topic__idx | CREATE UNIQUE INDEX assessment_topic_result_result_version_id_assessment_topic__idx ON public.assessment_topic_result USING btree (result_version_id, assessment_topic_id, school_id) |
| public.document_release_decision | document_release_decision_pkey | CREATE UNIQUE INDEX document_release_decision_pkey ON public.document_release_decision USING btree (id) |
| public.enrollment_source_state | enrollment_source_state_pkey | CREATE UNIQUE INDEX enrollment_source_state_pkey ON public.enrollment_source_state USING btree (id) |
| public.inbox_message | inbox_message_pkey | CREATE UNIQUE INDEX inbox_message_pkey ON public.inbox_message USING btree (id) |
| public.learning_audit_event | learning_audit_event_id_school_id_idx | CREATE UNIQUE INDEX learning_audit_event_id_school_id_idx ON public.learning_audit_event USING btree (id, school_id) |
| public.learning_audit_event | learning_audit_event_pkey | CREATE UNIQUE INDEX learning_audit_event_pkey ON public.learning_audit_event USING btree (id) |
| public.learning_operation | learning_operation_pkey | CREATE UNIQUE INDEX learning_operation_pkey ON public.learning_operation USING btree (school_id, id) |
| public.lesson_planning_policy | lesson_planning_policy_pkey | CREATE UNIQUE INDEX lesson_planning_policy_pkey ON public.lesson_planning_policy USING btree (id) |
| public.lesson_planning_policy | lesson_planning_policy_school_id_program_version_id_kind_key | CREATE UNIQUE INDEX lesson_planning_policy_school_id_program_version_id_kind_key ON public.lesson_planning_policy USING btree (school_id, program_version_id, kind) |
| public.lesson_source_snapshot | lesson_source_snapshot_id_school_id_idx | CREATE UNIQUE INDEX lesson_source_snapshot_id_school_id_idx ON public.lesson_source_snapshot USING btree (id, school_id) |
| public.lesson_source_snapshot | lesson_source_snapshot_id_school_id_lesson_id_idx | CREATE UNIQUE INDEX lesson_source_snapshot_id_school_id_lesson_id_idx ON public.lesson_source_snapshot USING btree (id, school_id, lesson_id) |
| public.lesson_source_snapshot | lesson_source_snapshot_lesson_id_lesson_revision_school_id_idx | CREATE UNIQUE INDEX lesson_source_snapshot_lesson_id_lesson_revision_school_id_idx ON public.lesson_source_snapshot USING btree (lesson_id, lesson_revision, school_id) |
| public.lesson_source_snapshot | lesson_source_snapshot_pkey | CREATE UNIQUE INDEX lesson_source_snapshot_pkey ON public.lesson_source_snapshot USING btree (id) |
| public.lesson_source_state | lesson_source_state_id_school_id_idx | CREATE UNIQUE INDEX lesson_source_state_id_school_id_idx ON public.lesson_source_state USING btree (id, school_id) |
| public.lesson_source_state | lesson_source_state_lesson_id_school_id_idx | CREATE UNIQUE INDEX lesson_source_state_lesson_id_school_id_idx ON public.lesson_source_state USING btree (lesson_id, school_id) |
| public.lesson_source_state | lesson_source_state_pkey | CREATE UNIQUE INDEX lesson_source_state_pkey ON public.lesson_source_state USING btree (id) |
| public.outbox_message | ix_outbox_message_sent_at_next_attempt_at | CREATE INDEX ix_outbox_message_sent_at_next_attempt_at ON public.outbox_message USING btree (sent_at, next_attempt_at) |
| public.outbox_message | outbox_message_pkey | CREATE UNIQUE INDEX outbox_message_pkey ON public.outbox_message USING btree (id) |
| public.policy_attestation | policy_attestation_pkey | CREATE UNIQUE INDEX policy_attestation_pkey ON public.policy_attestation USING btree (school_id, id) |
| public.practical_record_response | idx_practical_response_eligibility | CREATE INDEX idx_practical_response_eligibility ON public.practical_record_response USING btree (record_version_id, actor_role, response) |
| public.practical_record_response | practical_record_response_command_id_school_id_idx | CREATE UNIQUE INDEX practical_record_response_command_id_school_id_idx ON public.practical_record_response USING btree (command_id, school_id) |
| public.practical_record_response | practical_record_response_id_school_id_idx | CREATE UNIQUE INDEX practical_record_response_id_school_id_idx ON public.practical_record_response USING btree (id, school_id) |
| public.practical_record_response | practical_record_response_id_school_id_record_version_id_idx | CREATE UNIQUE INDEX practical_record_response_id_school_id_record_version_id_idx ON public.practical_record_response USING btree (id, school_id, record_version_id) |
| public.practical_record_response | practical_record_response_pkey | CREATE UNIQUE INDEX practical_record_response_pkey ON public.practical_record_response USING btree (id) |
| public.practical_record_response | practical_record_response_record_id_sequence_school_id_idx | CREATE UNIQUE INDEX practical_record_response_record_id_sequence_school_id_idx ON public.practical_record_response USING btree (record_id, sequence, school_id) |
| public.practical_record_topic | practical_record_topic_id_school_id_idx | CREATE UNIQUE INDEX practical_record_topic_id_school_id_idx ON public.practical_record_topic USING btree (id, school_id) |
| public.practical_record_topic | practical_record_topic_pkey | CREATE UNIQUE INDEX practical_record_topic_pkey ON public.practical_record_topic USING btree (id) |
| public.practical_record_topic | practical_record_topic_record_version_id_topic_id_school_id_idx | CREATE UNIQUE INDEX practical_record_topic_record_version_id_topic_id_school_id_idx ON public.practical_record_topic USING btree (record_version_id, topic_id, school_id) |
| public.practical_record_version | practical_record_version_id_school_id_enrollment_id_idx | CREATE UNIQUE INDEX practical_record_version_id_school_id_enrollment_id_idx ON public.practical_record_version USING btree (id, school_id, enrollment_id) |
| public.practical_record_version | practical_record_version_id_school_id_idx | CREATE UNIQUE INDEX practical_record_version_id_school_id_idx ON public.practical_record_version USING btree (id, school_id) |
| public.practical_record_version | practical_record_version_id_school_id_program_version_id_idx | CREATE UNIQUE INDEX practical_record_version_id_school_id_program_version_id_idx ON public.practical_record_version USING btree (id, school_id, program_version_id) |
| public.practical_record_version | practical_record_version_id_school_id_record_id_idx | CREATE UNIQUE INDEX practical_record_version_id_school_id_record_id_idx ON public.practical_record_version USING btree (id, school_id, record_id) |
| public.practical_record_version | practical_record_version_pkey | CREATE UNIQUE INDEX practical_record_version_pkey ON public.practical_record_version USING btree (id) |
| public.practical_record_version | practical_record_version_record_id_version_school_id_idx | CREATE UNIQUE INDEX practical_record_version_record_id_version_school_id_idx ON public.practical_record_version USING btree (record_id, version, school_id) |
| public.practical_training_record | idx_practical_by_enrollment | CREATE INDEX idx_practical_by_enrollment ON public.practical_training_record USING btree (school_id, enrollment_id) |
| public.practical_training_record | practical_training_record_id_school_id_enrollment_id_lesson_idx | CREATE UNIQUE INDEX practical_training_record_id_school_id_enrollment_id_lesson_idx ON public.practical_training_record USING btree (id, school_id, enrollment_id, lesson_id) |
| public.practical_training_record | practical_training_record_id_school_id_idx | CREATE UNIQUE INDEX practical_training_record_id_school_id_idx ON public.practical_training_record USING btree (id, school_id) |
| public.practical_training_record | practical_training_record_lesson_id_enrollment_id_school_id_idx | CREATE UNIQUE INDEX practical_training_record_lesson_id_enrollment_id_school_id_idx ON public.practical_training_record USING btree (lesson_id, enrollment_id, school_id) |
| public.practical_training_record | practical_training_record_pkey | CREATE UNIQUE INDEX practical_training_record_pkey ON public.practical_training_record USING btree (id) |
| public.program_rule_source | program_rule_source_id_school_id_idx | CREATE UNIQUE INDEX program_rule_source_id_school_id_idx ON public.program_rule_source USING btree (id, school_id) |
| public.program_rule_source | program_rule_source_pkey | CREATE UNIQUE INDEX program_rule_source_pkey ON public.program_rule_source USING btree (id) |
| public.readiness_decision | readiness_decision_command_id_school_id_idx | CREATE UNIQUE INDEX readiness_decision_command_id_school_id_idx ON public.readiness_decision USING btree (command_id, school_id) |
| public.readiness_decision | readiness_decision_id_school_id_enrollment_id_idx | CREATE UNIQUE INDEX readiness_decision_id_school_id_enrollment_id_idx ON public.readiness_decision USING btree (id, school_id, enrollment_id) |
| public.readiness_decision | readiness_decision_id_school_id_idx | CREATE UNIQUE INDEX readiness_decision_id_school_id_idx ON public.readiness_decision USING btree (id, school_id) |
| public.readiness_decision | readiness_decision_id_school_id_readiness_id_idx | CREATE UNIQUE INDEX readiness_decision_id_school_id_readiness_id_idx ON public.readiness_decision USING btree (id, school_id, readiness_id) |
| public.readiness_decision | readiness_decision_pkey | CREATE UNIQUE INDEX readiness_decision_pkey ON public.readiness_decision USING btree (id) |
| public.readiness_evaluation | readiness_evaluation_id_school_id_definition_version_id_idx | CREATE UNIQUE INDEX readiness_evaluation_id_school_id_definition_version_id_idx ON public.readiness_evaluation USING btree (id, school_id, definition_version_id) |
| public.readiness_evaluation | readiness_evaluation_id_school_id_enrollment_id_idx | CREATE UNIQUE INDEX readiness_evaluation_id_school_id_enrollment_id_idx ON public.readiness_evaluation USING btree (id, school_id, enrollment_id) |
| public.readiness_evaluation | readiness_evaluation_id_school_id_idx | CREATE UNIQUE INDEX readiness_evaluation_id_school_id_idx ON public.readiness_evaluation USING btree (id, school_id) |
| public.readiness_evaluation | readiness_evaluation_id_school_id_readiness_id_idx | CREATE UNIQUE INDEX readiness_evaluation_id_school_id_readiness_id_idx ON public.readiness_evaluation USING btree (id, school_id, readiness_id) |
| public.readiness_evaluation | readiness_evaluation_pkey | CREATE UNIQUE INDEX readiness_evaluation_pkey ON public.readiness_evaluation USING btree (id) |
| public.readiness_evidence_basis | idx_readiness_evidence_scope | CREATE INDEX idx_readiness_evidence_scope ON public.readiness_evidence_basis USING btree (school_id, enrollment_id, evaluation_id) |
| public.readiness_evidence_basis | readiness_evidence_basis_evaluation_id_lesson_id_school_id_idx | CREATE UNIQUE INDEX readiness_evidence_basis_evaluation_id_lesson_id_school_id_idx ON public.readiness_evidence_basis USING btree (evaluation_id, lesson_id, school_id) |
| public.readiness_evidence_basis | readiness_evidence_basis_evaluation_id_result_version_id_sc_idx | CREATE UNIQUE INDEX readiness_evidence_basis_evaluation_id_result_version_id_sc_idx ON public.readiness_evidence_basis USING btree (evaluation_id, result_version_id, school_id) |
| public.readiness_evidence_basis | readiness_evidence_basis_id_school_id_idx | CREATE UNIQUE INDEX readiness_evidence_basis_id_school_id_idx ON public.readiness_evidence_basis USING btree (id, school_id) |
| public.readiness_evidence_basis | readiness_evidence_basis_pkey | CREATE UNIQUE INDEX readiness_evidence_basis_pkey ON public.readiness_evidence_basis USING btree (id) |
| public.readiness_requirement_result | readiness_requirement_result_evaluation_id_requirement_id_s_idx | CREATE UNIQUE INDEX readiness_requirement_result_evaluation_id_requirement_id_s_idx ON public.readiness_requirement_result USING btree (evaluation_id, requirement_id, school_id) |
| public.readiness_requirement_result | readiness_requirement_result_id_school_id_idx | CREATE UNIQUE INDEX readiness_requirement_result_id_school_id_idx ON public.readiness_requirement_result USING btree (id, school_id) |
| public.readiness_requirement_result | readiness_requirement_result_pkey | CREATE UNIQUE INDEX readiness_requirement_result_pkey ON public.readiness_requirement_result USING btree (id) |
| public.reporting_declaration | reporting_declaration_command_id_school_id_idx | CREATE UNIQUE INDEX reporting_declaration_command_id_school_id_idx ON public.reporting_declaration USING btree (command_id, school_id) |
| public.reporting_declaration | reporting_declaration_id_school_id_idx | CREATE UNIQUE INDEX reporting_declaration_id_school_id_idx ON public.reporting_declaration USING btree (id, school_id) |
| public.reporting_declaration | reporting_declaration_pkey | CREATE UNIQUE INDEX reporting_declaration_pkey ON public.reporting_declaration USING btree (id) |
| public.school_source_state | PK_school_source_state | CREATE UNIQUE INDEX "PK_school_source_state" ON public.school_source_state USING btree (id) |
| public.student_training | student_training_id_school_id_category_code_idx | CREATE UNIQUE INDEX student_training_id_school_id_category_code_idx ON public.student_training USING btree (id, school_id, category_code) |
| public.student_training | student_training_id_school_id_idx | CREATE UNIQUE INDEX student_training_id_school_id_idx ON public.student_training USING btree (id, school_id) |
| public.student_training | student_training_id_school_id_program_version_id_idx | CREATE UNIQUE INDEX student_training_id_school_id_program_version_id_idx ON public.student_training USING btree (id, school_id, program_version_id) |
| public.student_training | student_training_id_school_id_student_id_idx | CREATE UNIQUE INDEX student_training_id_school_id_student_id_idx ON public.student_training USING btree (id, school_id, student_id) |
| public.student_training | student_training_pkey | CREATE UNIQUE INDEX student_training_pkey ON public.student_training USING btree (id) |
| public.theory_attendance | idx_theory_attendance_by_enrollment | CREATE INDEX idx_theory_attendance_by_enrollment ON public.theory_attendance USING btree (school_id, enrollment_id, record_version_id) |
| public.theory_attendance | theory_attendance_id_school_id_enrollment_id_idx | CREATE UNIQUE INDEX theory_attendance_id_school_id_enrollment_id_idx ON public.theory_attendance USING btree (id, school_id, enrollment_id) |
| public.theory_attendance | theory_attendance_id_school_id_idx | CREATE UNIQUE INDEX theory_attendance_id_school_id_idx ON public.theory_attendance USING btree (id, school_id) |
| public.theory_attendance | theory_attendance_pkey | CREATE UNIQUE INDEX theory_attendance_pkey ON public.theory_attendance USING btree (id) |
| public.theory_attendance | theory_attendance_record_version_id_enrollment_id_school_id_idx | CREATE UNIQUE INDEX theory_attendance_record_version_id_enrollment_id_school_id_idx ON public.theory_attendance USING btree (record_version_id, enrollment_id, school_id) |
| public.theory_record_version | theory_record_version_id_school_id_idx | CREATE UNIQUE INDEX theory_record_version_id_school_id_idx ON public.theory_record_version USING btree (id, school_id) |
| public.theory_record_version | theory_record_version_id_school_id_lesson_id_idx | CREATE UNIQUE INDEX theory_record_version_id_school_id_lesson_id_idx ON public.theory_record_version USING btree (id, school_id, lesson_id) |
| public.theory_record_version | theory_record_version_id_school_id_record_id_idx | CREATE UNIQUE INDEX theory_record_version_id_school_id_record_id_idx ON public.theory_record_version USING btree (id, school_id, record_id) |
| public.theory_record_version | theory_record_version_pkey | CREATE UNIQUE INDEX theory_record_version_pkey ON public.theory_record_version USING btree (id) |
| public.theory_record_version | theory_record_version_record_id_version_school_id_idx | CREATE UNIQUE INDEX theory_record_version_record_id_version_school_id_idx ON public.theory_record_version USING btree (record_id, version, school_id) |
| public.theory_training_record | theory_training_record_id_school_id_idx | CREATE UNIQUE INDEX theory_training_record_id_school_id_idx ON public.theory_training_record USING btree (id, school_id) |
| public.theory_training_record | theory_training_record_id_school_id_lesson_id_idx | CREATE UNIQUE INDEX theory_training_record_id_school_id_lesson_id_idx ON public.theory_training_record USING btree (id, school_id, lesson_id) |
| public.theory_training_record | theory_training_record_lesson_id_school_id_idx | CREATE UNIQUE INDEX theory_training_record_lesson_id_school_id_idx ON public.theory_training_record USING btree (lesson_id, school_id) |
| public.theory_training_record | theory_training_record_pkey | CREATE UNIQUE INDEX theory_training_record_pkey ON public.theory_training_record USING btree (id) |
| public.training_evidence_check | idx_check_item_target | CREATE INDEX idx_check_item_target ON public.training_evidence_check USING btree (evidence_item_id, school_id, snapshot_id) |
| public.training_evidence_check | idx_check_snapshot_tenant | CREATE INDEX idx_check_snapshot_tenant ON public.training_evidence_check USING btree (snapshot_id, school_id, enrollment_id) |
| public.training_evidence_check | training_evidence_check_id_school_id_idx | CREATE UNIQUE INDEX training_evidence_check_id_school_id_idx ON public.training_evidence_check USING btree (id, school_id) |
| public.training_evidence_check | training_evidence_check_pkey | CREATE UNIQUE INDEX training_evidence_check_pkey ON public.training_evidence_check USING btree (id) |
| public.training_evidence_check | ux_training_evidence_check_item | CREATE UNIQUE INDEX ux_training_evidence_check_item ON public.training_evidence_check USING btree (snapshot_id, school_id, check_code, field_code, evidence_item_id) WHERE (evidence_item_id IS NOT NULL) |
| public.training_evidence_check | ux_training_evidence_check_snapshot | CREATE UNIQUE INDEX ux_training_evidence_check_snapshot ON public.training_evidence_check USING btree (snapshot_id, school_id, check_code, field_code) WHERE (evidence_item_id IS NULL) |
| public.training_evidence_item | training_evidence_item_id_school_id_idx | CREATE UNIQUE INDEX training_evidence_item_id_school_id_idx ON public.training_evidence_item USING btree (id, school_id) |
| public.training_evidence_item | training_evidence_item_id_school_id_snapshot_id_idx | CREATE UNIQUE INDEX training_evidence_item_id_school_id_snapshot_id_idx ON public.training_evidence_item USING btree (id, school_id, snapshot_id) |
| public.training_evidence_item | training_evidence_item_pkey | CREATE UNIQUE INDEX training_evidence_item_pkey ON public.training_evidence_item USING btree (id) |
| public.training_evidence_item | training_evidence_item_snapshot_id_lesson_id_school_id_idx | CREATE UNIQUE INDEX training_evidence_item_snapshot_id_lesson_id_school_id_idx ON public.training_evidence_item USING btree (snapshot_id, lesson_id, school_id) |
| public.training_evidence_snapshot | training_evidence_snapshot_id_school_id_enrollment_id_idx | CREATE UNIQUE INDEX training_evidence_snapshot_id_school_id_enrollment_id_idx ON public.training_evidence_snapshot USING btree (id, school_id, enrollment_id) |
| public.training_evidence_snapshot | training_evidence_snapshot_id_school_id_idx | CREATE UNIQUE INDEX training_evidence_snapshot_id_school_id_idx ON public.training_evidence_snapshot USING btree (id, school_id) |
| public.training_evidence_snapshot | training_evidence_snapshot_pkey | CREATE UNIQUE INDEX training_evidence_snapshot_pkey ON public.training_evidence_snapshot USING btree (id) |
| public.training_program | training_program_id_school_id_category_code_idx | CREATE UNIQUE INDEX training_program_id_school_id_category_code_idx ON public.training_program USING btree (id, school_id, category_code) |
| public.training_program | training_program_id_school_id_idx | CREATE UNIQUE INDEX training_program_id_school_id_idx ON public.training_program USING btree (id, school_id) |
| public.training_program | training_program_pkey | CREATE UNIQUE INDEX training_program_pkey ON public.training_program USING btree (id) |
| public.training_program_version | training_program_version_id_school_id_idx | CREATE UNIQUE INDEX training_program_version_id_school_id_idx ON public.training_program_version USING btree (id, school_id) |
| public.training_program_version | training_program_version_id_school_id_program_id_idx | CREATE UNIQUE INDEX training_program_version_id_school_id_program_id_idx ON public.training_program_version USING btree (id, school_id, program_id) |
| public.training_program_version | training_program_version_pkey | CREATE UNIQUE INDEX training_program_version_pkey ON public.training_program_version USING btree (id) |
| public.training_program_version | training_program_version_program_id_version_school_id_idx | CREATE UNIQUE INDEX training_program_version_program_id_version_school_id_idx ON public.training_program_version USING btree (program_id, version, school_id) |
| public.training_topic | training_topic_id_school_id_idx | CREATE UNIQUE INDEX training_topic_id_school_id_idx ON public.training_topic USING btree (id, school_id) |
| public.training_topic | training_topic_id_school_id_program_version_id_idx | CREATE UNIQUE INDEX training_topic_id_school_id_program_version_id_idx ON public.training_topic USING btree (id, school_id, program_version_id) |
| public.training_topic | training_topic_pkey | CREATE UNIQUE INDEX training_topic_pkey ON public.training_topic USING btree (id) |
| public.training_topic | training_topic_program_version_id_topic_key_school_id_idx | CREATE UNIQUE INDEX training_topic_program_version_id_topic_key_school_id_idx ON public.training_topic USING btree (program_version_id, topic_key, school_id) |

## Row-Level Security

| Schema / table | Enabled | Forced |
|---|---|---|
| public.__EFMigrationsHistory | False | False |
| public.document_release_decision | True | True |
| public.inbox_message | True | False |
| public.enrollment_source_state | True | False |
| public.policy_attestation | True | False |
| public.school_source_state | True | False |
| public.lesson_planning_policy | True | False |
| public.learning_operation | True | False |
| public.outbox_message | True | False |
| public.training_program | True | False |
| public.training_program_version | True | False |
| public.assessment_definition | True | False |
| public.student_training | True | False |
| public.lesson_source_snapshot | True | False |
| public.lesson_source_state | True | False |
| public.practical_training_record | True | False |
| public.practical_record_version | True | False |
| public.practical_record_topic | True | False |
| public.practical_record_response | True | False |
| public.theory_training_record | True | False |
| public.theory_record_version | True | False |
| public.theory_attendance | True | False |
| public.assessment_readiness | True | False |
| public.readiness_evaluation | True | False |
| public.readiness_requirement_result | True | False |
| public.readiness_evidence_basis | True | False |
| public.readiness_decision | True | False |
| public.assessment | True | False |
| public.assessment_result_version | True | False |
| public.assessment_topic_result | True | False |
| public.program_rule_source | True | False |
| public.training_topic | True | False |
| public.assessment_definition_version | True | False |
| public.assessment_topic | True | False |
| public.admission_requirement | True | False |
| public.training_evidence_snapshot | True | False |
| public.training_evidence_item | True | False |
| public.training_evidence_check | True | False |
| public.reporting_declaration | True | False |
| public.learning_audit_event | True | False |

Policy expressions and command/role restrictions are retained verbatim in `../schema/implemented-catalogue.json` and `../schema/implemented-schema.sql`. Schema DDL also contains functions and triggers enforcing integrity and audit invariants.
