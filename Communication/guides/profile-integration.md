# Tutorial: integrate User Management

This tutorial targets implemented routes. Preconditions: [Getting Started](getting-started.md), an empty profile for your externally authenticated identity, a reachable Auth session provider and a valid user JWT. Use synthetic personal data. Tokens come from the actual configured issuer; no built-in test login endpoint is exposed by User Management.

## 1. Create the authenticated user's profile

```powershell
$base = 'http://localhost:5151'
$operationId = [guid]::NewGuid().ToString()
$headers = @{
  Authorization = "Bearer $env:VAIRAS_USER_TOKEN"
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

## 2. Fetch the actual resource

```powershell
$profile = Invoke-RestMethod "$base/api/v1/users/me" -Headers $headers
$profile.revision
```

Expect 200 with `status: "Active"`, the global `userId`, nullable contact/role fields and a revision. Keep `IdentityId`, `UserId` and role identifiers separate.

## 3. Update using the current revision

```powershell
$headers['Idempotency-Key'] = [guid]::NewGuid().ToString()
$update = @{ firstName='Alex'; lastName='Example Updated'; emailAddress='alex@example.test'; phoneNumber=$null; expectedRevision=$profile.revision } | ConvertTo-Json
Invoke-RestMethod "$base/api/v1/users/me" -Method Put -Headers $headers -ContentType 'application/json' -Body $update
```

Expect 200 with a receipt. A stale revision returns 409 `REVISION_CONFLICT`; fetch the latest profile, review the change and submit a new command identity. Do not silently overwrite concurrent edits. Validation failure is 400. A current-session dependency failure is 503 `DEPENDENCY_UNAVAILABLE`.

## 4. Create a global student profile

```powershell
$headers['Idempotency-Key'] = [guid]::NewGuid().ToString()
Invoke-RestMethod "$base/api/v1/users/me/student-profile" -Method Post -Headers $headers -ContentType 'application/json' -Body '{}'
```

Expect 201 on creation, or 200 `ALREADY_EXISTS` for an existing role. Student creation must not include a school or invitation. This global StudentId does not enroll the learner in any school. Teacher/administrator provisioning additionally requires exact School-owned invitation validation; bootstrap requires platform and School authority.

## 5. Understand the delegated variant

`/internal/v1/delegated/users/me` additionally requires a permitted workload JWT, independently validated `X-User-Authorization: Bearer ...`, the `profiles.mcp.write` scope and exact live human confirmation for mutations. The Chat provider must verify the command fingerprint, identity, operation ID and expiry. A missing confirmation yields 422 `CONFIRMATION_REQUIRED`. Never turn the model's statement of consent into a backend approval.

Read the [security guide](security.md) and the [dependency reference](../reference/user-management-dependencies.md) before building that adapter. Deployment of Chat/Auth/School providers and live integration remains separate work.
