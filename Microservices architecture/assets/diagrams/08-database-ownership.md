# Database Ownership

Eight independently owned PostgreSQL databases and service credentials on one proposed PostgreSQL Flexible Server. Services access only their own databases; cross-service identifiers are logical references without cross-database foreign keys.

## Diagram

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

[Back to architecture overview](../../README.md)
