# Communication contracts

Contracts are organized by communication type:

Start with [Getting Started](guides/getting-started.md), the [HTTP reference](reference/README.md), [profile tutorial](guides/profile-integration.md) and [proposed booking tutorial](guides/booking-integration.md).

The reviewed package contains 12 OpenAPI documents (including a checked consumer view), 7 AsyncAPI documents, 21 JSON event envelopes and 8 proposed MCP tool definitions. See the [alignment audit](audit/architecture-alignment.md), [documentation coverage](audit/requirements-matrix.md), [security](guides/security.md), [reliability](guides/errors-and-reliability.md) and [versioning](guides/versioning.md). Getting Started explains contract review and backend integration prerequisites. This directory contains documentation and contracts; executable validation tools and dependencies are maintained outside the documentation repository.

| Folder | Content |
|---|---|
| [Api](Api/) | Synchronous REST/HTTP contracts in OpenAPI 3.1 |
| [Async Api](<Async Api/>) | Asynchronous event contracts in AsyncAPI 3.0, event catalog and JSON examples |
| [mcp](mcp/) | MCP contract scope and tool-definition status |

## Synchronous API

- [Authentication](Api/authentication.openapi.yaml) — proposed provider lifecycle and required identity/token interfaces
- [Chat Backend](Api/chat.openapi.yaml) — proposed conversations, exact human approvals and restricted audit
- [Operational probes](Api/operations.openapi.yaml) — implemented User Management behavior; other origins proposed
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

## Contract status

User Management has an implementation in `Backend/Vairas.UserManagement`; its public/internal OpenAPI was exported from that implementation. Its dependency contracts describe expected Auth, School and Chat providers and do not claim those providers exist. Its event sender has automated coverage; live broker/subscriber interoperability is a separate check.

Other service specifications retain their proposed-interface status. AsyncAPI channel addresses are logical event addresses.

MCP tool input/output schemas and REST mappings are in [tools.json](mcp/tools.json); their proposed status and identity-delegation gate are explained in the [MCP guide](mcp/README.md). REST and event contracts do not replace MCP tool definitions.

[Architecture overview](<../Microservices architecture/README.md>)
