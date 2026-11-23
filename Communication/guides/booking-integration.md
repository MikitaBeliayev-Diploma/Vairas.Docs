# Tutorial: proposed MCP lesson booking

This is an integration design walkthrough using synthetic values. Scheduling, School and MCP providers are not implemented in the supplied Backend. It does not run against the existing User Management server. Use the machine-readable examples for a future sandbox; no working multi-service mock server is claimed.

## 1. Establish the authorized context

Authenticate the user through the configured issuer. The MCP adapter must obtain a verifiable user context and School permissions, separate from its own workload identity. Foundry identity delegation compatibility remains unresolved. Private tools stay disabled until that condition is met. No tool accepts a freely chosen actor UserId as authority.

Call `get_my_enrollments` with `{}`. Its REST mapping is `GET /api/v1/users/me/enrollments`; select an enrollment returned for that user. A school administrator must also have booking authority in the selected school. Global student identity and enrollment identity are distinct.

## 2. Query provisional availability

Call `find_available_lessons`:

```json
{"schoolId":"11111111-1111-4111-8111-111111111111","enrollmentId":"22222222-2222-4222-8222-222222222222","teacherId":"33333333-3333-4333-8333-333333333333","from":"2026-12-01T10:00:00Z","to":"2026-12-01T12:00:00Z"}
```

The adapter calls the School-scoped availability REST endpoint. A slot is provisional and holds no reservation. School permissions, instructor/vehicle eligibility, applicable rules and verified global-person bindings must be checked. Cross-school conflicts return generic unavailability, never another school's calendar. AC-099 privacy/legal clearance is required before real-data activation.

## 3. Preview exact arguments

Call `preview_lesson_booking` with the selected school, branch, enrollment, student, instructor, vehicle, category and UTC interval from [tools.json](../mcp/tools.json). The adapter checks availability and records an expiring preview bound to those exact values. In the Chat UI show the human the school, participants, resources and interval. The preview tool does not grant approval.

The Chat Backend must record a fresh authenticated human approval. Changing an argument, user, school or operation identity invalidates that approval. Approval allocation/storage is a proposed Chat capability; the existing profile-confirmation validator does not automatically authorize Scheduling commands.

## 4. Commit once

Call `create_lesson_booking` with `previewId`, `confirmationId`, a stable `operationId` and the exact `arguments` object. The adapter validates the stored approval and delegates to `POST /api/v1/practical-lessons` through the gateway with `Idempotency-Key: operationId`. The owning API must independently enforce authorization and concurrency protection.

On 201 the lesson is committed. On 409 refetch availability and request a fresh preview and approval. On 403 do not retry under a more privileged identity. On 202 `ReconciliationPending`, or a lost acknowledgement, query `GET /api/v1/scheduling-operations/{operationId}` and reconcile the same operation; do not create a replacement operation or assume rollback. The protective reservation remains until its authoritative outcome is known.

## 5. Observe downstream effects

The local transaction writes the lesson and outgoing event atomically when an Outbox is implemented. `LessonScheduled` reaches Notifications at least once; its consumer deduplicates event and semantic delivery intent. A notification failure does not roll back the booking. `LessonCompleted` later reconciles the source lifecycle into Learning Tracking, but awards no practical minutes. Only valid same-version instructor and student confirmations establish credit.

## 6. Exercise rejection cases before rollout

Verify foreign enrollment, expired/mismatched confirmation, another school booking concurrently, stale revision, dependency outage and ambiguous commit. Tests must prove no unauthorized disclosure, no duplicate reservation and no optimistic success after uncertainty. See [acceptance scenarios](../audit/acceptance-scenarios.md).

## Actual interval (G-01)

The local [storage/lifecycle amendment](../../Database/scheduling/docs/actual-interval.md) covers physical completion for practical and theory lessons, audited interval correction and exact source identity. LessonCompleted also signals a completed-source correction at a new aggregateVersion. Consumers fetch current training-source and reconcile before credit; planned event times never supply actuals. Provider/Outbox implementation remains required.
