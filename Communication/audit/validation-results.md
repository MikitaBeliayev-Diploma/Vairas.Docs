# Contract and repository review ? 2026-11-23

## Reviewed package

| Material | Result |
|---|---|
| HTTP contracts | 12 OpenAPI documents, 96 operation views; four duplicate the owning provider operations in the User Management consumer view |
| HTTP reference | 12 service pages and one index rendered from the final canonical contracts |
| Contract examples and boundaries | 1,196 checked parameter, media, event/MCP and negative/boundary values; no mismatches under the checked assertions |
| Local contract references | 1,122 internal references resolve; corresponding producer/consumer event schemas agree |
| Events and MCP | Seven AsyncAPI documents, 21 event types/envelope examples and eight MCP tools; REST mappings resolve |
| Implemented source | All 15 User Management controller routes, three response enums and both probe paths agree with the contracts |
| Database package | All eight DBML designs parse; fresh DDL, role overlays and synthetic seeds execute in embedded PostgreSQL (PGlite); 95 modeled tables / 963 columns match installed columns |
| Runtime role definitions | All eight runtime role definitions exclude SUPERUSER, BYPASSRLS, CREATEDB and CREATEROLE |

The contract review uses YAML parsing, local-reference checks, the JSON Schema assertions used by the supplied examples and targeted semantic checks. It is not an official OpenAPI/AsyncAPI meta-schema validator certification. Review utilities and their dependencies are maintained outside the Documentation repository.

## Corrections included

- Replaced success code APPLIED in 42 error examples with rejection codes appropriate to the HTTP status.
- Separated anonymous health/identity entry points from protected workload, user and school operations. OIDC linking requires the current bound user/session.
- Aligned theory records with the existing group-level database model: complete historical roster, immutable fact versions and explicit assigned-teacher confirmation. Present earns full minutes, Absent zero; students do not confirm theory.
- Required concurrency and correction reason for new practical/theory fact versions, corrected revision examples and exposed enrollment version for subsequent changes.
- Added exact historical group membership and lesson-interval lookup; unavailable or mismatched history cannot be replaced with a current roster.
- Kept practical credit owned by Learning Tracking facts/confirmations; events notify consumers and never authorize credit by themselves.
- Corrected the User Management physical-topic default and Learning Tracking's explicit mock-source seed prerequisite.

## Implementation boundary

Only User Management has implementation source in the supplied Backend. Other provider contracts and the theory operations remain proposed interfaces aligned with the schemas, not running services. User Management still depends on separate Authentication, School and Chat providers.

Embedded PostgreSQL and artifact checks do not prove live database upgrades, runtime credentials, actor authorization, concurrent transactions, broker delivery/recovery, real OAuth/Foundry/MCP flows or a deployed multi-service system. Demonstrate those against the [acceptance requirements](acceptance-scenarios.md); [architecture alignment](architecture-alignment.md) records the remaining gates.
