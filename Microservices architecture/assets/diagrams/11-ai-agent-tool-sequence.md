# AI Agent Tool Sequence

A read-only availability request passes through the agent and MCP tools. Booking requires a separate user confirmation validated by the backend before the canonical business API is called.

## Diagram

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

[Back to architecture overview](../../README.md)
