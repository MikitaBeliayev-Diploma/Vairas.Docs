# Vairas Vehicle Management API — Planned Vehicle State Change Saga

HTTP API contract. Vehicle Management owns vehicle
status and coordinates planned StartMaintenance, Deactivate, and Reactivate
operations with Scheduling. Planned changes run asynchronously.
Emergency vehicle failures are deliberately outside this contract.


[Canonical OpenAPI](../Api/vehicle-management.openapi.yaml) | [Security](../guides/security.md) | [Errors](../guides/errors-and-reliability.md)

## Operations

### POST /api/v1/vehicles/{vehicleId}/state-change-operations

Initiate a durable vehicle state-change Saga

Writes the Saga request with a unique Idempotency-Key, then schedules the
orchestrator. Does NOT claim the state change has completed. StartMaintenance
must reference an existing scheduled Maintenance aggregate. For planned
availability reduction Scheduling must block bookings before Vehicle status
changes. An equivalent retry returns the same operation (202 if unfinished,
200 if terminal); reusing the same key with a different request returns 409.


Operation ID: `requestVehicleStateChange`.

**Authorization:** `[{"bearerAuth": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| vehicleId | path | True | `See schema` |
| Idempotency-Key | header | True | `synthetic-Idempotency-Key` |
| X-Correlation-ID | header | False | `synthetic-X-Correlation-ID` |

**Sample request**

```http
POST /api/v1/vehicles/AUTHORIZED_ID/state-change-operations HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: synthetic-Idempotency-Key
X-Correlation-ID: synthetic-X-Correlation-ID
Content-Type: application/json

{
  "operationType": "StartMaintenance",
  "maintenanceId": "11111111-1111-4111-8111-111111111111"
}
```

**Responses**

- **202** — Accepted; operation is pending/in progress, not yet committed.

  Media type: `application/json`.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "vehicleId": "11111111-1111-4111-8111-111111111111",
  "operationType": "StartMaintenance",
  "status": "Pending",
  "createdAt": "2026-12-01T10:00:00Z",
  "updatedAt": "2026-12-01T10:00:00Z"
}
```

- **200** — Idempotent replay of a terminal operation result.

  Media type: `application/json`.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "vehicleId": "11111111-1111-4111-8111-111111111111",
  "operationType": "StartMaintenance",
  "status": "Pending",
  "createdAt": "2026-12-01T10:00:00Z",
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

- **401** — Missing/invalid token.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Missing/invalid token.",
  "status": 401,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

- **403** — Insufficient permission.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Insufficient permission.",
  "status": 403,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

- **404** — Not found or intentionally concealed resource.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Not found or intentionally concealed resource.",
  "status": 404,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

- **409** — Competing in-progress operation, idempotency mismatch, or state conflict.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Competing in-progress operation, idempotency mismatch, or state conflict.",
  "status": 409,
  "code": "RESOURCE_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Business-state validation failure, e.g. maintenance is not scheduled.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Business-state validation failure, e.g. maintenance is not scheduled.",
  "status": 422,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

- **429** — Too many requests.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Too many requests.",
  "status": 429,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

- **503** — Temporarily unable to process request; query status before assuming rollback.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Temporarily unable to process request; query status before assuming rollback.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

**Invalid input example:** Missing required operationType: reject with 400 before business work.

```json
{
  "maintenanceId": "11111111-1111-4111-8111-111111111111"
}
```

### GET /api/v1/vehicles/{vehicleId}/state-change-operations/{operationId}

Get the authoritative Saga state

Used by the UI after 202, disconnects, and timeouts. The response never
includes another tenant's lesson IDs or student details.


Operation ID: `getVehicleStateChangeOperation`.

**Authorization:** `[{"bearerAuth": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| vehicleId | path | True | `See schema` |
| operationId | path | True | `See schema` |
| X-Correlation-ID | header | False | `synthetic-X-Correlation-ID` |

**Sample request**

```http
GET /api/v1/vehicles/AUTHORIZED_ID/state-change-operations/AUTHORIZED_ID HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
X-Correlation-ID: synthetic-X-Correlation-ID
```

**Responses**

- **200** — Current persisted operation state.

  Media type: `application/json`.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "vehicleId": "11111111-1111-4111-8111-111111111111",
  "operationType": "StartMaintenance",
  "status": "Pending",
  "createdAt": "2026-12-01T10:00:00Z",
  "updatedAt": "2026-12-01T10:00:00Z"
}
```

- **401** — Missing/invalid token.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Missing/invalid token.",
  "status": 401,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

