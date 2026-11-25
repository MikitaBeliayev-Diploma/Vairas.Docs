# Implemented data dictionary — scheduling

Observed synthetic PostgreSQL database: `vairas_scheduling`. Exported from migrated local runtime on 2026-11-25. Schema-only evidence; no business rows are included.

Migrations in the owning service remain the schema evolution authority. Existing design dictionaries are preserved separately. Cross-service UUID references are not physical foreign keys unless listed below.

| Schema | Table | Column | PostgreSQL type | Nullable | Default | Maximum length |
|---|---|---|---|---|---|---|
| public | __EFMigrationsHistory | MigrationId | varchar | NO |  | 150 |
| public | __EFMigrationsHistory | ProductVersion | varchar | NO |  | 32 |
| public | assessment_appointment | id | uuid | NO |  |  |
| public | assessment_appointment | school_id | uuid | NO |  |  |
| public | assessment_appointment | kind | lesson_kind | NO |  |  |
| public | assessment_appointment | enrollment_id | uuid | NO |  |  |
| public | assessment_appointment | student_id | uuid | NO |  |  |
| public | assessment_appointment | assessment_definition_id | uuid | NO |  |  |
| public | assessment_appointment | outstanding_requirement_id | uuid | YES |  |  |
| public | assessment_appointment | reason | varchar | NO |  | 500 |
| public | assessment_appointment | teacher_id | uuid | NO |  |  |
| public | assessment_appointment | vehicle_id | uuid | YES |  |  |
| public | assessment_appointment | branch_id | uuid | NO |  |  |
| public | assessment_appointment | category_code | varchar | NO |  | 16 |
| public | assessment_appointment | starts_at | timestamptz | NO |  |  |
| public | assessment_appointment | ends_at | timestamptz | NO |  |  |
| public | assessment_appointment | status | lesson_status | NO | 'Scheduled'::lesson_status |  |
| public | assessment_appointment | created_at | timestamptz | NO |  |  |
| public | assessment_appointment | readiness_evaluation_id | uuid | NO | '00000000-0000-0000-0000-000000000000'::uuid |  |
| public | assessment_appointment | revision | int4 | NO | 1 |  |
| public | candidate_lesson | id | uuid | NO |  |  |
| public | candidate_lesson | request_id | uuid | NO |  |  |
| public | candidate_lesson | request_revision | int4 | NO |  |  |
| public | candidate_lesson | kind | lesson_kind | NO |  |  |
| public | candidate_lesson | student_id | uuid | YES |  |  |
| public | candidate_lesson | enrollment_id | uuid | YES |  |  |
| public | candidate_lesson | group_id | uuid | YES |  |  |
| public | candidate_lesson | teacher_id | uuid | NO |  |  |
| public | candidate_lesson | vehicle_id | uuid | YES |  |  |
| public | candidate_lesson | branch_id | uuid | NO |  |  |
| public | candidate_lesson | series_id | uuid | YES |  |  |
| public | candidate_lesson | starts_at | timestamptz | NO |  |  |
| public | candidate_lesson | ends_at | timestamptz | NO |  |  |
| public | candidate_lesson | category_code | varchar | NO |  | 16 |
| public | candidate_lesson_participant | candidate_lesson_id | uuid | NO |  |  |
| public | candidate_lesson_participant | enrollment_id | uuid | NO |  |  |
| public | candidate_lesson_participant | student_id | uuid | NO |  |  |
| public | candidate_lesson_participant | membership_revision | int8 | NO |  |  |
| public | gate_command | id | uuid | NO |  |  |
| public | gate_command | school_id | uuid | NO |  |  |
| public | gate_command | fingerprint | text | NO |  |  |
| public | gate_command | kind | text | NO |  |  |
| public | gate_command | result_json | text | NO |  |  |
| public | gate_command | http_status | int4 | NO |  |  |
| public | integration_inbox | event_id | uuid | NO |  |  |
| public | integration_inbox | producer | varchar | NO |  | 32 |
| public | integration_inbox | event_type | varchar | NO |  | 64 |
| public | integration_inbox | fingerprint | varchar | NO |  | 64 |
| public | integration_inbox | outcome | varchar | NO |  | 32 |
| public | integration_inbox | reviews_raised | int4 | NO |  |  |
| public | integration_inbox | processed_at | timestamptz | NO |  |  |
| public | lesson | id | uuid | NO |  |  |
| public | lesson | school_id | uuid | NO |  |  |
| public | lesson | kind | lesson_kind | NO |  |  |
| public | lesson | branch_id | uuid | NO |  |  |
| public | lesson | teacher_id | uuid | NO |  |  |
| public | lesson | enrollment_id | uuid | YES |  |  |
| public | lesson | student_id | uuid | YES |  |  |
| public | lesson | vehicle_id | uuid | YES |  |  |
| public | lesson | group_id | uuid | YES |  |  |
| public | lesson | group_membership_revision | int8 | YES |  |  |
| public | lesson | starts_at | timestamptz | NO |  |  |
| public | lesson | ends_at | timestamptz | NO |  |  |
| public | lesson | status | lesson_status | NO | 'Scheduled'::lesson_status |  |
| public | lesson | revision | int4 | NO | 1 |  |
| public | lesson | series_id | uuid | YES |  |  |
| public | lesson | source_candidate_id | uuid | YES |  |  |
| public | lesson | created_at | timestamptz | NO |  |  |
| public | lesson | category_code | varchar | NO |  | 16 |
| public | lesson | actual_start | timestamptz | YES |  |  |
| public | lesson | actual_end | timestamptz | YES |  |  |
| public | lesson | reason | varchar | YES |  | 500 |
| public | lesson_change | id | uuid | NO |  |  |
| public | lesson_change | school_id | uuid | NO |  |  |
| public | lesson_change | lesson_id | uuid | NO |  |  |
| public | lesson_change | operation_id | uuid | NO |  |  |
| public | lesson_change | revision | int4 | NO |  |  |
| public | lesson_change | previous_status | lesson_status | NO |  |  |
| public | lesson_change | previous_start | timestamptz | NO |  |  |
| public | lesson_change | previous_end | timestamptz | NO |  |  |
| public | lesson_change | previous_teacher_id | uuid | NO |  |  |
| public | lesson_change | previous_vehicle_id | uuid | YES |  |  |
| public | lesson_change | previous_branch_id | uuid | NO |  |  |
| public | lesson_change | previous_series_id | uuid | YES |  |  |
| public | lesson_change | previous_group_membership_revision | int8 | YES |  |  |
| public | lesson_change | changed_at | timestamptz | NO |  |  |
| public | lesson_change | previous_actual_start | timestamptz | YES |  |  |
| public | lesson_change | previous_actual_end | timestamptz | YES |  |  |
| public | lesson_participant | lesson_id | uuid | NO |  |  |
| public | lesson_participant | enrollment_id | uuid | NO |  |  |
| public | lesson_participant | student_id | uuid | NO |  |  |
| public | lesson_participant | membership_revision | int8 | NO |  |  |
| public | lesson_participant | is_active | bool | NO | true |  |
| public | lesson_review | id | uuid | NO |  |  |
| public | lesson_review | school_id | uuid | NO |  |  |
| public | lesson_review | target_kind | varchar | NO |  | 32 |
| public | lesson_review | target_id | uuid | NO |  |  |
| public | lesson_review | reason_code | varchar | NO |  | 64 |
| public | lesson_review | subject_role | varchar | NO |  | 16 |
| public | lesson_review | subject_user_id | uuid | NO |  |  |
| public | lesson_review | source_event_id | uuid | NO |  |  |
| public | lesson_review | raised_at | timestamptz | NO |  |  |
| public | lesson_review | resolved_at | timestamptz | YES |  |  |
| public | lesson_review | resolved_by_user_id | uuid | YES |  |  |
| public | lesson_review | resolution_note | varchar | YES |  | 500 |
| public | outbox_message | id | uuid | NO |  |  |
| public | outbox_message | school_id | uuid | NO |  |  |
| public | outbox_message | aggregate_id | uuid | NO |  |  |
| public | outbox_message | aggregate_version | int4 | NO |  |  |
| public | outbox_message | event_type | text | NO |  |  |
| public | outbox_message | payload | text | NO |  |  |
| public | outbox_message | occurred_at | timestamptz | NO |  |  |
| public | outbox_message | available_at | timestamptz | NO |  |  |
| public | outbox_message | lease_id | uuid | YES |  |  |
| public | outbox_message | lease_until | timestamptz | YES |  |  |
| public | outbox_message | published_at | timestamptz | YES |  |  |
| public | outbox_message | attempts | int4 | NO |  |  |
| public | recurring_lesson_series | id | uuid | NO |  |  |
| public | recurring_lesson_series | school_id | uuid | NO |  |  |
| public | recurring_lesson_series | kind | lesson_kind | NO |  |  |
| public | recurring_lesson_series | frequency | recurrence_frequency | NO |  |  |
| public | recurring_lesson_series | recurrence_interval | int4 | NO | 1 |  |
| public | recurring_lesson_series | weekdays | _int2 | YES |  |  |
| public | recurring_lesson_series | local_start_time | time | NO |  |  |
| public | recurring_lesson_series | duration_minutes | int4 | NO |  |  |
| public | recurring_lesson_series | time_zone | varchar | NO |  | 80 |
| public | recurring_lesson_series | starts_on | date | NO |  |  |
| public | recurring_lesson_series | ends_on | date | YES |  |  |
| public | recurring_lesson_series | occurrence_count | int4 | YES |  |  |
| public | reservation_claim | id | uuid | NO |  |  |
| public | reservation_claim | operation_id | uuid | NO |  |  |
| public | reservation_claim | lesson_id | uuid | YES |  |  |
| public | reservation_claim | assessment_appointment_id | uuid | YES |  |  |
| public | reservation_claim | school_id | uuid | NO |  |  |
| public | reservation_claim | resource_kind | varchar | NO |  | 24 |
| public | reservation_claim | resource_key | uuid | NO |  |  |
| public | reservation_claim | starts_at | timestamptz | NO |  |  |
| public | reservation_claim | ends_at | timestamptz | NO |  |  |
| public | reservation_claim | status | reservation_status | NO | 'Active'::reservation_status |  |
| public | reservation_claim | created_at | timestamptz | NO |  |  |
| public | reservation_claim | released_at | timestamptz | YES |  |  |
| public | scheduling_operation | id | uuid | NO |  |  |
| public | scheduling_operation | school_id | uuid | NO |  |  |
| public | scheduling_operation | action_type | varchar | NO |  | 32 |
| public | scheduling_operation | request_id | uuid | YES |  |  |
| public | scheduling_operation | request_revision | int4 | YES |  |  |
| public | scheduling_operation | actor_user_id | uuid | NO |  |  |
| public | scheduling_operation | channel | varchar | NO |  | 16 |
| public | scheduling_operation | reason | varchar | YES |  | 500 |
| public | scheduling_operation | status | operation_status | NO | 'Pending'::operation_status |  |
| public | scheduling_operation | started_at | timestamptz | NO |  |  |
| public | scheduling_operation | finished_at | timestamptz | YES |  |  |
| public | scheduling_operation | target_lesson_id | uuid | YES |  |  |
| public | scheduling_operation | expected_lesson_revision | int4 | YES |  |  |
| public | scheduling_operation | target_appointment_id | uuid | YES |  |  |
| public | scheduling_operation | result_lesson_id | uuid | YES |  |  |
| public | scheduling_operation | result_appointment_id | uuid | YES |  |  |
| public | scheduling_operation | outcome_code | varchar | YES |  | 64 |
| public | scheduling_operation | user_confirmed_at | timestamptz | YES |  |  |
| public | scheduling_operation | fingerprint | varchar | NO | ''::character varying | 64 |
| public | scheduling_operation | result_json | text | NO | ''::text |  |
| public | scheduling_operation | http_status | int4 | NO | 0 |  |
| public | scheduling_operation_rule | operation_id | uuid | NO |  |  |
| public | scheduling_operation_rule | rule_version_id | uuid | NO |  |  |
| public | scheduling_request | id | uuid | NO |  |  |
| public | scheduling_request | revision | int4 | NO |  |  |
| public | scheduling_request | school_id | uuid | NO |  |  |
| public | scheduling_request | status | request_status | NO | 'Draft'::request_status |  |
| public | scheduling_request | planning_start | date | YES |  |  |
| public | scheduling_request | planning_end | date | YES |  |  |
| public | scheduling_request | submitted_by_user_id | uuid | YES |  |  |
| public | scheduling_request | submitted_at | timestamptz | YES |  |  |
| public | scheduling_request | generated_at | timestamptz | YES |  |  |
| public | scheduling_request | confirmed_operation_id | uuid | YES |  |  |
| public | scheduling_request | confirmed_at | timestamptz | YES |  |  |
| public | scheduling_request | created_by_user_id | uuid | NO |  |  |
| public | scheduling_request | created_at | timestamptz | NO |  |  |
| public | scheduling_request | inputs_json | text | NO | '{}'::text |  |
| public | scheduling_request | basis_json | text | NO | ''::text |  |
| public | scheduling_request | school_revision | int8 | NO | 0 |  |
| public | scheduling_request_enrollment | request_id | uuid | NO |  |  |
| public | scheduling_request_enrollment | request_revision | int4 | NO |  |  |
| public | scheduling_request_enrollment | enrollment_id | uuid | NO |  |  |
| public | scheduling_request_enrollment | student_id | uuid | YES |  |  |
| public | scheduling_request_enrollment | enrollment_revision | int8 | YES |  |  |
| public | scheduling_request_enrollment | training_program_version_id | uuid | YES |  |  |
| public | scheduling_request_enrollment | category_code | varchar | YES |  | 16 |
| public | scheduling_request_group | request_id | uuid | NO |  |  |
| public | scheduling_request_group | request_revision | int4 | NO |  |  |
| public | scheduling_request_group | group_id | uuid | NO |  |  |
| public | scheduling_request_group | training_program_version_id | uuid | YES |  |  |
| public | scheduling_request_group | category_code | varchar | YES |  | 16 |
| public | scheduling_request_group | membership_revision | int8 | YES |  |  |
| public | scheduling_request_resource | request_id | uuid | NO |  |  |
| public | scheduling_request_resource | request_revision | int4 | NO |  |  |
| public | scheduling_request_resource | resource_kind | varchar | NO |  | 24 |
| public | scheduling_request_resource | resource_id | uuid | NO |  |  |
| public | scheduling_request_resource | eligibility_revision | int8 | YES |  |  |
| public | scheduling_request_rule | request_id | uuid | NO |  |  |
| public | scheduling_request_rule | request_revision | int4 | NO |  |  |
| public | scheduling_request_rule | rule_version_id | uuid | NO |  |  |
| public | scheduling_request_window | id | uuid | NO |  |  |
| public | scheduling_request_window | request_id | uuid | NO |  |  |
| public | scheduling_request_window | request_revision | int4 | NO |  |  |
| public | scheduling_request_window | starts_at | timestamptz | NO |  |  |
| public | scheduling_request_window | ends_at | timestamptz | NO |  |  |
| public | scheduling_rule_version | id | uuid | NO |  |  |
| public | scheduling_rule_version | rule_id | uuid | NO |  |  |
| public | scheduling_rule_version | revision | int4 | NO |  |  |
| public | scheduling_rule_version | source_kind | varchar | NO |  | 16 |
| public | scheduling_rule_version | school_id | uuid | YES |  |  |
| public | scheduling_rule_version | category_code | varchar | YES |  | 16 |
| public | scheduling_rule_version | rule_code | varchar | NO |  | 80 |
| public | scheduling_rule_version | severity | varchar | NO |  | 16 |
| public | scheduling_rule_version | override_policy | varchar | NO |  | 24 |
| public | scheduling_rule_version | scope_kind | varchar | NO |  | 24 |
| public | scheduling_rule_version | scope_resource_id | uuid | YES |  |  |
| public | scheduling_rule_version | decision_reason | varchar | YES |  | 500 |
| public | scheduling_rule_version | numeric_limit | numeric | YES |  |  |
| public | scheduling_rule_version | unit | varchar | YES |  | 32 |
| public | scheduling_rule_version | effective_from | timestamptz | NO |  |  |
| public | scheduling_rule_version | effective_to | timestamptz | YES |  |  |
| public | scheduling_rule_version | source_reference | varchar | NO |  | 400 |
| public | scheduling_rule_version | verification_status | varchar | NO |  | 24 |
| public | scheduling_rule_version | decided_at | timestamptz | YES |  |  |
| public | scheduling_rule_version | created_by_user_id | uuid | NO |  |  |
| public | scheduling_rule_version | created_at | timestamptz | NO |  |  |
| public | scheduling_rule_version | decided_by_user_id | uuid | YES |  |  |
| public | school_barrier | school_id | uuid | NO |  |  |
| public | school_barrier | revision_floor | int8 | NO |  |  |
| public | school_barrier | pending_operation_id | uuid | YES |  |  |
| public | school_transition | id | uuid | NO |  |  |
| public | school_transition | school_id | uuid | NO |  |  |
| public | school_transition | before_revision | int8 | NO |  |  |
| public | school_transition | after_revision | int8 | NO |  |  |
| public | school_transition | fingerprint | text | NO |  |  |
| public | school_transition | payload_json | text | NO |  |  |
| public | school_transition | status | text | NO |  |  |
| public | school_transition | created_at | timestamptz | NO |  |  |
| public | vehicle_block | id | uuid | NO |  |  |
| public | vehicle_block | school_id | uuid | NO |  |  |
| public | vehicle_block | vehicle_id | uuid | NO |  |  |
| public | vehicle_block | operation_id | uuid | NO |  |  |
| public | vehicle_block | reason | text | NO |  |  |
| public | vehicle_block | status | text | NO |  |  |
| public | vehicle_block | created_at | timestamptz | NO |  |  |
| public | vehicle_guard | vehicle_id | uuid | NO |  |  |
| public | vehicle_guard | school_id | uuid | NO |  |  |

