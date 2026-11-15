# Vehicle Management — Database access/security

Migration owner `v_vehicle_management_migration` and runtime login `v_vehicle_management_runtime` are distinct, NOSUPERUSER/NOCREATEDB/NOCREATEROLE/NOBYPASSRLS/NOREPLICATION. Passwords are not in Git; provision externally (the isolated test cluster uses loopback trust with synthetic data).

[Bootstrap roles](../security/bootstrap-roles.sql) before creation; [database grants/policies](../security/database-roles.sql) after schema installation. Runtime owns neither schema nor tables, cannot disable/drop triggers, TRUNCATE, create temp shadow tables, change replication mode or create objects. DELETE is granted only on current vehicle_supported_category and vehicle_teacher_assignment collection rows; no root, receipt or history deletion. Last-category/assignment authority and parent CAS remain handler duties. Reviewed retention cleanup is separate. No sequence exists in the UUID-based model; sequence grants are Not Applicable.

## Why row isolation was selected for this context

These tables contain school-owned records and existing database grants alone allow an omitted-filter raw query to read another school. The task explicitly requires testing that failure mode. This context therefore receives a narrowly documented SQL security overlay, without model/ownership changes. Policies cover: `vehicle`, `vehicle_supported_category`, `vehicle_teacher_assignment`, `maintenance`, `vehicle_operation`. A missing school scope denies rows; child tables without school_id derive scope through their existing local FK parent.

Begin a short transaction and `SET LOCAL vairas.school_id = '<owner-authorized SchoolId>'` after fresh authentication/School authorization, before any query. Pooling must rollback/reset scope and never accept this setting from model/client headers. RLS is defense against omitted predicates, not proof against a compromised trusted service that deliberately changes its GUC. API permission/actor/resource checks remain mandatory; end users receive no database credentials.

## Personal data / operations

Classifications are in data-dictionary.md. Use encrypted storage/backups and TLS/mTLS; secret references only; no bearer/API secrets in fixtures/logs. Synthetic demo data is the chosen demonstration masking method; no misleading general-purpose anonymization view was added. Numeric retention, controller/processor roles and erasure exceptions require policy approval. Triggers/append-only rules do not imply permanent retention or legal certification.

RLS/grants supplement the existing application authorization; native database tests cannot validate external session/School APIs. Security overlays are new tested implementation proposals, not retroactive proof of previously deployed services.
