--
-- PostgreSQL database dump
--

\restrict yLGDtJNC5qWcLv5m0AepTQANUpTwFw5gTIIQxJaiVyJ9nYjCUSrHTDAYuRUMvvA

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
-- Name: um_channel; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.um_channel AS ENUM (
    'Web',
    'MCP',
    'Internal'
);


--
-- Name: um_operation_outcome; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.um_operation_outcome AS ENUM (
    'Applied',
    'Rejected'
);


--
-- Name: um_user_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.um_user_status AS ENUM (
    'Active',
    'Inactive'
);


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
-- Name: administrator_profile; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.administrator_profile (
    administrator_id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL
);


--
-- Name: outbox_message; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outbox_message (
    event_id uuid NOT NULL,
    aggregate_id uuid NOT NULL,
    aggregate_version bigint NOT NULL,
    event_type character varying(80) NOT NULL,
    body jsonb NOT NULL,
    correlation_id character varying(128) NOT NULL,
    trace_parent character varying(128),
    occurred_at timestamp with time zone NOT NULL,
    next_attempt_at timestamp with time zone NOT NULL,
    published_at timestamp with time zone,
    lease_id uuid,
    leased_until timestamp with time zone,
    attempts integer NOT NULL,
    last_error_code character varying(80),
    CONSTRAINT outbox_lease CHECK (((lease_id IS NULL) = (leased_until IS NULL))),
    CONSTRAINT outbox_version CHECK (((aggregate_version > 0) AND (attempts >= 0)))
);


--
-- Name: profile_operation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profile_operation (
    operation_id uuid NOT NULL,
    actor_user_id uuid,
    actor_service character varying(120),
    requesting_school_id uuid,
    authority_basis character varying(250) NOT NULL,
    channel public.um_channel NOT NULL,
    command_name character varying(80) NOT NULL,
    target_kind character varying(80) NOT NULL,
    target_id uuid NOT NULL,
    expected_revision bigint,
    resulting_revision bigint,
    request_fingerprint character varying(64) NOT NULL,
    outcome public.um_operation_outcome NOT NULL,
    outcome_code character varying(80) NOT NULL,
    recorded_at timestamp with time zone NOT NULL,
    reason text,
    confirmation_id uuid,
    confirmed_at timestamp with time zone,
    CONSTRAINT um_accountable_actor CHECK (((actor_user_id IS NOT NULL) OR ((actor_service IS NOT NULL) AND (length(TRIM(BOTH FROM actor_service)) > 0)))),
    CONSTRAINT um_confirmation_pair CHECK (((confirmation_id IS NULL) = (confirmed_at IS NULL))),
    CONSTRAINT um_expected_revision CHECK (((expected_revision IS NULL) OR (expected_revision > 0))),
    CONSTRAINT um_mcp_write_confirmation CHECK (((channel <> 'MCP'::public.um_channel) OR (outcome <> 'Applied'::public.um_operation_outcome) OR (confirmation_id IS NOT NULL))),
    CONSTRAINT um_operation_basis CHECK (((length((request_fingerprint)::text) = 64) AND (length(TRIM(BOTH FROM authority_basis)) > 0) AND (length(TRIM(BOTH FROM command_name)) > 0) AND (length(TRIM(BOTH FROM target_kind)) > 0) AND (length(TRIM(BOTH FROM outcome_code)) > 0))),
    CONSTRAINT um_result_revision CHECK (((resulting_revision IS NULL) OR (resulting_revision > 0)))
);


--
-- Name: student_profile; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.student_profile (
    student_id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL
);


--
-- Name: teacher_profile; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teacher_profile (
    teacher_id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL
);


--
-- Name: user_profile; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_profile (
    user_id uuid NOT NULL,
    identity_id uuid NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    email_address character varying(254),
    phone_number character varying(32),
    status public.um_user_status DEFAULT 'Active'::public.um_user_status NOT NULL,
    revision bigint DEFAULT 1 NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT um_nonblank_email CHECK (((email_address IS NULL) OR (length(TRIM(BOTH FROM email_address)) > 0))),
    CONSTRAINT um_nonblank_name CHECK (((length(TRIM(BOTH FROM first_name)) > 0) AND (length(TRIM(BOTH FROM last_name)) > 0))),
    CONSTRAINT um_nonblank_phone CHECK (((phone_number IS NULL) OR (length(TRIM(BOTH FROM phone_number)) > 0))),
    CONSTRAINT um_profile_revision_time CHECK (((revision > 0) AND (updated_at >= created_at)))
);


--
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- Name: administrator_profile administrator_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.administrator_profile
    ADD CONSTRAINT administrator_profile_pkey PRIMARY KEY (administrator_id);


--
-- Name: administrator_profile administrator_profile_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.administrator_profile
    ADD CONSTRAINT administrator_profile_user_id_key UNIQUE (user_id);


--
-- Name: outbox_message outbox_message_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_message
    ADD CONSTRAINT outbox_message_pkey PRIMARY KEY (event_id);


--
-- Name: profile_operation profile_operation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_operation
    ADD CONSTRAINT profile_operation_pkey PRIMARY KEY (operation_id);


--
-- Name: student_profile student_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_profile
    ADD CONSTRAINT student_profile_pkey PRIMARY KEY (student_id);


--
-- Name: student_profile student_profile_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_profile
    ADD CONSTRAINT student_profile_user_id_key UNIQUE (user_id);


--
-- Name: teacher_profile teacher_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teacher_profile
    ADD CONSTRAINT teacher_profile_pkey PRIMARY KEY (teacher_id);


--
-- Name: teacher_profile teacher_profile_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teacher_profile
    ADD CONSTRAINT teacher_profile_user_id_key UNIQUE (user_id);


--
-- Name: user_profile user_profile_identity_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_profile
    ADD CONSTRAINT user_profile_identity_id_key UNIQUE (identity_id);


--
-- Name: user_profile user_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_profile
    ADD CONSTRAINT user_profile_pkey PRIMARY KEY (user_id);


--
-- Name: IX_outbox_message_next_attempt_at_occurred_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_outbox_message_next_attempt_at_occurred_at" ON public.outbox_message USING btree (next_attempt_at, occurred_at) WHERE (published_at IS NULL);


--
-- Name: profile_operation_target_kind_target_id_recorded_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX profile_operation_target_kind_target_id_recorded_at_idx ON public.profile_operation USING btree (target_kind, target_id, recorded_at);


--
-- Name: administrator_profile administrator_profile_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.administrator_profile
    ADD CONSTRAINT administrator_profile_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_profile(user_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: student_profile student_profile_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_profile
    ADD CONSTRAINT student_profile_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_profile(user_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: teacher_profile teacher_profile_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teacher_profile
    ADD CONSTRAINT teacher_profile_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_profile(user_id) ON DELETE RESTRICT DEFERRABLE;


--
-- PostgreSQL database dump complete
--

\unrestrict yLGDtJNC5qWcLv5m0AepTQANUpTwFw5gTIIQxJaiVyJ9nYjCUSrHTDAYuRUMvvA

