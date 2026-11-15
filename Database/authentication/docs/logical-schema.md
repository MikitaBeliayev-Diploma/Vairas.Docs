# Authentication — Logical relational schema

Authority: Current tactical proposal; no deployed handlers inferred. [Canonical DBML](../schema/schema.dbml).

The [Mermaid diagram](../schema/database-erd.md) shows keys/FKs and representative attributes; full attributes/defaults/classification are in data-dictionary.md. 

Physical count: 8 domain tables, 59 columns, 9 local FK declarations. EF migration history, where present, is technical metadata, not a new aggregate.

## Relationships and optionality

| Parent key | Child FK | Required? | Cardinality / integrity |
|---|---|---|---|
| identity(identity_id) | password_credential(identity_id) | Yes | 0..1 child per parent; default NO ACTION |
| identity(identity_id) | external_identity(identity_id) | Yes | 0..N children per parent; default NO ACTION |
| identity(identity_id) | auth_session(identity_id) | Yes | 0..N children per parent; default NO ACTION |
| auth_session(session_id) | refresh_token(session_id) | Yes | 0..N children per parent; default NO ACTION |
| refresh_token(refresh_token_id,session_id) | refresh_token(parent_token_id,session_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..1 child per parent; default NO ACTION |
| identity(identity_id) | account_challenge(identity_id) | Yes | 0..N children per parent; default NO ACTION |
| auth_session(session_id,identity_id) | oidc_request(link_session_id,link_identity_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| identity(identity_id) | security_event(identity_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |
| auth_session(session_id,identity_id) | security_event(session_id,identity_id) | Optional under SQL MATCH SIMPLE; nullable composite needs shape CHECK where paired | 0..N children per parent; default NO ACTION |

## Deployment/transaction source

[Install wrapper](../ddl/install.sql) is the only fresh-install entry. It references existing canonical SQL or the generated initial migration, not another service’s same-named schema.sql. [Security overlay](../security/database-roles.sql) follows schema creation; demo seeds run only under explicit test gates.

No previous production migration history was found/assumed. Reapplying raw initial DDL over a populated database is forbidden. Scheduling has a real EF migration/snapshot and no-op migration rerun check; other contexts use a fresh SQL baseline and require a separately reviewed differential upgrade if legacy data exists.

Current remote owner/API gaps do not by themselves invalidate relational design. They remain runtime/integration gates and cannot be proven by FK tests.

## Executable database rules beyond DBML

- account_challenge.account_challenge_identity_id_fkey: `FOREIGN KEY (identity_id) REFERENCES identity(identity_id) DEFERRABLE`.
- account_challenge.account_challenge_pkey: `PRIMARY KEY (challenge_id)`.
- account_challenge.account_challenge_secret_digest_key: `UNIQUE (secret_digest)`.
- account_challenge.ck_account_challenge_1: `CHECK (((purpose)::text = ANY ((ARRAY['VerifyEmail'::character varying, 'ResetPassword'::character varying])::text[])))`.
- account_challenge.ck_account_challenge_2: `CHECK ((credential_revision > 0))`.
- account_challenge.ck_account_challenge_3: `CHECK (((secret_digest)::text ~ '^[0-9a-f]{64}$'::text))`.
- account_challenge.ck_account_challenge_4: `CHECK ((expires_at > created_at))`.
- account_challenge.ck_account_challenge_5: `CHECK (((consumed_at IS NULL) OR (consumed_at >= created_at)))`.
- account_challenge.ck_account_challenge_6: `CHECK (((invalidated_at IS NULL) OR (invalidated_at >= created_at)))`.
- auth_session.auth_session_identity_id_fkey: `FOREIGN KEY (identity_id) REFERENCES identity(identity_id) DEFERRABLE`.
- auth_session.auth_session_pkey: `PRIMARY KEY (session_id)`.
- auth_session.ck_auth_session_1: `CHECK (((auth_method)::text = ANY ((ARRAY['Password'::character varying, 'Oidc'::character varying])::text[])))`.
- auth_session.ck_auth_session_2: `CHECK ((expires_at > created_at))`.
- auth_session.ck_auth_session_3: `CHECK (((revoked_at IS NULL) = (revocation_reason IS NULL)))`.
- auth_session.ck_auth_session_4: `CHECK (((revoked_at IS NULL) OR (revoked_at >= created_at)))`.
- external_identity.ck_external_identity_1: `CHECK (((length((issuer)::text) > 0) AND (length((subject)::text) > 0)))`.
- external_identity.external_identity_identity_id_fkey: `FOREIGN KEY (identity_id) REFERENCES identity(identity_id) DEFERRABLE`.
- external_identity.external_identity_pkey: `PRIMARY KEY (external_identity_id)`.
- identity.ck_identity_1: `CHECK (((security_state)::text = ANY ((ARRAY['Enabled'::character varying, 'Disabled'::character varying])::text[])))`.
- identity.ck_identity_2: `CHECK ((credential_revision > 0))`.
- identity.ck_identity_3: `CHECK (((login_email IS NULL) OR ((length((login_email)::text) > 3) AND ((login_email)::text = lower(btrim((login_email)::text))) AND ((login_email)::text ~ '^[!-~]+@[!-~]+$'::text))))`.
- identity.ck_identity_4: `CHECK (((email_verified_at IS NULL) OR ((login_email IS NOT NULL) AND (email_verified_at >= created_at))))`.
- identity.identity_login_email_key: `UNIQUE (login_email)`.
- identity.identity_pkey: `PRIMARY KEY (identity_id)`.
- oidc_request.ck_oidc_request_1: `CHECK (((purpose)::text = ANY ((ARRAY['Login'::character varying, 'Link'::character varying])::text[])))`.
- oidc_request.ck_oidc_request_2: `CHECK (((((purpose)::text = 'Login'::text) AND (link_identity_id IS NULL) AND (link_session_id IS NULL)) OR (((purpose)::text = 'Link'::text) AND (link_identity_id IS NOT NULL) AND (link_session_id IS NOT NULL))))`.
- oidc_request.ck_oidc_request_3: `CHECK ((((state_digest)::text ~ '^[0-9a-f]{64}$'::text) AND ((browser_digest)::text ~ '^[0-9a-f]{64}$'::text) AND ((nonce_digest)::text ~ '^[0-9a-f]{64}$'::text)))`.
- oidc_request.ck_oidc_request_4: `CHECK (((length((issuer)::text) > 0) AND (length(pkce_verifier_ciphertext) > 0) AND (length((redirect_uri)::text) > 0)))`.
- oidc_request.ck_oidc_request_5: `CHECK ((expires_at > created_at))`.
- oidc_request.ck_oidc_request_6: `CHECK (((consumed_at IS NULL) OR (consumed_at >= created_at)))`.
- oidc_request.oidc_request_link_session_id_link_identity_id_fkey: `FOREIGN KEY (link_session_id, link_identity_id) REFERENCES auth_session(session_id, identity_id) DEFERRABLE`.
- oidc_request.oidc_request_pkey: `PRIMARY KEY (request_id)`.
- oidc_request.oidc_request_state_digest_key: `UNIQUE (state_digest)`.
- password_credential.ck_password_credential_1: `CHECK (((length(password_hash) > 30) AND (password_hash ~~ '$argon2id$%'::text)))`.
- password_credential.password_credential_identity_id_fkey: `FOREIGN KEY (identity_id) REFERENCES identity(identity_id) DEFERRABLE`.
- password_credential.password_credential_pkey: `PRIMARY KEY (identity_id)`.
- refresh_token.ck_refresh_token_1: `CHECK (((secret_digest)::text ~ '^[0-9a-f]{64}$'::text))`.
- refresh_token.ck_refresh_token_2: `CHECK ((expires_at > created_at))`.
- refresh_token.ck_refresh_token_3: `CHECK (((parent_token_id IS NULL) OR (parent_token_id <> refresh_token_id)))`.
- refresh_token.ck_refresh_token_4: `CHECK (((consumed_at IS NULL) OR (consumed_at >= created_at)))`.
- refresh_token.ck_refresh_token_5: `CHECK (((revoked_at IS NULL) OR (revoked_at >= created_at)))`.
- refresh_token.refresh_token_parent_token_id_session_id_fkey: `FOREIGN KEY (parent_token_id, session_id) REFERENCES refresh_token(refresh_token_id, session_id) DEFERRABLE`.
- refresh_token.refresh_token_pkey: `PRIMARY KEY (refresh_token_id)`.
- refresh_token.refresh_token_secret_digest_key: `UNIQUE (secret_digest)`.
- refresh_token.refresh_token_session_id_fkey: `FOREIGN KEY (session_id) REFERENCES auth_session(session_id) DEFERRABLE`.
- security_event.ck_security_event_1: `CHECK (((session_id IS NULL) OR (identity_id IS NOT NULL)))`.
- security_event.ck_security_event_2: `CHECK (((length((event_type)::text) > 0) AND (length((outcome_code)::text) > 0)))`.
- security_event.security_event_identity_id_fkey: `FOREIGN KEY (identity_id) REFERENCES identity(identity_id) DEFERRABLE`.
- security_event.security_event_pkey: `PRIMARY KEY (event_id)`.
- security_event.security_event_session_id_identity_id_fkey: `FOREIGN KEY (session_id, identity_id) REFERENCES auth_session(session_id, identity_id) DEFERRABLE`.
