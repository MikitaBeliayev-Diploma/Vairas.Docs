# Vairas — Learning Tracking API

HTTP API contract. Tenant/resource authorization is mandatory inside the owning service.

[Canonical OpenAPI](../Api/learning-tracking.openapi.yaml) | [Security](../guides/security.md) | [Errors](../guides/errors-and-reliability.md)

## Operations

### GET /internal/v1/student-trainings/{enrollmentId}/confirmed-practical-records

Read only confirmed current revisions for journal generation

Read only confirmed current revisions for journal generation. The owning service enforces actor and school authorization.

Operation ID: `getConfirmedPracticalRecords`.

**Authorization:** `[{"workloadBearer": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| enrollmentId | path | True | `11111111-1111-4111-8111-111111111111` |
| X-Correlation-ID | header | False | `synthetic-X-Correlation-ID` |

**Sample request**

```http
GET /internal/v1/student-trainings/11111111-1111-4111-8111-111111111111/confirmed-practical-records HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
X-Correlation-ID: synthetic-X-Correlation-ID
```

**Responses**

- **200** — Result

  Media type: `application/json`.

```json
{
  "enrollmentId": "11111111-1111-4111-8111-111111111111",
  "snapshotVersion": "training-snapshot-7",
  "records": [
    {
      "recordId": "11111111-1111-4111-8111-111111111111",
      "revision": 1,
      "actualMinutes": 50
    }
  ]
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

### GET /api/v1/student-trainings/{enrollmentId}/progress

Get school scoped progress and hour deficits

Get school scoped progress and hour deficits. The owning service enforces actor and school authorization.

Operation ID: `getStudentProgress`.

**Authorization:** `[{"bearerAuth": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| enrollmentId | path | True | `11111111-1111-4111-8111-111111111111` |
| X-Correlation-ID | header | False | `synthetic-X-Correlation-ID` |

**Sample request**

```http
GET /api/v1/student-trainings/11111111-1111-4111-8111-111111111111/progress HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
X-Correlation-ID: synthetic-X-Correlation-ID
```

**Responses**

- **200** — Result

  Media type: `application/json`.

```json
{
  "enrollmentId": "11111111-1111-4111-8111-111111111111",
  "theoryMinutes": 600,
  "practicalMinutes": 300,
  "percent": 40,
  "outstandingRequirements": [
    "120 practical minutes remain"
  ],
  "pendingRecordCount": 1
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

### POST /api/v1/practical-records/{recordId}/confirmations

Confirm the exact current record revision by eligible student/instructor

Authenticated assigned instructor or enrolled student confirms the exact current fact revision. Both roles must confirm the same validated version before any minutes count. Administrator cannot sign for them. A subsequent dispute permanently closes that fact version; resolution creates a new version. Idempotent retries count once.

Operation ID: `confirmPracticalRecord`.

**Authorization:** `[{"bearerAuth": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| X-Correlation-ID | header | False | `synthetic-X-Correlation-ID` |
| recordId | path | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/practical-records/11111111-1111-4111-8111-111111111111/confirmations HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
X-Correlation-ID: synthetic-X-Correlation-ID
Content-Type: application/json

{
  "revision": 1
}
```

**Responses**

- **200** — Accepted

  Media type: `application/json`.

```json
{
  "recordId": "11111111-1111-4111-8111-111111111111",
  "revision": 1,
  "status": "Pending"
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

**Invalid input example:** Missing required revision: reject with 400 before business work.

```json
{}
```

### POST /api/v1/practical-records

Record journal facts against an authoritative completed lesson

Record journal facts against an authoritative completed lesson. Access is checked by the owning service for the authenticated actor and exact school/enrollment.

Operation ID: `createPracticalRecord`.

**Authorization:** `[{"bearerAuth": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/practical-records HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "enrollmentId": "11111111-1111-4111-8111-111111111111",
  "lessonId": "11111111-1111-4111-8111-111111111111",
  "programVersionId": "11111111-1111-4111-8111-111111111111",
  "sourceSnapshotId": "11111111-1111-4111-8111-111111111111",
  "trainingMinutes": 50,
  "distanceKm": 12.5,
  "topicIds": [
    "11111111-1111-4111-8111-111111111111"
  ],
  "durationExplanation": "Ten-minute break excluded from credited training.",
  "expectedRevision": 1,
  "correctionReason": "Corrected the recorded distance."
}
```

**Responses**

- **201** — Successful result

  Media type: `application/json`.

```json
{
  "recordId": "11111111-1111-4111-8111-111111111111",
  "enrollmentId": "11111111-1111-4111-8111-111111111111",
  "revision": 1,
  "factVersion": 1,
  "status": "Pending",
  "facts": {
    "schoolId": "11111111-1111-4111-8111-111111111111",
    "enrollmentId": "11111111-1111-4111-8111-111111111111",
    "lessonId": "11111111-1111-4111-8111-111111111111",
    "programVersionId": "11111111-1111-4111-8111-111111111111",
    "sourceSnapshotId": "11111111-1111-4111-8111-111111111111",
    "trainingMinutes": 50,
    "distanceKm": 12.5,
    "topicIds": [
      "11111111-1111-4111-8111-111111111111"
    ],
    "durationExplanation": "Ten-minute break excluded from credited training.",
    "expectedRevision": 1,
    "correctionReason": "Corrected the recorded distance."
  },
  "responses": [
    {
      "role": "Instructor",
      "response": "Confirm",
      "factVersion": 1
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

**Invalid input example:** Missing required schoolId: reject with 400 before business work.

```json
{
  "enrollmentId": "11111111-1111-4111-8111-111111111111",
  "lessonId": "11111111-1111-4111-8111-111111111111",
  "programVersionId": "11111111-1111-4111-8111-111111111111",
  "sourceSnapshotId": "11111111-1111-4111-8111-111111111111",
  "trainingMinutes": 50,
  "distanceKm": 12.5,
  "topicIds": [
    "11111111-1111-4111-8111-111111111111"
  ],
  "durationExplanation": "Ten-minute break excluded from credited training.",
  "expectedRevision": 1,
  "correctionReason": "Corrected the recorded distance."
}
```

### GET /api/v1/practical-records/{recordId}

Read permitted current-version facts and response state

Read permitted current-version facts and response state. Access is checked by the owning service for the authenticated actor and exact school/enrollment.

Operation ID: `getPracticalRecord`.

**Authorization:** `[{"bearerAuth": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| recordId | path | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
GET /api/v1/practical-records/11111111-1111-4111-8111-111111111111 HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
{
  "recordId": "11111111-1111-4111-8111-111111111111",
  "enrollmentId": "11111111-1111-4111-8111-111111111111",
  "revision": 1,
  "factVersion": 1,
  "status": "Pending",
  "facts": {
    "schoolId": "11111111-1111-4111-8111-111111111111",
    "enrollmentId": "11111111-1111-4111-8111-111111111111",
    "lessonId": "11111111-1111-4111-8111-111111111111",
    "programVersionId": "11111111-1111-4111-8111-111111111111",
    "sourceSnapshotId": "11111111-1111-4111-8111-111111111111",
    "trainingMinutes": 50,
    "distanceKm": 12.5,
    "topicIds": [
      "11111111-1111-4111-8111-111111111111"
    ],
    "durationExplanation": "Ten-minute break excluded from credited training.",
    "expectedRevision": 1,
    "correctionReason": "Corrected the recorded distance."
  },
  "responses": [
    {
      "role": "Instructor",
      "response": "Confirm",
      "factVersion": 1
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

### POST /api/v1/practical-records/{recordId}/versions

Append corrected facts and invalidate earlier confirmations

Assigned instructor appends a new immutable practical fact version using required expectedRevision and correctionReason. Reverify current source and enrollment/program scope. Keep prior versions and their confirmations; the new version requires fresh participant confirmations before credit. Preserve material identity and fail CAS conflicts without partial writes.

Operation ID: `revisePracticalRecord`.

**Authorization:** `[{"bearerAuth": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| recordId | path | True | `11111111-1111-4111-8111-111111111111` |
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/practical-records/11111111-1111-4111-8111-111111111111/versions HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "enrollmentId": "11111111-1111-4111-8111-111111111111",
  "lessonId": "11111111-1111-4111-8111-111111111111",
  "programVersionId": "11111111-1111-4111-8111-111111111111",
  "sourceSnapshotId": "11111111-1111-4111-8111-111111111111",
  "trainingMinutes": 50,
  "distanceKm": 12.5,
  "topicIds": [
    "11111111-1111-4111-8111-111111111111"
  ],
  "durationExplanation": "Ten-minute break excluded from credited training.",
  "expectedRevision": 1,
  "correctionReason": "Corrected the recorded distance."
}
```

**Responses**

- **201** — Successful result

  Media type: `application/json`.

```json
{
  "recordId": "11111111-1111-4111-8111-111111111111",
  "enrollmentId": "11111111-1111-4111-8111-111111111111",
  "revision": 2,
  "factVersion": 2,
  "status": "Pending",
  "facts": {
    "schoolId": "11111111-1111-4111-8111-111111111111",
    "enrollmentId": "11111111-1111-4111-8111-111111111111",
    "lessonId": "11111111-1111-4111-8111-111111111111",
    "programVersionId": "11111111-1111-4111-8111-111111111111",
    "sourceSnapshotId": "11111111-1111-4111-8111-111111111111",
    "trainingMinutes": 50,
    "distanceKm": 12.5,
    "topicIds": [
      "11111111-1111-4111-8111-111111111111"
    ],
    "durationExplanation": "Ten-minute break excluded from credited training."
  },
  "responses": []
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
  "enrollmentId": "11111111-1111-4111-8111-111111111111",
  "lessonId": "11111111-1111-4111-8111-111111111111",
  "programVersionId": "11111111-1111-4111-8111-111111111111",
  "sourceSnapshotId": "11111111-1111-4111-8111-111111111111",
  "trainingMinutes": 50,
  "distanceKm": 12.5,
  "topicIds": [
    "11111111-1111-4111-8111-111111111111"
  ],
  "durationExplanation": "Ten-minute break excluded from credited training.",
  "expectedRevision": 1,
  "correctionReason": "Corrected the recorded distance."
}
```

### POST /api/v1/practical-records/{recordId}/disputes

Dispute the exact current version and withdraw its credit

Dispute the exact current version and withdraw its credit. Access is checked by the owning service for the authenticated actor and exact school/enrollment.

Operation ID: `disputePracticalRecord`.

**Authorization:** `[{"bearerAuth": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| recordId | path | True | `11111111-1111-4111-8111-111111111111` |
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/practical-records/11111111-1111-4111-8111-111111111111/disputes HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "revision": 1,
  "reason": "Instructor requested a schedule correction."
}
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
{
  "recordId": "11111111-1111-4111-8111-111111111111",
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

**Invalid input example:** Missing required revision: reject with 400 before business work.

```json
{
  "reason": "Instructor requested a schedule correction."
}
```

### POST /api/v1/student-trainings/{enrollmentId}/readiness-evaluations

Evaluate applicable pre-assessment prerequisites

Evaluate applicable pre-assessment prerequisites. Access is checked by the owning service for the authenticated actor and exact school/enrollment.

Operation ID: `evaluateReadiness`.

**Authorization:** `[{"bearerAuth": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| enrollmentId | path | True | `11111111-1111-4111-8111-111111111111` |
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/student-trainings/11111111-1111-4111-8111-111111111111/readiness-evaluations HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "assessmentDefinitionVersionId": "11111111-1111-4111-8111-111111111111"
}
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
{
  "enrollmentId": "11111111-1111-4111-8111-111111111111",
  "evaluationId": "11111111-1111-4111-8111-111111111111",
  "prerequisitesSatisfied": false,
  "outstandingRequirements": [
    "120 practical minutes remain"
  ],
  "decision": "Pending"
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

**Invalid input example:** Missing required assessmentDefinitionVersionId: reject with 400 before business work.

```json
{}
```

### POST /api/v1/student-trainings/{enrollmentId}/readiness-decisions

Record qualified assessor decision without bypassing prerequisites

Record qualified assessor decision without bypassing prerequisites. Access is checked by the owning service for the authenticated actor and exact school/enrollment.

Operation ID: `decideReadiness`.

**Authorization:** `[{"bearerAuth": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| enrollmentId | path | True | `11111111-1111-4111-8111-111111111111` |
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/student-trainings/11111111-1111-4111-8111-111111111111/readiness-decisions HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "evaluationId": "11111111-1111-4111-8111-111111111111",
  "expectedRevision": 1,
  "decision": "Approved",
  "reason": "Instructor requested a schedule correction."
}
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
{
  "enrollmentId": "11111111-1111-4111-8111-111111111111",
  "evaluationId": "11111111-1111-4111-8111-111111111111",
  "prerequisitesSatisfied": false,
  "outstandingRequirements": [
    "120 practical minutes remain"
  ],
  "decision": "Pending"
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

**Invalid input example:** Missing required evaluationId: reject with 400 before business work.

```json
{
  "expectedRevision": 1,
  "decision": "Approved",
  "reason": "Instructor requested a schedule correction."
}
```

### POST /api/v1/student-trainings/{enrollmentId}/assessments

Record an authorized assessment result separately from readiness

Record an authorized assessment result separately from readiness. Access is checked by the owning service for the authenticated actor and exact school/enrollment.

Operation ID: `recordAssessmentResult`.

**Authorization:** `[{"bearerAuth": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| enrollmentId | path | True | `11111111-1111-4111-8111-111111111111` |
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/student-trainings/11111111-1111-4111-8111-111111111111/assessments HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "enrollmentId": "11111111-1111-4111-8111-111111111111",
  "assessmentDefinitionVersionId": "11111111-1111-4111-8111-111111111111",
  "stage": "Midterm",
  "result": "Passed",
  "assessedAt": "2026-12-01T10:00:00Z",
  "expectedRevision": 1,
  "trainingKind": "Theory"
}
```

**Responses**

- **201** — Successful result

  Media type: `application/json`.

```json
{
  "assessmentId": "11111111-1111-4111-8111-111111111111",
  "revision": 1,
  "result": "Passed"
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

**Invalid input example:** Missing required enrollmentId: reject with 400 before business work.

```json
{
  "assessmentDefinitionVersionId": "11111111-1111-4111-8111-111111111111",
  "stage": "Midterm",
  "result": "Passed",
  "assessedAt": "2026-12-01T10:00:00Z",
  "expectedRevision": 1,
  "trainingKind": "Theory"
}
```

### GET /internal/v1/student-trainings/{enrollmentId}/completion-evidence

Return current versioned completion evidence to Document Management

Return current versioned completion evidence to Document Management. Access is checked by the owning service for the authenticated actor and exact school/enrollment.

Operation ID: `getCompletionEvidence`.

**Authorization:** `[{"workloadBearer": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| enrollmentId | path | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
GET /internal/v1/student-trainings/11111111-1111-4111-8111-111111111111/completion-evidence HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
{
  "enrollmentId": "11111111-1111-4111-8111-111111111111",
  "snapshotVersion": "training-snapshot-7",
  "ready": false,
  "outstandingItems": [
    "Final assessment result is missing"
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

### POST /api/v1/theory-records

Record the full attendance roster for a theory lesson

The assigned teacher creates one group theory record with the full immutable Present/Absent roster. Verify school/lesson/source identity, exact historical group membership and each enrollment/student pair. Persist facts without automatic confirmation or credit. The teacher reviews and confirms the exact version through the confirmation operation; students do not confirm theory. Reject duplicate lesson records except an identical idempotent replay.

Operation ID: `recordTheoryAttendance`.

**Authorization:** `[{"bearerAuth": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/theory-records HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "lessonId": "11111111-1111-4111-8111-111111111111",
  "sourceSnapshotId": "11111111-1111-4111-8111-111111111111",
  "trainingMinutes": 50,
  "attendanceRows": [
    {
      "enrollmentId": "11111111-1111-4111-8111-111111111111",
      "studentId": "11111111-1111-4111-8111-111111111111",
      "attendance": "Present"
    },
    {
      "enrollmentId": "11111111-1111-4111-8111-111111111112",
      "studentId": "11111111-1111-4111-8111-111111111113",
      "attendance": "Absent"
    }
  ]
}
```

**Responses**

- **201** — Successful result

  Media type: `application/json`.

```json
{
  "recordId": "11111111-1111-4111-8111-111111111111",
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "lessonId": "11111111-1111-4111-8111-111111111111",
  "revision": 1,
  "factVersion": 1,
  "validation": "Valid",
  "confirmed": false,
  "facts": {
    "schoolId": "11111111-1111-4111-8111-111111111111",
    "lessonId": "11111111-1111-4111-8111-111111111111",
    "sourceSnapshotId": "11111111-1111-4111-8111-111111111111",
    "trainingMinutes": 50,
    "attendanceRows": [
      {
        "enrollmentId": "11111111-1111-4111-8111-111111111111",
        "studentId": "11111111-1111-4111-8111-111111111111",
        "attendance": "Present"
      },
      {
        "enrollmentId": "11111111-1111-4111-8111-111111111112",
        "studentId": "11111111-1111-4111-8111-111111111113",
        "attendance": "Absent"
      }
    ]
  }
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
  "lessonId": "11111111-1111-4111-8111-111111111111",
  "sourceSnapshotId": "11111111-1111-4111-8111-111111111111",
  "trainingMinutes": 50,
  "attendanceRows": [
    {
      "enrollmentId": "11111111-1111-4111-8111-111111111111",
      "studentId": "11111111-1111-4111-8111-111111111111",
      "attendance": "Present"
    },
    {
      "enrollmentId": "11111111-1111-4111-8111-111111111112",
      "studentId": "11111111-1111-4111-8111-111111111113",
      "attendance": "Absent"
    }
  ]
}
```

### POST /api/v1/student-trainings

Pin a published applicable programme version to an authorized School-owned enrollment

Pin a published applicable programme version to an authorized School-owned enrollment. Access is checked by the owning service for the authenticated actor and exact school/enrollment.

Operation ID: `startStudentTraining`.

**Authorization:** `[{"bearerAuth": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/student-trainings HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "enrollmentId": "11111111-1111-4111-8111-111111111111",
  "programVersionId": "11111111-1111-4111-8111-111111111111"
}
```

**Responses**

- **201** — Successful result

  Media type: `application/json`.

```json
{
  "enrollmentId": "11111111-1111-4111-8111-111111111111",
  "theoryMinutes": 600,
  "practicalMinutes": 300,
  "percent": 40,
  "outstandingRequirements": [
    "120 practical minutes remain"
  ],
  "pendingRecordCount": 1
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

### GET /api/v1/theory-records/{recordId}

Read the current group theory record

Only the assigned teacher or a school administrator with journal authority may read the full roster. Verify exact tenant and lesson scope. Student progress exposes only that student enrollment projection, not other students attendance.

Operation ID: `getTheoryRecord`.

**Authorization:** `[{"bearerAuth": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| recordId | path | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
GET /api/v1/theory-records/11111111-1111-4111-8111-111111111111 HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
```

**Responses**

- **200** — Read the current group theory record

  Media type: `application/json`.

```json
{
  "recordId": "11111111-1111-4111-8111-111111111111",
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "lessonId": "11111111-1111-4111-8111-111111111111",
  "revision": 1,
  "factVersion": 1,
  "validation": "Valid",
  "confirmed": false,
  "facts": {
    "schoolId": "11111111-1111-4111-8111-111111111111",
    "lessonId": "11111111-1111-4111-8111-111111111111",
    "sourceSnapshotId": "11111111-1111-4111-8111-111111111111",
    "trainingMinutes": 50,
    "attendanceRows": [
      {
        "enrollmentId": "11111111-1111-4111-8111-111111111111",
        "studentId": "11111111-1111-4111-8111-111111111111",
        "attendance": "Present"
      },
      {
        "enrollmentId": "11111111-1111-4111-8111-111111111112",
        "studentId": "11111111-1111-4111-8111-111111111113",
        "attendance": "Absent"
      }
    ]
  }
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

### POST /api/v1/theory-records/{recordId}/versions

Append corrected group theory facts

Assigned teacher uses expectedRevision and a nonblank correctionReason. Keep school/lesson identity, reverify exact current source and the complete historical roster, append a new immutable version and advance aggregate revision atomically. Prior confirmation stays on its old version; no credit until the new version is explicitly confirmed.

Operation ID: `reviseTheoryRecord`.

**Authorization:** `[{"bearerAuth": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| recordId | path | True | `11111111-1111-4111-8111-111111111111` |
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/theory-records/11111111-1111-4111-8111-111111111111/versions HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "lessonId": "11111111-1111-4111-8111-111111111111",
  "sourceSnapshotId": "11111111-1111-4111-8111-111111111111",
  "trainingMinutes": 50,
  "attendanceRows": [
    {
      "enrollmentId": "11111111-1111-4111-8111-111111111111",
      "studentId": "11111111-1111-4111-8111-111111111111",
      "attendance": "Present"
    },
    {
      "enrollmentId": "11111111-1111-4111-8111-111111111112",
      "studentId": "11111111-1111-4111-8111-111111111113",
      "attendance": "Absent"
    }
  ],
  "expectedRevision": 2,
  "correctionReason": "Corrected attendance after reviewing the verified lesson roster."
}
```

**Responses**

- **201** — Append corrected group theory facts

  Media type: `application/json`.

```json
{
  "recordId": "11111111-1111-4111-8111-111111111111",
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "lessonId": "11111111-1111-4111-8111-111111111111",
  "revision": 3,
  "factVersion": 2,
  "validation": "Valid",
  "confirmed": false,
  "facts": {
    "schoolId": "11111111-1111-4111-8111-111111111111",
    "lessonId": "11111111-1111-4111-8111-111111111111",
    "sourceSnapshotId": "11111111-1111-4111-8111-111111111111",
    "trainingMinutes": 50,
    "attendanceRows": [
      {
        "enrollmentId": "11111111-1111-4111-8111-111111111111",
        "studentId": "11111111-1111-4111-8111-111111111111",
        "attendance": "Present"
      },
      {
        "enrollmentId": "11111111-1111-4111-8111-111111111112",
        "studentId": "11111111-1111-4111-8111-111111111113",
        "attendance": "Absent"
      }
    ]
  }
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

### POST /api/v1/theory-records/{recordId}/confirmations

Confirm the reviewed full theory attendance version

Authenticate the assigned teacher, verify exact school/lesson authority, expectedRevision and factVersion, and recheck current completed-valid source and full as-of roster. Only a Valid current version may be teacher-confirmed; students and administrators cannot substitute that teacher. Atomically retain confirmation and advance revision. Present contributes once, Absent zero; a source correction blocks eligibility and needs new facts plus fresh confirmation. Exact idempotent retries reuse the result.

Operation ID: `confirmTheoryRecord`.

**Authorization:** `[{"bearerAuth": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| recordId | path | True | `11111111-1111-4111-8111-111111111111` |
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/theory-records/11111111-1111-4111-8111-111111111111/confirmations HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "expectedRevision": 1,
  "factVersion": 1
}
```

**Responses**

- **200** — Confirm the reviewed full theory attendance version

  Media type: `application/json`.

```json
{
  "recordId": "11111111-1111-4111-8111-111111111111",
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "lessonId": "11111111-1111-4111-8111-111111111111",
  "revision": 2,
  "factVersion": 1,
  "validation": "Valid",
  "confirmed": true,
  "facts": {
    "schoolId": "11111111-1111-4111-8111-111111111111",
    "lessonId": "11111111-1111-4111-8111-111111111111",
    "sourceSnapshotId": "11111111-1111-4111-8111-111111111111",
    "trainingMinutes": 50,
    "attendanceRows": [
      {
        "enrollmentId": "11111111-1111-4111-8111-111111111111",
        "studentId": "11111111-1111-4111-8111-111111111111",
        "attendance": "Present"
      },
      {
        "enrollmentId": "11111111-1111-4111-8111-111111111112",
        "studentId": "11111111-1111-4111-8111-111111111113",
        "attendance": "Absent"
      }
    ]
  }
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

### ConfirmedPracticalRecords

Confirmed Practical Records. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| enrollmentId | True | `string` | {"format": "uuid"} |
| snapshotVersion | True | `string` | {} |
| records | True | `array` | {"items": {"type": "object", "required": ["recordId", "revision", "actualMinutes"], "properties": {"recordId": {"type": "string", "format": "uuid"}, "revision": {"type": "integer"}, "actualMinutes": {"type": "integer"}}}} |

### Progress

Progress. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| enrollmentId | True | `string` | {"format": "uuid"} |
| theoryMinutes | True | `integer` | {} |
| practicalMinutes | True | `integer` | {} |
| percent | True | `number` | {"minimum": 0, "maximum": 100} |
| outstandingRequirements | True | `array` | {"items": {"type": "string"}} |
| pendingRecordCount | True | `integer` | {"minimum": 0} |

### ConfirmationRequest

Confirmation Request. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| revision | True | `integer` | {"minimum": 1, "description": "Exact immutable current factVersion being confirmed, not the aggregate revision. Both participant roles confirm this same fact version; reject an older or permanently disputed version."} |

### ConfirmationResult

Confirmation Result. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| recordId | True | `string` | {"format": "uuid"} |
| revision | True | `integer` | {"description": "The immutable fact version addressed by this confirmation."} |
| status | True | `string` | {"enum": ["Pending", "Confirmed", "Disputed"]} |

### PracticalFacts

Practical Facts. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| schoolId | True | `string` | {"format": "uuid"} |
| enrollmentId | True | `string` | {"format": "uuid"} |
| lessonId | True | `string` | {"format": "uuid"} |
| programVersionId | True | `string` | {"format": "uuid"} |
| sourceSnapshotId | True | `string` | {"format": "uuid"} |
| trainingMinutes | True | `integer` | {"minimum": 1} |
| distanceKm | True | `number` | {"minimum": 0} |
| topicIds | True | `array` | {"items": {"type": "string", "format": "uuid"}} |
| durationExplanation | False | `string` | {} |
| expectedRevision | False | `integer` | {"minimum": 1} |
| correctionReason | False | `string` | {} |

### PracticalRecord

Practical Record. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| recordId | True | `string` | {"format": "uuid"} |
| enrollmentId | True | `string` | {"format": "uuid"} |
| revision | True | `integer` | {"minimum": 1} |
| factVersion | True | `integer` | {"minimum": 1} |
| status | True | `string` | {"enum": ["Pending", "Confirmed", "Disputed", "Invalid"]} |
| facts | True | `#/components/schemas/PracticalFacts` | {} |
| responses | True | `array` | {"items": {"type": "object", "required": ["role", "response", "factVersion"], "properties": {"role": {"type": "string", "enum": ["Instructor", "Student"]}, "response": {"type": "string", "enum": ["Confirm", "Dispute"]}, "factVersion": {"type": "integer", "minimum": 1}}}} |

### Dispute

Dispute. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| revision | True | `integer` | {"minimum": 1, "description": "The immutable fact version being disputed, not an aggregate concurrency token."} |
| reason | True | `string` | {"minLength": 1} |

### Readiness

Readiness. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| enrollmentId | True | `string` | {"format": "uuid"} |
| evaluationId | True | `string` | {"format": "uuid"} |
| prerequisitesSatisfied | True | `boolean` | {} |
| outstandingRequirements | True | `array` | {"items": {"type": "string"}} |
| decision | True | `string` | {"enum": ["Pending", "Approved", "NotApproved"]} |

### ReadinessDecision

Readiness Decision. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| evaluationId | True | `string` | {"format": "uuid"} |
| expectedRevision | True | `integer` | {"minimum": 1} |
| decision | True | `string` | {"enum": ["Approved", "NotApproved"]} |
| reason | True | `string` | {"minLength": 1} |

### AssessmentResult

Assessment Result. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| enrollmentId | True | `string` | {"format": "uuid"} |
| assessmentDefinitionVersionId | True | `string` | {"format": "uuid"} |
| stage | True | `string` | {"enum": ["Midterm", "Final"]} |
| result | True | `string` | {"enum": ["Passed", "Failed"]} |
| assessedAt | True | `string` | {"format": "date-time"} |
| expectedRevision | True | `integer` | {"minimum": 1} |
| trainingKind | True | `string` | {"enum": ["Theory", "Practical"]} |

### Assessment

Assessment. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| assessmentId | True | `string` | {"format": "uuid"} |
| revision | True | `integer` | {"minimum": 1} |
| result | True | `string` | {"enum": ["Passed", "Failed"]} |

### Evidence

Evidence. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| enrollmentId | True | `string` | {"format": "uuid"} |
| snapshotVersion | True | `string` | {} |
| ready | True | `boolean` | {} |
| outstandingItems | True | `array` | {"items": {"type": "string"}} |

### TheoryFacts

Facts for one whole group lesson, not one student. The complete immutable attendanceRows must equal the verified as-of group roster from the current Scheduling source; no omitted, extra, duplicate or mismatched enrollment/student pairs. Verify each pinned student programme independently. Present earns full minutes only after current-source validation and teacher confirmation; Absent earns zero. No partial attendance or automatic credit on completion.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| schoolId | True | `string` | {"format": "uuid"} |
| lessonId | True | `string` | {"format": "uuid"} |
| sourceSnapshotId | True | `string` | {"format": "uuid"} |
| trainingMinutes | True | `integer` | {"minimum": 1} |
| durationExplanation | False | `string` | {} |
| attendanceRows | True | `array` | {"minItems": 1, "items": {"type": "object", "additionalProperties": false, "required": ["enrollmentId", "studentId", "attendance"], "properties": {"enrollmentId": {"type": "string", "format": "uuid"}, "studentId": {"type": "string", "format": "uuid"}, "attendance": {"type": "string", "enum": ["Present", "Absent"]}}}} |

```json
{
  "additionalProperties": false
}
```

### TrainingEnrollment



| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| schoolId | True | `string` | {"format": "uuid"} |
| enrollmentId | True | `string` | {"format": "uuid"} |
| programVersionId | True | `string` | {"format": "uuid"} |

### TheoryRecord

Current group theory record. revision is the aggregate CAS token; factVersion identifies immutable facts. confirmed is derived from the confirmation on that version; source freshness must still be verified before any credit.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| recordId | True | `string` | {"format": "uuid"} |
| schoolId | True | `string` | {"format": "uuid"} |
| lessonId | True | `string` | {"format": "uuid"} |
| revision | True | `integer` | {"minimum": 1} |
| factVersion | True | `integer` | {"minimum": 1} |
| validation | True | `string` | {"enum": ["Incomplete", "Valid", "Invalid"]} |
| confirmed | True | `boolean` | {} |
| facts | True | `#/components/schemas/TheoryFacts` | {} |

### RevisedPracticalFacts

Append a new immutable practical fact version with CAS and an audit reason; old confirmations remain on their original version and never transfer.

```json
{
  "allOf": [
    {
      "$ref": "#/components/schemas/PracticalFacts"
    },
    {
      "type": "object",
      "required": [
        "expectedRevision",
        "correctionReason"
      ],
      "properties": {
        "correctionReason": {
          "type": "string",
          "minLength": 1,
          "pattern": ".*\\S.*"
        }
      }
    }
  ],
  "description": "Append a new immutable practical fact version with CAS and an audit reason; old confirmations remain on their original version and never transfer."
}
```

### RevisedTheoryFacts

A complete replacement fact version for the same school/lesson; retain prior facts and confirmation, increment version/revision and require fresh teacher confirmation.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| schoolId | True | `string` | {"format": "uuid"} |
| lessonId | True | `string` | {"format": "uuid"} |
| sourceSnapshotId | True | `string` | {"format": "uuid"} |
| trainingMinutes | True | `integer` | {"minimum": 1} |
| durationExplanation | False | `string` | {} |
| attendanceRows | True | `array` | {"minItems": 1, "items": {"type": "object", "additionalProperties": false, "required": ["enrollmentId", "studentId", "attendance"], "properties": {"enrollmentId": {"type": "string", "format": "uuid"}, "studentId": {"type": "string", "format": "uuid"}, "attendance": {"type": "string", "enum": ["Present", "Absent"]}}}} |
| expectedRevision | True | `integer` | {"minimum": 1} |
| correctionReason | True | `string` | {"minLength": 1, "pattern": ".*\\S.*"} |

```json
{
  "additionalProperties": false
}
```

### TheoryConfirmation

The assigned teacher explicitly confirms the reviewed full roster and minutes of this exact current version. Confirmation authority is server-derived; students do not confirm theory attendance.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| expectedRevision | True | `integer` | {"minimum": 1} |
| factVersion | True | `integer` | {"minimum": 1} |

```json
{
  "additionalProperties": false
}
```
