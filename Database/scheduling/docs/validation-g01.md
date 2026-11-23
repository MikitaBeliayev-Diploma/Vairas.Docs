# G-01 design review

The amendment adds Scheduling-owned physical actual intervals while Learning Tracking retains teaching minutes, attendance, confirmations and derived credit.

## Reviewed artifacts

- `lesson.actual_start` / `actual_end` and previous actual bounds in `lesson_change` agree across DBML, ERD, dictionary and migration 002.
- Paired increasing intervals are required; every new or updated Completed row requires actual bounds.
- Legacy Completed rows are preserved without guessing actual time. Constraint validation follows verified reconciliation.
- Fresh installation includes migration 002; runtime grants permit the actual-time update.
- Completion, correction and source contracts distinguish actual time from planned time and credited minutes.
- Correction reasons are nonblank and limited to 500 characters, matching storage.

Offline review included 15 DBML/embedded PostgreSQL checks and 836 example/JSON Schema checks. These are local artifact results, not a live service or production migration claim. Executable checks are maintained outside this documentation repository.

## Remaining implementation evidence

Scheduling handlers, actor authorization, CAS/history/Outbox transactions, source reconciliation, duplicate recovery and concurrent correction require implementation and runtime verification. No real PostgreSQL upgrade, broker delivery, cross-service transaction or legal approval is certified by this review.

See [lifecycle and upgrade rules](actual-interval.md) and the [acceptance requirements](../../../Communication/audit/acceptance-scenarios.md).
