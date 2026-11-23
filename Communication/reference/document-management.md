# Vairas — Document Management API (PROPOSED)

Proposed OpenAPI contract; not evidence of implemented endpoints. Tenant/resource authorization is mandatory inside the owning service.

[Canonical OpenAPI](../Api/document-management.openapi.yaml) | [Security](../guides/security.md) | [Errors](../guides/errors-and-reliability.md)

## Operations

### POST /api/v1/schools/{schoolId}/contracts

Generate immutable contract from authorized enrollment snapshot

Generate immutable contract from authorized enrollment snapshot. Proposed interface; authoritative actor and school checks are mandatory.

Operation ID: `generateTrainingContract`. Status: **proposed**.

**Authorization:** `[{"bearerAuth": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

| Parameter | Location | Required | Example |
|---|---|---|---|
| X-Correlation-ID | header | False | `synthetic-X-Correlation-ID` |
| schoolId | path | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/schools/11111111-1111-4111-8111-111111111111/contracts HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
X-Correlation-ID: synthetic-X-Correlation-ID
Content-Type: application/json

{
  "enrollmentId": "11111111-1111-4111-8111-111111111111",
  "templateId": "11111111-1111-4111-8111-111111111111"
}
```

**Responses**

- **202** — Accepted

  Media type: `application/json`.

```json
{
  "jobId": "11111111-1111-4111-8111-111111111111",
  "status": "Pending",
  "ready": false,
  "missingItems": [],
  "sourceSnapshotVersion": "training-snapshot-7"
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

**Invalid input example:** Missing required enrollmentId: reject with 400 before business work.

```json
{
  "templateId": "11111111-1111-4111-8111-111111111111"
}
```

### POST /api/v1/enrollments/{enrollmentId}/journals

Generate a journal from a consistent Learning snapshot

Generate a journal from a consistent Learning snapshot. Proposed interface; authoritative actor and school checks are mandatory.

Operation ID: `generatePracticalJournal`. Status: **proposed**.

**Authorization:** `[{"bearerAuth": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

| Parameter | Location | Required | Example |
|---|---|---|---|
| X-Correlation-ID | header | False | `synthetic-X-Correlation-ID` |
| enrollmentId | path | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/enrollments/11111111-1111-4111-8111-111111111111/journals HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
X-Correlation-ID: synthetic-X-Correlation-ID
Content-Type: application/json

{
  "sourceSnapshotVersion": "training-snapshot-7"
}
```

**Responses**

- **202** — Accepted

  Media type: `application/json`.

```json
{
  "jobId": "11111111-1111-4111-8111-111111111111",
  "status": "Pending",
  "ready": false,
  "missingItems": [],
  "sourceSnapshotVersion": "training-snapshot-7"
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

**Invalid input example:** Missing required sourceSnapshotVersion: reject with 400 before business work.

```json
{}
```

### GET /api/v1/document-jobs/{jobId}

Read document-generation job state

Read document-generation job state. Proposed interface; authoritative actor and school checks are mandatory.

Operation ID: `getDocumentJob`. Status: **proposed**.

**Authorization:** `[{"bearerAuth": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

| Parameter | Location | Required | Example |
|---|---|---|---|
| jobId | path | True | `11111111-1111-4111-8111-111111111111` |
| X-Correlation-ID | header | False | `synthetic-X-Correlation-ID` |

**Sample request**

```http
GET /api/v1/document-jobs/11111111-1111-4111-8111-111111111111 HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
X-Correlation-ID: synthetic-X-Correlation-ID
```

**Responses**

- **200** — Result

  Media type: `application/json`.

```json
{
  "jobId": "11111111-1111-4111-8111-111111111111",
  "status": "Pending",
  "ready": false,
  "missingItems": [],
  "sourceSnapshotVersion": "training-snapshot-7"
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

### POST /api/v1/enrollments/{enrollmentId}/completion-reports

Prepare internal completion report for a human-controlled external handoff

Prepare internal completion report for a human-controlled external handoff. Access is checked by the owning service for the authenticated actor and exact school/enrollment.

Operation ID: `generateCompletionReport`. Status: **proposed**.

**Authorization:** `[{"bearerAuth": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

| Parameter | Location | Required | Example |
|---|---|---|---|
| enrollmentId | path | True | `11111111-1111-4111-8111-111111111111` |
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/enrollments/11111111-1111-4111-8111-111111111111/completion-reports HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "sourceSnapshotVersion": "training-snapshot-7"
}
```

**Responses**

- **202** — Successful result

  Media type: `application/json`.

```json
{
  "jobId": "11111111-1111-4111-8111-111111111111",
  "status": "Pending",
  "ready": false,
  "missingItems": [],
  "sourceSnapshotVersion": "training-snapshot-7"
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

**Invalid input example:** Missing required sourceSnapshotVersion: reject with 400 before business work.

```json
{}
```

### GET /api/v1/documents/{documentId}/download

Authorize access before issuing a short-lived file URL

Authorize access before issuing a short-lived file URL. Access is checked by the owning service for the authenticated actor and exact school/enrollment.

Operation ID: `getDocumentDownload`. Status: **proposed**.

**Authorization:** `[{"bearerAuth": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

| Parameter | Location | Required | Example |
|---|---|---|---|
| documentId | path | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
GET /api/v1/documents/11111111-1111-4111-8111-111111111111/download HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
{
  "documentId": "11111111-1111-4111-8111-111111111111",
  "downloadUrl": "https://files.vairas.example/synthetic-document",
  "expiresAt": "2026-12-01T11:00:00Z"
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

### GenerateContract

Owner resolves templateId to an authorized applicable immutable template version and pins it with the generated evidence. A template identifier is not a version.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| enrollmentId | True | `string` | {"format": "uuid"} |
| templateId | True | `string` | {"format": "uuid"} |

### GenerateJournal

Generate Journal. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| sourceSnapshotVersion | True | `string` | {} |

### DocumentJob

Completed means generation finished; it does not imply legally valid signature, release readiness or Regitra submission. Missing facts/confirmations must be visible. Historical output remains immutable after source revision.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| jobId | True | `string` | {"format": "uuid"} |
| status | True | `string` | {"enum": ["Pending", "Generating", "Completed", "Failed"]} |
| documentId | False | `string` | {"format": "uuid"} |
| ready | False | `boolean` | {} |
| missingItems | False | `array` | {"items": {"type": "string"}} |
| sourceSnapshotVersion | False | `string` | {} |
| documentState | False | `string` | {"enum": ["Prepared", "Indeterminate", "PublishedReview", "PublishedReady", "Stale", "Withdrawn"], "description": "Document lifecycle from the owner schema, independent of generation job status."} |

### CompletionReportRequest

Completion Report Request. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| sourceSnapshotVersion | True | `string` | {} |

### DocumentDownload

Document Download. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| documentId | True | `string` | {"format": "uuid"} |
| downloadUrl | True | `string` | {"format": "uri"} |
| expiresAt | True | `string` | {"format": "date-time"} |
