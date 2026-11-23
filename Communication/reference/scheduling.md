# Vairas — Scheduling API (PROPOSED)

Proposed OpenAPI contract; not evidence of implemented endpoints. Tenant/resource authorization is mandatory inside the owning service.

[Canonical OpenAPI](../Api/scheduling.openapi.yaml) | [Security](../guides/security.md) | [Errors](../guides/errors-and-reliability.md)

## Operations

### POST /api/v1/practical-lessons

Atomically reserve student, instructor and vehicle for one timeslot

 Unknown reservation outcome is ReconciliationPending; retain the protective reservation and reconcile by operation identity. AC-099 privacy/legal clearance and trusted global-person binding are required before real-data availability checks.

Operation ID: `createPracticalLesson`. Status: **proposed**.

**Authorization:** `[{"bearerAuth": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

| Parameter | Location | Required | Example |
|---|---|---|---|
| X-Correlation-ID | header | False | `synthetic-X-Correlation-ID` |
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/practical-lessons HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
X-Correlation-ID: synthetic-X-Correlation-ID
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "branchId": "11111111-1111-4111-8111-111111111111",
  "enrollmentId": "11111111-1111-4111-8111-111111111111",
  "studentId": "11111111-1111-4111-8111-111111111111",
  "teacherId": "11111111-1111-4111-8111-111111111111",
  "vehicleId": "11111111-1111-4111-8111-111111111111",
  "category": "B",
  "startsAt": "2026-12-01T10:00:00Z",
  "endsAt": "2026-12-01T11:00:00Z"
}
```

**Responses**

- **201** — Accepted and committed

  Media type: `application/json`.

```json
{
  "lessonId": "11111111-1111-4111-8111-111111111111",
  "status": "Scheduled",
  "version": 1,
  "startsAt": "2026-12-01T10:00:00Z",
  "endsAt": "2026-12-01T11:00:00Z",
  "kind": "Practical"
}
```

- **400** — Invalid input

  Media type: `application/problem+json`.

