CREATE TABLE "identity" (
  "identity_id" uuid PRIMARY KEY NOT NULL,
  "login_email" varchar(254) UNIQUE,
  "email_verified_at" timestamptz,
  "security_state" varchar(16) NOT NULL DEFAULT 'Enabled',
  "credential_revision" bigint NOT NULL DEFAULT 1,
  "created_at" timestamptz NOT NULL DEFAULT (clock_timestamp())
);

CREATE TABLE "password_credential" (
  "identity_id" uuid PRIMARY KEY NOT NULL,
  "password_hash" text NOT NULL,
  "changed_at" timestamptz NOT NULL DEFAULT (clock_timestamp())
);

CREATE TABLE "external_identity" (
  "external_identity_id" uuid PRIMARY KEY NOT NULL,
  "identity_id" uuid NOT NULL,
  "issuer" varchar(512) NOT NULL,
  "subject" varchar(255) NOT NULL,
  "linked_at" timestamptz NOT NULL DEFAULT (clock_timestamp())
);

CREATE TABLE "auth_session" (
  "session_id" uuid PRIMARY KEY NOT NULL,
  "identity_id" uuid NOT NULL,
  "auth_method" varchar(16) NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT (clock_timestamp()),
  "expires_at" timestamptz NOT NULL,
  "revoked_at" timestamptz,
  "revocation_reason" varchar(40)
);

CREATE TABLE "refresh_token" (
  "refresh_token_id" uuid PRIMARY KEY NOT NULL,
  "session_id" uuid NOT NULL,
  "parent_token_id" uuid,
  "secret_digest" varchar(64) UNIQUE NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT (clock_timestamp()),
  "expires_at" timestamptz NOT NULL,
  "consumed_at" timestamptz,
  "revoked_at" timestamptz
);

CREATE TABLE "account_challenge" (
  "challenge_id" uuid PRIMARY KEY NOT NULL,
  "identity_id" uuid NOT NULL,
  "purpose" varchar(20) NOT NULL,
  "login_email" varchar(254) NOT NULL,
  "credential_revision" bigint NOT NULL,
  "secret_digest" varchar(64) UNIQUE NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT (clock_timestamp()),
  "expires_at" timestamptz NOT NULL,
  "consumed_at" timestamptz,
  "invalidated_at" timestamptz
);

CREATE TABLE "oidc_request" (
  "request_id" uuid PRIMARY KEY NOT NULL,
  "purpose" varchar(8) NOT NULL,
  "issuer" varchar(512) NOT NULL,
  "state_digest" varchar(64) UNIQUE NOT NULL,
  "browser_digest" varchar(64) NOT NULL,
  "nonce_digest" varchar(64) NOT NULL,
  "pkce_verifier_ciphertext" text NOT NULL,
  "redirect_uri" varchar(1024) NOT NULL,
  "link_identity_id" uuid,
  "link_session_id" uuid,
  "created_at" timestamptz NOT NULL DEFAULT (clock_timestamp()),
  "expires_at" timestamptz NOT NULL,
  "consumed_at" timestamptz
);

CREATE TABLE "security_event" (
  "event_id" uuid PRIMARY KEY NOT NULL,
  "identity_id" uuid,
  "session_id" uuid,
  "event_type" varchar(48) NOT NULL,
  "outcome_code" varchar(48) NOT NULL,
  "correlation_id" uuid NOT NULL,
  "occurred_at" timestamptz NOT NULL DEFAULT (clock_timestamp())
);

CREATE UNIQUE INDEX ON "external_identity" ("issuer", "subject");

CREATE UNIQUE INDEX ON "auth_session" ("session_id", "identity_id");

CREATE INDEX ON "auth_session" ("identity_id");

CREATE UNIQUE INDEX ON "refresh_token" ("refresh_token_id", "session_id");

CREATE UNIQUE INDEX ON "refresh_token" ("parent_token_id", "session_id");

CREATE INDEX ON "refresh_token" ("session_id");

CREATE INDEX ON "account_challenge" ("identity_id", "purpose");

CREATE INDEX ON "security_event" ("identity_id", "occurred_at");

