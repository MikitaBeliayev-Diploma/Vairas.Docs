# Vairas Scheduling Service — Internal Vehicle Booking Gate API

Internal REST contract. Vehicle Management orchestrator invokes these
commands using workload authentication. Scheduling owns all booking gates,
reservations and their local atomic conflict checks. Each OperationId has
one stable outcome; rejected commands are also recorded for idempotency.


[Canonical OpenAPI](../Api/scheduling-internal.openapi.yaml) | [Security](../guides/security.md) | [Errors](../guides/errors-and-reliability.md)

## Operations

### POST /internal/v1/vehicle-blocks

Atomically block new bookings for a vehicle

An immediate, open-ended block, not future interval scheduling. Acquire
the SAME vehicle guard as a lesson booking inside one Scheduling DB
transaction; detect any future active lesson. On conflict, persist a
stable rejected command outcome without creating a block. A subsequent
attempt after lessons are rescheduled MUST use a new operationId.


Operation ID: `createVehicleBookingBlock`.

**Authorization:** `[{"workloadBearer": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| X-Correlation-ID | header | False | `synthetic-X-Correlation-ID` |

**Sample request**

```http
POST /internal/v1/vehicle-blocks HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
X-Correlation-ID: synthetic-X-Correlation-ID
Content-Type: application/json

{
  "operationId": "46c0b177-457b-46a6-b0a7-b170dbac938b",
  "vehicleId": "550e8400-e29b-41d4-a716-446655440000",
  "reason": "Maintenance",
  "conflictPolicy": "RejectIfFutureBookings"
}
```

**Responses**

- **201** — New block atomically committed.

  Media type: `application/json`.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "vehicleId": "11111111-1111-4111-8111-111111111111",
  "status": "Active",
  "updatedAt": "2026-12-01T10:00:00Z"
}
```

