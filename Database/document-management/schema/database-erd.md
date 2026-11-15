# Document Management Database Schema

```mermaid
erDiagram
  DOCUMENT_TEMPLATE ||--o{ TEMPLATE_VERSION : "school_id+template_id"
  TEMPLATE_VERSION o|--o| DOCUMENT_TEMPLATE : "school_id+template_id+active_version_id"
  FILE_OBJECT ||--o{ TEMPLATE_VERSION : "school_id+file_id"
  FILE_OBJECT ||--o{ TRAINING_CONTRACT : "school_id+generated_file_id"
  FILE_OBJECT ||--o{ TRAINING_CONTRACT : "school_id+basis_file_id"
  TEMPLATE_VERSION ||--o{ TRAINING_CONTRACT : "school_id+template_version_id"
  TRAINING_CONTRACT o|--o{ TRAINING_CONTRACT : "school_id+enrollment_id+replaces_contract_id"
  TRAINING_CONTRACT ||--o{ CONTRACT_SIGNED_COPY : "school_id+contract_id"
  FILE_OBJECT ||--o{ CONTRACT_SIGNED_COPY : "school_id+file_id"
  TRAINING_DOCUMENT ||--o{ DOCUMENT_VERSION : "school_id+document_id+enrollment_id"
  TEMPLATE_VERSION ||--o{ DOCUMENT_VERSION : "school_id+template_version_id"
  FILE_OBJECT ||--o{ DOCUMENT_VERSION : "school_id+rendered_file_id"
  FILE_OBJECT ||--o{ DOCUMENT_VERSION : "school_id+basis_file_id"
  TRAINING_CONTRACT o|--o{ STATE_EVENT : "school_id+contract_id"
  DOCUMENT_VERSION o|--o{ STATE_EVENT : "school_id+document_version_id"
  TRAINING_CONTRACT o|--o{ OPERATION_RECEIPT : "school_id+contract_id"
  DOCUMENT_VERSION o|--o{ OPERATION_RECEIPT : "school_id+document_version_id"
  DOCUMENT_VERSION o|--o| TRAINING_DOCUMENT : "school_id+document_id+current_version_id"
  DOCUMENT_TEMPLATE o|--o{ STATE_EVENT : "school_id+template_id"
  TEMPLATE_VERSION o|--o{ STATE_EVENT : "school_id+template_id+template_version_id"
  CONTRACT_SIGNED_COPY o|--o{ STATE_EVENT : "school_id+contract_id+signed_copy_id"
  OPERATION_RECEIPT ||--o{ STATE_EVENT : "school_id+command_id"
  DOCUMENT_TEMPLATE o|--o{ OPERATION_RECEIPT : "school_id+template_id"
  TEMPLATE_VERSION o|--o{ OPERATION_RECEIPT : "school_id+template_id+template_version_id"
  TRAINING_DOCUMENT o|--o{ STATE_EVENT : "school_id+document_id"
  TRAINING_DOCUMENT o|--o{ OPERATION_RECEIPT : "school_id+document_id"
  DOCUMENT_TEMPLATE {
    uuid template_id PK,FK
    uuid school_id FK
    uuid active_version_id FK
    varchar kind
    varchar name
    bigint revision
  }
  TEMPLATE_VERSION {
    uuid template_version_id PK
    uuid school_id FK
    uuid template_id FK
    uuid file_id FK
    integer version_no
    varchar status
    uuid created_by
  }
  FILE_OBJECT {
    uuid file_id PK
    uuid school_id
    varchar storage_key
    varchar purpose
  }
  TRAINING_CONTRACT {
    uuid contract_id PK
    uuid school_id FK
    uuid enrollment_id FK
    uuid template_version_id FK
    uuid generated_file_id FK
    uuid basis_file_id FK
    uuid replaces_contract_id FK
    uuid student_id
    varchar basis_schema_version
    varchar status
  }
  CONTRACT_SIGNED_COPY {
    uuid signed_copy_id PK
    uuid school_id FK
    uuid contract_id FK
    uuid file_id FK
    integer copy_no
    boolean is_current
    timestamptz declared_signed_at
  }
  TRAINING_DOCUMENT {
    uuid document_id PK,FK
    uuid school_id FK
    uuid current_version_id FK
    uuid enrollment_id
    varchar kind
    bigint revision
  }
  DOCUMENT_VERSION {
    uuid document_version_id PK
    uuid school_id FK
    uuid document_id FK
    uuid enrollment_id FK
    uuid template_version_id FK
    uuid rendered_file_id FK
    uuid basis_file_id FK
    integer version_no
    uuid evidence_snapshot_id
    bigint dependency_revision
  }
  STATE_EVENT {
    uuid event_id PK
    uuid school_id FK
    uuid template_id FK
    uuid template_version_id FK
    uuid signed_copy_id FK
    uuid contract_id FK
    uuid document_id FK
    uuid document_version_id FK
    uuid command_id FK
    varchar action
    bigint sequence_no
    varchar from_state
  }
  OPERATION_RECEIPT {
    uuid command_id PK
    uuid school_id FK
    uuid template_id FK
    uuid template_version_id FK
    uuid contract_id FK
    uuid document_id FK
    uuid document_version_id FK
    uuid actor_id
    varchar operation
    varchar_64_ request_digest
  }
  EVIDENCE_CHECKPOINT {
    uuid school_id PK
    uuid enrollment_id PK
    bigint dependency_revision
    uuid last_change_id
    timestamptz observed_at
  }
```

[DBML source](schema.dbml)
