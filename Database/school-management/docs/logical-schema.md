# School Management — Logical relational schema

Authority: D-045 plus explicitly proposed Round 2 refinements. [Canonical DBML](../schema/schema.dbml).

The [Mermaid diagram](../schema/database-erd.md) shows keys/FKs and representative attributes; full attributes/defaults/classification are in data-dictionary.md. 

Physical count: 13 domain tables, 137 columns, 31 local FK declarations. EF migration history, where present, is technical metadata, not a new aggregate.

## Relationships and optionality

| Parent key | Child FK | Required? | Cardinality / integrity |
|---|---|---|---|
| school(school_id) | school_invitation(school_id) | Yes | 0..N children per parent; restrict |
| school_membership(membership_id,school_id) | school_invitation(issuer_membership_id,school_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; restrict |
| school_operation(operation_id,school_id) | school_invitation(issued_operation_id,school_id) | Yes | 0..1 child per parent; restrict |
| school_operation(operation_id,school_id) | school_invitation(accepted_operation_id,school_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..1 child per parent; restrict |
| school_operation(operation_id,school_id) | school_invitation(revoked_operation_id,school_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..1 child per parent; restrict |
| school_membership(membership_id,school_id) | school_invitation(result_membership_id,school_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; restrict |
| student_enrollment(enrollment_id,school_id) | school_invitation(result_enrollment_id,school_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; restrict |
| school(school_id) | school_operation(school_id) | Yes | 0..N children per parent; restrict |
| school(school_id) | branch(school_id) | Yes | 0..N children per parent; restrict |
| school(school_id) | school_membership(school_id) | Yes | 0..N children per parent; restrict |
| school(school_id) | student_enrollment(school_id) | Yes | 0..N children per parent; restrict |
| school(school_id) | training_group(school_id) | Yes | 0..N children per parent; restrict |
| branch(branch_id,school_id) | training_group(branch_id,school_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; restrict |
| school_operation(operation_id,school_id) | branch(last_operation_id,school_id) | Yes | 0..N children per parent; restrict |
| school_operation(operation_id,school_id) | school_membership(last_operation_id,school_id) | Yes | 0..N children per parent; restrict |
| school_operation(operation_id,school_id) | student_enrollment(last_operation_id,school_id) | Yes | 0..N children per parent; restrict |
| school_operation(operation_id,school_id) | training_group(last_operation_id,school_id) | Yes | 0..N children per parent; restrict |
| school_membership(membership_id,school_id) | membership_permission_grant(membership_id,school_id) | Yes | 0..N children per parent; restrict |
| school_operation(operation_id,school_id) | membership_permission_grant(granted_operation_id,school_id) | Yes | 0..N children per parent; restrict |
| school_operation(operation_id,school_id) | membership_permission_grant(ended_operation_id,school_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; restrict |
| student_enrollment(enrollment_id,school_id) | enrollment_status_history(enrollment_id,school_id) | Yes | 0..N children per parent; restrict |
| school_operation(operation_id,school_id) | enrollment_status_history(operation_id,school_id) | Yes | 0..N children per parent; restrict |
| student_enrollment(enrollment_id,school_id) | student_group_membership(enrollment_id,school_id) | Yes | 0..N children per parent; restrict |
| training_group(group_id,school_id) | student_group_membership(group_id,school_id) | Yes | 0..N children per parent; restrict |
| school_operation(operation_id,school_id) | student_group_membership(last_operation_id,school_id) | Yes | 0..N children per parent; restrict |
| training_group(group_id,school_id) | teacher_group_assignment(group_id,school_id) | Yes | 0..N children per parent; restrict |
| school_operation(operation_id,school_id) | teacher_group_assignment(last_operation_id,school_id) | Yes | 0..N children per parent; restrict |
| training_group(group_id,school_id) | group_roster_revision(group_id,school_id) | Yes | 0..N children per parent; restrict |
| school_operation(operation_id,school_id) | group_roster_revision(operation_id,school_id) | Yes | 0..N children per parent; restrict |
| group_roster_revision(group_id,school_id,membership_revision) | group_roster_member(group_id,school_id,membership_revision) | Yes | 0..N children per parent; restrict |
| student_group_membership(membership_id,school_id,group_id,enrollment_id) | group_roster_member(membership_id,school_id,group_id,enrollment_id) | Yes | 0..N children per parent; restrict |

## Deployment/transaction source

[Install wrapper](../ddl/install.sql) is the only fresh-install entry. It references existing canonical SQL or the generated initial migration, not another service’s same-named schema.sql. [Security overlay](../security/database-roles.sql) follows schema creation; demo seeds run only under explicit test gates.

No previous production migration history was found/assumed. Reapplying raw initial DDL over a populated database is forbidden. Scheduling has a real EF migration/snapshot and no-op migration rerun check; other contexts use a fresh SQL baseline and require a separately reviewed differential upgrade if legacy data exists.

Current remote owner/API gaps do not by themselves invalidate relational design. They remain runtime/integration gates and cannot be proven by FK tests.

## Executable database rules beyond DBML

- branch.branch_last_operation_id_school_id_fkey: `FOREIGN KEY (last_operation_id, school_id) REFERENCES school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE`.
- branch.branch_name_revision: `CHECK (((length(TRIM(BOTH FROM name)) > 0) AND (revision > 0)))`.
- branch.branch_pkey: `PRIMARY KEY (branch_id, school_id)`.
- branch.branch_school_id_fkey: `FOREIGN KEY (school_id) REFERENCES school(school_id) ON DELETE RESTRICT DEFERRABLE`.
- enrollment_status_history.completion_basis_required: `CHECK (((to_status <> 'Completed'::sm_enrollment_status) OR ((completion_evidence_id IS NOT NULL) AND (completion_dependency_revision IS NOT NULL) AND (completion_dependency_revision > 0) AND (completion_verified_at IS NOT NULL))))`.
- enrollment_status_history.enrollment_history_immediate_terminal: `CHECK ((isfinite(effective_at) AND isfinite(recorded_at) AND ((to_status = 'Active'::sm_enrollment_status) OR (effective_at = recorded_at))))`.
- enrollment_status_history.enrollment_history_revision: `CHECK ((enrollment_revision > 0))`.
- enrollment_status_history.enrollment_history_transition: `CHECK ((((from_status IS NULL) AND (to_status = 'Active'::sm_enrollment_status)) OR ((from_status IS NOT NULL) AND (from_status = 'Active'::sm_enrollment_status) AND (to_status <> 'Active'::sm_enrollment_status))))`.
- enrollment_status_history.enrollment_status_history_enrollment_id_school_id_fkey: `FOREIGN KEY (enrollment_id, school_id) REFERENCES student_enrollment(enrollment_id, school_id) ON DELETE RESTRICT DEFERRABLE`.
- enrollment_status_history.enrollment_status_history_operation_id_school_id_fkey: `FOREIGN KEY (operation_id, school_id) REFERENCES school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE`.
- enrollment_status_history.enrollment_status_history_pkey: `PRIMARY KEY (enrollment_id, school_id, enrollment_revision)`.
- group_roster_member.group_roster_member_group_id_school_id_membership_revision_fkey: `FOREIGN KEY (group_id, school_id, membership_revision) REFERENCES group_roster_revision(group_id, school_id, membership_revision) ON DELETE RESTRICT DEFERRABLE`.
- group_roster_member.group_roster_member_membership_id_school_id_group_id_enrol_fkey: `FOREIGN KEY (membership_id, school_id, group_id, enrollment_id) REFERENCES student_group_membership(membership_id, school_id, group_id, enrollment_id) ON DELETE RESTRICT DEFERRABLE`.
- group_roster_member.group_roster_member_pkey: `PRIMARY KEY (group_id, school_id, membership_revision, membership_id)`.
- group_roster_member.roster_enrollment_basis: `CHECK (((enrollment_revision > 0) AND (length(TRIM(BOTH FROM category_code)) > 0)))`.
- group_roster_member.roster_enrollment_period: `CHECK (((enrollment_ended_at IS NULL) OR (enrollment_ended_at > enrollment_started_at)))`.
- group_roster_member.roster_enrollment_shape: `CHECK ((((enrollment_status = 'Active'::sm_enrollment_status) AND (enrollment_ended_at IS NULL)) OR ((enrollment_status <> 'Active'::sm_enrollment_status) AND (enrollment_ended_at IS NOT NULL))))`.
- group_roster_member.roster_membership_period: `CHECK (((left_at IS NULL) OR (left_at > joined_at)))`.
- group_roster_revision.group_roster_revision_group_id_school_id_fkey: `FOREIGN KEY (group_id, school_id) REFERENCES training_group(group_id, school_id) ON DELETE RESTRICT DEFERRABLE`.
- group_roster_revision.group_roster_revision_operation_id_school_id_fkey: `FOREIGN KEY (operation_id, school_id) REFERENCES school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE`.
- group_roster_revision.group_roster_revision_pkey: `PRIMARY KEY (group_id, school_id, membership_revision)`.
- group_roster_revision.roster_revision_positive: `CHECK ((membership_revision > 0))`.
- membership_permission_grant.grant_end_evidence: `CHECK (((ended_at IS NULL) = (ended_operation_id IS NULL)))`.
- membership_permission_grant.grant_period: `CHECK (((ended_at IS NULL) OR (ended_at > started_at)))`.
- membership_permission_grant.membership_permission_grant_ended_operation_id_school_id_fkey: `FOREIGN KEY (ended_operation_id, school_id) REFERENCES school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE`.
- membership_permission_grant.membership_permission_grant_granted_operation_id_school_id_fkey: `FOREIGN KEY (granted_operation_id, school_id) REFERENCES school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE`.
- membership_permission_grant.membership_permission_grant_membership_id_school_id_fkey: `FOREIGN KEY (membership_id, school_id) REFERENCES school_membership(membership_id, school_id) ON DELETE RESTRICT DEFERRABLE`.
- membership_permission_grant.membership_permission_grant_pkey: `PRIMARY KEY (grant_id, school_id)`.
- membership_permission_grant.sm_grant_finite: `CHECK ((isfinite(started_at) AND ((ended_at IS NULL) OR isfinite(ended_at))))`.
- membership_permission_grant.sm_grant_no_overlap: `EXCLUDE USING gist (school_id WITH =, membership_id WITH =, permission WITH =, tstzrange(started_at, ended_at, '[)'::text) WITH &&)`.
- school.school_name_nonempty: `CHECK ((length(TRIM(BOTH FROM name)) > 0))`.
- school.school_pkey: `PRIMARY KEY (school_id)`.
- school.school_revision_time: `CHECK (((revision > 0) AND (updated_at >= created_at)))`.
- school_invitation.invitation_accept_time: `CHECK (((accepted_at IS NULL) OR (isfinite(accepted_at) AND (accepted_at >= created_at) AND (accepted_at < expires_at))))`.
- school_invitation.invitation_admin_platform_basis: `CHECK (((role <> 'Administrator'::sm_role) OR (issuer_membership_id IS NULL)))`.
- school_invitation.invitation_category_shape: `CHECK ((((role = 'Student'::sm_role) AND (category_code IS NOT NULL) AND (length(TRIM(BOTH FROM category_code)) > 0)) OR ((role <> 'Student'::sm_role) AND (category_code IS NULL))))`.
- school_invitation.invitation_revision_expiry: `CHECK (((revision > 0) AND isfinite(created_at) AND isfinite(expires_at) AND (expires_at > created_at)))`.
- school_invitation.invitation_revoke_time: `CHECK (((revoked_at IS NULL) OR (isfinite(revoked_at) AND (revoked_at >= created_at))))`.
- school_invitation.invitation_state_shape: `CHECK ((((status = 'Pending'::sm_invitation_status) AND (accepted_operation_id IS NULL) AND (accepted_at IS NULL) AND (result_membership_id IS NULL) AND (result_enrollment_id IS NULL) AND (revoked_operation_id IS NULL) AND (revoked_at IS NULL)) OR ((status = 'Accepted'::sm_invitation_status) AND (accepted_operation_id IS NOT NULL) AND (accepted_at IS NOT NULL) AND (result_membership_id IS NOT NULL) AND (revoked_operation_id IS NULL) AND (revoked_at IS NULL) AND (((role = 'Student'::sm_role) AND (result_enrollment_id IS NOT NULL)) OR ((role <> 'Student'::sm_role) AND (result_enrollment_id IS NULL)))) OR ((status = 'Revoked'::sm_invitation_status) AND (revoked_operation_id IS NOT NULL) AND (revoked_at IS NOT NULL) AND (accepted_operation_id IS NULL) AND (accepted_at IS NULL) AND (result_membership_id IS NULL) AND (result_enrollment_id IS NULL))))`.
- school_invitation.school_invitation_accepted_operation_id_school_id_fkey: `FOREIGN KEY (accepted_operation_id, school_id) REFERENCES school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE`.
- school_invitation.school_invitation_issued_operation_id_school_id_fkey: `FOREIGN KEY (issued_operation_id, school_id) REFERENCES school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE`.
- school_invitation.school_invitation_issuer_membership_id_school_id_fkey: `FOREIGN KEY (issuer_membership_id, school_id) REFERENCES school_membership(membership_id, school_id) ON DELETE RESTRICT DEFERRABLE`.
- school_invitation.school_invitation_pkey: `PRIMARY KEY (invitation_id, school_id)`.
- school_invitation.school_invitation_result_enrollment_id_school_id_fkey: `FOREIGN KEY (result_enrollment_id, school_id) REFERENCES student_enrollment(enrollment_id, school_id) ON DELETE RESTRICT DEFERRABLE`.
- school_invitation.school_invitation_result_membership_id_school_id_fkey: `FOREIGN KEY (result_membership_id, school_id) REFERENCES school_membership(membership_id, school_id) ON DELETE RESTRICT DEFERRABLE`.
- school_invitation.school_invitation_revoked_operation_id_school_id_fkey: `FOREIGN KEY (revoked_operation_id, school_id) REFERENCES school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE`.
- school_invitation.school_invitation_school_id_fkey: `FOREIGN KEY (school_id) REFERENCES school(school_id) ON DELETE RESTRICT DEFERRABLE`.
- school_membership.membership_period: `CHECK (((ended_at IS NULL) OR (ended_at > started_at)))`.
- school_membership.membership_revision: `CHECK ((revision > 0))`.
- school_membership.school_membership_last_operation_id_school_id_fkey: `FOREIGN KEY (last_operation_id, school_id) REFERENCES school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE`.
- school_membership.school_membership_pkey: `PRIMARY KEY (membership_id, school_id)`.
- school_membership.school_membership_school_id_fkey: `FOREIGN KEY (school_id) REFERENCES school(school_id) ON DELETE RESTRICT DEFERRABLE`.
- school_membership.sm_membership_finite: `CHECK ((isfinite(started_at) AND ((ended_at IS NULL) OR isfinite(ended_at))))`.
- school_membership.sm_membership_no_overlap: `EXCLUDE USING gist (school_id WITH =, user_id WITH =, role WITH =, tstzrange(started_at, ended_at, '[)'::text) WITH &&)`.
- school_operation.operation_confirmation_pair: `CHECK (((confirmation_id IS NULL) = (confirmed_at IS NULL)))`.
- school_operation.operation_coordinated_commit: `CHECK (((status <> 'Committed'::sm_operation_status) OR (coordination_required = false) OR (resulting_school_revision IS NOT NULL)))`.
- school_operation.operation_coordination_revisions: `CHECK ((((coordination_required = false) AND (expected_school_revision IS NULL) AND (resulting_school_revision IS NULL)) OR ((coordination_required = true) AND (expected_school_revision IS NOT NULL) AND (expected_school_revision > 0) AND ((resulting_school_revision IS NULL) OR (resulting_school_revision = (expected_school_revision + 1))))))`.
- school_operation.operation_expected_revision: `CHECK (((expected_revision IS NULL) OR (expected_revision > 0)))`.
- school_operation.operation_mcp_confirmation: `CHECK (((status <> 'Committed'::sm_operation_status) OR (channel <> 'MCP'::sm_channel) OR (confirmation_id IS NOT NULL)))`.
- school_operation.operation_required_metadata: `CHECK (((length(TRIM(BOTH FROM command_name)) > 0) AND (length(TRIM(BOTH FROM authority_basis)) > 0) AND (length((request_fingerprint)::text) = 64)))`.
- school_operation.operation_resolution_shape: `CHECK ((((status = ANY (ARRAY['Committed'::sm_operation_status, 'Rejected'::sm_operation_status])) AND (resolved_at IS NOT NULL)) OR ((status = ANY (ARRAY['Pending'::sm_operation_status, 'ReconciliationPending'::sm_operation_status])) AND (resolved_at IS NULL))))`.
- school_operation.operation_resolution_time: `CHECK (((resolved_at IS NULL) OR (resolved_at >= requested_at)))`.
- school_operation.operation_result_revision: `CHECK (((resulting_revision IS NULL) OR (resulting_revision > 0)))`.
- school_operation.school_operation_pkey: `PRIMARY KEY (operation_id, school_id)`.
- school_operation.school_operation_school_id_fkey: `FOREIGN KEY (school_id) REFERENCES school(school_id) ON DELETE RESTRICT DEFERRABLE`.
- student_enrollment.enrollment_category_revision: `CHECK (((length(TRIM(BOTH FROM category_code)) > 0) AND (revision > 0)))`.
- student_enrollment.enrollment_finite_lifecycle: `CHECK ((isfinite(started_at) AND isfinite(status_changed_at) AND ((ended_at IS NULL) OR isfinite(ended_at))))`.
- student_enrollment.enrollment_lifecycle_shape: `CHECK ((((status = 'Active'::sm_enrollment_status) AND (ended_at IS NULL)) OR ((status <> 'Active'::sm_enrollment_status) AND (ended_at IS NOT NULL) AND (ended_at = status_changed_at))))`.
- student_enrollment.enrollment_period: `CHECK (((ended_at IS NULL) OR (ended_at > started_at)))`.
- student_enrollment.student_enrollment_last_operation_id_school_id_fkey: `FOREIGN KEY (last_operation_id, school_id) REFERENCES school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE`.
- student_enrollment.student_enrollment_pkey: `PRIMARY KEY (enrollment_id, school_id)`.
- student_enrollment.student_enrollment_school_id_fkey: `FOREIGN KEY (school_id) REFERENCES school(school_id) ON DELETE RESTRICT DEFERRABLE`.
- student_group_membership.association_revision: `CHECK ((revision > 0))`.
- student_group_membership.sm_student_group_finite: `CHECK ((isfinite(joined_at) AND ((left_at IS NULL) OR isfinite(left_at))))`.
- student_group_membership.sm_student_group_no_overlap: `EXCLUDE USING gist (school_id WITH =, enrollment_id WITH =, group_id WITH =, tstzrange(joined_at, left_at, '[)'::text) WITH &&)`.
- student_group_membership.student_group_membership_enrollment_id_school_id_fkey: `FOREIGN KEY (enrollment_id, school_id) REFERENCES student_enrollment(enrollment_id, school_id) ON DELETE RESTRICT DEFERRABLE`.
- student_group_membership.student_group_membership_group_id_school_id_fkey: `FOREIGN KEY (group_id, school_id) REFERENCES training_group(group_id, school_id) ON DELETE RESTRICT DEFERRABLE`.
- student_group_membership.student_group_membership_last_operation_id_school_id_fkey: `FOREIGN KEY (last_operation_id, school_id) REFERENCES school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE`.
- student_group_membership.student_group_membership_pkey: `PRIMARY KEY (membership_id, school_id)`.
- student_group_membership.student_group_period: `CHECK (((left_at IS NULL) OR (left_at > joined_at)))`.
- teacher_group_assignment.sm_teacher_group_finite: `CHECK ((isfinite(assigned_at) AND ((ended_at IS NULL) OR isfinite(ended_at))))`.
- teacher_group_assignment.sm_teacher_group_no_overlap: `EXCLUDE USING gist (school_id WITH =, teacher_id WITH =, group_id WITH =, tstzrange(assigned_at, ended_at, '[)'::text) WITH &&)`.
- teacher_group_assignment.teacher_assignment_period: `CHECK (((ended_at IS NULL) OR (ended_at > assigned_at)))`.
- teacher_group_assignment.teacher_assignment_revision: `CHECK ((revision > 0))`.
- teacher_group_assignment.teacher_group_assignment_group_id_school_id_fkey: `FOREIGN KEY (group_id, school_id) REFERENCES training_group(group_id, school_id) ON DELETE RESTRICT DEFERRABLE`.
- teacher_group_assignment.teacher_group_assignment_last_operation_id_school_id_fkey: `FOREIGN KEY (last_operation_id, school_id) REFERENCES school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE`.
- teacher_group_assignment.teacher_group_assignment_pkey: `PRIMARY KEY (assignment_id, school_id)`.
- training_group.group_name_revisions: `CHECK (((length(TRIM(BOTH FROM name)) > 0) AND (revision > 0) AND (membership_revision > 0)))`.
- training_group.group_optional_category: `CHECK (((category_code IS NULL) OR (length(TRIM(BOTH FROM category_code)) > 0)))`.
- training_group.group_period: `CHECK (((ended_at IS NULL) OR (ended_at > started_at)))`.
- training_group.training_group_branch_id_school_id_fkey: `FOREIGN KEY (branch_id, school_id) REFERENCES branch(branch_id, school_id) ON DELETE RESTRICT DEFERRABLE`.
- training_group.training_group_last_operation_id_school_id_fkey: `FOREIGN KEY (last_operation_id, school_id) REFERENCES school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE`.
- training_group.training_group_pkey: `PRIMARY KEY (group_id, school_id)`.
- training_group.training_group_school_id_fkey: `FOREIGN KEY (school_id) REFERENCES school(school_id) ON DELETE RESTRICT DEFERRABLE`.
