# Distributed Tracing and Observability

Application, agent, model and MCP telemetry connects with business-service spans, asynchronous message processing and centralized monitoring.

## Diagram

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

## Design rules

- Instrument **Gateway, MCP adapter, Authentication, every business service, Notifications and outbox / subscriber workers** with OpenTelemetry.
- Trace entry requests, outgoing HTTP calls, the Scheduling booking transaction, Saga steps, message publication and message handling. Record producer and consumer causal relationships even if asynchronous traces are separate.
- Each app sets distinct `service.name`; record `traceId`, `spanId`, `correlationId`, and appropriate `eventId` / `operationId` for investigations.
- Export application traces and metrics to **Azure Monitor / Application Insights**; capture structured app logs and Azure Container Apps platform diagnostics in **Log Analytics**. Broker and Container Apps platform metrics feed Azure Monitor alerts.
- Useful monitors: REST p95 latency/error rate, Saga failures/recovery age, outbox age, Service Bus dead-letter count, consumer lag, and scheduling conflict rejects. Define alert thresholds when operational data exists.
- Gateway routing/authentication/rate limiting and **downstream service-level school authorization** remain separate controls. Monitoring is not an access-control decision point.

[Back to architecture overview](../../README.md)
