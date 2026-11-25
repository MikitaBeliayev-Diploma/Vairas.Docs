# Implemented data dictionary — authentication

Observed synthetic PostgreSQL database: `vairas_authentication`. Exported from migrated local runtime on 2026-11-25. Schema-only evidence; no business rows are included.

Migrations in the owning service remain the schema evolution authority. Existing design dictionaries are preserved separately. Cross-service UUID references are not physical foreign keys unless listed below.

| Schema | Table | Column | PostgreSQL type | Nullable | Default | Maximum length |
|---|---|---|---|---|---|---|
| public | __EFMigrationsHistory | MigrationId | varchar | NO |  | 150 |
| public | __EFMigrationsHistory | ProductVersion | varchar | NO |  | 32 |
| public | account_challenge | challenge_id | uuid | NO |  |  |
| public | account_challenge | identity_id | uuid | NO |  |  |
| public | account_challenge | purpose | varchar | NO |  | 20 |
| public | account_challenge | login_email | varchar | NO |  | 254 |
| public | account_challenge | credential_revision | int8 | NO |  |  |
| public | account_challenge | secret_digest | varchar | NO |  | 64 |
| public | account_challenge | created_at | timestamptz | NO | clock_timestamp() |  |
| public | account_challenge | expires_at | timestamptz | NO |  |  |
| public | account_challenge | consumed_at | timestamptz | YES |  |  |
| public | account_challenge | invalidated_at | timestamptz | YES |  |  |
| public | auth_operation | operation_id | uuid | NO |  |  |
| public | auth_operation | identity_id | uuid | NO |  |  |
| public | auth_operation | source_session_id | uuid | NO |  |  |
| public | auth_operation | target_session_id | uuid | NO |  |  |
| public | auth_operation | fingerprint | varchar | NO |  | 64 |
| public | auth_operation | recorded_at | timestamptz | NO |  |  |
| public | auth_operation | outcome_status | int4 | NO |  |  |
| public | auth_session | session_id | uuid | NO |  |  |
| public | auth_session | identity_id | uuid | NO |  |  |
| public | auth_session | auth_method | varchar | NO |  | 16 |
| public | auth_session | created_at | timestamptz | NO | clock_timestamp() |  |
| public | auth_session | expires_at | timestamptz | NO |  |  |
| public | auth_session | revoked_at | timestamptz | YES |  |  |
| public | auth_session | revocation_reason | varchar | YES |  | 40 |
| public | challenge_delivery | delivery_id | uuid | NO |  |  |
| public | challenge_delivery | challenge_id | uuid | NO |  |  |
| public | challenge_delivery | protected_payload | text | YES |  |  |
| public | challenge_delivery | status | varchar | NO |  | 16 |
| public | challenge_delivery | attempts | int4 | NO |  |  |
| public | challenge_delivery | created_at | timestamptz | NO |  |  |
| public | challenge_delivery | expires_at | timestamptz | NO |  |  |
| public | challenge_delivery | next_attempt_at | timestamptz | NO |  |  |
| public | challenge_delivery | lease_id | uuid | YES |  |  |
| public | challenge_delivery | leased_until | timestamptz | YES |  |  |
| public | challenge_delivery | last_error_code | varchar | YES |  | 80 |
| public | external_identity | external_identity_id | uuid | NO |  |  |
| public | external_identity | identity_id | uuid | NO |  |  |
| public | external_identity | issuer | varchar | NO |  | 512 |
| public | external_identity | subject | varchar | NO |  | 255 |
| public | external_identity | linked_at | timestamptz | NO | clock_timestamp() |  |
| public | identity | identity_id | uuid | NO |  |  |
| public | identity | login_email | varchar | YES |  | 254 |
| public | identity | email_verified_at | timestamptz | YES |  |  |
| public | identity | security_state | varchar | NO | 'Enabled'::character varying | 16 |
| public | identity | credential_revision | int8 | NO | 1 |  |
| public | identity | created_at | timestamptz | NO | clock_timestamp() |  |
| public | oidc_request | request_id | uuid | NO |  |  |
| public | oidc_request | purpose | varchar | NO |  | 8 |
| public | oidc_request | issuer | varchar | NO |  | 512 |
| public | oidc_request | state_digest | varchar | NO |  | 64 |
| public | oidc_request | browser_digest | varchar | NO |  | 64 |
| public | oidc_request | nonce_digest | varchar | NO |  | 64 |
| public | oidc_request | pkce_verifier_ciphertext | text | NO |  |  |
| public | oidc_request | redirect_uri | varchar | NO |  | 1024 |
| public | oidc_request | link_identity_id | uuid | YES |  |  |
| public | oidc_request | link_session_id | uuid | YES |  |  |
| public | oidc_request | created_at | timestamptz | NO | clock_timestamp() |  |
| public | oidc_request | expires_at | timestamptz | NO |  |  |
| public | oidc_request | consumed_at | timestamptz | YES |  |  |
| public | password_credential | identity_id | uuid | NO |  |  |
| public | password_credential | password_hash | text | NO |  |  |
| public | password_credential | changed_at | timestamptz | NO | clock_timestamp() |  |
| public | refresh_token | refresh_token_id | uuid | NO |  |  |
| public | refresh_token | session_id | uuid | NO |  |  |
| public | refresh_token | parent_token_id | uuid | YES |  |  |
| public | refresh_token | secret_digest | varchar | NO |  | 64 |
| public | refresh_token | created_at | timestamptz | NO | clock_timestamp() |  |
| public | refresh_token | expires_at | timestamptz | NO |  |  |
| public | refresh_token | consumed_at | timestamptz | YES |  |  |
| public | refresh_token | revoked_at | timestamptz | YES |  |  |
| public | security_event | event_id | uuid | NO |  |  |
| public | security_event | identity_id | uuid | YES |  |  |
| public | security_event | session_id | uuid | YES |  |  |
| public | security_event | event_type | varchar | NO |  | 48 |
| public | security_event | outcome_code | varchar | NO |  | 48 |
| public | security_event | correlation_id | uuid | NO |  |  |
| public | security_event | occurred_at | timestamptz | NO | clock_timestamp() |  |

