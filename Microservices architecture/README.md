# Microservices Architecture

Architecture documentation for **Vairas: SaaS Platform for Driving School Training Process Management with an MCP-Based AI Assistant**.

**Status:** Proposed architecture. These documents describe design decisions and do not establish implementation or deployment completion.

## Diagrams

Each linked Markdown document contains a Mermaid diagram and its explanation.

[View all diagrams in one document](Diagrams.md).

| No. | Document | Purpose |
|---|---|---|
| 01 | [Bounded Context Map](assets/diagrams/01-bounded-context-map.md) | Business responsibilities, ownership boundaries and logical integration between six business contexts and two supporting contexts. |
| 02 | [Container Architecture](assets/diagrams/02-container-architecture.md) | Application containers, external entry points, synchronous and asynchronous integration, persistence and observability. |
| 03 | [Service Communications](assets/diagrams/03-service-communications.md) | Inter-service HTTPS/REST calls and asynchronous domain events delivered through Azure Service Bus. Solid arrows denote synchronous calls; dashed arrows denote event publication or consumption. |
| 04 | [Azure Deployment](assets/diagrams/04-azure-deployment.md) | Proposed Azure placement of Foundry, the Chat Backend, gateway, MCP server, business services, storage, messaging and monitoring. |
| 05 | [Service Health and Readiness](assets/diagrams/05-health-endpoints.md) | Liveness and readiness endpoints for all eight services, the API Gateway and the MCP adapter. Azure Container Apps configures probes per application. |
| 06 | [Correlation ID Propagation](assets/diagrams/06-correlation-id-propagation.md) | A lesson-creation request carries a correlation ID and W3C tracing context through HTTP calls, the transactional Outbox and asynchronous event processing. |
| 07 | [Distributed Tracing and Observability](assets/diagrams/07-distributed-tracing.md) | Application, agent, model and MCP telemetry connects with business-service spans, asynchronous message processing and centralized monitoring. |
| 08 | [Database Ownership](assets/diagrams/08-database-ownership.md) | Eight independently owned PostgreSQL databases and service credentials on one proposed PostgreSQL Flexible Server. Services access only their own databases; cross-service identifiers are logical references without cross-database foreign keys. |
| 09 | [Planned Maintenance Saga](assets/diagrams/09-maintenance-saga.md) | Proposed extension: Vehicle Management coordinates a maintenance operation with a Scheduling booking block. This illustrates a distributed consistency pattern; fleet maintenance is not a mandatory deliverable of the approved diploma application. |
| 10 | [AI Agent and MCP Architecture](assets/diagrams/10-ai-agent-mcp-architecture.md) | Microsoft Foundry Agent Service orchestrates model inference and controlled MCP tools. Vairas enforces authenticated user and tenant permissions through its gateway and business APIs. |
| 11 | [AI Agent Tool Sequence](assets/diagrams/11-ai-agent-tool-sequence.md) | A read-only availability request passes through the agent and MCP tools. Booking requires a separate user confirmation validated by the backend before the canonical business API is called. |

## Service decomposition

Boundaries follow business responsibilities and data ownership. They allow changes and deployment to be managed separately for scheduling, training records and document generation. Authentication and notification delivery are supporting capabilities.

| Service | Responsibility and owned data |
|---|---|
| School Management | Schools, memberships, groups and student enrollments |
| User Management | Profiles, contact information and user status |
| Scheduling | Lessons, schedule proposals, reservations and conflict decisions |
| Vehicle Management | Vehicles and operational eligibility |
| Learning Tracking | Practical training records, hours, learning progress and assessments |
| Document Management | Contracts, templates and generated documents |
| Authentication | Identities, credentials and sessions |
| Notifications | Email templates and delivery state |

`StudentEnrollment` belongs to School Management; learning progress belongs to Learning Tracking. Scheduling owns lesson reservations and conflict checks. Vehicle Management owns vehicle operational state.

## AI assistant and MCP integration

The Angular Chat UI enters through YARP. A Chat Backend/BFF manages sessions, user context and write approvals, then sends authenticated requests to Microsoft Foundry Agent Service. Foundry Models provides hosted LLM inference. The agent runtime orchestrates tool calls; the model does not directly call Vairas APIs.

