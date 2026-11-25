> Baseline design reference. The [2026-11-24 implementation extension](implementation.md) records nine added columns, six reliability tables and current deployment/verification boundaries. The current combined schema is [DBML](../schema/schema.dbml).

# Scheduling — Indexes and database rules

| Feature | Necessary? | Business/technical reason |
| --- | --- | --- |
| Indexes | Yes, existing | PK/UNIQUE candidate-key enforcement and actual scoped/temporal source lookups. No duplicate PK/UNIQUE indexes added. |
| Views | No new view | No approved repeated read/support/report query requires one in this database package. A view would not secure raw table access. |
| Triggers | Context dependent | Retain only existing cross-row, immutable/version/lifecycle guards. New RLS/grants do not duplicate transition logic. |
| Functions/procedures | Existing technical functions only | Trigger helpers / Auth refresh / Document activation where already designed. No solver/progress or ordinary service workflow moved into SQL. |
| Personal data masking | Synthetic demo + restricted access | No real records exported. Service-required raw data cannot be meaningfully masked for runtime. |

## Query/index inventory

- scheduling_request: PK(id,revision).
- scheduling_request: UNIQUE(id,revision,school_id).
- scheduling_request: INDEX(school_id,status).
- scheduling_request_enrollment: PK(request_id,request_revision,enrollment_id).
- scheduling_request_group: PK(request_id,request_revision,group_id).
- scheduling_request_resource: PK(request_id,request_revision,resource_kind,resource_id).
- scheduling_request_window: PK(id).
- scheduling_rule_version: PK(id).
- scheduling_rule_version: UNIQUE(rule_id,revision).
- scheduling_rule_version: INDEX(source_kind,school_id,rule_code).
- scheduling_request_rule: PK(request_id,request_revision,rule_version_id).
- scheduling_operation_rule: PK(operation_id,rule_version_id).
- candidate_lesson: PK(id).
- candidate_lesson: UNIQUE(id,request_id,request_revision).
- candidate_lesson: INDEX(request_id,request_revision).
- candidate_lesson_participant: PK(candidate_lesson_id,enrollment_id).
- candidate_lesson_participant: UNIQUE(candidate_lesson_id,student_id).
- recurring_lesson_series: PK(id).
- recurring_lesson_series: UNIQUE(id,school_id,kind).
- lesson: PK(id).
- lesson: UNIQUE(id,school_id).
- lesson: UNIQUE(source_candidate_id).
- lesson: INDEX(school_id,starts_at).
- lesson: INDEX(teacher_id,starts_at,ends_at).
- lesson_participant: PK(lesson_id,enrollment_id).
- lesson_participant: UNIQUE(lesson_id,student_id).
- scheduling_operation: PK(id).
- scheduling_operation: UNIQUE(id,school_id).
- reservation_claim: PK(id).
- reservation_claim: INDEX(resource_kind,resource_key,starts_at,ends_at).
- reservation_claim: INDEX(lesson_id,resource_kind,resource_key).
- lesson_change: PK(id).
- lesson_change: UNIQUE(lesson_id,revision).
- assessment_appointment: PK(id).
- assessment_appointment: UNIQUE(id,school_id).

## Measurement boundaries

EXPLAIN JSON for a representative local query is stored in native evidence. Tiny fixtures may correctly choose sequential scan. No speedup/throughput claim or speculative extra index is made. Any future index needs a real predicate/cardinality/workload measurement.

Reference data: Not Applicable as a global fixed-table seed for this context. Existing enum/status domains are installed by DDL; school-owned templates/programmes/rules are business configuration, not invented global lookup rows. Demo configurations are explicitly synthetic and must not be promoted to legal/category authority.
