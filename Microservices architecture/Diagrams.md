# Architecture Diagrams

**Status:** Proposed architecture.

The following diagrams describe the Vairas microservices and MCP-based AI assistant.

[Architecture overview](README.md)

## 01. Bounded Context Map

Business responsibilities, ownership boundaries and logical integration between six business contexts and two supporting contexts.

[Detailed document](assets/diagrams/01-bounded-context-map.md)

```mermaid
flowchart TB
    subgraph BUSINESS["Vairas — business bounded contexts"]
        USER["User Management<br/>Profiles, contacts, user status"]
        SCHOOL["School Management<br/>Schools, memberships, enrollments, groups"]
        SCHED["Scheduling<br/>Lessons, proposals, conflicts, reservations"]
        VEH["Vehicle Management<br/>Vehicles, eligibility, maintenance"]
        LEARN["Learning Tracking<br/>Practical records, hours, assessments"]
        DOC["Document Management<br/>Contracts, templates, document output"]
    end
    subgraph SUPPORT["Supporting bounded contexts"]
        AUTH["Authentication<br/>Identity, credentials, sessions"]
        NOTIF["Notifications<br/>Email templates and delivery"]
    end
    AUTH -.->|IdentityId| USER
    SCHOOL -->|Profile IDs| USER
    SCHED -->|Enrollment and group validation| SCHOOL
    SCHED -->|Eligibility REST| VEH
    VEH -->|Saga booking-block REST| SCHED
    SCHED -.->|LessonCompleted event| LEARN
    LEARN -->|Enrollment ID validation| SCHOOL
    DOC -->|Enrollment data| SCHOOL
    DOC -->|Confirmed training facts| LEARN
    SCHED -.->|Lesson events| NOTIF
    LEARN -.->|Assessment events| NOTIF
    VEH -.->|Maintenance events| NOTIF
```

## 02. Container Architecture

Application containers, external entry points, synchronous and asynchronous integration, persistence and observability.

[Detailed document](assets/diagrams/02-container-architecture.md)

```mermaid
flowchart TB
    WEB["Angular Web App<br/>Chat UI"]
    GW["YARP API Gateway / BFF<br/>Routing + authorization + rate limiting"]
    CHAT["Chat Backend<br/>User/session context + write approvals"]
    subgraph FOUNDRY["Microsoft Foundry - Managed AI"]
        AGENT["Foundry Agent Service<br/>Agent runtime + tool orchestration"]
        MODEL["Foundry Model Deployment<br/>LLM inference"]
    end
    MCP["Vairas MCP Server<br/>Curated business tools"]
    subgraph BUSINESSES["Six business microservices"]
        USER["User Management"]
        SCHOOL["School Management"]
        SCHED["Scheduling"]
        VEH["Vehicle Management"]
        LEARN["Learning Tracking"]
        DOC["Document Management"]
    end
    subgraph SUPPORT["Supporting services"]
        AUTH["Authentication"]
        NOTIF["Notifications"]
    end
    ASB{{"Azure Service Bus<br/>Topics + subscriptions"}}
    DB[("Eight service-owned PostgreSQL databases")]
    BLOB[("Azure Blob Storage")]
    OBS["Azure Monitor + Application Insights<br/>OpenTelemetry traces and logs"]
    WEB -->|HTTPS| GW
    GW -->|/chat HTTPS| CHAT
    CHAT -->|Authenticated agent request| AGENT
    AGENT <-->|Model inference| MODEL
    AGENT -->|MCP tools over secure HTTPS| GW
    GW -->|/mcp route + agent authentication| MCP
    MCP -->|Authorized REST; user and school scope enforced| GW
    GW -->|Business REST endpoints| USER & SCHOOL & SCHED & VEH & LEARN & DOC & AUTH & NOTIF
    SCHED -->|REST vehicle eligibility| VEH
    VEH -->|REST maintenance Saga| SCHED
    SCHED -->|REST enrollment permission| SCHOOL
    SCHOOL & USER & SCHED & VEH & LEARN -.->|Domain events| ASB
    ASB -.->|Subscriptions| SCHED & LEARN & DOC & NOTIF
    USER & SCHOOL & SCHED & VEH & LEARN & DOC & AUTH & NOTIF -->|Each service only its own DB| DB
    DOC -->|File objects| BLOB
    GW & CHAT & MCP & AUTH & USER & SCHOOL & SCHED & VEH & LEARN & DOC & NOTIF -.->|Traces, logs, metrics| OBS
    AGENT -.->|Agent telemetry| OBS
```

