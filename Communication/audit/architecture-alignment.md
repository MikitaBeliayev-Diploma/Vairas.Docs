# Architecture alignment audit — 2026-11-22

## Evidence and scope

This audit relates the Business Analysis, eight database designs and architecture diagrams to the separate `Backend/Vairas.UserManagement` source checkout. It documents interface ownership, implementation coverage and remaining design gates. Expert requirements and review arrangements are indexed in the [repository overview](../../README.md).

Only User Management is present as an implementation in the supplied Backend. It has 15 controller operations, two operational probes, dependency clients and an Outbox sender. Other business providers, gateway, Chat/MCP and Foundry deployment remain designs. Corrected API metadata describes source behavior; it is not evidence of deployment or a corrected backend exporter.

## Findings and dispositions

| Finding | Evidence | Disposition |
|---|---|---|
| Export had integer response enums despite string serialization | Program.cs, Domain enum declarations | Corrected UserStatus, ProfileKind and OperationOutcome schemas |
| Export contained a temporary test-host port | launchSettings.json versus stored `servers` | Loopback profile set to localhost:5151; other origins documented as placeholders |
| Missing path declarations and malformed flow-map response descriptions | Existing School, Scheduling, Learning, Document and Saga YAML | Corrected path parameters and response descriptions |
| HTTP media examples absent at baseline | Nine original specifications / 40 operations | Added explicit request/response/error and parameter examples; invalid-request fixtures checked where schema-required inputs exist |
| Auth identity lifecycle absent | Authentication schema, User Management JWT and HTTP clients | Added proposed Authentication spec; token/session expectations preserved |
| School/Chat calls lacked canonical provider views | DependencyClients.cs | Added owning provider definitions aligned with the consumer view |
| Initial scheduling and manual changes incompletely covered | BA US-004–010/021/025; Scheduling schema | Added draft, immutable submission, proposal, confirm, move/cancel, theory, assessment, rules and reconciliation interfaces |
| Learning record, readiness and document workflows incomplete | BA US-012–016/022–024; Learning/Document schemas | Added facts, versions, disputes, attendance, readiness, assessments, completion evidence/report and authorized download |
| Notifications status enum omitted Sending/DeliveryUnknown | notification status CHECK in current DBML | Corrected API state model and documented no blind retry after uncertainty |
| MCP schemas missing | Architecture five tools and BA US-018/019 | Added tools/list-shaped schemas; three explicitly proposed extensions cover personal schedule and rescheduling |
| Probes absent from contracts | Program.cs and health diagram | Added plain-text health contract; readiness is local database access, not external provider health |
| Examples/catalog referred to an unavailable generator | Event catalog | Removed unsupported generator provenance; participant views checked directly |

## Owner and interface map

| Owner | Authority | Contract and status |
|---|---|---|
| Authentication | IdentityId, credentials, sessions, token issuance | [OpenAPI](../Api/authentication.openapi.yaml), proposed; required by implemented UM consumer |
| User Management | UserId, global role IDs, contacts, global activity | [OpenAPI](../Api/user-management.openapi.yaml), implemented source; [sender](<../Async Api/user-management.asyncapi.yaml>) implemented adapter |
| School Management | SchoolId, memberships, invitations, EnrollmentId and group roster | [OpenAPI](../Api/school-management.openapi.yaml), proposed; group/program links do not transfer Learning ownership |
| Scheduling | Lessons, request/proposal versions, reservations and conflict decisions | [OpenAPI](../Api/scheduling.openapi.yaml), proposed; [internal Saga](../Api/scheduling-internal.openapi.yaml) remains an optional extension |
| Vehicle Management | Vehicles and operational eligibility | [OpenAPI](../Api/vehicle-management.openapi.yaml), proposed; maintenance is optional |
| Learning Tracking | Programme versions, facts, credit, readiness and assessments | [OpenAPI](../Api/learning-tracking.openapi.yaml), proposed; StudentId is never an EnrollmentId substitute |
| Document Management | Templates, document versions and generation lifecycle | [OpenAPI](../Api/document-management.openapi.yaml), proposed; downloads require tenant/resource checks |
| Notifications | Templates, recipient rendering snapshot and delivery attempts | [OpenAPI](../Api/notifications.openapi.yaml), proposed; contacts come from User Management |
| Chat Backend | User conversation, exact human approval and restricted assistant audit | [OpenAPI](../Api/chat.openapi.yaml), proposed; no duplicated business state |
| MCP adapter / gateway | Controlled routing and verifiable delegated user context | [tool schemas](../mcp/tools.json), proposed; hints are not authorization |

