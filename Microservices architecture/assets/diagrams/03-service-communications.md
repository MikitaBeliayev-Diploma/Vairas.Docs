# Service Communications

Inter-service HTTPS/REST calls and asynchronous domain events delivered through Azure Service Bus. Solid arrows denote synchronous calls; dashed arrows denote event publication or consumption.

## Diagram

```mermaid
flowchart TB
    CHAT["Chat Backend"]
    AGENT["Microsoft Foundry Agent Service"]
    MCP["Vairas MCP Server<br/>Tool allowlist and auth context"]
    GW["YARP Gateway<br/>/mcp and /api routes"]
    subgraph CORE["Service-to-service HTTPS / REST"]
        SCHOOL["School Management"]
        USER["User Management"]
        AUTH["Authentication"]
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
    GW -->|Authorized API routing| SCHOOL & USER & AUTH & SCHED & VEH & LEARN & DOC & NOTIF
    USER -->|JWKS, workload tokens, current session validation| AUTH
    USER -->|Invitation and bootstrap authority validation| SCHOOL
    USER -->|Exact MCP confirmation validation| CHAT
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

[Back to architecture overview](../../README.md)

The User Management HTTP clients implement the three added dependency contracts. Authentication, School and Chat providers remain separate implementation requirements. JWT signature checks use cached issuer keys; session admission checks are explicit HTTP calls. No remote write occurs inside a profile transaction.
