# User Management — Indexes and database rules

| Feature | Necessary? | Business/technical reason |
| --- | --- | --- |
| Indexes | Yes, existing | PK/UNIQUE candidate-key enforcement and actual scoped/temporal source lookups. No duplicate PK/UNIQUE indexes added. |
| Views | No new view | No approved repeated read/support/report query requires one in this database package. A view would not secure raw table access. |
| Triggers | Context dependent | Retain only existing cross-row, immutable/version/lifecycle guards. New RLS/grants do not duplicate transition logic. |
| Functions/procedures | Existing technical functions only | Trigger helpers / Auth refresh / Document activation where already designed. No solver/progress or ordinary service workflow moved into SQL. |
| Personal data masking | Synthetic demo + restricted access | No real records exported. Service-required raw data cannot be meaningfully masked for runtime. |

## Query/index inventory

- user_profile: PK(user_id).
- user_profile: UNIQUE(identity_id).
- student_profile: PK(student_id).
- student_profile: UNIQUE(user_id).
- teacher_profile: PK(teacher_id).
- teacher_profile: UNIQUE(user_id).
- administrator_profile: PK(administrator_id).
- administrator_profile: UNIQUE(user_id).
- profile_operation: PK(operation_id).
- profile_operation: INDEX(target_kind,target_id,recorded_at).
- outbox_message (technical): PK(event_id); partial INDEX(next_attempt_at,occurred_at) WHERE published_at IS NULL for eligible delivery claims.

## Measurement boundaries

EXPLAIN JSON for a representative local query is stored in native evidence. Tiny fixtures may correctly choose sequential scan. No speedup/throughput claim or speculative extra index is made. Any future index needs a real predicate/cardinality/workload measurement.

Reference data: Not Applicable as a global fixed-table seed for this context. Existing enum/status domains are installed by DDL; school-owned templates/programmes/rules are business configuration, not invented global lookup rows. Demo configurations are explicitly synthetic and must not be promoted to legal/category authority.
