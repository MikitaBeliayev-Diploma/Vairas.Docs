# School Management — Indexes and database rules

| Feature | Necessary? | Business/technical reason |
| --- | --- | --- |
| Indexes | Yes, existing | PK/UNIQUE candidate-key enforcement and actual scoped/temporal source lookups. No duplicate PK/UNIQUE indexes added. |
| Views | No new view | No approved repeated read/support/report query requires one in this database package. A view would not secure raw table access. |
| Triggers | Context dependent | Retain only existing cross-row, immutable/version/lifecycle guards. New RLS/grants do not duplicate transition logic. |
| Functions/procedures | Existing technical functions only | Trigger helpers / Auth refresh / Document activation where already designed. No solver/progress or ordinary service workflow moved into SQL. |
| Personal data masking | Synthetic demo + restricted access | No real records exported. Service-required raw data cannot be meaningfully masked for runtime. |

## Query/index inventory

- school: PK(school_id).
- school_operation: PK(operation_id,school_id).
- school_operation: INDEX(school_id,target_kind,target_id,requested_at).
- branch: PK(branch_id,school_id).
- school_membership: PK(membership_id,school_id).
- school_membership: INDEX(school_id,user_id,role,started_at).
- membership_permission_grant: PK(grant_id,school_id).
- membership_permission_grant: INDEX(membership_id,school_id,permission,started_at).
- student_enrollment: PK(enrollment_id,school_id).
- student_enrollment: UNIQUE(enrollment_id).
- student_enrollment: INDEX(school_id,student_id,status).
- enrollment_status_history: PK(enrollment_id,school_id,enrollment_revision).
- training_group: PK(group_id,school_id).
- student_group_membership: PK(membership_id,school_id).
- student_group_membership: UNIQUE(membership_id,school_id,group_id,enrollment_id).
- student_group_membership: INDEX(school_id,group_id,joined_at).
- student_group_membership: INDEX(school_id,enrollment_id,joined_at).
- teacher_group_assignment: PK(assignment_id,school_id).
- teacher_group_assignment: INDEX(school_id,group_id,assigned_at).
- teacher_group_assignment: INDEX(school_id,teacher_id,assigned_at).
- group_roster_revision: PK(group_id,school_id,membership_revision).
- group_roster_member: PK(group_id,school_id,membership_revision,membership_id).
- school_invitation: PK(invitation_id,school_id).
- school_invitation: UNIQUE(issued_operation_id,school_id).
- school_invitation: UNIQUE(accepted_operation_id,school_id).
- school_invitation: UNIQUE(revoked_operation_id,school_id).
- school_invitation: INDEX(school_id,target_user_id,status,expires_at).

Supplement: `Database/school-management/ddl/school-management-postgresql-constraints.sql`.

## Measurement boundaries

EXPLAIN JSON for a representative local query is stored in native evidence. Tiny fixtures may correctly choose sequential scan. No speedup/throughput claim or speculative extra index is made. Any future index needs a real predicate/cardinality/workload measurement.

Reference data: Not Applicable as a global fixed-table seed for this context. Existing enum/status domains are installed by DDL; school-owned templates/programmes/rules are business configuration, not invented global lookup rows. Demo configurations are explicitly synthetic and must not be promoted to legal/category authority.
