# Communication contracts

Contracts are organized by communication type:

Start with [Getting Started](guides/getting-started.md), the [HTTP reference](reference/README.md), [profile tutorial](guides/profile-integration.md) and [booking tutorial](guides/booking-integration.md).

The reviewed package contains 12 OpenAPI documents (including a checked consumer view), 7 AsyncAPI documents, 21 JSON event envelopes and 8 MCP tool definitions. See [security](guides/security.md), [reliability](guides/errors-and-reliability.md) and [versioning](guides/versioning.md). Getting Started explains contract review and backend integration prerequisites. This directory contains documentation and contracts; executable validation tools and dependencies are maintained outside the documentation repository.

| Folder | Content |
|---|---|
| [Api](Api/) | Synchronous REST/HTTP contracts in OpenAPI 3.1 |
| [Async Api](<Async Api/>) | Asynchronous event contracts in AsyncAPI 3.0, event catalog and JSON examples |
| [mcp](mcp/) | MCP contract scope and tool-definition status |

## Synchronous API

- [Authentication](Api/authentication.openapi.yaml) — identity lifecycle and token/session interfaces
- [Chat Backend](Api/chat.openapi.yaml) — conversations, exact human approvals and restricted audit
- [Operational probes](Api/operations.openapi.yaml) — health endpoint contract
- [Document Management](Api/document-management.openapi.yaml)
- [Learning Tracking](Api/learning-tracking.openapi.yaml)
- [Notifications](Api/notifications.openapi.yaml)
- [Scheduling internal](Api/scheduling-internal.openapi.yaml)
- [Scheduling](Api/scheduling.openapi.yaml)
- [School Management](Api/school-management.openapi.yaml)
- [User Management](Api/user-management.openapi.yaml)
- [User Management dependencies](Api/user-management-dependencies.openapi.yaml)
- [Vehicle Management](Api/vehicle-management.openapi.yaml)
- [Vehicle state Saga REST contracts](Api/docs/ADR-007-saga-rest-contracts.md)

## Asynchronous API

- [Document Management](<Async Api/document-management.asyncapi.yaml>)
- [Learning Tracking](<Async Api/learning-tracking.asyncapi.yaml>)
- [Notifications](<Async Api/notifications.asyncapi.yaml>)
- [Scheduling](<Async Api/scheduling.asyncapi.yaml>)
- [School Management](<Async Api/school-management.asyncapi.yaml>)
- [User Management](<Async Api/user-management.asyncapi.yaml>)
- [Vehicle Management](<Async Api/vehicle-management.asyncapi.yaml>)
- [Integration event catalog](<Async Api/docs/EVENT_CATALOG.md>)
- [21 JSON event examples](<Async Api/examples/>)

## Standards validation

Validated on **2026-11-23**: all **12 OpenAPI specifications passed with 0 errors and 0 warnings under the selected rules**.

- Tool: Stoplight Spectral programmatic engine (`@stoplight/spectral-core` **1.24.1**) with AJV **8.20.0**.
- Standard: the [OpenAPI 3.1 schema maintained by Stoplight](https://github.com/stoplightio/spectral/blob/develop/packages/rulesets/src/oas/schemas/oas/v3.1/index.json), schema ID `https://spec.openapis.org/oas/3.1/schema/2021-09-28`, with Schema Objects checked against the [OAS base dialect](https://spec.openapis.org/oas/3.1/dialect/2024-11-10.html).
- Checked: document and Schema Object structure, references, unique operation IDs, required path parameters and defined security schemes. The OAS `media-range` format is an annotation; the complete recommended style/OWASP policies were not part of this run.
- Validated inputs: the 12 current files in `Communication/Api`. `user-management.openapi.yaml` is documentation revision **1.0.1**, SHA-256 `af08661fff98be256540dc5c5cc62ad9b230940c75e028cb1019080f05941807` (UTF-8 text normalized to LF, without BOM). The other 11 OpenAPI files match [revision c9369d3](https://github.com/MikitaBeliayev-Diploma/Vairas.Docs/tree/c9369d34e7a262bf3fe28172b3764c1ed03f4272/Communication/Api) after the same normalization. See the [API changelog](guides/versioning.md#api-changelog).
- A valid control passed; invalid controls missing `info.title`, using an invalid Schema Object type or omitting a path parameter were rejected.

Validation tools and dependencies remain outside this repository. Revalidate changed specifications and update this record when their content changes. Specification validation does not establish live service behavior or authorization.

[Profile integration](guides/profile-integration.md) starts with user-token acquisition before the implemented profile calls; a deployed Authentication provider remains a prerequisite.

## Implementation coverage

The specifications define the interfaces. The table below records implementation evidence in the supplied Backend checkout; it is independent of documentation readiness.

| Component | Implementation coverage |
|---|---|
| User Management HTTP API and health probes | Source implementation available: 15 controller routes and two probes. |
| User Management event sender | Outbox and Service Bus adapter available in source; live broker delivery and subscriber interoperability remain unverified. |
| Authentication | Provider implementation not present in the supplied Backend; User Management requires its issuer and current-session interfaces. |
| School Management | Provider implementation not present; User Management has clients for invitation/bootstrap authority checks. |
| Scheduling | Provider implementation not present; completion, actual-time correction, reservations and reconciliation are specified by the contracts. |
| Vehicle Management | Provider and Saga implementation not present. |
| Learning Tracking | Provider implementation not present; facts, confirmations and derived credit are specified by the contracts. |
| Document Management | Provider implementation not present. |
| Notifications | Provider implementation not present; optional maintenance notifications are excluded by the current source/type constraints (G-04). |
| Chat Backend, MCP adapter and gateway | Implementations not present; verifiable user delegation and exact human approval remain prerequisites for private tools. |
| Cross-service event consumers | Implementations not present; deduplication, revision ordering and recovery require runtime evidence. |

User Management's [dependency view](Api/user-management-dependencies.openapi.yaml) describes the interfaces it consumes. MCP input/output schemas and REST mappings are in [tools.json](mcp/tools.json). AsyncAPI channel addresses are logical event addresses; broker provisioning and deployment are separate from these interface definitions.

[Architecture overview](<../Microservices architecture/README.md>)
