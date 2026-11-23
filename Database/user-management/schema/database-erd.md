# User Management Database Schema

```mermaid
erDiagram
  USER_PROFILE ||--o| STUDENT_PROFILE : "user_id"
  USER_PROFILE ||--o| TEACHER_PROFILE : "user_id"
  USER_PROFILE ||--o| ADMINISTRATOR_PROFILE : "user_id"
  USER_PROFILE {
    uuid user_id PK
    uuid identity_id
    varchar_100_ first_name
    varchar_100_ last_name
  }
  STUDENT_PROFILE {
    uuid student_id PK
    uuid user_id FK
    timestamptz created_at
  }
  TEACHER_PROFILE {
    uuid teacher_id PK
    uuid user_id FK
    timestamptz created_at
  }
  ADMINISTRATOR_PROFILE {
    uuid administrator_id PK
    uuid user_id FK
    timestamptz created_at
  }
  PROFILE_OPERATION {
    uuid operation_id PK
    uuid actor_user_id
    varchar_120_ actor_service
    uuid requesting_school_id
  }
  OUTBOX_MESSAGE {
    uuid event_id PK
    uuid aggregate_id
    bigint aggregate_version
    varchar_80_ event_type
    jsonb body
    varchar_128_ correlation_id
    varchar_128_ trace_parent
    timestamptz occurred_at
    timestamptz next_attempt_at
    timestamptz published_at
    uuid lease_id
    timestamptz leased_until
    int attempts
    varchar_80_ last_error_code
  }
```

[DBML source](schema.dbml)

`OUTBOX_MESSAGE` is technical delivery metadata. `aggregate_id` identifies the event's UserId logically; the DDL declares no foreign key. Its partial delivery index and CHECK constraints are documented in the DBML and DDL.
