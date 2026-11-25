# Backend API handoff for the frontend — 2026-11-25

All routes are reached through the Gateway (`https://localhost:7000`). Every call needs a user bearer token for the target
service audience. Errors are `application/problem+json` with `code` and `correlationId` (400 validation, 401 authentication,
403 access denied, 404 not found *or* outside the caller's school/enrollment scope, 409 conflict/stale revision, 422 rule
violation, 429 rate limited, 503 owner/database unavailable). A list endpoint never reveals whether an out-of-scope resource exists.
The mapping to individual User Story / Acceptance Criteria numbers was not re-verified against the Business Analysis in this
pass; the "Purpose" column states the workflow instead.

## New or completed read endpoints

| Method | Route | Response | Permission / scope | Purpose |
|---|---|---|---|---|
| GET | `/api/v1/student-trainings/{enrollmentId}/reporting-declarations?schoolId=` | `ReportingDeclarationDetail[]` — `declarationId, snapshotId, actorUserId, declaredAt, statement` (newest first) | School Administrator of `schoolId`; enrollment must belong to the school | Show previously recorded **internal** manual-reporting declarations (never an external acknowledgement). Created by `POST` of the same route (idempotent by `Idempotency-Key`). *(this pass)* |
| GET | `/api/v1/schools/{schoolId}/scheduling-rule-versions?ruleId=&effectiveOnly=false&limit=100` | `RuleVersionDetail[]` — `ruleVersionId, ruleId, revision, ruleType, sourceKind, severity, scopeKind, scopeResourceId, value, unit, effectiveFrom, effectiveTo, verificationStatus, superseded, effectiveNow` | School Administrator of `schoolId` (rule owner needed only to publish) | School rule history plus the verified legal baseline (`sourceKind` ≠ `School`). `effectiveOnly=true` returns only the revision in force now. `limit` 1–200 (400 otherwise). Rule versions are immutable; `superseded` marks older revisions. *(this pass)* |
| GET | `/api/v1/training-programs/{programId}/versions` | programme versions | existing programme authorization | Programme/version discovery. *(found already present; reviewed by routing only)* |
| GET | `/api/v1/lessons/{lessonId}/theory-roster?schoolId=` | `Roster` — exact retained historical roster | authorized actors of the school | Authoritative participants of a past theory lesson (not the current group). *(found already present; contract not re-reviewed)* |
| GET | `/api/v1/lessons/{lessonId}/theory-records?schoolId=` | `TheoryRecordResult[]` | authorized actors of the school | Existing theory attendance records of a lesson. *(found already present; contract not re-reviewed)* |
| GET | `/api/v1/assessment-appointments` | assessment appointments | authorized actors | Appointment discovery. *(found already present; contract not re-reviewed)* |
| GET | `/api/v1/schools/{schoolId}/invitations` | invitation metadata (no secrets) | School Administrator | Invitation status/expiry discovery. *(found already present; contract not re-reviewed)* |

Already available before this pass and reusable by the frontend (no change): `GET /api/v1/student-trainings/{id}/assessments`,
`/readiness`, `/progress`, `/practical-records`, `/completion-evidence`; `GET /api/v1/assessments/{id}/versions`;
`GET /api/v1/training-evidence/{snapshotId}`; Documents `GET /api/v1/enrollments/{id}/documents`, `/documents/{id}/history`.

OpenAPI exports (`Backend/<Service>/api/*.openapi.{json,yaml}`) and the Gateway `routes.json` were updated for the two endpoints
added in this pass. Gateway test `Every_public_operation_routes_to_its_owner_over_real_HTTP` now expects 173 routes.

## Still without a dedicated read endpoint (frontend must not assume support)

* Scheduling requests/proposals list (only `GET scheduling-requests/{id}` exists).
* Enrollment configuration status and group-membership history listing beyond the existing `groups/{id}/participants`.
* Completion-report/publication history in Documents beyond `documents/{id}/history`.
* Assessment readiness for one definition by id (existing `readiness` returns per-enrollment results).
