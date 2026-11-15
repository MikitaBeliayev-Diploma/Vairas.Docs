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
```

[DBML source](schema.dbml)
