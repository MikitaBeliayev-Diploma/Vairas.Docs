# Vairas Authentication API

Source: Authentication database identity/session/token/challenge model and User Management dependency clients. Credential policy, challenge delivery adapter and external issuer allowlist are design settings requiring implementation review; login is not an OAuth password grant. Browser OIDC correlation must use secure server-bound cookies; linking requires the existing user session.

[Canonical OpenAPI](../Api/authentication.openapi.yaml) | [Security](../guides/security.md) | [Errors](../guides/errors-and-reliability.md)

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

### POST /api/v1/auth/registrations

Register a local identity without creating a UserProfile

Register a local identity without creating a UserProfile or school enrollment. This entry point is anonymous; validate credentials and account policy, apply abuse controls and avoid disclosing account existence.

Operation ID: `registerIdentity`.

**Authorization:** `[]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

**Sample request**

```http
POST /api/v1/auth/registrations HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Content-Type: application/json

{
  "email": "alex@example.test",
  "password": "${USER_PASSWORD}"
}
```

**Responses**

- **202** — Successful result

  Media type: `application/json`.

```json
{
  "message": "Request accepted."
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

**Invalid input example:** Missing required email: reject with 400 before business work.

```json
{
  "password": "synthetic-passphrase-2026"
}
```

### POST /api/v1/auth/login

Issue an identity/session-bound token pair

Authenticate local credentials and issue an identity/session-bound token pair. This entry point is anonymous; check account activity and apply anti-enumeration and abuse controls. School authorization remains with business services.

Operation ID: `loginIdentity`.

**Authorization:** `[]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

**Sample request**

```http
POST /api/v1/auth/login HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Content-Type: application/json

{
  "email": "alex@example.test",
  "password": "${USER_PASSWORD}"
}
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
{
  "accessToken": "${USER_TOKEN}",
  "refreshToken": "${REFRESH_TOKEN}",
  "tokenType": "Bearer",
  "expiresIn": 900,
  "identityId": "11111111-1111-4111-8111-111111111111",
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

**Invalid input example:** Missing required email: reject with 400 before business work.

```json
{
  "password": "${USER_PASSWORD}"
}
```

### POST /api/v1/auth/refresh

Rotate one refresh token; reuse revokes the affected session family

Authenticate the presented refresh-token credential, rotate it once and revoke the affected session family on detected reuse. No access bearer is required; check session activity, expiry and exact token-family binding.

Operation ID: `rotateRefreshToken`.

**Authorization:** `[]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

**Sample request**

```http
POST /api/v1/auth/refresh HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Content-Type: application/json

{
  "refreshToken": "${REFRESH_TOKEN}"
}
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
{
  "accessToken": "${USER_TOKEN}",
  "refreshToken": "${REFRESH_TOKEN}",
  "tokenType": "Bearer",
  "expiresIn": 900,
  "identityId": "11111111-1111-4111-8111-111111111111",
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

**Invalid input example:** Missing required refreshToken: reject with 400 before business work.

```json
{}
```

### POST /api/v1/auth/challenges

Request a challenge without disclosing account existence

Request a verification or password-reset challenge without revealing account existence. No prior bearer is required. Rate-limit delivery, return a generic acknowledgment and retain only protected challenge material.

Operation ID: `requestAccountChallenge`.

**Authorization:** `[]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

**Sample request**

```http
POST /api/v1/auth/challenges HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Content-Type: application/json

{
  "email": "alex@example.test",
  "purpose": "VerifyEmail"
}
```

**Responses**

- **202** — Successful result

  Media type: `application/json`.

```json
{
  "message": "Request accepted."
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

**Invalid input example:** Missing required email: reject with 400 before business work.

```json
{
  "purpose": "VerifyEmail"
}
```

### POST /api/v1/auth/challenges/completion

Consume one unexpired revision-bound challenge

Consume one unexpired, purpose- and credential-revision-bound challenge. The challenge credential authorizes this operation; no school/enrollment membership or prior access bearer is required. A password-reset challenge requires newPassword and revokes affected sessions under the owner policy.

Operation ID: `completeAccountChallenge`.

**Authorization:** `[]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

**Sample request**

```http
POST /api/v1/auth/challenges/completion HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Content-Type: application/json

{
  "challengeToken": "${CHALLENGE_TOKEN}",
  "newPassword": "${NEW_USER_PASSWORD}"
}
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
{
  "message": "Request accepted."
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

**Invalid input example:** Missing required challengeToken: reject with 400 before business work.

```json
{
  "newPassword": "synthetic-new-passphrase-2026"
}
```

### POST /api/v1/auth/oidc/requests

Start allowlisted OIDC login or authenticated explicit linking

Start allowlisted external OIDC login or explicit linking. Login may be anonymous. Link requires a currently authenticated active identity/session, server-bound to the stored request; reject anonymous Link with 401. Validate exact issuer and redirect URI and retain state, nonce and PKCE bindings. Never infer linking from email.

Operation ID: `beginOidc`.

**Authorization:** `[{}, {"bearerAuth": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

**Sample request**

```http
POST /api/v1/auth/oidc/requests HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Content-Type: application/json

{
  "issuer": "https://auth.vairas.example",
  "redirectUri": "https://app.vairas.example/auth/callback",
  "purpose": "Login"
}
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
{
  "authorizationUrl": "https://identity.example/authorize?state=synthetic-state"
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

**Invalid input example:** Missing required issuer: reject with 400 before business work.

```json
{
  "redirectUri": "https://app.vairas.example/auth/callback",
  "purpose": "Login"
}
```

### POST /api/v1/auth/oidc/callback

Verify state, nonce, PKCE and exact issuer/subject; never autolink by email

Validate the stored one-time request, state, nonce, PKCE, exact issuer/subject and allowlisted redirect. For Link, recheck the originally bound identity/session before changing its external binding. No caller-supplied school or matching email grants identity ownership.

Operation ID: `completeOidc`.

**Authorization:** `[]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

**Sample request**

```http
POST /api/v1/auth/oidc/callback HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Content-Type: application/json

{
  "code": "APPLIED",
  "state": "synthetic-state"
}
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
{
  "accessToken": "${USER_TOKEN}",
  "refreshToken": "${REFRESH_TOKEN}",
  "tokenType": "Bearer",
  "expiresIn": 900,
  "identityId": "11111111-1111-4111-8111-111111111111",
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

**Invalid input example:** Missing required code: reject with 400 before business work.

```json
{
  "state": "synthetic-state"
}
```

### POST /api/v1/auth/sessions/{sessionId}/revocation

Revoke an owned session and its refresh family

Require a valid authenticated identity and verify that sessionId belongs to it. Revoke that session and refresh family idempotently; school membership is not authority to revoke another identity session.

Operation ID: `revokeOwnSession`.

**Authorization:** `[{"bearerAuth": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| sessionId | path | True | `11111111-1111-4111-8111-111111111111` |
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/auth/sessions/11111111-1111-4111-8111-111111111111/revocation HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
{
  "message": "Request accepted."
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

### GET /.well-known/openid-configuration

Return configured issuer metadata

Return public configured issuer metadata used by JWT consumers. No bearer or school/enrollment authorization is required; publish only configured issuer/key locations and supported capabilities.

Operation ID: `getIssuerDiscovery`.

**Authorization:** `[]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

**Sample request**

```http
GET /.well-known/openid-configuration HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
{
  "issuer": "https://auth.vairas.example",
  "jwks_uri": "https://auth.vairas.example/.well-known/jwks.json",
  "token_endpoint": "https://auth.vairas.example/connect/token"
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

### GET /.well-known/jwks.json

Return public signing keys only

Return public signing keys only. No bearer or school/enrollment authorization is required. Never publish private key parameters or symmetric signing material.

Operation ID: `getSigningKeys`.

**Authorization:** `[]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

**Sample request**

```http
GET /.well-known/jwks.json HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
{
  "keys": [
    {
      "kty": "RSA",
      "use": "sig",
      "alg": "RS256",
      "kid": "synthetic-key-1",
      "n": "c3ludGhldGljLW1vZHVsdXM",
      "e": "AQAB"
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

### Registration

Registration. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| email | True | `string` | {"format": "email"} |
| password | True | `string` | {"minLength": 12, "writeOnly": true} |

### Login

Login. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| email | True | `string` | {"format": "email"} |
| password | True | `string` | {"writeOnly": true} |

### TokenPair

Token Pair. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| accessToken | True | `string` | {} |
| refreshToken | True | `string` | {} |
| tokenType | True | `string` | {"enum": ["Bearer"]} |
| expiresIn | True | `integer` | {"minimum": 1} |
| identityId | True | `string` | {"format": "uuid"} |
| sessionId | True | `string` | {"format": "uuid"} |

### Refresh

Refresh. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| refreshToken | True | `string` | {"writeOnly": true} |

### Accepted

Accepted. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| message | True | `string` | {} |

### ChallengeRequest

Challenge Request. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| email | True | `string` | {"format": "email"} |
| purpose | True | `string` | {"enum": ["VerifyEmail", "ResetPassword"]} |

### ChallengeCompletion

Challenge Completion. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| challengeToken | True | `string` | {"writeOnly": true} |
| newPassword | False | `string` | {"minLength": 12, "writeOnly": true} |

### SessionRevocation

Session Revocation. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| sessionId | True | `string` | {"format": "uuid"} |

### OidcStart

Oidc Start. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| issuer | True | `string` | {"format": "uri"} |
| redirectUri | True | `string` | {"format": "uri"} |
| purpose | True | `string` | {"enum": ["Login", "Link"]} |

### OidcRedirect

Oidc Redirect. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| authorizationUrl | True | `string` | {"format": "uri"} |

### OidcCallback

Oidc Callback. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| code | True | `string` | {"writeOnly": true} |
| state | True | `string` | {"writeOnly": true} |

### Jwks

Jwks. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| keys | True | `array` | {"items": {"type": "object", "required": ["kty", "use", "alg", "kid", "n", "e"], "properties": {"kty": {"type": "string", "enum": ["RSA"]}, "use": {"type": "string", "enum": ["sig"]}, "alg": {"type": "string", "enum": ["RS256"]}, "kid": {"type": "string"}, "n": {"type": "string"}, "e": {"type": "string"}}}} |

### Discovery

Minimum issuer metadata consumed by JWT validators. Optional discovery capabilities may be published only when actually supported by the configured issuer; this contract does not advertise an authorization-code endpoint or certify a full OpenID Provider.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| issuer | True | `string` | {"format": "uri"} |
| jwks_uri | True | `string` | {"format": "uri"} |
| token_endpoint | True | `string` | {"format": "uri"} |
| response_types_supported | False | `array` | {"items": {"type": "string"}} |
| subject_types_supported | False | `array` | {"items": {"type": "string"}} |
| id_token_signing_alg_values_supported | False | `array` | {"items": {"type": "string"}} |
