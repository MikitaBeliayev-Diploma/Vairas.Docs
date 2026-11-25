# Implemented data dictionary — school-management

Observed synthetic PostgreSQL database: `vairas_school_management`. Exported from migrated local runtime on 2026-11-25. Schema-only evidence; no business rows are included.

Migrations in the owning service remain the schema evolution authority. Existing design dictionaries are preserved separately. Cross-service UUID references are not physical foreign keys unless listed below.

| Schema | Table | Column | PostgreSQL type | Nullable | Default | Maximum length |
|---|---|---|---|---|---|---|
| public | __EFMigrationsHistory | MigrationId | varchar | NO |  | 150 |
| public | __EFMigrationsHistory | ProductVersion | varchar | NO |  | 32 |
| public | branch | branch_id | uuid | NO |  |  |
| public | branch | school_id | uuid | NO |  |  |
| public | branch | name | varchar | NO |  | 200 |
| public | branch | address_line | varchar | YES |  | 300 |
| public | branch | city | varchar | YES |  | 120 |
| public | branch | postal_code | varchar | YES |  | 30 |
| public | branch | country_code | varchar | YES |  | 2 |
| public | branch | status | sm_status | NO | 'Active'::sm_status |  |
| public | branch | revision | int8 | NO | 1 |  |
| public | branch | last_operation_id | uuid | NO |  |  |
| public | enrollment_status_history | enrollment_id | uuid | NO |  |  |
| public | enrollment_status_history | school_id | uuid | NO |  |  |
| public | enrollment_status_history | enrollment_revision | int8 | NO |  |  |
| public | enrollment_status_history | from_status | sm_enrollment_status | YES |  |  |
| public | enrollment_status_history | to_status | sm_enrollment_status | NO |  |  |
| public | enrollment_status_history | effective_at | timestamptz | NO |  |  |
| public | enrollment_status_history | recorded_at | timestamptz | NO | clock_timestamp() |  |
| public | enrollment_status_history | operation_id | uuid | NO |  |  |
| public | enrollment_status_history | completion_evidence_id | uuid | YES |  |  |
| public | enrollment_status_history | completion_dependency_revision | int8 | YES |  |  |
| public | enrollment_status_history | completion_verified_at | timestamptz | YES |  |  |
| public | group_roster_member | group_id | uuid | NO |  |  |
| public | group_roster_member | school_id | uuid | NO |  |  |
| public | group_roster_member | membership_revision | int8 | NO |  |  |
| public | group_roster_member | membership_id | uuid | NO |  |  |
| public | group_roster_member | enrollment_id | uuid | NO |  |  |
| public | group_roster_member | student_id | uuid | NO |  |  |
| public | group_roster_member | enrollment_revision | int8 | NO |  |  |
| public | group_roster_member | enrollment_status | sm_enrollment_status | NO |  |  |
| public | group_roster_member | category_code | varchar | NO |  | 20 |
| public | group_roster_member | enrollment_started_at | timestamptz | NO |  |  |
| public | group_roster_member | enrollment_ended_at | timestamptz | YES |  |  |
| public | group_roster_member | joined_at | timestamptz | NO |  |  |
| public | group_roster_member | left_at | timestamptz | YES |  |  |
| public | group_roster_revision | group_id | uuid | NO |  |  |
| public | group_roster_revision | school_id | uuid | NO |  |  |
| public | group_roster_revision | membership_revision | int8 | NO |  |  |
| public | group_roster_revision | recorded_at | timestamptz | NO |  |  |
| public | group_roster_revision | operation_id | uuid | NO |  |  |
| public | integration_inbox | event_id | uuid | NO |  |  |
| public | integration_inbox | producer | varchar | NO |  | 32 |
| public | integration_inbox | event_type | varchar | NO |  | 64 |
| public | integration_inbox | fingerprint | varchar | NO |  | 64 |
| public | integration_inbox | outcome | varchar | NO |  | 32 |
| public | integration_inbox | reviews_raised | int4 | NO |  |  |
| public | integration_inbox | processed_at | timestamptz | NO |  |  |
| public | membership_permission_grant | grant_id | uuid | NO |  |  |
| public | membership_permission_grant | school_id | uuid | NO |  |  |
| public | membership_permission_grant | membership_id | uuid | NO |  |  |
| public | membership_permission_grant | permission | sm_permission | NO |  |  |
| public | membership_permission_grant | started_at | timestamptz | NO |  |  |
| public | membership_permission_grant | ended_at | timestamptz | YES |  |  |
| public | membership_permission_grant | granted_operation_id | uuid | NO |  |  |
| public | membership_permission_grant | ended_operation_id | uuid | YES |  |  |
| public | membership_review | review_id | uuid | NO |  |  |
| public | membership_review | school_id | uuid | NO |  |  |
| public | membership_review | target_kind | varchar | NO |  | 32 |
| public | membership_review | target_id | uuid | NO |  |  |
| public | membership_review | reason_code | varchar | NO |  | 64 |
| public | membership_review | subject_role | varchar | NO |  | 16 |
| public | membership_review | subject_user_id | uuid | NO |  |  |
| public | membership_review | source_event_id | uuid | NO |  |  |
| public | membership_review | raised_at | timestamptz | NO |  |  |
| public | membership_review | resolved_at | timestamptz | YES |  |  |
| public | membership_review | resolved_by_user_id | uuid | YES |  |  |
| public | membership_review | resolution_note | varchar | YES |  | 500 |
| public | school | school_id | uuid | NO |  |  |
| public | school | name | varchar | NO |  | 200 |
| public | school | status | sm_status | NO | 'Active'::sm_status |  |
| public | school | revision | int8 | NO | 1 |  |
| public | school | created_at | timestamptz | NO |  |  |
| public | school | updated_at | timestamptz | NO |  |  |
| public | school_coordination | operation_id | uuid | NO |  |  |
| public | school_coordination | school_id | uuid | NO |  |  |
| public | school_coordination | fingerprint | text | NO |  |  |
| public | school_coordination | command_json | text | NO |  |  |
| public | school_coordination | transition_json | text | NO |  |  |
| public | school_coordination | payload_hash | text | NO |  |  |
| public | school_coordination | state | text | NO |  |  |
| public | school_coordination | before_revision | int8 | NO |  |  |
| public | school_coordination | after_revision | int8 | NO |  |  |
| public | school_coordination | effective_from | timestamptz | NO |  |  |
| public | school_coordination | actor_user_id | uuid | NO |  |  |
| public | school_coordination | result_id | uuid | NO |  |  |
| public | school_coordination | lease_id | uuid | YES |  |  |
| public | school_coordination | lease_until | timestamptz | YES |  |  |
| public | school_invitation | invitation_id | uuid | NO |  |  |
| public | school_invitation | school_id | uuid | NO |  |  |
| public | school_invitation | target_user_id | uuid | NO |  |  |
| public | school_invitation | role | sm_role | NO |  |  |
| public | school_invitation | category_code | varchar | YES |  | 20 |
| public | school_invitation | issuer_membership_id | uuid | YES |  |  |
| public | school_invitation | status | sm_invitation_status | NO | 'Pending'::sm_invitation_status |  |
| public | school_invitation | revision | int8 | NO | 1 |  |
| public | school_invitation | created_at | timestamptz | NO |  |  |
| public | school_invitation | expires_at | timestamptz | NO |  |  |
| public | school_invitation | issued_operation_id | uuid | NO |  |  |
| public | school_invitation | accepted_operation_id | uuid | YES |  |  |
| public | school_invitation | accepted_at | timestamptz | YES |  |  |
| public | school_invitation | result_membership_id | uuid | YES |  |  |
| public | school_invitation | result_enrollment_id | uuid | YES |  |  |
| public | school_invitation | revoked_operation_id | uuid | YES |  |  |
| public | school_invitation | revoked_at | timestamptz | YES |  |  |
| public | school_learning_outbox | id | uuid | NO |  |  |
| public | school_learning_outbox | school_id | uuid | NO |  |  |
| public | school_learning_outbox | aggregate_id | uuid | NO |  |  |
| public | school_learning_outbox | aggregate_version | int8 | NO |  |  |
| public | school_learning_outbox | event_type | text | NO |  |  |
| public | school_learning_outbox | payload | text | NO |  |  |
| public | school_learning_outbox | correlation_id | text | NO |  |  |
| public | school_learning_outbox | occurred_at | timestamptz | NO |  |  |
| public | school_learning_outbox | sent_at | timestamptz | YES |  |  |
| public | school_learning_outbox | lease_id | uuid | YES |  |  |
| public | school_learning_outbox | lease_until | timestamptz | YES |  |  |
| public | school_learning_outbox | attempts | int4 | NO |  |  |
| public | school_learning_outbox | next_attempt_at | timestamptz | NO |  |  |
| public | school_membership | membership_id | uuid | NO |  |  |
| public | school_membership | school_id | uuid | NO |  |  |
| public | school_membership | user_id | uuid | NO |  |  |
| public | school_membership | role | sm_role | NO |  |  |
| public | school_membership | started_at | timestamptz | NO |  |  |
| public | school_membership | ended_at | timestamptz | YES |  |  |
| public | school_membership | revision | int8 | NO | 1 |  |
| public | school_membership | last_operation_id | uuid | NO |  |  |
| public | school_operation | operation_id | uuid | NO |  |  |
| public | school_operation | school_id | uuid | NO |  |  |
| public | school_operation | command_name | varchar | NO |  | 80 |
| public | school_operation | target_kind | varchar | NO |  | 60 |
| public | school_operation | target_id | uuid | NO |  |  |
| public | school_operation | expected_revision | int8 | YES |  |  |
| public | school_operation | resulting_revision | int8 | YES |  |  |
| public | school_operation | coordination_required | bool | NO | false |  |
| public | school_operation | expected_school_revision | int8 | YES |  |  |
| public | school_operation | resulting_school_revision | int8 | YES |  |  |
| public | school_operation | actor_user_id | uuid | NO |  |  |
| public | school_operation | channel | sm_channel | NO |  |  |
| public | school_operation | status | sm_operation_status | NO |  |  |
| public | school_operation | request_fingerprint | varchar | NO |  | 64 |
| public | school_operation | requested_at | timestamptz | NO |  |  |
| public | school_operation | resolved_at | timestamptz | YES |  |  |
| public | school_operation | reason | text | YES |  |  |
| public | school_operation | outcome_code | varchar | YES |  | 80 |
| public | school_operation | authority_basis | varchar | NO |  | 200 |
| public | school_operation | confirmation_id | uuid | YES |  |  |
| public | school_operation | confirmed_at | timestamptz | YES |  |  |
| public | student_enrollment | enrollment_id | uuid | NO |  |  |
| public | student_enrollment | school_id | uuid | NO |  |  |
| public | student_enrollment | student_id | uuid | NO |  |  |
| public | student_enrollment | category_code | varchar | NO |  | 20 |
| public | student_enrollment | started_at | timestamptz | NO |  |  |
| public | student_enrollment | ended_at | timestamptz | YES |  |  |
| public | student_enrollment | status | sm_enrollment_status | NO | 'Active'::sm_enrollment_status |  |
| public | student_enrollment | status_changed_at | timestamptz | NO | clock_timestamp() |  |
| public | student_enrollment | revision | int8 | NO | 1 |  |
| public | student_enrollment | last_operation_id | uuid | NO |  |  |
| public | student_group_membership | membership_id | uuid | NO |  |  |
| public | student_group_membership | school_id | uuid | NO |  |  |
| public | student_group_membership | enrollment_id | uuid | NO |  |  |
| public | student_group_membership | group_id | uuid | NO |  |  |
| public | student_group_membership | joined_at | timestamptz | NO |  |  |
| public | student_group_membership | left_at | timestamptz | YES |  |  |
| public | student_group_membership | association_program_version_id | uuid | NO |  |  |
| public | student_group_membership | association_verified_at | timestamptz | NO |  |  |
| public | student_group_membership | revision | int8 | NO | 1 |  |
| public | student_group_membership | last_operation_id | uuid | NO |  |  |
| public | teacher_group_assignment | assignment_id | uuid | NO |  |  |
| public | teacher_group_assignment | school_id | uuid | NO |  |  |
| public | teacher_group_assignment | teacher_id | uuid | NO |  |  |
| public | teacher_group_assignment | group_id | uuid | NO |  |  |
| public | teacher_group_assignment | assigned_at | timestamptz | NO |  |  |
| public | teacher_group_assignment | ended_at | timestamptz | YES |  |  |
| public | teacher_group_assignment | revision | int8 | NO | 1 |  |
| public | teacher_group_assignment | last_operation_id | uuid | NO |  |  |
| public | training_group | group_id | uuid | NO |  |  |
| public | training_group | school_id | uuid | NO |  |  |
| public | training_group | branch_id | uuid | YES |  |  |
| public | training_group | name | varchar | NO |  | 200 |
| public | training_group | category_code | varchar | YES |  | 20 |
| public | training_group | started_at | timestamptz | NO |  |  |
| public | training_group | ended_at | timestamptz | YES |  |  |
| public | training_group | revision | int8 | NO | 1 |  |
| public | training_group | membership_revision | int8 | NO | 1 |  |
| public | training_group | last_operation_id | uuid | NO |  |  |

