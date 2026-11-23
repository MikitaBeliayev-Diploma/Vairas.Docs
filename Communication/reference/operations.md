# Vairas operational probes

Shared health contract: User Management implements these routes; other service/gateway/MCP probes remain deployment requirements. Readiness checks local prerequisites, not remote Auth/School/Chat or broker admission. Probe ingress is restricted by deployment policy.

[Canonical OpenAPI](../Api/operations.openapi.yaml) | [Security](../guides/security.md) | [Errors](../guides/errors-and-reliability.md)

## Operations

### GET /health/live

Process liveness

Anonymous process liveness at the application layer. No user, school or network dependency checks are performed. Deployment may restrict probe ingress. Implemented for User Management; proposed for other containers.

Operation ID: `getLiveness`. Status: **implemented-user-management; proposed-other-services**.

**Authorization:** `[]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

**Sample request**

```http
GET /health/live HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
```

**Responses**

- **200** — Healthy; middleware can also return Degraded with HTTP 200.

  Media type: `text/plain`.

```text
Healthy
```

- **503** — Unhealthy prerequisite

  Media type: `text/plain`.

```text
Unhealthy
```

### GET /health/ready

Local prerequisite readiness

Anonymous local prerequisite readiness at the application layer. User Management checks its owned database tables; this does not establish remote-provider or broker health. No user or school authorization is required. Deployment may restrict probe ingress.

Operation ID: `getReadiness`. Status: **implemented-user-management; proposed-other-services**.

**Authorization:** `[]`. An empty list is anonymous at the application layer. An empty object is the anonymous alternative; any conditional authentication requirement is stated above. Infrastructure ingress restrictions still apply.

**Sample request**

```http
GET /health/ready HTTP/1.1
Host: YOUR_CONFIGURED_SERVICE_ORIGIN
X-Correlation-ID: reference-example-01
```

**Responses**

- **200** — Healthy; middleware can also return Degraded with HTTP 200.

  Media type: `text/plain`.

```text
Healthy
```

- **503** — Unhealthy prerequisite

  Media type: `text/plain`.

```text
Unhealthy
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
