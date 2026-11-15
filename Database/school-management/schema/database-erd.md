# School Management Database Schema

```mermaid
erDiagram
  SCHOOL ||--o{ SCHOOL_INVITATION : "school_id"
  SCHOOL_MEMBERSHIP o|--o{ SCHOOL_INVITATION : "issuer_membership_id+school_id"
  SCHOOL_OPERATION ||--o| SCHOOL_INVITATION : "issued_operation_id+school_id"
  SCHOOL_OPERATION o|--o| SCHOOL_INVITATION : "accepted_operation_id+school_id"
  SCHOOL_OPERATION o|--o| SCHOOL_INVITATION : "revoked_operation_id+school_id"
  SCHOOL_MEMBERSHIP o|--o{ SCHOOL_INVITATION : "result_membership_id+school_id"
  STUDENT_ENROLLMENT o|--o{ SCHOOL_INVITATION : "result_enrollment_id+school_id"
  SCHOOL ||--o{ SCHOOL_OPERATION : "school_id"
  SCHOOL ||--o{ BRANCH : "school_id"
  SCHOOL ||--o{ SCHOOL_MEMBERSHIP : "school_id"
  SCHOOL ||--o{ STUDENT_ENROLLMENT : "school_id"
  SCHOOL ||--o{ TRAINING_GROUP : "school_id"
  BRANCH o|--o{ TRAINING_GROUP : "branch_id+school_id"
  SCHOOL_OPERATION ||--o{ BRANCH : "last_operation_id+school_id"
  SCHOOL_OPERATION ||--o{ SCHOOL_MEMBERSHIP : "last_operation_id+school_id"
  SCHOOL_OPERATION ||--o{ STUDENT_ENROLLMENT : "last_operation_id+school_id"
  SCHOOL_OPERATION ||--o{ TRAINING_GROUP : "last_operation_id+school_id"
  SCHOOL_MEMBERSHIP ||--o{ MEMBERSHIP_PERMISSION_GRANT : "membership_id+school_id"
  SCHOOL_OPERATION ||--o{ MEMBERSHIP_PERMISSION_GRANT : "granted_operation_id+school_id"
  SCHOOL_OPERATION o|--o{ MEMBERSHIP_PERMISSION_GRANT : "ended_operation_id+school_id"
  STUDENT_ENROLLMENT ||--o{ ENROLLMENT_STATUS_HISTORY : "enrollment_id+school_id"
  SCHOOL_OPERATION ||--o{ ENROLLMENT_STATUS_HISTORY : "operation_id+school_id"
  STUDENT_ENROLLMENT ||--o{ STUDENT_GROUP_MEMBERSHIP : "enrollment_id+school_id"
  TRAINING_GROUP ||--o{ STUDENT_GROUP_MEMBERSHIP : "group_id+school_id"
  SCHOOL_OPERATION ||--o{ STUDENT_GROUP_MEMBERSHIP : "last_operation_id+school_id"
  TRAINING_GROUP ||--o{ TEACHER_GROUP_ASSIGNMENT : "group_id+school_id"
  SCHOOL_OPERATION ||--o{ TEACHER_GROUP_ASSIGNMENT : "last_operation_id+school_id"
  TRAINING_GROUP ||--o{ GROUP_ROSTER_REVISION : "group_id+school_id"
  SCHOOL_OPERATION ||--o{ GROUP_ROSTER_REVISION : "operation_id+school_id"
  GROUP_ROSTER_REVISION ||--o{ GROUP_ROSTER_MEMBER : "group_id+school_id+membership_revision"
  STUDENT_GROUP_MEMBERSHIP ||--o{ GROUP_ROSTER_MEMBER : "membership_id+school_id+group_id+enrollment_id"
  SCHOOL {
    uuid school_id PK
    varchar_200_ name
    sm_status status
    bigint revision
  }
  SCHOOL_OPERATION {
    uuid operation_id PK
    uuid school_id PK,FK
    varchar_80_ command_name
    varchar_60_ target_kind
    uuid target_id
  }
  BRANCH {
    uuid branch_id PK
    uuid school_id PK,FK
    uuid last_operation_id FK
    varchar_200_ name
    varchar_300_ address_line
    varchar_120_ city
  }
  SCHOOL_MEMBERSHIP {
    uuid membership_id PK
    uuid school_id PK,FK
    uuid last_operation_id FK
    uuid user_id
    sm_role role
    timestamptz started_at
  }
  MEMBERSHIP_PERMISSION_GRANT {
    uuid grant_id PK
    uuid school_id PK,FK
    uuid membership_id FK
    uuid granted_operation_id FK
    uuid ended_operation_id FK
    sm_permission permission
    timestamptz started_at
    timestamptz ended_at
  }
  STUDENT_ENROLLMENT {
    uuid enrollment_id PK
    uuid school_id PK,FK
    uuid last_operation_id FK
    uuid student_id
    varchar_20_ category_code
    timestamptz started_at
  }
  ENROLLMENT_STATUS_HISTORY {
    uuid enrollment_id PK,FK
    uuid school_id PK,FK
    bigint enrollment_revision PK
    uuid operation_id FK
    sm_enrollment_status from_status
    sm_enrollment_status to_status
    timestamptz effective_at
  }
  TRAINING_GROUP {
    uuid group_id PK
    uuid school_id PK,FK
    uuid branch_id FK
    uuid last_operation_id FK
    varchar_200_ name
    varchar_20_ category_code
    timestamptz started_at
  }
  STUDENT_GROUP_MEMBERSHIP {
    uuid membership_id PK
    uuid school_id PK,FK
    uuid enrollment_id FK
    uuid group_id FK
    uuid last_operation_id FK
    timestamptz joined_at
    timestamptz left_at
    uuid association_program_version_id
  }
  TEACHER_GROUP_ASSIGNMENT {
    uuid assignment_id PK
    uuid school_id PK,FK
    uuid group_id FK
    uuid last_operation_id FK
    uuid teacher_id
    timestamptz assigned_at
    timestamptz ended_at
  }
  GROUP_ROSTER_REVISION {
    uuid group_id PK,FK
    uuid school_id PK,FK
    bigint membership_revision PK
    uuid operation_id FK
    timestamptz recorded_at
  }
  GROUP_ROSTER_MEMBER {
    uuid group_id PK,FK
    uuid school_id PK,FK
    bigint membership_revision PK,FK
    uuid membership_id PK,FK
    uuid enrollment_id FK
    uuid student_id
    bigint enrollment_revision
    sm_enrollment_status enrollment_status
  }
  SCHOOL_INVITATION {
    uuid invitation_id PK
    uuid school_id PK,FK
    uuid issuer_membership_id FK
    uuid issued_operation_id FK
    uuid accepted_operation_id FK
    uuid result_membership_id FK
    uuid result_enrollment_id FK
    uuid revoked_operation_id FK
    uuid target_user_id
    sm_role role
    varchar_20_ category_code
  }
```

[DBML source](schema.dbml)