## 03. Service Communications

Inter-service HTTPS/REST calls and asynchronous domain events delivered through Azure Service Bus. Solid arrows denote synchronous calls; dashed arrows denote event publication or consumption.

[Detailed document](assets/diagrams/03-service-communications.md)

```mermaid
flowchart TB
    CHAT["Chat Backend"]
    AGENT["Microsoft Foundry Agent Service"]
    MCP["Vairas MCP Server<br/>Tool allowlist and auth context"]
    GW["YARP Gateway<br/>/mcp and /api routes"]
    subgraph CORE["Service-to-service HTTPS / REST"]
        SCHOOL["School Management"]
        USER["User Management"]
        SCHED["Scheduling"]
        VEH["Vehicle Management"]
        LEARN["Learning Tracking"]
        DOC["Document Management"]
        NOTIF["Notifications"]
    end
    SB{{"Azure Service Bus<br/>5 topics / 10 subscriptions"}}
    CHAT -->|Agent request| AGENT
    AGENT -->|MCP HTTPS with authenticated tool caller| GW
    GW -->|Internal /mcp routing| MCP
    MCP -->|Business REST via gateway; principal and school scope| GW
    GW -->|Authorized API routing| SCHOOL & USER & SCHED & VEH & LEARN & DOC & NOTIF
    SCHOOL -->|Profile existence| USER
    SCHED -->|Enrollment permission| SCHOOL
    SCHED -->|Vehicle eligibility| VEH
    VEH -->|Maintenance Saga block / release| SCHED
    LEARN -->|Enrollment validation| SCHOOL
    DOC -->|Contract / enrollment| SCHOOL
    DOC -->|Profile fields| USER
    DOC -->|Confirmed training facts| LEARN
    NOTIF -->|Recipient contacts| USER
    SCHOOL & USER & SCHED & VEH & LEARN -.->|Publish domain events| SB
    SB -.->|Filtered subscriptions| SCHED & LEARN & DOC & NOTIF
```

## 04. Azure Deployment

Proposed Azure placement of Foundry, the Chat Backend, gateway, MCP server, business services, storage, messaging and monitoring.

[Detailed document](assets/diagrams/04-azure-deployment.md)

```mermaid
flowchart TB
    B["Browser / Angular"]
    subgraph AZURE["Azure - proposed EU-region architecture"]
        SWA["Azure Static Web Apps<br/>Angular UI"]
        subgraph FOUNDRY["Microsoft Foundry"]
            AGENT["Foundry Agent Service<br/>Managed agent runtime"]
            MODEL["Foundry Models<br/>LLM model deployment"]
        end
        ACR["Azure Container Registry"]
        subgraph ACA["Azure Container Apps Environment"]
            GW["YARP Gateway<br/>HTTPS external ingress; /api and protected /mcp"]
            CHAT["Chat Backend / BFF<br/>Session and approvals"]
            MCP["Vairas MCP Server<br/>Internal-only backend app"]
            AUTH["Authentication"]
            USER["User Management"]
            SCHOOL["School Management"]
            SCHED["Scheduling"]
            VEH["Vehicle Management"]
            LEARN["Learning Tracking"]
            DOC["Document Management"]
            NOTIF["Notifications API + worker"]
        end
        PROBES["Container Apps health probes<br/>/health/live and /health/ready"]
        BUS{{"Azure Service Bus Standard<br/>Topics, subscriptions, DLQ"}}
        DB[("Azure Database for PostgreSQL<br/>Eight isolated DBs + roles")]
        BLOB[("Azure Blob Storage")]
        EMAIL["Azure Communication Services Email"]
        KV["Azure Key Vault"]
        AI["Azure Monitor / Application Insights<br/>App + agent traces and metrics"]
        LAW["Log Analytics<br/>Correlated structured logs"]
    end
    B -->|HTTPS| SWA
    SWA -->|HTTPS| GW
    GW -->|Internal /chat| CHAT
    CHAT -->|Foundry API| AGENT
    AGENT <-->|Inference| MODEL
    AGENT -->|Remote MCP secure HTTPS + agent identity or user OAuth| GW
    GW -->|Protected /mcp| MCP
    MCP -->|Internal REST via gateway| GW
    GW -->|Authorized /api routes| AUTH & USER & SCHOOL & SCHED & VEH & LEARN & DOC & NOTIF
    SCHED <-->|REST Saga| VEH
    SCHOOL & USER & SCHED & VEH & LEARN -.->|AMQP TLS| BUS
    BUS -.->|Consumer subscriptions| SCHED & LEARN & DOC & NOTIF
    AUTH & USER & SCHOOL & SCHED & VEH & LEARN & DOC & NOTIF -->|Owned DB access only| DB
    DOC -->|Files| BLOB
    NOTIF -->|Send email| EMAIL
    ACR -.->|Container images| ACA
    ACA -.->|Managed identity access| KV
    PROBES -.->|Per-app checks| ACA
    ACA -.->|OTel signals| AI
    AGENT -.->|Foundry agent telemetry| AI
    ACA -.->|App/platform logs| LAW
```

