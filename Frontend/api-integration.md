# Frontend API integration

The browser calls the Vairas API Gateway only. During local development Angular proxies same-origin `/api` requests to `https://localhost:7000` and verifies the Gateway certificate against the local CA. Feature API clients use typed `HttpClient` methods; the interceptor supplies the bearer token, correlation ID, refresh handling and user-safe errors. No runtime mock server or data fallback exists.

## API ownership

| Feature | Gateway routes used |
| --- | --- |
| Authentication | `/api/v1/auth/login`, `/refresh`, `/registrations`, `/challenges`, `/sessions/{id}/revocation` |
| User Management | `/api/v1/users/me` |
| School Management | `/api/v1/users/me/schools`, `/enrollments`, `/schools/{id}/enrollments`, branches, groups, teachers, invitations and memberships |
| Scheduling | `/api/v1/users/me/lessons`, practical/theory lesson commands, scheduling requests, proposals, operations and assessment appointments |
| Learning Tracking | student-training progress, practical/theory records, readiness, assessments, evidence and reporting declarations |
| Vehicle Management | school vehicles, assignments and vehicle state-change operations |
| Document Management | enrollment journals/reports, document jobs, review/publication, version downloads |
| Chat Backend | chat sessions/messages, action previews/executions and assistant audit |

The API Gateway owns routing and the backend owns authorization and business rules. UUID types remain distinct: IdentityId, UserId, StudentId, SchoolId and EnrollmentId must not be substituted for one another. School changes invalidate in-flight requests and clear school-scoped state; student features use the selected authorized EnrollmentId.

## Authentication and request behavior

Access tokens stay in memory. The rotating refresh token and selected school/enrollment are kept in per-tab `sessionStorage` to restore the session after a reload; credentials and access tokens are not persisted there. Concurrent refresh requests share one in-flight refresh operation. A refresh token is never retried after an ambiguous failure. A single 401 retry preserves the original Idempotency-Key; non-idempotent requests are never retried automatically for network or server errors.

Scheduling commands retain their operation identity until the backend confirms the result. A pending or unknown result is reconciled through the same operation key. API ProblemDetails codes map to safe user-facing explanations and correlation references; raw server exceptions are not shown.

## Known contract limitations

- Registration is shown in the UI, but the current Authentication OpenAPI source marks `POST /api/v1/auth/registrations` as proposed. The form must not be represented as a confirmed live signup flow until the endpoint is implemented and enabled in the local stack.
- Public user-name lookup is limited. Other students, teachers and vehicles may be labelled with short identifiers until an authorized read model supplies display names.
- Some read models are not listable: practical/theory records and assessment appointments are opened by ID; the UI retains only the identifiers needed to return to records created in the current browser. Historical declaration lists are not available; submitted declaration receipts are stored locally for display.
- Curriculum visibility is role-limited. Teachers can use topics from existing records or provide the authorized programme topic ID where the contract does not expose the curriculum.
- The Chat Backend may return a preview-only execution profile. The UI enables writes only when the backend grants `ConfirmedLessonActionsV1`; exact preview arguments, expiry and explicit user approval are sent to the execution endpoint.
- The local model test double is configured behind Chat Backend. The frontend sends ordinary Chat API requests and contains no scripted assistant replies or fake tool results.

These gaps are reported as missing backend capabilities or limited read models. The frontend does not substitute synthetic business data or report an unconfirmed write as successful.
