# Authentication, authorization and tenant scope

## Implemented User Management

Public self-service requests use a user bearer JWT. RS256 signature, configured issuer/audience, UUID `sub` and `sid`, expiry and current Auth admission must pass. `sub` identifies an Authentication identity, not a profile. Admission can fail even when a JWT is cryptographically valid. Global profile activity is checked for existing users.

Internal status/contact/binding requests use workload JWTs with a separate audience. Permissions intersect token scopes and the configured client allowlist. A Notifications caller cannot obtain all profile fields: the contact projection contains only UserId and nullable email. Internal paths must remain behind trusted routing.

Delegated requests require both workload and end-user authorization in the same OpenAPI Security Requirement Object: `Authorization` carries the workload token; `X-User-Authorization` carries the independently validated user JWT. Mutations additionally validate exact confirmation. Deactivation and bootstrap require an active configured platform operator; bootstrap also checks School authority. An AdministratorProfile alone grants no school membership or platform privilege.

| Operation family | Workload scope | Additional gate |
|---|---|---|
| User status | `profiles.status.read` | Allowed workload client |
| Contact projection | `profiles.contact.read` | Allowed notification/document client |
| Role binding | `profiles.binding.read` | Allowed workload client |
| Delegated profiles | `profiles.mcp.write` | User JWT; mutation confirmation |
| Global deactivation | `profiles.deactivate` | User JWT; configured platform operator |
| Administrator bootstrap | `profiles.bootstrap` | User JWT; platform operator; School first-admin policy |

User Management's outbound token uses OAuth client credentials and the configured `identity.validate school.profile-provisioning confirmations.validate` scopes. The client caches the token only until a safety margin before expiry. It times out HTTP dependencies after five seconds and treats unavailable/malformed authoritative responses as dependency failures.

## Proposed providers and MCP

Authentication owns credentials, sessions, refresh rotation and challenges. Profile contacts are not credentials. OIDC linking matches exact issuer/subject and requires explicit authenticated linking; matching email never authorizes an automatic merge. Refresh reuse handling must revoke the affected session family. Credential and challenge policies in the new API are proposed, not implemented.

MCP metadata hints are not security controls. Every private tool must bind its agent invocation to a verifiable end user, then enforce the same roles, enrollment context and business rules as Web. Shared agent credentials do not establish a user's permissions. The Foundry/Vairas identity-delegation mechanism is an open integration gate; no speculative token exchange endpoint is presented as operational.

School owns memberships/invitations/enrollments. Learning Tracking owns programme requirements, practical facts and credit; Scheduling owns reservations; Vehicle Management owns operational eligibility. Never join another service's database or treat an identifier supplied by a model as permission.

## Secrets and telemetry

Use environment variables, user-secrets or an external secret store. Examples use `${...}` placeholders and synthetic identities; `.example` and `.test` addresses are documentation-only. Never commit bearer/refresh tokens, passwords, private signing keys, connection credentials, broker secrets or real approval tokens. Public JWKS contains only public signing material. Avoid logging raw JWTs, challenge/OIDC codes, invitation secrets, personal payloads or conversation contents. Correlation IDs are diagnostic identifiers, not authorization tokens.

Apply TLS outside loopback development. Restrict probe and internal ingress in deployment. Repository read access and real deployment security require independent verification.