```json
{
  "title": "Invalid input",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Authentication required

  Media type: `application/problem+json`.

```json
{
  "title": "Authentication required",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Access forbidden

  Media type: `application/problem+json`.

```json
{
  "title": "Access forbidden",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Resource not found or not visible

  Media type: `application/problem+json`.

```json
{
  "title": "Resource not found or not visible",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Business conflict

  Media type: `application/problem+json`.

```json
{
  "title": "Business conflict",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Business rule rejected

  Media type: `application/problem+json`.

```json
{
  "title": "Business rule rejected",
  "status": 422,
  "code": "BUSINESS_RULE_REJECTED",
  "correlationId": "integration-example-01"
}
```

- **503** — Dependency unavailable

  Media type: `application/problem+json`.

```json
{
  "title": "Dependency unavailable",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

- **202** — Reconciliation pending; do not assume rollback or availability. Query the operation with the same Idempotency-Key.

  Media type: `application/json`.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "status": "Pending",
  "lessonIds": [
    "11111111-1111-4111-8111-111111111111"
  ]
}
```

**Invalid input example:** Missing required schoolId: reject with 400 before business work.

```json
{
  "branchId": "11111111-1111-4111-8111-111111111111",
  "enrollmentId": "11111111-1111-4111-8111-111111111111",
  "studentId": "11111111-1111-4111-8111-111111111111",
  "teacherId": "11111111-1111-4111-8111-111111111111",
  "vehicleId": "11111111-1111-4111-8111-111111111111",
  "category": "B",
  "startsAt": "2026-12-01T10:00:00Z",
  "endsAt": "2026-12-01T11:00:00Z"
}
```

### GET /api/v1/practical-lessons/{lessonId}

Get authorized lesson by ID

Get authorized lesson by ID. Proposed interface; authoritative actor and school checks are mandatory.

Operation ID: `getPracticalLesson`. Status: **proposed**.

**Authorization:** `[{"bearerAuth": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

| Parameter | Location | Required | Example |
|---|---|---|---|
| lessonId | path | True | `11111111-1111-4111-8111-111111111111` |
| X-Correlation-ID | header | False | `synthetic-X-Correlation-ID` |

**Sample request**

```http
GET /api/v1/practical-lessons/11111111-1111-4111-8111-111111111111 HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
X-Correlation-ID: synthetic-X-Correlation-ID
```

**Responses**

- **200** — Result

  Media type: `application/json`.

```json
{
  "lessonId": "11111111-1111-4111-8111-111111111111",
  "status": "Scheduled",
  "version": 1,
  "startsAt": "2026-12-01T10:00:00Z",
  "endsAt": "2026-12-01T11:00:00Z",
  "kind": "Practical"
}
```

- **400** — Invalid input

  Media type: `application/problem+json`.

```json
{
  "title": "Invalid input",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Authentication required

  Media type: `application/problem+json`.

```json
{
  "title": "Authentication required",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Access forbidden

  Media type: `application/problem+json`.

```json
{
  "title": "Access forbidden",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Resource not found or not visible

  Media type: `application/problem+json`.

```json
{
  "title": "Resource not found or not visible",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Business conflict

  Media type: `application/problem+json`.

```json
{
  "title": "Business conflict",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Business rule rejected

  Media type: `application/problem+json`.

```json
{
  "title": "Business rule rejected",
  "status": 422,
  "code": "BUSINESS_RULE_REJECTED",
  "correlationId": "integration-example-01"
}
```

- **503** — Dependency unavailable

  Media type: `application/problem+json`.

```json
{
  "title": "Dependency unavailable",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### POST /api/v1/practical-lessons/{lessonId}/completion

Mark scheduled lesson complete and store LessonCompleted Outbox event

Assigned teacher completes a Scheduled practical lesson with verified actualStart/actualEnd and expectedVersion. Enforce increasing, non-future actual time, exact school/lesson authority and CAS. Atomically append OLD state including actuals, persist Completed and a new revision, and enqueue LessonCompleted in an Outbox. Exact Idempotency-Key retries return the prior outcome; different payload or stale revision returns 409. Completion alone never credits minutes. G-01 storage is included in the local design; provider is not implemented.

Operation ID: `completePracticalLesson`. Status: **proposed-provider-design-amended-G-01**.

**Authorization:** `[{"bearerAuth": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

| Parameter | Location | Required | Example |
|---|---|---|---|
| X-Correlation-ID | header | False | `synthetic-X-Correlation-ID` |
| lessonId | path | True | `11111111-1111-4111-8111-111111111111` |
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/practical-lessons/11111111-1111-4111-8111-111111111111/completion HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
X-Correlation-ID: synthetic-X-Correlation-ID
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "expectedVersion": 1,
  "actualStart": "2026-12-01T10:05:00Z",
  "actualEnd": "2026-12-01T10:55:00Z"
}
```

**Responses**

- **200** — Accepted

  Media type: `application/json`.

```json
{
  "lessonId": "11111111-1111-4111-8111-111111111111",
  "status": "Completed",
  "version": 2,
  "startsAt": "2026-12-01T10:00:00Z",
  "endsAt": "2026-12-01T11:00:00Z",
  "kind": "Practical",
  "actualStart": "2026-12-01T10:05:00Z",
  "actualEnd": "2026-12-01T10:55:00Z"
}
```

- **400** — Invalid input

  Media type: `application/problem+json`.

```json
{
  "title": "Invalid input",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Authentication required

  Media type: `application/problem+json`.

```json
{
  "title": "Authentication required",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Access forbidden

  Media type: `application/problem+json`.

```json
{
  "title": "Access forbidden",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Resource not found or not visible

  Media type: `application/problem+json`.

```json
{
  "title": "Resource not found or not visible",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Business conflict

  Media type: `application/problem+json`.

```json
{
  "title": "Business conflict",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Business rule rejected

  Media type: `application/problem+json`.

```json
{
  "title": "Business rule rejected",
  "status": 422,
  "code": "BUSINESS_RULE_REJECTED",
  "correlationId": "integration-example-01"
}
```

- **503** — Dependency unavailable

  Media type: `application/problem+json`.

```json
{
  "title": "Dependency unavailable",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

**Invalid input example:** Missing required expectedVersion: reject with 400 before business work.

```json
{}
```

### POST /api/v1/scheduling-requests

Save an incomplete editable Draft Input Set

Save an incomplete editable Draft Input Set. Access is checked by the owning service for the authenticated actor and exact school/enrollment.

Operation ID: `createSchedulingDraft`. Status: **proposed**.

**Authorization:** `[{"bearerAuth": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

| Parameter | Location | Required | Example |
|---|---|---|---|
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/scheduling-requests HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "expectedRevision": 1
}
```

**Responses**

- **201** — Successful result

  Media type: `application/json`.

```json
{
  "requestId": "11111111-1111-4111-8111-111111111111",
  "revision": 1,
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "status": "Draft",
  "missingItems": []
}
```

- **400** — Invalid request

  Media type: `application/problem+json`.

```json
{
  "title": "Invalid request",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Authentication required

  Media type: `application/problem+json`.

```json
{
  "title": "Authentication required",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Permission denied

  Media type: `application/problem+json`.

```json
{
  "title": "Permission denied",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Resource not found or not visible

  Media type: `application/problem+json`.

```json
{
  "title": "Resource not found or not visible",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Current revision or resource conflict

  Media type: `application/problem+json`.

```json
{
  "title": "Current revision or resource conflict",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Business constraints reject the request

  Media type: `application/problem+json`.

```json
{
  "title": "Business constraints reject the request",
  "status": 422,
  "code": "BUSINESS_RULE_REJECTED",
  "correlationId": "integration-example-01"
}
```

- **503** — Authoritative dependency unavailable

  Media type: `application/problem+json`.

```json
{
  "title": "Authoritative dependency unavailable",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

**Invalid input example:** Missing required schoolId: reject with 400 before business work.

```json
{
  "expectedRevision": 1
}
```

### GET /api/v1/scheduling-requests/{requestId}

Read an authorized draft or frozen request

Read an authorized draft or frozen request. Access is checked by the owning service for the authenticated actor and exact school/enrollment.

Operation ID: `getSchedulingRequest`. Status: **proposed**.

**Authorization:** `[{"bearerAuth": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

| Parameter | Location | Required | Example |
|---|---|---|---|
| requestId | path | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
GET /api/v1/scheduling-requests/11111111-1111-4111-8111-111111111111 HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
{
  "requestId": "11111111-1111-4111-8111-111111111111",
  "revision": 1,
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "status": "Draft",
  "missingItems": []
}
```

- **400** — Invalid request

  Media type: `application/problem+json`.

```json
{
  "title": "Invalid request",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Authentication required

  Media type: `application/problem+json`.

```json
{
  "title": "Authentication required",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Permission denied

  Media type: `application/problem+json`.

```json
{
  "title": "Permission denied",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Resource not found or not visible

  Media type: `application/problem+json`.

```json
{
  "title": "Resource not found or not visible",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Current revision or resource conflict

  Media type: `application/problem+json`.

```json
{
  "title": "Current revision or resource conflict",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Business constraints reject the request

  Media type: `application/problem+json`.

```json
{
  "title": "Business constraints reject the request",
  "status": 422,
  "code": "BUSINESS_RULE_REJECTED",
  "correlationId": "integration-example-01"
}
```

- **503** — Authoritative dependency unavailable

  Media type: `application/problem+json`.

```json
{
  "title": "Authoritative dependency unavailable",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### PUT /api/v1/scheduling-requests/{requestId}

Replace draft inputs as a new draft revision

Replace draft inputs as a new draft revision. Access is checked by the owning service for the authenticated actor and exact school/enrollment. expectedRevision is mandatory for a revision; submitted snapshots cannot be edited. Copy into a new draft instead.

Operation ID: `reviseSchedulingDraft`. Status: **proposed**.

**Authorization:** `[{"bearerAuth": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

| Parameter | Location | Required | Example |
|---|---|---|---|
| requestId | path | True | `11111111-1111-4111-8111-111111111111` |
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
PUT /api/v1/scheduling-requests/11111111-1111-4111-8111-111111111111 HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "expectedRevision": 1
}
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
{
  "requestId": "11111111-1111-4111-8111-111111111111",
  "revision": 2,
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "status": "Draft",
  "missingItems": []
}
```

- **400** — Invalid request

  Media type: `application/problem+json`.

```json
{
  "title": "Invalid request",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Authentication required

  Media type: `application/problem+json`.

```json
{
  "title": "Authentication required",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Permission denied

  Media type: `application/problem+json`.

```json
{
  "title": "Permission denied",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Resource not found or not visible

  Media type: `application/problem+json`.

```json
{
  "title": "Resource not found or not visible",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Current revision or resource conflict

  Media type: `application/problem+json`.

```json
{
  "title": "Current revision or resource conflict",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Business constraints reject the request

  Media type: `application/problem+json`.

```json
{
  "title": "Business constraints reject the request",
  "status": 422,
  "code": "BUSINESS_RULE_REJECTED",
  "correlationId": "integration-example-01"
}
```

- **503** — Authoritative dependency unavailable

  Media type: `application/problem+json`.

```json
{
  "title": "Authoritative dependency unavailable",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### POST /api/v1/scheduling-requests/{requestId}/submissions

Validate complete inputs and freeze an immutable request revision

Validate complete inputs and freeze an immutable request revision. Access is checked by the owning service for the authenticated actor and exact school/enrollment.

Operation ID: `submitSchedulingRequest`. Status: **proposed**.

**Authorization:** `[{"bearerAuth": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

| Parameter | Location | Required | Example |
|---|---|---|---|
| requestId | path | True | `11111111-1111-4111-8111-111111111111` |
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/scheduling-requests/11111111-1111-4111-8111-111111111111/submissions HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "expectedRevision": 1
}
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
{
  "requestId": "11111111-1111-4111-8111-111111111111",
  "revision": 1,
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "status": "Draft",
  "missingItems": []
}
```

- **400** — Invalid request

  Media type: `application/problem+json`.

```json
{
  "title": "Invalid request",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Authentication required

  Media type: `application/problem+json`.

```json
{
  "title": "Authentication required",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Permission denied

  Media type: `application/problem+json`.

```json
{
  "title": "Permission denied",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Resource not found or not visible

  Media type: `application/problem+json`.

```json
{
  "title": "Resource not found or not visible",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Current revision or resource conflict

  Media type: `application/problem+json`.

```json
{
  "title": "Current revision or resource conflict",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Business constraints reject the request

  Media type: `application/problem+json`.

```json
{
  "title": "Business constraints reject the request",
  "status": 422,
  "code": "BUSINESS_RULE_REJECTED",
  "correlationId": "integration-example-01"
}
```

- **503** — Authoritative dependency unavailable

  Media type: `application/problem+json`.

```json
{
  "title": "Authoritative dependency unavailable",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

**Invalid input example:** Missing required expectedRevision: reject with 400 before business work.

```json
{}
```

### POST /api/v1/scheduling-requests/{requestId}/proposals

Generate an unconfirmed proposal or explain safe infeasibility

Generate an unconfirmed proposal or explain safe infeasibility. Access is checked by the owning service for the authenticated actor and exact school/enrollment.

Operation ID: `generateScheduleProposal`. Status: **proposed**.

**Authorization:** `[{"bearerAuth": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

| Parameter | Location | Required | Example |
|---|---|---|---|
| requestId | path | True | `11111111-1111-4111-8111-111111111111` |
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/scheduling-requests/11111111-1111-4111-8111-111111111111/proposals HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "expectedRevision": 1
}
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
{
  "requestId": "11111111-1111-4111-8111-111111111111",
  "revision": 1,
  "status": "Ready",
  "lessons": [
    {
      "schoolId": "11111111-1111-4111-8111-111111111111",
      "branchId": "11111111-1111-4111-8111-111111111111",
      "enrollmentId": "11111111-1111-4111-8111-111111111111",
      "studentId": "11111111-1111-4111-8111-111111111111",
      "teacherId": "11111111-1111-4111-8111-111111111111",
      "vehicleId": "11111111-1111-4111-8111-111111111111",
      "category": "B",
      "startsAt": "2026-12-01T10:00:00Z",
      "endsAt": "2026-12-01T11:00:00Z"
    }
  ],
  "issues": [],
  "theoryLessons": [
    {
      "schoolId": "11111111-1111-4111-8111-111111111111",
      "groupId": "11111111-1111-4111-8111-111111111111",
      "teacherId": "11111111-1111-4111-8111-111111111111",
      "classroomId": "11111111-1111-4111-8111-111111111111",
      "startsAt": "2026-12-01T10:00:00Z",
      "endsAt": "2026-12-01T11:00:00Z"
    }
  ]
}
```

- **400** — Invalid request

  Media type: `application/problem+json`.

```json
{
  "title": "Invalid request",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Authentication required

  Media type: `application/problem+json`.

```json
{
  "title": "Authentication required",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Permission denied

  Media type: `application/problem+json`.

```json
{
  "title": "Permission denied",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Resource not found or not visible

  Media type: `application/problem+json`.

```json
{
  "title": "Resource not found or not visible",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Current revision or resource conflict

  Media type: `application/problem+json`.

```json
{
  "title": "Current revision or resource conflict",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Business constraints reject the request

  Media type: `application/problem+json`.

```json
{
  "title": "Business constraints reject the request",
  "status": 422,
  "code": "BUSINESS_RULE_REJECTED",
  "correlationId": "integration-example-01"
}
```

- **503** — Authoritative dependency unavailable

  Media type: `application/problem+json`.

```json
{
  "title": "Authoritative dependency unavailable",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

**Invalid input example:** Missing required expectedRevision: reject with 400 before business work.

```json
{}
```

### POST /api/v1/scheduling-requests/{requestId}/confirmations

Revalidate exact proposal and atomically commit reservations

Revalidate exact proposal and atomically commit reservations. Access is checked by the owning service for the authenticated actor and exact school/enrollment. Unknown reservation outcome is ReconciliationPending; retain the protective reservation and reconcile by operation identity. AC-099 privacy/legal clearance and trusted global-person binding are required before real-data availability checks.

Operation ID: `confirmScheduleProposal`. Status: **proposed**.

**Authorization:** `[{"bearerAuth": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

| Parameter | Location | Required | Example |
|---|---|---|---|
| requestId | path | True | `11111111-1111-4111-8111-111111111111` |
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/scheduling-requests/11111111-1111-4111-8111-111111111111/confirmations HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "expectedRevision": 1
}
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "status": "Pending",
  "lessonIds": [
    "11111111-1111-4111-8111-111111111111"
  ]
}
```

- **400** — Invalid request

  Media type: `application/problem+json`.

```json
{
  "title": "Invalid request",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Authentication required

  Media type: `application/problem+json`.

```json
{
  "title": "Authentication required",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Permission denied

  Media type: `application/problem+json`.

```json
{
  "title": "Permission denied",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Resource not found or not visible

  Media type: `application/problem+json`.

```json
{
  "title": "Resource not found or not visible",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Current revision or resource conflict

  Media type: `application/problem+json`.

```json
{
  "title": "Current revision or resource conflict",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Business constraints reject the request

  Media type: `application/problem+json`.

```json
{
  "title": "Business constraints reject the request",
  "status": 422,
  "code": "BUSINESS_RULE_REJECTED",
  "correlationId": "integration-example-01"
}
```

- **503** — Authoritative dependency unavailable

  Media type: `application/problem+json`.

```json
{
  "title": "Authoritative dependency unavailable",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

- **202** — Reconciliation pending; do not assume rollback or availability. Query the operation with the same Idempotency-Key.

  Media type: `application/json`.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "status": "Pending",
  "lessonIds": [
    "11111111-1111-4111-8111-111111111111"
  ]
}
```

**Invalid input example:** Missing required expectedRevision: reject with 400 before business work.

```json
{}
```

### GET /api/v1/scheduling-operations/{operationId}

Reconcile a timed-out command by its stable identity

Reconcile a timed-out command by its stable identity. Access is checked by the owning service for the authenticated actor and exact school/enrollment.

Operation ID: `getSchedulingOperation`. Status: **proposed**.

**Authorization:** `[{"bearerAuth": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

| Parameter | Location | Required | Example |
|---|---|---|---|
| operationId | path | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
GET /api/v1/scheduling-operations/11111111-1111-4111-8111-111111111111 HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "status": "Pending",
  "lessonIds": [
    "11111111-1111-4111-8111-111111111111"
  ]
}
```

- **400** — Invalid request

  Media type: `application/problem+json`.

```json
{
  "title": "Invalid request",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Authentication required

  Media type: `application/problem+json`.

```json
{
  "title": "Authentication required",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Permission denied

  Media type: `application/problem+json`.

```json
{
  "title": "Permission denied",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Resource not found or not visible

  Media type: `application/problem+json`.

```json
{
  "title": "Resource not found or not visible",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Current revision or resource conflict

  Media type: `application/problem+json`.

```json
{
  "title": "Current revision or resource conflict",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Business constraints reject the request

  Media type: `application/problem+json`.

```json
{
  "title": "Business constraints reject the request",
  "status": 422,
  "code": "BUSINESS_RULE_REJECTED",
  "correlationId": "integration-example-01"
}
```

- **503** — Authoritative dependency unavailable

  Media type: `application/problem+json`.

```json
{
  "title": "Authoritative dependency unavailable",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### POST /api/v1/practical-lessons/{lessonId}/rescheduling

Move an authorized lesson with history and global conflict checks

Move an authorized lesson with history and global conflict checks. Access is checked by the owning service for the authenticated actor and exact school/enrollment. Unknown reservation outcome is ReconciliationPending; retain the protective reservation and reconcile by operation identity. AC-099 privacy/legal clearance and trusted global-person binding are required before real-data availability checks.

Operation ID: `reschedulePracticalLesson`. Status: **proposed**.

**Authorization:** `[{"bearerAuth": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

| Parameter | Location | Required | Example |
|---|---|---|---|
| lessonId | path | True | `11111111-1111-4111-8111-111111111111` |
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/practical-lessons/11111111-1111-4111-8111-111111111111/rescheduling HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "expectedVersion": 1,
  "startsAt": "2026-12-01T10:00:00Z",
  "endsAt": "2026-12-01T11:00:00Z",
  "reason": "Instructor requested a schedule correction."
}
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
{
  "lessonId": "11111111-1111-4111-8111-111111111111",
  "status": "Scheduled",
  "version": 2,
  "startsAt": "2026-12-01T10:00:00Z",
  "endsAt": "2026-12-01T11:00:00Z",
  "kind": "Practical"
}
```

- **400** — Invalid request

  Media type: `application/problem+json`.

```json
{
  "title": "Invalid request",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Authentication required

  Media type: `application/problem+json`.

```json
{
  "title": "Authentication required",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Permission denied

  Media type: `application/problem+json`.

```json
{
  "title": "Permission denied",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Resource not found or not visible

  Media type: `application/problem+json`.

```json
{
  "title": "Resource not found or not visible",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Current revision or resource conflict

  Media type: `application/problem+json`.

```json
{
  "title": "Current revision or resource conflict",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Business constraints reject the request

  Media type: `application/problem+json`.

```json
{
  "title": "Business constraints reject the request",
  "status": 422,
  "code": "BUSINESS_RULE_REJECTED",
  "correlationId": "integration-example-01"
}
```

- **503** — Authoritative dependency unavailable

  Media type: `application/problem+json`.

```json
{
  "title": "Authoritative dependency unavailable",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

- **202** — Reconciliation pending; do not assume rollback or availability. Query the operation with the same Idempotency-Key.

  Media type: `application/json`.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "status": "Pending",
  "lessonIds": [
    "11111111-1111-4111-8111-111111111111"
  ]
}
```

**Invalid input example:** Missing required expectedVersion: reject with 400 before business work.

```json
{
  "startsAt": "2026-12-01T10:00:00Z",
  "endsAt": "2026-12-01T11:00:00Z",
  "reason": "Instructor requested a schedule correction."
}
```

### POST /api/v1/practical-lessons/{lessonId}/cancellation

Cancel a lesson and release its reservations

Cancel a lesson and release its reservations. Access is checked by the owning service for the authenticated actor and exact school/enrollment.

Operation ID: `cancelPracticalLesson`. Status: **proposed**.

**Authorization:** `[{"bearerAuth": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

| Parameter | Location | Required | Example |
|---|---|---|---|
| lessonId | path | True | `11111111-1111-4111-8111-111111111111` |
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/practical-lessons/11111111-1111-4111-8111-111111111111/cancellation HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "expectedVersion": 1,
  "reason": "Instructor requested a schedule correction."
}
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
{
  "lessonId": "11111111-1111-4111-8111-111111111111",
  "status": "Scheduled",
  "version": 1,
  "startsAt": "2026-12-01T10:00:00Z",
  "endsAt": "2026-12-01T11:00:00Z",
  "kind": "Practical"
}
```

- **400** — Invalid request

  Media type: `application/problem+json`.

```json
{
  "title": "Invalid request",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Authentication required

  Media type: `application/problem+json`.

```json
{
  "title": "Authentication required",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Permission denied

  Media type: `application/problem+json`.

```json
{
  "title": "Permission denied",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Resource not found or not visible

  Media type: `application/problem+json`.

```json
{
  "title": "Resource not found or not visible",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Current revision or resource conflict

  Media type: `application/problem+json`.

```json
{
  "title": "Current revision or resource conflict",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Business constraints reject the request

  Media type: `application/problem+json`.

```json
{
  "title": "Business constraints reject the request",
  "status": 422,
  "code": "BUSINESS_RULE_REJECTED",
  "correlationId": "integration-example-01"
}
```

- **503** — Authoritative dependency unavailable

  Media type: `application/problem+json`.

```json
{
  "title": "Authoritative dependency unavailable",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

**Invalid input example:** Missing required expectedVersion: reject with 400 before business work.

```json
{
  "reason": "Instructor requested a schedule correction."
}
```

### POST /api/v1/theory-lessons

Reserve a theory lesson and frozen group roster

Reserve a theory lesson and frozen group roster. Access is checked by the owning service for the authenticated actor and exact school/enrollment.

Operation ID: `createTheoryLesson`. Status: **proposed**.

**Authorization:** `[{"bearerAuth": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

| Parameter | Location | Required | Example |
|---|---|---|---|
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/theory-lessons HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "groupId": "11111111-1111-4111-8111-111111111111",
  "teacherId": "11111111-1111-4111-8111-111111111111",
  "classroomId": "11111111-1111-4111-8111-111111111111",
  "startsAt": "2026-12-01T10:00:00Z",
  "endsAt": "2026-12-01T11:00:00Z"
}
```

**Responses**

- **201** — Successful result

  Media type: `application/json`.

```json
{
  "lessonId": "11111111-1111-4111-8111-111111111111",
  "status": "Scheduled",
  "version": 1,
  "startsAt": "2026-12-01T10:00:00Z",
  "endsAt": "2026-12-01T11:00:00Z",
  "kind": "Practical"
}
```

- **400** — Invalid request

  Media type: `application/problem+json`.

```json
{
  "title": "Invalid request",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Authentication required

  Media type: `application/problem+json`.

```json
{
  "title": "Authentication required",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Permission denied

  Media type: `application/problem+json`.

```json
{
  "title": "Permission denied",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Resource not found or not visible

  Media type: `application/problem+json`.

```json
{
  "title": "Resource not found or not visible",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Current revision or resource conflict

  Media type: `application/problem+json`.

```json
{
  "title": "Current revision or resource conflict",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Business constraints reject the request

  Media type: `application/problem+json`.

```json
{
  "title": "Business constraints reject the request",
  "status": 422,
  "code": "BUSINESS_RULE_REJECTED",
  "correlationId": "integration-example-01"
}
```

- **503** — Authoritative dependency unavailable

  Media type: `application/problem+json`.

```json
{
  "title": "Authoritative dependency unavailable",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

**Invalid input example:** Missing required schoolId: reject with 400 before business work.

```json
{
  "groupId": "11111111-1111-4111-8111-111111111111",
  "teacherId": "11111111-1111-4111-8111-111111111111",
  "classroomId": "11111111-1111-4111-8111-111111111111",
  "startsAt": "2026-12-01T10:00:00Z",
  "endsAt": "2026-12-01T11:00:00Z"
}
```

### GET /api/v1/users/me/lessons

List only the authenticated student or assigned instructor lessons

List only the authenticated student or assigned instructor lessons. Access is checked by the owning service for the authenticated actor and exact school/enrollment.

Operation ID: `getMyLessons`. Status: **proposed**.

**Authorization:** `[{"bearerAuth": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

| Parameter | Location | Required | Example |
|---|---|---|---|
| from | query | True | `2026-12-01T10:00:00Z` |
| to | query | True | `2026-12-01T12:00:00Z` |

**Sample request**

```http
GET /api/v1/users/me/lessons?from=2026-12-01T10%3A00%3A00Z&to=2026-12-01T12%3A00%3A00Z HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
[
  {
    "lessonId": "11111111-1111-4111-8111-111111111111",
    "status": "Scheduled",
    "version": 1,
    "startsAt": "2026-12-01T10:00:00Z",
    "endsAt": "2026-12-01T11:00:00Z",
    "kind": "Practical"
  }
]
```

- **400** — Invalid request

  Media type: `application/problem+json`.

```json
{
  "title": "Invalid request",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Authentication required

  Media type: `application/problem+json`.

```json
{
  "title": "Authentication required",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Permission denied

  Media type: `application/problem+json`.

```json
{
  "title": "Permission denied",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Resource not found or not visible

  Media type: `application/problem+json`.

```json
{
  "title": "Resource not found or not visible",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Current revision or resource conflict

  Media type: `application/problem+json`.

```json
{
  "title": "Current revision or resource conflict",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Business constraints reject the request

  Media type: `application/problem+json`.

```json
{
  "title": "Business constraints reject the request",
  "status": 422,
  "code": "BUSINESS_RULE_REJECTED",
  "correlationId": "integration-example-01"
}
```

- **503** — Authoritative dependency unavailable

  Media type: `application/problem+json`.

```json
{
  "title": "Authoritative dependency unavailable",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### GET /api/v1/schools/{schoolId}/availability

Find authorized slots without exposing foreign tenant reservations

Find authorized slots without exposing foreign tenant reservations. Access is checked by the owning service for the authenticated actor and exact school/enrollment.

Operation ID: `findAvailableLessons`. Status: **proposed**.

**Authorization:** `[{"bearerAuth": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

| Parameter | Location | Required | Example |
|---|---|---|---|
| schoolId | path | True | `11111111-1111-4111-8111-111111111111` |
| from | query | True | `2026-12-01T10:00:00Z` |
| to | query | True | `2026-12-01T12:00:00Z` |
| enrollmentId | query | True | `11111111-1111-4111-8111-111111111111` |
| teacherId | query | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
GET /api/v1/schools/11111111-1111-4111-8111-111111111111/availability?from=2026-12-01T10%3A00%3A00Z&to=2026-12-01T12%3A00%3A00Z&enrollmentId=11111111-1111-4111-8111-111111111111&teacherId=11111111-1111-4111-8111-111111111111 HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
{
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "slots": [
    {
      "startsAt": "2026-12-01T10:00:00Z",
      "endsAt": "2026-12-01T11:00:00Z",
      "teacherId": "11111111-1111-4111-8111-111111111111",
      "vehicleId": "11111111-1111-4111-8111-111111111111"
    }
  ]
}
```

- **400** — Invalid request

  Media type: `application/problem+json`.

```json
{
  "title": "Invalid request",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Authentication required

  Media type: `application/problem+json`.

```json
{
  "title": "Authentication required",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Permission denied

  Media type: `application/problem+json`.

```json
{
  "title": "Permission denied",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Resource not found or not visible

  Media type: `application/problem+json`.

```json
{
  "title": "Resource not found or not visible",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Current revision or resource conflict

  Media type: `application/problem+json`.

```json
{
  "title": "Current revision or resource conflict",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Business constraints reject the request

  Media type: `application/problem+json`.

```json
{
  "title": "Business constraints reject the request",
  "status": 422,
  "code": "BUSINESS_RULE_REJECTED",
  "correlationId": "integration-example-01"
}
```

- **503** — Authoritative dependency unavailable

  Media type: `application/problem+json`.

```json
{
  "title": "Authoritative dependency unavailable",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### POST /api/v1/schools/{schoolId}/scheduling-rule-versions

Create an audited school restriction that cannot weaken verified law

Create an audited school restriction that cannot weaken verified law. Access is checked by the owning service for the authenticated actor and exact school/enrollment.

Operation ID: `createSchoolRuleVersion`. Status: **proposed**.

**Authorization:** `[{"bearerAuth": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

| Parameter | Location | Required | Example |
|---|---|---|---|
| schoolId | path | True | `11111111-1111-4111-8111-111111111111` |
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/schools/11111111-1111-4111-8111-111111111111/scheduling-rule-versions HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "ruleType": "MAX_LESSONS_PER_STUDENT_PER_DAY",
  "value": 4,
  "unit": "Lessons",
  "scopeKind": "School",
  "effectiveFrom": "2026-12-01T00:00:00Z",
  "sourceReference": "urn:vairas:synthetic:school-policy",
  "expectedRevision": 1
}
```

**Responses**

- **201** — Successful result

  Media type: `application/json`.

```json
{
  "ruleVersionId": "11111111-1111-4111-8111-111111111111",
  "revision": 1,
  "status": "Pending"
}
```

- **400** — Invalid request

  Media type: `application/problem+json`.

```json
{
  "title": "Invalid request",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Authentication required

  Media type: `application/problem+json`.

```json
{
  "title": "Authentication required",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Permission denied

  Media type: `application/problem+json`.

```json
{
  "title": "Permission denied",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Resource not found or not visible

  Media type: `application/problem+json`.

```json
{
  "title": "Resource not found or not visible",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Current revision or resource conflict

  Media type: `application/problem+json`.

```json
{
  "title": "Current revision or resource conflict",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Business constraints reject the request

  Media type: `application/problem+json`.

```json
{
  "title": "Business constraints reject the request",
  "status": 422,
  "code": "BUSINESS_RULE_REJECTED",
  "correlationId": "integration-example-01"
}
```

- **503** — Authoritative dependency unavailable

  Media type: `application/problem+json`.

```json
{
  "title": "Authoritative dependency unavailable",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

**Invalid input example:** Missing required schoolId: reject with 400 before business work.

```json
{
  "ruleType": "MAX_LESSONS_PER_STUDENT_PER_DAY",
  "value": 4,
  "unit": "Lessons",
  "scopeKind": "School",
  "effectiveFrom": "2026-12-01T00:00:00Z",
  "sourceReference": "urn:vairas:synthetic:school-policy",
  "expectedRevision": 1
}
```

### POST /api/v1/assessment-appointments

Schedule an additional or repeated assessment after authoritative readiness checks

Schedule an additional or repeated assessment after authoritative readiness checks. Access is checked by the owning service for the authenticated actor and exact school/enrollment.

Operation ID: `scheduleAssessmentAppointment`. Status: **proposed**.

**Authorization:** `[{"bearerAuth": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

| Parameter | Location | Required | Example |
|---|---|---|---|
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/assessment-appointments HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "enrollmentId": "11111111-1111-4111-8111-111111111111",
  "assessmentDefinitionVersionId": "11111111-1111-4111-8111-111111111111",
  "readinessEvaluationId": "11111111-1111-4111-8111-111111111111",
  "teacherId": "11111111-1111-4111-8111-111111111111",
  "startsAt": "2026-12-01T10:00:00Z",
  "endsAt": "2026-12-01T11:00:00Z"
}
```

**Responses**

- **201** — Successful result

  Media type: `application/json`.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "status": "Pending",
  "lessonIds": [
    "11111111-1111-4111-8111-111111111111"
  ]
}
```

- **400** — Invalid request

  Media type: `application/problem+json`.

```json
{
  "title": "Invalid request",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Authentication required

  Media type: `application/problem+json`.

```json
{
  "title": "Authentication required",
  "status": 401,
  "code": "UNAUTHENTICATED",
  "correlationId": "integration-example-01"
}
```

- **403** — Permission denied

  Media type: `application/problem+json`.

```json
{
  "title": "Permission denied",
  "status": 403,
  "code": "FORBIDDEN",
  "correlationId": "integration-example-01"
}
```

- **404** — Resource not found or not visible

  Media type: `application/problem+json`.

```json
{
  "title": "Resource not found or not visible",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Current revision or resource conflict

  Media type: `application/problem+json`.

```json
{
  "title": "Current revision or resource conflict",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Business constraints reject the request

  Media type: `application/problem+json`.

```json
{
  "title": "Business constraints reject the request",
  "status": 422,
  "code": "BUSINESS_RULE_REJECTED",
  "correlationId": "integration-example-01"
}
```

- **503** — Authoritative dependency unavailable

  Media type: `application/problem+json`.

```json
{
  "title": "Authoritative dependency unavailable",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

**Invalid input example:** Missing required schoolId: reject with 400 before business work.

```json
{
  "enrollmentId": "11111111-1111-4111-8111-111111111111",
  "assessmentDefinitionVersionId": "11111111-1111-4111-8111-111111111111",
  "readinessEvaluationId": "11111111-1111-4111-8111-111111111111",
  "teacherId": "11111111-1111-4111-8111-111111111111",
  "startsAt": "2026-12-01T10:00:00Z",
  "endsAt": "2026-12-01T11:00:00Z"
}
```

### GET /internal/v1/lessons/{lessonId}/training-source

Read authoritative physical lifecycle and actual interval for Learning Tracking

G-01 storage/lifecycle amendment is included in the local Scheduling design. Return one consistent authoritative lesson revision and its physical interval and identities. No provider is implemented yet. Completed-and-valid requires verified increasing actual bounds; legacy missing actuals return sourceValid=false and both actual fields null. Planned time cannot substitute. Learning binds the verified current lessonRevision to an immutable snapshot; source corrections require new fact versions and confirmations.

Operation ID: `getLessonTrainingSource`. Status: **proposed-provider-design-amended-G-01**.

**Authorization:** `[{"workloadBearer": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

| Parameter | Location | Required | Example |
|---|---|---|---|
| lessonId | path | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
GET /internal/v1/lessons/11111111-1111-4111-8111-111111111111/training-source HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
{
  "lessonId": "11111111-1111-4111-8111-111111111111",
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "lessonRevision": 2,
  "kind": "Practical",
  "physicallyCompleted": true,
  "sourceValid": true,
  "actualStart": "2026-12-01T10:00:00Z",
  "actualEnd": "2026-12-01T11:00:00Z",
  "groupMembershipRevision": null,
  "teacherId": "11111111-1111-4111-8111-111111111111",
  "enrollmentId": "11111111-1111-4111-8111-111111111111",
  "studentId": "11111111-1111-4111-8111-111111111111",
  "vehicleId": "11111111-1111-4111-8111-111111111111",
  "groupId": null
}
```

- **400** — Invalid request

  Media type: `application/problem+json`.

```json
{
  "title": "The request was rejected.",
  "status": 400,
  "code": "REQUEST_REJECTED",
  "correlationId": "integration-example-01"
}
```

- **401** — Authentication required

  Media type: `application/problem+json`.

```json
{
  "title": "The request was rejected.",
  "status": 401,
  "code": "REQUEST_REJECTED",
  "correlationId": "integration-example-01"
}
```

- **403** — Permission denied

  Media type: `application/problem+json`.

```json
{
  "title": "The request was rejected.",
  "status": 403,
  "code": "REQUEST_REJECTED",
  "correlationId": "integration-example-01"
}
```

- **404** — Resource not found or not visible

  Media type: `application/problem+json`.

```json
{
  "title": "The request was rejected.",
  "status": 404,
  "code": "REQUEST_REJECTED",
  "correlationId": "integration-example-01"
}
```

- **409** — Current revision or resource conflict

  Media type: `application/problem+json`.

```json
{
  "title": "The request was rejected.",
  "status": 409,
  "code": "REQUEST_REJECTED",
  "correlationId": "integration-example-01"
}
```

- **422** — Business constraints reject the request

  Media type: `application/problem+json`.

```json
{
  "title": "The request was rejected.",
  "status": 422,
  "code": "REQUEST_REJECTED",
  "correlationId": "integration-example-01"
}
```

- **503** — Authoritative dependency unavailable

  Media type: `application/problem+json`.

```json
{
  "title": "The request was rejected.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### POST /api/v1/theory-lessons/{lessonId}/completion

Mark scheduled lesson complete and store LessonCompleted Outbox event

Assigned teacher completes a Scheduled theory lesson with verified actualStart/actualEnd and expectedVersion. Enforce increasing, non-future actual time, exact school/lesson authority and CAS. Atomically append OLD state including actuals, persist Completed and a new revision, and enqueue LessonCompleted in an Outbox. Exact Idempotency-Key retries return the prior outcome; different payload or stale revision returns 409. Completion alone never credits minutes. G-01 storage is included in the local design; provider is not implemented. Preserve the verified historical group membership revision; this command does not record attendance.

Operation ID: `completeTheoryLesson`. Status: **proposed-provider-design-amended-G-01**.

**Authorization:** `[{"bearerAuth": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

| Parameter | Location | Required | Example |
|---|---|---|---|
| X-Correlation-ID | header | False | `synthetic-X-Correlation-ID` |
| lessonId | path | True | `11111111-1111-4111-8111-111111111111` |
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/theory-lessons/11111111-1111-4111-8111-111111111111/completion HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
X-Correlation-ID: synthetic-X-Correlation-ID
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "expectedVersion": 1,
  "actualStart": "2026-12-01T10:05:00Z",
  "actualEnd": "2026-12-01T10:55:00Z"
}
```

**Responses**

- **200** — Accepted

  Media type: `application/json`.

```json
{
  "lessonId": "11111111-1111-4111-8111-111111111111",
  "status": "Completed",
  "version": 2,
  "startsAt": "2026-12-01T10:00:00Z",
  "endsAt": "2026-12-01T11:00:00Z",
  "kind": "Theory",
  "actualStart": "2026-12-01T10:05:00Z",
  "actualEnd": "2026-12-01T10:55:00Z"
}
```

- **400** — Invalid input

  Media type: `application/problem+json`.

```json
{
  "title": "Invalid input",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Authentication required

  Media type: `application/problem+json`.

```json
{
  "title": "Authentication required",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Access forbidden

  Media type: `application/problem+json`.

```json
{
  "title": "Access forbidden",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Resource not found or not visible

  Media type: `application/problem+json`.

```json
{
  "title": "Resource not found or not visible",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Business conflict

  Media type: `application/problem+json`.

```json
{
  "title": "Business conflict",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Business rule rejected

  Media type: `application/problem+json`.

```json
{
  "title": "Business rule rejected",
  "status": 422,
  "code": "BUSINESS_RULE_REJECTED",
  "correlationId": "integration-example-01"
}
```

- **503** — Dependency unavailable

  Media type: `application/problem+json`.

```json
{
  "title": "Dependency unavailable",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

**Invalid input example:** Missing required expectedVersion: reject with 400 before business work.

```json
{}
```

### PATCH /api/v1/lessons/{lessonId}/actual-interval

Correct a completed lesson physical interval with an audited new revision

Authorized assigned teacher or explicitly authorized correcting actor updates a Completed practical/theory interval with expectedVersion and a required correction reason. Validate scope, increasing non-future interval and exact Idempotency-Key binding. Atomically retain OLD state, update actuals and revision, and enqueue a new-revision LessonCompleted reconciliation signal through Outbox. Preserve planned interval. Existing Learning facts and confirmations are not transferred: reconcile source, block old credit, create new fact versions and obtain fresh required confirmations. Legacy Completed rows without actuals can be repaired only from trusted evidence; no planned-time backfill.

Operation ID: `correctLessonActualInterval`. Status: **proposed-provider-design-amended-G-01**.

**Authorization:** `[{"bearerAuth": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

| Parameter | Location | Required | Example |
|---|---|---|---|
| X-Correlation-ID | header | False | `synthetic-X-Correlation-ID` |
| lessonId | path | True | `11111111-1111-4111-8111-111111111111` |
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
PATCH /api/v1/lessons/11111111-1111-4111-8111-111111111111/actual-interval HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
X-Correlation-ID: synthetic-X-Correlation-ID
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "expectedVersion": 2,
  "actualStart": "2026-12-01T10:05:00Z",
  "actualEnd": "2026-12-01T10:55:00Z",
  "reason": "Verified correction of the recorded physical interval."
}
```

**Responses**

- **200** — Accepted

  Media type: `application/json`.

```json
{
  "lessonId": "11111111-1111-4111-8111-111111111111",
  "status": "Completed",
  "version": 3,
  "startsAt": "2026-12-01T10:00:00Z",
  "endsAt": "2026-12-01T11:00:00Z",
  "kind": "Practical",
  "actualStart": "2026-12-01T10:05:00Z",
  "actualEnd": "2026-12-01T10:55:00Z"
}
```

- **400** — Invalid input

  Media type: `application/problem+json`.

```json
{
  "title": "Invalid input",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Authentication required

  Media type: `application/problem+json`.

```json
{
  "title": "Authentication required",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Access forbidden

  Media type: `application/problem+json`.

```json
{
  "title": "Access forbidden",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Resource not found or not visible

  Media type: `application/problem+json`.

```json
{
  "title": "Resource not found or not visible",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Business conflict

  Media type: `application/problem+json`.

```json
{
  "title": "Business conflict",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Business rule rejected

  Media type: `application/problem+json`.

```json
{
  "title": "Business rule rejected",
  "status": 422,
  "code": "BUSINESS_RULE_REJECTED",
  "correlationId": "integration-example-01"
}
```

- **503** — Dependency unavailable

  Media type: `application/problem+json`.

```json
{
  "title": "Dependency unavailable",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

**Invalid input example:** Missing required expectedVersion: reject with 400 before business work.

```json
{}
```

## Data models

Required fields, nullability, constraints and descriptions are authoritative in the YAML. Conditional and composed schemas are shown below.

### Problem

Problem. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| title | True | `string` | {} |
| status | True | `integer` | {} |
| code | True | `string` | {} |
| correlationId | True | `string` | {} |

### CreatePracticalLesson

Additional practical lessons use this command; repeated assessments require an assessment appointment and Learning Tracking readiness, not a synthetic LessonCompleted credit.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| schoolId | True | `string` | {"format": "uuid"} |
| branchId | True | `string` | {"format": "uuid"} |
| enrollmentId | True | `string` | {"format": "uuid"} |
| studentId | True | `string` | {"format": "uuid"} |
| teacherId | True | `string` | {"format": "uuid"} |
| vehicleId | True | `string` | {"format": "uuid"} |
| category | True | `string` | {} |
| startsAt | True | `string` | {"format": "date-time"} |
| endsAt | True | `string` | {"format": "date-time"} |

### PracticalLesson

Lesson view for practical or theory kind; actual fields describe physical elapsed time, never credited teaching minutes.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| lessonId | True | `string` | {"format": "uuid"} |
| status | True | `string` | {"enum": ["Scheduled", "Completed", "Cancelled", "NoShow"]} |
| version | True | `integer` | {"minimum": 1} |
| startsAt | False | `string` | {"format": "date-time"} |
| endsAt | False | `string` | {"format": "date-time"} |
| kind | False | `string` | {"enum": ["Practical", "Theory"]} |
| actualStart | False | `['string', 'null']` | {"format": "date-time"} |
| actualEnd | False | `['string', 'null']` | {"format": "date-time"} |

### CompleteLesson

G-01 local design amendment: persist the verified actual interval with the lifecycle revision. Both bounds are required; actualEnd must exceed actualStart and cannot be in the future at acceptance. Planned time is never a fallback. Service implementation remains required.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| expectedVersion | True | `integer` | {"minimum": 1} |
| actualStart | True | `string` | {"format": "date-time"} |
| actualEnd | True | `string` | {"format": "date-time"} |

### DraftInputs

Incomplete fields allowed only in Draft. Submission requires programme, same-school enrollments/groups/resources, time windows and verified applicable rules. PUT additionally requires expectedRevision.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| schoolId | True | `string` | {"format": "uuid"} |
| programVersionId | False | `string` | {"format": "uuid"} |
| enrollmentIds | False | `array` | {"items": {"type": "string", "format": "uuid"}} |
| groupIds | False | `array` | {"items": {"type": "string", "format": "uuid"}} |
| teacherIds | False | `array` | {"items": {"type": "string", "format": "uuid"}} |
| vehicleIds | False | `array` | {"items": {"type": "string", "format": "uuid"}} |
| planningStart | False | `string` | {"format": "date"} |
| planningEnd | False | `string` | {"format": "date"} |
| ruleVersionIds | False | `array` | {"items": {"type": "string", "format": "uuid"}} |
| windows | False | `array` | {"items": {"type": "object", "required": ["startsAt", "endsAt"], "properties": {"startsAt": {"type": "string", "format": "date-time"}, "endsAt": {"type": "string", "format": "date-time"}}, "description": "Planning window uses UTC instants; conversion from school-local planning dates must handle Europe/Vilnius daylight saving."}} |
| preferences | False | `array` | {"items": {"type": "string"}, "description": "Human-readable preferences are informational draft inputs only. Only published typed rule versions can affect generation; unparsed strings cannot enforce policy."} |
| expectedRevision | False | `integer` | {"minimum": 1} |
| draftRevision | False | `integer` | {"minimum": 1, "description": "Draft input version; PUT compares expectedRevision to the current revision."} |

### SchedulingRequest

Scheduling Request. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| requestId | True | `string` | {"format": "uuid"} |
| revision | True | `integer` | {"minimum": 1} |
| schoolId | True | `string` | {"format": "uuid"} |
| status | True | `string` | {"enum": ["Draft", "Submitted", "Ready", "Infeasible", "Rejected", "Stale", "Superseded", "Confirmed"]} |
| missingItems | True | `array` | {"items": {"type": "string"}} |

### ExpectedRevision

Expected Revision. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| expectedRevision | True | `integer` | {"minimum": 1} |

### ScheduleProposal

Schedule Proposal. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| requestId | True | `string` | {"format": "uuid"} |
| revision | True | `integer` | {"minimum": 1} |
| status | True | `string` | {"enum": ["Ready", "Infeasible", "Stale"]} |
| lessons | True | `array` | {"items": {"$ref": "#/components/schemas/CreatePracticalLesson"}} |
| issues | True | `array` | {"items": {"type": "string"}} |
| theoryLessons | True | `array` | {"items": {"$ref": "#/components/schemas/TheoryLesson"}} |

### SchedulingOperation

Scheduling Operation. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| operationId | True | `string` | {"format": "uuid"} |
| status | True | `string` | {"enum": ["Pending", "Committed", "Rejected", "ReconciliationPending"]} |
| lessonIds | True | `array` | {"items": {"type": "string", "format": "uuid"}} |

### RescheduleLesson

Reschedule Lesson. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| expectedVersion | True | `integer` | {"minimum": 1} |
| startsAt | True | `string` | {"format": "date-time"} |
| endsAt | True | `string` | {"format": "date-time"} |
| reason | True | `string` | {"minLength": 1, "maxLength": 500, "pattern": ".*\\S.*"} |

### CancelLesson

Cancel Lesson. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| expectedVersion | True | `integer` | {"minimum": 1} |
| reason | True | `string` | {"minLength": 1} |

### Availability

Availability. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| schoolId | True | `string` | {"format": "uuid"} |
| slots | True | `array` | {"items": {"type": "object", "required": ["startsAt", "endsAt", "teacherId", "vehicleId"], "properties": {"startsAt": {"type": "string", "format": "date-time"}, "endsAt": {"type": "string", "format": "date-time"}, "teacherId": {"type": "string", "format": "uuid"}, "vehicleId": {"type": "string", "format": "uuid"}}}} |

### LessonList

Lesson List. See the operation descriptions for authorization and lifecycle constraints.

```json
{
  "type": "array",
  "items": {
    "$ref": "#/components/schemas/PracticalLesson"
  },
  "description": "Lesson List. See the operation descriptions for authorization and lifecycle constraints."
}
```

### TheoryLesson

Theory Lesson. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| schoolId | True | `string` | {"format": "uuid"} |
| groupId | True | `string` | {"format": "uuid"} |
| teacherId | True | `string` | {"format": "uuid"} |
| classroomId | True | `string` | {"format": "uuid"} |
| startsAt | True | `string` | {"format": "date-time"} |
| endsAt | True | `string` | {"format": "date-time"} |

### SchoolRestriction

Wire catalogue code must resolve to an implemented School rule. The repository synthetic seed confirms MAX_LESSONS_PER_STUDENT_PER_DAY with unit Lessons; remaining catalogue codes require owner confirmation, not arbitrary string execution.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| schoolId | True | `string` | {"format": "uuid"} |
| ruleType | True | `string` | {"description": "Canonical implemented rule catalogue code; unknown codes rejected. Only the four supported School rule types may be used; this contract does not invent their catalogue values.", "example": "MAX_LESSONS_PER_STUDENT_PER_DAY"} |
| value | True | `integer` | {"minimum": 1} |
| expectedRevision | True | `integer` | {"minimum": 1} |
| unit | False | `string` | {} |
| scopeKind | False | `string` | {"enum": ["School", "Instructor", "Vehicle", "Branch", "Group", "Student"]} |
| effectiveFrom | False | `string` | {"format": "date-time"} |
| sourceReference | False | `string` | {} |

### RuleVersion

Rule Version. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| ruleVersionId | True | `string` | {"format": "uuid"} |
| revision | True | `integer` | {"minimum": 1} |
| status | True | `string` | {"enum": ["Pending", "Verified", "Rejected"]} |

### AssessmentAppointment



| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| schoolId | True | `string` | {"format": "uuid"} |
| enrollmentId | True | `string` | {"format": "uuid"} |
| assessmentDefinitionVersionId | True | `string` | {"format": "uuid"} |
| readinessEvaluationId | True | `string` | {"format": "uuid"} |
| teacherId | True | `string` | {"format": "uuid"} |
| startsAt | True | `string` | {"format": "date-time"} |
| endsAt | True | `string` | {"format": "date-time"} |

### ReviseDraftInputs



```json
{
  "allOf": [
    {
      "$ref": "#/components/schemas/DraftInputs"
    },
    {
      "type": "object",
      "required": [
        "expectedRevision"
      ]
    }
  ]
}
```

### TrainingSource

Exact Scheduling identity and physical state for lessonRevision. Both actual bounds null or strictly increasing (service check); Completed without verified actuals is never sourceValid. Practical requires enrollment/student/vehicle and null group/membership. Theory requires group/membership and null practical identities.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| lessonId | True | `string` | {"format": "uuid"} |
| schoolId | True | `string` | {"format": "uuid"} |
| lessonRevision | True | `integer` | {"minimum": 1} |
| kind | True | `string` | {"enum": ["Practical", "Theory"]} |
| physicallyCompleted | True | `boolean` | {} |
| sourceValid | True | `boolean` | {} |
| actualStart | True | `['string', 'null']` | {"format": "date-time"} |
| actualEnd | True | `['string', 'null']` | {"format": "date-time"} |
| groupMembershipRevision | True | `['integer', 'null']` | {"minimum": 1} |
| teacherId | True | `string` | {"format": "uuid", "description": "Maps to Learning instructor_id."} |
| enrollmentId | True | `['string', 'null']` | {"format": "uuid"} |
| studentId | True | `['string', 'null']` | {"format": "uuid"} |
| vehicleId | True | `['string', 'null']` | {"format": "uuid"} |
| groupId | True | `['string', 'null']` | {"format": "uuid"} |

```json
{
  "allOf": [
    {
      "if": {
        "properties": {
          "physicallyCompleted": {
            "const": true
          },
          "sourceValid": {
            "const": true
          }
        },
        "required": [
          "physicallyCompleted",
          "sourceValid"
        ]
      },
      "then": {
        "properties": {
          "actualStart": {
            "type": "string",
            "format": "date-time"
          },
          "actualEnd": {
            "type": "string",
            "format": "date-time"
          }
        }
      }
    },
    {
      "oneOf": [
        {
          "properties": {
            "actualStart": {
              "type": "null"
            },
            "actualEnd": {
              "type": "null"
            }
          }
        },
        {
          "properties": {
            "actualStart": {
              "type": "string",
              "format": "date-time"
            },
            "actualEnd": {
              "type": "string",
              "format": "date-time"
            }
          }
        }
      ]
    },
    {
      "if": {
        "properties": {
          "kind": {
            "const": "Practical"
          }
        }
      },
      "then": {
        "properties": {
          "enrollmentId": {
            "type": "string"
          },
          "studentId": {
            "type": "string"
          },
          "vehicleId": {
            "type": "string"
          },
          "groupId": {
            "type": "null"
          },
          "groupMembershipRevision": {
            "type": "null"
          }
        }
      },
      "else": {
        "properties": {
          "enrollmentId": {
            "type": "null"
          },
          "studentId": {
            "type": "null"
          },
          "vehicleId": {
            "type": "null"
          },
          "groupId": {
            "type": "string"
          },
          "groupMembershipRevision": {
            "type": "integer"
          }
        }
      }
    }
  ]
}
```

### CorrectLessonActualInterval

Completed lesson interval correction; a nonblank audit reason and expected revision are mandatory. No automatic re-credit.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| expectedVersion | True | `integer` | {"minimum": 1} |
| actualStart | True | `string` | {"format": "date-time"} |
| actualEnd | True | `string` | {"format": "date-time"} |
| reason | True | `string` | {"minLength": 1, "maxLength": 500, "pattern": ".*\\S.*"} |
