# Vehicle Management — Indexes and database rules

| Feature | Necessary? | Business/technical reason |
| --- | --- | --- |
| Indexes | Yes, existing | PK/UNIQUE candidate-key enforcement and actual scoped/temporal source lookups. No duplicate PK/UNIQUE indexes added. |
| Views | No new view | No approved repeated read/support/report query requires one in this database package. A view would not secure raw table access. |
| Triggers | Context dependent | Retain only existing cross-row, immutable/version/lifecycle guards. New RLS/grants do not duplicate transition logic. |
| Functions/procedures | Existing technical functions only | Trigger helpers / Auth refresh / Document activation where already designed. No solver/progress or ordinary service workflow moved into SQL. |
| Personal data masking | Synthetic demo + restricted access | No real records exported. Service-required raw data cannot be meaningfully masked for runtime. |

## Query/index inventory

- vehicle: PK(vehicle_id).
- vehicle: UNIQUE(vehicle_id,school_id).
- vehicle: UNIQUE(school_id,registration_country_code,registration_number).
- vehicle: INDEX(school_id,branch_id,status).
- vehicle_supported_category: PK(vehicle_id,school_id,category_code).
- vehicle_teacher_assignment: PK(vehicle_id,school_id,teacher_id).
- vehicle_teacher_assignment: INDEX(school_id,teacher_id).
- vehicle_teacher_assignment: INDEX(school_id,school_membership_id).
- maintenance: PK(maintenance_id).
- maintenance: UNIQUE(maintenance_id,vehicle_id,school_id).
- maintenance: INDEX(school_id,vehicle_id,status).
- vehicle_operation: PK(operation_id).
- vehicle_operation: INDEX(school_id,vehicle_id,recorded_at).

Supplement: `Database/vehicle-management/ddl/vehicle-management-postgresql-constraints.sql`.

## Measurement boundaries

EXPLAIN JSON for a representative local query is stored in native evidence. Tiny fixtures may correctly choose sequential scan. No speedup/throughput claim or speculative extra index is made. Any future index needs a real predicate/cardinality/workload measurement.

Reference data: Not Applicable as a global fixed-table seed for this context. Existing enum/status domains are installed by DDL; school-owned templates/programmes/rules are business configuration, not invented global lookup rows. Demo configurations are explicitly synthetic and must not be promoted to legal/category authority.
