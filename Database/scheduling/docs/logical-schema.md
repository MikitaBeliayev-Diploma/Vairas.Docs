> Baseline design reference. The [2026-11-24 implementation extension](implementation.md) records nine added columns, six reliability tables and current deployment/verification boundaries. The current combined schema is [DBML](../schema/schema.dbml).

# Scheduling — Logical relational schema

Authority: Owner-adopted D-044; scheduling-refined is NOT silently adopted. [Canonical DBML](../schema/schema.dbml).

The [Mermaid diagram](../schema/database-erd.md) shows keys/FKs and representative attributes; full attributes/defaults/classification are in data-dictionary.md.

Physical count: 17 domain tables, 175 columns, 25 local FK declarations. EF migration history, where present, is technical metadata, not a new aggregate.

## Relationships and optionality

| Parent key | Child FK | Required? | Cardinality / integrity |
|---|---|---|---|
| scheduling_rule_version(id) | scheduling_request_rule(rule_version_id) | Yes | 0..N children per parent; default NO ACTION |
| candidate_lesson(id) | candidate_lesson_participant(candidate_lesson_id) | Yes | 0..N children per parent; default NO ACTION |
| lesson(id) | lesson_participant(lesson_id) | Yes | 0..N children per parent; default NO ACTION |
| scheduling_request(id,revision) | scheduling_request_enrollment(request_id,request_revision) | Yes | 0..N children per parent; default NO ACTION |
| scheduling_request(id,revision) | scheduling_request_group(request_id,request_revision) | Yes | 0..N children per parent; default NO ACTION |
| scheduling_request(id,revision) | scheduling_request_resource(request_id,request_revision) | Yes | 0..N children per parent; default NO ACTION |
| scheduling_request(id,revision) | scheduling_request_window(request_id,request_revision) | Yes | 0..N children per parent; default NO ACTION |
| scheduling_request(id,revision) | scheduling_request_rule(request_id,request_revision) | Yes | 0..N children per parent; default NO ACTION |
| scheduling_request(id,revision) | candidate_lesson(request_id,request_revision) | Yes | 0..N children per parent; default NO ACTION |
| recurring_lesson_series(id,school_id,kind) | lesson(series_id,school_id,kind) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| scheduling_request(id,revision,school_id) | scheduling_operation(request_id,request_revision,school_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| scheduling_operation(id,school_id) | scheduling_request(confirmed_operation_id,school_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| scheduling_operation(id,school_id) | reservation_claim(operation_id,school_id) | Yes | 0..N children per parent; default NO ACTION |
| lesson(id,school_id) | reservation_claim(lesson_id,school_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| lesson(id,school_id) | lesson_change(lesson_id,school_id) | Yes | 0..N children per parent; default NO ACTION |
| scheduling_operation(id,school_id) | lesson_change(operation_id,school_id) | Yes | 0..N children per parent; default NO ACTION |
| candidate_lesson(id) | lesson(source_candidate_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..1 child per parent; default NO ACTION |
| recurring_lesson_series(id) | candidate_lesson(series_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| assessment_appointment(id,school_id) | reservation_claim(assessment_appointment_id,school_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| lesson(id,school_id) | scheduling_operation(target_lesson_id,school_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| lesson(id,school_id) | scheduling_operation(result_lesson_id,school_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| assessment_appointment(id,school_id) | scheduling_operation(target_appointment_id,school_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| assessment_appointment(id,school_id) | scheduling_operation(result_appointment_id,school_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| scheduling_operation(id) | scheduling_operation_rule(operation_id) | Yes | 0..N children per parent; default NO ACTION |
| scheduling_rule_version(id) | scheduling_operation_rule(rule_version_id) | Yes | 0..N children per parent; default NO ACTION |

## Deployment/transaction source

[Install wrapper](../ddl/install.sql) is the only fresh-install entry. It references existing canonical SQL or the generated initial migration, not another service’s same-named schema.sql. [Security overlay](../security/database-roles.sql) follows schema creation; demo seeds run only under explicit test gates.

No previous production migration history was found/assumed. Reapplying raw initial DDL over a populated database is forbidden. Scheduling has a real EF migration/snapshot and no-op migration rerun check; other contexts use a fresh SQL baseline and require a separately reviewed differential upgrade if legacy data exists.

Current remote owner/API gaps do not by themselves invalidate relational design. They remain runtime/integration gates and cannot be proven by FK tests.

## Executable database rules beyond DBML

- __EFMigrationsHistory.PK___EFMigrationsHistory: `PRIMARY KEY ("MigrationId")`.
- assessment_appointment.AK_assessment_appointment_id_school_id: `UNIQUE (id, school_id)`.
- assessment_appointment.PK_assessment_appointment: `PRIMARY KEY (id)`.
- assessment_appointment.assessment_interval: `CHECK ((ends_at > starts_at))`.
- assessment_appointment.assessment_type: `CHECK ((((kind = 'Practical'::lesson_kind) AND (vehicle_id IS NOT NULL)) OR ((kind = 'Theory'::lesson_kind) AND (vehicle_id IS NULL))))`.
- candidate_lesson.AK_candidate_lesson_id_request_id_request_revision: `UNIQUE (id, request_id, request_revision)`.
- candidate_lesson.FK_candidate_lesson_recurring_lesson_series_series_id: `FOREIGN KEY (series_id) REFERENCES recurring_lesson_series(id) ON DELETE RESTRICT`.
- candidate_lesson.FK_candidate_lesson_scheduling_request_request_id_request_revi~: `FOREIGN KEY (request_id, request_revision) REFERENCES scheduling_request(id, revision) ON DELETE RESTRICT`.
- candidate_lesson.PK_candidate_lesson: `PRIMARY KEY (id)`.
- candidate_lesson.candidate_interval: `CHECK ((ends_at > starts_at))`.
- candidate_lesson.candidate_type: `CHECK ((((kind = 'Practical'::lesson_kind) AND (enrollment_id IS NOT NULL) AND (student_id IS NOT NULL) AND (vehicle_id IS NOT NULL) AND (group_id IS NULL)) OR ((kind = 'Theory'::lesson_kind) AND (group_id IS NOT NULL) AND (enrollment_id IS NULL) AND (student_id IS NULL) AND (vehicle_id IS NULL))))`.
- candidate_lesson_participant.FK_candidate_lesson_participant_candidate_lesson_candidate_les~: `FOREIGN KEY (candidate_lesson_id) REFERENCES candidate_lesson(id) ON DELETE RESTRICT`.
- candidate_lesson_participant.PK_candidate_lesson_participant: `PRIMARY KEY (candidate_lesson_id, enrollment_id)`.
- candidate_lesson_participant.candidate_lesson_participant_membership_revision: `CHECK ((membership_revision > 0))`.
- lesson.AK_lesson_id_school_id: `UNIQUE (id, school_id)`.
- lesson.FK_lesson_candidate_lesson_source_candidate_id: `FOREIGN KEY (source_candidate_id) REFERENCES candidate_lesson(id) ON DELETE RESTRICT`.
- lesson.FK_lesson_recurring_lesson_series_series_id_school_id_kind: `FOREIGN KEY (series_id, school_id, kind) REFERENCES recurring_lesson_series(id, school_id, kind) ON DELETE RESTRICT`.
- lesson.PK_lesson: `PRIMARY KEY (id)`.
- lesson.lesson_interval: `CHECK ((ends_at > starts_at))`.
- lesson.lesson_membership_basis: `CHECK ((((kind = 'Practical'::lesson_kind) AND (group_membership_revision IS NULL)) OR ((kind = 'Theory'::lesson_kind) AND (group_membership_revision IS NOT NULL) AND (group_membership_revision > 0))))`.
- lesson.lesson_revision_positive: `CHECK ((revision > 0))`.
- lesson.lesson_type: `CHECK ((((kind = 'Practical'::lesson_kind) AND (enrollment_id IS NOT NULL) AND (student_id IS NOT NULL) AND (vehicle_id IS NOT NULL) AND (group_id IS NULL)) OR ((kind = 'Theory'::lesson_kind) AND (group_id IS NOT NULL) AND (enrollment_id IS NULL) AND (student_id IS NULL) AND (vehicle_id IS NULL))))`.
- lesson_change.FK_lesson_change_lesson_lesson_id_school_id: `FOREIGN KEY (lesson_id, school_id) REFERENCES lesson(id, school_id) ON DELETE RESTRICT`.
- lesson_change.FK_lesson_change_scheduling_operation_operation_id_school_id: `FOREIGN KEY (operation_id, school_id) REFERENCES scheduling_operation(id, school_id) ON DELETE RESTRICT`.
- lesson_change.PK_lesson_change: `PRIMARY KEY (id)`.
- lesson_change.history_previous_interval: `CHECK ((previous_end > previous_start))`.
- lesson_change.history_revision_positive: `CHECK ((revision > 1))`.
- lesson_participant.FK_lesson_participant_lesson_lesson_id: `FOREIGN KEY (lesson_id) REFERENCES lesson(id) ON DELETE RESTRICT`.
- lesson_participant.PK_lesson_participant: `PRIMARY KEY (lesson_id, enrollment_id)`.
- lesson_participant.lesson_participant_membership_revision: `CHECK ((membership_revision > 0))`.
- recurring_lesson_series.AK_recurring_lesson_series_id_school_id_kind: `UNIQUE (id, school_id, kind)`.
- recurring_lesson_series.PK_recurring_lesson_series: `PRIMARY KEY (id)`.
- recurring_lesson_series.recurrence_count: `CHECK (((occurrence_count IS NULL) OR (occurrence_count > 0)))`.
- recurring_lesson_series.recurrence_end_choice: `CHECK (((((ends_on IS NOT NULL))::integer + ((occurrence_count IS NOT NULL))::integer) = 1))`.
- recurring_lesson_series.recurrence_end_range: `CHECK (((ends_on IS NULL) OR (ends_on >= starts_on)))`.
- recurring_lesson_series.recurrence_positive: `CHECK (((recurrence_interval > 0) AND (duration_minutes > 0)))`.
- recurring_lesson_series.recurrence_weekdays: `CHECK ((((frequency = 'Daily'::recurrence_frequency) AND (COALESCE(cardinality(weekdays), 0) = 0)) OR ((frequency = 'Weekly'::recurrence_frequency) AND (weekdays IS NOT NULL) AND ((cardinality(weekdays) >= 1) AND (cardinality(weekdays) <= 7)) AND (weekdays <@ ARRAY[(1)::smallint, (2)::smallint, (3)::smallint, (4)::smallint, (5)::smallint, (6)::smallint, (7)::smallint]))))`.
- reservation_claim.FK_reservation_claim_assessment_appointment_assessment_appoint~: `FOREIGN KEY (assessment_appointment_id, school_id) REFERENCES assessment_appointment(id, school_id) ON DELETE RESTRICT`.
- reservation_claim.FK_reservation_claim_lesson_lesson_id_school_id: `FOREIGN KEY (lesson_id, school_id) REFERENCES lesson(id, school_id) ON DELETE RESTRICT`.
- reservation_claim.FK_reservation_claim_scheduling_operation_operation_id_school_~: `FOREIGN KEY (operation_id, school_id) REFERENCES scheduling_operation(id, school_id) ON DELETE RESTRICT`.
- reservation_claim.PK_reservation_claim: `PRIMARY KEY (id)`.
- reservation_claim.active_resource_no_overlap: `EXCLUDE USING gist (resource_kind WITH =, resource_key WITH =, tstzrange(starts_at, ends_at, '[)'::text) WITH &&) WHERE ((status = 'Active'::reservation_status))`.
- reservation_claim.claim_interval: `CHECK ((ends_at > starts_at))`.
- reservation_claim.claim_kind: `CHECK (((resource_kind)::text = ANY ((ARRAY['Student'::character varying, 'Instructor'::character varying, 'Vehicle'::character varying, 'Group'::character varying])::text[])))`.
- reservation_claim.claim_owner: `CHECK (((((lesson_id IS NOT NULL))::integer + ((assessment_appointment_id IS NOT NULL))::integer) = 1))`.
- reservation_claim.claim_release: `CHECK ((((status = 'Active'::reservation_status) AND (released_at IS NULL)) OR ((status = 'Released'::reservation_status) AND (released_at IS NOT NULL) AND (released_at >= created_at))))`.
- scheduling_operation.AK_scheduling_operation_id_school_id: `UNIQUE (id, school_id)`.
- scheduling_operation.FK_scheduling_operation_assessment_appointment_result_appointm~: `FOREIGN KEY (result_appointment_id, school_id) REFERENCES assessment_appointment(id, school_id) ON DELETE RESTRICT`.
- scheduling_operation.FK_scheduling_operation_assessment_appointment_target_appointm~: `FOREIGN KEY (target_appointment_id, school_id) REFERENCES assessment_appointment(id, school_id) ON DELETE RESTRICT`.
- scheduling_operation.FK_scheduling_operation_lesson_result_lesson_id_school_id: `FOREIGN KEY (result_lesson_id, school_id) REFERENCES lesson(id, school_id) ON DELETE RESTRICT`.
- scheduling_operation.FK_scheduling_operation_lesson_target_lesson_id_school_id: `FOREIGN KEY (target_lesson_id, school_id) REFERENCES lesson(id, school_id) ON DELETE RESTRICT`.
- scheduling_operation.FK_scheduling_operation_scheduling_request_request_id_request_~: `FOREIGN KEY (request_id, request_revision, school_id) REFERENCES scheduling_request(id, revision, school_id) ON DELETE RESTRICT`.
- scheduling_operation.PK_scheduling_operation: `PRIMARY KEY (id)`.
- scheduling_operation.operation_action: `CHECK (((action_type)::text = ANY ((ARRAY['ConfirmSchedule'::character varying, 'CreateLesson'::character varying, 'Reschedule'::character varying, 'Cancel'::character varying, 'ChangeGroup'::character varying, 'CompleteLesson'::character varying, 'CreateAssessment'::character varying, 'CancelAssessment'::character varying])::text[])))`.
- scheduling_operation.operation_channel: `CHECK (((channel)::text = ANY ((ARRAY['Web'::character varying, 'MCP'::character varying, 'Internal'::character varying])::text[])))`.
- scheduling_operation.operation_expected_revision: `CHECK (((expected_lesson_revision IS NULL) OR (expected_lesson_revision > 0)))`.
- scheduling_operation.operation_finished: `CHECK ((((status = 'Pending'::operation_status) AND (finished_at IS NULL)) OR (status = 'ReconciliationPending'::operation_status) OR ((status = ANY (ARRAY['Committed'::operation_status, 'Rejected'::operation_status])) AND (finished_at IS NOT NULL))))`.
- scheduling_operation.operation_request_pair: `CHECK (((request_id IS NULL) = (request_revision IS NULL)))`.
- scheduling_operation.operation_target_xor: `CHECK (((target_lesson_id IS NULL) OR (target_appointment_id IS NULL)))`.
- scheduling_operation_rule.FK_scheduling_operation_rule_scheduling_operation_operation_id: `FOREIGN KEY (operation_id) REFERENCES scheduling_operation(id) ON DELETE RESTRICT`.
- scheduling_operation_rule.FK_scheduling_operation_rule_scheduling_rule_version_rule_vers~: `FOREIGN KEY (rule_version_id) REFERENCES scheduling_rule_version(id) ON DELETE RESTRICT`.
- scheduling_operation_rule.PK_scheduling_operation_rule: `PRIMARY KEY (operation_id, rule_version_id)`.
- scheduling_request.AK_scheduling_request_id_revision_school_id: `UNIQUE (id, revision, school_id)`.
- scheduling_request.FK_scheduling_request_scheduling_operation_confirmed_operation~: `FOREIGN KEY (confirmed_operation_id, school_id) REFERENCES scheduling_operation(id, school_id) ON DELETE RESTRICT`.
- scheduling_request.PK_scheduling_request: `PRIMARY KEY (id, revision)`.
- scheduling_request.request_confirmed_metadata: `CHECK ((((status = 'Confirmed'::request_status) AND (confirmed_at IS NOT NULL) AND (confirmed_operation_id IS NOT NULL)) OR ((status <> 'Confirmed'::request_status) AND (confirmed_at IS NULL) AND (confirmed_operation_id IS NULL))))`.
- scheduling_request.request_period: `CHECK (((planning_start IS NULL) OR (planning_end IS NULL) OR (planning_end >= planning_start)))`.
- scheduling_request.request_ready_metadata: `CHECK (((status <> ALL (ARRAY['Ready'::request_status, 'Confirmed'::request_status])) OR (generated_at IS NOT NULL)))`.
- scheduling_request.request_revision_positive: `CHECK ((revision > 0))`.
- scheduling_request.request_single_school: `EXCLUDE USING gist (id WITH =, school_id WITH <>)`.
- scheduling_request.request_submitted_pair: `CHECK (((submitted_at IS NULL) = (submitted_by_user_id IS NULL)))`.
- scheduling_request.request_validated_metadata: `CHECK (((status <> ALL (ARRAY['Submitted'::request_status, 'Ready'::request_status, 'Infeasible'::request_status, 'Stale'::request_status, 'Superseded'::request_status, 'Confirmed'::request_status])) OR ((submitted_at IS NOT NULL) AND (planning_start IS NOT NULL) AND (planning_end IS NOT NULL))))`.
- scheduling_request_enrollment.FK_scheduling_request_enrollment_scheduling_request_request_id~: `FOREIGN KEY (request_id, request_revision) REFERENCES scheduling_request(id, revision) ON DELETE RESTRICT`.
- scheduling_request_enrollment.PK_scheduling_request_enrollment: `PRIMARY KEY (request_id, request_revision, enrollment_id)`.
- scheduling_request_enrollment.scheduling_request_enrollment_revision: `CHECK ((request_revision > 0))`.
- scheduling_request_group.FK_scheduling_request_group_scheduling_request_request_id_requ~: `FOREIGN KEY (request_id, request_revision) REFERENCES scheduling_request(id, revision) ON DELETE RESTRICT`.
- scheduling_request_group.PK_scheduling_request_group: `PRIMARY KEY (request_id, request_revision, group_id)`.
- scheduling_request_group.scheduling_request_group_revision: `CHECK ((request_revision > 0))`.
- scheduling_request_resource.FK_scheduling_request_resource_scheduling_request_request_id_r~: `FOREIGN KEY (request_id, request_revision) REFERENCES scheduling_request(id, revision) ON DELETE RESTRICT`.
- scheduling_request_resource.PK_scheduling_request_resource: `PRIMARY KEY (request_id, request_revision, resource_kind, resource_id)`.
- scheduling_request_resource.resource_kind_valid: `CHECK (((resource_kind)::text = ANY ((ARRAY['Instructor'::character varying, 'Vehicle'::character varying, 'Branch'::character varying])::text[])))`.
- scheduling_request_resource.resource_source_revision: `CHECK (((eligibility_revision IS NULL) OR (eligibility_revision > 0)))`.
- scheduling_request_resource.scheduling_request_resource_revision: `CHECK ((request_revision > 0))`.
- scheduling_request_rule.FK_scheduling_request_rule_scheduling_request_request_id_reque~: `FOREIGN KEY (request_id, request_revision) REFERENCES scheduling_request(id, revision) ON DELETE RESTRICT`.
- scheduling_request_rule.FK_scheduling_request_rule_scheduling_rule_version_rule_versio~: `FOREIGN KEY (rule_version_id) REFERENCES scheduling_rule_version(id) ON DELETE RESTRICT`.
- scheduling_request_rule.PK_scheduling_request_rule: `PRIMARY KEY (request_id, request_revision, rule_version_id)`.
- scheduling_request_rule.scheduling_request_rule_revision: `CHECK ((request_revision > 0))`.
- scheduling_request_window.FK_scheduling_request_window_scheduling_request_request_id_req~: `FOREIGN KEY (request_id, request_revision) REFERENCES scheduling_request(id, revision) ON DELETE RESTRICT`.
- scheduling_request_window.PK_scheduling_request_window: `PRIMARY KEY (id)`.
- scheduling_request_window.window_interval: `CHECK ((ends_at > starts_at))`.
- scheduling_rule_version.PK_scheduling_rule_version: `PRIMARY KEY (id)`.
- scheduling_rule_version.rule_decision_actor: `CHECK (((((verification_status)::text = 'Pending'::text) AND (decided_at IS NULL) AND (decided_by_user_id IS NULL)) OR (((verification_status)::text = ANY ((ARRAY['Verified'::character varying, 'Rejected'::character varying])::text[])) AND (decided_at IS NOT NULL) AND (decided_by_user_id IS NOT NULL))))`.
- scheduling_rule_version.rule_effective_interval: `CHECK (((effective_to IS NULL) OR (effective_to > effective_from)))`.
- scheduling_rule_version.rule_override_policy: `CHECK ((((override_policy)::text = ANY ((ARRAY['Locked'::character varying, 'SchoolEditable'::character varying])::text[])) AND ((((source_kind)::text = 'Legal'::text) AND ((override_policy)::text = 'Locked'::text)) OR (((source_kind)::text = 'School'::text) AND ((override_policy)::text = 'SchoolEditable'::text)))))`.
- scheduling_rule_version.rule_revision: `CHECK ((revision > 0))`.
- scheduling_rule_version.rule_school_scope: `CHECK (((((source_kind)::text = 'Legal'::text) AND (school_id IS NULL)) OR (((source_kind)::text = 'School'::text) AND (school_id IS NOT NULL))))`.
- scheduling_rule_version.rule_scope: `CHECK ((((scope_kind)::text = ANY ((ARRAY['School'::character varying, 'Instructor'::character varying, 'Vehicle'::character varying, 'Branch'::character varying, 'Group'::character varying, 'Student'::character varying])::text[])) AND ((((scope_kind)::text = 'School'::text) AND (scope_resource_id IS NULL)) OR (((scope_kind)::text <> 'School'::text) AND (scope_resource_id IS NOT NULL)))))`.
- scheduling_rule_version.rule_severity: `CHECK ((((severity)::text = ANY ((ARRAY['Hard'::character varying, 'Preference'::character varying])::text[])) AND (((source_kind)::text <> 'Legal'::text) OR ((severity)::text = 'Hard'::text))))`.
- scheduling_rule_version.rule_source_kind: `CHECK (((source_kind)::text = ANY ((ARRAY['Legal'::character varying, 'School'::character varying])::text[])))`.
- scheduling_rule_version.rule_typed_limit: `CHECK ((((numeric_limit IS NULL) AND (unit IS NULL)) OR ((numeric_limit > (0)::numeric) AND (unit IS NOT NULL))))`.
- scheduling_rule_version.rule_verification: `CHECK (((verification_status)::text = ANY ((ARRAY['Verified'::character varying, 'Pending'::character varying, 'Rejected'::character varying])::text[])))`.

## G-01 amendment

The installation includes [migration 002](../ddl/002-actual-interval.sql). `lesson.actual_start/actual_end` store the physical interval; `lesson_change.previous_actual_start/previous_actual_end` retain its OLD state. `lesson_actual_interval` and `history_actual_interval` enforce paired increasing bounds. `lesson_completed_requires_actuals` requires actuals for Completed; legacy NOT VALID handling is described in [the lifecycle contract](actual-interval.md). No credit total is stored.
