# Errors, concurrency and delivery

## Error format and recovery

Business APIs document `application/problem+json`: `title`, numeric HTTP `status`, stable `code`, and `correlationId`; optional `type`, `instance`, validation `errors` and rejected `operation` add context. Health probes return plain text instead. OAuth token error conventions are a provider integration decision; the current expected provider view documents a problem response but clients rely only on non-success status.

| HTTP | Implemented User Management examples | Client action |
|---|---|---|
| 400 | `VALIDATION_FAILED` | Correct the request; do not replay the same invalid command |
| 401/403 | `HTTP_ERROR`, `FORBIDDEN` depending on the rejection path | Renew valid credentials or obtain permission; no privilege escalation |
| 404 | `NOT_FOUND` | Check identity/resource scope; do not enumerate foreign resources |
| 409 | `REVISION_CONFLICT`, `IDEMPOTENCY_KEY_REUSED`, `RESOURCE_CONFLICT`, `PROFILE_EXISTS` | Refetch/reconcile; changed intent needs a new operation ID |
| 422 | `CONFIRMATION_REQUIRED`, `CONFIRMATION_INVALID`, `CONFIRMATION_EXPIRED` | Obtain exact current approval; never invent consent |
| 503 | `DEPENDENCY_UNAVAILABLE`, `DATABASE_UNAVAILABLE` | Restore authority and reconcile mutations before retrying |
| 500 | `INTERNAL_ERROR` | Preserve correlation ID; investigate and reconcile |

Other services' error codes are proposed contract vocabulary, not proof of server handlers. Generic examples show a category; operation-specific descriptions constrain its meaning. Problem details must not expose other schools' identifiers, database messages or secrets.

## Idempotency and revisions

User Management uses a UUID `Idempotency-Key` and a canonical command fingerprint bound to the actor/workload/channel and exact fields. Identical retries return the recorded outcome after current admission checks. Different payloads with the same key conflict. A create can return 201 again on a completed identical replay; `ALREADY_EXISTS` role reuse returns 200. Receipt `code` is `APPLIED` for an ordinary successful mutation. Fetch the resource to obtain its current state.

Profile revision is a positive integer for update/deactivation. Creation requires expectedRevision to be null/absent. Student profile creation forbids school and invitation; staff roles require them. Unknown JSON members are rejected. Nullable contact fields remain required JSON properties for ProfileRequest.

Scheduling request revision freezes input/proposal identity. Lesson concurrency revision, practical fact version, practical aggregate revision and event aggregateVersion are separate counters. Confirming a stale proposal must not silently update its basis. Current resources, verified legal rules and global reservations are rechecked atomically at commit. Intervals use UTC instants; school-local planning dates use Europe/Vilnius and require DST-aware conversion.

An ambiguous commit is not a rollback. Proposed Scheduling commands return/retain `ReconciliationPending`; query by the same operation identity and keep protective reservations while uncertain. Vehicle Saga must block first, then reduce availability; activate first, then release a block. Unknown outcomes must never trigger unsafe compensation.

## Events and notifications

See the [event catalog](<../Async Api/docs/EVENT_CATALOG.md>). Producer/consumer AsyncAPI views share identical payload schemas and headers; `.v1` is the logical event address version. Azure Service Bus uses a physical topic per producer family, with filtered service subscriptions. Transport `Subject`/application properties, payload and business identity remain distinct.

At-least-once delivery requires consumer Inbox/deduplication and monotonic aggregate revisions. Outbox change and business change must commit locally together. A redelivery with the same eventId is not a second business fact; a later record revision supersedes previous credit. Retry transient failures with bounded backoff; poison messages go to DLQ for investigation. Do not claim that these consumers are implemented.

Only the User Management sender is implemented in the current Backend. Its Azure SDK adapter sets MessageId, Subject and correlation/application properties. No live broker/subscriber verification was performed for this documentation update.

Notifications supports `Pending`, `Sending`, `Sent`, `Failed`, `Cancelled`, `DeliveryUnknown`. `Sent` means provider acceptance. `DeliveryUnknown` requires reconciliation and provider idempotency evidence before retry; do not send a duplicate blindly. Current DB policy restricts notification intents to Scheduling/LearningTracking. The legacy MaintenanceScheduled subscription conflicts with that policy and remains a documented optional-design gate.

## Lists, pagination and limits

Existing list responses are arrays; cursor pagination is not implemented or guaranteed. Consumers must not assume `nextCursor`, totals or stable snapshot semantics. Availability and personal lesson queries require bounded `from`/`to` intervals; permissible maximum horizon and row caps require a service policy decision before deployment. Do not invent numeric limits for an unimplemented service.

No measured or enforced gateway/API rate-limit policy is established by the supplied code. Future throttling must document scope, quota/window, 429 response and Retry-After before it is advertised. Clients should apply bounded retry budgets and avoid automatic mutation retries without reconciliation. This is an explicit Maximum-level topic with an implementation limitation, not a claim of implemented throttling.
