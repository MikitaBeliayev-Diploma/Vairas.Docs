# G-01: actual lesson interval

Accepted for the local design on 2026-11-22 at the author's request. This amends the current Scheduling design; it does not rewrite historical adoption decisions or claim a deployed provider.

Scheduling owns planned `starts_at/ends_at`, physical `actual_start/actual_end`, lifecycle and `lesson.revision`. Learning Tracking owns training minutes, topics, attendance, confirmations and credit. Actual elapsed time and credited teaching minutes are distinct. The Learning source snapshot is an immutable copy of the verified Scheduling revision.

## Storage and upgrade

Fresh installs run `initial.sql` then [002-actual-interval.sql](../ddl/002-actual-interval.sql) through `install.sql`. Existing installations apply only migration 002 once, then apply the new column grant through the established deployment process. That security file also creates policies/roles and is not an idempotent upgrade script; use the explicit grant below for existing installations:

```sql
GRANT UPDATE(actual_start,actual_end) ON lesson TO v_scheduling_runtime;
```

Both actual bounds are NULL or form a strictly increasing interval. Every new or updated Completed row requires both bounds. Actual bounds may differ from the planned interval. History retains the previous actual interval on every mutation. Historical Completed snapshots from before migration may legitimately lack actuals and must remain identifiable as unverified history.

The migration adds the completion constraint as NOT VALID to preserve existing Completed rows without inventing facts. It validates automatically when there are no exceptions. For existing exceptions, list them with:

```sql
SELECT id, school_id, revision FROM lesson
WHERE status='Completed' AND (actual_start IS NULL OR actual_end IS NULL);
```

Recover times only from trusted evidence using the audited correction workflow and a new lesson revision. Otherwise retain an unverified source and block credit. Never copy planned values, silently change historical status or rewrite prior Learning snapshots. After all exceptions are resolved:

```sql
ALTER TABLE lesson VALIDATE CONSTRAINT lesson_completed_requires_actuals;
```

## Provider transaction and authorization

These are required service rules; the repository has no Scheduling implementation yet.

1. Authenticate the assigned teacher and exact SchoolId/lesson scope. Administrative correction requires explicit authorized authority and an audit reason; it cannot substitute participant confirmations.
2. Complete a Scheduled practical or theory lesson with `expectedVersion`, actualStart and actualEnd. Reject a non-increasing/future-ended interval and unsupported lifecycle transition. Recheck authoritative references and any affected scheduling policies. JSON Schema validates shape; timestamp ordering and current-time checks belong to the service.
3. Use an operation identity (Idempotency-Key) bound to the exact actor, tenant, target and payload. An identical retry returns the recorded result; key reuse with different data is a conflict. With a stale expectedVersion return 409 without partial writes.
4. Lock/CAS the lesson, append its OLD state to lesson_change including previous actuals, persist status/actuals and increment revision in one local transaction. Completion publishes LessonCompleted through a transactional Outbox. A correction of a Completed interval requires a reason, new revision and a new-revision LessonCompleted reconciliation signal. The event describes the current completed state and may be emitted again after a correction; it never grants credit. Event consumers always fetch the current training-source; late/repeated events cannot restore old evidence. Implement Outbox before enabling these commands.
5. The source endpoint reads one consistent revision and includes school, kind, teacher/instructor mapping, enrollment/student/vehicle or group/membership identity, status-derived physicallyCompleted, actuals and sourceValid. sourceValid requires authenticated authoritative data, required identities and a verified interval for completion; status alone is insufficient. Legacy missing actuals return sourceValid=false and both actuals=null.

## Learning reconciliation

The LessonCompleted event is a lifecycle signal with planned times; it awards no minutes. The adapter fetches `/internal/v1/lessons/{lessonId}/training-source` and binds its exact lessonRevision and identity to a new immutable snapshot. If the fetched revision is newer than the event, use the verified current revision; never label newer fields with the old event revision. Same revision with differing significant fields is a conflict and blocks credit pending reconciliation.

A source correction invalidates dependent current eligibility and requires a new practical/theory fact version and fresh required confirmations. Existing confirmations stay attached to their original fact version. A source-only update cannot automatically re-credit old records. Practical credit needs a current Valid version, verified current source and same-version instructor/student confirmation without a later dispute. Theory credit also needs current teacher confirmation and Present attendance. `training_minutes` may be shorter than elapsed time (for example breaks); explain shorter duration and never derive credit from Scheduled/Completed alone.

## Verification boundary

Validate DBML, migration constraints, OpenAPI, examples, source identity shapes and generated references offline. Service transaction/CAS, real Outbox delivery, duplicate recovery, authorization and concurrent correction tests remain implementation acceptance gates. See the Communication acceptance scenarios.