## Physical constraints

| Schema / table | Name | Definition |
|---|---|---|
| public.__EFMigrationsHistory | PK___EFMigrationsHistory | PRIMARY KEY ("MigrationId") |
| public.assessment_appointment | AK_assessment_appointment_id_school_id | UNIQUE (id, school_id) |
| public.assessment_appointment | PK_assessment_appointment | PRIMARY KEY (id) |
| public.assessment_appointment | assessment_interval | CHECK ((ends_at > starts_at)) |
| public.assessment_appointment | assessment_type | CHECK ((((kind = 'Practical'::lesson_kind) AND (vehicle_id IS NOT NULL)) OR ((kind = 'Theory'::lesson_kind) AND (vehicle_id IS NULL)))) |
| public.candidate_lesson | AK_candidate_lesson_id_request_id_request_revision | UNIQUE (id, request_id, request_revision) |
| public.candidate_lesson | FK_candidate_lesson_recurring_lesson_series_series_id | FOREIGN KEY (series_id) REFERENCES recurring_lesson_series(id) ON DELETE RESTRICT |
| public.candidate_lesson | FK_candidate_lesson_scheduling_request_request_id_request_revi~ | FOREIGN KEY (request_id, request_revision) REFERENCES scheduling_request(id, revision) ON DELETE RESTRICT |
| public.candidate_lesson | PK_candidate_lesson | PRIMARY KEY (id) |
| public.candidate_lesson | candidate_interval | CHECK ((ends_at > starts_at)) |
| public.candidate_lesson | candidate_type | CHECK ((((kind = 'Practical'::lesson_kind) AND (enrollment_id IS NOT NULL) AND (student_id IS NOT NULL) AND (vehicle_id IS NOT NULL) AND (group_id IS NULL)) OR ((kind = 'Theory'::lesson_kind) AND (group_id IS NOT NULL) AND (enrollment_id IS NULL) AND (student_id IS NULL) AND (vehicle_id IS NULL)))) |
| public.candidate_lesson_participant | FK_candidate_lesson_participant_candidate_lesson_candidate_les~ | FOREIGN KEY (candidate_lesson_id) REFERENCES candidate_lesson(id) ON DELETE RESTRICT |
| public.candidate_lesson_participant | PK_candidate_lesson_participant | PRIMARY KEY (candidate_lesson_id, enrollment_id) |
| public.candidate_lesson_participant | candidate_lesson_participant_membership_revision | CHECK ((membership_revision > 0)) |
| public.gate_command | PK_gate_command | PRIMARY KEY (id) |
| public.integration_inbox | PK_integration_inbox | PRIMARY KEY (event_id) |
| public.integration_inbox | integration_inbox_fingerprint | CHECK (((fingerprint)::text ~ '^[0-9a-f]{64}$'::text)) |
| public.integration_inbox | integration_inbox_reviews | CHECK ((reviews_raised >= 0)) |
| public.lesson | AK_lesson_id_school_id | UNIQUE (id, school_id) |
| public.lesson | FK_lesson_candidate_lesson_source_candidate_id | FOREIGN KEY (source_candidate_id) REFERENCES candidate_lesson(id) ON DELETE RESTRICT |
| public.lesson | FK_lesson_recurring_lesson_series_series_id_school_id_kind | FOREIGN KEY (series_id, school_id, kind) REFERENCES recurring_lesson_series(id, school_id, kind) ON DELETE RESTRICT |
| public.lesson | PK_lesson | PRIMARY KEY (id) |
| public.lesson | lesson_actual_interval | CHECK ((((actual_start IS NULL) AND (actual_end IS NULL)) OR ((actual_start IS NOT NULL) AND (actual_end IS NOT NULL) AND (actual_end > actual_start)))) |
| public.lesson | lesson_completed_requires_actuals | CHECK (((status <> 'Completed'::lesson_status) OR ((actual_start IS NOT NULL) AND (actual_end IS NOT NULL)))) |
| public.lesson | lesson_interval | CHECK ((ends_at > starts_at)) |
| public.lesson | lesson_membership_basis | CHECK ((((kind = 'Practical'::lesson_kind) AND (group_membership_revision IS NULL)) OR ((kind = 'Theory'::lesson_kind) AND (group_membership_revision IS NOT NULL) AND (group_membership_revision > 0)))) |
| public.lesson | lesson_reason | CHECK (((reason IS NULL) OR ((kind = 'Practical'::lesson_kind) AND ((reason)::text = btrim((reason)::text)) AND ((reason)::text <> ''::text)))) |
| public.lesson | lesson_revision_positive | CHECK ((revision > 0)) |
| public.lesson | lesson_type | CHECK ((((kind = 'Practical'::lesson_kind) AND (enrollment_id IS NOT NULL) AND (student_id IS NOT NULL) AND (vehicle_id IS NOT NULL) AND (group_id IS NULL)) OR ((kind = 'Theory'::lesson_kind) AND (group_id IS NOT NULL) AND (enrollment_id IS NULL) AND (student_id IS NULL) AND (vehicle_id IS NULL)))) |
| public.lesson_change | FK_lesson_change_lesson_lesson_id_school_id | FOREIGN KEY (lesson_id, school_id) REFERENCES lesson(id, school_id) ON DELETE RESTRICT |
| public.lesson_change | FK_lesson_change_scheduling_operation_operation_id_school_id | FOREIGN KEY (operation_id, school_id) REFERENCES scheduling_operation(id, school_id) ON DELETE RESTRICT |
| public.lesson_change | PK_lesson_change | PRIMARY KEY (id) |
| public.lesson_change | history_actual_interval | CHECK ((((previous_actual_start IS NULL) AND (previous_actual_end IS NULL)) OR ((previous_actual_start IS NOT NULL) AND (previous_actual_end IS NOT NULL) AND (previous_actual_end > previous_actual_start)))) |
| public.lesson_change | history_previous_interval | CHECK ((previous_end > previous_start)) |
| public.lesson_change | history_revision_positive | CHECK ((revision > 1)) |
| public.lesson_participant | FK_lesson_participant_lesson_lesson_id | FOREIGN KEY (lesson_id) REFERENCES lesson(id) ON DELETE RESTRICT |
| public.lesson_participant | PK_lesson_participant | PRIMARY KEY (lesson_id, enrollment_id) |
| public.lesson_participant | lesson_participant_membership_revision | CHECK ((membership_revision > 0)) |
| public.lesson_review | PK_lesson_review | PRIMARY KEY (id) |
| public.lesson_review | lesson_review_resolution | CHECK ((((resolved_at IS NULL) = (resolved_by_user_id IS NULL)) AND ((resolved_at IS NULL) = (resolution_note IS NULL)) AND ((resolved_at IS NULL) OR (resolved_at >= raised_at)))) |
| public.lesson_review | lesson_review_role | CHECK (((subject_role)::text = ANY ((ARRAY['Teacher'::character varying, 'Student'::character varying])::text[]))) |
| public.lesson_review | lesson_review_target | CHECK (((target_kind)::text = ANY ((ARRAY['Lesson'::character varying, 'AssessmentAppointment'::character varying])::text[]))) |
| public.outbox_message | PK_outbox_message | PRIMARY KEY (id) |
| public.recurring_lesson_series | AK_recurring_lesson_series_id_school_id_kind | UNIQUE (id, school_id, kind) |
| public.recurring_lesson_series | PK_recurring_lesson_series | PRIMARY KEY (id) |
| public.recurring_lesson_series | recurrence_count | CHECK (((occurrence_count IS NULL) OR (occurrence_count > 0))) |
| public.recurring_lesson_series | recurrence_end_choice | CHECK (((((ends_on IS NOT NULL))::integer + ((occurrence_count IS NOT NULL))::integer) = 1)) |
| public.recurring_lesson_series | recurrence_end_range | CHECK (((ends_on IS NULL) OR (ends_on >= starts_on))) |
| public.recurring_lesson_series | recurrence_positive | CHECK (((recurrence_interval > 0) AND (duration_minutes > 0))) |
| public.recurring_lesson_series | recurrence_weekdays | CHECK ((((frequency = 'Daily'::recurrence_frequency) AND (COALESCE(cardinality(weekdays), 0) = 0)) OR ((frequency = 'Weekly'::recurrence_frequency) AND (weekdays IS NOT NULL) AND ((cardinality(weekdays) >= 1) AND (cardinality(weekdays) <= 7)) AND (weekdays <@ ARRAY[(1)::smallint, (2)::smallint, (3)::smallint, (4)::smallint, (5)::smallint, (6)::smallint, (7)::smallint])))) |
| public.reservation_claim | FK_reservation_claim_assessment_appointment_assessment_appoint~ | FOREIGN KEY (assessment_appointment_id, school_id) REFERENCES assessment_appointment(id, school_id) ON DELETE RESTRICT |
| public.reservation_claim | FK_reservation_claim_lesson_lesson_id_school_id | FOREIGN KEY (lesson_id, school_id) REFERENCES lesson(id, school_id) ON DELETE RESTRICT |
| public.reservation_claim | FK_reservation_claim_scheduling_operation_operation_id_school_~ | FOREIGN KEY (operation_id, school_id) REFERENCES scheduling_operation(id, school_id) ON DELETE RESTRICT |
| public.reservation_claim | PK_reservation_claim | PRIMARY KEY (id) |
| public.reservation_claim | active_resource_no_overlap | EXCLUDE USING gist (resource_kind WITH =, resource_key WITH =, tstzrange(starts_at, ends_at, '[)'::text) WITH &&) WHERE ((status = 'Active'::reservation_status)) |
| public.reservation_claim | claim_interval | CHECK ((ends_at > starts_at)) |
| public.reservation_claim | claim_kind | CHECK (((resource_kind)::text = ANY ((ARRAY['Student'::character varying, 'Instructor'::character varying, 'Vehicle'::character varying, 'Group'::character varying])::text[]))) |
| public.reservation_claim | claim_owner | CHECK (((((lesson_id IS NOT NULL))::integer + ((assessment_appointment_id IS NOT NULL))::integer) = 1)) |
| public.reservation_claim | claim_release | CHECK ((((status = 'Active'::reservation_status) AND (released_at IS NULL)) OR ((status = 'Released'::reservation_status) AND (released_at IS NOT NULL) AND (released_at >= created_at)))) |
| public.scheduling_operation | AK_scheduling_operation_id_school_id | UNIQUE (id, school_id) |
| public.scheduling_operation | FK_scheduling_operation_assessment_appointment_result_appointm~ | FOREIGN KEY (result_appointment_id, school_id) REFERENCES assessment_appointment(id, school_id) ON DELETE RESTRICT |
| public.scheduling_operation | FK_scheduling_operation_assessment_appointment_target_appointm~ | FOREIGN KEY (target_appointment_id, school_id) REFERENCES assessment_appointment(id, school_id) ON DELETE RESTRICT |
| public.scheduling_operation | FK_scheduling_operation_lesson_result_lesson_id_school_id | FOREIGN KEY (result_lesson_id, school_id) REFERENCES lesson(id, school_id) ON DELETE RESTRICT |
| public.scheduling_operation | FK_scheduling_operation_lesson_target_lesson_id_school_id | FOREIGN KEY (target_lesson_id, school_id) REFERENCES lesson(id, school_id) ON DELETE RESTRICT |
| public.scheduling_operation | FK_scheduling_operation_scheduling_request_request_id_request_~ | FOREIGN KEY (request_id, request_revision, school_id) REFERENCES scheduling_request(id, revision, school_id) ON DELETE RESTRICT |
| public.scheduling_operation | PK_scheduling_operation | PRIMARY KEY (id) |
| public.scheduling_operation | operation_action | CHECK (((action_type)::text = ANY ((ARRAY['ConfirmSchedule'::character varying, 'CreateLesson'::character varying, 'Reschedule'::character varying, 'Cancel'::character varying, 'ChangeGroup'::character varying, 'CompleteLesson'::character varying, 'CorrectActualInterval'::character varying, 'CreateAssessment'::character varying, 'CancelAssessment'::character varying, 'CreateDraft'::character varying, 'ReviseDraft'::character varying, 'SubmitRequest'::character varying, 'GenerateProposal'::character varying, 'PublishRule'::character varying])::text[]))) |
| public.scheduling_operation | operation_channel | CHECK (((channel)::text = ANY ((ARRAY['Web'::character varying, 'MCP'::character varying, 'Internal'::character varying])::text[]))) |
| public.scheduling_operation | operation_expected_revision | CHECK (((expected_lesson_revision IS NULL) OR (expected_lesson_revision > 0))) |
| public.scheduling_operation | operation_finished | CHECK ((((status = 'Pending'::operation_status) AND (finished_at IS NULL)) OR (status = 'ReconciliationPending'::operation_status) OR ((status = ANY (ARRAY['Committed'::operation_status, 'Rejected'::operation_status])) AND (finished_at IS NOT NULL)))) |
| public.scheduling_operation | operation_request_pair | CHECK (((request_id IS NULL) = (request_revision IS NULL))) |
| public.scheduling_operation | operation_target_xor | CHECK (((target_lesson_id IS NULL) OR (target_appointment_id IS NULL))) |
| public.scheduling_operation_rule | FK_scheduling_operation_rule_scheduling_operation_operation_id | FOREIGN KEY (operation_id) REFERENCES scheduling_operation(id) ON DELETE RESTRICT |
| public.scheduling_operation_rule | FK_scheduling_operation_rule_scheduling_rule_version_rule_vers~ | FOREIGN KEY (rule_version_id) REFERENCES scheduling_rule_version(id) ON DELETE RESTRICT |
| public.scheduling_operation_rule | PK_scheduling_operation_rule | PRIMARY KEY (operation_id, rule_version_id) |
| public.scheduling_request | AK_scheduling_request_id_revision_school_id | UNIQUE (id, revision, school_id) |
| public.scheduling_request | FK_scheduling_request_scheduling_operation_confirmed_operation~ | FOREIGN KEY (confirmed_operation_id, school_id) REFERENCES scheduling_operation(id, school_id) ON DELETE RESTRICT |
| public.scheduling_request | PK_scheduling_request | PRIMARY KEY (id, revision) |
| public.scheduling_request | request_confirmed_metadata | CHECK ((((status = 'Confirmed'::request_status) AND (confirmed_at IS NOT NULL) AND (confirmed_operation_id IS NOT NULL)) OR ((status <> 'Confirmed'::request_status) AND (confirmed_at IS NULL) AND (confirmed_operation_id IS NULL)))) |
| public.scheduling_request | request_period | CHECK (((planning_start IS NULL) OR (planning_end IS NULL) OR (planning_end >= planning_start))) |
| public.scheduling_request | request_ready_metadata | CHECK (((status <> ALL (ARRAY['Ready'::request_status, 'Confirmed'::request_status])) OR (generated_at IS NOT NULL))) |
| public.scheduling_request | request_revision_positive | CHECK ((revision > 0)) |
| public.scheduling_request | request_single_school | EXCLUDE USING gist (id WITH =, school_id WITH <>) |
| public.scheduling_request | request_submitted_pair | CHECK (((submitted_at IS NULL) = (submitted_by_user_id IS NULL))) |
| public.scheduling_request | request_validated_metadata | CHECK (((status <> ALL (ARRAY['Submitted'::request_status, 'Ready'::request_status, 'Infeasible'::request_status, 'Stale'::request_status, 'Superseded'::request_status, 'Confirmed'::request_status])) OR ((submitted_at IS NOT NULL) AND (planning_start IS NOT NULL) AND (planning_end IS NOT NULL)))) |
| public.scheduling_request_enrollment | FK_scheduling_request_enrollment_scheduling_request_request_id~ | FOREIGN KEY (request_id, request_revision) REFERENCES scheduling_request(id, revision) ON DELETE RESTRICT |
| public.scheduling_request_enrollment | PK_scheduling_request_enrollment | PRIMARY KEY (request_id, request_revision, enrollment_id) |
| public.scheduling_request_enrollment | scheduling_request_enrollment_revision | CHECK ((request_revision > 0)) |
| public.scheduling_request_group | FK_scheduling_request_group_scheduling_request_request_id_requ~ | FOREIGN KEY (request_id, request_revision) REFERENCES scheduling_request(id, revision) ON DELETE RESTRICT |
| public.scheduling_request_group | PK_scheduling_request_group | PRIMARY KEY (request_id, request_revision, group_id) |
| public.scheduling_request_group | scheduling_request_group_revision | CHECK ((request_revision > 0)) |
| public.scheduling_request_resource | FK_scheduling_request_resource_scheduling_request_request_id_r~ | FOREIGN KEY (request_id, request_revision) REFERENCES scheduling_request(id, revision) ON DELETE RESTRICT |
| public.scheduling_request_resource | PK_scheduling_request_resource | PRIMARY KEY (request_id, request_revision, resource_kind, resource_id) |
| public.scheduling_request_resource | resource_kind_valid | CHECK (((resource_kind)::text = ANY ((ARRAY['Instructor'::character varying, 'Vehicle'::character varying, 'Branch'::character varying])::text[]))) |
| public.scheduling_request_resource | resource_source_revision | CHECK (((eligibility_revision IS NULL) OR (eligibility_revision > 0))) |
| public.scheduling_request_resource | scheduling_request_resource_revision | CHECK ((request_revision > 0)) |
| public.scheduling_request_rule | FK_scheduling_request_rule_scheduling_request_request_id_reque~ | FOREIGN KEY (request_id, request_revision) REFERENCES scheduling_request(id, revision) ON DELETE RESTRICT |
| public.scheduling_request_rule | FK_scheduling_request_rule_scheduling_rule_version_rule_versio~ | FOREIGN KEY (rule_version_id) REFERENCES scheduling_rule_version(id) ON DELETE RESTRICT |
| public.scheduling_request_rule | PK_scheduling_request_rule | PRIMARY KEY (request_id, request_revision, rule_version_id) |
| public.scheduling_request_rule | scheduling_request_rule_revision | CHECK ((request_revision > 0)) |
| public.scheduling_request_window | FK_scheduling_request_window_scheduling_request_request_id_req~ | FOREIGN KEY (request_id, request_revision) REFERENCES scheduling_request(id, revision) ON DELETE RESTRICT |
| public.scheduling_request_window | PK_scheduling_request_window | PRIMARY KEY (id) |
| public.scheduling_request_window | window_interval | CHECK ((ends_at > starts_at)) |
| public.scheduling_rule_version | PK_scheduling_rule_version | PRIMARY KEY (id) |
| public.scheduling_rule_version | rule_decision_actor | CHECK (((((verification_status)::text = 'Pending'::text) AND (decided_at IS NULL) AND (decided_by_user_id IS NULL)) OR (((verification_status)::text = ANY ((ARRAY['Verified'::character varying, 'Rejected'::character varying])::text[])) AND (decided_at IS NOT NULL) AND (decided_by_user_id IS NOT NULL)))) |
| public.scheduling_rule_version | rule_effective_interval | CHECK (((effective_to IS NULL) OR (effective_to > effective_from))) |
| public.scheduling_rule_version | rule_override_policy | CHECK ((((override_policy)::text = ANY ((ARRAY['Locked'::character varying, 'SchoolEditable'::character varying])::text[])) AND ((((source_kind)::text = 'Legal'::text) AND ((override_policy)::text = 'Locked'::text)) OR (((source_kind)::text = 'School'::text) AND ((override_policy)::text = 'SchoolEditable'::text))))) |
| public.scheduling_rule_version | rule_revision | CHECK ((revision > 0)) |
| public.scheduling_rule_version | rule_school_scope | CHECK (((((source_kind)::text = 'Legal'::text) AND (school_id IS NULL)) OR (((source_kind)::text = 'School'::text) AND (school_id IS NOT NULL)))) |
| public.scheduling_rule_version | rule_scope | CHECK ((((scope_kind)::text = ANY ((ARRAY['School'::character varying, 'Instructor'::character varying, 'Vehicle'::character varying, 'Branch'::character varying, 'Group'::character varying, 'Student'::character varying])::text[])) AND ((((scope_kind)::text = 'School'::text) AND (scope_resource_id IS NULL)) OR (((scope_kind)::text <> 'School'::text) AND (scope_resource_id IS NOT NULL))))) |
| public.scheduling_rule_version | rule_severity | CHECK ((((severity)::text = ANY ((ARRAY['Hard'::character varying, 'Preference'::character varying])::text[])) AND (((source_kind)::text <> 'Legal'::text) OR ((severity)::text = 'Hard'::text)))) |
| public.scheduling_rule_version | rule_source_kind | CHECK (((source_kind)::text = ANY ((ARRAY['Legal'::character varying, 'School'::character varying])::text[]))) |
| public.scheduling_rule_version | rule_typed_limit | CHECK ((((numeric_limit IS NULL) AND (unit IS NULL)) OR ((numeric_limit > (0)::numeric) AND (unit IS NOT NULL)))) |
| public.scheduling_rule_version | rule_verification | CHECK (((verification_status)::text = ANY ((ARRAY['Verified'::character varying, 'Pending'::character varying, 'Rejected'::character varying])::text[]))) |
| public.school_barrier | PK_school_barrier | PRIMARY KEY (school_id) |
| public.school_transition | PK_school_transition | PRIMARY KEY (id) |
| public.vehicle_block | PK_vehicle_block | PRIMARY KEY (id) |
| public.vehicle_guard | PK_vehicle_guard | PRIMARY KEY (vehicle_id) |

