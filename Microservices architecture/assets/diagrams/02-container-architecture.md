# Container Architecture

Application containers, external entry points, synchronous and asynchronous integration, persistence and observability.

## Diagram

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

[Back to architecture overview](../../README.md)
