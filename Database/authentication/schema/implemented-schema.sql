--
-- PostgreSQL database dump
--

\restrict 5IdrP5csZrLNfjHF2ObdmVqAC4kLJTWKRlMYhsSeisRVGRpj1eGNScn7CGSmY6p

-- Dumped from database version 17.12 (Debian 17.12-1.pgdg13+1)
-- Dumped by pg_dump version 17.12 (Debian 17.12-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: auth_refresh_bounds(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.auth_refresh_bounds() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
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


--
-- Name: auth_rotate_refresh(text, uuid, text, uuid, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.auth_rotate_refresh(p_old_digest text, p_new_id uuid, p_new_digest text, p_correlation uuid, p_at timestamp with time zone) RETURNS TABLE(outcome text, identity_id uuid, session_id uuid)
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    DECLARE t refresh_token; s auth_session; a identity; at_time timestamptz;
    BEGIN
     IF p_at IS NULL THEN RAISE EXCEPTION 'Rotation time is required'; END IF;
     SELECT * INTO t FROM refresh_token r WHERE r.secret_digest=p_old_digest;
     IF NOT FOUND THEN RETURN QUERY SELECT 'Denied'::text,NULL::uuid,NULL::uuid; RETURN; END IF;
     SELECT * INTO s FROM auth_session x WHERE x.session_id=t.session_id;
     SELECT * INTO a FROM identity x WHERE x.identity_id=s.identity_id FOR UPDATE;
     SELECT * INTO s FROM auth_session x WHERE x.session_id=t.session_id FOR UPDATE;
     SELECT * INTO t FROM refresh_token r WHERE r.refresh_token_id=t.refresh_token_id FOR UPDATE;
     -- Application time, clamped so no new fact precedes the session or any token already in its family.
     SELECT GREATEST(p_at,s.created_at,max(r.created_at)) INTO at_time FROM refresh_token r WHERE r.session_id=s.session_id;
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


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: __EFMigrationsHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL
);


--
-- Name: account_challenge; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_challenge (
    challenge_id uuid NOT NULL,
    identity_id uuid NOT NULL,
    purpose character varying(20) NOT NULL,
    login_email character varying(254) NOT NULL,
    credential_revision bigint NOT NULL,
    secret_digest character varying(64) NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    consumed_at timestamp with time zone,
    invalidated_at timestamp with time zone,
    CONSTRAINT ck_account_challenge_1 CHECK (((purpose)::text = ANY ((ARRAY['VerifyEmail'::character varying, 'ResetPassword'::character varying])::text[]))),
    CONSTRAINT ck_account_challenge_2 CHECK ((credential_revision > 0)),
    CONSTRAINT ck_account_challenge_3 CHECK (((secret_digest)::text ~ '^[0-9a-f]{64}$'::text)),
    CONSTRAINT ck_account_challenge_4 CHECK ((expires_at > created_at)),
    CONSTRAINT ck_account_challenge_5 CHECK (((consumed_at IS NULL) OR (consumed_at >= created_at))),
    CONSTRAINT ck_account_challenge_6 CHECK (((invalidated_at IS NULL) OR (invalidated_at >= created_at)))
);


--
-- Name: auth_operation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_operation (
    operation_id uuid NOT NULL,
    identity_id uuid NOT NULL,
    source_session_id uuid NOT NULL,
    target_session_id uuid NOT NULL,
    fingerprint character varying(64) NOT NULL,
    recorded_at timestamp with time zone NOT NULL,
    outcome_status integer NOT NULL,
    CONSTRAINT auth_operation_fingerprint_check CHECK (((fingerprint)::text ~ '^[0-9a-f]{64}$'::text)),
    CONSTRAINT auth_operation_outcome_status_check CHECK ((outcome_status = ANY (ARRAY[200, 404])))
);


--
-- Name: auth_session; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_session (
    session_id uuid NOT NULL,
    identity_id uuid NOT NULL,
    auth_method character varying(16) NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    revoked_at timestamp with time zone,
    revocation_reason character varying(40),
    CONSTRAINT ck_auth_session_1 CHECK (((auth_method)::text = ANY ((ARRAY['Password'::character varying, 'Oidc'::character varying])::text[]))),
    CONSTRAINT ck_auth_session_2 CHECK ((expires_at > created_at)),
    CONSTRAINT ck_auth_session_3 CHECK (((revoked_at IS NULL) = (revocation_reason IS NULL))),
    CONSTRAINT ck_auth_session_4 CHECK (((revoked_at IS NULL) OR (revoked_at >= created_at)))
);


--
-- Name: challenge_delivery; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.challenge_delivery (
    delivery_id uuid NOT NULL,
    challenge_id uuid NOT NULL,
    protected_payload text,
    status character varying(16) NOT NULL,
    attempts integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    next_attempt_at timestamp with time zone NOT NULL,
    lease_id uuid,
    leased_until timestamp with time zone,
    last_error_code character varying(80),
    CONSTRAINT challenge_delivery_attempts_check CHECK ((attempts >= 0)),
    CONSTRAINT challenge_delivery_check CHECK ((expires_at > created_at)),
    CONSTRAINT challenge_delivery_check1 CHECK (((lease_id IS NULL) = (leased_until IS NULL))),
    CONSTRAINT challenge_delivery_check2 CHECK ((((status)::text = 'Sending'::text) = (lease_id IS NOT NULL))),
    CONSTRAINT challenge_delivery_check3 CHECK ((((status)::text <> ALL ((ARRAY['Pending'::character varying, 'Sending'::character varying])::text[])) OR (protected_payload IS NOT NULL))),
    CONSTRAINT challenge_delivery_status_check CHECK (((status)::text = ANY ((ARRAY['Pending'::character varying, 'Sending'::character varying, 'Sent'::character varying, 'Failed'::character varying, 'Unknown'::character varying, 'Superseded'::character varying, 'Expired'::character varying])::text[])))
);


--
-- Name: external_identity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.external_identity (
    external_identity_id uuid NOT NULL,
    identity_id uuid NOT NULL,
    issuer character varying(512) NOT NULL,
    subject character varying(255) NOT NULL,
    linked_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    CONSTRAINT ck_external_identity_1 CHECK (((length((issuer)::text) > 0) AND (length((subject)::text) > 0)))
);


--
-- Name: identity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.identity (
    identity_id uuid NOT NULL,
    login_email character varying(254),
    email_verified_at timestamp with time zone,
    security_state character varying(16) DEFAULT 'Enabled'::character varying NOT NULL,
    credential_revision bigint DEFAULT 1 NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    CONSTRAINT ck_identity_1 CHECK (((security_state)::text = ANY ((ARRAY['Enabled'::character varying, 'Disabled'::character varying])::text[]))),
    CONSTRAINT ck_identity_2 CHECK ((credential_revision > 0)),
    CONSTRAINT ck_identity_3 CHECK (((login_email IS NULL) OR ((length((login_email)::text) > 3) AND ((login_email)::text = lower(btrim((login_email)::text))) AND ((login_email)::text ~ '^[!-~]+@[!-~]+$'::text)))),
    CONSTRAINT ck_identity_4 CHECK (((email_verified_at IS NULL) OR ((login_email IS NOT NULL) AND (email_verified_at >= created_at))))
);


--
-- Name: oidc_request; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oidc_request (
    request_id uuid NOT NULL,
    purpose character varying(8) NOT NULL,
    issuer character varying(512) NOT NULL,
    state_digest character varying(64) NOT NULL,
    browser_digest character varying(64) NOT NULL,
    nonce_digest character varying(64) NOT NULL,
    pkce_verifier_ciphertext text NOT NULL,
    redirect_uri character varying(1024) NOT NULL,
    link_identity_id uuid,
    link_session_id uuid,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    consumed_at timestamp with time zone,
    CONSTRAINT ck_oidc_request_1 CHECK (((purpose)::text = ANY ((ARRAY['Login'::character varying, 'Link'::character varying])::text[]))),
    CONSTRAINT ck_oidc_request_2 CHECK (((((purpose)::text = 'Login'::text) AND (link_identity_id IS NULL) AND (link_session_id IS NULL)) OR (((purpose)::text = 'Link'::text) AND (link_identity_id IS NOT NULL) AND (link_session_id IS NOT NULL)))),
    CONSTRAINT ck_oidc_request_3 CHECK ((((state_digest)::text ~ '^[0-9a-f]{64}$'::text) AND ((browser_digest)::text ~ '^[0-9a-f]{64}$'::text) AND ((nonce_digest)::text ~ '^[0-9a-f]{64}$'::text))),
    CONSTRAINT ck_oidc_request_4 CHECK (((length((issuer)::text) > 0) AND (length(pkce_verifier_ciphertext) > 0) AND (length((redirect_uri)::text) > 0))),
    CONSTRAINT ck_oidc_request_5 CHECK ((expires_at > created_at)),
    CONSTRAINT ck_oidc_request_6 CHECK (((consumed_at IS NULL) OR (consumed_at >= created_at)))
);


--
-- Name: password_credential; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.password_credential (
    identity_id uuid NOT NULL,
    password_hash text NOT NULL,
    changed_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    CONSTRAINT ck_password_credential_1 CHECK (((length(password_hash) > 30) AND (password_hash ~~ '$argon2id$%'::text)))
);


--
-- Name: refresh_token; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.refresh_token (
    refresh_token_id uuid NOT NULL,
    session_id uuid NOT NULL,
    parent_token_id uuid,
    secret_digest character varying(64) NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    consumed_at timestamp with time zone,
    revoked_at timestamp with time zone,
    CONSTRAINT ck_refresh_token_1 CHECK (((secret_digest)::text ~ '^[0-9a-f]{64}$'::text)),
    CONSTRAINT ck_refresh_token_2 CHECK ((expires_at > created_at)),
    CONSTRAINT ck_refresh_token_3 CHECK (((parent_token_id IS NULL) OR (parent_token_id <> refresh_token_id))),
    CONSTRAINT ck_refresh_token_4 CHECK (((consumed_at IS NULL) OR (consumed_at >= created_at))),
    CONSTRAINT ck_refresh_token_5 CHECK (((revoked_at IS NULL) OR (revoked_at >= created_at)))
);


--
-- Name: security_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.security_event (
    event_id uuid NOT NULL,
    identity_id uuid,
    session_id uuid,
    event_type character varying(48) NOT NULL,
    outcome_code character varying(48) NOT NULL,
    correlation_id uuid NOT NULL,
    occurred_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    CONSTRAINT ck_security_event_1 CHECK (((session_id IS NULL) OR (identity_id IS NOT NULL))),
    CONSTRAINT ck_security_event_2 CHECK (((length((event_type)::text) > 0) AND (length((outcome_code)::text) > 0)))
);


--
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- Name: account_challenge account_challenge_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_challenge
    ADD CONSTRAINT account_challenge_pkey PRIMARY KEY (challenge_id);


--
-- Name: account_challenge account_challenge_secret_digest_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_challenge
    ADD CONSTRAINT account_challenge_secret_digest_key UNIQUE (secret_digest);


--
-- Name: auth_operation auth_operation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_operation
    ADD CONSTRAINT auth_operation_pkey PRIMARY KEY (operation_id);


--
-- Name: auth_session auth_session_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_session
    ADD CONSTRAINT auth_session_pkey PRIMARY KEY (session_id);


--
-- Name: challenge_delivery challenge_delivery_challenge_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.challenge_delivery
    ADD CONSTRAINT challenge_delivery_challenge_id_key UNIQUE (challenge_id);


--
-- Name: challenge_delivery challenge_delivery_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.challenge_delivery
    ADD CONSTRAINT challenge_delivery_pkey PRIMARY KEY (delivery_id);


--
-- Name: external_identity external_identity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_identity
    ADD CONSTRAINT external_identity_pkey PRIMARY KEY (external_identity_id);


--
-- Name: identity identity_login_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identity
    ADD CONSTRAINT identity_login_email_key UNIQUE (login_email);


--
-- Name: identity identity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identity
    ADD CONSTRAINT identity_pkey PRIMARY KEY (identity_id);


--
-- Name: oidc_request oidc_request_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oidc_request
    ADD CONSTRAINT oidc_request_pkey PRIMARY KEY (request_id);


--
-- Name: oidc_request oidc_request_state_digest_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oidc_request
    ADD CONSTRAINT oidc_request_state_digest_key UNIQUE (state_digest);


--
-- Name: password_credential password_credential_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_credential
    ADD CONSTRAINT password_credential_pkey PRIMARY KEY (identity_id);


--
-- Name: refresh_token refresh_token_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_token
    ADD CONSTRAINT refresh_token_pkey PRIMARY KEY (refresh_token_id);


--
-- Name: refresh_token refresh_token_secret_digest_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_token
    ADD CONSTRAINT refresh_token_secret_digest_key UNIQUE (secret_digest);


--
-- Name: security_event security_event_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_event
    ADD CONSTRAINT security_event_pkey PRIMARY KEY (event_id);


--
-- Name: account_challenge_identity_id_purpose_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX account_challenge_identity_id_purpose_idx ON public.account_challenge USING btree (identity_id, purpose);


--
-- Name: auth_session_identity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_session_identity_id_idx ON public.auth_session USING btree (identity_id);


--
-- Name: auth_session_session_id_identity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX auth_session_session_id_identity_id_idx ON public.auth_session USING btree (session_id, identity_id);


--
-- Name: external_identity_issuer_subject_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX external_identity_issuer_subject_idx ON public.external_identity USING btree (issuer, subject);


--
-- Name: ix_delivery_pending; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_delivery_pending ON public.challenge_delivery USING btree (next_attempt_at) WHERE ((status)::text = 'Pending'::text);


--
-- Name: refresh_token_parent_token_id_session_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX refresh_token_parent_token_id_session_id_idx ON public.refresh_token USING btree (parent_token_id, session_id);


--
-- Name: refresh_token_refresh_token_id_session_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX refresh_token_refresh_token_id_session_id_idx ON public.refresh_token USING btree (refresh_token_id, session_id);


--
-- Name: refresh_token_session_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX refresh_token_session_id_idx ON public.refresh_token USING btree (session_id);


--
-- Name: security_event_identity_id_occurred_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX security_event_identity_id_occurred_at_idx ON public.security_event USING btree (identity_id, occurred_at);


--
-- Name: ux_challenge_live; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_challenge_live ON public.account_challenge USING btree (identity_id, purpose) WHERE ((consumed_at IS NULL) AND (invalidated_at IS NULL));


--
-- Name: ux_refresh_live; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_refresh_live ON public.refresh_token USING btree (session_id) WHERE ((consumed_at IS NULL) AND (revoked_at IS NULL));


--
-- Name: ux_refresh_root; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_refresh_root ON public.refresh_token USING btree (session_id) WHERE (parent_token_id IS NULL);


--
-- Name: refresh_token refresh_bounds; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER refresh_bounds BEFORE INSERT OR UPDATE ON public.refresh_token FOR EACH ROW EXECUTE FUNCTION public.auth_refresh_bounds();


--
-- Name: account_challenge account_challenge_identity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_challenge
    ADD CONSTRAINT account_challenge_identity_id_fkey FOREIGN KEY (identity_id) REFERENCES public.identity(identity_id) DEFERRABLE;


--
-- Name: auth_operation auth_operation_source_session_id_identity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_operation
    ADD CONSTRAINT auth_operation_source_session_id_identity_id_fkey FOREIGN KEY (source_session_id, identity_id) REFERENCES public.auth_session(session_id, identity_id);


--
-- Name: auth_session auth_session_identity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_session
    ADD CONSTRAINT auth_session_identity_id_fkey FOREIGN KEY (identity_id) REFERENCES public.identity(identity_id) DEFERRABLE;


--
-- Name: challenge_delivery challenge_delivery_challenge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.challenge_delivery
    ADD CONSTRAINT challenge_delivery_challenge_id_fkey FOREIGN KEY (challenge_id) REFERENCES public.account_challenge(challenge_id);


--
-- Name: external_identity external_identity_identity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_identity
    ADD CONSTRAINT external_identity_identity_id_fkey FOREIGN KEY (identity_id) REFERENCES public.identity(identity_id) DEFERRABLE;


--
-- Name: oidc_request oidc_request_link_session_id_link_identity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oidc_request
    ADD CONSTRAINT oidc_request_link_session_id_link_identity_id_fkey FOREIGN KEY (link_session_id, link_identity_id) REFERENCES public.auth_session(session_id, identity_id) DEFERRABLE;


--
-- Name: password_credential password_credential_identity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_credential
    ADD CONSTRAINT password_credential_identity_id_fkey FOREIGN KEY (identity_id) REFERENCES public.identity(identity_id) DEFERRABLE;


--
-- Name: refresh_token refresh_token_parent_token_id_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_token
    ADD CONSTRAINT refresh_token_parent_token_id_session_id_fkey FOREIGN KEY (parent_token_id, session_id) REFERENCES public.refresh_token(refresh_token_id, session_id) DEFERRABLE;


--
-- Name: refresh_token refresh_token_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_token
    ADD CONSTRAINT refresh_token_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.auth_session(session_id) DEFERRABLE;


--
-- Name: security_event security_event_identity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_event
    ADD CONSTRAINT security_event_identity_id_fkey FOREIGN KEY (identity_id) REFERENCES public.identity(identity_id) DEFERRABLE;


--
-- Name: security_event security_event_session_id_identity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_event
    ADD CONSTRAINT security_event_session_id_identity_id_fkey FOREIGN KEY (session_id, identity_id) REFERENCES public.auth_session(session_id, identity_id) DEFERRABLE;


--
-- PostgreSQL database dump complete
--

\unrestrict 5IdrP5csZrLNfjHF2ObdmVqAC4kLJTWKRlMYhsSeisRVGRpj1eGNScn7CGSmY6p