## Indexes

| Schema / table | Index | Definition |
|---|---|---|
| public.__EFMigrationsHistory | PK___EFMigrationsHistory | CREATE UNIQUE INDEX "PK___EFMigrationsHistory" ON public."__EFMigrationsHistory" USING btree ("MigrationId") |
| public.assessment_appointment | AK_assessment_appointment_id_school_id | CREATE UNIQUE INDEX "AK_assessment_appointment_id_school_id" ON public.assessment_appointment USING btree (id, school_id) |
| public.assessment_appointment | PK_assessment_appointment | CREATE UNIQUE INDEX "PK_assessment_appointment" ON public.assessment_appointment USING btree (id) |
| public.candidate_lesson | AK_candidate_lesson_id_request_id_request_revision | CREATE UNIQUE INDEX "AK_candidate_lesson_id_request_id_request_revision" ON public.candidate_lesson USING btree (id, request_id, request_revision) |
| public.candidate_lesson | IX_candidate_lesson_request_id_request_revision | CREATE INDEX "IX_candidate_lesson_request_id_request_revision" ON public.candidate_lesson USING btree (request_id, request_revision) |
| public.candidate_lesson | IX_candidate_lesson_series_id | CREATE INDEX "IX_candidate_lesson_series_id" ON public.candidate_lesson USING btree (series_id) |
| public.candidate_lesson | PK_candidate_lesson | CREATE UNIQUE INDEX "PK_candidate_lesson" ON public.candidate_lesson USING btree (id) |
| public.candidate_lesson_participant | IX_candidate_lesson_participant_candidate_lesson_id_student_id | CREATE UNIQUE INDEX "IX_candidate_lesson_participant_candidate_lesson_id_student_id" ON public.candidate_lesson_participant USING btree (candidate_lesson_id, student_id) |
| public.candidate_lesson_participant | PK_candidate_lesson_participant | CREATE UNIQUE INDEX "PK_candidate_lesson_participant" ON public.candidate_lesson_participant USING btree (candidate_lesson_id, enrollment_id) |
| public.gate_command | PK_gate_command | CREATE UNIQUE INDEX "PK_gate_command" ON public.gate_command USING btree (id) |
| public.integration_inbox | PK_integration_inbox | CREATE UNIQUE INDEX "PK_integration_inbox" ON public.integration_inbox USING btree (event_id) |
| public.lesson | AK_lesson_id_school_id | CREATE UNIQUE INDEX "AK_lesson_id_school_id" ON public.lesson USING btree (id, school_id) |
| public.lesson | IX_lesson_school_id_starts_at | CREATE INDEX "IX_lesson_school_id_starts_at" ON public.lesson USING btree (school_id, starts_at) |
| public.lesson | IX_lesson_series_id_school_id_kind | CREATE INDEX "IX_lesson_series_id_school_id_kind" ON public.lesson USING btree (series_id, school_id, kind) |
| public.lesson | IX_lesson_source_candidate_id | CREATE UNIQUE INDEX "IX_lesson_source_candidate_id" ON public.lesson USING btree (source_candidate_id) |
| public.lesson | IX_lesson_teacher_id_starts_at_ends_at | CREATE INDEX "IX_lesson_teacher_id_starts_at_ends_at" ON public.lesson USING btree (teacher_id, starts_at, ends_at) |
| public.lesson | PK_lesson | CREATE UNIQUE INDEX "PK_lesson" ON public.lesson USING btree (id) |
| public.lesson_change | IX_lesson_change_lesson_id_revision | CREATE UNIQUE INDEX "IX_lesson_change_lesson_id_revision" ON public.lesson_change USING btree (lesson_id, revision) |
| public.lesson_change | IX_lesson_change_lesson_id_school_id | CREATE INDEX "IX_lesson_change_lesson_id_school_id" ON public.lesson_change USING btree (lesson_id, school_id) |
| public.lesson_change | IX_lesson_change_operation_id_school_id | CREATE INDEX "IX_lesson_change_operation_id_school_id" ON public.lesson_change USING btree (operation_id, school_id) |
| public.lesson_change | PK_lesson_change | CREATE UNIQUE INDEX "PK_lesson_change" ON public.lesson_change USING btree (id) |
| public.lesson_participant | IX_lesson_participant_lesson_id_student_id | CREATE UNIQUE INDEX "IX_lesson_participant_lesson_id_student_id" ON public.lesson_participant USING btree (lesson_id, student_id) |
| public.lesson_participant | PK_lesson_participant | CREATE UNIQUE INDEX "PK_lesson_participant" ON public.lesson_participant USING btree (lesson_id, enrollment_id) |
| public.lesson_review | IX_lesson_review_school_id_resolved_at | CREATE INDEX "IX_lesson_review_school_id_resolved_at" ON public.lesson_review USING btree (school_id, resolved_at) |
| public.lesson_review | IX_lesson_review_source_event_id_target_kind_target_id | CREATE UNIQUE INDEX "IX_lesson_review_source_event_id_target_kind_target_id" ON public.lesson_review USING btree (source_event_id, target_kind, target_id) |
| public.lesson_review | PK_lesson_review | CREATE UNIQUE INDEX "PK_lesson_review" ON public.lesson_review USING btree (id) |
| public.outbox_message | IX_outbox_message_published_at_available_at | CREATE INDEX "IX_outbox_message_published_at_available_at" ON public.outbox_message USING btree (published_at, available_at) |
| public.outbox_message | PK_outbox_message | CREATE UNIQUE INDEX "PK_outbox_message" ON public.outbox_message USING btree (id) |
| public.recurring_lesson_series | AK_recurring_lesson_series_id_school_id_kind | CREATE UNIQUE INDEX "AK_recurring_lesson_series_id_school_id_kind" ON public.recurring_lesson_series USING btree (id, school_id, kind) |
| public.recurring_lesson_series | PK_recurring_lesson_series | CREATE UNIQUE INDEX "PK_recurring_lesson_series" ON public.recurring_lesson_series USING btree (id) |
| public.reservation_claim | IX_reservation_claim_assessment_appointment_id_school_id | CREATE INDEX "IX_reservation_claim_assessment_appointment_id_school_id" ON public.reservation_claim USING btree (assessment_appointment_id, school_id) |
| public.reservation_claim | IX_reservation_claim_lesson_id_resource_kind_resource_key | CREATE INDEX "IX_reservation_claim_lesson_id_resource_kind_resource_key" ON public.reservation_claim USING btree (lesson_id, resource_kind, resource_key) |
| public.reservation_claim | IX_reservation_claim_lesson_id_school_id | CREATE INDEX "IX_reservation_claim_lesson_id_school_id" ON public.reservation_claim USING btree (lesson_id, school_id) |
| public.reservation_claim | IX_reservation_claim_operation_id_school_id | CREATE INDEX "IX_reservation_claim_operation_id_school_id" ON public.reservation_claim USING btree (operation_id, school_id) |
| public.reservation_claim | IX_reservation_claim_resource_kind_resource_key_starts_at_ends~ | CREATE INDEX "IX_reservation_claim_resource_kind_resource_key_starts_at_ends~" ON public.reservation_claim USING btree (resource_kind, resource_key, starts_at, ends_at) |
| public.reservation_claim | PK_reservation_claim | CREATE UNIQUE INDEX "PK_reservation_claim" ON public.reservation_claim USING btree (id) |
| public.reservation_claim | active_resource_no_overlap | CREATE INDEX active_resource_no_overlap ON public.reservation_claim USING gist (resource_kind, resource_key, tstzrange(starts_at, ends_at, '[)'::text)) WHERE (status = 'Active'::reservation_status) |
| public.scheduling_operation | AK_scheduling_operation_id_school_id | CREATE UNIQUE INDEX "AK_scheduling_operation_id_school_id" ON public.scheduling_operation USING btree (id, school_id) |
| public.scheduling_operation | IX_scheduling_operation_request_id_request_revision_school_id | CREATE INDEX "IX_scheduling_operation_request_id_request_revision_school_id" ON public.scheduling_operation USING btree (request_id, request_revision, school_id) |
| public.scheduling_operation | IX_scheduling_operation_result_appointment_id_school_id | CREATE INDEX "IX_scheduling_operation_result_appointment_id_school_id" ON public.scheduling_operation USING btree (result_appointment_id, school_id) |
| public.scheduling_operation | IX_scheduling_operation_result_lesson_id_school_id | CREATE INDEX "IX_scheduling_operation_result_lesson_id_school_id" ON public.scheduling_operation USING btree (result_lesson_id, school_id) |
| public.scheduling_operation | IX_scheduling_operation_target_appointment_id_school_id | CREATE INDEX "IX_scheduling_operation_target_appointment_id_school_id" ON public.scheduling_operation USING btree (target_appointment_id, school_id) |
| public.scheduling_operation | IX_scheduling_operation_target_lesson_id_school_id | CREATE INDEX "IX_scheduling_operation_target_lesson_id_school_id" ON public.scheduling_operation USING btree (target_lesson_id, school_id) |
| public.scheduling_operation | PK_scheduling_operation | CREATE UNIQUE INDEX "PK_scheduling_operation" ON public.scheduling_operation USING btree (id) |
| public.scheduling_operation_rule | IX_scheduling_operation_rule_rule_version_id | CREATE INDEX "IX_scheduling_operation_rule_rule_version_id" ON public.scheduling_operation_rule USING btree (rule_version_id) |
| public.scheduling_operation_rule | PK_scheduling_operation_rule | CREATE UNIQUE INDEX "PK_scheduling_operation_rule" ON public.scheduling_operation_rule USING btree (operation_id, rule_version_id) |
| public.scheduling_request | AK_scheduling_request_id_revision_school_id | CREATE UNIQUE INDEX "AK_scheduling_request_id_revision_school_id" ON public.scheduling_request USING btree (id, revision, school_id) |
| public.scheduling_request | IX_scheduling_request_confirmed_operation_id_school_id | CREATE INDEX "IX_scheduling_request_confirmed_operation_id_school_id" ON public.scheduling_request USING btree (confirmed_operation_id, school_id) |
| public.scheduling_request | IX_scheduling_request_school_id_status | CREATE INDEX "IX_scheduling_request_school_id_status" ON public.scheduling_request USING btree (school_id, status) |
| public.scheduling_request | PK_scheduling_request | CREATE UNIQUE INDEX "PK_scheduling_request" ON public.scheduling_request USING btree (id, revision) |
| public.scheduling_request | request_single_school | CREATE INDEX request_single_school ON public.scheduling_request USING gist (id, school_id) |
| public.scheduling_request_enrollment | PK_scheduling_request_enrollment | CREATE UNIQUE INDEX "PK_scheduling_request_enrollment" ON public.scheduling_request_enrollment USING btree (request_id, request_revision, enrollment_id) |
| public.scheduling_request_group | PK_scheduling_request_group | CREATE UNIQUE INDEX "PK_scheduling_request_group" ON public.scheduling_request_group USING btree (request_id, request_revision, group_id) |
| public.scheduling_request_resource | PK_scheduling_request_resource | CREATE UNIQUE INDEX "PK_scheduling_request_resource" ON public.scheduling_request_resource USING btree (request_id, request_revision, resource_kind, resource_id) |
| public.scheduling_request_rule | IX_scheduling_request_rule_rule_version_id | CREATE INDEX "IX_scheduling_request_rule_rule_version_id" ON public.scheduling_request_rule USING btree (rule_version_id) |
| public.scheduling_request_rule | PK_scheduling_request_rule | CREATE UNIQUE INDEX "PK_scheduling_request_rule" ON public.scheduling_request_rule USING btree (request_id, request_revision, rule_version_id) |
| public.scheduling_request_window | IX_scheduling_request_window_request_id_request_revision | CREATE INDEX "IX_scheduling_request_window_request_id_request_revision" ON public.scheduling_request_window USING btree (request_id, request_revision) |
| public.scheduling_request_window | PK_scheduling_request_window | CREATE UNIQUE INDEX "PK_scheduling_request_window" ON public.scheduling_request_window USING btree (id) |
| public.scheduling_rule_version | IX_scheduling_rule_version_rule_id_revision | CREATE UNIQUE INDEX "IX_scheduling_rule_version_rule_id_revision" ON public.scheduling_rule_version USING btree (rule_id, revision) |
| public.scheduling_rule_version | IX_scheduling_rule_version_source_kind_school_id_rule_code | CREATE INDEX "IX_scheduling_rule_version_source_kind_school_id_rule_code" ON public.scheduling_rule_version USING btree (source_kind, school_id, rule_code) |
| public.scheduling_rule_version | PK_scheduling_rule_version | CREATE UNIQUE INDEX "PK_scheduling_rule_version" ON public.scheduling_rule_version USING btree (id) |
| public.school_barrier | PK_school_barrier | CREATE UNIQUE INDEX "PK_school_barrier" ON public.school_barrier USING btree (school_id) |
| public.school_transition | IX_school_transition_school_id_status | CREATE INDEX "IX_school_transition_school_id_status" ON public.school_transition USING btree (school_id, status) |
| public.school_transition | PK_school_transition | CREATE UNIQUE INDEX "PK_school_transition" ON public.school_transition USING btree (id) |
| public.vehicle_block | IX_vehicle_block_vehicle_id_status | CREATE INDEX "IX_vehicle_block_vehicle_id_status" ON public.vehicle_block USING btree (vehicle_id, status) |
| public.vehicle_block | PK_vehicle_block | CREATE UNIQUE INDEX "PK_vehicle_block" ON public.vehicle_block USING btree (id) |
| public.vehicle_guard | PK_vehicle_guard | CREATE UNIQUE INDEX "PK_vehicle_guard" ON public.vehicle_guard USING btree (vehicle_id) |