## 05. Service Health and Readiness

Liveness and readiness endpoints for all eight services, the API Gateway and the MCP adapter. Azure Container Apps configures probes per application.

[Detailed document](assets/diagrams/05-health-endpoints.md)

```mermaid
flowchart TB
    P["Azure Container Apps<br/>startup / liveness / readiness probes"]
    subgraph EDGE["Edge and interface containers"]
        GW["YARP Gateway / BFF<br/>GET /health/live<br/>GET /health/ready"]
        MCP["MCP Adapter<br/>GET /health/live<br/>GET /health/ready"]
    end
    subgraph BUSINESS["Business service containers"]
        SCHOOL["School Management<br/>GET /health/live<br/>GET /health/ready"]
        USER["User Management<br/>GET /health/live<br/>GET /health/ready"]
        SCHED["Scheduling<br/>GET /health/live<br/>GET /health/ready"]
        VEH["Vehicle Management<br/>GET /health/live<br/>GET /health/ready"]
        LEARN["Learning Tracking<br/>GET /health/live<br/>GET /health/ready"]
        DOC["Document Management<br/>GET /health/live<br/>GET /health/ready"]
    end
    subgraph SUPPORT["Supporting service containers"]
        AUTH["Authentication<br/>GET /health/live<br/>GET /health/ready"]
        NOTIF["Notifications<br/>GET /health/live<br/>GET /health/ready"]
    end
    P --> GW & MCP
    P --> SCHOOL & USER & SCHED & VEH & LEARN & DOC
    P --> AUTH & NOTIF
    DB[("Service-owned PostgreSQL")]
    CONFIG["Local configuration / startup state"]
    SCHED -.->|Readiness: own DB| DB
    VEH -.->|Readiness: own DB| DB
    AUTH -.->|Readiness: own DB| DB
    GW -.->|Readiness: local routing / auth config| CONFIG
    NOTE["Liveness: process responsive (no network dependency).<br/>Readiness: critical local prerequisites; do not turn transient email or broker failure into restarts."]
    NOTE -.-> P
```

## 06. Correlation ID Propagation

A lesson-creation request carries a correlation ID and W3C tracing context through HTTP calls, the transactional Outbox and asynchronous event processing.

[Detailed document](assets/diagrams/06-correlation-id-propagation.md)

```mermaid
sequenceDiagram
    autonumber
    actor Client as Angular / MCP
    participant GW as API Gateway
    participant S as Scheduling
    participant SM as School Management
    participant V as Vehicle Management
    participant DB as Scheduling DB
    participant OUT as Outbox dispatcher
    participant SB as Azure Service Bus
    participant N as Notifications

    Client->>GW: POST CreateLesson (optional traceparent)
    GW->>GW: Validate or generate X-Correlation-ID
    GW->>GW: Start / continue W3C trace context
    GW->>S: HTTPS + X-Correlation-ID + traceparent
    S->>SM: Validate enrollment (same correlation ID + trace context)
    SM-->>S: Allowed
    S->>V: Check vehicle eligibility (same context)
    V-->>S: Eligible
    S->>DB: Atomic reservation + Outbox(eventId, correlationId, trace context)
    DB-->>S: Committed
    S-->>GW: 201 Created
    GW-->>Client: 201 Created + X-Correlation-ID

    Note over OUT,SB: Later, asynchronously (no synchronous dependency)
    OUT->>SB: MessageId=eventId, CorrelationId=correlationId
    Note over OUT,SB: W3C context through SDK Diagnostic-Id / traceparent
    SB->>N: Event delivery + same correlation ID and trace context
    N->>N: Log correlationId + traceId + spanId + eventId
    N-->>SB: Complete after durable processing
    Note over GW,S: HTTP spans use parent-child relationships
    Note over OUT,N: Async processing may link separate traces
```

