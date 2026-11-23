# Documentation strategy and versioning

Canonical HTTP contracts use OpenAPI 3.1 YAML, event views use AsyncAPI 3.0 YAML and MCP tool schemas use JSON Schema 2020-12. Structured Markdown is the selected developer-accessible publishing format; no hosted Swagger UI is required to read this package. Generated [reference pages](../reference/README.md) include HTTP request/response examples and model tables. The existing API exports raw OpenAPI at `/openapi/v1.json` in Development; that export is not an interactive UI.

Business routes use `/api/v1`, internal routes `/internal/v1`, and event addresses `.v1`. Specification `info.version` tracks document/interface revision and is independent of URL major versions. User Management remains 1.0.0; new design additions are 0.2.0 proposals. Operational probes and discovery paths are intentionally unversioned.

Breaking changes include new required inputs, removed fields, narrowed accepted values, changed response types, changed authorization requirements or changed event meaning. Introduce a new major route/event version and document side-by-side migration; never silently change a deployed v1 contract. This update changes proposed interfaces and corrects inaccurate metadata for the existing code. It does not assert that a deployed v1 consumer migration occurred.

For future additive fields, consumers should tolerate documented response extensions. Requests may reject unknown fields as User Management does. New enum values can break exhaustive clients: review each introduction for compatibility. Defaults, optionality and nullability must be documented separately. Do not change identity or tenant semantics under a stable field name.

## Maintenance workflow

1. Change the owning contract with source and status (`implemented`, `proposed`, or an explicit gate).
2. Update examples and relevant tutorial/diagram; update [changelog](../CHANGELOG.md).
3. If the endpoint is implemented, compare routes, DTO serialization, security and failures against code. A raw exporter is only one source and can contain metadata defects.
4. Update provider/consumer views together and review matching request, response and event schemas.
5. Update the Markdown reference with the canonical specification; check examples, operation counts and links. Validation tools belong with the implementation/tooling outside this repository.
6. Record review scope and remaining gaps in the [audit](../audit/architecture-alignment.md). Live claims require live evidence.

The [coverage matrix](../audit/requirements-matrix.md) describes documentation structure, standards and known limitations. The written report should explain the same strategy and distinguish designed interfaces from implemented services.
