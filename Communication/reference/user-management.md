# Vairas User Management API

Global profiles and idempotent commands. Internal operations require a workload JWT. Delegated and platform mutations additionally require a user JWT in X-User-Authorization. Mutations return operation receipts; fetch current resource state separately.

[Canonical OpenAPI](../Api/user-management.openapi.yaml) | [Security](../guides/security.md) | [Errors](../guides/errors-and-reliability.md)

## Operations

### GET /internal/v1/users/{userId}/status

Read operational status using a permitted workload identity.

 Required workload scope and local client allowlist: profiles.status.read. See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior.

Operation ID: `getInternalV1UsersUserIdStatus`. Status: **implemented**.

**Authorization:** `[{"WorkloadBearer": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

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

  Media type: `text/plain`.

```text
{'userId': '11111111-1111-4111-8111-111111111111', 'active': True}
```


  Media type: `application/json`.

```json
{
  "userId": "11111111-1111-4111-8111-111111111111",
  "active": true
}
```


  Media type: `text/json`.

```json
{
  "userId": "11111111-1111-4111-8111-111111111111",
  "active": true
}
```

- **400** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 422,
  "code": "CONFIRMATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure; preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

```json
{
  "title": "Unexpected failure; preserve correlation ID and reconcile mutations before retrying.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### GET /internal/v1/users/{userId}/contact

Read a minimal contact projection for a configured notification/document workload.

 Required workload scope and local client allowlist: profiles.contact.read. See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior.

Operation ID: `getInternalV1UsersUserIdContact`. Status: **implemented**.

**Authorization:** `[{"WorkloadBearer": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

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

  Media type: `text/plain`.

```text
{'userId': '11111111-1111-4111-8111-111111111111', 'email': 'alex@example.test'}
```


  Media type: `application/json`.

```json
{
  "userId": "11111111-1111-4111-8111-111111111111",
  "email": "alex@example.test"
}
```


  Media type: `text/json`.

```json
{
  "userId": "11111111-1111-4111-8111-111111111111",
  "email": "alex@example.test"
}
```

- **400** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 422,
  "code": "CONFIRMATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure; preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

```json
{
  "title": "Unexpected failure; preserve correlation ID and reconcile mutations before retrying.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### GET /internal/v1/profiles/{kind}/{profileId}

Resolve a role identifier to its global user and active state.

 Required workload scope and local client allowlist: profiles.binding.read. See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior.

Operation ID: `getInternalV1ProfilesKindProfileId`. Status: **implemented**.

**Authorization:** `[{"WorkloadBearer": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

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

  Media type: `text/plain`.

```text
{'kind': 'Student', 'profileId': '11111111-1111-4111-8111-111111111111', 'userId': '11111111-1111-4111-8111-111111111111', 'active': True}
```


  Media type: `application/json`.

```json
{
  "kind": "Teacher",
  "profileId": "11111111-1111-4111-8111-111111111111",
  "userId": "11111111-1111-4111-8111-111111111111",
  "active": true
}
```


  Media type: `text/json`.

```json
{
  "kind": "Student",
  "profileId": "11111111-1111-4111-8111-111111111111",
  "userId": "11111111-1111-4111-8111-111111111111",
  "active": true
}
```

- **400** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 422,
  "code": "CONFIRMATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure; preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

```json
{
  "title": "Unexpected failure; preserve correlation ID and reconcile mutations before retrying.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### POST /internal/v1/users/{userId}/deactivate

Deactivate a global user using both platform-operator and workload authorization.

 Required workload scope and local client allowlist: profiles.deactivate. See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior.

Operation ID: `postInternalV1UsersUserIdDeactivate`. Status: **implemented**.

**Authorization:** `[{"WorkloadBearer": [], "DelegatedUser": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

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

- **200** — OK
- **400** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 422,
  "code": "CONFIRMATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure; preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

```json
{
  "title": "Unexpected failure; preserve correlation ID and reconcile mutations before retrying.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

**Invalid input example:** Missing required expectedRevision: reject with 400 before business work.

```json
{
  "reason": "Instructor requested a schedule correction."
}
```

### POST /internal/v1/users/{userId}/administrator-profile/bootstrap

Bootstrap an administrator after checking platform and school authority.

 Required workload scope and local client allowlist: profiles.bootstrap. See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior.

Operation ID: `postInternalV1UsersUserIdAdministratorProfileBootstrap`. Status: **implemented**.

**Authorization:** `[{"WorkloadBearer": [], "DelegatedUser": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

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

- **200** — OK
- **400** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 422,
  "code": "CONFIRMATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure; preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

```json
{
  "title": "Unexpected failure; preserve correlation ID and reconcile mutations before retrying.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

**Invalid input example:** Missing required schoolId: reject with 400 before business work.

```json
{}
```

### GET /api/v1/users/me

Read the current user's global profile and role bindings.

 See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior.

Operation ID: `getApiV1UsersMe`. Status: **implemented**.

**Authorization:** `[{"UserBearer": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

**Sample request**

```http
GET /api/v1/users/me HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
```

**Responses**

- **200** — OK

  Media type: `text/plain`.

```text
{'userId': '11111111-1111-4111-8111-111111111111', 'firstName': 'Alex', 'lastName': 'Example', 'emailAddress': 'alex@example.test', 'phoneNumber': '+37060000000', 'status': 'Active', 'revision': 1, 'createdAt': '2026-12-01T10:00:00Z', 'updatedAt': '2026-12-01T10:00:00Z', 'studentId': '11111111-1111-4111-8111-111111111111', 'teacherId': '11111111-1111-4111-8111-111111111111', 'administratorId': '11111111-1111-4111-8111-111111111111'}
```


  Media type: `application/json`.

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

- **400** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 422,
  "code": "CONFIRMATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure; preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

```json
{
  "title": "Unexpected failure; preserve correlation ID and reconcile mutations before retrying.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### POST /api/v1/users/me

Create a profile bound to the authenticated identity.

 See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior.

Operation ID: `postApiV1UsersMe`. Status: **implemented**.

**Authorization:** `[{"UserBearer": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

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

  Media type: `text/plain`.

```text
{'operationId': '11111111-1111-4111-8111-111111111111', 'outcome': 'Applied', 'code': 'APPLIED', 'targetKind': 'UserProfile', 'targetId': '11111111-1111-4111-8111-111111111111', 'resultingRevision': 1, 'recordedAt': '2026-12-01T10:00:00Z'}
```


  Media type: `application/json`.

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

- **400** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 422,
  "code": "CONFIRMATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure; preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

```json
{
  "title": "Unexpected failure; preserve correlation ID and reconcile mutations before retrying.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

**Invalid input example:** Missing required firstName: reject with 400 before business work.

```json
{
  "lastName": "Example",
  "emailAddress": "alex@example.test",
  "phoneNumber": null
}
```

### PUT /api/v1/users/me

Replace personal information using the expected resource revision.

 See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior. expectedRevision must be positive and match the current profile; a create request must omit it or set null.

Operation ID: `putApiV1UsersMe`. Status: **implemented**.

**Authorization:** `[{"UserBearer": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

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

  Media type: `text/plain`.

```text
{'operationId': '11111111-1111-4111-8111-111111111111', 'outcome': 'Applied', 'code': 'APPLIED', 'targetKind': 'UserProfile', 'targetId': '11111111-1111-4111-8111-111111111111', 'resultingRevision': 1, 'recordedAt': '2026-12-01T10:00:00Z'}
```


  Media type: `application/json`.

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

- **400** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 422,
  "code": "CONFIRMATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure; preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

```json
{
  "title": "Unexpected failure; preserve correlation ID and reconcile mutations before retrying.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

**Invalid input example:** Missing required firstName: reject with 400 before business work.

```json
{
  "lastName": "Example",
  "emailAddress": "alex@example.test",
  "phoneNumber": null,
  "expectedRevision": 1
}
```

### GET /internal/v1/delegated/users/me

Read the current user's global profile and role bindings.

 Required workload scope and local client allowlist: profiles.mcp.write. See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior.

Operation ID: `getInternalV1DelegatedUsersMe`. Status: **implemented**.

**Authorization:** `[{"WorkloadBearer": [], "DelegatedUser": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

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

  Media type: `text/plain`.

```text
{'userId': '11111111-1111-4111-8111-111111111111', 'firstName': 'Alex', 'lastName': 'Example', 'emailAddress': 'alex@example.test', 'phoneNumber': '+37060000000', 'status': 'Active', 'revision': 1, 'createdAt': '2026-12-01T10:00:00Z', 'updatedAt': '2026-12-01T10:00:00Z', 'studentId': '11111111-1111-4111-8111-111111111111', 'teacherId': '11111111-1111-4111-8111-111111111111', 'administratorId': '11111111-1111-4111-8111-111111111111'}
```


  Media type: `application/json`.

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

- **400** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 422,
  "code": "CONFIRMATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure; preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

```json
{
  "title": "Unexpected failure; preserve correlation ID and reconcile mutations before retrying.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### POST /internal/v1/delegated/users/me

Create a profile bound to the authenticated identity.

 Required workload scope and local client allowlist: profiles.mcp.write. See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior.

Operation ID: `postInternalV1DelegatedUsersMe`. Status: **implemented**.

**Authorization:** `[{"WorkloadBearer": [], "DelegatedUser": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

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

  Media type: `text/plain`.

```text
{'operationId': '11111111-1111-4111-8111-111111111111', 'outcome': 'Applied', 'code': 'APPLIED', 'targetKind': 'UserProfile', 'targetId': '11111111-1111-4111-8111-111111111111', 'resultingRevision': 1, 'recordedAt': '2026-12-01T10:00:00Z'}
```


  Media type: `application/json`.

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

- **400** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 422,
  "code": "CONFIRMATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure; preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

```json
{
  "title": "Unexpected failure; preserve correlation ID and reconcile mutations before retrying.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

**Invalid input example:** Missing required firstName: reject with 400 before business work.

```json
{
  "lastName": "Example",
  "emailAddress": "alex@example.test",
  "phoneNumber": null,
  "confirmationId": "11111111-1111-4111-8111-111111111111"
}
```

### PUT /internal/v1/delegated/users/me

Replace personal information using the expected resource revision.

 Required workload scope and local client allowlist: profiles.mcp.write. See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior. expectedRevision must be positive and match the current profile; a create request must omit it or set null.

Operation ID: `putInternalV1DelegatedUsersMe`. Status: **implemented**.

**Authorization:** `[{"WorkloadBearer": [], "DelegatedUser": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

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

  Media type: `text/plain`.

```text
{'operationId': '11111111-1111-4111-8111-111111111111', 'outcome': 'Applied', 'code': 'APPLIED', 'targetKind': 'UserProfile', 'targetId': '11111111-1111-4111-8111-111111111111', 'resultingRevision': 1, 'recordedAt': '2026-12-01T10:00:00Z'}
```


  Media type: `application/json`.

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

- **400** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 422,
  "code": "CONFIRMATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure; preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

```json
{
  "title": "Unexpected failure; preserve correlation ID and reconcile mutations before retrying.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

**Invalid input example:** Missing required firstName: reject with 400 before business work.

```json
{
  "lastName": "Example",
  "emailAddress": "alex@example.test",
  "phoneNumber": null,
  "expectedRevision": 1,
  "confirmationId": "11111111-1111-4111-8111-111111111111"
}
```

### GET /api/v1/users/me/{role}-profile

Read a role profile; it does not establish school membership.

 See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior.

Operation ID: `getApiV1UsersMeRoleProfile`. Status: **implemented**.

**Authorization:** `[{"UserBearer": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

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

  Media type: `text/plain`.

```text
{'kind': 'Student', 'profileId': '11111111-1111-4111-8111-111111111111', 'userId': '11111111-1111-4111-8111-111111111111', 'active': True}
```


  Media type: `application/json`.

```json
{
  "kind": "Teacher",
  "profileId": "11111111-1111-4111-8111-111111111111",
  "userId": "11111111-1111-4111-8111-111111111111",
  "active": true
}
```


  Media type: `text/json`.

```json
{
  "kind": "Student",
  "profileId": "11111111-1111-4111-8111-111111111111",
  "userId": "11111111-1111-4111-8111-111111111111",
  "active": true
}
```

- **400** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 422,
  "code": "CONFIRMATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure; preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

```json
{
  "title": "Unexpected failure; preserve correlation ID and reconcile mutations before retrying.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### POST /api/v1/users/me/{role}-profile

Create or reuse a stable role profile after current authorization checks.

 See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior. student requires schoolId and invitationId to be null; teacher/administrator require both. All delegated mutations require confirmationId.

Operation ID: `postApiV1UsersMeRoleProfile`. Status: **implemented**.

**Authorization:** `[{"UserBearer": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

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

- **201** — Created

  Media type: `text/plain`.

```text
{'operationId': '11111111-1111-4111-8111-111111111111', 'outcome': 'Applied', 'code': 'APPLIED', 'targetKind': 'TeacherProfile', 'targetId': '11111111-1111-4111-8111-111111111111', 'resultingRevision': None, 'recordedAt': '2026-12-01T10:00:00Z'}
```


  Media type: `application/json`.

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

- **200** — OK

  Media type: `text/plain`.

```text
{'operationId': '11111111-1111-4111-8111-111111111111', 'outcome': 'Applied', 'code': 'APPLIED', 'targetKind': 'TeacherProfile', 'targetId': '11111111-1111-4111-8111-111111111111', 'resultingRevision': None, 'recordedAt': '2026-12-01T10:00:00Z'}
```


  Media type: `application/json`.

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

- **400** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 422,
  "code": "CONFIRMATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure; preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

```json
{
  "title": "Unexpected failure; preserve correlation ID and reconcile mutations before retrying.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### GET /internal/v1/delegated/users/me/{role}-profile

Read a role profile; it does not establish school membership.

 Required workload scope and local client allowlist: profiles.mcp.write. See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior.

Operation ID: `getInternalV1DelegatedUsersMeRoleProfile`. Status: **implemented**.

**Authorization:** `[{"WorkloadBearer": [], "DelegatedUser": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

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

  Media type: `text/plain`.

```text
{'kind': 'Student', 'profileId': '11111111-1111-4111-8111-111111111111', 'userId': '11111111-1111-4111-8111-111111111111', 'active': True}
```


  Media type: `application/json`.

```json
{
  "kind": "Teacher",
  "profileId": "11111111-1111-4111-8111-111111111111",
  "userId": "11111111-1111-4111-8111-111111111111",
  "active": true
}
```


  Media type: `text/json`.

```json
{
  "kind": "Student",
  "profileId": "11111111-1111-4111-8111-111111111111",
  "userId": "11111111-1111-4111-8111-111111111111",
  "active": true
}
```

- **400** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 422,
  "code": "CONFIRMATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure; preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

```json
{
  "title": "Unexpected failure; preserve correlation ID and reconcile mutations before retrying.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
  "correlationId": "integration-example-01"
}
```

### POST /internal/v1/delegated/users/me/{role}-profile

Create or reuse a stable role profile after current authorization checks.

 Required workload scope and local client allowlist: profiles.mcp.write. See ../guides/security.md and ../guides/errors-and-reliability.md for current authorization and retry behavior. student requires schoolId and invitationId to be null; teacher/administrator require both. All delegated mutations require confirmationId.

Operation ID: `postInternalV1DelegatedUsersMeRoleProfile`. Status: **implemented**.

**Authorization:** `[{"WorkloadBearer": [], "DelegatedUser": []}]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

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

- **201** — Created

  Media type: `text/plain`.

```text
{'operationId': '11111111-1111-4111-8111-111111111111', 'outcome': 'Applied', 'code': 'APPLIED', 'targetKind': 'TeacherProfile', 'targetId': '11111111-1111-4111-8111-111111111111', 'resultingRevision': None, 'recordedAt': '2026-12-01T10:00:00Z'}
```


  Media type: `application/json`.

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

- **200** — OK

  Media type: `text/plain`.

```text
{'operationId': '11111111-1111-4111-8111-111111111111', 'outcome': 'Applied', 'code': 'APPLIED', 'targetKind': 'TeacherProfile', 'targetId': '11111111-1111-4111-8111-111111111111', 'resultingRevision': None, 'recordedAt': '2026-12-01T10:00:00Z'}
```


  Media type: `application/json`.

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

- **400** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 400,
  "code": "VALIDATION_FAILED",
  "correlationId": "integration-example-01"
}
```

- **401** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 401,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **403** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 403,
  "code": "HTTP_ERROR",
  "correlationId": "integration-example-01"
}
```

- **404** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 404,
  "code": "NOT_FOUND",
  "correlationId": "integration-example-01"
}
```

- **409** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 409,
  "code": "REVISION_CONFLICT",
  "correlationId": "integration-example-01"
}
```

- **422** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 422,
  "code": "CONFIRMATION_REQUIRED",
  "correlationId": "integration-example-01"
}
```

- **500** — Unexpected failure; preserve correlation ID and reconcile mutations before retrying.

  Media type: `application/problem+json`.

```json
{
  "title": "Unexpected failure; preserve correlation ID and reconcile mutations before retrying.",
  "status": 500,
  "code": "INTERNAL_ERROR",
  "correlationId": "integration-example-01"
}
```

- **503** — Problem Details with code and correlationId.

  Media type: `application/problem+json`.

```json
{
  "title": "Problem Details with code and correlationId.",
  "status": 503,
  "code": "DEPENDENCY_UNAVAILABLE",
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
