# Learning Tracking — Logical relational schema

Authority: Owner-adopted D-042, no ledger or programme transfer. [Canonical DBML](../schema/schema.dbml).

The [Mermaid diagram](../schema/database-erd.md) shows keys/FKs and representative attributes; full attributes/defaults/classification are in data-dictionary.md. 

Physical count: 31 domain tables, 312 columns, 56 local FK declarations. EF migration history, where present, is technical metadata, not a new aggregate.

## Relationships and optionality

| Parent key | Child FK | Required? | Cardinality / integrity |
|---|---|---|---|
| training_program(id,school_id) | training_program_version(program_id,school_id) | Yes | 0..N children per parent; default NO ACTION |
| training_program_version(id,school_id) | program_rule_source(program_version_id,school_id) | Yes | 0..N children per parent; default NO ACTION |
| training_program_version(id,school_id) | training_topic(program_version_id,school_id) | Yes | 0..N children per parent; default NO ACTION |
| training_program(id,school_id) | assessment_definition(program_id,school_id) | Yes | 0..N children per parent; default NO ACTION |
| assessment_definition(id,school_id,program_id) | assessment_definition_version(definition_id,school_id,program_id) | Yes | 0..N children per parent; default NO ACTION |
| training_program_version(id,school_id,program_id) | assessment_definition_version(program_version_id,school_id,program_id) | Yes | 0..N children per parent; default NO ACTION |
| assessment_definition_version(id,school_id,program_version_id) | assessment_topic(definition_version_id,school_id,program_version_id) | Yes | 0..N children per parent; default NO ACTION |
| training_topic(id,school_id,program_version_id) | assessment_topic(topic_id,school_id,program_version_id) | Yes | 0..N children per parent; default NO ACTION |
| assessment_definition_version(id,school_id,program_version_id) | admission_requirement(definition_version_id,school_id,program_version_id) | Yes | 0..N children per parent; default NO ACTION |
| assessment_definition_version(id,school_id,program_version_id) | admission_requirement(prerequisite_definition_version_id,school_id,program_version_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| training_program_version(id,school_id) | student_training(program_version_id,school_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| lesson_source_snapshot(id,school_id,lesson_id) | lesson_source_state(current_snapshot_id,school_id,lesson_id) | Yes | 0..1 child per parent; default NO ACTION |
| student_training(id,school_id) | practical_training_record(enrollment_id,school_id) | Yes | 0..N children per parent; default NO ACTION |
| practical_training_record(id,school_id,enrollment_id,lesson_id) | practical_record_version(record_id,school_id,enrollment_id,lesson_id) | Yes | 0..N children per parent; default NO ACTION |
| student_training(id,school_id,program_version_id) | practical_record_version(enrollment_id,school_id,program_version_id) | Yes | 0..N children per parent; default NO ACTION |
| lesson_source_snapshot(id,school_id,lesson_id) | practical_record_version(source_snapshot_id,school_id,lesson_id) | Yes | 0..N children per parent; default NO ACTION |
| practical_record_version(id,school_id,record_id) | practical_training_record(current_version_id,school_id,id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..1 child per parent; default NO ACTION |
| practical_record_version(id,school_id,program_version_id) | practical_record_topic(record_version_id,school_id,program_version_id) | Yes | 0..N children per parent; default NO ACTION |
| training_topic(id,school_id,program_version_id) | practical_record_topic(topic_id,school_id,program_version_id) | Yes | 0..N children per parent; default NO ACTION |
| practical_record_version(id,school_id,record_id) | practical_record_response(record_version_id,school_id,record_id) | Yes | 0..N children per parent; default NO ACTION |
| theory_training_record(id,school_id,lesson_id) | theory_record_version(record_id,school_id,lesson_id) | Yes | 0..N children per parent; default NO ACTION |
| lesson_source_snapshot(id,school_id,lesson_id) | theory_record_version(source_snapshot_id,school_id,lesson_id) | Yes | 0..N children per parent; default NO ACTION |
| theory_record_version(id,school_id,record_id) | theory_training_record(current_version_id,school_id,id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..1 child per parent; default NO ACTION |
| theory_record_version(id,school_id) | theory_attendance(record_version_id,school_id) | Yes | 0..N children per parent; default NO ACTION |
| student_training(id,school_id,student_id) | theory_attendance(enrollment_id,school_id,student_id) | Yes | 0..N children per parent; default NO ACTION |
| student_training(id,school_id,program_version_id) | assessment_readiness(enrollment_id,school_id,program_version_id) | Yes | 0..N children per parent; default NO ACTION |
| assessment_definition_version(id,school_id,program_version_id) | assessment_readiness(definition_version_id,school_id,program_version_id) | Yes | 0..N children per parent; default NO ACTION |
| assessment_readiness(id,school_id,enrollment_id) | readiness_evaluation(readiness_id,school_id,enrollment_id) | Yes | 0..N children per parent; default NO ACTION |
| assessment_readiness(id,school_id,definition_version_id) | readiness_evaluation(readiness_id,school_id,definition_version_id) | Yes | 0..N children per parent; default NO ACTION |
| readiness_evaluation(id,school_id,readiness_id) | assessment_readiness(current_evaluation_id,school_id,id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..1 child per parent; default NO ACTION |
| readiness_evaluation(id,school_id,definition_version_id) | readiness_requirement_result(evaluation_id,school_id,definition_version_id) | Yes | 0..N children per parent; default NO ACTION |
| admission_requirement(id,school_id,definition_version_id) | readiness_requirement_result(requirement_id,school_id,definition_version_id) | Yes | 0..N children per parent; default NO ACTION |
| readiness_evaluation(id,school_id,enrollment_id) | readiness_evidence_basis(evaluation_id,school_id,enrollment_id) | Yes | 0..N children per parent; default NO ACTION |
| practical_record_version(id,school_id,enrollment_id) | readiness_evidence_basis(practical_record_version_id,school_id,enrollment_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| theory_attendance(id,school_id,enrollment_id) | readiness_evidence_basis(theory_attendance_id,school_id,enrollment_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| assessment_result_version(id,school_id,enrollment_id) | readiness_evidence_basis(result_version_id,school_id,enrollment_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| readiness_evaluation(id,school_id,readiness_id) | readiness_decision(evaluation_id,school_id,readiness_id) | Yes | 0..N children per parent; default NO ACTION |
| readiness_evaluation(id,school_id,enrollment_id) | readiness_decision(evaluation_id,school_id,enrollment_id) | Yes | 0..N children per parent; default NO ACTION |
| readiness_decision(id,school_id,readiness_id) | assessment_readiness(current_decision_id,school_id,id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..1 child per parent; default NO ACTION |
| student_training(id,school_id,program_version_id) | assessment(enrollment_id,school_id,program_version_id) | Yes | 0..N children per parent; default NO ACTION |
| assessment_definition_version(id,school_id,program_version_id) | assessment(definition_version_id,school_id,program_version_id) | Yes | 0..N children per parent; default NO ACTION |
| assessment(id,school_id,enrollment_id,definition_version_id) | assessment_result_version(assessment_id,school_id,enrollment_id,definition_version_id) | Yes | 0..N children per parent; default NO ACTION |
| assessment_readiness(id,school_id,enrollment_id,definition_version_id) | assessment_result_version(readiness_id,school_id,enrollment_id,definition_version_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| readiness_decision(id,school_id,readiness_id) | assessment_result_version(readiness_decision_id,school_id,readiness_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| assessment_result_version(id,school_id,definition_version_id) | assessment_topic_result(result_version_id,school_id,definition_version_id) | Yes | 0..N children per parent; default NO ACTION |
| assessment_topic(id,school_id,definition_version_id) | assessment_topic_result(assessment_topic_id,school_id,definition_version_id) | Yes | 0..N children per parent; default NO ACTION |
| student_training(id,school_id,program_version_id) | training_evidence_snapshot(enrollment_id,school_id,program_version_id) | Yes | 0..N children per parent; default NO ACTION |
| training_evidence_snapshot(id,school_id,enrollment_id) | training_evidence_item(snapshot_id,school_id,enrollment_id) | Yes | 0..N children per parent; default NO ACTION |
| practical_record_version(id,school_id,enrollment_id) | training_evidence_item(practical_record_version_id,school_id,enrollment_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| assessment_result_version(id,school_id,enrollment_id) | training_evidence_item(result_version_id,school_id,enrollment_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| theory_attendance(id,school_id,enrollment_id) | training_evidence_item(theory_attendance_id,school_id,enrollment_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| readiness_decision(id,school_id,enrollment_id) | training_evidence_item(readiness_decision_id,school_id,enrollment_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| training_evidence_snapshot(id,school_id,enrollment_id) | training_evidence_check(snapshot_id,school_id,enrollment_id) | Yes | 0..N children per parent; default NO ACTION |
| training_evidence_item(id,school_id,snapshot_id) | training_evidence_check(evidence_item_id,school_id,snapshot_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| training_evidence_snapshot(id,school_id) | reporting_declaration(snapshot_id,school_id) | Yes | 0..N children per parent; default NO ACTION |
| lesson_source_snapshot(id,school_id) | learning_audit_event(source_snapshot_id,school_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |

## Deployment/transaction source

[Install wrapper](../ddl/install.sql) is the only fresh-install entry. It references existing canonical SQL or the generated initial migration, not another service’s same-named schema.sql. [Security overlay](../security/database-roles.sql) follows schema creation; demo seeds run only under explicit test gates.

No previous production migration history was found/assumed. Reapplying raw initial DDL over a populated database is forbidden. Scheduling has a real EF migration/snapshot and no-op migration rerun check; other contexts use a fresh SQL baseline and require a separately reviewed differential upgrade if legacy data exists.

Current remote owner/API gaps do not by themselves invalidate relational design. They remain runtime/integration gates and cannot be proven by FK tests.

## Executable database rules beyond DBML

- admission_requirement.admission_requirement_definition_version_id_school_id_prog_fkey: `FOREIGN KEY (definition_version_id, school_id, program_version_id) REFERENCES assessment_definition_version(id, school_id, program_version_id) DEFERRABLE`.
- admission_requirement.admission_requirement_pkey: `PRIMARY KEY (id)`.
- admission_requirement.admission_requirement_prerequisite_definition_version_id_s_fkey: `FOREIGN KEY (prerequisite_definition_version_id, school_id, program_version_id) REFERENCES assessment_definition_version(id, school_id, program_version_id) DEFERRABLE`.
- admission_requirement.requirement_typed_shape: `CHECK ((((kind = ANY (ARRAY['MinimumTheoryMinutes'::lt_requirement_kind, 'MinimumPracticalMinutes'::lt_requirement_kind])) AND (minimum_minutes IS NOT NULL) AND (minimum_minutes >= 0) AND (prerequisite_definition_version_id IS NULL) AND (minimum_mark IS NULL)) OR ((kind = 'AssessmentPassed'::lt_requirement_kind) AND (minimum_minutes IS NULL) AND (prerequisite_definition_version_id IS NOT NULL) AND (minimum_mark IS NULL)) OR ((kind = 'MinimumMark'::lt_requirement_kind) AND (minimum_minutes IS NULL) AND (prerequisite_definition_version_id IS NOT NULL) AND (minimum_mark IS NOT NULL))))`.
- assessment.assessment_attempt_positive: `CHECK (((attempt_number > 0) AND (revision > 0)))`.
- assessment.assessment_definition_version_id_school_id_program_version_fkey: `FOREIGN KEY (definition_version_id, school_id, program_version_id) REFERENCES assessment_definition_version(id, school_id, program_version_id) DEFERRABLE`.
- assessment.assessment_enrollment_id_school_id_program_version_id_fkey: `FOREIGN KEY (enrollment_id, school_id, program_version_id) REFERENCES student_training(id, school_id, program_version_id) DEFERRABLE`.
- assessment.assessment_pkey: `PRIMARY KEY (id)`.
- assessment_definition.assessment_definition_pkey: `PRIMARY KEY (id)`.
- assessment_definition.assessment_definition_program_id_school_id_fkey: `FOREIGN KEY (program_id, school_id) REFERENCES training_program(id, school_id) DEFERRABLE`.
- assessment_definition_version.assessment_definition_version_definition_id_school_id_prog_fkey: `FOREIGN KEY (definition_id, school_id, program_id) REFERENCES assessment_definition(id, school_id, program_id) DEFERRABLE`.
- assessment_definition_version.assessment_definition_version_pkey: `PRIMARY KEY (id)`.
- assessment_definition_version.assessment_definition_version_program_version_id_school_id_fkey: `FOREIGN KEY (program_version_id, school_id, program_id) REFERENCES training_program_version(id, school_id, program_id) DEFERRABLE`.
- assessment_definition_version.assessment_scale: `CHECK (((minimum_mark < maximum_mark) AND (passing_mark >= minimum_mark) AND (passing_mark <= maximum_mark)))`.
- assessment_readiness.assessment_readiness_current_decision_id_school_id_id_fkey: `FOREIGN KEY (current_decision_id, school_id, id) REFERENCES readiness_decision(id, school_id, readiness_id) DEFERRABLE`.
- assessment_readiness.assessment_readiness_current_evaluation_id_school_id_id_fkey: `FOREIGN KEY (current_evaluation_id, school_id, id) REFERENCES readiness_evaluation(id, school_id, readiness_id) DEFERRABLE`.
- assessment_readiness.assessment_readiness_definition_version_id_school_id_progr_fkey: `FOREIGN KEY (definition_version_id, school_id, program_version_id) REFERENCES assessment_definition_version(id, school_id, program_version_id) DEFERRABLE`.
- assessment_readiness.assessment_readiness_enrollment_id_school_id_program_versi_fkey: `FOREIGN KEY (enrollment_id, school_id, program_version_id) REFERENCES student_training(id, school_id, program_version_id) DEFERRABLE`.
- assessment_readiness.assessment_readiness_pkey: `PRIMARY KEY (id)`.
- assessment_readiness.readiness_revision_positive: `CHECK ((revision > 0))`.
- assessment_result_version.assessment_result_reason: `CHECK ((((version = 1) AND (status = 'Recorded'::lt_result_status) AND (correction_reason IS NULL)) OR ((version > 1) AND (correction_reason IS NOT NULL) AND (length(TRIM(BOTH FROM correction_reason)) > 0))))`.
- assessment_result_version.assessment_result_time: `CHECK ((recorded_at >= assessed_at))`.
- assessment_result_version.assessment_result_version_assessment_id_school_id_enrollme_fkey: `FOREIGN KEY (assessment_id, school_id, enrollment_id, definition_version_id) REFERENCES assessment(id, school_id, enrollment_id, definition_version_id) DEFERRABLE`.
- assessment_result_version.assessment_result_version_pkey: `PRIMARY KEY (id)`.
- assessment_result_version.assessment_result_version_positive: `CHECK ((version > 0))`.
- assessment_result_version.assessment_result_version_readiness_decision_id_school_id__fkey: `FOREIGN KEY (readiness_decision_id, school_id, readiness_id) REFERENCES readiness_decision(id, school_id, readiness_id) DEFERRABLE`.
- assessment_result_version.assessment_result_version_readiness_id_school_id_enrollmen_fkey: `FOREIGN KEY (readiness_id, school_id, enrollment_id, definition_version_id) REFERENCES assessment_readiness(id, school_id, enrollment_id, definition_version_id) DEFERRABLE`.
- assessment_result_version.result_readiness_pair: `CHECK (((readiness_id IS NULL) = (readiness_decision_id IS NULL)))`.
- assessment_result_version.result_review_pending_shape: `CHECK ((((status = 'ReviewRequired'::lt_result_status) AND (version > 1) AND (reviewed_invalidation_at IS NOT NULL)) OR (status <> 'ReviewRequired'::lt_result_status)))`.
- assessment_result_version.result_review_requires_decision: `CHECK (((reviewed_invalidation_at IS NULL) OR (readiness_decision_id IS NOT NULL)))`.
- assessment_result_version.result_review_timestamp: `CHECK (((reviewed_invalidation_at IS NULL) OR ((version > 1) AND (recorded_at >= reviewed_invalidation_at))))`.
- assessment_topic.assessment_topic_definition_version_id_school_id_program_v_fkey: `FOREIGN KEY (definition_version_id, school_id, program_version_id) REFERENCES assessment_definition_version(id, school_id, program_version_id) DEFERRABLE`.
- assessment_topic.assessment_topic_pkey: `PRIMARY KEY (id)`.
- assessment_topic.assessment_topic_topic_id_school_id_program_version_id_fkey: `FOREIGN KEY (topic_id, school_id, program_version_id) REFERENCES training_topic(id, school_id, program_version_id) DEFERRABLE`.
- assessment_topic_result.assessment_topic_result_assessment_topic_id_school_id_defi_fkey: `FOREIGN KEY (assessment_topic_id, school_id, definition_version_id) REFERENCES assessment_topic(id, school_id, definition_version_id) DEFERRABLE`.
- assessment_topic_result.assessment_topic_result_pkey: `PRIMARY KEY (id)`.
- assessment_topic_result.assessment_topic_result_result_version_id_school_id_defini_fkey: `FOREIGN KEY (result_version_id, school_id, definition_version_id) REFERENCES assessment_result_version(id, school_id, definition_version_id) DEFERRABLE`.
- learning_audit_event.learning_audit_event_pkey: `PRIMARY KEY (id)`.
- learning_audit_event.learning_audit_event_source_snapshot_id_school_id_fkey: `FOREIGN KEY (source_snapshot_id, school_id) REFERENCES lesson_source_snapshot(id, school_id) DEFERRABLE`.
- lesson_source_snapshot.completed_source_requires_actuals: `CHECK (((NOT (physically_completed AND source_valid)) OR ((actual_start IS NOT NULL) AND (actual_end IS NOT NULL))))`.
- lesson_source_snapshot.lesson_source_snapshot_pkey: `PRIMARY KEY (id)`.
- lesson_source_snapshot.source_actual_interval: `CHECK ((((actual_start IS NULL) AND (actual_end IS NULL)) OR ((actual_start IS NOT NULL) AND (actual_end IS NOT NULL) AND (actual_end > actual_start))))`.
- lesson_source_snapshot.source_kind_shape: `CHECK ((((kind = 'Practical'::lt_training_kind) AND (enrollment_id IS NOT NULL) AND (student_id IS NOT NULL) AND (vehicle_id IS NOT NULL) AND (group_id IS NULL) AND (membership_revision IS NULL)) OR ((kind = 'Theory'::lt_training_kind) AND (enrollment_id IS NULL) AND (student_id IS NULL) AND (vehicle_id IS NULL) AND (group_id IS NOT NULL) AND (membership_revision IS NOT NULL) AND (membership_revision > 0))))`.
- lesson_source_snapshot.source_revision_positive: `CHECK ((lesson_revision > 0))`.
- lesson_source_state.lesson_source_state_current_snapshot_id_school_id_lesson_i_fkey: `FOREIGN KEY (current_snapshot_id, school_id, lesson_id) REFERENCES lesson_source_snapshot(id, school_id, lesson_id) DEFERRABLE`.
- lesson_source_state.lesson_source_state_pkey: `PRIMARY KEY (id)`.
- practical_record_response.dispute_reason: `CHECK (((response <> 'Dispute'::lt_response_kind) OR ((reason IS NOT NULL) AND (length(TRIM(BOTH FROM reason)) > 0))))`.
- practical_record_response.practical_record_response_pkey: `PRIMARY KEY (id)`.
- practical_record_response.practical_record_response_record_version_id_school_id_reco_fkey: `FOREIGN KEY (record_version_id, school_id, record_id) REFERENCES practical_record_version(id, school_id, record_id) DEFERRABLE`.
- practical_record_response.response_sequence: `CHECK ((sequence > 0))`.
- practical_record_topic.practical_record_topic_pkey: `PRIMARY KEY (id)`.
- practical_record_topic.practical_record_topic_record_version_id_school_id_program_fkey: `FOREIGN KEY (record_version_id, school_id, program_version_id) REFERENCES practical_record_version(id, school_id, program_version_id) DEFERRABLE`.
- practical_record_topic.practical_record_topic_topic_id_school_id_program_version__fkey: `FOREIGN KEY (topic_id, school_id, program_version_id) REFERENCES training_topic(id, school_id, program_version_id) DEFERRABLE`.
- practical_record_version.practical_correction_reason: `CHECK (((version = 1) OR ((correction_reason IS NOT NULL) AND (length(TRIM(BOTH FROM correction_reason)) > 0))))`.
- practical_record_version.practical_distance: `CHECK (((distance_km IS NULL) OR (distance_km >= (0)::numeric)))`.
- practical_record_version.practical_minutes: `CHECK (((training_minutes IS NULL) OR (training_minutes > 0)))`.
- practical_record_version.practical_record_version_enrollment_id_school_id_program_v_fkey: `FOREIGN KEY (enrollment_id, school_id, program_version_id) REFERENCES student_training(id, school_id, program_version_id) DEFERRABLE`.
- practical_record_version.practical_record_version_pkey: `PRIMARY KEY (id)`.
- practical_record_version.practical_record_version_record_id_school_id_enrollment_id_fkey: `FOREIGN KEY (record_id, school_id, enrollment_id, lesson_id) REFERENCES practical_training_record(id, school_id, enrollment_id, lesson_id) DEFERRABLE`.
- practical_record_version.practical_record_version_source_snapshot_id_school_id_less_fkey: `FOREIGN KEY (source_snapshot_id, school_id, lesson_id) REFERENCES lesson_source_snapshot(id, school_id, lesson_id) DEFERRABLE`.
- practical_record_version.practical_valid_shape: `CHECK (((validation <> 'Valid'::lt_validation) OR ((training_minutes IS NOT NULL) AND (distance_km IS NOT NULL))))`.
- practical_record_version.practical_version_positive: `CHECK ((version > 0))`.
- practical_training_record.practical_revision_positive: `CHECK ((revision > 0))`.
- practical_training_record.practical_training_record_current_version_id_school_id_id_fkey: `FOREIGN KEY (current_version_id, school_id, id) REFERENCES practical_record_version(id, school_id, record_id) DEFERRABLE`.
- practical_training_record.practical_training_record_enrollment_id_school_id_fkey: `FOREIGN KEY (enrollment_id, school_id) REFERENCES student_training(id, school_id) DEFERRABLE`.
- practical_training_record.practical_training_record_pkey: `PRIMARY KEY (id)`.
- program_rule_source.program_rule_source_pkey: `PRIMARY KEY (id)`.
- program_rule_source.program_rule_source_program_version_id_school_id_fkey: `FOREIGN KEY (program_version_id, school_id) REFERENCES training_program_version(id, school_id) DEFERRABLE`.
- program_rule_source.rule_effective_period: `CHECK (((effective_to IS NULL) OR (effective_to >= effective_from)))`.
- program_rule_source.rule_verification_pair: `CHECK (((verified_by IS NULL) = (verified_at IS NULL)))`.
- readiness_decision.decision_terminal_invalidation_shape: `CHECK ((((invalidated_at IS NULL) AND (invalidated_by IS NULL) AND (invalidation_reason IS NULL) AND (invalidation_dependency_revision IS NULL) AND (invalidation_scope IS NULL) AND (invalidation_effective_at IS NULL)) OR ((decision = 'Approved'::lt_decision) AND (invalidated_at IS NOT NULL) AND (invalidated_by IS NOT NULL) AND (invalidation_reason IS NOT NULL) AND (length(TRIM(BOTH FROM invalidation_reason)) > 0) AND (invalidation_dependency_revision IS NOT NULL) AND (invalidation_dependency_revision > 0) AND (invalidated_at >= decided_at) AND (invalidation_scope IS NOT NULL) AND ((invalidation_scope = 'HistoricalReviewRequired'::lt_invalidation_scope) OR ((invalidation_scope = 'ProspectiveOnly'::lt_invalidation_scope) AND (invalidation_effective_at IS NOT NULL) AND (invalidation_effective_at >= decided_at))))))`.
- readiness_decision.decline_reason: `CHECK (((decision <> 'NotApproved'::lt_decision) OR (length(TRIM(BOTH FROM reason)) > 0)))`.
- readiness_decision.readiness_decision_evaluation_id_school_id_enrollment_id_fkey: `FOREIGN KEY (evaluation_id, school_id, enrollment_id) REFERENCES readiness_evaluation(id, school_id, enrollment_id) DEFERRABLE`.
- readiness_decision.readiness_decision_evaluation_id_school_id_readiness_id_fkey: `FOREIGN KEY (evaluation_id, school_id, readiness_id) REFERENCES readiness_evaluation(id, school_id, readiness_id) DEFERRABLE`.
- readiness_decision.readiness_decision_pkey: `PRIMARY KEY (id)`.
- readiness_evaluation.evaluation_dependency_positive: `CHECK ((dependency_revision > 0))`.
- readiness_evaluation.readiness_evaluation_pkey: `PRIMARY KEY (id)`.
- readiness_evaluation.readiness_evaluation_readiness_id_school_id_definition_ver_fkey: `FOREIGN KEY (readiness_id, school_id, definition_version_id) REFERENCES assessment_readiness(id, school_id, definition_version_id) DEFERRABLE`.
- readiness_evaluation.readiness_evaluation_readiness_id_school_id_enrollment_id_fkey: `FOREIGN KEY (readiness_id, school_id, enrollment_id) REFERENCES assessment_readiness(id, school_id, enrollment_id) DEFERRABLE`.
- readiness_evidence_basis.readiness_evidence_basis_evaluation_id_school_id_enrollmen_fkey: `FOREIGN KEY (evaluation_id, school_id, enrollment_id) REFERENCES readiness_evaluation(id, school_id, enrollment_id) DEFERRABLE`.
- readiness_evidence_basis.readiness_evidence_basis_pkey: `PRIMARY KEY (id)`.
- readiness_evidence_basis.readiness_evidence_basis_practical_record_version_id_schoo_fkey: `FOREIGN KEY (practical_record_version_id, school_id, enrollment_id) REFERENCES practical_record_version(id, school_id, enrollment_id) DEFERRABLE`.
- readiness_evidence_basis.readiness_evidence_basis_result_version_id_school_id_enrol_fkey: `FOREIGN KEY (result_version_id, school_id, enrollment_id) REFERENCES assessment_result_version(id, school_id, enrollment_id) DEFERRABLE`.
- readiness_evidence_basis.readiness_evidence_basis_theory_attendance_id_school_id_en_fkey: `FOREIGN KEY (theory_attendance_id, school_id, enrollment_id) REFERENCES theory_attendance(id, school_id, enrollment_id) DEFERRABLE`.
- readiness_evidence_basis.readiness_evidence_source_xor: `CHECK ((((((practical_record_version_id IS NOT NULL))::integer + ((theory_attendance_id IS NOT NULL))::integer) + ((result_version_id IS NOT NULL))::integer) = 1))`.
- readiness_evidence_basis.readiness_evidence_typed_shape: `CHECK (((((practical_record_version_id IS NOT NULL) OR (theory_attendance_id IS NOT NULL)) AND (lesson_id IS NOT NULL) AND (observed_minutes IS NOT NULL) AND (observed_minutes > 0)) OR ((result_version_id IS NOT NULL) AND (lesson_id IS NULL) AND (observed_minutes IS NULL))))`.
- readiness_requirement_result.observed_minutes_nonnegative: `CHECK (((observed_minutes IS NULL) OR (observed_minutes >= 0)))`.
- readiness_requirement_result.readiness_requirement_result_evaluation_id_school_id_defin_fkey: `FOREIGN KEY (evaluation_id, school_id, definition_version_id) REFERENCES readiness_evaluation(id, school_id, definition_version_id) DEFERRABLE`.
- readiness_requirement_result.readiness_requirement_result_pkey: `PRIMARY KEY (id)`.
- readiness_requirement_result.readiness_requirement_result_requirement_id_school_id_defi_fkey: `FOREIGN KEY (requirement_id, school_id, definition_version_id) REFERENCES admission_requirement(id, school_id, definition_version_id) DEFERRABLE`.
- reporting_declaration.reporting_declaration_pkey: `PRIMARY KEY (id)`.
- reporting_declaration.reporting_declaration_snapshot_id_school_id_fkey: `FOREIGN KEY (snapshot_id, school_id) REFERENCES training_evidence_snapshot(id, school_id) DEFERRABLE`.
- student_training.program_initial_assignment_pair: `CHECK ((((program_version_id IS NULL) AND (program_assigned_by IS NULL) AND (program_assigned_at IS NULL)) OR ((program_version_id IS NOT NULL) AND (program_assigned_by IS NOT NULL) AND (program_assigned_at IS NOT NULL))))`.
- student_training.student_training_pkey: `PRIMARY KEY (id)`.
- student_training.student_training_program_version_id_school_id_fkey: `FOREIGN KEY (program_version_id, school_id) REFERENCES training_program_version(id, school_id) DEFERRABLE`.
- student_training.training_dependency_positive: `CHECK ((dependency_revision > 0))`.
- theory_attendance.theory_attendance_enrollment_id_school_id_student_id_fkey: `FOREIGN KEY (enrollment_id, school_id, student_id) REFERENCES student_training(id, school_id, student_id) DEFERRABLE`.
- theory_attendance.theory_attendance_pkey: `PRIMARY KEY (id)`.
- theory_attendance.theory_attendance_record_version_id_school_id_fkey: `FOREIGN KEY (record_version_id, school_id) REFERENCES theory_record_version(id, school_id) DEFERRABLE`.
- theory_record_version.theory_confirmation_pair: `CHECK (((confirmed_by IS NULL) = (confirmed_at IS NULL)))`.
- theory_record_version.theory_confirmed_valid: `CHECK (((confirmed_at IS NULL) OR (validation = 'Valid'::lt_validation)))`.
- theory_record_version.theory_correction_reason: `CHECK (((version = 1) OR ((correction_reason IS NOT NULL) AND (length(TRIM(BOTH FROM correction_reason)) > 0))))`.
- theory_record_version.theory_positive: `CHECK (((version > 0) AND (training_minutes > 0)))`.
- theory_record_version.theory_record_version_pkey: `PRIMARY KEY (id)`.
- theory_record_version.theory_record_version_record_id_school_id_lesson_id_fkey: `FOREIGN KEY (record_id, school_id, lesson_id) REFERENCES theory_training_record(id, school_id, lesson_id) DEFERRABLE`.
- theory_record_version.theory_record_version_source_snapshot_id_school_id_lesson__fkey: `FOREIGN KEY (source_snapshot_id, school_id, lesson_id) REFERENCES lesson_source_snapshot(id, school_id, lesson_id) DEFERRABLE`.
- theory_training_record.theory_revision_positive: `CHECK ((revision > 0))`.
- theory_training_record.theory_training_record_current_version_id_school_id_id_fkey: `FOREIGN KEY (current_version_id, school_id, id) REFERENCES theory_record_version(id, school_id, record_id) DEFERRABLE`.
- theory_training_record.theory_training_record_pkey: `PRIMARY KEY (id)`.
- training_evidence_check.evidence_check_codes_nonblank: `CHECK (((length(TRIM(BOTH FROM check_code)) > 0) AND (length(TRIM(BOTH FROM field_code)) > 0)))`.
- training_evidence_check.evidence_check_explanation_nonblank: `CHECK ((length(TRIM(BOTH FROM explanation)) > 0))`.
- training_evidence_check.evidence_check_scope_shape: `CHECK ((((check_scope = 'Snapshot'::lt_check_scope) AND (evidence_item_id IS NULL)) OR ((check_scope = 'EvidenceItem'::lt_check_scope) AND (evidence_item_id IS NOT NULL))))`.
- training_evidence_check.training_evidence_check_evidence_item_id_school_id_snapsho_fkey: `FOREIGN KEY (evidence_item_id, school_id, snapshot_id) REFERENCES training_evidence_item(id, school_id, snapshot_id) DEFERRABLE`.
- training_evidence_check.training_evidence_check_pkey: `PRIMARY KEY (id)`.
- training_evidence_check.training_evidence_check_snapshot_id_school_id_enrollment_i_fkey: `FOREIGN KEY (snapshot_id, school_id, enrollment_id) REFERENCES training_evidence_snapshot(id, school_id, enrollment_id) DEFERRABLE`.
- training_evidence_item.evidence_item_lesson_shape: `CHECK (((((practical_record_version_id IS NOT NULL) OR (theory_attendance_id IS NOT NULL)) AND (lesson_id IS NOT NULL) AND (credited_minutes_at_snapshot IS NOT NULL)) OR ((practical_record_version_id IS NULL) AND (theory_attendance_id IS NULL) AND (lesson_id IS NULL) AND (credited_minutes_at_snapshot IS NULL))))`.
- training_evidence_item.evidence_item_minutes_nonnegative: `CHECK (((credited_minutes_at_snapshot IS NULL) OR (credited_minutes_at_snapshot >= 0)))`.
- training_evidence_item.evidence_item_one_source: `CHECK (((((((practical_record_version_id IS NOT NULL))::integer + ((theory_attendance_id IS NOT NULL))::integer) + ((result_version_id IS NOT NULL))::integer) + ((readiness_decision_id IS NOT NULL))::integer) = 1))`.
- training_evidence_item.evidence_response_shape: `CHECK (((record_response_sequence IS NULL) OR ((practical_record_version_id IS NOT NULL) AND (record_response_sequence >= 0))))`.
- training_evidence_item.training_evidence_item_pkey: `PRIMARY KEY (id)`.
- training_evidence_item.training_evidence_item_practical_record_version_id_school__fkey: `FOREIGN KEY (practical_record_version_id, school_id, enrollment_id) REFERENCES practical_record_version(id, school_id, enrollment_id) DEFERRABLE`.
- training_evidence_item.training_evidence_item_readiness_decision_id_school_id_enr_fkey: `FOREIGN KEY (readiness_decision_id, school_id, enrollment_id) REFERENCES readiness_decision(id, school_id, enrollment_id) DEFERRABLE`.
- training_evidence_item.training_evidence_item_result_version_id_school_id_enrollm_fkey: `FOREIGN KEY (result_version_id, school_id, enrollment_id) REFERENCES assessment_result_version(id, school_id, enrollment_id) DEFERRABLE`.
- training_evidence_item.training_evidence_item_snapshot_id_school_id_enrollment_id_fkey: `FOREIGN KEY (snapshot_id, school_id, enrollment_id) REFERENCES training_evidence_snapshot(id, school_id, enrollment_id) DEFERRABLE`.
- training_evidence_item.training_evidence_item_theory_attendance_id_school_id_enro_fkey: `FOREIGN KEY (theory_attendance_id, school_id, enrollment_id) REFERENCES theory_attendance(id, school_id, enrollment_id) DEFERRABLE`.
- training_evidence_snapshot.evidence_dependency_positive: `CHECK ((dependency_revision > 0))`.
- training_evidence_snapshot.ready_evidence_basis: `CHECK (((status <> 'Ready'::lt_evidence_status) OR ((checklist_version_id IS NOT NULL) AND (source_verified_at IS NOT NULL))))`.
- training_evidence_snapshot.training_evidence_snapshot_enrollment_id_school_id_program_fkey: `FOREIGN KEY (enrollment_id, school_id, program_version_id) REFERENCES student_training(id, school_id, program_version_id) DEFERRABLE`.
- training_evidence_snapshot.training_evidence_snapshot_pkey: `PRIMARY KEY (id)`.
- training_program.program_revision_positive: `CHECK ((revision > 0))`.
- training_program.training_program_pkey: `PRIMARY KEY (id)`.
- training_program_version.program_conversion_positive: `CHECK (((theory_minutes_per_unit > 0) AND (practical_minutes_per_unit > 0)))`.
- training_program_version.program_effective_period: `CHECK (((effective_to IS NULL) OR (effective_to >= effective_from)))`.
- training_program_version.program_minutes_nonnegative: `CHECK (((required_theory_minutes >= 0) AND (required_practical_minutes >= 0)))`.
- training_program_version.program_publication_shape: `CHECK ((((status = 'Draft'::lt_program_status) AND (published_at IS NULL) AND (published_by IS NULL) AND (retired_at IS NULL)) OR ((status = 'Published'::lt_program_status) AND (published_at IS NOT NULL) AND (published_by IS NOT NULL) AND (retired_at IS NULL) AND legal_basis_verified) OR ((status = 'Retired'::lt_program_status) AND (published_at IS NOT NULL) AND (published_by IS NOT NULL) AND (retired_at IS NOT NULL) AND (retired_at >= published_at) AND legal_basis_verified)))`.
- training_program_version.program_version_positive: `CHECK ((version > 0))`.
- training_program_version.published_checklist: `CHECK (((status = 'Draft'::lt_program_status) OR (journal_checklist_version_id IS NOT NULL)))`.
- training_program_version.training_program_version_pkey: `PRIMARY KEY (id)`.
- training_program_version.training_program_version_program_id_school_id_fkey: `FOREIGN KEY (program_id, school_id) REFERENCES training_program(id, school_id) DEFERRABLE`.
- training_topic.training_topic_pkey: `PRIMARY KEY (id)`.
- training_topic.training_topic_program_version_id_school_id_fkey: `FOREIGN KEY (program_version_id, school_id) REFERENCES training_program_version(id, school_id) DEFERRABLE`.
