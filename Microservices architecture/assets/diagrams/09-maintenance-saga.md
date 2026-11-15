# Planned Maintenance Saga

Proposed extension: Vehicle Management coordinates a maintenance operation with a Scheduling booking block. This illustrates a distributed consistency pattern; fleet maintenance is not a mandatory deliverable of the approved diploma application.

## Diagram

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

[Back to architecture overview](../../README.md)