## Physical constraints

| Schema / table | Name | Definition |
|---|---|---|
| public.__EFMigrationsHistory | PK___EFMigrationsHistory | PRIMARY KEY ("MigrationId") |
| public.branch | branch_last_operation_id_school_id_fkey | FOREIGN KEY (last_operation_id, school_id) REFERENCES school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE |
| public.branch | branch_name_revision | CHECK (((length(TRIM(BOTH FROM name)) > 0) AND (revision > 0))) |
| public.branch | branch_pkey | PRIMARY KEY (branch_id, school_id) |
| public.branch | branch_school_id_fkey | FOREIGN KEY (school_id) REFERENCES school(school_id) ON DELETE RESTRICT DEFERRABLE |
| public.enrollment_status_history | completion_basis_required | CHECK (((to_status <> 'Completed'::sm_enrollment_status) OR ((completion_evidence_id IS NOT NULL) AND (completion_dependency_revision IS NOT NULL) AND (completion_dependency_revision > 0) AND (completion_verified_at IS NOT NULL)))) |
| public.enrollment_status_history | enrollment_history_immediate_terminal | CHECK ((isfinite(effective_at) AND isfinite(recorded_at) AND ((to_status = 'Active'::sm_enrollment_status) OR (effective_at = recorded_at)))) |
| public.enrollment_status_history | enrollment_history_revision | CHECK ((enrollment_revision > 0)) |
| public.enrollment_status_history | enrollment_history_transition | CHECK ((((from_status IS NULL) AND (to_status = 'Active'::sm_enrollment_status)) OR ((from_status IS NOT NULL) AND (from_status = 'Active'::sm_enrollment_status) AND (to_status <> 'Active'::sm_enrollment_status)))) |
| public.enrollment_status_history | enrollment_status_history_enrollment_id_school_id_fkey | FOREIGN KEY (enrollment_id, school_id) REFERENCES student_enrollment(enrollment_id, school_id) ON DELETE RESTRICT DEFERRABLE |
| public.enrollment_status_history | enrollment_status_history_operation_id_school_id_fkey | FOREIGN KEY (operation_id, school_id) REFERENCES school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE |
| public.enrollment_status_history | enrollment_status_history_pkey | PRIMARY KEY (enrollment_id, school_id, enrollment_revision) |
| public.group_roster_member | group_roster_member_group_id_school_id_membership_revision_fkey | FOREIGN KEY (group_id, school_id, membership_revision) REFERENCES group_roster_revision(group_id, school_id, membership_revision) ON DELETE RESTRICT DEFERRABLE |
| public.group_roster_member | group_roster_member_membership_id_school_id_group_id_enrol_fkey | FOREIGN KEY (membership_id, school_id, group_id, enrollment_id) REFERENCES student_group_membership(membership_id, school_id, group_id, enrollment_id) ON DELETE RESTRICT DEFERRABLE |
| public.group_roster_member | group_roster_member_pkey | PRIMARY KEY (group_id, school_id, membership_revision, membership_id) |
| public.group_roster_member | roster_enrollment_basis | CHECK (((enrollment_revision > 0) AND (length(TRIM(BOTH FROM category_code)) > 0))) |
| public.group_roster_member | roster_enrollment_period | CHECK (((enrollment_ended_at IS NULL) OR (enrollment_ended_at > enrollment_started_at))) |
| public.group_roster_member | roster_enrollment_shape | CHECK ((((enrollment_status = 'Active'::sm_enrollment_status) AND (enrollment_ended_at IS NULL)) OR ((enrollment_status <> 'Active'::sm_enrollment_status) AND (enrollment_ended_at IS NOT NULL)))) |
| public.group_roster_member | roster_membership_period | CHECK (((left_at IS NULL) OR (left_at > joined_at))) |
| public.group_roster_revision | group_roster_revision_group_id_school_id_fkey | FOREIGN KEY (group_id, school_id) REFERENCES training_group(group_id, school_id) ON DELETE RESTRICT DEFERRABLE |
| public.group_roster_revision | group_roster_revision_operation_id_school_id_fkey | FOREIGN KEY (operation_id, school_id) REFERENCES school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE |
| public.group_roster_revision | group_roster_revision_pkey | PRIMARY KEY (group_id, school_id, membership_revision) |
| public.group_roster_revision | roster_revision_positive | CHECK ((membership_revision > 0)) |
| public.integration_inbox | PK_integration_inbox | PRIMARY KEY (event_id) |
| public.integration_inbox | integration_inbox_fingerprint | CHECK (((fingerprint)::text ~ '^[0-9a-f]{64}$'::text)) |
| public.integration_inbox | integration_inbox_reviews | CHECK ((reviews_raised >= 0)) |
| public.membership_permission_grant | grant_end_evidence | CHECK (((ended_at IS NULL) = (ended_operation_id IS NULL))) |
| public.membership_permission_grant | grant_period | CHECK (((ended_at IS NULL) OR (ended_at > started_at))) |
| public.membership_permission_grant | membership_permission_grant_ended_operation_id_school_id_fkey | FOREIGN KEY (ended_operation_id, school_id) REFERENCES school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE |
| public.membership_permission_grant | membership_permission_grant_granted_operation_id_school_id_fkey | FOREIGN KEY (granted_operation_id, school_id) REFERENCES school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE |
| public.membership_permission_grant | membership_permission_grant_membership_id_school_id_fkey | FOREIGN KEY (membership_id, school_id) REFERENCES school_membership(membership_id, school_id) ON DELETE RESTRICT DEFERRABLE |
| public.membership_permission_grant | membership_permission_grant_pkey | PRIMARY KEY (grant_id, school_id) |
| public.membership_permission_grant | sm_grant_finite | CHECK ((isfinite(started_at) AND ((ended_at IS NULL) OR isfinite(ended_at)))) |
| public.membership_permission_grant | sm_grant_no_overlap | EXCLUDE USING gist (school_id WITH =, membership_id WITH =, permission WITH =, tstzrange(started_at, ended_at, '[)'::text) WITH &&) |
| public.membership_review | PK_membership_review | PRIMARY KEY (review_id) |
| public.membership_review | membership_review_resolution | CHECK ((((resolved_at IS NULL) = (resolved_by_user_id IS NULL)) AND ((resolved_at IS NULL) = (resolution_note IS NULL)) AND ((resolved_at IS NULL) OR (resolved_at >= raised_at)))) |
| public.membership_review | membership_review_role | CHECK (((subject_role)::text = ANY ((ARRAY['Student'::character varying, 'Teacher'::character varying, 'Administrator'::character varying])::text[]))) |
| public.membership_review | membership_review_target | CHECK (((target_kind)::text = ANY ((ARRAY['Membership'::character varying, 'Enrollment'::character varying])::text[]))) |
| public.school | school_name_nonempty | CHECK ((length(TRIM(BOTH FROM name)) > 0)) |
| public.school | school_pkey | PRIMARY KEY (school_id) |
| public.school | school_revision_time | CHECK (((revision > 0) AND (updated_at >= created_at))) |
| public.school_coordination | PK_school_coordination | PRIMARY KEY (operation_id, school_id) |
| public.school_invitation | invitation_accept_time | CHECK (((accepted_at IS NULL) OR (isfinite(accepted_at) AND (accepted_at >= created_at) AND (accepted_at < expires_at)))) |
| public.school_invitation | invitation_admin_platform_basis | CHECK (((role <> 'Administrator'::sm_role) OR (issuer_membership_id IS NULL))) |
| public.school_invitation | invitation_category_shape | CHECK ((((role = 'Student'::sm_role) AND (category_code IS NOT NULL) AND (length(TRIM(BOTH FROM category_code)) > 0)) OR ((role <> 'Student'::sm_role) AND (category_code IS NULL)))) |
| public.school_invitation | invitation_revision_expiry | CHECK (((revision > 0) AND isfinite(created_at) AND isfinite(expires_at) AND (expires_at > created_at))) |
| public.school_invitation | invitation_revoke_time | CHECK (((revoked_at IS NULL) OR (isfinite(revoked_at) AND (revoked_at >= created_at)))) |
| public.school_invitation | invitation_state_shape | CHECK ((((status = 'Pending'::sm_invitation_status) AND (accepted_operation_id IS NULL) AND (accepted_at IS NULL) AND (result_membership_id IS NULL) AND (result_enrollment_id IS NULL) AND (revoked_operation_id IS NULL) AND (revoked_at IS NULL)) OR ((status = 'Accepted'::sm_invitation_status) AND (accepted_operation_id IS NOT NULL) AND (accepted_at IS NOT NULL) AND (result_membership_id IS NOT NULL) AND (revoked_operation_id IS NULL) AND (revoked_at IS NULL) AND (((role = 'Student'::sm_role) AND (result_enrollment_id IS NOT NULL)) OR ((role <> 'Student'::sm_role) AND (result_enrollment_id IS NULL)))) OR ((status = 'Revoked'::sm_invitation_status) AND (revoked_operation_id IS NOT NULL) AND (revoked_at IS NOT NULL) AND (accepted_operation_id IS NULL) AND (accepted_at IS NULL) AND (result_membership_id IS NULL) AND (result_enrollment_id IS NULL)))) |
| public.school_invitation | school_invitation_accepted_operation_id_school_id_fkey | FOREIGN KEY (accepted_operation_id, school_id) REFERENCES school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE |
| public.school_invitation | school_invitation_issued_operation_id_school_id_fkey | FOREIGN KEY (issued_operation_id, school_id) REFERENCES school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE |
| public.school_invitation | school_invitation_issuer_membership_id_school_id_fkey | FOREIGN KEY (issuer_membership_id, school_id) REFERENCES school_membership(membership_id, school_id) ON DELETE RESTRICT DEFERRABLE |
| public.school_invitation | school_invitation_pkey | PRIMARY KEY (invitation_id, school_id) |
| public.school_invitation | school_invitation_result_enrollment_id_school_id_fkey | FOREIGN KEY (result_enrollment_id, school_id) REFERENCES student_enrollment(enrollment_id, school_id) ON DELETE RESTRICT DEFERRABLE |
| public.school_invitation | school_invitation_result_membership_id_school_id_fkey | FOREIGN KEY (result_membership_id, school_id) REFERENCES school_membership(membership_id, school_id) ON DELETE RESTRICT DEFERRABLE |
| public.school_invitation | school_invitation_revoked_operation_id_school_id_fkey | FOREIGN KEY (revoked_operation_id, school_id) REFERENCES school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE |
| public.school_invitation | school_invitation_school_id_fkey | FOREIGN KEY (school_id) REFERENCES school(school_id) ON DELETE RESTRICT DEFERRABLE |
| public.school_learning_outbox | PK_school_learning_outbox | PRIMARY KEY (id) |
| public.school_membership | membership_period | CHECK (((ended_at IS NULL) OR (ended_at > started_at))) |
| public.school_membership | membership_revision | CHECK ((revision > 0)) |
| public.school_membership | school_membership_last_operation_id_school_id_fkey | FOREIGN KEY (last_operation_id, school_id) REFERENCES school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE |
| public.school_membership | school_membership_pkey | PRIMARY KEY (membership_id, school_id) |
| public.school_membership | school_membership_school_id_fkey | FOREIGN KEY (school_id) REFERENCES school(school_id) ON DELETE RESTRICT DEFERRABLE |
| public.school_membership | sm_membership_finite | CHECK ((isfinite(started_at) AND ((ended_at IS NULL) OR isfinite(ended_at)))) |
| public.school_membership | sm_membership_no_overlap | EXCLUDE USING gist (school_id WITH =, user_id WITH =, role WITH =, tstzrange(started_at, ended_at, '[)'::text) WITH &&) |
| public.school_operation | operation_confirmation_pair | CHECK (((confirmation_id IS NULL) = (confirmed_at IS NULL))) |
| public.school_operation | operation_coordinated_commit | CHECK (((status <> 'Committed'::sm_operation_status) OR (coordination_required = false) OR (resulting_school_revision IS NOT NULL))) |
| public.school_operation | operation_coordination_revisions | CHECK ((((coordination_required = false) AND (expected_school_revision IS NULL) AND (resulting_school_revision IS NULL)) OR ((coordination_required = true) AND (expected_school_revision IS NOT NULL) AND (expected_school_revision > 0) AND ((resulting_school_revision IS NULL) OR (resulting_school_revision = (expected_school_revision + 1)))))) |
| public.school_operation | operation_expected_revision | CHECK (((expected_revision IS NULL) OR (expected_revision > 0))) |
| public.school_operation | operation_mcp_confirmation | CHECK (((status <> 'Committed'::sm_operation_status) OR (channel <> 'MCP'::sm_channel) OR (confirmation_id IS NOT NULL))) |
| public.school_operation | operation_required_metadata | CHECK (((length(TRIM(BOTH FROM command_name)) > 0) AND (length(TRIM(BOTH FROM authority_basis)) > 0) AND (length((request_fingerprint)::text) = 64))) |
| public.school_operation | operation_resolution_shape | CHECK ((((status = ANY (ARRAY['Committed'::sm_operation_status, 'Rejected'::sm_operation_status])) AND (resolved_at IS NOT NULL)) OR ((status = ANY (ARRAY['Pending'::sm_operation_status, 'ReconciliationPending'::sm_operation_status])) AND (resolved_at IS NULL)))) |
| public.school_operation | operation_resolution_time | CHECK (((resolved_at IS NULL) OR (resolved_at >= requested_at))) |
| public.school_operation | operation_result_revision | CHECK (((resulting_revision IS NULL) OR (resulting_revision > 0))) |
| public.school_operation | school_operation_pkey | PRIMARY KEY (operation_id, school_id) |
| public.school_operation | school_operation_school_id_fkey | FOREIGN KEY (school_id) REFERENCES school(school_id) ON DELETE RESTRICT DEFERRABLE |
| public.student_enrollment | enrollment_category_revision | CHECK (((length(TRIM(BOTH FROM category_code)) > 0) AND (revision > 0))) |
| public.student_enrollment | enrollment_finite_lifecycle | CHECK ((isfinite(started_at) AND isfinite(status_changed_at) AND ((ended_at IS NULL) OR isfinite(ended_at)))) |
| public.student_enrollment | enrollment_lifecycle_shape | CHECK ((((status = 'Active'::sm_enrollment_status) AND (ended_at IS NULL)) OR ((status <> 'Active'::sm_enrollment_status) AND (ended_at IS NOT NULL) AND (ended_at = status_changed_at)))) |
| public.student_enrollment | enrollment_period | CHECK (((ended_at IS NULL) OR (ended_at > started_at))) |
| public.student_enrollment | student_enrollment_last_operation_id_school_id_fkey | FOREIGN KEY (last_operation_id, school_id) REFERENCES school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE |
| public.student_enrollment | student_enrollment_pkey | PRIMARY KEY (enrollment_id, school_id) |
| public.student_enrollment | student_enrollment_school_id_fkey | FOREIGN KEY (school_id) REFERENCES school(school_id) ON DELETE RESTRICT DEFERRABLE |
| public.student_group_membership | association_revision | CHECK ((revision > 0)) |
| public.student_group_membership | sm_student_group_finite | CHECK ((isfinite(joined_at) AND ((left_at IS NULL) OR isfinite(left_at)))) |
| public.student_group_membership | sm_student_group_no_overlap | EXCLUDE USING gist (school_id WITH =, enrollment_id WITH =, group_id WITH =, tstzrange(joined_at, left_at, '[)'::text) WITH &&) |
| public.student_group_membership | student_group_membership_enrollment_id_school_id_fkey | FOREIGN KEY (enrollment_id, school_id) REFERENCES student_enrollment(enrollment_id, school_id) ON DELETE RESTRICT DEFERRABLE |
| public.student_group_membership | student_group_membership_group_id_school_id_fkey | FOREIGN KEY (group_id, school_id) REFERENCES training_group(group_id, school_id) ON DELETE RESTRICT DEFERRABLE |
| public.student_group_membership | student_group_membership_last_operation_id_school_id_fkey | FOREIGN KEY (last_operation_id, school_id) REFERENCES school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE |
| public.student_group_membership | student_group_membership_pkey | PRIMARY KEY (membership_id, school_id) |
| public.student_group_membership | student_group_period | CHECK (((left_at IS NULL) OR (left_at > joined_at))) |
| public.teacher_group_assignment | sm_teacher_group_finite | CHECK ((isfinite(assigned_at) AND ((ended_at IS NULL) OR isfinite(ended_at)))) |
| public.teacher_group_assignment | sm_teacher_group_no_overlap | EXCLUDE USING gist (school_id WITH =, teacher_id WITH =, group_id WITH =, tstzrange(assigned_at, ended_at, '[)'::text) WITH &&) |
| public.teacher_group_assignment | teacher_assignment_period | CHECK (((ended_at IS NULL) OR (ended_at > assigned_at))) |
| public.teacher_group_assignment | teacher_assignment_revision | CHECK ((revision > 0)) |
| public.teacher_group_assignment | teacher_group_assignment_group_id_school_id_fkey | FOREIGN KEY (group_id, school_id) REFERENCES training_group(group_id, school_id) ON DELETE RESTRICT DEFERRABLE |
| public.teacher_group_assignment | teacher_group_assignment_last_operation_id_school_id_fkey | FOREIGN KEY (last_operation_id, school_id) REFERENCES school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE |
| public.teacher_group_assignment | teacher_group_assignment_pkey | PRIMARY KEY (assignment_id, school_id) |
| public.training_group | group_name_revisions | CHECK (((length(TRIM(BOTH FROM name)) > 0) AND (revision > 0) AND (membership_revision > 0))) |
| public.training_group | group_optional_category | CHECK (((category_code IS NULL) OR (length(TRIM(BOTH FROM category_code)) > 0))) |
| public.training_group | group_period | CHECK (((ended_at IS NULL) OR (ended_at > started_at))) |
| public.training_group | training_group_branch_id_school_id_fkey | FOREIGN KEY (branch_id, school_id) REFERENCES branch(branch_id, school_id) ON DELETE RESTRICT DEFERRABLE |
| public.training_group | training_group_last_operation_id_school_id_fkey | FOREIGN KEY (last_operation_id, school_id) REFERENCES school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE |
| public.training_group | training_group_pkey | PRIMARY KEY (group_id, school_id) |
| public.training_group | training_group_school_id_fkey | FOREIGN KEY (school_id) REFERENCES school(school_id) ON DELETE RESTRICT DEFERRABLE |