- **200** — Idempotent replay of successful original command.

  Media type: `application/json`.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "vehicleId": "11111111-1111-4111-8111-111111111111",
  "status": "Active",
  "updatedAt": "2026-12-01T10:00:00Z"
}
```

- **400** — Malformed request.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Malformed request.",
  "status": 400,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

- **401** — Missing/invalid service token.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Missing/invalid service token.",
  "status": 401,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

- **403** — Caller lacks internal Scheduling permission.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Caller lacks internal Scheduling permission.",
  "status": 403,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

- **409** — Future lessons, competing block, state, or idempotency conflict.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Future lessons, competing block, state, or idempotency conflict.",
  "status": 409,
  "code": "RESOURCE_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Valid JSON but rejected by domain validation.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Valid JSON but rejected by domain validation.",
  "status": 422,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

- **503** — Temporarily unavailable. Call outcome query or replay same operationId; never assume rollback.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Temporarily unavailable. Call outcome query or replay same operationId; never assume rollback.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

**Invalid input example:** Missing required operationId: reject with 400 before business work.

```json
{
  "vehicleId": "11111111-1111-4111-8111-111111111111",
  "reason": "Maintenance",
  "conflictPolicy": "RejectIfFutureBookings"
}
```

### GET /internal/v1/vehicle-blocks/by-operation/{operationId}

Resolve ambiguous result by Saga operation ID

Returns both successful and rejected persisted outcomes. 404 means
not yet found; it is NOT proof that an in-flight POST failed. Retry the
POST with the same operationId when the result remains uncertain.


Operation ID: `getVehicleBlockCommandOutcome`.

**Authorization:** `[{"workloadBearer": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| operationId | path | True | `See schema` |
| X-Correlation-ID | header | False | `synthetic-X-Correlation-ID` |

**Sample request**

```http
GET /internal/v1/vehicle-blocks/by-operation/AUTHORIZED_ID HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
X-Correlation-ID: synthetic-X-Correlation-ID
```

**Responses**

- **200** — Durable known command result.

  Media type: `application/json`.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "vehicleId": "11111111-1111-4111-8111-111111111111",
  "status": "Active",
  "updatedAt": "2026-12-01T10:00:00Z"
}
```

- **401** — Missing/invalid service token.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Missing/invalid service token.",
  "status": 401,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

- **403** — Caller lacks internal Scheduling permission.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Caller lacks internal Scheduling permission.",
  "status": 403,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

- **404** — Unknown operation/block; not definitive proof a concurrent command was rolled back.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Unknown operation/block; not definitive proof a concurrent command was rolled back.",
  "status": 404,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

- **503** — Temporarily unavailable. Call outcome query or replay same operationId; never assume rollback.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Temporarily unavailable. Call outcome query or replay same operationId; never assume rollback.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### POST /internal/v1/vehicle-blocks/{blockId}/release

Release precisely one block by a distinct durable command

Only the owning orchestrator may release this specific block after
verifying Vehicle Management's authoritative status is Active (normal
Reactivate) or after confirming the planned transition never applied
(compensation). No other block is released. A repeated releaseOperationId
returns the same terminal result without additional side effects.


Operation ID: `releaseVehicleBookingBlock`.

**Authorization:** `[{"workloadBearer": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| blockId | path | True | `See schema` |
| X-Correlation-ID | header | False | `synthetic-X-Correlation-ID` |

**Sample request**

```http
POST /internal/v1/vehicle-blocks/AUTHORIZED_ID/release HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
X-Correlation-ID: synthetic-X-Correlation-ID
Content-Type: application/json

{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "releaseOperationId": "11111111-1111-4111-8111-111111111111",
  "reason": "Reactivated"
}
```

**Responses**

- **200** — Released, or exact idempotent replay of a release.

  Media type: `application/json`.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "vehicleId": "11111111-1111-4111-8111-111111111111",
  "status": "Active",
  "updatedAt": "2026-12-01T10:00:00Z"
}
```

- **400** — Malformed request.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Malformed request.",
  "status": 400,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

- **401** — Missing/invalid service token.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Missing/invalid service token.",
  "status": 401,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

- **403** — Caller lacks internal Scheduling permission.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Caller lacks internal Scheduling permission.",
  "status": 403,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

- **404** — Unknown operation/block; not definitive proof a concurrent command was rolled back.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Unknown operation/block; not definitive proof a concurrent command was rolled back.",
  "status": 404,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

- **409** — Future lessons, competing block, state, or idempotency conflict.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Future lessons, competing block, state, or idempotency conflict.",
  "status": 409,
  "code": "RESOURCE_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **503** — Temporarily unavailable. Call outcome query or replay same operationId; never assume rollback.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Temporarily unavailable. Call outcome query or replay same operationId; never assume rollback.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

**Invalid input example:** Missing required operationId: reject with 400 before business work.

```json
{
  "releaseOperationId": "11111111-1111-4111-8111-111111111111",
  "reason": "Reactivated"
}
```

## Data models

Required fields, nullability, constraints and descriptions are authoritative in the YAML. Conditional and composed schemas are shown below.

### CreateBlockRequest

Create Block Request. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| operationId | True | `string` | {"format": "uuid"} |
| vehicleId | True | `string` | {"format": "uuid"} |
| reason | True | `string` | {"enum": ["Maintenance", "Deactivation"]} |
| conflictPolicy | True | `string` | {"enum": ["RejectIfFutureBookings"]} |

```json
{
  "additionalProperties": false
}
```

### ReleaseBlockRequest

Release Block Request. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| operationId | True | `string` | {"format": "uuid", "description": "Original Saga operation that acquired this block."} |
| releaseOperationId | True | `string` | {"format": "uuid", "description": "Stable idempotency key for the release command."} |
| reason | True | `string` | {"enum": ["Reactivated", "CompensateFailedTransition"]} |

```json
{
  "additionalProperties": false
}
```

### BlockOutcome

Block Outcome. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| operationId | True | `string` | {"format": "uuid"} |
| vehicleId | True | `string` | {"format": "uuid"} |
| blockId | False | `string` | {"format": "uuid"} |
| status | True | `string` | {"enum": ["Active", "Released", "Rejected"]} |
| errorCode | False | `string` | {"enum": ["FUTURE_LESSONS_EXIST", "VEHICLE_ALREADY_BLOCKED", "COMMAND_PAYLOAD_MISMATCH"]} |
| updatedAt | True | `string` | {"format": "date-time"} |

```json
{
  "additionalProperties": false
}
```

### Problem

Problem. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| type | True | `string` | {"format": "uri-reference"} |
| title | True | `string` | {} |
| status | True | `integer` | {} |
| code | True | `string` | {} |
| correlationId | True | `string` | {} |
| detail | False | `string` | {} |

```json
{
  "additionalProperties": true
}
```
