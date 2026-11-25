# Vairas Scheduling API

Implemented HTTP contract; generated from the current ASP.NET Core application. Missing providers fail closed. See the Scheduling implementation contract amendments for version differences.

| Method | Path | Behavior |
|---|---|---|
| GET | `/internal/v1/lessons/{lessonId}/training-source` | Return one consistent physical source revision to the authorized Learning workload. |
| POST | `/api/v1/practical-lessons` | Atomically reserve a practical lesson and all its resources. |
| POST | `/internal/v1/delegated/practical-lessons` | Atomically reserve a practical lesson and all its resources. |
| POST | `/api/v1/theory-lessons` | Reserve a theory group, teacher and the exact participant roster. |
| POST | `/internal/v1/delegated/theory-lessons` | Reserve a theory group, teacher and the exact participant roster. |
| GET | `/api/v1/practical-lessons/{lessonId}` | Read an authorized practical or theory lesson. |
| GET | `/api/v1/theory-lessons/{lessonId}` | Read an authorized practical or theory lesson. |
| POST | `/api/v1/practical-lessons/{lessonId}/rescheduling` | Replace the slot atomically; conflicts retain the original allocation. |
| POST | `/api/v1/theory-lessons/{lessonId}/rescheduling` | Replace the slot atomically; conflicts retain the original allocation. |
| POST | `/internal/v1/delegated/lessons/{lessonId}/rescheduling` | Replace the slot atomically; conflicts retain the original allocation. |
| POST | `/api/v1/practical-lessons/{lessonId}/cancellation` | Cancel a scheduled lesson and release reservations with retained history. |
| POST | `/api/v1/theory-lessons/{lessonId}/cancellation` | Cancel a scheduled lesson and release reservations with retained history. |
| POST | `/internal/v1/delegated/lessons/{lessonId}/cancellation` | Cancel a scheduled lesson and release reservations with retained history. |
| POST | `/api/v1/practical-lessons/{lessonId}/completion` | Assigned teacher records physical completion, without awarding learning credit. |
| POST | `/api/v1/theory-lessons/{lessonId}/completion` | Assigned teacher records physical completion, without awarding learning credit. |
| PATCH | `/api/v1/lessons/{lessonId}/actual-interval` | Correct a completed physical interval with explicit School correction authority and reason. |
| GET | `/api/v1/users/me/lessons` | List only the authenticated student's or assigned teacher's lessons. |
| GET | `/api/v1/scheduling-operations/{operationId}` | Reconcile an ambiguous command using the same operation identity. |
| GET | `/api/v1/schools/{schoolId}/availability` | Find bounded provisional slots without exposing foreign calendars. |
| POST | `/api/v1/scheduling-requests` | Save an incomplete school-scoped draft without proposing or reserving lessons. |
| PUT | `/api/v1/scheduling-requests/{requestId}` | Create a new editable revision and supersede any pending source proposal. |
| GET | `/api/v1/scheduling-requests/{requestId}` | Read the latest authorized revision with safe missing-input categories. |
| POST | `/api/v1/scheduling-requests/{requestId}/submissions` | Validate authoritative inputs and freeze the exact request revision. |
| POST | `/api/v1/scheduling-requests/{requestId}/proposals` | Generate an unconfirmed proposal or prove infeasibility within the bounded input space. |
| POST | `/api/v1/scheduling-requests/{requestId}/confirmations` | Revalidate and atomically reserve every lesson in an exact proposal. |
| POST | `/internal/v1/delegated/scheduling-requests/{requestId}/confirmations` | Revalidate and atomically reserve every lesson in an exact proposal. |
| POST | `/api/v1/schools/{schoolId}/scheduling-rule-versions` | Publish a new immutable School rule without weakening verified law. |
| GET | `/api/v1/schools/{schoolId}/scheduling-rule-versions/{ruleVersionId}` | Read the identity, revision and verification state of an authorized School rule version. |
| POST | `/api/v1/assessment-appointments` | Schedule an appointment from current authoritative assessment/readiness evidence. |
| GET | `/api/v1/assessment-appointments/{appointmentId}` | Read an authorized assessment time/resource allocation. |
| POST | `/api/v1/assessment-appointments/{appointmentId}/cancellation` | Cancel an appointment without changing Learning readiness or results. |
