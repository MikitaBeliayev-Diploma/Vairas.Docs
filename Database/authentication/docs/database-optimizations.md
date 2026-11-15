# Authentication — Indexes and database rules

| Feature | Necessary? | Business/technical reason |
| --- | --- | --- |
| Indexes | Yes, existing | PK/UNIQUE candidate-key enforcement and actual scoped/temporal source lookups. No duplicate PK/UNIQUE indexes added. |
| Views | No new view | No approved repeated read/support/report query requires one in this database package. A view would not secure raw table access. |
| Triggers | Context dependent | Retain only existing cross-row, immutable/version/lifecycle guards. New RLS/grants do not duplicate transition logic. |
| Functions/procedures | Existing technical functions only | Trigger helpers / Auth refresh / Document activation where already designed. No solver/progress or ordinary service workflow moved into SQL. |
| Personal data masking | Synthetic demo + restricted access | No real records exported. Service-required raw data cannot be meaningfully masked for runtime. |

## Query/index inventory

- identity: PK(identity_id).
- identity: UNIQUE(login_email).
- password_credential: PK(identity_id).
- external_identity: PK(external_identity_id).
- external_identity: UNIQUE(issuer,subject).
- auth_session: PK(session_id).
- auth_session: UNIQUE(session_id,identity_id).
- auth_session: INDEX(identity_id).
- refresh_token: PK(refresh_token_id).
- refresh_token: UNIQUE(refresh_token_id,session_id).
- refresh_token: UNIQUE(parent_token_id,session_id).
- refresh_token: UNIQUE(secret_digest).
- refresh_token: INDEX(session_id).
- account_challenge: PK(challenge_id).
- account_challenge: UNIQUE(secret_digest).
- account_challenge: INDEX(identity_id,purpose).
- oidc_request: PK(request_id).
- oidc_request: UNIQUE(state_digest).
- security_event: PK(event_id).
- security_event: INDEX(identity_id,occurred_at).

## Measurement boundaries

EXPLAIN JSON for a representative local query is stored in native evidence. Tiny fixtures may correctly choose sequential scan. No speedup/throughput claim or speculative extra index is made. Any future index needs a real predicate/cardinality/workload measurement.

Reference data: Not Applicable as a global fixed-table seed for this context. Existing enum/status domains are installed by DDL; school-owned templates/programmes/rules are business configuration, not invented global lookup rows. Demo configurations are explicitly synthetic and must not be promoted to legal/category authority.