The Vairas MCP Server exposes controlled business tools and forwards operations through YARP to ordinary REST APIs. It is a supporting integration, not a seventh business bounded context, and holds no duplicate business data. The gateway exposes a protected `/mcp` route while the MCP container remains internal. Private connectivity requires an explicitly supported Foundry network configuration.

### Authorization and confirmation

- Authenticate the agent caller at `/mcp`; bind every private operation to a verifiable end-user identity and actual enrollment/school permissions. A shared agent identity does not establish user permissions.
- User identity delegation remains an unresolved integration condition for Vairas's own authentication system. Foundry OAuth passthrough depends on compatible identity-provider and authentication flows. Enable private tools only with a verified authorization context.
- The backend records explicit user approval bound to the exact arguments for a mutating action. MCP and business APIs validate approval, authorization and business constraints; model-generated statements cannot grant approval.
- Downstream services enforce tenant isolation and scheduling conflict rules. The model cannot authorize an inferred `userId` or `schoolId`, access databases directly or bypass the canonical APIs.
- Keep personal data, credentials and private conversation content out of telemetry unless a specific data-protection decision permits it. Validate cross-platform trace propagation before claiming a continuous end-to-end trace.

### Proposed tool interface

| Tool | Responsibility |
|---|---|
| `get_my_enrollments` | Return only the authenticated user's enrollments |
| `find_available_lessons` | Find availability within authorized school, instructor and vehicle scope |
| `get_student_training_progress` | Return training progress after access checks |
| `preview_lesson_booking` | Preview exact booking arguments and recheck availability |
| `create_lesson_booking` | Submit an approved booking with authorization, idempotency and conflict protection |

The managed Foundry agent is the selected diagram baseline. A runtime hosted in the Chat Backend, using Foundry only for inference, remains an alternative if identity delegation cannot be made compatible. Predictive exam-pass ML is outside this release scope.

## Communication and consistency

- HTTPS/REST handles checks that require an immediate decision, such as enrollment authorization and vehicle eligibility. Synchronous call chains must not exceed three business services.
- Azure Service Bus carries domain events using Pub/Sub, filtered subscriptions and dead-letter queues. The proposed topology contains five topics and ten subscriptions.
- Each service owns its database and credentials. Other services obtain data through contracts or events, without direct database access or cross-service foreign keys.
- Business changes and outgoing events are persisted atomically through an Outbox. Consumers use an idempotent Inbox to handle at-least-once delivery.
- The optional planned-maintenance Saga is coordinated by Vehicle Management. Scheduling serializes booking changes and maintenance blocks in its own database. No distributed two-phase commit is used.

## Operational design

Every service, the gateway and the MCP adapter expose `/health/live` and `/health/ready`. Liveness checks process responsiveness; readiness checks critical local prerequisites. The [health document](assets/diagrams/05-health-endpoints.md) defines the intended endpoint behavior.

The [correlation document](assets/diagrams/06-correlation-id-propagation.md) defines propagation across HTTP, Outbox and Service Bus boundaries. The [tracing document](assets/diagrams/07-distributed-tracing.md) describes OpenTelemetry spans, Application Insights, centralized logs and operational metrics.

## API contracts

OpenAPI and AsyncAPI contracts are separate required submission artifacts. They are not included in this diagram package; the communication diagrams do not replace those contracts.

## Infrastructure references

- [Azure Container Apps health probes](https://learn.microsoft.com/en-us/azure/container-apps/health-probes)
- [Azure Service Bus distributed tracing](https://learn.microsoft.com/en-us/azure/service-bus-messaging/service-bus-end-to-end-tracing)
- [OpenTelemetry in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/app/opentelemetry-enable)
- [Foundry Agent Service](https://learn.microsoft.com/en-us/azure/foundry/agents/overview)
- [Remote MCP server](https://learn.microsoft.com/en-us/azure/foundry/mcp/build-your-own-mcp-server)
- [MCP server authentication](https://learn.microsoft.com/en-us/azure/foundry/agents/how-to/mcp-authentication)
