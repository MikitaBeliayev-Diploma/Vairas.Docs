# Contract review and backend integration

This repository contains documentation, OpenAPI/AsyncAPI contracts, MCP schemas and database artifacts. Start with the [contract index](../README.md), [architecture](<../../Microservices architecture/README.md>) and [implementation coverage](../audit/architecture-alignment.md).

## Review the contracts

Read the [HTTP reference](../reference/README.md) together with its canonical YAML. Review request/response examples, authentication, tenant scope, errors, versioning and provider status. Event views and examples are in [Async Api](<../Async Api/>); MCP tool schemas are in [mcp](../mcp/README.md). No Python or Node installation is required to read these materials.

Executable test suites, validation utilities and dependency caches are maintained outside this documentation repository. Changes to a contract require matching updates to reference pages, examples, producer/consumer views and relevant diagrams. Artifact consistency does not establish live interoperability.

## Existing User Management backend

The separate `Backend/Vairas.UserManagement` checkout contains the implemented service and its build, database installation, configuration and test instructions. Use its README as the operational source. The Documentation repository contains no backend solution.

Use an empty development database with a migration owner and a separate non-superuser runtime identity. Apply either the backend EF migrations or the documented fresh-install SQL path; never run initial SQL over an EF-initialized database. Configure credentials, Authentication issuer/audiences, workload clients and Auth/School/Chat origins outside Git. These dependencies are expected providers, not running services supplied by this guide.

The documented loopback address is `http://localhost:5151`; Development exports OpenAPI at `/openapi/v1.json`. The canonical [User Management contract](../Api/user-management.openapi.yaml) corrects known export metadata defects, so review raw exports before replacing it.

A valid user token needs an Authentication identity UUID in `sub`, an active session UUID in `sid`, current session admission and endpoint-specific authorization. A UserId cannot replace the Authentication identity. Without reachable authoritative providers, protected workflows cannot succeed. A missing profile returns 404; creation is described in the [profile guide](profile-integration.md).

## Proposed services

Scheduling, Learning Tracking, School, Vehicle, Document, Notifications, gateway, Chat/MCP and Foundry integration require their documented implementations and deployment evidence. A schema or a successful local health response does not prove a working multi-service system. Outbox dispatch additionally requires broker configuration.

## Continue

- [Profile integration](profile-integration.md): implemented routes and expected dependencies.
- [Booking integration](booking-integration.md): proposed MCP/REST workflow.
- [Security](security.md), [errors and reliability](errors-and-reliability.md), [versioning](versioning.md).
