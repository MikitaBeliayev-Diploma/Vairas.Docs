# Notifications — Indexes and database rules

| Feature | Necessary? | Business/technical reason |
| --- | --- | --- |
| Indexes | Yes, existing | PK/UNIQUE candidate-key enforcement and actual scoped/temporal source lookups. No duplicate PK/UNIQUE indexes added. |
| Views | No new view | No approved repeated read/support/report query requires one in this database package. A view would not secure raw table access. |
| Triggers | Context dependent | Retain only existing cross-row, immutable/version/lifecycle guards. New RLS/grants do not duplicate transition logic. |
| Functions/procedures | Existing technical functions only | Trigger helpers / Auth refresh / Document activation where already designed. No solver/progress or ordinary service workflow moved into SQL. |
| Personal data masking | Synthetic demo + restricted access | No real records exported. Service-required raw data cannot be meaningfully masked for runtime. |

## Query/index inventory

- notification_template: PK(school_id,template_id).
- notification: PK(school_id,notification_id).
- notification: UNIQUE(school_id,recipient_user_id,channel,dispatch_key).
- notification: INDEX(status,next_attempt_at,scheduled_at).
- notification: INDEX(school_id,recipient_user_id,created_at).
- notification: INDEX(school_id,source_context,source_id,source_revision).
- notification_delivery_attempt: PK(school_id,attempt_id).
- notification_delivery_attempt: UNIQUE(school_id,notification_id,attempt_no).
- notification_delivery_attempt: UNIQUE(school_id,provider_key).
- notification_inbox: PK(school_id,producer,event_id).
- notification_operation: PK(school_id,operation_id).

## Measurement boundaries

EXPLAIN JSON for a representative local query is stored in native evidence. Tiny fixtures may correctly choose sequential scan. No speedup/throughput claim or speculative extra index is made. Any future index needs a real predicate/cardinality/workload measurement.

Reference data: Not Applicable as a global fixed-table seed for this context. Existing enum/status domains are installed by DDL; school-owned templates/programmes/rules are business configuration, not invented global lookup rows. Demo configurations are explicitly synthetic and must not be promoted to legal/category authority.
