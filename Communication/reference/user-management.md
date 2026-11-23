# Vairas User Management API

Global profiles and idempotent commands. Internal operations require a workload JWT. Delegated and platform mutations additionally require a user JWT in X-User-Authorization. Mutations return operation receipts; fetch current resource state separately.

[Canonical OpenAPI](../Api/user-management.openapi.yaml) | [Security](../guides/security.md) | [Errors](../guides/errors-and-reliability.md)

## Operations

### GET /internal/v1/users/{userId}/status

Read operational status using a permitted workload identity.

 Required workload scope and local client allowlist: profiles.status.read. See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior.

Operation ID: `getInternalV1UsersUserIdStatus`.

**Authorization:** `[{"WorkloadBearer": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| userId | path | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
GET /internal/v1/users/11111111-1111-4111-8111-111111111111/status HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
```

**Responses**

- **200** — OK

  Media type: `application/json`.

  Example: `typical` — OK.

```json
{
  "userId": "11111111-1111-4111-8111-111111111111",
  "active": true
}
```

  Media type: `text/json`.

  Example: `typical` — OK.

```json
{
  "userId": "11111111-1111-4111-8111-111111111111",
  "active": true
}
```

- **401** — Workload authentication required (AUTHENTICATION_REQUIRED).

  Media type: `application/problem+json`.

  Example: `authentication_required` — AUTHENTICATION_REQUIRED.

