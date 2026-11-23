# Vairas — School Management API

HTTP API contract. Tenant/resource authorization is mandatory inside the owning service.

[Canonical OpenAPI](../Api/school-management.openapi.yaml) | [Security](../guides/security.md) | [Errors](../guides/errors-and-reliability.md)

## Operations

### GET /internal/v1/enrollments/{enrollmentId}/eligibility

Check enrollment eligibility for this school and actor

Check enrollment eligibility for this school and actor. The owning service enforces actor and school authorization.

Operation ID: `checkEnrollmentEligibility`.

**Authorization:** `[{"workloadBearer": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| enrollmentId | path | True | `11111111-1111-4111-8111-111111111111` |
| schoolId | query | True | `11111111-1111-4111-8111-111111111111` |
| actingUserId | query | True | `11111111-1111-4111-8111-111111111111` |
| X-Correlation-ID | header | False | `synthetic-X-Correlation-ID` |
| teacherId | query | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
GET /internal/v1/enrollments/11111111-1111-4111-8111-111111111111/eligibility?schoolId=11111111-1111-4111-8111-111111111111&actingUserId=11111111-1111-4111-8111-111111111111&teacherId=11111111-1111-4111-8111-111111111111 HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
X-Correlation-ID: synthetic-X-Correlation-ID
```

**Responses**

- **200** — Result

  Media type: `application/json`.

