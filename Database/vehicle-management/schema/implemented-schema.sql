--
-- PostgreSQL database dump
--

\restrict SBJWA2ElspG91PYSCfmYwPH4tr0w3CnRbXe7cHIHLSdzAa20ZbgHz5UiZoHjNXv

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
-- Name: vm_channel; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.vm_channel AS ENUM (
    'Web',
    'MCP',
    'Internal'
);


--
-- Name: vm_maintenance_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.vm_maintenance_status AS ENUM (
    'Scheduled',
    'InProgress',
    'Completed',
    'Cancelled'
);


--
-- Name: vm_maintenance_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.vm_maintenance_type AS ENUM (
    'Service',
    'Repair',
    'Inspection'
);


--
-- Name: vm_transmission; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.vm_transmission AS ENUM (
    'Manual',
    'Automatic'
);


--
-- Name: vm_vehicle_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.vm_vehicle_status AS ENUM (
    'Active',
    'Inactive',
    'UnderMaintenance'
);


--
-- Name: vm_due_work(boolean, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vm_due_work(is_outbox boolean, batch_size integer) RETURNS TABLE(school_id uuid, item_id uuid)
    LANGUAGE sql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
     SELECT w.school_id,w.item_id FROM (
       SELECT o.school_id,o.message_id AS item_id,o.next_attempt_at FROM public.outbox_message o
       WHERE is_outbox AND o.published_at IS NULL AND o.next_attempt_at<=clock_timestamp() AND (o.lease_until IS NULL OR o.lease_until<=clock_timestamp())
       UNION ALL
       SELECT s.school_id,s.operation_id AS item_id,s.next_attempt_at FROM public.vehicle_state_change_operation s
       WHERE NOT is_outbox AND s.status NOT IN ('Completed','Rejected') AND s.next_attempt_at<=clock_timestamp() AND (s.lease_until IS NULL OR s.lease_until<=clock_timestamp())
     ) w ORDER BY w.next_attempt_at,w.item_id LIMIT LEAST(GREATEST(batch_size,1),100)
    $$;


--
-- Name: vm_immutable(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vm_immutable() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    BEGIN RAISE EXCEPTION 'Immutable evidence' USING ERRCODE='23514'; END $$;


--
-- Name: vm_outbox_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vm_outbox_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    BEGIN
     IF ROW(NEW.message_id,NEW.school_id,NEW.vehicle_id,NEW.aggregate_version,NEW.event_type,NEW.payload_json,NEW.correlation_id,NEW.occurred_at)
     IS DISTINCT FROM ROW(OLD.message_id,OLD.school_id,OLD.vehicle_id,OLD.aggregate_version,OLD.event_type,OLD.payload_json,OLD.correlation_id,OLD.occurred_at)
     OR OLD.published_at IS NOT NULL THEN RAISE EXCEPTION 'Immutable outbox content or delivered result' USING ERRCODE='23514'; END IF;
     RETURN NEW;
    END $$;


--
-- Name: vm_saga_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vm_saga_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    BEGIN
     IF ROW(NEW.operation_id,NEW.school_id,NEW.vehicle_id,NEW.actor_user_id,NEW.branch_id,NEW.operation_type,NEW.expected_vehicle_revision,NEW.fingerprint,NEW.reason,NEW.correlation_id,NEW.release_operation_id,NEW.created_at)
     IS DISTINCT FROM ROW(OLD.operation_id,OLD.school_id,OLD.vehicle_id,OLD.actor_user_id,OLD.branch_id,OLD.operation_type,OLD.expected_vehicle_revision,OLD.fingerprint,OLD.reason,OLD.correlation_id,OLD.release_operation_id,OLD.created_at)
     OR OLD.status IN ('Completed','Rejected') THEN RAISE EXCEPTION 'Immutable Saga intent or terminal result' USING ERRCODE='23514'; END IF;
     RETURN NEW;
    END $$;


--
-- Name: vm_vehicle_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vm_vehicle_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    BEGIN
     IF NEW.vehicle_id<>OLD.vehicle_id OR NEW.school_id<>OLD.school_id OR NEW.branch_id<>OLD.branch_id OR NEW.created_at<>OLD.created_at
     OR NEW.revision<>OLD.revision+1 THEN RAISE EXCEPTION 'Vehicle identity or revision conflict' USING ERRCODE='23514'; END IF;
     RETURN NEW;
    END $$;


--
-- Name: vm_work_health(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vm_work_health() RETURNS TABLE("PendingSagas" bigint, "RecoverySagas" bigint, "OldestSagaSeconds" double precision, "PendingOutbox" bigint, "OldestOutboxSeconds" double precision)
    LANGUAGE sql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
     SELECT
     (SELECT count(*) FROM public.vehicle_state_change_operation WHERE status NOT IN ('Completed','Rejected')),
     (SELECT count(*) FROM public.vehicle_state_change_operation WHERE status='NeedsRecovery'),
     (SELECT COALESCE(GREATEST(EXTRACT(epoch FROM clock_timestamp()-min(created_at)),0),0)::double precision FROM public.vehicle_state_change_operation WHERE status NOT IN ('Completed','Rejected')),
     (SELECT count(*) FROM public.outbox_message WHERE published_at IS NULL),
     (SELECT COALESCE(GREATEST(EXTRACT(epoch FROM clock_timestamp()-min(occurred_at)),0),0)::double precision FROM public.outbox_message WHERE published_at IS NULL)
    $$;


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
-- Name: command_request; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.command_request (
    request_id uuid NOT NULL,
    school_id uuid NOT NULL,
    actor_user_id uuid NOT NULL,
    idempotency_key character varying(128) NOT NULL,
    command_name character varying(80) NOT NULL,
    fingerprint character varying(64) NOT NULL,
    vehicle_id uuid NOT NULL,
    response_json text,
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT command_request_fingerprint_check CHECK (((fingerprint)::text ~ '^[0-9a-f]{64}$'::text)),
    CONSTRAINT command_request_idempotency_key_check CHECK (((length((idempotency_key)::text) >= 8) AND (length((idempotency_key)::text) <= 128)))
);


--
-- Name: maintenance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.maintenance (
    maintenance_id uuid NOT NULL,
    school_id uuid NOT NULL,
    vehicle_id uuid NOT NULL,
    type public.vm_maintenance_type NOT NULL,
    scheduled_at timestamp with time zone NOT NULL,
    started_at timestamp with time zone,
    completed_at timestamp with time zone,
    cancelled_at timestamp with time zone,
    status public.vm_maintenance_status DEFAULT 'Scheduled'::public.vm_maintenance_status NOT NULL,
    comment text,
    revision bigint DEFAULT 1 NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT vm_maintenance_lifecycle_shape CHECK ((((status = 'Scheduled'::public.vm_maintenance_status) AND (started_at IS NULL) AND (completed_at IS NULL) AND (cancelled_at IS NULL)) OR ((status = 'InProgress'::public.vm_maintenance_status) AND (started_at IS NOT NULL) AND (completed_at IS NULL) AND (cancelled_at IS NULL)) OR ((status = 'Completed'::public.vm_maintenance_status) AND (started_at IS NOT NULL) AND (completed_at IS NOT NULL) AND (cancelled_at IS NULL)) OR ((status = 'Cancelled'::public.vm_maintenance_status) AND (started_at IS NULL) AND (completed_at IS NULL) AND (cancelled_at IS NOT NULL)))),
    CONSTRAINT vm_maintenance_revision_time CHECK (((revision > 0) AND (updated_at >= created_at))),
    CONSTRAINT vm_maintenance_time_order CHECK ((((started_at IS NULL) OR (started_at >= created_at)) AND ((completed_at IS NULL) OR (completed_at >= started_at)) AND ((cancelled_at IS NULL) OR (cancelled_at >= created_at)))),
    CONSTRAINT vm_maintenance_updated_time CHECK ((((started_at IS NULL) OR (updated_at >= started_at)) AND ((completed_at IS NULL) OR (updated_at >= completed_at)) AND ((cancelled_at IS NULL) OR (updated_at >= cancelled_at))))
);


--
-- Name: outbox_message; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outbox_message (
    message_id uuid NOT NULL,
    school_id uuid NOT NULL,
    vehicle_id uuid NOT NULL,
    aggregate_version bigint NOT NULL,
    event_type character varying(80) NOT NULL,
    payload_json text NOT NULL,
    correlation_id character varying(128) NOT NULL,
    occurred_at timestamp with time zone NOT NULL,
    next_attempt_at timestamp with time zone NOT NULL,
    lease_token uuid,
    lease_until timestamp with time zone,
    attempts integer NOT NULL,
    published_at timestamp with time zone,
    CONSTRAINT outbox_message_aggregate_version_check CHECK ((aggregate_version > 0)),
    CONSTRAINT outbox_message_attempts_check CHECK ((attempts >= 0)),
    CONSTRAINT outbox_message_check CHECK (((lease_token IS NULL) = (lease_until IS NULL))),
    CONSTRAINT outbox_message_check1 CHECK (((published_at IS NULL) OR (published_at >= occurred_at))),
    CONSTRAINT outbox_message_event_type_check CHECK (((event_type)::text = ANY ((ARRAY['VehicleActivated'::character varying, 'VehicleDeactivated'::character varying])::text[])))
);


--
-- Name: vehicle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehicle (
    vehicle_id uuid NOT NULL,
    school_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    registration_country_code character varying(2) NOT NULL,
    registration_number character varying(32) NOT NULL,
    manufacturer character varying(100) NOT NULL,
    model character varying(100) NOT NULL,
    manufacture_year smallint NOT NULL,
    transmission public.vm_transmission NOT NULL,
    status public.vm_vehicle_status DEFAULT 'Inactive'::public.vm_vehicle_status NOT NULL,
    revision bigint DEFAULT 1 NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT vm_country_shape CHECK (((registration_country_code)::text ~ '^[A-Z]{2}$'::text)),
    CONSTRAINT vm_details_nonblank CHECK (((length(TRIM(BOTH FROM manufacturer)) > 0) AND (length(TRIM(BOTH FROM model)) > 0))),
    CONSTRAINT vm_registration_shape CHECK (((length(TRIM(BOTH FROM registration_number)) > 0) AND ((registration_number)::text = upper(TRIM(BOTH FROM registration_number))))),
    CONSTRAINT vm_revision_time CHECK (((revision > 0) AND (updated_at >= created_at))),
    CONSTRAINT vm_year_storage_range CHECK (((manufacture_year >= 1886) AND (manufacture_year <= 9999)))
);


--
-- Name: vehicle_operation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehicle_operation (
    operation_id uuid NOT NULL,
    school_id uuid NOT NULL,
    vehicle_id uuid NOT NULL,
    maintenance_id uuid,
    actor_user_id uuid,
    actor_service character varying(120),
    channel public.vm_channel NOT NULL,
    command_name character varying(80) NOT NULL,
    request_fingerprint character varying(64) NOT NULL,
    expected_vehicle_revision bigint,
    expected_maintenance_revision bigint,
    resulting_vehicle_revision bigint NOT NULL,
    resulting_maintenance_revision bigint,
    reason text,
    confirmation_id uuid,
    confirmed_at timestamp with time zone,
    recorded_at timestamp with time zone NOT NULL,
    CONSTRAINT vm_confirmation_pair CHECK (((confirmation_id IS NULL) = (confirmed_at IS NULL))),
    CONSTRAINT vm_confirmation_time CHECK (((confirmed_at IS NULL) OR (confirmed_at <= recorded_at))),
    CONSTRAINT vm_mcp_confirmation CHECK (((channel <> 'MCP'::public.vm_channel) OR (confirmation_id IS NOT NULL))),
    CONSTRAINT vm_operation_actor CHECK ((((actor_user_id IS NOT NULL) AND (actor_service IS NULL)) OR ((actor_user_id IS NULL) AND (actor_service IS NOT NULL) AND (length(TRIM(BOTH FROM actor_service)) > 0) AND (channel = 'Internal'::public.vm_channel)))),
    CONSTRAINT vm_operation_maintenance_shape CHECK ((((maintenance_id IS NULL) AND (expected_maintenance_revision IS NULL) AND (resulting_maintenance_revision IS NULL)) OR ((maintenance_id IS NOT NULL) AND (resulting_maintenance_revision IS NOT NULL) AND ((expected_maintenance_revision IS NULL) OR (expected_maintenance_revision > 0))))),
    CONSTRAINT vm_operation_revision_order CHECK ((((expected_vehicle_revision IS NULL) OR (resulting_vehicle_revision >= expected_vehicle_revision)) AND ((expected_maintenance_revision IS NULL) OR (resulting_maintenance_revision > expected_maintenance_revision)))),
    CONSTRAINT vm_operation_revisions CHECK ((((expected_vehicle_revision IS NULL) OR (expected_vehicle_revision > 0)) AND (resulting_vehicle_revision > 0) AND ((resulting_maintenance_revision IS NULL) OR (resulting_maintenance_revision > 0)))),
    CONSTRAINT vm_operation_shape CHECK (((length(TRIM(BOTH FROM command_name)) > 0) AND ((request_fingerprint)::text ~ '^[0-9a-f]{64}$'::text)))
);


--
-- Name: vehicle_state_change_operation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehicle_state_change_operation (
    operation_id uuid NOT NULL,
    school_id uuid NOT NULL,
    vehicle_id uuid NOT NULL,
    actor_user_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    operation_type character varying(32) NOT NULL,
    status character varying(32) NOT NULL,
    resume_status character varying(32) NOT NULL,
    expected_vehicle_revision bigint NOT NULL,
    fingerprint character varying(64) NOT NULL,
    reason character varying(1000) NOT NULL,
    correlation_id character varying(128) NOT NULL,
    block_id uuid,
    block_operation_id uuid,
    release_operation_id uuid NOT NULL,
    result_vehicle_status public.vm_vehicle_status,
    error_code character varying(120),
    attempts integer NOT NULL,
    next_attempt_at timestamp with time zone NOT NULL,
    lease_token uuid,
    lease_until timestamp with time zone,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT vehicle_state_change_operation_attempts_check CHECK ((attempts >= 0)),
    CONSTRAINT vehicle_state_change_operation_check CHECK ((updated_at >= created_at)),
    CONSTRAINT vehicle_state_change_operation_check1 CHECK (((lease_token IS NULL) = (lease_until IS NULL))),
    CONSTRAINT vehicle_state_change_operation_check2 CHECK (((block_id IS NULL) = (block_operation_id IS NULL))),
    CONSTRAINT vehicle_state_change_operation_expected_vehicle_revision_check CHECK ((expected_vehicle_revision > 0)),
    CONSTRAINT vehicle_state_change_operation_fingerprint_check CHECK (((fingerprint)::text ~ '^[0-9a-f]{64}$'::text)),
    CONSTRAINT vehicle_state_change_operation_operation_type_check CHECK (((operation_type)::text = ANY ((ARRAY['Deactivate'::character varying, 'Reactivate'::character varying])::text[]))),
    CONSTRAINT vehicle_state_change_operation_reason_check CHECK ((length(TRIM(BOTH FROM reason)) > 0)),
    CONSTRAINT vehicle_state_change_operation_resume_status_check CHECK (((resume_status)::text = ANY ((ARRAY['Pending'::character varying, 'Blocking'::character varying, 'SchedulingBlocked'::character varying, 'ApplyingVehicleState'::character varying, 'ReleasingBlock'::character varying, 'Completed'::character varying, 'Rejected'::character varying, 'NeedsRecovery'::character varying])::text[]))),
    CONSTRAINT vehicle_state_change_operation_status_check CHECK (((status)::text = ANY ((ARRAY['Pending'::character varying, 'Blocking'::character varying, 'SchedulingBlocked'::character varying, 'ApplyingVehicleState'::character varying, 'ReleasingBlock'::character varying, 'Completed'::character varying, 'Rejected'::character varying, 'NeedsRecovery'::character varying])::text[])))
);


--
-- Name: vehicle_supported_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehicle_supported_category (
    vehicle_id uuid NOT NULL,
    school_id uuid NOT NULL,
    category_code character varying(16) NOT NULL,
    CONSTRAINT vm_category_shape CHECK (((length(TRIM(BOTH FROM category_code)) > 0) AND ((category_code)::text = upper(TRIM(BOTH FROM category_code)))))
);


--
-- Name: vehicle_teacher_assignment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehicle_teacher_assignment (
    vehicle_id uuid NOT NULL,
    school_id uuid NOT NULL,
    teacher_id uuid NOT NULL,
    school_membership_id uuid NOT NULL,
    assigned_at timestamp with time zone NOT NULL
);


--
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- Name: command_request command_request_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.command_request
    ADD CONSTRAINT command_request_pkey PRIMARY KEY (request_id);


--
-- Name: command_request command_request_school_id_actor_user_id_command_name_idempo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.command_request
    ADD CONSTRAINT command_request_school_id_actor_user_id_command_name_idempo_key UNIQUE (school_id, actor_user_id, command_name, idempotency_key);


--
-- Name: maintenance maintenance_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance
    ADD CONSTRAINT maintenance_pkey PRIMARY KEY (maintenance_id);


--
-- Name: outbox_message outbox_message_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_message
    ADD CONSTRAINT outbox_message_pkey PRIMARY KEY (message_id);


--
-- Name: vehicle_operation vehicle_operation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_operation
    ADD CONSTRAINT vehicle_operation_pkey PRIMARY KEY (operation_id);


--
-- Name: vehicle vehicle_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle
    ADD CONSTRAINT vehicle_pkey PRIMARY KEY (vehicle_id);


--
-- Name: vehicle_state_change_operation vehicle_state_change_operation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_state_change_operation
    ADD CONSTRAINT vehicle_state_change_operation_pkey PRIMARY KEY (operation_id);


--
-- Name: vehicle_supported_category vehicle_supported_category_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_supported_category
    ADD CONSTRAINT vehicle_supported_category_pkey PRIMARY KEY (vehicle_id, school_id, category_code);


--
-- Name: vehicle_teacher_assignment vehicle_teacher_assignment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_teacher_assignment
    ADD CONSTRAINT vehicle_teacher_assignment_pkey PRIMARY KEY (vehicle_id, school_id, teacher_id);


--
-- Name: maintenance_maintenance_id_vehicle_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX maintenance_maintenance_id_vehicle_id_school_id_idx ON public.maintenance USING btree (maintenance_id, vehicle_id, school_id);


--
-- Name: maintenance_school_id_vehicle_id_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX maintenance_school_id_vehicle_id_status_idx ON public.maintenance USING btree (school_id, vehicle_id, status);


--
-- Name: vehicle_operation_school_id_vehicle_id_recorded_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX vehicle_operation_school_id_vehicle_id_recorded_at_idx ON public.vehicle_operation USING btree (school_id, vehicle_id, recorded_at);


--
-- Name: vehicle_school_id_branch_id_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX vehicle_school_id_branch_id_status_idx ON public.vehicle USING btree (school_id, branch_id, status);


--
-- Name: vehicle_school_id_registration_country_code_registration_nu_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX vehicle_school_id_registration_country_code_registration_nu_idx ON public.vehicle USING btree (school_id, registration_country_code, registration_number);


--
-- Name: vehicle_teacher_assignment_school_id_school_membership_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX vehicle_teacher_assignment_school_id_school_membership_id_idx ON public.vehicle_teacher_assignment USING btree (school_id, school_membership_id);


--
-- Name: vehicle_teacher_assignment_school_id_teacher_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX vehicle_teacher_assignment_school_id_teacher_id_idx ON public.vehicle_teacher_assignment USING btree (school_id, teacher_id);


--
-- Name: vehicle_vehicle_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX vehicle_vehicle_id_school_id_idx ON public.vehicle USING btree (vehicle_id, school_id);


--
-- Name: vm_one_inprogress_per_vehicle; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX vm_one_inprogress_per_vehicle ON public.maintenance USING btree (vehicle_id, school_id) WHERE (status = 'InProgress'::public.vm_maintenance_status);


--
-- Name: vm_one_live_state_change; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX vm_one_live_state_change ON public.vehicle_state_change_operation USING btree (school_id, vehicle_id) WHERE ((status)::text <> ALL ((ARRAY['Completed'::character varying, 'Rejected'::character varying])::text[]));


--
-- Name: vm_outbox_due; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX vm_outbox_due ON public.outbox_message USING btree (next_attempt_at, lease_until) WHERE (published_at IS NULL);


--
-- Name: vm_saga_due; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX vm_saga_due ON public.vehicle_state_change_operation USING btree (next_attempt_at, lease_until) WHERE ((status)::text <> ALL ((ARRAY['Completed'::character varying, 'Rejected'::character varying])::text[]));


--
-- Name: outbox_message vm_outbox_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER vm_outbox_guard BEFORE UPDATE ON public.outbox_message FOR EACH ROW EXECUTE FUNCTION public.vm_outbox_guard();


--
-- Name: vehicle_operation vm_receipt_immutable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER vm_receipt_immutable BEFORE DELETE OR UPDATE ON public.vehicle_operation FOR EACH ROW EXECUTE FUNCTION public.vm_immutable();


--
-- Name: command_request vm_request_immutable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER vm_request_immutable BEFORE DELETE OR UPDATE ON public.command_request FOR EACH ROW EXECUTE FUNCTION public.vm_immutable();


--
-- Name: vehicle_state_change_operation vm_saga_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER vm_saga_guard BEFORE UPDATE ON public.vehicle_state_change_operation FOR EACH ROW EXECUTE FUNCTION public.vm_saga_guard();


--
-- Name: vehicle vm_vehicle_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER vm_vehicle_guard BEFORE UPDATE ON public.vehicle FOR EACH ROW EXECUTE FUNCTION public.vm_vehicle_guard();


--
-- Name: command_request command_request_vehicle_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.command_request
    ADD CONSTRAINT command_request_vehicle_id_school_id_fkey FOREIGN KEY (vehicle_id, school_id) REFERENCES public.vehicle(vehicle_id, school_id) ON DELETE RESTRICT;


--
-- Name: maintenance maintenance_vehicle_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance
    ADD CONSTRAINT maintenance_vehicle_id_school_id_fkey FOREIGN KEY (vehicle_id, school_id) REFERENCES public.vehicle(vehicle_id, school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: outbox_message outbox_message_vehicle_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_message
    ADD CONSTRAINT outbox_message_vehicle_id_school_id_fkey FOREIGN KEY (vehicle_id, school_id) REFERENCES public.vehicle(vehicle_id, school_id) ON DELETE RESTRICT;


--
-- Name: vehicle_operation vehicle_operation_maintenance_id_vehicle_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_operation
    ADD CONSTRAINT vehicle_operation_maintenance_id_vehicle_id_school_id_fkey FOREIGN KEY (maintenance_id, vehicle_id, school_id) REFERENCES public.maintenance(maintenance_id, vehicle_id, school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: vehicle_operation vehicle_operation_vehicle_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_operation
    ADD CONSTRAINT vehicle_operation_vehicle_id_school_id_fkey FOREIGN KEY (vehicle_id, school_id) REFERENCES public.vehicle(vehicle_id, school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: vehicle_state_change_operation vehicle_state_change_operation_vehicle_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_state_change_operation
    ADD CONSTRAINT vehicle_state_change_operation_vehicle_id_school_id_fkey FOREIGN KEY (vehicle_id, school_id) REFERENCES public.vehicle(vehicle_id, school_id) ON DELETE RESTRICT;


--
-- Name: vehicle_supported_category vehicle_supported_category_vehicle_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_supported_category
    ADD CONSTRAINT vehicle_supported_category_vehicle_id_school_id_fkey FOREIGN KEY (vehicle_id, school_id) REFERENCES public.vehicle(vehicle_id, school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: vehicle_teacher_assignment vehicle_teacher_assignment_vehicle_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_teacher_assignment
    ADD CONSTRAINT vehicle_teacher_assignment_vehicle_id_school_id_fkey FOREIGN KEY (vehicle_id, school_id) REFERENCES public.vehicle(vehicle_id, school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: command_request; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.command_request ENABLE ROW LEVEL SECURITY;

--
-- Name: maintenance; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.maintenance ENABLE ROW LEVEL SECURITY;

--
-- Name: outbox_message; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.outbox_message ENABLE ROW LEVEL SECURITY;

--
-- Name: command_request tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.command_request TO v_vehicle_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: maintenance tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.maintenance TO v_vehicle_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: outbox_message tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.outbox_message TO v_vehicle_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: vehicle tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.vehicle TO v_vehicle_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: vehicle_operation tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.vehicle_operation TO v_vehicle_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: vehicle_state_change_operation tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.vehicle_state_change_operation TO v_vehicle_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: vehicle_supported_category tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.vehicle_supported_category TO v_vehicle_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: vehicle_teacher_assignment tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.vehicle_teacher_assignment TO v_vehicle_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: vehicle; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.vehicle ENABLE ROW LEVEL SECURITY;

--
-- Name: vehicle_operation; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.vehicle_operation ENABLE ROW LEVEL SECURITY;

--
-- Name: vehicle_state_change_operation; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.vehicle_state_change_operation ENABLE ROW LEVEL SECURITY;

--
-- Name: vehicle_supported_category; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.vehicle_supported_category ENABLE ROW LEVEL SECURITY;

--
-- Name: vehicle_teacher_assignment; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.vehicle_teacher_assignment ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--

\unrestrict SBJWA2ElspG91PYSCfmYwPH4tr0w3CnRbXe7cHIHLSdzAa20ZbgHz5UiZoHjNXv