The [generated reference](../reference/README.md) lists every operation, its status, parameters, security, examples and models. Public route additions are proposals. No generic CRUD API was inferred from database table names.

## Deployment and design gates

| Gate | Required resolution before real use |
|---|---|
| G-01 — actual lesson facts | Local design amended on 2026-11-22: Scheduling migration 002 stores physical actuals and OLD-state history; Learning owns teaching minutes and credit. Completion, correction and source contracts are aligned. Design gap resolved; provider, CAS/history/Outbox/reconciliation and live upgrade validation remain unimplemented. Legacy missing actuals stay unverified. See [G-01 lifecycle and migration](../../Database/scheduling/docs/actual-interval.md). |
| G-02 — global reservation/privacy | BA AC-083/090–102 requires trusted global learner identity, non-disclosing conflicts, lawful processing clearance and atomic reservation decisions. Contracts cannot prove cross-service/cross-school locking. Ambiguous outcomes remain ReconciliationPending. |
| G-03 — roster coordination | School group changes must not become effective before reservation revalidation. Durable coordination/recovery across School and Scheduling is unimplemented; no cross-database transaction is assumed. |
| G-04 — notifications maintenance | Legacy MaintenanceScheduled subscribes to Vehicle, but Notifications DB currently accepts only Scheduling/LearningTracking source contexts and excludes this type. Keep it optional/disabled until the owner approves compatible schema and handlers, or removes this optional integration. |
| G-05 — legal rules and journal | Applicable programme/rule verification, legal field checklist, electronic confirmation mechanism, retention and statutory validity require owner/legal review. Missing or unverified law fails closed. No legal certification is claimed. |
| G-06 — private MCP | Foundry identity delegation, workload/user validation, exact expiring approval and downstream parity are not implemented. The profile confirmation contract supports profile commands only. Private tools cannot be enabled on shared agent identity alone. |
| G-07 — new learning events | PracticalRecordConfirmed/Revised remain proposals requiring owner adoption. Their schemas do not certify publishers/subscribers or exactly-once credit. |
| G-08 — operational policies | Numeric rate limits, maximum query horizons/page sizes, issuer configuration and the complete School rule-code catalogue need implementation policy. One synthetic seed code is evidenced; arbitrary rule strings cannot execute. |
| G-09 — provider security/error behavior | Authentication and other providers must implement the documented wire contracts, challenge delivery and error policy. Schema-valid examples are not executable identity-provider configuration. |

## Messaging topology reconciliation

Five producer families produce 21 logical event addresses. Counting distinct producer→consumer service pairs yields the ten intended subscriptions below; several logical event types share one filtered subscription. The physical topology is proposed and no broker resources were inspected.

| Proposed producer topic | Consumer subscription |
|---|---|
| school | scheduling |
| school | learning-tracking |
| user | school-management |
| user | scheduling |
| vehicle | scheduling |
| vehicle | notifications — optional; blocked by G-04 |
| scheduling | notifications |
| scheduling | learning-tracking |
| learning | notifications |
| learning | document-management |

User Management config defaults to the `vairas.user.deactivated.v1` physical topic; `.v1` logical addresses do not imply a physical topic per event. Final topic names, subscription filters, ACLs, DLQ/retention and provisioning must be adopted explicitly. Nine service pairs avoid the optional maintenance-notification mismatch; keeping the diagram's ten requires resolving that gate.

## Verification limits

See the [review scope](validation-results.md) for the distinction between artifact consistency and runtime evidence. Schema and source review do not establish PostgreSQL integration/concurrency behavior, deployed Azure resources, Foundry identity delegation, broker delivery or working multi-service flows. Required runtime evidence is listed in the [acceptance scenarios](acceptance-scenarios.md).