```json
{
  "title": "Authentication required.",
  "status": 401,
  "code": "AUTHENTICATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

- **403** — Workload scope or local client allowlist rejected (ACCESS_DENIED).

  Media type: `application/problem+json`.

  Example: `access_denied` — ACCESS_DENIED.

```json
{
  "title": "Access denied.",
  "status": 403,
  "code": "ACCESS_DENIED",
  "correlationId": "integration-example-01"
}
```

- **404** — Profile, target user or role not found (NOT_FOUND).

  Media type: `application/problem+json`.

  Example: `not_found` — NOT_FOUND.

```json
{
  "title": "Resource not found or not visible.",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure (INTERNAL_ERROR); preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

  Example: `internal_error` — INTERNAL_ERROR.

```json
{
  "title": "An unexpected error occurred.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Owned database unavailable (DATABASE_UNAVAILABLE).

  Media type: `application/problem+json`.

  Example: `database_unavailable` — DATABASE_UNAVAILABLE.

```json
{
  "title": "The database is unavailable.",
  "status": 503,
  "code": "DATABASE_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### GET /internal/v1/users/{userId}/contact

Read a minimal contact projection for a configured notification/document workload.

 Required workload scope and local client allowlist: profiles.contact.read. See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior.

Operation ID: `getInternalV1UsersUserIdContact`.

**Authorization:** `[{"WorkloadBearer": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| userId | path | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
GET /internal/v1/users/11111111-1111-4111-8111-111111111111/contact HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
```

**Responses**

- **200** — OK

  Media type: `application/json`.

  Example: `typical` — OK.

```json
{
  "userId": "11111111-1111-4111-8111-111111111111",
  "email": "alex@example.test"
}
```

  Media type: `text/json`.

  Example: `typical` — OK.

```json
{
  "userId": "11111111-1111-4111-8111-111111111111",
  "email": "alex@example.test"
}
```

- **401** — Workload authentication required (AUTHENTICATION_REQUIRED).

  Media type: `application/problem+json`.

  Example: `authentication_required` — AUTHENTICATION_REQUIRED.

```json
{
  "title": "Authentication required.",
  "status": 401,
  "code": "AUTHENTICATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

- **403** — Workload scope or local client allowlist rejected (ACCESS_DENIED).

  Media type: `application/problem+json`.

  Example: `access_denied` — ACCESS_DENIED.

```json
{
  "title": "Access denied.",
  "status": 403,
  "code": "ACCESS_DENIED",
  "correlationId": "integration-example-01"
}
```

- **404** — Profile, target user or role not found (NOT_FOUND).

  Media type: `application/problem+json`.

  Example: `not_found` — NOT_FOUND.

```json
{
  "title": "Resource not found or not visible.",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure (INTERNAL_ERROR); preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

  Example: `internal_error` — INTERNAL_ERROR.

```json
{
  "title": "An unexpected error occurred.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Owned database unavailable (DATABASE_UNAVAILABLE).

  Media type: `application/problem+json`.

  Example: `database_unavailable` — DATABASE_UNAVAILABLE.

```json
{
  "title": "The database is unavailable.",
  "status": 503,
  "code": "DATABASE_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### GET /internal/v1/profiles/{kind}/{profileId}

Resolve a role identifier to its global user and active state.

 Required workload scope and local client allowlist: profiles.binding.read. See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior.

Operation ID: `getInternalV1ProfilesKindProfileId`.

**Authorization:** `[{"WorkloadBearer": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| kind | path | True | `teacher` |
| profileId | path | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
GET /internal/v1/profiles/teacher/11111111-1111-4111-8111-111111111111 HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
```

**Responses**

- **200** — OK

  Media type: `application/json`.

  Example: `typical` — OK.

```json
{
  "kind": "Teacher",
  "profileId": "11111111-1111-4111-8111-111111111111",
  "userId": "11111111-1111-4111-8111-111111111111",
  "active": true
}
```

  Media type: `text/json`.

  Example: `typical` — OK.

```json
{
  "kind": "Student",
  "profileId": "11111111-1111-4111-8111-111111111111",
  "userId": "11111111-1111-4111-8111-111111111111",
  "active": true
}
```

- **401** — Workload authentication required (AUTHENTICATION_REQUIRED).

  Media type: `application/problem+json`.

  Example: `authentication_required` — AUTHENTICATION_REQUIRED.

```json
{
  "title": "Authentication required.",
  "status": 401,
  "code": "AUTHENTICATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

- **403** — Workload scope or local client allowlist rejected (ACCESS_DENIED).

  Media type: `application/problem+json`.

  Example: `access_denied` — ACCESS_DENIED.

```json
{
  "title": "Access denied.",
  "status": 403,
  "code": "ACCESS_DENIED",
  "correlationId": "integration-example-01"
}
```

- **404** — Profile, target user or role not found (NOT_FOUND).

  Media type: `application/problem+json`.

  Example: `not_found` — NOT_FOUND.

```json
{
  "title": "Resource not found or not visible.",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure (INTERNAL_ERROR); preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

  Example: `internal_error` — INTERNAL_ERROR.

```json
{
  "title": "An unexpected error occurred.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Owned database unavailable (DATABASE_UNAVAILABLE).

  Media type: `application/problem+json`.

  Example: `database_unavailable` — DATABASE_UNAVAILABLE.

```json
{
  "title": "The database is unavailable.",
  "status": 503,
  "code": "DATABASE_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### POST /internal/v1/users/{userId}/deactivate

Deactivate a global user using both platform-operator and workload authorization.

 Required workload scope and local client allowlist: profiles.deactivate. See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior.

Operation ID: `postInternalV1UsersUserIdDeactivate`.

**Authorization:** `[{"WorkloadBearer": [], "DelegatedUser": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| userId | path | True | `11111111-1111-4111-8111-111111111111` |
| Idempotency-Key | header | False | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /internal/v1/users/11111111-1111-4111-8111-111111111111/deactivate HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
X-User-Authorization: Bearer ${USER_TOKEN}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "expectedRevision": 1,
  "reason": "Instructor requested a schedule correction."
}
```

**Responses**

- **200** — Deactivated or already inactive; operation receipt.

  Media type: `application/json`.

  Example: `applied` — User deactivated.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "outcome": "Applied",
  "code": "APPLIED",
  "targetKind": "UserProfile",
  "targetId": "22222222-2222-4222-8222-222222222222",
  "resultingRevision": 2,
  "recordedAt": "2026-12-01T10:00:00Z"
}
```

  Example: `already_inactive` — Target already inactive.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "outcome": "Applied",
  "code": "ALREADY_INACTIVE",
  "targetKind": "UserProfile",
  "targetId": "22222222-2222-4222-8222-222222222222",
  "resultingRevision": 2,
  "recordedAt": "2026-12-01T10:00:00Z"
}
```

  Media type: `text/json`.

  Example: `applied` — User deactivated.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "outcome": "Applied",
  "code": "APPLIED",
  "targetKind": "UserProfile",
  "targetId": "22222222-2222-4222-8222-222222222222",
  "resultingRevision": 2,
  "recordedAt": "2026-12-01T10:00:00Z"
}
```

  Example: `already_inactive` — Target already inactive.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "outcome": "Applied",
  "code": "ALREADY_INACTIVE",
  "targetKind": "UserProfile",
  "targetId": "22222222-2222-4222-8222-222222222222",
  "resultingRevision": 2,
  "recordedAt": "2026-12-01T10:00:00Z"
}
```

- **400** — Invalid JSON, required properties or command arguments (VALIDATION_FAILED).

  Media type: `application/problem+json`.

  Example: `validation_failed` — VALIDATION_FAILED.

```json
{
  "title": "The request is invalid.",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Authentication required or user identity/session invalid (AUTHENTICATION_REQUIRED, INVALID_IDENTITY, SESSION_INVALID).

  Media type: `application/problem+json`.

  Example: `authentication_required` — AUTHENTICATION_REQUIRED.

```json
{
  "title": "Authentication required.",
  "status": 401,
  "code": "AUTHENTICATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

  Example: `invalid_identity` — INVALID_IDENTITY.

```json
{
  "title": "A valid user token with a session is required.",
  "status": 401,
  "code": "INVALID_IDENTITY",
  "correlationId": "integration-example-01"
}
```

  Example: `session_invalid` — SESSION_INVALID.

```json
{
  "title": "The session is not active.",
  "status": 401,
  "code": "SESSION_INVALID",
  "correlationId": "integration-example-01"
}
```

- **403** — Access policy or current business authority rejected (ACCESS_DENIED).

  Media type: `application/problem+json`.

  Example: `access_denied` — ACCESS_DENIED.

```json
{
  "title": "Access denied.",
  "status": 403,
  "code": "ACCESS_DENIED",
  "correlationId": "integration-example-01"
}
```

- **404** — Profile, target user or role not found (NOT_FOUND).

  Media type: `application/problem+json`.

  Example: `not_found` — NOT_FOUND.

```json
{
  "title": "Resource not found or not visible.",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Command rejected: REVISION_CONFLICT, IDEMPOTENCY_KEY_REUSED, RESOURCE_CONFLICT. Refetch on revision conflict; changed intent requires a new Idempotency-Key.

  Media type: `application/problem+json`.

  Example: `revision_conflict` — REVISION_CONFLICT.

```json
{
  "title": "The resource has changed.",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

  Example: `idempotency_key_reused` — IDEMPOTENCY_KEY_REUSED.

```json
{
  "title": "The operation ID is already in use.",
  "status": 409,
  "code": "IDEMPOTENCY_KEY_REUSED",
  "correlationId": "integration-example-01"
}
```

  Example: `resource_conflict` — RESOURCE_CONFLICT.

```json
{
  "title": "The resource already exists.",
  "status": 409,
  "code": "RESOURCE_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **415** — Unsupported request Content-Type (HTTP_ERROR); send a documented JSON media type.

  Media type: `application/problem+json`.

  Example: `http_error` — HTTP_ERROR.

```json
{
  "title": "The request could not be processed.",
  "status": 415,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure (INTERNAL_ERROR); preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

  Example: `internal_error` — INTERNAL_ERROR.

```json
{
  "title": "An unexpected error occurred.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Authoritative dependency or owned database unavailable (DEPENDENCY_UNAVAILABLE, DATABASE_UNAVAILABLE).

  Media type: `application/problem+json`.

  Example: `dependency_unavailable` — DEPENDENCY_UNAVAILABLE.

```json
{
  "title": "A required dependency is unavailable.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

  Example: `database_unavailable` — DATABASE_UNAVAILABLE.

```json
{
  "title": "The database is unavailable.",
  "status": 503,
  "code": "DATABASE_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### POST /internal/v1/users/{userId}/administrator-profile/bootstrap

Bootstrap an administrator after checking platform and school authority.

 Required workload scope and local client allowlist: profiles.bootstrap. See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior.

Operation ID: `postInternalV1UsersUserIdAdministratorProfileBootstrap`.

**Authorization:** `[{"WorkloadBearer": [], "DelegatedUser": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| userId | path | True | `11111111-1111-4111-8111-111111111111` |
| Idempotency-Key | header | False | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /internal/v1/users/11111111-1111-4111-8111-111111111111/administrator-profile/bootstrap HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
X-User-Authorization: Bearer ${USER_TOKEN}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "schoolId": "11111111-1111-4111-8111-111111111111"
}
```

**Responses**

- **200** — Existing administrator profile reused (ALREADY_EXISTS); operation receipt.

  Media type: `application/json`.

  Example: `already_exists` — Existing administrator reused.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "outcome": "Applied",
  "code": "ALREADY_EXISTS",
  "targetKind": "AdministratorProfile",
  "targetId": "22222222-2222-4222-8222-222222222222",
  "resultingRevision": null,
  "recordedAt": "2026-12-01T10:00:00Z"
}
```

  Media type: `text/json`.

  Example: `already_exists` — Existing administrator reused.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "outcome": "Applied",
  "code": "ALREADY_EXISTS",
  "targetKind": "AdministratorProfile",
  "targetId": "22222222-2222-4222-8222-222222222222",
  "resultingRevision": null,
  "recordedAt": "2026-12-01T10:00:00Z"
}
```

- **201** — Administrator profile created; operation receipt and Location header.

  `Location`: `/internal/v1/profiles/administrator/22222222-2222-4222-8222-222222222222`.

  Media type: `application/json`.

  Example: `applied` — Administrator created.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "outcome": "Applied",
  "code": "APPLIED",
  "targetKind": "AdministratorProfile",
  "targetId": "22222222-2222-4222-8222-222222222222",
  "resultingRevision": null,
  "recordedAt": "2026-12-01T10:00:00Z"
}
```

  Media type: `text/json`.

  Example: `applied` — Administrator created.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "outcome": "Applied",
  "code": "APPLIED",
  "targetKind": "AdministratorProfile",
  "targetId": "22222222-2222-4222-8222-222222222222",
  "resultingRevision": null,
  "recordedAt": "2026-12-01T10:00:00Z"
}
```

- **400** — Invalid JSON, required properties or command arguments (VALIDATION_FAILED).

  Media type: `application/problem+json`.

  Example: `validation_failed` — VALIDATION_FAILED.

```json
{
  "title": "The request is invalid.",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Authentication required or user identity/session invalid (AUTHENTICATION_REQUIRED, INVALID_IDENTITY, SESSION_INVALID).

  Media type: `application/problem+json`.

  Example: `authentication_required` — AUTHENTICATION_REQUIRED.

```json
{
  "title": "Authentication required.",
  "status": 401,
  "code": "AUTHENTICATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

  Example: `invalid_identity` — INVALID_IDENTITY.

```json
{
  "title": "A valid user token with a session is required.",
  "status": 401,
  "code": "INVALID_IDENTITY",
  "correlationId": "integration-example-01"
}
```

  Example: `session_invalid` — SESSION_INVALID.

```json
{
  "title": "The session is not active.",
  "status": 401,
  "code": "SESSION_INVALID",
  "correlationId": "integration-example-01"
}
```

- **403** — Access policy or current business authority rejected (ACCESS_DENIED).

  Media type: `application/problem+json`.

  Example: `access_denied` — ACCESS_DENIED.

```json
{
  "title": "Access denied.",
  "status": 403,
  "code": "ACCESS_DENIED",
  "correlationId": "integration-example-01"
}
```

- **404** — Profile, target user or role not found (NOT_FOUND).

  Media type: `application/problem+json`.

  Example: `not_found` — NOT_FOUND.

```json
{
  "title": "Resource not found or not visible.",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Command rejected: IDEMPOTENCY_KEY_REUSED, RESOURCE_CONFLICT. Refetch on revision conflict; changed intent requires a new Idempotency-Key.

  Media type: `application/problem+json`.

  Example: `idempotency_key_reused` — IDEMPOTENCY_KEY_REUSED.

```json
{
  "title": "The operation ID is already in use.",
  "status": 409,
  "code": "IDEMPOTENCY_KEY_REUSED",
  "correlationId": "integration-example-01"
}
```

  Example: `resource_conflict` — RESOURCE_CONFLICT.

```json
{
  "title": "The resource already exists.",
  "status": 409,
  "code": "RESOURCE_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **415** — Unsupported request Content-Type (HTTP_ERROR); send a documented JSON media type.

  Media type: `application/problem+json`.

  Example: `http_error` — HTTP_ERROR.

```json
{
  "title": "The request could not be processed.",
  "status": 415,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **422** — The target user is inactive (USER_INACTIVE).

  Media type: `application/problem+json`.

  Example: `user_inactive` — USER_INACTIVE.

```json
{
  "title": "The command was rejected.",
  "status": 422,
  "code": "USER_INACTIVE",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure (INTERNAL_ERROR); preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

  Example: `internal_error` — INTERNAL_ERROR.

```json
{
  "title": "An unexpected error occurred.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Authoritative dependency or owned database unavailable (DEPENDENCY_UNAVAILABLE, DATABASE_UNAVAILABLE).

  Media type: `application/problem+json`.

  Example: `dependency_unavailable` — DEPENDENCY_UNAVAILABLE.

```json
{
  "title": "A required dependency is unavailable.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

  Example: `database_unavailable` — DATABASE_UNAVAILABLE.

```json
{
  "title": "The database is unavailable.",
  "status": 503,
  "code": "DATABASE_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### GET /api/v1/users/me

Read the current user's global profile and role bindings.

 See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior.

Operation ID: `getApiV1UsersMe`.

**Authorization:** `[{"UserBearer": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

**Sample request**

```http
GET /api/v1/users/me HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
```

**Responses**

- **200** — OK

  Media type: `application/json`.

  Example: `typical` — OK.

```json
{
  "userId": "11111111-1111-4111-8111-111111111111",
  "firstName": "Alex",
  "lastName": "Example",
  "emailAddress": "alex@example.test",
  "phoneNumber": "+37060000000",
  "status": "Active",
  "revision": 1,
  "createdAt": "2026-12-01T10:00:00Z",
  "updatedAt": "2026-12-01T10:00:00Z",
  "studentId": "11111111-1111-4111-8111-111111111111",
  "teacherId": "11111111-1111-4111-8111-111111111111",
  "administratorId": "11111111-1111-4111-8111-111111111111"
}
```

  Media type: `text/json`.

  Example: `typical` — OK.

```json
{
  "userId": "11111111-1111-4111-8111-111111111111",
  "firstName": "Alex",
  "lastName": "Example",
  "emailAddress": "alex@example.test",
  "phoneNumber": "+37060000000",
  "status": "Active",
  "revision": 1,
  "createdAt": "2026-12-01T10:00:00Z",
  "updatedAt": "2026-12-01T10:00:00Z",
  "studentId": "11111111-1111-4111-8111-111111111111",
  "teacherId": "11111111-1111-4111-8111-111111111111",
  "administratorId": "11111111-1111-4111-8111-111111111111"
}
```

- **401** — Authentication required or user identity/session invalid (AUTHENTICATION_REQUIRED, INVALID_IDENTITY, SESSION_INVALID).

  Media type: `application/problem+json`.

  Example: `authentication_required` — AUTHENTICATION_REQUIRED.

```json
{
  "title": "Authentication required.",
  "status": 401,
  "code": "AUTHENTICATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

  Example: `invalid_identity` — INVALID_IDENTITY.

```json
{
  "title": "A valid user token with a session is required.",
  "status": 401,
  "code": "INVALID_IDENTITY",
  "correlationId": "integration-example-01"
}
```

  Example: `session_invalid` — SESSION_INVALID.

```json
{
  "title": "The session is not active.",
  "status": 401,
  "code": "SESSION_INVALID",
  "correlationId": "integration-example-01"
}
```

- **403** — Access policy or current business authority rejected (ACCESS_DENIED).

  Media type: `application/problem+json`.

  Example: `access_denied` — ACCESS_DENIED.

```json
{
  "title": "Access denied.",
  "status": 403,
  "code": "ACCESS_DENIED",
  "correlationId": "integration-example-01"
}
```

- **404** — Profile, target user or role not found (NOT_FOUND).

  Media type: `application/problem+json`.

  Example: `not_found` — NOT_FOUND.

```json
{
  "title": "Resource not found or not visible.",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure (INTERNAL_ERROR); preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

  Example: `internal_error` — INTERNAL_ERROR.

```json
{
  "title": "An unexpected error occurred.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Authoritative dependency or owned database unavailable (DEPENDENCY_UNAVAILABLE, DATABASE_UNAVAILABLE).

  Media type: `application/problem+json`.

  Example: `dependency_unavailable` — DEPENDENCY_UNAVAILABLE.

```json
{
  "title": "A required dependency is unavailable.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

  Example: `database_unavailable` — DATABASE_UNAVAILABLE.

```json
{
  "title": "The database is unavailable.",
  "status": 503,
  "code": "DATABASE_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### POST /api/v1/users/me

Create a profile bound to the authenticated identity.

 See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior.

Operation ID: `postApiV1UsersMe`.

**Authorization:** `[{"UserBearer": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| Idempotency-Key | header | False | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/users/me HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "firstName": "Alex",
  "lastName": "Example",
  "emailAddress": "alex@example.test",
  "phoneNumber": null
}
```

**Responses**

- **201** — Created

  Media type: `application/json`.

  Example: `typical` — Created.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "outcome": "Applied",
  "code": "APPLIED",
  "targetKind": "UserProfile",
  "targetId": "11111111-1111-4111-8111-111111111111",
  "resultingRevision": 1,
  "recordedAt": "2026-12-01T10:00:00Z"
}
```

  Media type: `text/json`.

  Example: `typical` — Created.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "outcome": "Applied",
  "code": "APPLIED",
  "targetKind": "UserProfile",
  "targetId": "11111111-1111-4111-8111-111111111111",
  "resultingRevision": 1,
  "recordedAt": "2026-12-01T10:00:00Z"
}
```

- **400** — Invalid JSON, required properties or command arguments (VALIDATION_FAILED).

  Media type: `application/problem+json`.

  Example: `validation_failed` — VALIDATION_FAILED.

```json
{
  "title": "The request is invalid.",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Authentication required or user identity/session invalid (AUTHENTICATION_REQUIRED, INVALID_IDENTITY, SESSION_INVALID).

  Media type: `application/problem+json`.

  Example: `authentication_required` — AUTHENTICATION_REQUIRED.

```json
{
  "title": "Authentication required.",
  "status": 401,
  "code": "AUTHENTICATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

  Example: `invalid_identity` — INVALID_IDENTITY.

```json
{
  "title": "A valid user token with a session is required.",
  "status": 401,
  "code": "INVALID_IDENTITY",
  "correlationId": "integration-example-01"
}
```

  Example: `session_invalid` — SESSION_INVALID.

```json
{
  "title": "The session is not active.",
  "status": 401,
  "code": "SESSION_INVALID",
  "correlationId": "integration-example-01"
}
```

- **403** — Access policy or current business authority rejected (ACCESS_DENIED).

  Media type: `application/problem+json`.

  Example: `access_denied` — ACCESS_DENIED.

```json
{
  "title": "Access denied.",
  "status": 403,
  "code": "ACCESS_DENIED",
  "correlationId": "integration-example-01"
}
```

- **409** — Command rejected: PROFILE_EXISTS, IDEMPOTENCY_KEY_REUSED, RESOURCE_CONFLICT. Refetch on revision conflict; changed intent requires a new Idempotency-Key.

  Media type: `application/problem+json`.

  Example: `profile_exists` — PROFILE_EXISTS.

```json
{
  "title": "The command was rejected.",
  "status": 409,
  "code": "PROFILE_EXISTS",
  "correlationId": "integration-example-01"
}
```

  Example: `idempotency_key_reused` — IDEMPOTENCY_KEY_REUSED.

```json
{
  "title": "The operation ID is already in use.",
  "status": 409,
  "code": "IDEMPOTENCY_KEY_REUSED",
  "correlationId": "integration-example-01"
}
```

  Example: `resource_conflict` — RESOURCE_CONFLICT.

```json
{
  "title": "The resource already exists.",
  "status": 409,
  "code": "RESOURCE_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **415** — Unsupported request Content-Type (HTTP_ERROR); send a documented JSON media type.

  Media type: `application/problem+json`.

  Example: `http_error` — HTTP_ERROR.

```json
{
  "title": "The request could not be processed.",
  "status": 415,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure (INTERNAL_ERROR); preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

  Example: `internal_error` — INTERNAL_ERROR.

```json
{
  "title": "An unexpected error occurred.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Authoritative dependency or owned database unavailable (DEPENDENCY_UNAVAILABLE, DATABASE_UNAVAILABLE).

  Media type: `application/problem+json`.

  Example: `dependency_unavailable` — DEPENDENCY_UNAVAILABLE.

```json
{
  "title": "A required dependency is unavailable.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

  Example: `database_unavailable` — DATABASE_UNAVAILABLE.

```json
{
  "title": "The database is unavailable.",
  "status": 503,
  "code": "DATABASE_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### PUT /api/v1/users/me

Replace personal information using the expected resource revision.

 See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior. expectedRevision must be positive and match the current profile; a create request must omit it or set null.

Operation ID: `putApiV1UsersMe`.

**Authorization:** `[{"UserBearer": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| Idempotency-Key | header | False | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
PUT /api/v1/users/me HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "firstName": "Alex",
  "lastName": "Example",
  "emailAddress": "alex@example.test",
  "phoneNumber": null,
  "expectedRevision": 1
}
```

**Responses**

- **200** — OK

  Media type: `application/json`.

  Example: `typical` — OK.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "outcome": "Applied",
  "code": "APPLIED",
  "targetKind": "UserProfile",
  "targetId": "11111111-1111-4111-8111-111111111111",
  "resultingRevision": 1,
  "recordedAt": "2026-12-01T10:00:00Z"
}
```

  Media type: `text/json`.

  Example: `typical` — OK.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "outcome": "Applied",
  "code": "APPLIED",
  "targetKind": "UserProfile",
  "targetId": "11111111-1111-4111-8111-111111111111",
  "resultingRevision": 1,
  "recordedAt": "2026-12-01T10:00:00Z"
}
```

- **400** — Invalid JSON, required properties or command arguments (VALIDATION_FAILED).

  Media type: `application/problem+json`.

  Example: `validation_failed` — VALIDATION_FAILED.

```json
{
  "title": "The request is invalid.",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Authentication required or user identity/session invalid (AUTHENTICATION_REQUIRED, INVALID_IDENTITY, SESSION_INVALID).

  Media type: `application/problem+json`.

  Example: `authentication_required` — AUTHENTICATION_REQUIRED.

```json
{
  "title": "Authentication required.",
  "status": 401,
  "code": "AUTHENTICATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

  Example: `invalid_identity` — INVALID_IDENTITY.

```json
{
  "title": "A valid user token with a session is required.",
  "status": 401,
  "code": "INVALID_IDENTITY",
  "correlationId": "integration-example-01"
}
```

  Example: `session_invalid` — SESSION_INVALID.

```json
{
  "title": "The session is not active.",
  "status": 401,
  "code": "SESSION_INVALID",
  "correlationId": "integration-example-01"
}
```

- **403** — Access policy or current business authority rejected (ACCESS_DENIED).

  Media type: `application/problem+json`.

  Example: `access_denied` — ACCESS_DENIED.

```json
{
  "title": "Access denied.",
  "status": 403,
  "code": "ACCESS_DENIED",
  "correlationId": "integration-example-01"
}
```

- **409** — Command rejected: REVISION_CONFLICT, IDEMPOTENCY_KEY_REUSED, RESOURCE_CONFLICT. Refetch on revision conflict; changed intent requires a new Idempotency-Key.

  Media type: `application/problem+json`.

  Example: `revision_conflict` — REVISION_CONFLICT.

```json
{
  "title": "The resource has changed.",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

  Example: `idempotency_key_reused` — IDEMPOTENCY_KEY_REUSED.

```json
{
  "title": "The operation ID is already in use.",
  "status": 409,
  "code": "IDEMPOTENCY_KEY_REUSED",
  "correlationId": "integration-example-01"
}
```

  Example: `resource_conflict` — RESOURCE_CONFLICT.

```json
{
  "title": "The resource already exists.",
  "status": 409,
  "code": "RESOURCE_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **415** — Unsupported request Content-Type (HTTP_ERROR); send a documented JSON media type.

  Media type: `application/problem+json`.

  Example: `http_error` — HTTP_ERROR.

```json
{
  "title": "The request could not be processed.",
  "status": 415,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure (INTERNAL_ERROR); preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

  Example: `internal_error` — INTERNAL_ERROR.

```json
{
  "title": "An unexpected error occurred.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Authoritative dependency or owned database unavailable (DEPENDENCY_UNAVAILABLE, DATABASE_UNAVAILABLE).

  Media type: `application/problem+json`.

  Example: `dependency_unavailable` — DEPENDENCY_UNAVAILABLE.

```json
{
  "title": "A required dependency is unavailable.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

  Example: `database_unavailable` — DATABASE_UNAVAILABLE.

```json
{
  "title": "The database is unavailable.",
  "status": 503,
  "code": "DATABASE_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### GET /internal/v1/delegated/users/me

Read the current user's global profile and role bindings.

 Required workload scope and local client allowlist: profiles.mcp.write. See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior.

Operation ID: `getInternalV1DelegatedUsersMe`.

**Authorization:** `[{"WorkloadBearer": [], "DelegatedUser": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

**Sample request**

```http
GET /internal/v1/delegated/users/me HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
X-User-Authorization: Bearer ${USER_TOKEN}
```

**Responses**

- **200** — OK

  Media type: `application/json`.

  Example: `typical` — OK.

```json
{
  "userId": "11111111-1111-4111-8111-111111111111",
  "firstName": "Alex",
  "lastName": "Example",
  "emailAddress": "alex@example.test",
  "phoneNumber": "+37060000000",
  "status": "Active",
  "revision": 1,
  "createdAt": "2026-12-01T10:00:00Z",
  "updatedAt": "2026-12-01T10:00:00Z",
  "studentId": "11111111-1111-4111-8111-111111111111",
  "teacherId": "11111111-1111-4111-8111-111111111111",
  "administratorId": "11111111-1111-4111-8111-111111111111"
}
```

  Media type: `text/json`.

  Example: `typical` — OK.

```json
{
  "userId": "11111111-1111-4111-8111-111111111111",
  "firstName": "Alex",
  "lastName": "Example",
  "emailAddress": "alex@example.test",
  "phoneNumber": "+37060000000",
  "status": "Active",
  "revision": 1,
  "createdAt": "2026-12-01T10:00:00Z",
  "updatedAt": "2026-12-01T10:00:00Z",
  "studentId": "11111111-1111-4111-8111-111111111111",
  "teacherId": "11111111-1111-4111-8111-111111111111",
  "administratorId": "11111111-1111-4111-8111-111111111111"
}
```

- **401** — Authentication required or user identity/session invalid (AUTHENTICATION_REQUIRED, INVALID_IDENTITY, SESSION_INVALID).

  Media type: `application/problem+json`.

  Example: `authentication_required` — AUTHENTICATION_REQUIRED.

```json
{
  "title": "Authentication required.",
  "status": 401,
  "code": "AUTHENTICATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

  Example: `invalid_identity` — INVALID_IDENTITY.

```json
{
  "title": "A valid user token with a session is required.",
  "status": 401,
  "code": "INVALID_IDENTITY",
  "correlationId": "integration-example-01"
}
```

  Example: `session_invalid` — SESSION_INVALID.

```json
{
  "title": "The session is not active.",
  "status": 401,
  "code": "SESSION_INVALID",
  "correlationId": "integration-example-01"
}
```

- **403** — Access policy or current business authority rejected (ACCESS_DENIED).

  Media type: `application/problem+json`.

  Example: `access_denied` — ACCESS_DENIED.

```json
{
  "title": "Access denied.",
  "status": 403,
  "code": "ACCESS_DENIED",
  "correlationId": "integration-example-01"
}
```

- **404** — Profile, target user or role not found (NOT_FOUND).

  Media type: `application/problem+json`.

  Example: `not_found` — NOT_FOUND.

```json
{
  "title": "Resource not found or not visible.",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure (INTERNAL_ERROR); preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

  Example: `internal_error` — INTERNAL_ERROR.

```json
{
  "title": "An unexpected error occurred.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Authoritative dependency or owned database unavailable (DEPENDENCY_UNAVAILABLE, DATABASE_UNAVAILABLE).

  Media type: `application/problem+json`.

  Example: `dependency_unavailable` — DEPENDENCY_UNAVAILABLE.

```json
{
  "title": "A required dependency is unavailable.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

  Example: `database_unavailable` — DATABASE_UNAVAILABLE.

```json
{
  "title": "The database is unavailable.",
  "status": 503,
  "code": "DATABASE_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### POST /internal/v1/delegated/users/me

Create a profile bound to the authenticated identity.

 Required workload scope and local client allowlist: profiles.mcp.write. See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior.

Operation ID: `postInternalV1DelegatedUsersMe`.

**Authorization:** `[{"WorkloadBearer": [], "DelegatedUser": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| Idempotency-Key | header | False | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /internal/v1/delegated/users/me HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
X-User-Authorization: Bearer ${USER_TOKEN}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "firstName": "Alex",
  "lastName": "Example",
  "emailAddress": "alex@example.test",
  "phoneNumber": null,
  "confirmationId": "11111111-1111-4111-8111-111111111111"
}
```

**Responses**

- **201** — Created

  Media type: `application/json`.

  Example: `typical` — Created.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "outcome": "Applied",
  "code": "APPLIED",
  "targetKind": "UserProfile",
  "targetId": "11111111-1111-4111-8111-111111111111",
  "resultingRevision": 1,
  "recordedAt": "2026-12-01T10:00:00Z"
}
```

  Media type: `text/json`.

  Example: `typical` — Created.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "outcome": "Applied",
  "code": "APPLIED",
  "targetKind": "UserProfile",
  "targetId": "11111111-1111-4111-8111-111111111111",
  "resultingRevision": 1,
  "recordedAt": "2026-12-01T10:00:00Z"
}
```

- **400** — Invalid JSON, required properties or command arguments (VALIDATION_FAILED).

  Media type: `application/problem+json`.

  Example: `validation_failed` — VALIDATION_FAILED.

```json
{
  "title": "The request is invalid.",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Authentication required or user identity/session invalid (AUTHENTICATION_REQUIRED, INVALID_IDENTITY, SESSION_INVALID).

  Media type: `application/problem+json`.

  Example: `authentication_required` — AUTHENTICATION_REQUIRED.

```json
{
  "title": "Authentication required.",
  "status": 401,
  "code": "AUTHENTICATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

  Example: `invalid_identity` — INVALID_IDENTITY.

```json
{
  "title": "A valid user token with a session is required.",
  "status": 401,
  "code": "INVALID_IDENTITY",
  "correlationId": "integration-example-01"
}
```

  Example: `session_invalid` — SESSION_INVALID.

```json
{
  "title": "The session is not active.",
  "status": 401,
  "code": "SESSION_INVALID",
  "correlationId": "integration-example-01"
}
```

- **403** — Access policy or current business authority rejected (ACCESS_DENIED).

  Media type: `application/problem+json`.

  Example: `access_denied` — ACCESS_DENIED.

```json
{
  "title": "Access denied.",
  "status": 403,
  "code": "ACCESS_DENIED",
  "correlationId": "integration-example-01"
}
```

- **409** — Command rejected: PROFILE_EXISTS, IDEMPOTENCY_KEY_REUSED, RESOURCE_CONFLICT. Refetch on revision conflict; changed intent requires a new Idempotency-Key.

  Media type: `application/problem+json`.

  Example: `profile_exists` — PROFILE_EXISTS.

```json
{
  "title": "The command was rejected.",
  "status": 409,
  "code": "PROFILE_EXISTS",
  "correlationId": "integration-example-01"
}
```

  Example: `idempotency_key_reused` — IDEMPOTENCY_KEY_REUSED.

```json
{
  "title": "The operation ID is already in use.",
  "status": 409,
  "code": "IDEMPOTENCY_KEY_REUSED",
  "correlationId": "integration-example-01"
}
```

  Example: `resource_conflict` — RESOURCE_CONFLICT.

```json
{
  "title": "The resource already exists.",
  "status": 409,
  "code": "RESOURCE_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **415** — Unsupported request Content-Type (HTTP_ERROR); send a documented JSON media type.

  Media type: `application/problem+json`.

  Example: `http_error` — HTTP_ERROR.

```json
{
  "title": "The request could not be processed.",
  "status": 415,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **422** — Exact MCP confirmation is missing, invalid or expired (CONFIRMATION_REQUIRED, CONFIRMATION_INVALID, CONFIRMATION_EXPIRED).

  Media type: `application/problem+json`.

  Example: `confirmation_required` — CONFIRMATION_REQUIRED.

```json
{
  "title": "Exact confirmation is required.",
  "status": 422,
  "code": "CONFIRMATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

  Example: `confirmation_invalid` — CONFIRMATION_INVALID.

```json
{
  "title": "Confirmation does not match the command.",
  "status": 422,
  "code": "CONFIRMATION_INVALID",
  "correlationId": "integration-example-01"
}
```

  Example: `confirmation_expired` — CONFIRMATION_EXPIRED.

```json
{
  "title": "A fresh confirmation is required.",
  "status": 422,
  "code": "CONFIRMATION_EXPIRED",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure (INTERNAL_ERROR); preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

  Example: `internal_error` — INTERNAL_ERROR.

```json
{
  "title": "An unexpected error occurred.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Authoritative dependency or owned database unavailable (DEPENDENCY_UNAVAILABLE, DATABASE_UNAVAILABLE).

  Media type: `application/problem+json`.

  Example: `dependency_unavailable` — DEPENDENCY_UNAVAILABLE.

```json
{
  "title": "A required dependency is unavailable.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

  Example: `database_unavailable` — DATABASE_UNAVAILABLE.

```json
{
  "title": "The database is unavailable.",
  "status": 503,
  "code": "DATABASE_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### PUT /internal/v1/delegated/users/me

Replace personal information using the expected resource revision.

 Required workload scope and local client allowlist: profiles.mcp.write. See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior. expectedRevision must be positive and match the current profile; a create request must omit it or set null.

Operation ID: `putInternalV1DelegatedUsersMe`.

**Authorization:** `[{"WorkloadBearer": [], "DelegatedUser": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| Idempotency-Key | header | False | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
PUT /internal/v1/delegated/users/me HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
X-User-Authorization: Bearer ${USER_TOKEN}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "firstName": "Alex",
  "lastName": "Example",
  "emailAddress": "alex@example.test",
  "phoneNumber": null,
  "expectedRevision": 1,
  "confirmationId": "11111111-1111-4111-8111-111111111111"
}
```

**Responses**

- **200** — OK

  Media type: `application/json`.

  Example: `typical` — OK.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "outcome": "Applied",
  "code": "APPLIED",
  "targetKind": "UserProfile",
  "targetId": "11111111-1111-4111-8111-111111111111",
  "resultingRevision": 1,
  "recordedAt": "2026-12-01T10:00:00Z"
}
```

  Media type: `text/json`.

  Example: `typical` — OK.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "outcome": "Applied",
  "code": "APPLIED",
  "targetKind": "UserProfile",
  "targetId": "11111111-1111-4111-8111-111111111111",
  "resultingRevision": 1,
  "recordedAt": "2026-12-01T10:00:00Z"
}
```

- **400** — Invalid JSON, required properties or command arguments (VALIDATION_FAILED).

  Media type: `application/problem+json`.

  Example: `validation_failed` — VALIDATION_FAILED.

```json
{
  "title": "The request is invalid.",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Authentication required or user identity/session invalid (AUTHENTICATION_REQUIRED, INVALID_IDENTITY, SESSION_INVALID).

  Media type: `application/problem+json`.

  Example: `authentication_required` — AUTHENTICATION_REQUIRED.

```json
{
  "title": "Authentication required.",
  "status": 401,
  "code": "AUTHENTICATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

  Example: `invalid_identity` — INVALID_IDENTITY.

```json
{
  "title": "A valid user token with a session is required.",
  "status": 401,
  "code": "INVALID_IDENTITY",
  "correlationId": "integration-example-01"
}
```

  Example: `session_invalid` — SESSION_INVALID.

```json
{
  "title": "The session is not active.",
  "status": 401,
  "code": "SESSION_INVALID",
  "correlationId": "integration-example-01"
}
```

- **403** — Access policy or current business authority rejected (ACCESS_DENIED).

  Media type: `application/problem+json`.

  Example: `access_denied` — ACCESS_DENIED.

```json
{
  "title": "Access denied.",
  "status": 403,
  "code": "ACCESS_DENIED",
  "correlationId": "integration-example-01"
}
```

- **409** — Command rejected: REVISION_CONFLICT, IDEMPOTENCY_KEY_REUSED, RESOURCE_CONFLICT. Refetch on revision conflict; changed intent requires a new Idempotency-Key.

  Media type: `application/problem+json`.

  Example: `revision_conflict` — REVISION_CONFLICT.

```json
{
  "title": "The resource has changed.",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

  Example: `idempotency_key_reused` — IDEMPOTENCY_KEY_REUSED.

```json
{
  "title": "The operation ID is already in use.",
  "status": 409,
  "code": "IDEMPOTENCY_KEY_REUSED",
  "correlationId": "integration-example-01"
}
```

  Example: `resource_conflict` — RESOURCE_CONFLICT.

```json
{
  "title": "The resource already exists.",
  "status": 409,
  "code": "RESOURCE_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **415** — Unsupported request Content-Type (HTTP_ERROR); send a documented JSON media type.

  Media type: `application/problem+json`.

  Example: `http_error` — HTTP_ERROR.

```json
{
  "title": "The request could not be processed.",
  "status": 415,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **422** — Exact MCP confirmation is missing, invalid or expired (CONFIRMATION_REQUIRED, CONFIRMATION_INVALID, CONFIRMATION_EXPIRED).

  Media type: `application/problem+json`.

  Example: `confirmation_required` — CONFIRMATION_REQUIRED.

```json
{
  "title": "Exact confirmation is required.",
  "status": 422,
  "code": "CONFIRMATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

  Example: `confirmation_invalid` — CONFIRMATION_INVALID.

```json
{
  "title": "Confirmation does not match the command.",
  "status": 422,
  "code": "CONFIRMATION_INVALID",
  "correlationId": "integration-example-01"
}
```

  Example: `confirmation_expired` — CONFIRMATION_EXPIRED.

```json
{
  "title": "A fresh confirmation is required.",
  "status": 422,
  "code": "CONFIRMATION_EXPIRED",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure (INTERNAL_ERROR); preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

  Example: `internal_error` — INTERNAL_ERROR.

```json
{
  "title": "An unexpected error occurred.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Authoritative dependency or owned database unavailable (DEPENDENCY_UNAVAILABLE, DATABASE_UNAVAILABLE).

  Media type: `application/problem+json`.

  Example: `dependency_unavailable` — DEPENDENCY_UNAVAILABLE.

```json
{
  "title": "A required dependency is unavailable.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

  Example: `database_unavailable` — DATABASE_UNAVAILABLE.

```json
{
  "title": "The database is unavailable.",
  "status": 503,
  "code": "DATABASE_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### GET /api/v1/users/me/{role}-profile

Read a role profile; it does not establish school membership.

 See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior.

Operation ID: `getApiV1UsersMeRoleProfile`.

**Authorization:** `[{"UserBearer": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| role | path | True | `teacher` |

**Sample request**

```http
GET /api/v1/users/me/teacher-profile HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
```

**Responses**

- **200** — OK

  Media type: `application/json`.

  Example: `typical` — OK.

```json
{
  "kind": "Teacher",
  "profileId": "11111111-1111-4111-8111-111111111111",
  "userId": "11111111-1111-4111-8111-111111111111",
  "active": true
}
```

  Media type: `text/json`.

  Example: `typical` — OK.

```json
{
  "kind": "Student",
  "profileId": "11111111-1111-4111-8111-111111111111",
  "userId": "11111111-1111-4111-8111-111111111111",
  "active": true
}
```

- **401** — Authentication required or user identity/session invalid (AUTHENTICATION_REQUIRED, INVALID_IDENTITY, SESSION_INVALID).

  Media type: `application/problem+json`.

  Example: `authentication_required` — AUTHENTICATION_REQUIRED.

```json
{
  "title": "Authentication required.",
  "status": 401,
  "code": "AUTHENTICATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

  Example: `invalid_identity` — INVALID_IDENTITY.

```json
{
  "title": "A valid user token with a session is required.",
  "status": 401,
  "code": "INVALID_IDENTITY",
  "correlationId": "integration-example-01"
}
```

  Example: `session_invalid` — SESSION_INVALID.

```json
{
  "title": "The session is not active.",
  "status": 401,
  "code": "SESSION_INVALID",
  "correlationId": "integration-example-01"
}
```

- **403** — Access policy or current business authority rejected (ACCESS_DENIED).

  Media type: `application/problem+json`.

  Example: `access_denied` — ACCESS_DENIED.

```json
{
  "title": "Access denied.",
  "status": 403,
  "code": "ACCESS_DENIED",
  "correlationId": "integration-example-01"
}
```

- **404** — Profile, target user or role not found (NOT_FOUND).

  Media type: `application/problem+json`.

  Example: `not_found` — NOT_FOUND.

```json
{
  "title": "Resource not found or not visible.",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure (INTERNAL_ERROR); preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

  Example: `internal_error` — INTERNAL_ERROR.

```json
{
  "title": "An unexpected error occurred.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Authoritative dependency or owned database unavailable (DEPENDENCY_UNAVAILABLE, DATABASE_UNAVAILABLE).

  Media type: `application/problem+json`.

  Example: `dependency_unavailable` — DEPENDENCY_UNAVAILABLE.

```json
{
  "title": "A required dependency is unavailable.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

  Example: `database_unavailable` — DATABASE_UNAVAILABLE.

```json
{
  "title": "The database is unavailable.",
  "status": 503,
  "code": "DATABASE_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### POST /api/v1/users/me/{role}-profile

Create or reuse a stable role profile after current authorization checks.

 See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior. student requires schoolId and invitationId to be null; teacher/administrator require both. All delegated mutations require confirmationId.

Operation ID: `postApiV1UsersMeRoleProfile`.

**Authorization:** `[{"UserBearer": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| role | path | True | `teacher` |
| Idempotency-Key | header | False | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/users/me/teacher-profile HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "invitationId": "11111111-1111-4111-8111-111111111111"
}
```

**Responses**

- **200** — OK

  Media type: `application/json`.

  Example: `typical` — OK.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "outcome": "Applied",
  "code": "APPLIED",
  "targetKind": "TeacherProfile",
  "targetId": "11111111-1111-4111-8111-111111111111",
  "resultingRevision": null,
  "recordedAt": "2026-12-01T10:00:00Z"
}
```

  Media type: `text/json`.

  Example: `typical` — OK.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "outcome": "Applied",
  "code": "APPLIED",
  "targetKind": "TeacherProfile",
  "targetId": "11111111-1111-4111-8111-111111111111",
  "resultingRevision": null,
  "recordedAt": "2026-12-01T10:00:00Z"
}
```

- **201** — Created

  Media type: `application/json`.

  Example: `typical` — Created.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "outcome": "Applied",
  "code": "APPLIED",
  "targetKind": "TeacherProfile",
  "targetId": "11111111-1111-4111-8111-111111111111",
  "resultingRevision": null,
  "recordedAt": "2026-12-01T10:00:00Z"
}
```

  Media type: `text/json`.

  Example: `typical` — Created.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "outcome": "Applied",
  "code": "APPLIED",
  "targetKind": "TeacherProfile",
  "targetId": "11111111-1111-4111-8111-111111111111",
  "resultingRevision": null,
  "recordedAt": "2026-12-01T10:00:00Z"
}
```

- **400** — Invalid JSON, required properties or command arguments (VALIDATION_FAILED).

  Media type: `application/problem+json`.

  Example: `validation_failed` — VALIDATION_FAILED.

```json
{
  "title": "The request is invalid.",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Authentication required or user identity/session invalid (AUTHENTICATION_REQUIRED, INVALID_IDENTITY, SESSION_INVALID).

  Media type: `application/problem+json`.

  Example: `authentication_required` — AUTHENTICATION_REQUIRED.

```json
{
  "title": "Authentication required.",
  "status": 401,
  "code": "AUTHENTICATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

  Example: `invalid_identity` — INVALID_IDENTITY.

```json
{
  "title": "A valid user token with a session is required.",
  "status": 401,
  "code": "INVALID_IDENTITY",
  "correlationId": "integration-example-01"
}
```

  Example: `session_invalid` — SESSION_INVALID.

```json
{
  "title": "The session is not active.",
  "status": 401,
  "code": "SESSION_INVALID",
  "correlationId": "integration-example-01"
}
```

- **403** — Access policy or current business authority rejected (ACCESS_DENIED).

  Media type: `application/problem+json`.

  Example: `access_denied` — ACCESS_DENIED.

```json
{
  "title": "Access denied.",
  "status": 403,
  "code": "ACCESS_DENIED",
  "correlationId": "integration-example-01"
}
```

- **404** — Profile, target user or role not found (NOT_FOUND).

  Media type: `application/problem+json`.

  Example: `not_found` — NOT_FOUND.

```json
{
  "title": "Resource not found or not visible.",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Command rejected: IDEMPOTENCY_KEY_REUSED, RESOURCE_CONFLICT. Refetch on revision conflict; changed intent requires a new Idempotency-Key.

  Media type: `application/problem+json`.

  Example: `idempotency_key_reused` — IDEMPOTENCY_KEY_REUSED.

```json
{
  "title": "The operation ID is already in use.",
  "status": 409,
  "code": "IDEMPOTENCY_KEY_REUSED",
  "correlationId": "integration-example-01"
}
```

  Example: `resource_conflict` — RESOURCE_CONFLICT.

```json
{
  "title": "The resource already exists.",
  "status": 409,
  "code": "RESOURCE_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **415** — Unsupported request Content-Type (HTTP_ERROR); send a documented JSON media type.

  Media type: `application/problem+json`.

  Example: `http_error` — HTTP_ERROR.

```json
{
  "title": "The request could not be processed.",
  "status": 415,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure (INTERNAL_ERROR); preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

  Example: `internal_error` — INTERNAL_ERROR.

```json
{
  "title": "An unexpected error occurred.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Authoritative dependency or owned database unavailable (DEPENDENCY_UNAVAILABLE, DATABASE_UNAVAILABLE).

  Media type: `application/problem+json`.

  Example: `dependency_unavailable` — DEPENDENCY_UNAVAILABLE.

```json
{
  "title": "A required dependency is unavailable.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

  Example: `database_unavailable` — DATABASE_UNAVAILABLE.

```json
{
  "title": "The database is unavailable.",
  "status": 503,
  "code": "DATABASE_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### GET /internal/v1/delegated/users/me/{role}-profile

Read a role profile; it does not establish school membership.

 Required workload scope and local client allowlist: profiles.mcp.write. See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior.

Operation ID: `getInternalV1DelegatedUsersMeRoleProfile`.

**Authorization:** `[{"WorkloadBearer": [], "DelegatedUser": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| role | path | True | `teacher` |

**Sample request**

```http
GET /internal/v1/delegated/users/me/teacher-profile HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
X-User-Authorization: Bearer ${USER_TOKEN}
```

**Responses**

- **200** — OK

  Media type: `application/json`.

  Example: `typical` — OK.

```json
{
  "kind": "Teacher",
  "profileId": "11111111-1111-4111-8111-111111111111",
  "userId": "11111111-1111-4111-8111-111111111111",
  "active": true
}
```

  Media type: `text/json`.

  Example: `typical` — OK.

```json
{
  "kind": "Student",
  "profileId": "11111111-1111-4111-8111-111111111111",
  "userId": "11111111-1111-4111-8111-111111111111",
  "active": true
}
```

- **401** — Authentication required or user identity/session invalid (AUTHENTICATION_REQUIRED, INVALID_IDENTITY, SESSION_INVALID).

  Media type: `application/problem+json`.

  Example: `authentication_required` — AUTHENTICATION_REQUIRED.

```json
{
  "title": "Authentication required.",
  "status": 401,
  "code": "AUTHENTICATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

  Example: `invalid_identity` — INVALID_IDENTITY.

```json
{
  "title": "A valid user token with a session is required.",
  "status": 401,
  "code": "INVALID_IDENTITY",
  "correlationId": "integration-example-01"
}
```

  Example: `session_invalid` — SESSION_INVALID.

```json
{
  "title": "The session is not active.",
  "status": 401,
  "code": "SESSION_INVALID",
  "correlationId": "integration-example-01"
}
```

- **403** — Access policy or current business authority rejected (ACCESS_DENIED).

  Media type: `application/problem+json`.

  Example: `access_denied` — ACCESS_DENIED.

```json
{
  "title": "Access denied.",
  "status": 403,
  "code": "ACCESS_DENIED",
  "correlationId": "integration-example-01"
}
```

- **404** — Profile, target user or role not found (NOT_FOUND).

  Media type: `application/problem+json`.

  Example: `not_found` — NOT_FOUND.

```json
{
  "title": "Resource not found or not visible.",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure (INTERNAL_ERROR); preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

  Example: `internal_error` — INTERNAL_ERROR.

```json
{
  "title": "An unexpected error occurred.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Authoritative dependency or owned database unavailable (DEPENDENCY_UNAVAILABLE, DATABASE_UNAVAILABLE).

  Media type: `application/problem+json`.

  Example: `dependency_unavailable` — DEPENDENCY_UNAVAILABLE.

```json
{
  "title": "A required dependency is unavailable.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

  Example: `database_unavailable` — DATABASE_UNAVAILABLE.

```json
{
  "title": "The database is unavailable.",
  "status": 503,
  "code": "DATABASE_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### POST /internal/v1/delegated/users/me/{role}-profile

Create or reuse a stable role profile after current authorization checks.

 Required workload scope and local client allowlist: profiles.mcp.write. See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior. student requires schoolId and invitationId to be null; teacher/administrator require both. All delegated mutations require confirmationId.

Operation ID: `postInternalV1DelegatedUsersMeRoleProfile`.

**Authorization:** `[{"WorkloadBearer": [], "DelegatedUser": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| role | path | True | `teacher` |
| Idempotency-Key | header | False | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /internal/v1/delegated/users/me/teacher-profile HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
X-User-Authorization: Bearer ${USER_TOKEN}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "invitationId": "11111111-1111-4111-8111-111111111111",
  "confirmationId": "11111111-1111-4111-8111-111111111111"
}
```

**Responses**

- **200** — OK

  Media type: `application/json`.

  Example: `typical` — OK.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "outcome": "Applied",
  "code": "APPLIED",
  "targetKind": "TeacherProfile",
  "targetId": "11111111-1111-4111-8111-111111111111",
  "resultingRevision": null,
  "recordedAt": "2026-12-01T10:00:00Z"
}
```

  Media type: `text/json`.

  Example: `typical` — OK.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "outcome": "Applied",
  "code": "APPLIED",
  "targetKind": "TeacherProfile",
  "targetId": "11111111-1111-4111-8111-111111111111",
  "resultingRevision": null,
  "recordedAt": "2026-12-01T10:00:00Z"
}
```

- **201** — Created

  Media type: `application/json`.

  Example: `typical` — Created.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "outcome": "Applied",
  "code": "APPLIED",
  "targetKind": "TeacherProfile",
  "targetId": "11111111-1111-4111-8111-111111111111",
  "resultingRevision": null,
  "recordedAt": "2026-12-01T10:00:00Z"
}
```

  Media type: `text/json`.

  Example: `typical` — Created.

```json
{
  "operationId": "11111111-1111-4111-8111-111111111111",
  "outcome": "Applied",
  "code": "APPLIED",
  "targetKind": "TeacherProfile",
  "targetId": "11111111-1111-4111-8111-111111111111",
  "resultingRevision": null,
  "recordedAt": "2026-12-01T10:00:00Z"
}
```

- **400** — Invalid JSON, required properties or command arguments (VALIDATION_FAILED).

  Media type: `application/problem+json`.

  Example: `validation_failed` — VALIDATION_FAILED.

```json
{
  "title": "The request is invalid.",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Authentication required or user identity/session invalid (AUTHENTICATION_REQUIRED, INVALID_IDENTITY, SESSION_INVALID).

  Media type: `application/problem+json`.

  Example: `authentication_required` — AUTHENTICATION_REQUIRED.

```json
{
  "title": "Authentication required.",
  "status": 401,
  "code": "AUTHENTICATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

  Example: `invalid_identity` — INVALID_IDENTITY.

```json
{
  "title": "A valid user token with a session is required.",
  "status": 401,
  "code": "INVALID_IDENTITY",
  "correlationId": "integration-example-01"
}
```

  Example: `session_invalid` — SESSION_INVALID.

```json
{
  "title": "The session is not active.",
  "status": 401,
  "code": "SESSION_INVALID",
  "correlationId": "integration-example-01"
}
```

- **403** — Access policy or current business authority rejected (ACCESS_DENIED).

  Media type: `application/problem+json`.

  Example: `access_denied` — ACCESS_DENIED.

```json
{
  "title": "Access denied.",
  "status": 403,
  "code": "ACCESS_DENIED",
  "correlationId": "integration-example-01"
}
```

- **404** — Profile, target user or role not found (NOT_FOUND).

  Media type: `application/problem+json`.

  Example: `not_found` — NOT_FOUND.

```json
{
  "title": "Resource not found or not visible.",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Command rejected: IDEMPOTENCY_KEY_REUSED, RESOURCE_CONFLICT. Refetch on revision conflict; changed intent requires a new Idempotency-Key.

  Media type: `application/problem+json`.

  Example: `idempotency_key_reused` — IDEMPOTENCY_KEY_REUSED.

```json
{
  "title": "The operation ID is already in use.",
  "status": 409,
  "code": "IDEMPOTENCY_KEY_REUSED",
  "correlationId": "integration-example-01"
}
```

  Example: `resource_conflict` — RESOURCE_CONFLICT.

```json
{
  "title": "The resource already exists.",
  "status": 409,
  "code": "RESOURCE_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **415** — Unsupported request Content-Type (HTTP_ERROR); send a documented JSON media type.

  Media type: `application/problem+json`.

  Example: `http_error` — HTTP_ERROR.

```json
{
  "title": "The request could not be processed.",
  "status": 415,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **422** — Exact MCP confirmation is missing, invalid or expired (CONFIRMATION_REQUIRED, CONFIRMATION_INVALID, CONFIRMATION_EXPIRED).

  Media type: `application/problem+json`.

  Example: `confirmation_required` — CONFIRMATION_REQUIRED.

```json
{
  "title": "Exact confirmation is required.",
  "status": 422,
  "code": "CONFIRMATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

  Example: `confirmation_invalid` — CONFIRMATION_INVALID.

```json
{
  "title": "Confirmation does not match the command.",
  "status": 422,
  "code": "CONFIRMATION_INVALID",
  "correlationId": "integration-example-01"
}
```

  Example: `confirmation_expired` — CONFIRMATION_EXPIRED.

```json
{
  "title": "A fresh confirmation is required.",
  "status": 422,
  "code": "CONFIRMATION_EXPIRED",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure (INTERNAL_ERROR); preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

  Example: `internal_error` — INTERNAL_ERROR.

```json
{
  "title": "An unexpected error occurred.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Authoritative dependency or owned database unavailable (DEPENDENCY_UNAVAILABLE, DATABASE_UNAVAILABLE).

  Media type: `application/problem+json`.

  Example: `dependency_unavailable` — DEPENDENCY_UNAVAILABLE.

```json
{
  "title": "A required dependency is unavailable.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

  Example: `database_unavailable` — DATABASE_UNAVAILABLE.

```json
{
  "title": "The database is unavailable.",
  "status": 503,
  "code": "DATABASE_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

## Data models

Required fields, nullability, constraints and descriptions are authoritative in the YAML. Conditional and composed schemas are shown below.

### ApiProblem

Api Problem. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| title | True | `string` | {} |
| status | True | `integer` | {} |
| code | True | `string` | {} |
| correlationId | True | `string` | {} |
| type | False | `string` | {"format": "uri-reference"} |
| instance | False | `string` | {} |
| errors | False | `object` | {"additionalProperties": {"type": "array", "items": {"type": "string"}}} |
| operation | False | `#/components/schemas/OperationReceipt` | {} |

### BootstrapRequest

School-authorized bootstrap of the first administrator.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| schoolId | True | `string` | {"format": "uuid"} |

```json
{
  "additionalProperties": false
}
```

### DeactivateRequest

Global deactivation of a user at a specific revision.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| expectedRevision | True | `['integer', 'string']` | {"pattern": "^-?(?:0\|[1-9]\\d*)$", "format": "int64"} |
| reason | False | `['null', 'string']` | {"maxLength": 1000} |

```json
{
  "additionalProperties": false
}
```

### OperationOutcome

Canonical response names from JsonStringEnumConverter. The default converter also accepts defined integer enum input values; these models are responses.

```json
{
  "type": "string",
  "enum": [
    "Applied",
    "Rejected"
  ],
  "description": "Canonical response names from JsonStringEnumConverter. The default converter also accepts defined integer enum input values; these models are responses."
}
```

### OperationReceipt

Operation Receipt. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| operationId | True | `string` | {"format": "uuid"} |
| outcome | True | `#/components/schemas/OperationOutcome` | {} |
| code | True | `string` | {} |
| targetKind | True | `string` | {} |
| targetId | True | `string` | {"format": "uuid"} |
| resultingRevision | True | `['null', 'integer', 'string']` | {"pattern": "^-?(?:0\|[1-9]\\d*)$", "format": "int64"} |
| recordedAt | True | `string` | {"format": "date-time"} |

### ProfileKind

Canonical response names from JsonStringEnumConverter. The default converter also accepts defined integer enum input values; these models are responses.

```json
{
  "type": "string",
  "enum": [
    "Student",
    "Teacher",
    "Administrator"
  ],
  "description": "Canonical response names from JsonStringEnumConverter. The default converter also accepts defined integer enum input values; these models are responses."
}
```

### ProfileRequest

Personal information for creating or replacing the authenticated profile.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| firstName | True | `string` | {"minLength": 1, "maxLength": 100, "description": "Required non-whitespace personal name; original value is retained in the command fingerprint."} |
| lastName | True | `string` | {"minLength": 1, "maxLength": 100, "description": "Required non-whitespace personal name; original value is retained in the command fingerprint."} |
| emailAddress | True | `['null', 'string']` | {"maxLength": 254, "description": "Contact email or null; non-null values must pass FluentValidation EmailAddress. Not an authentication identity."} |
| phoneNumber | True | `['null', 'string']` | {"maxLength": 32, "description": "Non-whitespace contact number or null."} |
| expectedRevision | False | `['null', 'integer', 'string']` | {"pattern": "^-?(?:0\|[1-9]\\d*)$", "format": "int64"} |
| confirmationId | False | `['null', 'string']` | {"format": "uuid"} |

```json
{
  "additionalProperties": false
}
```

### RoleProfileResult

Role Profile Result. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| kind | True | `#/components/schemas/ProfileKind` | {} |
| profileId | True | `string` | {"format": "uuid"} |
| userId | True | `string` | {"format": "uuid"} |
| active | True | `boolean` | {} |

### RoleRequest

Role provisioning arguments; school and invitation are mandatory for staff roles.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| schoolId | False | `['null', 'string']` | {"format": "uuid"} |
| invitationId | False | `['null', 'string']` | {"format": "uuid"} |
| confirmationId | False | `['null', 'string']` | {"format": "uuid"} |

```json
{
  "additionalProperties": false
}
```

### UserContactResponse

Minimal contact details; a contact address can be absent.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| userId | True | `string` | {"format": "uuid"} |
| email | True | `['null', 'string']` | {} |

### UserProfileResult

User Profile Result. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| userId | True | `string` | {"format": "uuid"} |
| firstName | True | `string` | {} |
| lastName | True | `string` | {} |
| emailAddress | True | `['null', 'string']` | {} |
| phoneNumber | True | `['null', 'string']` | {} |
| status | True | `#/components/schemas/UserStatus` | {} |
| revision | True | `['integer', 'string']` | {"pattern": "^-?(?:0\|[1-9]\\d*)$", "format": "int64"} |
| createdAt | True | `string` | {"format": "date-time"} |
| updatedAt | True | `string` | {"format": "date-time"} |
| studentId | True | `['null', 'string']` | {"format": "uuid"} |
| teacherId | True | `['null', 'string']` | {"format": "uuid"} |
| administratorId | True | `['null', 'string']` | {"format": "uuid"} |

### UserStatus

Canonical response names from JsonStringEnumConverter. The default converter also accepts defined integer enum input values; these models are responses.

```json
{
  "type": "string",
  "enum": [
    "Active",
    "Inactive"
  ],
  "description": "Canonical response names from JsonStringEnumConverter. The default converter also accepts defined integer enum input values; these models are responses."
}
```

### UserStatusResponse

Authoritative global operational status.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| userId | True | `string` | {"format": "uuid"} |
| active | True | `boolean` | {} |
