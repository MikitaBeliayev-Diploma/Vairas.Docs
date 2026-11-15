# Azure Deployment

Proposed Azure placement of Foundry, the Chat Backend, gateway, MCP server, business services, storage, messaging and monitoring.

## Diagram

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

[Back to architecture overview](../../README.md)
