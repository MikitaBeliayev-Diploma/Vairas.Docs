# Documentation strategy and versioning

Canonical HTTP contracts use OpenAPI 3.1 YAML, event views use AsyncAPI 3.0 YAML and MCP tool schemas use JSON Schema 2020-12. Structured Markdown is the selected developer-accessible publishing format; no hosted Swagger UI is required to read this package. Generated [reference pages](../reference/README.md) include HTTP request/response examples and model tables. The existing API exports raw OpenAPI at `/openapi/v1.json` in Development; that export is not an interactive UI.

Business routes use `/api/v1`, internal routes `/internal/v1`, and event addresses `.v1`. Specification `info.version` tracks document/interface revision and is independent of URL major versions. User Management documentation is 1.0.1; interface design additions use revision 0.2.0. Operational probes and discovery paths are intentionally unversioned.

Breaking changes include new required inputs, removed fields, narrowed accepted values, changed response types, changed authorization requirements or changed event meaning. Introduce a new major route/event version and document side-by-side migration; never silently change a deployed v1 contract. This update revises interface definitions and corrects inaccurate metadata for the existing code. It does not assert that a deployed v1 consumer migration occurred.

For future additive fields, consumers should tolerate documented response extensions. Requests may reject unknown fields as User Management does. New enum values can break exhaustive clients: review each introduction for compatibility. Defaults, optionality and nullability must be documented separately. Do not change identity or tenant semantics under a stable field name.

## Maintenance workflow

1. Change the owning contract with its source and update [implementation coverage](../README.md#implementation-coverage) when runtime availability changes.
2. Update examples and the relevant tutorial/diagram. Update the API changelog below with dated interface changes, compatibility decisions and migration notes; retain detailed edits in version-control history.
3. If the endpoint is implemented, compare routes, DTO serialization, security and failures against code. A raw exporter is only one source and can contain metadata defects.
4. Update provider/consumer views together and review matching request, response and event schemas. Re-run standards validation for every changed OpenAPI file and update the [validation record](../README.md#standards-validation).
5. Update the Markdown reference with the canonical specification; check examples, operation counts and links. Validation tools belong with the implementation/tooling outside this repository.
6. Keep [implementation coverage](../README.md#implementation-coverage) and the [reliability guide](errors-and-reliability.md) aligned with verified behavior. Live claims require live evidence.

The written report should explain the documentation structure, tools, standards, naming/versioning and formatting conventions, together with known limitations. Distinguish defined interfaces from implemented services.

## API changelog

### 2026-11-23 — User Management documentation 1.0.1

- Corrected response metadata to match the source: removed object responses advertised as `text/plain`, restricted errors to applicable operations, documented unsupported JSON request media types (415), and added the missing deactivation receipt and bootstrap 201/200 receipts with their models and examples.
- Documented concrete authentication, authority, idempotency, revision and confirmation error codes. Internal workload reads report database availability separately from user-session/provider admission.
- Synchronized the OpenAPI exporter and Markdown reference, clarified security requirement arrays, and explained public, internal and delegated routes in the [security guide](security.md#public-and-internal-routes).
- Retained the authentication-to-profile tutorial and recorded standards validation in the [contract index](../README.md#standards-validation).

Compatibility: these are documentation/export corrections to the existing implementation. Routes, request fields, authorization policies, database schemas and business behavior are unchanged. Consumers should use the documented JSON response media types and handle the applicable error codes. No deployed consumer migration is asserted. The contract baseline before this correction is [c9369d3](https://github.com/MikitaBeliayev-Diploma/Vairas.Docs/tree/c9369d34e7a262bf3fe28172b3764c1ed03f4272/Communication/Api).

This section is the API change history; a separate CHANGELOG file is not required. Add an entry here whenever an interface or its documented behavior changes, including the migration steps for any breaking revision.
