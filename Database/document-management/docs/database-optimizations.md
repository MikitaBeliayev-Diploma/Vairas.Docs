# Document Management — Indexes and database rules

| Feature | Necessary? | Business/technical reason |
| --- | --- | --- |
| Indexes | Yes, existing | PK/UNIQUE candidate-key enforcement and actual scoped/temporal source lookups. No duplicate PK/UNIQUE indexes added. |
| Views | No new view | No approved repeated read/support/report query requires one in this database package. A view would not secure raw table access. |
| Triggers | Context dependent | Retain only existing cross-row, immutable/version/lifecycle guards. New RLS/grants do not duplicate transition logic. |
| Functions/procedures | Existing technical functions only | Trigger helpers / Auth refresh / Document activation where already designed. No solver/progress or ordinary service workflow moved into SQL. |
| Personal data masking | Synthetic demo + restricted access | No real records exported. Service-required raw data cannot be meaningfully masked for runtime. |

## Query/index inventory

- document_template: PK(template_id).
- document_template: UNIQUE(school_id,template_id).
- template_version: PK(template_version_id).
- template_version: UNIQUE(school_id,template_version_id).
- template_version: UNIQUE(school_id,template_id,version_no).
- template_version: UNIQUE(school_id,template_id,template_version_id).
- file_object: PK(file_id).
- file_object: UNIQUE(school_id,file_id).
- file_object: UNIQUE(school_id,storage_key).
- training_contract: PK(contract_id).
- training_contract: UNIQUE(school_id,contract_id).
- training_contract: UNIQUE(school_id,enrollment_id,contract_id).
- contract_signed_copy: PK(signed_copy_id).
- contract_signed_copy: UNIQUE(school_id,signed_copy_id).
- contract_signed_copy: UNIQUE(school_id,contract_id,signed_copy_id).
- contract_signed_copy: UNIQUE(school_id,contract_id,copy_no).
- training_document: PK(document_id).
- training_document: UNIQUE(school_id,document_id).
- training_document: UNIQUE(school_id,enrollment_id,kind).
- training_document: UNIQUE(school_id,document_id,enrollment_id).
- document_version: PK(document_version_id).
- document_version: UNIQUE(school_id,document_version_id).
- document_version: UNIQUE(school_id,document_id,document_version_id).
- document_version: UNIQUE(school_id,document_id,version_no).
- state_event: PK(event_id).
- state_event: UNIQUE(school_id,event_id).
- state_event: UNIQUE(school_id,template_id,sequence_no).
- state_event: UNIQUE(school_id,contract_id,sequence_no).
- state_event: UNIQUE(school_id,document_id,sequence_no).
- state_event: UNIQUE(school_id,document_version_id,sequence_no).
- operation_receipt: PK(command_id).
- operation_receipt: UNIQUE(school_id,command_id).
- evidence_checkpoint: PK(school_id,enrollment_id).

Supplement: `Database/document-management/ddl/postgresql-constraints.sql`.

## Measurement boundaries

EXPLAIN JSON for a representative local query is stored in native evidence. Tiny fixtures may correctly choose sequential scan. No speedup/throughput claim or speculative extra index is made. Any future index needs a real predicate/cardinality/workload measurement.

Reference data: Not Applicable as a global fixed-table seed for this context. Existing enum/status domains are installed by DDL; school-owned templates/programmes/rules are business configuration, not invented global lookup rows. Demo configurations are explicitly synthetic and must not be promoted to legal/category authority.