## 07. Distributed Tracing and Observability

Application, agent, model and MCP telemetry connects with business-service spans, asynchronous message processing and centralized monitoring.

[Detailed document](assets/diagrams/07-distributed-tracing.md)

```mermaid
flowchart TB
    WEB["Angular chat user"]
    GW["YARP Gateway / BFF"]
    CHAT["Chat Backend"]
    AGENT["Foundry Agent Service<br/>Agent spans and tool calls"]
    MODEL["Foundry model deployment<br/>Inference span"]
    MCP["Vairas MCP Server<br/>Tool execution spans"]
    S["Scheduling<br/>REST and DB spans"]
    SCHOOL["School Management<br/>Enrollment auth span"]
    VEH["Vehicle Management<br/>Eligibility span"]
    OUT["Scheduling Outbox dispatcher<br/>Publish span"]
    BUS{{"Azure Service Bus<br/>CorrelationId + trace context"}}
    N["Notifications consumer<br/>Process span"]
    OTEL["OpenTelemetry + W3C trace context<br/>service.name, traceId, spanId, correlationId"]
    AI["Azure Monitor / Application Insights<br/>Distributed trace analysis"]
    LOG["Log Analytics<br/>Structured logs"]
    WEB -->|HTTPS trace context| GW
    GW --> CHAT
    CHAT -->|Agent request context| AGENT
    AGENT -->|Model inference| MODEL
    AGENT -->|MCP HTTPS request| GW
    GW -->|/mcp| MCP
    MCP -->|/api REST| GW
    GW --> S
    S --> SCHOOL
    S --> VEH
    S -.->|Persist outbox metadata| OUT
    OUT -->|MessageId + CorrelationId| BUS
    BUS -->|Consumer context or span links| N
    GW & CHAT & MCP & S & SCHOOL & VEH & OUT & N -.->|OTel export| OTEL
    AGENT -.->|Foundry telemetry integration| AI
    OTEL -->|Traces and metrics| AI
    OTEL -->|Correlated application logs| LOG
    NOTE["Cross-platform trace propagation must be validated.<br/>Correlation ID is not an authorization credential."]
    NOTE -.-> OTEL
```

## 08. Database Ownership

Eight independently owned PostgreSQL databases and service credentials on one proposed PostgreSQL Flexible Server. Services access only their own databases; cross-service identifiers are logical references without cross-database foreign keys.

[Detailed document](assets/diagrams/08-database-ownership.md)

```mermaid
flowchart TB
    subgraph PG["Azure Database for PostgreSQL Flexible Server"]
        UDB[("User DB")]
        SDB[("School DB")]
        BDB[("Scheduling DB")]
        VDB[("Vehicle DB")]
        LDB[("Learning DB")]
        DDB[("Document DB")]
        ADB[("Authentication DB")]
        NDB[("Notifications DB")]
    end
    U["User Management"] -->|user_db_role| UDB
    SM["School Management"] -->|school_db_role| SDB
    S["Scheduling"] -->|scheduling_db_role| BDB
    V["Vehicle Management"] -->|vehicle_db_role| VDB
    L["Learning Tracking"] -->|learning_db_role| LDB
    D["Document Management"] -->|document_db_role| DDB
    A["Authentication"] -->|auth_db_role| ADB
    N["Notifications"] -->|notifications_db_role| NDB
    NOTE["No access to another service DB<br/>Cross-service IDs are logical only"]
    NOTE -.-> PG
```

## 09. Planned Maintenance Saga

Proposed extension: Vehicle Management coordinates a maintenance operation with a Scheduling booking block. This illustrates a distributed consistency pattern; fleet maintenance is not a mandatory deliverable of the approved diploma application.

[Detailed document](assets/diagrams/09-maintenance-saga.md)