## Indexes

| Schema / table | Index | Definition |
|---|---|---|
| public.__EFMigrationsHistory | PK___EFMigrationsHistory | CREATE UNIQUE INDEX "PK___EFMigrationsHistory" ON public."__EFMigrationsHistory" USING btree ("MigrationId") |
| public.branch | branch_pkey | CREATE UNIQUE INDEX branch_pkey ON public.branch USING btree (branch_id, school_id) |
| public.enrollment_status_history | enrollment_status_history_pkey | CREATE UNIQUE INDEX enrollment_status_history_pkey ON public.enrollment_status_history USING btree (enrollment_id, school_id, enrollment_revision) |
| public.group_roster_member | group_roster_member_pkey | CREATE UNIQUE INDEX group_roster_member_pkey ON public.group_roster_member USING btree (group_id, school_id, membership_revision, membership_id) |
| public.group_roster_revision | group_roster_revision_pkey | CREATE UNIQUE INDEX group_roster_revision_pkey ON public.group_roster_revision USING btree (group_id, school_id, membership_revision) |
| public.integration_inbox | PK_integration_inbox | CREATE UNIQUE INDEX "PK_integration_inbox" ON public.integration_inbox USING btree (event_id) |
| public.membership_permission_grant | membership_permission_grant_membership_id_school_id_permiss_idx | CREATE INDEX membership_permission_grant_membership_id_school_id_permiss_idx ON public.membership_permission_grant USING btree (membership_id, school_id, permission, started_at) |
| public.membership_permission_grant | membership_permission_grant_pkey | CREATE UNIQUE INDEX membership_permission_grant_pkey ON public.membership_permission_grant USING btree (grant_id, school_id) |
| public.membership_permission_grant | sm_grant_no_overlap | CREATE INDEX sm_grant_no_overlap ON public.membership_permission_grant USING gist (school_id, membership_id, permission, tstzrange(started_at, ended_at, '[)'::text)) |
| public.membership_review | IX_membership_review_school_id_resolved_at | CREATE INDEX "IX_membership_review_school_id_resolved_at" ON public.membership_review USING btree (school_id, resolved_at) |
| public.membership_review | IX_membership_review_source_event_id_target_kind_target_id | CREATE UNIQUE INDEX "IX_membership_review_source_event_id_target_kind_target_id" ON public.membership_review USING btree (source_event_id, target_kind, target_id) |
| public.membership_review | PK_membership_review | CREATE UNIQUE INDEX "PK_membership_review" ON public.membership_review USING btree (review_id) |
| public.school | school_pkey | CREATE UNIQUE INDEX school_pkey ON public.school USING btree (school_id) |
| public.school_coordination | PK_school_coordination | CREATE UNIQUE INDEX "PK_school_coordination" ON public.school_coordination USING btree (operation_id, school_id) |
| public.school_invitation | school_invitation_accepted_operation_id_school_id_idx | CREATE UNIQUE INDEX school_invitation_accepted_operation_id_school_id_idx ON public.school_invitation USING btree (accepted_operation_id, school_id) |
| public.school_invitation | school_invitation_issued_operation_id_school_id_idx | CREATE UNIQUE INDEX school_invitation_issued_operation_id_school_id_idx ON public.school_invitation USING btree (issued_operation_id, school_id) |
| public.school_invitation | school_invitation_pkey | CREATE UNIQUE INDEX school_invitation_pkey ON public.school_invitation USING btree (invitation_id, school_id) |
| public.school_invitation | school_invitation_revoked_operation_id_school_id_idx | CREATE UNIQUE INDEX school_invitation_revoked_operation_id_school_id_idx ON public.school_invitation USING btree (revoked_operation_id, school_id) |
| public.school_invitation | school_invitation_school_id_target_user_id_status_expires_a_idx | CREATE INDEX school_invitation_school_id_target_user_id_status_expires_a_idx ON public.school_invitation USING btree (school_id, target_user_id, status, expires_at) |
| public.school_learning_outbox | IX_school_learning_outbox_sent_at_next_attempt_at | CREATE INDEX "IX_school_learning_outbox_sent_at_next_attempt_at" ON public.school_learning_outbox USING btree (sent_at, next_attempt_at) |
| public.school_learning_outbox | PK_school_learning_outbox | CREATE UNIQUE INDEX "PK_school_learning_outbox" ON public.school_learning_outbox USING btree (id) |
| public.school_membership | school_membership_pkey | CREATE UNIQUE INDEX school_membership_pkey ON public.school_membership USING btree (membership_id, school_id) |
| public.school_membership | school_membership_school_id_user_id_role_started_at_idx | CREATE INDEX school_membership_school_id_user_id_role_started_at_idx ON public.school_membership USING btree (school_id, user_id, role, started_at) |
| public.school_membership | sm_membership_no_overlap | CREATE INDEX sm_membership_no_overlap ON public.school_membership USING gist (school_id, user_id, role, tstzrange(started_at, ended_at, '[)'::text)) |
| public.school_operation | school_operation_pkey | CREATE UNIQUE INDEX school_operation_pkey ON public.school_operation USING btree (operation_id, school_id) |
| public.school_operation | school_operation_school_id_target_kind_target_id_requested__idx | CREATE INDEX school_operation_school_id_target_kind_target_id_requested__idx ON public.school_operation USING btree (school_id, target_kind, target_id, requested_at) |
| public.school_operation | sm_one_unresolved_coordination_per_school | CREATE UNIQUE INDEX sm_one_unresolved_coordination_per_school ON public.school_operation USING btree (school_id) WHERE (coordination_required AND (status = ANY (ARRAY['Pending'::sm_operation_status, 'ReconciliationPending'::sm_operation_status]))) |
| public.student_enrollment | sm_enrollment_global_identity | CREATE UNIQUE INDEX sm_enrollment_global_identity ON public.student_enrollment USING btree (enrollment_id) |
| public.student_enrollment | student_enrollment_pkey | CREATE UNIQUE INDEX student_enrollment_pkey ON public.student_enrollment USING btree (enrollment_id, school_id) |
| public.student_enrollment | student_enrollment_school_id_student_id_status_idx | CREATE INDEX student_enrollment_school_id_student_id_status_idx ON public.student_enrollment USING btree (school_id, student_id, status) |
| public.student_group_membership | sm_student_group_no_overlap | CREATE INDEX sm_student_group_no_overlap ON public.student_group_membership USING gist (school_id, enrollment_id, group_id, tstzrange(joined_at, left_at, '[)'::text)) |
| public.student_group_membership | student_group_membership_membership_id_school_id_group_id_e_idx | CREATE UNIQUE INDEX student_group_membership_membership_id_school_id_group_id_e_idx ON public.student_group_membership USING btree (membership_id, school_id, group_id, enrollment_id) |
| public.student_group_membership | student_group_membership_pkey | CREATE UNIQUE INDEX student_group_membership_pkey ON public.student_group_membership USING btree (membership_id, school_id) |
| public.student_group_membership | student_group_membership_school_id_enrollment_id_joined_at_idx | CREATE INDEX student_group_membership_school_id_enrollment_id_joined_at_idx ON public.student_group_membership USING btree (school_id, enrollment_id, joined_at) |
| public.student_group_membership | student_group_membership_school_id_group_id_joined_at_idx | CREATE INDEX student_group_membership_school_id_group_id_joined_at_idx ON public.student_group_membership USING btree (school_id, group_id, joined_at) |
| public.teacher_group_assignment | sm_teacher_group_no_overlap | CREATE INDEX sm_teacher_group_no_overlap ON public.teacher_group_assignment USING gist (school_id, teacher_id, group_id, tstzrange(assigned_at, ended_at, '[)'::text)) |
| public.teacher_group_assignment | teacher_group_assignment_pkey | CREATE UNIQUE INDEX teacher_group_assignment_pkey ON public.teacher_group_assignment USING btree (assignment_id, school_id) |
| public.teacher_group_assignment | teacher_group_assignment_school_id_group_id_assigned_at_idx | CREATE INDEX teacher_group_assignment_school_id_group_id_assigned_at_idx ON public.teacher_group_assignment USING btree (school_id, group_id, assigned_at) |
| public.teacher_group_assignment | teacher_group_assignment_school_id_teacher_id_assigned_at_idx | CREATE INDEX teacher_group_assignment_school_id_teacher_id_assigned_at_idx ON public.teacher_group_assignment USING btree (school_id, teacher_id, assigned_at) |
| public.training_group | training_group_pkey | CREATE UNIQUE INDEX training_group_pkey ON public.training_group USING btree (group_id, school_id) |

## Row-Level Security

| Schema / table | Enabled | Forced |
|---|---|---|
| public.__EFMigrationsHistory | False | False |
| public.membership_permission_grant | True | False |
| public.student_enrollment | True | False |
| public.integration_inbox | False | False |
| public.school | True | False |
| public.school_operation | True | False |
| public.branch | True | False |
| public.school_membership | True | False |
| public.enrollment_status_history | True | False |
| public.training_group | True | False |
| public.student_group_membership | True | False |
| public.membership_review | True | False |
| public.teacher_group_assignment | True | False |
| public.group_roster_revision | True | False |
| public.group_roster_member | True | False |
| public.school_invitation | True | False |
| public.school_coordination | True | False |
| public.school_learning_outbox | True | False |

Policy expressions and command/role restrictions are retained verbatim in `../schema/implemented-catalogue.json` and `../schema/implemented-schema.sql`. Schema DDL also contains functions and triggers enforcing integrity and audit invariants.