ALTER TABLE "password_credential" ADD FOREIGN KEY ("identity_id") REFERENCES "identity" ("identity_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "external_identity" ADD FOREIGN KEY ("identity_id") REFERENCES "identity" ("identity_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "auth_session" ADD FOREIGN KEY ("identity_id") REFERENCES "identity" ("identity_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "refresh_token" ADD FOREIGN KEY ("session_id") REFERENCES "auth_session" ("session_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "refresh_token" ADD FOREIGN KEY ("parent_token_id", "session_id") REFERENCES "refresh_token" ("refresh_token_id", "session_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "account_challenge" ADD FOREIGN KEY ("identity_id") REFERENCES "identity" ("identity_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "oidc_request" ADD FOREIGN KEY ("link_session_id", "link_identity_id") REFERENCES "auth_session" ("session_id", "identity_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "security_event" ADD FOREIGN KEY ("identity_id") REFERENCES "identity" ("identity_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "security_event" ADD FOREIGN KEY ("session_id", "identity_id") REFERENCES "auth_session" ("session_id", "identity_id") DEFERRABLE INITIALLY IMMEDIATE;

 
ALTER TABLE identity ADD CONSTRAINT ck_identity_1 CHECK (security_state IN ('Enabled','Disabled'));
ALTER TABLE identity ADD CONSTRAINT ck_identity_2 CHECK (credential_revision > 0);
ALTER TABLE identity ADD CONSTRAINT ck_identity_3 CHECK (login_email IS NULL OR (length(login_email)>3 AND login_email = lower(btrim(login_email)) AND login_email ~ '^[!-~]+@[!-~]+$'));
ALTER TABLE identity ADD CONSTRAINT ck_identity_4 CHECK (email_verified_at IS NULL OR (login_email IS NOT NULL AND email_verified_at >= created_at));
ALTER TABLE password_credential ADD CONSTRAINT ck_password_credential_1 CHECK (length(password_hash) > 30 AND password_hash LIKE '$argon2id$%');
ALTER TABLE external_identity ADD CONSTRAINT ck_external_identity_1 CHECK (length(issuer)>0 AND length(subject)>0);
ALTER TABLE auth_session ADD CONSTRAINT ck_auth_session_1 CHECK (auth_method IN ('Password','Oidc'));
ALTER TABLE auth_session ADD CONSTRAINT ck_auth_session_2 CHECK (expires_at > created_at);
ALTER TABLE auth_session ADD CONSTRAINT ck_auth_session_3 CHECK ((revoked_at IS NULL) = (revocation_reason IS NULL));
ALTER TABLE auth_session ADD CONSTRAINT ck_auth_session_4 CHECK (revoked_at IS NULL OR revoked_at >= created_at);
ALTER TABLE refresh_token ADD CONSTRAINT ck_refresh_token_1 CHECK (secret_digest ~ '^[0-9a-f]{64}$');
ALTER TABLE refresh_token ADD CONSTRAINT ck_refresh_token_2 CHECK (expires_at > created_at);
ALTER TABLE refresh_token ADD CONSTRAINT ck_refresh_token_3 CHECK (parent_token_id IS NULL OR parent_token_id <> refresh_token_id);
ALTER TABLE refresh_token ADD CONSTRAINT ck_refresh_token_4 CHECK (consumed_at IS NULL OR consumed_at >= created_at);
ALTER TABLE refresh_token ADD CONSTRAINT ck_refresh_token_5 CHECK (revoked_at IS NULL OR revoked_at >= created_at);
ALTER TABLE account_challenge ADD CONSTRAINT ck_account_challenge_1 CHECK (purpose IN ('VerifyEmail','ResetPassword'));
ALTER TABLE account_challenge ADD CONSTRAINT ck_account_challenge_2 CHECK (credential_revision>0);
ALTER TABLE account_challenge ADD CONSTRAINT ck_account_challenge_3 CHECK (secret_digest ~ '^[0-9a-f]{64}$');
ALTER TABLE account_challenge ADD CONSTRAINT ck_account_challenge_4 CHECK (expires_at > created_at);
ALTER TABLE account_challenge ADD CONSTRAINT ck_account_challenge_5 CHECK (consumed_at IS NULL OR consumed_at >= created_at);
ALTER TABLE account_challenge ADD CONSTRAINT ck_account_challenge_6 CHECK (invalidated_at IS NULL OR invalidated_at >= created_at);
ALTER TABLE oidc_request ADD CONSTRAINT ck_oidc_request_1 CHECK (purpose IN ('Login','Link'));
ALTER TABLE oidc_request ADD CONSTRAINT ck_oidc_request_2 CHECK ((purpose='Login' AND link_identity_id IS NULL AND link_session_id IS NULL) OR (purpose='Link' AND link_identity_id IS NOT NULL AND link_session_id IS NOT NULL));
ALTER TABLE oidc_request ADD CONSTRAINT ck_oidc_request_3 CHECK (state_digest ~ '^[0-9a-f]{64}$' AND browser_digest ~ '^[0-9a-f]{64}$' AND nonce_digest ~ '^[0-9a-f]{64}$');
ALTER TABLE oidc_request ADD CONSTRAINT ck_oidc_request_4 CHECK (length(issuer)>0 AND length(pkce_verifier_ciphertext)>0 AND length(redirect_uri)>0);
ALTER TABLE oidc_request ADD CONSTRAINT ck_oidc_request_5 CHECK (expires_at > created_at);
ALTER TABLE oidc_request ADD CONSTRAINT ck_oidc_request_6 CHECK (consumed_at IS NULL OR consumed_at >= created_at);
ALTER TABLE security_event ADD CONSTRAINT ck_security_event_1 CHECK (session_id IS NULL OR identity_id IS NOT NULL);
ALTER TABLE security_event ADD CONSTRAINT ck_security_event_2 CHECK (length(event_type)>0 AND length(outcome_code)>0);
CREATE UNIQUE INDEX ux_refresh_live ON refresh_token(session_id)
 WHERE consumed_at IS NULL AND revoked_at IS NULL;
CREATE UNIQUE INDEX ux_refresh_root ON refresh_token(session_id) WHERE parent_token_id IS NULL;
CREATE UNIQUE INDEX ux_challenge_live ON account_challenge(identity_id,purpose)
 WHERE consumed_at IS NULL AND invalidated_at IS NULL;
 
CREATE FUNCTION auth_refresh_bounds() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE s auth_session; parent refresh_token;
BEGIN
 SELECT * INTO STRICT s FROM auth_session WHERE session_id=NEW.session_id;
 IF NEW.created_at < s.created_at OR NEW.expires_at > s.expires_at THEN
  RAISE EXCEPTION 'Refresh lifetime outside session';
 END IF;
 IF NEW.parent_token_id IS NOT NULL THEN
  SELECT * INTO STRICT parent FROM refresh_token WHERE refresh_token_id=NEW.parent_token_id AND session_id=NEW.session_id;
  IF parent.consumed_at IS NULL OR parent.consumed_at > NEW.created_at THEN
   RAISE EXCEPTION 'Parent must be consumed before replacement';
  END IF;
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER refresh_bounds BEFORE INSERT OR UPDATE ON refresh_token
 FOR EACH ROW EXECUTE FUNCTION auth_refresh_bounds();

 
 
CREATE FUNCTION auth_rotate_refresh(p_old_digest text,p_new_id uuid,p_new_digest text,p_correlation uuid)
RETURNS TABLE(outcome text,identity_id uuid,session_id uuid) LANGUAGE plpgsql AS $$
DECLARE t refresh_token; s auth_session; a identity; at_time timestamptz;
BEGIN
 SELECT * INTO t FROM refresh_token r WHERE r.secret_digest=p_old_digest;
 IF NOT FOUND THEN RETURN QUERY SELECT 'Denied'::text,NULL::uuid,NULL::uuid; RETURN; END IF;
 SELECT * INTO s FROM auth_session x WHERE x.session_id=t.session_id;
 SELECT * INTO a FROM identity x WHERE x.identity_id=s.identity_id FOR UPDATE;
 SELECT * INTO s FROM auth_session x WHERE x.session_id=t.session_id FOR UPDATE;
 SELECT * INTO t FROM refresh_token r WHERE r.refresh_token_id=t.refresh_token_id FOR UPDATE;
 at_time:=clock_timestamp();
 IF t.consumed_at IS NOT NULL THEN
  UPDATE auth_session x SET revoked_at=COALESCE(x.revoked_at,at_time),
    revocation_reason=COALESCE(x.revocation_reason,'RefreshReuse') WHERE x.session_id=s.session_id;
  UPDATE refresh_token r SET revoked_at=COALESCE(r.revoked_at,at_time) WHERE r.session_id=s.session_id;
  INSERT INTO security_event VALUES(p_new_id,a.identity_id,s.session_id,'RefreshReuse','Denied',p_correlation,at_time);
  RETURN QUERY SELECT 'Denied'::text,NULL::uuid,NULL::uuid; RETURN;
 END IF;
 IF a.security_state<>'Enabled' OR s.revoked_at IS NOT NULL OR s.expires_at<=at_time
    OR t.expires_at<=at_time OR t.revoked_at IS NOT NULL THEN
  RETURN QUERY SELECT 'Denied'::text,NULL::uuid,NULL::uuid; RETURN;
 END IF;
 UPDATE refresh_token r SET consumed_at=at_time WHERE r.refresh_token_id=t.refresh_token_id;
 INSERT INTO refresh_token(refresh_token_id,session_id,parent_token_id,secret_digest,created_at,expires_at)
 VALUES(p_new_id,s.session_id,t.refresh_token_id,p_new_digest,at_time,LEAST(at_time+interval '7 days',s.expires_at));
 INSERT INTO security_event VALUES(p_new_id,a.identity_id,s.session_id,'RefreshRotated','Succeeded',p_correlation,at_time);
 RETURN QUERY SELECT 'Rotated'::text,a.identity_id,s.session_id;
END $$;
REVOKE ALL ON FUNCTION auth_rotate_refresh(text,uuid,text,uuid) FROM PUBLIC;