```mermaid
sequenceDiagram
    actor Admin
    participant V as Vehicle Management / Saga
    participant VDB as Vehicle DB
    participant S as Scheduling
    participant SDB as Scheduling DB
    participant MQ as Azure Service Bus

    Admin->>V: Request planned maintenance (operationId, vehicleId, interval)
    V->>VDB: Persist Pending operation
    V->>S: BlockVehicleBookings(operationId, vehicleId, interval)
    S->>SDB: BEGIN, lock vehicle guard row
    S->>SDB: Check conflicting bookings and blocks

    alt Existing bookings conflict
        S->>SDB: ROLLBACK
        S-->>V: 409 Bookings require resolution
        V->>VDB: Mark operation Rejected
        V-->>Admin: Reschedule affected lessons first
    else No conflicting bookings
        S->>SDB: Save block + commit
        S-->>V: BlockConfirmed (blockId)
        V->>VDB: Set UnderMaintenance + Completed + Outbox atomically
        V-->>Admin: Maintenance accepted
        VDB-->>MQ: Publish MaintenanceStarted from Outbox
    end

    opt Vehicle update fails after block confirmed
        Note over V,S: Keep protective block, retry with same operationId
        Note over V,S: Only release after verified safe recovery or compensation
    end
```

## 10. AI Agent and MCP Architecture

Microsoft Foundry Agent Service orchestrates model inference and controlled MCP tools. Vairas enforces authenticated user and tenant permissions through its gateway and business APIs.

[Detailed document](assets/diagrams/10-ai-agent-mcp-architecture.md)

```mermaid
flowchart LR
    U["Angular chat user"]
    BFF["YARP Gateway + Chat Backend<br/>User session, chat, approvals"]
    subgraph AZAI["Microsoft Foundry"]
        AG["Foundry Agent Service<br/>Prompt agent or hosted agent"]
        LLM["Foundry Models<br/>LLM deployment"]
    end
    MCP["Vairas MCP Server<br/>Business tool definitions + policy gate"]
    subgraph API["Internal business REST APIs"]
        SM["School Management"]
        SC["Scheduling"]
        VM["Vehicle Management"]
        LT["Learning Tracking"]
        UM["User Management"]
        DM["Document Management"]
    end
    U -->|Chat HTTPS| BFF
    BFF -->|Authenticated agent request| AG
    AG <-->|Inference| LLM
    AG -->|Tool calls via protected /mcp endpoint| BFF
    BFF -->|Route /mcp| MCP
    MCP -->|Authorized business REST through Gateway| BFF
    BFF -->|/api routing| SM & SC & VM & LT & UM & DM
    NOTE["No direct database access by agent.<br/>Enforce user + tenant permissions in backend.<br/>Preview + explicit confirmation for writes."]
    NOTE -.-> MCP
```

## 11. AI Agent Tool Sequence

A read-only availability request passes through the agent and MCP tools. Booking requires a separate user confirmation validated by the backend before the canonical business API is called.

[Detailed document](assets/diagrams/11-ai-agent-tool-sequence.md)

```mermaid
sequenceDiagram
    autonumber
    actor User as Driving-school user
    participant UI as Angular Chat
    participant BFF as Chat Backend / YARP
    participant Agent as Foundry Agent Service
    participant LLM as Foundry Model
    participant MCP as Vairas MCP Server
    participant School as School Management
    participant Sched as Scheduling

    User->>UI: Find an available practical lesson for me
    UI->>BFF: Authenticated chat request
    BFF->>Agent: Request + bounded user context
    Agent->>LLM: Interpret intent, select safe tools
    LLM-->>Agent: Call find_available_lessons
    Agent->>BFF: Protected MCP tool request
    BFF->>MCP: /mcp route, authenticate tool caller
    MCP->>BFF: REST enrollment / school authorization
    BFF->>School: Validate current user's enrollment and school scope
    School-->>BFF: Allowed enrollment data
    BFF-->>MCP: Authorized context
    MCP->>BFF: REST scheduling availability
    BFF->>Sched: Search availability under validated tenant scope
    Sched-->>BFF: Available slots
    BFF-->>MCP: Slots
    MCP-->>BFF: MCP tool result
    BFF-->>Agent: Tool result
    Agent->>LLM: Prepare human-readable options
    LLM-->>Agent: Suggested lesson options
    Agent-->>BFF: Final response
    BFF-->>UI: Available options
    UI-->>User: Show slots

    opt User chooses a slot for booking
        User->>UI: Confirm booking
        UI->>BFF: Confirm exact slot and user authorization
        Note over BFF,Sched: Confirmation validated by backend, never trust LLM assertions
        BFF->>Sched: Create lesson using canonical business API
        Sched-->>BFF: Booking result or 409 Conflict
        BFF-->>UI: Confirmed result or conflict
    end
```
