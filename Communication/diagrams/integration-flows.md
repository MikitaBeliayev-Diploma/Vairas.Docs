# Integration flows and contract boundaries

The diagrams describe contract boundaries and request flows. Runtime availability is recorded in [implementation coverage](../README.md#implementation-coverage).

## Profile command admission

```mermaid
sequenceDiagram
    actor User
    participant UM as User Management
    participant Auth as Authentication provider
    participant School as School provider
    participant Chat as Chat confirmation provider
    participant DB as User Management database
    User->>UM: POST profile with JWT and operation identity
    UM->>Auth: Validate exact identity and current session
    Auth-->>UM: Admission and expiry
    opt Staff role or bootstrap
        UM->>School: Validate exact invitation or bootstrap authority
        School-->>UM: Bound decision and expiry
    end
    opt Delegated mutation
        UM->>Chat: Validate exact recorded human approval
        Chat-->>UM: Matching binding and expiry
    end
    UM->>DB: Local transaction and idempotent operation outcome
    DB-->>UM: Commit
    UM-->>User: Operation receipt or problem
```

## Proposal confirmation and uncertain outcome

```mermaid
sequenceDiagram
    actor Admin
    participant Scheduling
    participant School
    participant Vehicle
    participant DB as Scheduling reservation authority
    Admin->>Scheduling: Submit validated immutable request revision
    Scheduling-->>Admin: Unconfirmed proposal or infeasibility
    Admin->>Scheduling: Confirm exact revision and operation identity
    Scheduling->>School: Current enrollment and roster authorization
    Scheduling->>Vehicle: Current operational eligibility
    Scheduling->>DB: Serialize conflict check and reservation commit
    alt Known committed outcome
        DB-->>Scheduling: Committed
        Scheduling-->>Admin: Committed lesson IDs
    else Outcome uncertain
        Scheduling-->>Admin: ReconciliationPending
        Admin->>Scheduling: Query same operation identity
        Scheduling->>DB: Reconcile authoritative reservation outcome
    end
```

School and Vehicle HTTP checks are provisional; atomic reservation protection belongs to Scheduling. Cross-school global identity/privacy is an explicit implementation gate. There is no distributed database transaction.

## MCP approval and business parity

```mermaid
sequenceDiagram
    actor Human
    participant Chat
    participant Agent as Foundry agent
    participant MCP
    participant API as Canonical business API
    Human->>Chat: Request a lesson change
    Chat->>Agent: Verified user and school context
    Agent->>MCP: Preview exact action
    MCP->>API: Authorized availability checks
    MCP-->>Chat: Expiring server-bound preview
    Chat-->>Human: Show exact arguments
    Human->>Chat: Explicit authenticated approval
    Chat->>Chat: Store exact approval and operation binding
    Agent->>MCP: Execute using preview and confirmation
    MCP->>Chat: Verify approval and identity binding
    MCP->>API: Authorized idempotent command
    API-->>MCP: Committed, rejected or reconciliation pending
    MCP-->>Human: Accurate outcome without inferred success
```

Identity delegation is unresolved. This diagram defines required controls, not an operational Foundry token flow. Profile confirmation validation is an implemented consumer contract with proposed provider; booking approval still needs its own business-compatible implementation.

## Training facts and document generation

```mermaid
flowchart LR
    S[Scheduling lifecycle and authoritative source] -->|Source reconciliation: actual-time gate| L[Learning Tracking]
    I[Assigned instructor] -->|Confirm current fact version| L
    ST[Enrolled student] -->|Confirm or dispute same version| L
    L -->|Derived confirmed credit and deficits| P[Authorized progress views]
    L -->|Versioned confirmed facts and evidence| D[Document Management]
    D --> J[Journal or internal completion report]
    L -.->|Confirmed or revised event| D
    S -.->|Schedule events| N[Notifications]
```

Scheduling completion alone awards no hours. Scheduling actual-time persistence is included in local migration 002; handlers, Outbox and source reconciliation remain implementation requirements. Document generation completion does not certify readiness, electronic-signature validity or external reporting.

## Theory attendance and confirmation

```mermaid
sequenceDiagram
    actor Teacher
    participant LT as Learning Tracking
    participant Scheduling
    participant School
    Teacher->>LT: Record full Present/Absent roster and minutes
    LT->>Scheduling: Verify current lesson source revision and identities
    LT->>School: Verify retained membership revision for the lesson interval
    LT-->>Teacher: Immutable unconfirmed fact version and aggregate revision
    Teacher->>LT: Review and confirm exact factVersion with expectedRevision
    LT->>Scheduling: Recheck current completed-valid source
    LT->>School: Recheck exact complete historical roster
    LT-->>Teacher: Teacher-confirmed current version
    Note over LT: Present earns full minutes, Absent zero; no student confirmation
    opt Source or attendance corrected
        Teacher->>LT: Append new facts with CAS and audit reason
        LT-->>Teacher: New unconfirmed version; old eligibility blocked
    end
```

The record belongs to one group lesson. A caller cannot confirm a partial roster or transfer a previous version's confirmation. Each participant's programme and enrollment remain independently scoped.
