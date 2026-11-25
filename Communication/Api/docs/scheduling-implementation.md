# Scheduling implementation contract amendments

The archived YAML under `api/source` preserves the reviewed proposed input. The generated `api/scheduling.openapi.json` is the implemented HTTP contract. These amendments are explicit additions to D-044, not retroactive changes to its adoption record.

- Theory uses the same resource input shape as practical with `branchId`, `category` and `groupId`; practical-only identifiers are null. `classroomId` is removed as agreed; classrooms are outside this version.
- Interval timestamps use UTC and PostgreSQL microsecond precision; finer input precision is rejected before writes to preserve exact same-revision source facts.
- Reads/action routes require `schoolId`. Theory read/reschedule/cancel and appointment read/cancel complete the proposed action surface. Lesson JSON adds tenant/resource identity and physical intervals.
- School rule publication accepts stable optional `ruleId`, `scopeResourceId`, `severity`, `effectiveTo`, source and reason. Creation uses expectedRevision=0; updates append an immutable version. Only the four adopted numeric School codes are accepted.
- Draft inputs include typed recurrence selections. Unparsed preference text is retained as informational draft content; only implemented typed rule versions influence evaluation.
- Reliability migration adds command fingerprint/result, draft/source basis, appointment readiness identity/revision and soft active flags on retained theory participants. Six new reliability tables are technical/workflow storage, not six new business bounded contexts.
- Vehicle gate commands add explicit `schoolId`. Block/release/outcome routes preserve immutable operation binding and stable rejected outcomes. Availability evidence must declare the compatible gate protocol; a provisional GET alone cannot authorize commitment.
- School publishes `internal/v1/scheduling/access`, `snapshots`, `rule-scope` and exact `coordination/{operationId}` decisions. Scheduling exposes prepare/finalize/abort/outcome and scoped lesson-impact routes. Their DTOs and generated OpenAPI define the exact wire shape.
- Learning's expected planning-input and assessment-evidence interfaces are POST `internal/v1/scheduling/planning-inputs` and `assessment-evidence`. They must echo school/programme or assessment/readiness identity and current validity. Planning returns immutable programme version and finite required demands/options. Absent/mismatched evidence returns 503; no amount, duration, eligibility or readiness is guessed.
- A roster revision emits `LessonParticipantsChanged` on `vairas.scheduling.lesson-participants-changed.v1`, with the common event headers and payload schoolId/lessonId/lessonKind/teacherId/groupId/groupMembershipRevision. This is a new contract addition. Completion corrections continue to emit `LessonCompleted` at the new aggregateVersion.
- AsyncAPI payload is the message body; common IntegrationHeaders are Service Bus application properties. MessageId=eventId, Subject=eventType. Planned startsAt/endsAt in completion events never supply actual teaching facts.
- Delegated mutations are explicitly documented under `/internal/v1/delegated`; the workload must have `scheduling.mcp.write` and an allowlist entry. User admission and exact Chat confirmation remain mandatory. No MCP/Chat implementation is included here.

The shared Documentation update explicitly records these amendments and migration 003, preserving the frozen initial/G-01 SQL. Local exports and this record identify the implemented surface independently of deployment.
