# Vairas — Notifications API (PROPOSED)

Proposed OpenAPI contract; not evidence of implemented endpoints. Tenant/resource authorization is mandatory inside the owning service.

[Canonical OpenAPI](../Api/notifications.openapi.yaml) | [Security](../guides/security.md) | [Errors](../guides/errors-and-reliability.md)

## Operations

### GET /api/v1/schools/{schoolId}/notification-templates

List school-owned templates

List school-owned templates. Proposed interface; authoritative actor and school checks are mandatory.

Operation ID: `getNotificationTemplates`. Status: **proposed**.

**Authorization:** `[{"bearerAuth": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

| Parameter | Location | Required | Example |
|---|---|---|---|
| schoolId | path | True | `11111111-1111-4111-8111-111111111111` |
| X-Correlation-ID | header | False | `synthetic-X-Correlation-ID` |

**Sample request**

```http
GET /api/v1/schools/11111111-1111-4111-8111-111111111111/notification-templates HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
X-Correlation-ID: synthetic-X-Correlation-ID
```

**Responses**

- **200** — Result

  Media type: `application/json`.

```json
[
  {
    "templateId": "11111111-1111-4111-8111-111111111111",
    "type": "LessonScheduled"
  }
]
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

### GET /api/v1/schools/{schoolId}/notifications/{notificationId}

View allowed notification delivery state

View allowed notification delivery state. Proposed interface; authoritative actor and school checks are mandatory.

Operation ID: `getNotificationStatus`. Status: **proposed**.

**Authorization:** `[{"bearerAuth": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

| Parameter | Location | Required | Example |
|---|---|---|---|
| schoolId | path | True | `11111111-1111-4111-8111-111111111111` |
| notificationId | path | True | `11111111-1111-4111-8111-111111111111` |
| X-Correlation-ID | header | False | `synthetic-X-Correlation-ID` |

**Sample request**

```http
GET /api/v1/schools/11111111-1111-4111-8111-111111111111/notifications/11111111-1111-4111-8111-111111111111 HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
X-Correlation-ID: synthetic-X-Correlation-ID
```

**Responses**

- **200** — Result

  Media type: `application/json`.

```json
{
  "notificationId": "11111111-1111-4111-8111-111111111111",
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

### NotificationTemplates

Notification Templates. See the operation descriptions for authorization and lifecycle constraints.

```json
{
  "type": "array",
  "items": {
    "type": "object",
    "required": [
      "templateId",
      "type"
    ],
    "properties": {
      "templateId": {
        "type": "string",
        "format": "uuid"
      },
      "type": {
        "type": "string"
      }
    }
  },
  "description": "Notification Templates. See the operation descriptions for authorization and lifecycle constraints."
}
```

### NotificationStatus

Sent means provider acceptance, not recipient delivery/read. DeliveryUnknown requires provider reconciliation; never blindly retry. Status and attempt information are restricted to authorized school/recipient scope.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| notificationId | True | `string` | {"format": "uuid"} |
| status | True | `string` | {"enum": ["Pending", "Sending", "Sent", "Failed", "Cancelled", "DeliveryUnknown"]} |