## Physical constraints

| Schema / table | Name | Definition |
|---|---|---|
| public.__EFMigrationsHistory | PK___EFMigrationsHistory | PRIMARY KEY ("MigrationId") |
| public.account_challenge | account_challenge_identity_id_fkey | FOREIGN KEY (identity_id) REFERENCES identity(identity_id) DEFERRABLE |
| public.account_challenge | account_challenge_pkey | PRIMARY KEY (challenge_id) |
| public.account_challenge | account_challenge_secret_digest_key | UNIQUE (secret_digest) |
| public.account_challenge | ck_account_challenge_1 | CHECK (((purpose)::text = ANY ((ARRAY['VerifyEmail'::character varying, 'ResetPassword'::character varying])::text[]))) |
| public.account_challenge | ck_account_challenge_2 | CHECK ((credential_revision > 0)) |
| public.account_challenge | ck_account_challenge_3 | CHECK (((secret_digest)::text ~ '^[0-9a-f]{64}$'::text)) |
| public.account_challenge | ck_account_challenge_4 | CHECK ((expires_at > created_at)) |
| public.account_challenge | ck_account_challenge_5 | CHECK (((consumed_at IS NULL) OR (consumed_at >= created_at))) |
| public.account_challenge | ck_account_challenge_6 | CHECK (((invalidated_at IS NULL) OR (invalidated_at >= created_at))) |
| public.auth_operation | auth_operation_fingerprint_check | CHECK (((fingerprint)::text ~ '^[0-9a-f]{64}$'::text)) |
| public.auth_operation | auth_operation_outcome_status_check | CHECK ((outcome_status = ANY (ARRAY[200, 404]))) |
| public.auth_operation | auth_operation_pkey | PRIMARY KEY (operation_id) |
| public.auth_operation | auth_operation_source_session_id_identity_id_fkey | FOREIGN KEY (source_session_id, identity_id) REFERENCES auth_session(session_id, identity_id) |
| public.auth_session | auth_session_identity_id_fkey | FOREIGN KEY (identity_id) REFERENCES identity(identity_id) DEFERRABLE |
| public.auth_session | auth_session_pkey | PRIMARY KEY (session_id) |
| public.auth_session | ck_auth_session_1 | CHECK (((auth_method)::text = ANY ((ARRAY['Password'::character varying, 'Oidc'::character varying])::text[]))) |
| public.auth_session | ck_auth_session_2 | CHECK ((expires_at > created_at)) |
| public.auth_session | ck_auth_session_3 | CHECK (((revoked_at IS NULL) = (revocation_reason IS NULL))) |
| public.auth_session | ck_auth_session_4 | CHECK (((revoked_at IS NULL) OR (revoked_at >= created_at))) |
| public.challenge_delivery | challenge_delivery_attempts_check | CHECK ((attempts >= 0)) |
| public.challenge_delivery | challenge_delivery_challenge_id_fkey | FOREIGN KEY (challenge_id) REFERENCES account_challenge(challenge_id) |
| public.challenge_delivery | challenge_delivery_challenge_id_key | UNIQUE (challenge_id) |
| public.challenge_delivery | challenge_delivery_check | CHECK ((expires_at > created_at)) |
| public.challenge_delivery | challenge_delivery_check1 | CHECK (((lease_id IS NULL) = (leased_until IS NULL))) |
| public.challenge_delivery | challenge_delivery_check2 | CHECK ((((status)::text = 'Sending'::text) = (lease_id IS NOT NULL))) |
| public.challenge_delivery | challenge_delivery_check3 | CHECK ((((status)::text <> ALL ((ARRAY['Pending'::character varying, 'Sending'::character varying])::text[])) OR (protected_payload IS NOT NULL))) |
| public.challenge_delivery | challenge_delivery_pkey | PRIMARY KEY (delivery_id) |
| public.challenge_delivery | challenge_delivery_status_check | CHECK (((status)::text = ANY ((ARRAY['Pending'::character varying, 'Sending'::character varying, 'Sent'::character varying, 'Failed'::character varying, 'Unknown'::character varying, 'Superseded'::character varying, 'Expired'::character varying])::text[]))) |
| public.external_identity | ck_external_identity_1 | CHECK (((length((issuer)::text) > 0) AND (length((subject)::text) > 0))) |
| public.external_identity | external_identity_identity_id_fkey | FOREIGN KEY (identity_id) REFERENCES identity(identity_id) DEFERRABLE |
| public.external_identity | external_identity_pkey | PRIMARY KEY (external_identity_id) |
| public.identity | ck_identity_1 | CHECK (((security_state)::text = ANY ((ARRAY['Enabled'::character varying, 'Disabled'::character varying])::text[]))) |
| public.identity | ck_identity_2 | CHECK ((credential_revision > 0)) |
| public.identity | ck_identity_3 | CHECK (((login_email IS NULL) OR ((length((login_email)::text) > 3) AND ((login_email)::text = lower(btrim((login_email)::text))) AND ((login_email)::text ~ '^[!-~]+@[!-~]+$'::text)))) |
| public.identity | ck_identity_4 | CHECK (((email_verified_at IS NULL) OR ((login_email IS NOT NULL) AND (email_verified_at >= created_at)))) |
| public.identity | identity_login_email_key | UNIQUE (login_email) |
| public.identity | identity_pkey | PRIMARY KEY (identity_id) |
| public.oidc_request | ck_oidc_request_1 | CHECK (((purpose)::text = ANY ((ARRAY['Login'::character varying, 'Link'::character varying])::text[]))) |
| public.oidc_request | ck_oidc_request_2 | CHECK (((((purpose)::text = 'Login'::text) AND (link_identity_id IS NULL) AND (link_session_id IS NULL)) OR (((purpose)::text = 'Link'::text) AND (link_identity_id IS NOT NULL) AND (link_session_id IS NOT NULL)))) |
| public.oidc_request | ck_oidc_request_3 | CHECK ((((state_digest)::text ~ '^[0-9a-f]{64}$'::text) AND ((browser_digest)::text ~ '^[0-9a-f]{64}$'::text) AND ((nonce_digest)::text ~ '^[0-9a-f]{64}$'::text))) |
| public.oidc_request | ck_oidc_request_4 | CHECK (((length((issuer)::text) > 0) AND (length(pkce_verifier_ciphertext) > 0) AND (length((redirect_uri)::text) > 0))) |
| public.oidc_request | ck_oidc_request_5 | CHECK ((expires_at > created_at)) |
| public.oidc_request | ck_oidc_request_6 | CHECK (((consumed_at IS NULL) OR (consumed_at >= created_at))) |
| public.oidc_request | oidc_request_link_session_id_link_identity_id_fkey | FOREIGN KEY (link_session_id, link_identity_id) REFERENCES auth_session(session_id, identity_id) DEFERRABLE |
| public.oidc_request | oidc_request_pkey | PRIMARY KEY (request_id) |
| public.oidc_request | oidc_request_state_digest_key | UNIQUE (state_digest) |
| public.password_credential | ck_password_credential_1 | CHECK (((length(password_hash) > 30) AND (password_hash ~~ '$argon2id$%'::text))) |
| public.password_credential | password_credential_identity_id_fkey | FOREIGN KEY (identity_id) REFERENCES identity(identity_id) DEFERRABLE |
| public.password_credential | password_credential_pkey | PRIMARY KEY (identity_id) |
| public.refresh_token | ck_refresh_token_1 | CHECK (((secret_digest)::text ~ '^[0-9a-f]{64}$'::text)) |
| public.refresh_token | ck_refresh_token_2 | CHECK ((expires_at > created_at)) |
| public.refresh_token | ck_refresh_token_3 | CHECK (((parent_token_id IS NULL) OR (parent_token_id <> refresh_token_id))) |
| public.refresh_token | ck_refresh_token_4 | CHECK (((consumed_at IS NULL) OR (consumed_at >= created_at))) |
| public.refresh_token | ck_refresh_token_5 | CHECK (((revoked_at IS NULL) OR (revoked_at >= created_at))) |
| public.refresh_token | refresh_token_parent_token_id_session_id_fkey | FOREIGN KEY (parent_token_id, session_id) REFERENCES refresh_token(refresh_token_id, session_id) DEFERRABLE |
| public.refresh_token | refresh_token_pkey | PRIMARY KEY (refresh_token_id) |
| public.refresh_token | refresh_token_secret_digest_key | UNIQUE (secret_digest) |
| public.refresh_token | refresh_token_session_id_fkey | FOREIGN KEY (session_id) REFERENCES auth_session(session_id) DEFERRABLE |
| public.security_event | ck_security_event_1 | CHECK (((session_id IS NULL) OR (identity_id IS NOT NULL))) |
| public.security_event | ck_security_event_2 | CHECK (((length((event_type)::text) > 0) AND (length((outcome_code)::text) > 0))) |
| public.security_event | security_event_identity_id_fkey | FOREIGN KEY (identity_id) REFERENCES identity(identity_id) DEFERRABLE |
| public.security_event | security_event_pkey | PRIMARY KEY (event_id) |
| public.security_event | security_event_session_id_identity_id_fkey | FOREIGN KEY (session_id, identity_id) REFERENCES auth_session(session_id, identity_id) DEFERRABLE |

