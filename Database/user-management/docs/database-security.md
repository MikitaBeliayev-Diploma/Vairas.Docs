# User Management — Database access/security

Migration owner `v_user_management_migration` and runtime login `v_user_management_runtime` are distinct, NOSUPERUSER/NOCREATEDB/NOCREATEROLE/NOBYPASSRLS/NOREPLICATION. Passwords are not in Git; provision externally (the isolated test cluster uses loopback trust with synthetic data).

[Bootstrap roles](../security/bootstrap-roles.sql) before creation; [database grants/policies](../security/database-roles.sql) after schema installation. Runtime owns neither schema nor tables, cannot disable/drop triggers, TRUNCATE, create temp shadow tables, change replication mode or create objects. No DELETE is granted; reviewed retention cleanup is a separate owner procedure. No sequence exists in the UUID-based model; sequence grants are Not Applicable.

## Global identity/profile boundary

No SchoolId exists by design. Do not invent school ownership or tenant FKs in a global credential/profile store. This trusted service necessarily resolves global account/profile bindings; database privilege tests do NOT establish end-user authorization. Authentication/UM APIs must validate the exact self/delegated subject, fresh activity and permitted field projections. Credentials are never shared with school users. RLS was not applied blindly because it would break the accepted global identity model; this limitation is explicit.

## Personal data / operations

Classifications are in data-dictionary.md. Use encrypted storage/backups and TLS/mTLS; secret references only; no bearer/API secrets in fixtures/logs. Synthetic demo data is the chosen demonstration masking method; no misleading general-purpose anonymization view was added. Numeric retention, controller/processor roles and erasure exceptions require policy approval. Triggers/append-only rules do not imply permanent retention or legal certification.

RLS/grants supplement the existing application authorization; native database tests cannot validate external session/School APIs. Security overlays are new tested implementation proposals, not retroactive proof of previously deployed services.
