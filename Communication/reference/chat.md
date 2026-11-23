# Vairas Chat Backend API

Architecture Chat/BFF responsibilities and BA US-018/019/020. Identity delegation remains unimplemented.

[Canonical OpenAPI](../Api/chat.openapi.yaml) | [Security](../guides/security.md) | [Errors](../guides/errors-and-reliability.md)

## Operations

### POST /internal/v1/confirmations/validate

Validate explicit human approval bound to the exact command

Validate explicit human approval bound to the exact command. The owning service enforces actor and school authorization.

Operation ID: `validateExactProfileConfirmation`.

**Authorization:** `[{"workloadOAuth": ["confirmations.validate"]}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

**Sample request**

```http
POST /internal/v1/confirmations/validate HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Content-Type: application/json

{
  "confirmationId": "11111111-1111-4111-8111-111111111111",
  "identityId": "11111111-1111-4111-8111-111111111111",
  "operationId": "11111111-1111-4111-8111-111111111111",
  "requestFingerprint": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "commandName": "CreateUser"
}
```

**Responses**

- **200** — The Chat Backend must retain an actual authenticated human approval and compare every request binding. Echo request bindings, the original server-recorded confirmation time and its expiry. This is read-only validation, not consumption or a model assertion. Allocate confirmationId before calculating the final command fingerprint.

  Media type: `application/json`.

```json
{
  "confirmationId": "11111111-1111-4111-8111-111111111111",
  "identityId": "11111111-1111-4111-8111-111111111111",
  "operationId": "11111111-1111-4111-8111-111111111111",
  "requestFingerprint": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "commandName": "CreateUser",
  "allowed": true,
  "confirmedAt": "2026-12-01T10:00:00Z",
  "expiresAt": "2026-12-01T11:00:00Z"
}
```

- **401** — Workload unauthenticated

  Media type: `application/problem+json`.

```json
{
  "title": "Workload unauthenticated",
  "status": 401,
  "code": "PROVIDER_REJECTED",
  "correlationId": "integration-example-01"
}
```

- **403** — Workload lacks permission

  Media type: `application/problem+json`.

```json
{
  "title": "Workload lacks permission",
  "status": 403,
  "code": "PROVIDER_REJECTED",
  "correlationId": "integration-example-01"
}
```

- **503** — Confirmation provider unavailable

  Media type: `application/problem+json`.

```json
{
  "title": "Confirmation provider unavailable",
  "status": 503,
  "code": "PROVIDER_REJECTED",
  "correlationId": "integration-example-01"
}
```

**Invalid input example:** Missing required confirmationId: reject with 400 before business work.

```json
{
  "identityId": "11111111-1111-4111-8111-111111111111",
  "operationId": "11111111-1111-4111-8111-111111111111",
  "requestFingerprint": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "commandName": "CreateUser"
}
```

### POST /api/v1/chat/sessions

Create an authenticated user-owned conversation

Create an authenticated user-owned conversation. Access is checked by the owning service for the authenticated actor and exact school/enrollment.

Operation ID: `createChatSession`.

**Authorization:** `[{"bearerAuth": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/chat/sessions HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
```

**Responses**

- **201** — Successful result

  Media type: `application/json`.

```json
{
  "sessionId": "11111111-1111-4111-8111-111111111111"
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

### POST /api/v1/chat/sessions/{sessionId}/messages

Invoke the assistant within verified user and selected school scope

Invoke the assistant within verified user and selected school scope. Access is checked by the owning service for the authenticated actor and exact school/enrollment.

Operation ID: `sendChatMessage`.

**Authorization:** `[{"bearerAuth": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| sessionId | path | True | `11111111-1111-4111-8111-111111111111` |
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/chat/sessions/11111111-1111-4111-8111-111111111111/messages HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "text": "synthetic-text",
  "schoolId": "11111111-1111-4111-8111-111111111111"
}
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
{
  "messageId": "11111111-1111-4111-8111-111111111111",
  "text": "synthetic-text"
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

**Invalid input example:** Missing required text: reject with 400 before business work.

```json
{
  "schoolId": "11111111-1111-4111-8111-111111111111"
}
```

### POST /api/v1/chat/action-previews/{previewId}/confirmations

Record authenticated human approval for exact server-stored preview arguments

Record authenticated human approval for exact server-stored preview arguments. Access is checked by the owning service for the authenticated actor and exact school/enrollment.

Operation ID: `recordHumanApproval`.

**Authorization:** `[{"bearerAuth": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| previewId | path | True | `11111111-1111-4111-8111-111111111111` |
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/chat/action-previews/11111111-1111-4111-8111-111111111111/confirmations HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "argumentsFingerprint": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
  "approved": true
}
```

**Responses**

- **201** — Successful result

  Media type: `application/json`.

```json
{
  "confirmationId": "11111111-1111-4111-8111-111111111111",
  "previewId": "11111111-1111-4111-8111-111111111111",
  "operationId": "11111111-1111-4111-8111-111111111111",
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

**Invalid input example:** Missing required operationId: reject with 400 before business work.

```json
{
  "argumentsFingerprint": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
  "approved": true
}
```

### GET /api/v1/schools/{schoolId}/assistant-audit

Read restricted MCP write-attempt evidence without raw conversation or secrets

Read restricted MCP write-attempt evidence without raw conversation or secrets. Access is checked by the owning service for the authenticated actor and exact school/enrollment.

Operation ID: `getAssistantAudit`.

**Authorization:** `[{"bearerAuth": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| schoolId | path | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
GET /api/v1/schools/11111111-1111-4111-8111-111111111111/assistant-audit HTTP/1.1
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
    "operationId": "11111111-1111-4111-8111-111111111111",
    "outcome": "Permitted",
    "recordedAt": "2026-12-01T10:00:00Z"
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

### Id

Id. See the operation descriptions for authorization and lifecycle constraints.

```json
{
  "type": "string",
  "format": "uuid",
  "description": "Id. See the operation descriptions for authorization and lifecycle constraints."
}
```

### NullableId

Nullable Id. See the operation descriptions for authorization and lifecycle constraints.

```json
{
  "type": [
    "string",
    "null"
  ],
  "format": "uuid",
  "description": "Nullable Id. See the operation descriptions for authorization and lifecycle constraints."
}
```

### SchoolAuthorityRequest

School Authority Request. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| actorUserId | True | `#/components/schemas/Id` | {} |
| targetUserId | True | `#/components/schemas/Id` | {} |
| schoolId | True | `#/components/schemas/Id` | {} |
| invitationId | True | `#/components/schemas/NullableId` | {} |
| role | True | `string` | {"enum": ["Teacher", "Administrator"]} |
| bootstrap | True | `boolean` | {} |

### ConfirmationRequest

Confirmation Request. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| confirmationId | True | `#/components/schemas/Id` | {} |
| identityId | True | `#/components/schemas/Id` | {} |
| operationId | True | `#/components/schemas/Id` | {} |
| requestFingerprint | True | `string` | {"pattern": "^[0-9a-f]{64}$"} |
| schoolId | True | `#/components/schemas/NullableId` | {} |
| commandName | True | `string` | {"enum": ["CreateUser", "UpdateUser", "CreateStudent", "CreateTeacher", "CreateAdministrator"]} |

### ChatSession



| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| sessionId | True | `string` | {"format": "uuid"} |

### ChatMessage



| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| text | True | `string` | {"minLength": 1} |
| schoolId | False | `string` | {"format": "uuid"} |

### ChatReply



| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| messageId | True | `string` | {"format": "uuid"} |
| text | True | `string` | {} |
| previewId | False | `string` | {"format": "uuid"} |

### HumanApproval



| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| operationId | True | `string` | {"format": "uuid"} |
| argumentsFingerprint | True | `string` | {"pattern": "^[0-9a-f]{64}$"} |
| approved | True | `boolean` | {"const": true} |

### RecordedApproval



| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| confirmationId | True | `string` | {"format": "uuid"} |
| previewId | True | `string` | {"format": "uuid"} |
| operationId | True | `string` | {"format": "uuid"} |
| expiresAt | True | `string` | {"format": "date-time"} |

### AuditList



```json
{
  "type": "array",
  "items": {
    "type": "object",
    "required": [
      "operationId",
      "outcome",
      "recordedAt"
    ],
    "properties": {
      "operationId": {
        "type": "string",
        "format": "uuid"
      },
      "outcome": {
        "type": "string",
        "enum": [
          "Permitted",
          "Rejected",
          "Failed"
        ]
      },
      "recordedAt": {
        "type": "string",
        "format": "date-time"
      }
    }
  }
}
```