```json
{
  "enrollmentId": "11111111-1111-4111-8111-111111111111",
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "studentId": "11111111-1111-4111-8111-111111111111",
  "active": true,
  "category": "B",
  "version": 1,
  "teacherAllowed": true
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

### GET /internal/v1/groups/{groupId}/participants

Resolve enrolled students to be reserved for a theory lesson

Require a permitted workload and exact school/group scope. Without membershipRevision, return the current complete enrollment/student roster and its membershipVersion. With membershipRevision, return exactly that retained historical revision or fail closed if it cannot be verified; never substitute the current roster. This supports the immutable as-of roster used for theory confirmation and does not prove future reservation eligibility. Filter the retained membership periods for the exact required from/to lesson interval and return only verified full-interval participants. For Learning confirmation, verify the same retained participant basis as the lesson source; reconcile physical-time deviations and any membership mismatch before credit.

Operation ID: `getGroupParticipants`.

**Authorization:** `[{"workloadBearer": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| groupId | path | True | `11111111-1111-4111-8111-111111111111` |
| schoolId | query | True | `11111111-1111-4111-8111-111111111111` |
| X-Correlation-ID | header | False | `synthetic-X-Correlation-ID` |
| membershipRevision | query | False | `1` |
| from | query | True | `2026-12-01T10:00:00Z` |
| to | query | True | `2026-12-01T11:00:00Z` |

**Sample request**

```http
GET /internal/v1/groups/11111111-1111-4111-8111-111111111111/participants?schoolId=11111111-1111-4111-8111-111111111111&membershipRevision=1&from=2026-12-01T10%3A00%3A00Z&to=2026-12-01T11%3A00%3A00Z HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
X-Correlation-ID: synthetic-X-Correlation-ID
```

**Responses**

- **200** — Result

  Media type: `application/json`.

```json
{
  "groupId": "11111111-1111-4111-8111-111111111111",
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "membershipVersion": 3,
  "participants": [
    {
      "enrollmentId": "11111111-1111-4111-8111-111111111111",
      "studentId": "11111111-1111-4111-8111-111111111111"
    }
  ]
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

### POST /api/v1/schools/{schoolId}/enrollments

Create school-scoped enrollment

Create school-scoped enrollment. The owning service enforces actor and school authorization.

Operation ID: `createEnrollment`.

**Authorization:** `[{"bearerAuth": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| X-Correlation-ID | header | False | `synthetic-X-Correlation-ID` |
| schoolId | path | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
POST /api/v1/schools/11111111-1111-4111-8111-111111111111/enrollments HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
X-Correlation-ID: synthetic-X-Correlation-ID
Content-Type: application/json

{
  "studentId": "11111111-1111-4111-8111-111111111111",
  "licenseCategory": "B"
}
```

**Responses**

- **201** — Accepted and committed

  Media type: `application/json`.

```json
{
  "enrollmentId": "11111111-1111-4111-8111-111111111111",
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "studentId": "11111111-1111-4111-8111-111111111111",
  "status": "Active",
  "version": 1
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

**Invalid input example:** Missing required studentId: reject with 400 before business work.

```json
{
  "licenseCategory": "B"
}
```

### GET /api/v1/schools/{schoolId}/memberships

Return memberships authorized for this school

Return memberships authorized for this school. The owning service enforces actor and school authorization.

Operation ID: `getMemberships`.

**Authorization:** `[{"bearerAuth": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| schoolId | path | True | `11111111-1111-4111-8111-111111111111` |
| X-Correlation-ID | header | False | `synthetic-X-Correlation-ID` |

**Sample request**

```http
GET /api/v1/schools/11111111-1111-4111-8111-111111111111/memberships HTTP/1.1
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
    "userId": "11111111-1111-4111-8111-111111111111",
    "role": "Teacher"
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

### GET /api/v1/users/me/enrollments

List only enrollments owned by the authenticated user

List only enrollments owned by the authenticated user. Access is checked by the owning service for the authenticated actor and exact school/enrollment.

Operation ID: `getMyEnrollments`.

**Authorization:** `[{"bearerAuth": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

**Sample request**

```http
GET /api/v1/users/me/enrollments HTTP/1.1
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
    "enrollmentId": "11111111-1111-4111-8111-111111111111",
    "schoolId": "11111111-1111-4111-8111-111111111111",
    "studentId": "11111111-1111-4111-8111-111111111111",
    "status": "Active",
    "version": 1
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

### GET /api/v1/schools/{schoolId}/enrollments/{enrollmentId}

Read the authorized enrollment and school binding

Read the authorized enrollment and school binding. Access is checked by the owning service for the authenticated actor and exact school/enrollment.

Operation ID: `getEnrollment`.

**Authorization:** `[{"bearerAuth": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| schoolId | path | True | `11111111-1111-4111-8111-111111111111` |
| enrollmentId | path | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
GET /api/v1/schools/11111111-1111-4111-8111-111111111111/enrollments/11111111-1111-4111-8111-111111111111 HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
{
  "enrollmentId": "11111111-1111-4111-8111-111111111111",
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "studentId": "11111111-1111-4111-8111-111111111111",
  "status": "Active",
  "version": 1
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

### PUT /api/v1/schools/{schoolId}/enrollments/{enrollmentId}/group-assignment

Assign group and programme after global reservation revalidation

Validate same-school group/programme applicability. Coordinate with Scheduling before making a roster change effective; invalidate affected proposals. If cross-service reservation outcome is unknown keep the change pending, not effective. The durable coordination design remains a deployment gate; this command does not create a cross-database transaction.

Operation ID: `assignEnrollmentGroup`.

**Authorization:** `[{"bearerAuth": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| schoolId | path | True | `11111111-1111-4111-8111-111111111111` |
| enrollmentId | path | True | `11111111-1111-4111-8111-111111111111` |
| Idempotency-Key | header | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
PUT /api/v1/schools/11111111-1111-4111-8111-111111111111/enrollments/11111111-1111-4111-8111-111111111111/group-assignment HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
Idempotency-Key: 11111111-1111-4111-8111-111111111111
Content-Type: application/json

{
  "groupId": "11111111-1111-4111-8111-111111111111",
  "programVersionId": "11111111-1111-4111-8111-111111111111",
  "expectedRevision": 1
}
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
{
  "enrollmentId": "11111111-1111-4111-8111-111111111111",
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "studentId": "11111111-1111-4111-8111-111111111111",
  "status": "Active",
  "version": 2
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

**Invalid input example:** Missing required groupId: reject with 400 before business work.

```json
{
  "programVersionId": "11111111-1111-4111-8111-111111111111",
  "expectedRevision": 1
}
```

### GET /api/v1/schools/{schoolId}/planning-inputs

Report missing school-scoped planning inputs

Report missing school-scoped planning inputs. Access is checked by the owning service for the authenticated actor and exact school/enrollment.

Operation ID: `getPlanningInputs`.

**Authorization:** `[{"bearerAuth": []}]`. Only an empty top-level `security: []` or an empty requirement object `{}` permits anonymous access. Empty arrays after scheme names do not disable authentication. Schemes within one requirement object are required together; separate objects are alternatives. See the security guide for conditional checks and ingress restrictions.

| Parameter | Location | Required | Example |
|---|---|---|---|
| schoolId | path | True | `11111111-1111-4111-8111-111111111111` |

**Sample request**

```http
GET /api/v1/schools/11111111-1111-4111-8111-111111111111/planning-inputs HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
Authorization: Bearer ${TOKEN_WITH_REQUIRED_AUDIENCE_AND_SCOPES}
```

**Responses**

- **200** — Successful result

  Media type: `application/json`.

```json
{
  "schoolId": "11111111-1111-4111-8111-111111111111",
  "complete": false,
  "missingItems": []
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

### EnrollmentEligibility

Enrollment Eligibility. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| enrollmentId | True | `string` | {"format": "uuid"} |
| schoolId | True | `string` | {"format": "uuid"} |
| studentId | True | `string` | {"format": "uuid"} |
| active | True | `boolean` | {} |
| category | True | `string` | {} |
| version | True | `integer` | {"minimum": 1} |
| teacherAllowed | True | `boolean` | {} |

### GroupParticipants

Complete verified enrollment/student pairs at exactly membershipVersion. No duplicate enrollment; school, group and historical membership must be owner-verified.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| groupId | True | `string` | {"format": "uuid"} |
| schoolId | True | `string` | {"format": "uuid"} |
| membershipVersion | True | `integer` | {"minimum": 1} |
| participants | True | `array` | {"items": {"type": "object", "additionalProperties": false, "required": ["enrollmentId", "studentId"], "properties": {"enrollmentId": {"type": "string", "format": "uuid"}, "studentId": {"type": "string", "format": "uuid"}}}} |

### CreateEnrollment

Create Enrollment. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| studentId | True | `string` | {"format": "uuid"} |
| licenseCategory | True | `string` | {} |

### Enrollment

Enrollment. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| enrollmentId | True | `string` | {"format": "uuid"} |
| schoolId | True | `string` | {"format": "uuid"} |
| studentId | True | `string` | {"format": "uuid"} |
| status | True | `string` | {"enum": ["Active", "Completed", "Withdrawn", "Transferred", "Cancelled"]} |
| version | True | `integer` | {"minimum": 1, "description": "Current enrollment revision; use as expectedRevision for an enrollment change."} |

### MembershipList

Membership List. See the operation descriptions for authorization and lifecycle constraints.

```json
{
  "type": "array",
  "items": {
    "type": "object",
    "required": [
      "userId",
      "role"
    ],
    "properties": {
      "userId": {
        "type": "string",
        "format": "uuid"
      },
      "role": {
        "type": "string",
        "enum": [
          "Student",
          "Teacher",
          "Administrator"
        ]
      }
    }
  },
  "description": "Membership List. See the operation descriptions for authorization and lifecycle constraints."
}
```

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

### EnrollmentList

Enrollment List. See the operation descriptions for authorization and lifecycle constraints.

```json
{
  "type": "array",
  "items": {
    "$ref": "#/components/schemas/Enrollment"
  },
  "description": "Enrollment List. See the operation descriptions for authorization and lifecycle constraints."
}
```

### GroupAssignment

Group Assignment. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| groupId | True | `string` | {"format": "uuid"} |
| programVersionId | True | `string` | {"format": "uuid"} |
| expectedRevision | True | `integer` | {"minimum": 1, "description": "Current enrollment version, not the group membership snapshot revision. Recheck roster/program applicability and coordination separately."} |

### PlanningInputs

Planning Inputs. See the operation descriptions for authorization and lifecycle constraints.

| Field | Required | Type / reference | Constraints / meaning |
|---|---|---|---|
| schoolId | True | `string` | {"format": "uuid"} |
| complete | True | `boolean` | {} |
| missingItems | True | `array` | {"items": {"type": "string"}} |