- **403** — Insufficient permission.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Insufficient permission.",
  "status": 403,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

- **404** — Not found or intentionally concealed resource.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Not found or intentionally concealed resource.",
  "status": 404,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

- **429** — Too many requests.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Too many requests.",
  "status": 429,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

- **503** — Temporarily unable to process request; query status before assuming rollback.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Temporarily unable to process request; query status before assuming rollback.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### GET /internal/v1/vehicles/{vehicleId}/eligibility

Query operational suitability; NOT a booking reservation

Checks vehicle's current status, category, assigned teacher and branch.
This preflight result does not reserve a vehicle and is insufficient by
itself to prevent races with later state changes. Scheduling must still
enforce its booking gate transaction.


Operation ID: `getVehicleEligibility`.

**Authorization:** `[{"workloadBearer": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| vehicleId | path | True | `See schema` |
| branchId | query | True | `11111111-1111-4111-8111-111111111111` |
| teacherId | query | True | `11111111-1111-4111-8111-111111111111` |
| category | query | True | `B` |
| X-Correlation-ID | header | False | `synthetic-X-Correlation-ID` |

**Sample request**

```http
GET /internal/v1/vehicles/AUTHORIZED_ID/eligibility?branchId=11111111-1111-4111-8111-111111111111&teacherId=11111111-1111-4111-8111-111111111111&category=B HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
X-Correlation-ID: synthetic-X-Correlation-ID
```

**Responses**

- **200** — Suitability result (includes eligible=false; do not use 409 here).

  Media type: `application/json`.

```json
{
  "vehicleId": "11111111-1111-4111-8111-111111111111",
  "eligible": true,
  "vehicleStatus": "Active",
  "vehicleVersion": 1
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

- **401** — Missing/invalid token.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Missing/invalid token.",
  "status": 401,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

- **403** — Insufficient permission.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Insufficient permission.",
  "status": 403,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

- **404** — Not found or intentionally concealed resource.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Not found or intentionally concealed resource.",
  "status": 404,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

- **503** — Temporarily unable to process request; query status before assuming rollback.

  Media type: `application/problem+json`.

```json
{
  "type": "LessonScheduled",
  "title": "Temporarily unable to process request; query status before assuming rollback.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

## Data models

Required fields, nullability, constraints and descriptions are authoritative in the YAML. Conditional and composed schemas are shown below.

### StateChangeRequest

State Change Request. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| operationType | True | `string` | {"enum": ["StartMaintenance", "Deactivate", "Reactivate"]} |
| maintenanceId | False | `string` | {"format": "uuid", "description": "Required for StartMaintenance; prohibited for other operations."} |

```json
{
  "additionalProperties": false,
  "allOf": [
    {
      "if": {
        "properties": {
          "operationType": {
            "const": "StartMaintenance"
          }
        },
        "required": [
          "operationType"
        ]
      },
      "then": {
        "required": [
          "maintenanceId"
        ]
      },
      "else": {
        "not": {
          "required": [
            "maintenanceId"
          ]
        }
      }
    }
  ]
}
```

### StateChangeOperation

State Change Operation. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| operationId | True | `string` | {"format": "uuid"} |
| vehicleId | True | `string` | {"format": "uuid"} |
| operationType | True | `string` | {"enum": ["StartMaintenance", "Deactivate", "Reactivate"]} |
| status | True | `string` | {"enum": ["Pending", "Blocking", "SchedulingBlocked", "ApplyingVehicleState", "ReleasingBlock", "Completed", "Rejected", "NeedsRecovery"]} |
| blockId | False | `string` | {"format": "uuid"} |
| resultVehicleStatus | False | `string` | {"enum": ["Active", "Inactive", "UnderMaintenance"]} |
| errorCode | False | `string` | {"description": "Stable, non-sensitive machine-readable result code on rejection/recovery."} |
| createdAt | True | `string` | {"format": "date-time"} |
| updatedAt | True | `string` | {"format": "date-time"} |

```json
{
  "additionalProperties": false
}
```

### VehicleEligibility

Vehicle Eligibility. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| vehicleId | True | `string` | {"format": "uuid"} |
| eligible | True | `boolean` | {} |
| vehicleStatus | True | `string` | {"enum": ["Active", "Inactive", "UnderMaintenance"]} |
| vehicleVersion | True | `integer` | {"minimum": 0} |
| reasons | False | `array` | {"items": {"type": "string", "enum": ["STATUS_NOT_ACTIVE", "CATEGORY_NOT_SUPPORTED", "TEACHER_NOT_ASSIGNED", "BRANCH_MISMATCH"]}} |

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
