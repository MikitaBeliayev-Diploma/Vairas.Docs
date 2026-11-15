# API Contracts

This directory contains the supplied Vairas REST and integration-event contracts, supporting documentation and message examples.

## OpenAPI 3.1

- [document-management](openapi/document-management.openapi.yaml)
- [learning-tracking](openapi/learning-tracking.openapi.yaml)
- [notifications](openapi/notifications.openapi.yaml)
- [scheduling-internal](openapi/scheduling-internal.openapi.yaml)
- [scheduling](openapi/scheduling.openapi.yaml)
- [school-management](openapi/school-management.openapi.yaml)
- [user-management](openapi/user-management.openapi.yaml)
- [vehicle-management](openapi/vehicle-management.openapi.yaml)

## AsyncAPI 3.0

- [document-management](asyncapi/document-management.asyncapi.yaml)
- [learning-tracking](asyncapi/learning-tracking.asyncapi.yaml)
- [notifications](asyncapi/notifications.asyncapi.yaml)
- [scheduling](asyncapi/scheduling.asyncapi.yaml)
- [school-management](asyncapi/school-management.asyncapi.yaml)
- [user-management](asyncapi/user-management.asyncapi.yaml)
- [vehicle-management](asyncapi/vehicle-management.asyncapi.yaml)

## Supporting documents

- [Integration event catalog](docs/EVENT_CATALOG.md)
- [Vehicle state Saga REST contracts](docs/ADR-007-saga-rest-contracts.md)
- [21 JSON event examples](examples/)
- [MCP tool contract scope](mcp/README.md)

## Contract scope

The supplied specifications describe proposed interfaces; they do not establish that endpoints or integrations are implemented. AsyncAPI channel addresses are logical event addresses. Mapping them to the architecture's physical Azure Service Bus topics and filtered subscriptions remains to be specified.

MCP `tools/list` input/output schemas are not included in this archive. Business OpenAPI/AsyncAPI contracts do not replace those tool definitions.

[Back to architecture overview](../README.md)