## Row-Level Security

| Schema / table | Enabled | Forced |
|---|---|---|
| public.candidate_lesson | True | False |
| public.candidate_lesson_participant | True | False |
| public.__EFMigrationsHistory | False | False |
| public.recurring_lesson_series | True | False |
| public.outbox_message | True | False |
| public.school_transition | True | False |
| public.scheduling_request_rule | True | False |
| public.scheduling_operation_rule | True | False |
| public.lesson | True | False |
| public.lesson_participant | True | False |
| public.scheduling_operation | True | False |
| public.reservation_claim | True | False |
| public.scheduling_request | True | False |
| public.scheduling_request_enrollment | True | False |
| public.scheduling_request_group | True | False |
| public.scheduling_request_resource | True | False |
| public.scheduling_request_window | True | False |
| public.lesson_change | True | False |
| public.assessment_appointment | True | False |
| public.integration_inbox | False | False |
| public.lesson_review | True | False |
| public.scheduling_rule_version | True | False |
| public.vehicle_guard | True | False |
| public.vehicle_block | True | False |
| public.gate_command | True | False |
| public.school_barrier | True | False |

Policy expressions and command/role restrictions are retained verbatim in `../schema/implemented-catalogue.json` and `../schema/implemented-schema.sql`. Schema DDL also contains functions and triggers enforcing integrity and audit invariants.
