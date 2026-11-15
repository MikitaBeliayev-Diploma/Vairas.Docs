# AI Agent and MCP Architecture

Microsoft Foundry Agent Service orchestrates model inference and controlled MCP tools. Vairas enforces authenticated user and tenant permissions through its gateway and business APIs.

## Diagram

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

[Back to architecture overview](../../README.md)
