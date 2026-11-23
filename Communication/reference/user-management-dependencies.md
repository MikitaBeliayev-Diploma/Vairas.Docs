# User Management dependency contracts

Exact checked consumer view of Auth, School and Chat provider path items consumed by implemented User Management clients. These providers remain proposed; validation checks drift against the owning specifications.

[Canonical OpenAPI](../Api/user-management-dependencies.openapi.yaml) | [Security](../guides/security.md) | [Errors](../guides/errors-and-reliability.md)

## Operations

### POST /connect/token

Obtain an outbound workload token using OAuth2 client credentials

Authenticate an allowlisted workload using OAuth2 client credentials and issue only its permitted scopes/audience. No end-user or school membership is implied. User Management consumes this interface.

Operation ID: `acquireUserManagementWorkloadToken`.

**Authorization:** `[]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

**Sample request**

```http
POST /connect/token HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials&client_id=user-management&client_secret=%24%7BWORKLOAD_CLIENT_SECRET%7D&scope=identity.validate+school.profile-provisioning+confirmations.validate
```

**Responses**

- **200** — Token is cached only until expiry minus a safety margin

  Media type: `application/json`.

```json
{
  "access_token": "${WORKLOAD_TOKEN}",
  "token_type": "Bearer",
  "expires_in": 900
}
```

- **400** — Invalid client credentials or scope

  Media type: `application/problem+json`.

```json
{
  "title": "Invalid client credentials or scope",
  "status": 400,
  "code": "PROVIDER_REJECTED",
  "correlationId": "integration-example-01"
}
```

- **401** — Client not authenticated

  Media type: `application/problem+json`.

```json
{
  "title": "Client not authenticated",
  "status": 401,
  "code": "PROVIDER_REJECTED",
  "correlationId": "integration-example-01"
}
```

**Invalid input example:** Missing required grant_type: reject with 400 before business work.

```json
{
  "client_id": "user-management",
  "client_secret": "${WORKLOAD_CLIENT_SECRET}",
  "scope": "identity.validate school.profile-provisioning confirmations.validate"
}
```

### POST /internal/v1/sessions/validate

Validate current identity admission and exact session ownership

Require an authenticated workload with identity.validate scope. Verify the exact identity/session pair, revocation and expiry; return authoritative admission and validUntil. This is global Authentication state, not school/enrollment authorization.

Operation ID: `validateUserManagementSession`.

**Authorization:** `[{"workloadOAuth": ["identity.validate"]}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

**Sample request**

```http
POST /internal/v1/sessions/validate HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Content-Type: application/json

{
  "identityId": "11111111-1111-4111-8111-111111111111",
  "sessionId": "11111111-1111-4111-8111-111111111111"
}
```

**Responses**

- **200** — Active only if identity Enabled, session belongs to identity, and the session is unexpired and unrevoked. Negative decisions echo the requested IDs without disclosing others.

  Media type: `application/json`.

```json
{
  "active": true,
  "identityId": "11111111-1111-4111-8111-111111111111",
  "sessionId": "11111111-1111-4111-8111-111111111111",
  "validUntil": "2026-12-01T11:00:00Z"
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

- **503** — No authoritative decision available

  Media type: `application/problem+json`.

```json
{
  "title": "No authoritative decision available",
  "status": 503,
  "code": "PROVIDER_REJECTED",
  "correlationId": "integration-example-01"
}
```

**Invalid input example:** Missing required identityId: reject with 400 before business work.

```json
{
  "sessionId": "11111111-1111-4111-8111-111111111111"
}
```

### POST /internal/v1/profile-provisioning/validate

Check exact invitation or initial administrator bootstrap authority

Check exact invitation or initial administrator bootstrap authority. The owning service enforces actor and school authorization.

Operation ID: `validateProfileProvisioning`.

**Authorization:** `[{"workloadOAuth": ["school.profile-provisioning"]}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

**Sample request**

```http
POST /internal/v1/profile-provisioning/validate HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Content-Type: application/json

{
  "actorUserId": "11111111-1111-4111-8111-111111111111",
  "targetUserId": "11111111-1111-4111-8111-111111111111",
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "invitationId": "11111111-1111-4111-8111-111111111111",
  "role": "Teacher",
  "bootstrap": false
}
```

**Responses**

- **200** — Echo every binding from the request. For ordinary onboarding require actor=target, exact School invitation target/role, active school and current issuer authority, valid status and unexpired invitation. An accepted invitation can authorize a completed retry only when it retains the same exact target and role binding. Bootstrap is Administrator-only and requires the School-owned first-administrator policy. InvitationId is an identifier, not a bearer secret. Never accept an invitation or create membership from this validation endpoint.

  Media type: `application/json`.

```json
{
  "actorUserId": "11111111-1111-4111-8111-111111111111",
  "targetUserId": "11111111-1111-4111-8111-111111111111",
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "invitationId": "11111111-1111-4111-8111-111111111111",
  "role": "Teacher",
  "bootstrap": false,
  "allowed": true,
  "authorityBasis": "invitation-revision-3",
  "validUntil": "2026-12-01T11:00:00Z"
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

- **503** — Authoritative decision unavailable

  Media type: `application/problem+json`.

```json
{
  "title": "Authoritative decision unavailable",
  "status": 503,
  "code": "PROVIDER_REJECTED",
  "correlationId": "integration-example-01"
}
```

**Invalid input example:** Missing required actorUserId: reject with 400 before business work.

```json
{
  "targetUserId": "11111111-1111-4111-8111-111111111111",
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "invitationId": "11111111-1111-4111-8111-111111111111",
  "role": "Teacher",
  "bootstrap": false
}
```

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

## Data models

Required fields, nullability, constraints and descriptions are authoritative in the YAML. Conditional and composed schemas are shown below.

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

### Problem

Problem. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| title | True | `string` | {} |
| status | True | `integer` | {} |
| code | True | `string` | {} |
| correlationId | True | `string` | {} |