## Indexes

| Schema / table | Index | Definition |
|---|---|---|
| public.__EFMigrationsHistory | PK___EFMigrationsHistory | CREATE UNIQUE INDEX "PK___EFMigrationsHistory" ON public."__EFMigrationsHistory" USING btree ("MigrationId") |
| public.account_challenge | account_challenge_identity_id_purpose_idx | CREATE INDEX account_challenge_identity_id_purpose_idx ON public.account_challenge USING btree (identity_id, purpose) |
| public.account_challenge | account_challenge_pkey | CREATE UNIQUE INDEX account_challenge_pkey ON public.account_challenge USING btree (challenge_id) |
| public.account_challenge | account_challenge_secret_digest_key | CREATE UNIQUE INDEX account_challenge_secret_digest_key ON public.account_challenge USING btree (secret_digest) |
| public.account_challenge | ux_challenge_live | CREATE UNIQUE INDEX ux_challenge_live ON public.account_challenge USING btree (identity_id, purpose) WHERE ((consumed_at IS NULL) AND (invalidated_at IS NULL)) |
| public.auth_operation | auth_operation_pkey | CREATE UNIQUE INDEX auth_operation_pkey ON public.auth_operation USING btree (operation_id) |
| public.auth_session | auth_session_identity_id_idx | CREATE INDEX auth_session_identity_id_idx ON public.auth_session USING btree (identity_id) |
| public.auth_session | auth_session_pkey | CREATE UNIQUE INDEX auth_session_pkey ON public.auth_session USING btree (session_id) |
| public.auth_session | auth_session_session_id_identity_id_idx | CREATE UNIQUE INDEX auth_session_session_id_identity_id_idx ON public.auth_session USING btree (session_id, identity_id) |
| public.challenge_delivery | challenge_delivery_challenge_id_key | CREATE UNIQUE INDEX challenge_delivery_challenge_id_key ON public.challenge_delivery USING btree (challenge_id) |
| public.challenge_delivery | challenge_delivery_pkey | CREATE UNIQUE INDEX challenge_delivery_pkey ON public.challenge_delivery USING btree (delivery_id) |
| public.challenge_delivery | ix_delivery_pending | CREATE INDEX ix_delivery_pending ON public.challenge_delivery USING btree (next_attempt_at) WHERE ((status)::text = 'Pending'::text) |
| public.external_identity | external_identity_issuer_subject_idx | CREATE UNIQUE INDEX external_identity_issuer_subject_idx ON public.external_identity USING btree (issuer, subject) |
| public.external_identity | external_identity_pkey | CREATE UNIQUE INDEX external_identity_pkey ON public.external_identity USING btree (external_identity_id) |
| public.identity | identity_login_email_key | CREATE UNIQUE INDEX identity_login_email_key ON public.identity USING btree (login_email) |
| public.identity | identity_pkey | CREATE UNIQUE INDEX identity_pkey ON public.identity USING btree (identity_id) |
| public.oidc_request | oidc_request_pkey | CREATE UNIQUE INDEX oidc_request_pkey ON public.oidc_request USING btree (request_id) |
| public.oidc_request | oidc_request_state_digest_key | CREATE UNIQUE INDEX oidc_request_state_digest_key ON public.oidc_request USING btree (state_digest) |
| public.password_credential | password_credential_pkey | CREATE UNIQUE INDEX password_credential_pkey ON public.password_credential USING btree (identity_id) |
| public.refresh_token | refresh_token_parent_token_id_session_id_idx | CREATE UNIQUE INDEX refresh_token_parent_token_id_session_id_idx ON public.refresh_token USING btree (parent_token_id, session_id) |
| public.refresh_token | refresh_token_pkey | CREATE UNIQUE INDEX refresh_token_pkey ON public.refresh_token USING btree (refresh_token_id) |
| public.refresh_token | refresh_token_refresh_token_id_session_id_idx | CREATE UNIQUE INDEX refresh_token_refresh_token_id_session_id_idx ON public.refresh_token USING btree (refresh_token_id, session_id) |
| public.refresh_token | refresh_token_secret_digest_key | CREATE UNIQUE INDEX refresh_token_secret_digest_key ON public.refresh_token USING btree (secret_digest) |
| public.refresh_token | refresh_token_session_id_idx | CREATE INDEX refresh_token_session_id_idx ON public.refresh_token USING btree (session_id) |
| public.refresh_token | ux_refresh_live | CREATE UNIQUE INDEX ux_refresh_live ON public.refresh_token USING btree (session_id) WHERE ((consumed_at IS NULL) AND (revoked_at IS NULL)) |
| public.refresh_token | ux_refresh_root | CREATE UNIQUE INDEX ux_refresh_root ON public.refresh_token USING btree (session_id) WHERE (parent_token_id IS NULL) |
| public.security_event | security_event_identity_id_occurred_at_idx | CREATE INDEX security_event_identity_id_occurred_at_idx ON public.security_event USING btree (identity_id, occurred_at) |
| public.security_event | security_event_pkey | CREATE UNIQUE INDEX security_event_pkey ON public.security_event USING btree (event_id) |

## Row-Level Security

| Schema / table | Enabled | Forced |
|---|---|---|
| public.__EFMigrationsHistory | False | False |
| public.identity | False | False |
| public.external_identity | False | False |
| public.auth_session | False | False |
| public.password_credential | False | False |
| public.refresh_token | False | False |
| public.account_challenge | False | False |
| public.oidc_request | False | False |
| public.security_event | False | False |
| public.auth_operation | False | False |
| public.challenge_delivery | False | False |

Policy expressions and command/role restrictions are retained verbatim in `../schema/implemented-catalogue.json` and `../schema/implemented-schema.sql`. Schema DDL also contains functions and triggers enforcing integrity and audit invariants.
