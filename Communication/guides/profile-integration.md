# Tutorial: authenticate and integrate User Management

This tutorial obtains a user JWT, creates a profile, reads it and updates it with concurrency protection. User Management routes are implemented. The login step requires a separately deployed Authentication provider implementing the [Vairas Authentication contract](../Api/authentication.openapi.yaml); that provider is proposed and is not included as a running service in the supplied Backend. The commands document the integration workflow; no successful live login or cross-service execution is claimed.

## Prerequisites

- Follow [Getting Started](getting-started.md) and the backend README to install/configure User Management.
- Provision a synthetic account in the actual Authentication provider. Its identity must not yet have a User Management profile for the create step below.
- Set `VAIRAS_AUTH_BASE_URL` to the deployed HTTPS origin implementing the Vairas login contract. The documentation placeholder `api.vairas.example` is not a running server.
- Configure User Management to trust that provider's issuer, signing keys and user audience, and to reach its session-validation endpoint using the configured workload credential. A JWT signature alone does not satisfy current-session admission.
- Use the known local User Management origin `http://localhost:5151` below, or replace `$base` with its configured HTTPS deployment origin.

If Authentication is not deployed, stop before these calls. User Management does not provide a built-in test login or issue user tokens. When using a different identity provider, obtain a user access token through that provider's supported flow and assign it to `$accessToken` before step 2; the Vairas-specific login URL below is not a generic OAuth endpoint.

## 1. Authenticate and obtain the user access token

Run in an interactive PowerShell session. Enter only a synthetic account belonging to the configured provider. The credential prompt avoids putting its password in command history; the request still holds it briefly in memory and must use HTTPS. Do not print or record the request body, token response or tokens.

```powershell
$authBase = $env:VAIRAS_AUTH_BASE_URL
if ([string]::IsNullOrWhiteSpace($authBase)) {
  throw 'Set VAIRAS_AUTH_BASE_URL to your deployed Authentication origin.'
}
$authUri = [uri]$authBase
if (-not $authUri.IsAbsoluteUri -or $authUri.Scheme -ne 'https') {
  throw 'The Authentication origin must be an absolute HTTPS URL.'
}
$authBase = $authBase.TrimEnd('/')
$tokens = $null
$accessToken = $null
$credential = Get-Credential -UserName 'alex@example.test' -Message 'Synthetic Authentication account'
try {
  $loginBody = @{
    email = $credential.UserName
    password = $credential.GetNetworkCredential().Password
  } | ConvertTo-Json
  $tokens = Invoke-RestMethod "$authBase/api/v1/auth/login" -Method Post `
    -ContentType 'application/json' -Body $loginBody -ErrorAction Stop
} finally {
  $loginBody = $null
  $credential = $null
}
if ($tokens.tokenType -ne 'Bearer' -or [string]::IsNullOrWhiteSpace($tokens.accessToken)) {
  throw 'Authentication did not return the required Bearer access token.'
}
$accessToken = $tokens.accessToken
```

Expected successful response: HTTP 200 with the following shape. Values below are placeholders, not credentials:

```json
{"accessToken":"${ACCESS_TOKEN_FROM_ISSUER}","refreshToken":"${REFRESH_TOKEN_FROM_ISSUER}","tokenType":"Bearer","expiresIn":900,"identityId":"11111111-1111-4111-8111-111111111111","sessionId":"22222222-2222-4222-8222-222222222222"}
```

The user token must contain the configured user audience, an Authentication identity UUID in `sub` and a session UUID in `sid`. User Management verifies the token and current session; the client does not grant itself authority by decoding claims. Do not substitute a UserId or a client-credentials workload token. The `/connect/token` client-credentials operation serves service workloads, not end-user password login.

For invalid credentials, expect a rejected login such as 401; do not call profile endpoints with a missing token. A 503 means the configured authority is unavailable. If the access token expires, follow the provider's documented refresh/login flow, replace `$accessToken` and rebuild the Authorization header. Never reuse a consumed refresh token; the Vairas refresh contract rotates it and detects reuse.

## 2. Create the authenticated user's profile

```powershell
$base = 'http://localhost:5151'
$operationId = [guid]::NewGuid().ToString()
$headers = @{
  Authorization = "Bearer $accessToken"
  'Idempotency-Key' = $operationId
  'X-Correlation-ID' = 'profile-tutorial-01'
}
$body = @{ firstName='Alex'; lastName='Example'; emailAddress='alex@example.test'; phoneNumber=$null } | ConvertTo-Json
$receipt = Invoke-RestMethod "$base/api/v1/users/me" -Method Post -Headers $headers -ContentType 'application/json' -Body $body
```

Expect HTTP 201 and an operation receipt, not the profile itself:

```json
{"operationId":"11111111-1111-4111-8111-111111111111","outcome":"Applied","code":"APPLIED","targetKind":"UserProfile","targetId":"22222222-2222-4222-8222-222222222222","resultingRevision":1,"recordedAt":"2026-12-01T10:00:00Z"}
```

The command uses the token identity. Do not add a client-chosen UserId to the body. Repeat the identical request with the same operation ID after a transport failure. Current admission checks still apply; the completed command is not performed twice. Reusing the ID for a changed body returns 409 `IDEMPOTENCY_KEY_REUSED`.

## 3. Fetch the actual resource

```powershell
$profile = Invoke-RestMethod "$base/api/v1/users/me" -Headers $headers
$profile.revision
```

Expect 200 with `status: "Active"`, the global `userId`, nullable contact/role fields and a revision. Keep `IdentityId`, `UserId` and role identifiers separate.

## 4. Update using the current revision

```powershell
$headers['Idempotency-Key'] = [guid]::NewGuid().ToString()
$update = @{ firstName='Alex'; lastName='Example Updated'; emailAddress='alex@example.test'; phoneNumber=$null; expectedRevision=$profile.revision } | ConvertTo-Json
Invoke-RestMethod "$base/api/v1/users/me" -Method Put -Headers $headers -ContentType 'application/json' -Body $update
```

Expect 200 with a receipt. A stale revision returns 409 `REVISION_CONFLICT`; fetch the latest profile, review the change and submit a new command identity. Do not silently overwrite concurrent edits. Validation failure is 400. A current-session dependency failure is 503 `DEPENDENCY_UNAVAILABLE`.

## 5. Create a global student profile

```powershell
$headers['Idempotency-Key'] = [guid]::NewGuid().ToString()
Invoke-RestMethod "$base/api/v1/users/me/student-profile" -Method Post -Headers $headers -ContentType 'application/json' -Body '{}'
```

Expect 201 on creation, or 200 `ALREADY_EXISTS` for an existing role. Student creation must not include a school or invitation. This global StudentId does not enroll the learner in any school. Teacher/administrator provisioning additionally requires exact School-owned invitation validation; bootstrap requires platform and School authority.

## 6. Understand the delegated variant

`/internal/v1/delegated/users/me` additionally requires a permitted workload JWT, independently validated `X-User-Authorization: Bearer ...`, the `profiles.mcp.write` scope and exact live human confirmation for mutations. The Chat provider must verify the command fingerprint, identity, operation ID and expiry. A missing confirmation yields 422 `CONFIRMATION_REQUIRED`. Never turn the model's statement of consent into a backend approval.

Read the [security guide](security.md) and the [dependency reference](../reference/user-management-dependencies.md) before building that adapter. Deployment of Chat/Auth/School providers and live integration remains separate work.

When finished, discard the tutorial token variables and headers. Clearing variables does not revoke a session; use the provider session-revocation operation when revocation is required.

```powershell
$headers.Clear()
$accessToken = $null
$tokens = $null
```
