# Learning Tracking — Indexes and database rules

| Feature | Necessary? | Business/technical reason |
| --- | --- | --- |
| Indexes | Yes, existing | PK/UNIQUE candidate-key enforcement and actual scoped/temporal source lookups. No duplicate PK/UNIQUE indexes added. |
| Views | No new view | No approved repeated read/support/report query requires one in this database package. A view would not secure raw table access. |
| Triggers | Context dependent | Retain only existing cross-row, immutable/version/lifecycle guards. New RLS/grants do not duplicate transition logic. |
| Functions/procedures | Existing technical functions only | Trigger helpers / Auth refresh / Document activation where already designed. No solver/progress or ordinary service workflow moved into SQL. |
| Personal data masking | Synthetic demo + restricted access | No real records exported. Service-required raw data cannot be meaningfully masked for runtime. |

## Query/index inventory

- training_program: PK(id).
- training_program: UNIQUE(id,school_id).
- training_program: UNIQUE(id,school_id,category_code).
- training_program_version: PK(id).
- training_program_version: UNIQUE(id,school_id).
- training_program_version: UNIQUE(program_id,version,school_id).
- training_program_version: UNIQUE(id,school_id,program_id).
- program_rule_source: PK(id).
- program_rule_source: UNIQUE(id,school_id).
- training_topic: PK(id).
- training_topic: UNIQUE(id,school_id).
- training_topic: UNIQUE(program_version_id,topic_key,school_id).
- training_topic: UNIQUE(id,school_id,program_version_id).
- assessment_definition: PK(id).
- assessment_definition: UNIQUE(id,school_id).
- assessment_definition: UNIQUE(program_id,code,school_id).
- assessment_definition: UNIQUE(id,school_id,program_id).
- assessment_definition_version: PK(id).
- assessment_definition_version: UNIQUE(id,school_id).
- assessment_definition_version: UNIQUE(definition_id,program_version_id,school_id).
- assessment_definition_version: UNIQUE(id,school_id,program_version_id).
- assessment_definition_version: UNIQUE(id,school_id,definition_id).
- assessment_topic: PK(id).
- assessment_topic: UNIQUE(id,school_id).
- assessment_topic: UNIQUE(definition_version_id,topic_id,school_id).
- assessment_topic: UNIQUE(id,school_id,definition_version_id).
- admission_requirement: PK(id).
- admission_requirement: UNIQUE(id,school_id).
- admission_requirement: UNIQUE(definition_version_id,code,school_id).
- admission_requirement: UNIQUE(id,school_id,definition_version_id).
- student_training: PK(id).
- student_training: UNIQUE(id,school_id).
- student_training: UNIQUE(id,school_id,category_code).
- student_training: UNIQUE(id,school_id,student_id).
- student_training: UNIQUE(id,school_id,program_version_id).
- lesson_source_snapshot: PK(id).
- lesson_source_snapshot: UNIQUE(id,school_id).
- lesson_source_snapshot: UNIQUE(lesson_id,lesson_revision,school_id).
- lesson_source_snapshot: UNIQUE(id,school_id,lesson_id).
- lesson_source_state: PK(id).
- lesson_source_state: UNIQUE(id,school_id).
- lesson_source_state: UNIQUE(lesson_id,school_id).
- practical_training_record: PK(id).
- practical_training_record: UNIQUE(id,school_id).
- practical_training_record: UNIQUE(lesson_id,enrollment_id,school_id).
- practical_training_record: UNIQUE(id,school_id,enrollment_id,lesson_id).
- practical_training_record: INDEX(school_id,enrollment_id).
- practical_record_version: PK(id).
- practical_record_version: UNIQUE(id,school_id).
- practical_record_version: UNIQUE(record_id,version,school_id).
- practical_record_version: UNIQUE(id,school_id,record_id).
- practical_record_version: UNIQUE(id,school_id,program_version_id).
- practical_record_version: UNIQUE(id,school_id,enrollment_id).
- practical_record_topic: PK(id).
- practical_record_topic: UNIQUE(id,school_id).
- practical_record_topic: UNIQUE(record_version_id,topic_id,school_id).
- practical_record_response: PK(id).
- practical_record_response: UNIQUE(id,school_id).
- practical_record_response: UNIQUE(record_id,sequence,school_id).
- practical_record_response: UNIQUE(command_id,school_id).
- practical_record_response: UNIQUE(id,school_id,record_version_id).
- practical_record_response: INDEX(record_version_id,actor_role,response).
- theory_training_record: PK(id).
- theory_training_record: UNIQUE(id,school_id).
- theory_training_record: UNIQUE(lesson_id,school_id).
- theory_training_record: UNIQUE(id,school_id,lesson_id).
- theory_record_version: PK(id).
- theory_record_version: UNIQUE(id,school_id).
- theory_record_version: UNIQUE(record_id,version,school_id).
- theory_record_version: UNIQUE(id,school_id,record_id).
- theory_record_version: UNIQUE(id,school_id,lesson_id).
- theory_attendance: PK(id).
- theory_attendance: UNIQUE(id,school_id).
- theory_attendance: UNIQUE(id,school_id,enrollment_id).
- theory_attendance: UNIQUE(record_version_id,enrollment_id,school_id).
- theory_attendance: INDEX(school_id,enrollment_id,record_version_id).
- assessment_readiness: PK(id).
- assessment_readiness: UNIQUE(id,school_id).
- assessment_readiness: UNIQUE(enrollment_id,program_version_id,definition_version_id,school_id).
- assessment_readiness: UNIQUE(id,school_id,enrollment_id).
- assessment_readiness: UNIQUE(id,school_id,definition_version_id).
- assessment_readiness: UNIQUE(id,school_id,enrollment_id,definition_version_id).
- readiness_evaluation: PK(id).
- readiness_evaluation: UNIQUE(id,school_id).
- readiness_evaluation: UNIQUE(id,school_id,readiness_id).
- readiness_evaluation: UNIQUE(id,school_id,enrollment_id).
- readiness_evaluation: UNIQUE(id,school_id,definition_version_id).
- readiness_requirement_result: PK(id).
- readiness_requirement_result: UNIQUE(id,school_id).
- readiness_requirement_result: UNIQUE(evaluation_id,requirement_id,school_id).
- readiness_evidence_basis: PK(id).
- readiness_evidence_basis: UNIQUE(id,school_id).
- readiness_evidence_basis: UNIQUE(evaluation_id,lesson_id,school_id).
- readiness_evidence_basis: UNIQUE(evaluation_id,result_version_id,school_id).
- readiness_evidence_basis: INDEX(school_id,enrollment_id,evaluation_id).
- readiness_decision: PK(id).
- readiness_decision: UNIQUE(id,school_id).
- readiness_decision: UNIQUE(command_id,school_id).
- readiness_decision: UNIQUE(id,school_id,readiness_id).
- readiness_decision: UNIQUE(id,school_id,enrollment_id).
- assessment: PK(id).
- assessment: UNIQUE(id,school_id).
- assessment: UNIQUE(enrollment_id,definition_version_id,attempt_number,school_id).
- assessment: UNIQUE(id,school_id,enrollment_id).
- assessment: UNIQUE(id,school_id,definition_version_id).
- assessment: UNIQUE(id,school_id,enrollment_id,definition_version_id).
- assessment_result_version: PK(id).
- assessment_result_version: UNIQUE(id,school_id).
- assessment_result_version: UNIQUE(assessment_id,version,school_id).
- assessment_result_version: UNIQUE(command_id,school_id).
- assessment_result_version: UNIQUE(id,school_id,assessment_id).
- assessment_result_version: UNIQUE(id,school_id,enrollment_id).
- assessment_result_version: UNIQUE(id,school_id,definition_version_id).
- assessment_topic_result: PK(id).
- assessment_topic_result: UNIQUE(id,school_id).
- assessment_topic_result: UNIQUE(result_version_id,assessment_topic_id,school_id).
- training_evidence_snapshot: PK(id).
- training_evidence_snapshot: UNIQUE(id,school_id).
- training_evidence_snapshot: UNIQUE(id,school_id,enrollment_id).
- training_evidence_item: PK(id).
- training_evidence_item: UNIQUE(id,school_id).
- training_evidence_item: UNIQUE(id,school_id,snapshot_id).
- training_evidence_item: UNIQUE(snapshot_id,lesson_id,school_id).
- training_evidence_check: PK(id).
- training_evidence_check: UNIQUE(id,school_id).
- training_evidence_check: INDEX(snapshot_id,school_id,enrollment_id).
- training_evidence_check: INDEX(evidence_item_id,school_id,snapshot_id).
- reporting_declaration: PK(id).
- reporting_declaration: UNIQUE(id,school_id).
- reporting_declaration: UNIQUE(command_id,school_id).
- learning_audit_event: PK(id).
- learning_audit_event: UNIQUE(id,school_id).

One new technical trigger/function lt_terminal_invalidation_guard in security/database-roles.sql enforces the adopted one-time terminal decision invalidation. Positive runtime invalidation and rejected second/cleared transitions are natively tested. This justified exception to the existing-helper-only default does not move ordinary learning business logic into SQL.

Supplement: `D:\Diplom\docs\diploma\database\contexts\learning-tracking\migrations\002-null-safe-evidence.sql`.

## Measurement boundaries

EXPLAIN JSON for a representative local query is stored in native evidence. Tiny fixtures may correctly choose sequential scan. No speedup/throughput claim or speculative extra index is made. Any future index needs a real predicate/cardinality/workload measurement.

Reference data: Not Applicable as a global fixed-table seed for this context. Existing enum/status domains are installed by DDL; school-owned templates/programmes/rules are business configuration, not invented global lookup rows. Demo configurations are explicitly synthetic and must not be promoted to legal/category authority.
