--
-- PostgreSQL database dump
--

\restrict 9XHVWQwmmbxV723c1j5RXaWiNCpEWYhyluZigmkw43nadfeihWZVHeaV2SvrkGM

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
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- Name: lesson_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.lesson_kind AS ENUM (
    'Practical',
    'Theory'
);


--
-- Name: lesson_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.lesson_status AS ENUM (
    'Cancelled',
    'Completed',
    'NoShow',
    'Scheduled'
);


--
-- Name: operation_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.operation_status AS ENUM (
    'Committed',
    'Pending',
    'ReconciliationPending',
    'Rejected'
);


--
-- Name: recurrence_frequency; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.recurrence_frequency AS ENUM (
    'Daily',
    'Weekly'
);


--
-- Name: request_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.request_status AS ENUM (
    'Confirmed',
    'Draft',
    'Infeasible',
    'Ready',
    'Rejected',
    'Stale',
    'Submitted',
    'Superseded'
);


--
-- Name: reservation_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.reservation_status AS ENUM (
    'Active',
    'Released'
);


--
-- Name: integration_inbox_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.integration_inbox_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    BEGIN RAISE EXCEPTION 'Integration inbox is append-only'; END $$;


--
-- Name: lesson_review_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.lesson_review_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    BEGIN
     IF TG_OP='DELETE' OR OLD.resolved_at IS NOT NULL THEN RAISE EXCEPTION 'Lesson review history is immutable'; END IF;
     IF (NEW.id,NEW.school_id,NEW.target_kind,NEW.target_id,NEW.reason_code,NEW.subject_role,NEW.subject_user_id,NEW.source_event_id,NEW.raised_at)
        IS DISTINCT FROM (OLD.id,OLD.school_id,OLD.target_kind,OLD.target_id,OLD.reason_code,OLD.subject_role,OLD.subject_user_id,OLD.source_event_id,OLD.raised_at)
     THEN RAISE EXCEPTION 'Lesson review identity is immutable'; END IF;
     RETURN NEW;
    END $$;


--
-- Name: scheduling_immutable(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.scheduling_immutable() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$ BEGIN
     RAISE EXCEPTION 'Scheduling evidence is immutable' USING ERRCODE='23514';
    END $$;


--
-- Name: scheduling_operation_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.scheduling_operation_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$ BEGIN
     IF OLD.status IN ('Committed','Rejected') OR
       (to_jsonb(NEW)-ARRAY['status','finished_at','result_lesson_id','result_appointment_id','outcome_code','result_json','http_status'])
       IS DISTINCT FROM (to_jsonb(OLD)-ARRAY['status','finished_at','result_lesson_id','result_appointment_id','outcome_code','result_json','http_status']) THEN
      RAISE EXCEPTION 'Immutable command identity or terminal outcome' USING ERRCODE='23514';
     END IF;
     RETURN NEW;
    END $$;


--
-- Name: scheduling_request_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.scheduling_request_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$ BEGIN
     IF OLD.status <> 'Draft' AND (to_jsonb(NEW)-ARRAY['status','generated_at','confirmed_at','confirmed_operation_id'])
     IS DISTINCT FROM (to_jsonb(OLD)-ARRAY['status','generated_at','confirmed_at','confirmed_operation_id']) THEN
      RAISE EXCEPTION 'Submitted inputs are immutable' USING ERRCODE='23514';
     END IF;
     IF OLD.status='Confirmed' THEN RAISE EXCEPTION 'Confirmed request is immutable' USING ERRCODE='23514'; END IF;
     RETURN NEW;
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
-- Name: assessment_appointment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessment_appointment (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    kind public.lesson_kind NOT NULL,
    enrollment_id uuid NOT NULL,
    student_id uuid NOT NULL,
    assessment_definition_id uuid NOT NULL,
    outstanding_requirement_id uuid,
    reason character varying(500) NOT NULL,
    teacher_id uuid NOT NULL,
    vehicle_id uuid,
    branch_id uuid NOT NULL,
    category_code character varying(16) NOT NULL,
    starts_at timestamp with time zone NOT NULL,
    ends_at timestamp with time zone NOT NULL,
    status public.lesson_status DEFAULT 'Scheduled'::public.lesson_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    readiness_evaluation_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    revision integer DEFAULT 1 NOT NULL,
    CONSTRAINT assessment_interval CHECK ((ends_at > starts_at)),
    CONSTRAINT assessment_type CHECK ((((kind = 'Practical'::public.lesson_kind) AND (vehicle_id IS NOT NULL)) OR ((kind = 'Theory'::public.lesson_kind) AND (vehicle_id IS NULL))))
);


--
-- Name: candidate_lesson; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.candidate_lesson (
    id uuid NOT NULL,
    request_id uuid NOT NULL,
    request_revision integer NOT NULL,
    kind public.lesson_kind NOT NULL,
    student_id uuid,
    enrollment_id uuid,
    group_id uuid,
    teacher_id uuid NOT NULL,
    vehicle_id uuid,
    branch_id uuid NOT NULL,
    series_id uuid,
    starts_at timestamp with time zone NOT NULL,
    ends_at timestamp with time zone NOT NULL,
    category_code character varying(16) NOT NULL,
    CONSTRAINT candidate_interval CHECK ((ends_at > starts_at)),
    CONSTRAINT candidate_type CHECK ((((kind = 'Practical'::public.lesson_kind) AND (enrollment_id IS NOT NULL) AND (student_id IS NOT NULL) AND (vehicle_id IS NOT NULL) AND (group_id IS NULL)) OR ((kind = 'Theory'::public.lesson_kind) AND (group_id IS NOT NULL) AND (enrollment_id IS NULL) AND (student_id IS NULL) AND (vehicle_id IS NULL))))
);


--
-- Name: candidate_lesson_participant; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.candidate_lesson_participant (
    candidate_lesson_id uuid NOT NULL,
    enrollment_id uuid NOT NULL,
    student_id uuid NOT NULL,
    membership_revision bigint NOT NULL,
    CONSTRAINT candidate_lesson_participant_membership_revision CHECK ((membership_revision > 0))
);


--
-- Name: gate_command; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gate_command (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    fingerprint text NOT NULL,
    kind text NOT NULL,
    result_json text NOT NULL,
    http_status integer NOT NULL
);


--
-- Name: integration_inbox; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integration_inbox (
    event_id uuid NOT NULL,
    producer character varying(32) NOT NULL,
    event_type character varying(64) NOT NULL,
    fingerprint character varying(64) NOT NULL,
    outcome character varying(32) NOT NULL,
    reviews_raised integer NOT NULL,
    processed_at timestamp with time zone NOT NULL,
    CONSTRAINT integration_inbox_fingerprint CHECK (((fingerprint)::text ~ '^[0-9a-f]{64}$'::text)),
    CONSTRAINT integration_inbox_reviews CHECK ((reviews_raised >= 0))
);


--
-- Name: lesson; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lesson (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    kind public.lesson_kind NOT NULL,
    branch_id uuid NOT NULL,
    teacher_id uuid NOT NULL,
    enrollment_id uuid,
    student_id uuid,
    vehicle_id uuid,
    group_id uuid,
    group_membership_revision bigint,
    starts_at timestamp with time zone NOT NULL,
    ends_at timestamp with time zone NOT NULL,
    status public.lesson_status DEFAULT 'Scheduled'::public.lesson_status NOT NULL,
    revision integer DEFAULT 1 NOT NULL,
    series_id uuid,
    source_candidate_id uuid,
    created_at timestamp with time zone NOT NULL,
    category_code character varying(16) NOT NULL,
    actual_start timestamp with time zone,
    actual_end timestamp with time zone,
    reason character varying(500),
    CONSTRAINT lesson_actual_interval CHECK ((((actual_start IS NULL) AND (actual_end IS NULL)) OR ((actual_start IS NOT NULL) AND (actual_end IS NOT NULL) AND (actual_end > actual_start)))),
    CONSTRAINT lesson_completed_requires_actuals CHECK (((status <> 'Completed'::public.lesson_status) OR ((actual_start IS NOT NULL) AND (actual_end IS NOT NULL)))),
    CONSTRAINT lesson_interval CHECK ((ends_at > starts_at)),
    CONSTRAINT lesson_membership_basis CHECK ((((kind = 'Practical'::public.lesson_kind) AND (group_membership_revision IS NULL)) OR ((kind = 'Theory'::public.lesson_kind) AND (group_membership_revision IS NOT NULL) AND (group_membership_revision > 0)))),
    CONSTRAINT lesson_reason CHECK (((reason IS NULL) OR ((kind = 'Practical'::public.lesson_kind) AND ((reason)::text = btrim((reason)::text)) AND ((reason)::text <> ''::text)))),
    CONSTRAINT lesson_revision_positive CHECK ((revision > 0)),
    CONSTRAINT lesson_type CHECK ((((kind = 'Practical'::public.lesson_kind) AND (enrollment_id IS NOT NULL) AND (student_id IS NOT NULL) AND (vehicle_id IS NOT NULL) AND (group_id IS NULL)) OR ((kind = 'Theory'::public.lesson_kind) AND (group_id IS NOT NULL) AND (enrollment_id IS NULL) AND (student_id IS NULL) AND (vehicle_id IS NULL))))
);


--
-- Name: lesson_change; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lesson_change (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    lesson_id uuid NOT NULL,
    operation_id uuid NOT NULL,
    revision integer NOT NULL,
    previous_status public.lesson_status NOT NULL,
    previous_start timestamp with time zone NOT NULL,
    previous_end timestamp with time zone NOT NULL,
    previous_teacher_id uuid NOT NULL,
    previous_vehicle_id uuid,
    previous_branch_id uuid NOT NULL,
    previous_series_id uuid,
    previous_group_membership_revision bigint,
    changed_at timestamp with time zone NOT NULL,
    previous_actual_start timestamp with time zone,
    previous_actual_end timestamp with time zone,
    CONSTRAINT history_actual_interval CHECK ((((previous_actual_start IS NULL) AND (previous_actual_end IS NULL)) OR ((previous_actual_start IS NOT NULL) AND (previous_actual_end IS NOT NULL) AND (previous_actual_end > previous_actual_start)))),
    CONSTRAINT history_previous_interval CHECK ((previous_end > previous_start)),
    CONSTRAINT history_revision_positive CHECK ((revision > 1))
);


--
-- Name: lesson_participant; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lesson_participant (
    lesson_id uuid NOT NULL,
    enrollment_id uuid NOT NULL,
    student_id uuid NOT NULL,
    membership_revision bigint NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT lesson_participant_membership_revision CHECK ((membership_revision > 0))
);


--
-- Name: lesson_review; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lesson_review (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    target_kind character varying(32) NOT NULL,
    target_id uuid NOT NULL,
    reason_code character varying(64) NOT NULL,
    subject_role character varying(16) NOT NULL,
    subject_user_id uuid NOT NULL,
    source_event_id uuid NOT NULL,
    raised_at timestamp with time zone NOT NULL,
    resolved_at timestamp with time zone,
    resolved_by_user_id uuid,
    resolution_note character varying(500),
    CONSTRAINT lesson_review_resolution CHECK ((((resolved_at IS NULL) = (resolved_by_user_id IS NULL)) AND ((resolved_at IS NULL) = (resolution_note IS NULL)) AND ((resolved_at IS NULL) OR (resolved_at >= raised_at)))),
    CONSTRAINT lesson_review_role CHECK (((subject_role)::text = ANY ((ARRAY['Teacher'::character varying, 'Student'::character varying])::text[]))),
    CONSTRAINT lesson_review_target CHECK (((target_kind)::text = ANY ((ARRAY['Lesson'::character varying, 'AssessmentAppointment'::character varying])::text[])))
);


--
-- Name: outbox_message; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outbox_message (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    aggregate_id uuid NOT NULL,
    aggregate_version integer NOT NULL,
    event_type text NOT NULL,
    payload text NOT NULL,
    occurred_at timestamp with time zone NOT NULL,
    available_at timestamp with time zone NOT NULL,
    lease_id uuid,
    lease_until timestamp with time zone,
    published_at timestamp with time zone,
    attempts integer NOT NULL
);


--
-- Name: recurring_lesson_series; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recurring_lesson_series (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    kind public.lesson_kind NOT NULL,
    frequency public.recurrence_frequency NOT NULL,
    recurrence_interval integer DEFAULT 1 NOT NULL,
    weekdays smallint[],
    local_start_time time without time zone NOT NULL,
    duration_minutes integer NOT NULL,
    time_zone character varying(80) NOT NULL,
    starts_on date NOT NULL,
    ends_on date,
    occurrence_count integer,
    CONSTRAINT recurrence_count CHECK (((occurrence_count IS NULL) OR (occurrence_count > 0))),
    CONSTRAINT recurrence_end_choice CHECK (((((ends_on IS NOT NULL))::integer + ((occurrence_count IS NOT NULL))::integer) = 1)),
    CONSTRAINT recurrence_end_range CHECK (((ends_on IS NULL) OR (ends_on >= starts_on))),
    CONSTRAINT recurrence_positive CHECK (((recurrence_interval > 0) AND (duration_minutes > 0))),
    CONSTRAINT recurrence_weekdays CHECK ((((frequency = 'Daily'::public.recurrence_frequency) AND (COALESCE(cardinality(weekdays), 0) = 0)) OR ((frequency = 'Weekly'::public.recurrence_frequency) AND (weekdays IS NOT NULL) AND ((cardinality(weekdays) >= 1) AND (cardinality(weekdays) <= 7)) AND (weekdays <@ ARRAY[(1)::smallint, (2)::smallint, (3)::smallint, (4)::smallint, (5)::smallint, (6)::smallint, (7)::smallint]))))
);


--
-- Name: reservation_claim; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reservation_claim (
    id uuid NOT NULL,
    operation_id uuid NOT NULL,
    lesson_id uuid,
    assessment_appointment_id uuid,
    school_id uuid NOT NULL,
    resource_kind character varying(24) NOT NULL,
    resource_key uuid NOT NULL,
    starts_at timestamp with time zone NOT NULL,
    ends_at timestamp with time zone NOT NULL,
    status public.reservation_status DEFAULT 'Active'::public.reservation_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    released_at timestamp with time zone,
    CONSTRAINT claim_interval CHECK ((ends_at > starts_at)),
    CONSTRAINT claim_kind CHECK (((resource_kind)::text = ANY ((ARRAY['Student'::character varying, 'Instructor'::character varying, 'Vehicle'::character varying, 'Group'::character varying])::text[]))),
    CONSTRAINT claim_owner CHECK (((((lesson_id IS NOT NULL))::integer + ((assessment_appointment_id IS NOT NULL))::integer) = 1)),
    CONSTRAINT claim_release CHECK ((((status = 'Active'::public.reservation_status) AND (released_at IS NULL)) OR ((status = 'Released'::public.reservation_status) AND (released_at IS NOT NULL) AND (released_at >= created_at))))
);


--
-- Name: scheduling_operation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scheduling_operation (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    action_type character varying(32) NOT NULL,
    request_id uuid,
    request_revision integer,
    actor_user_id uuid NOT NULL,
    channel character varying(16) NOT NULL,
    reason character varying(500),
    status public.operation_status DEFAULT 'Pending'::public.operation_status NOT NULL,
    started_at timestamp with time zone NOT NULL,
    finished_at timestamp with time zone,
    target_lesson_id uuid,
    expected_lesson_revision integer,
    target_appointment_id uuid,
    result_lesson_id uuid,
    result_appointment_id uuid,
    outcome_code character varying(64),
    user_confirmed_at timestamp with time zone,
    fingerprint character varying(64) DEFAULT ''::character varying NOT NULL,
    result_json text DEFAULT ''::text NOT NULL,
    http_status integer DEFAULT 0 NOT NULL,
    CONSTRAINT operation_action CHECK (((action_type)::text = ANY ((ARRAY['ConfirmSchedule'::character varying, 'CreateLesson'::character varying, 'Reschedule'::character varying, 'Cancel'::character varying, 'ChangeGroup'::character varying, 'CompleteLesson'::character varying, 'CorrectActualInterval'::character varying, 'CreateAssessment'::character varying, 'CancelAssessment'::character varying, 'CreateDraft'::character varying, 'ReviseDraft'::character varying, 'SubmitRequest'::character varying, 'GenerateProposal'::character varying, 'PublishRule'::character varying])::text[]))),
    CONSTRAINT operation_channel CHECK (((channel)::text = ANY ((ARRAY['Web'::character varying, 'MCP'::character varying, 'Internal'::character varying])::text[]))),
    CONSTRAINT operation_expected_revision CHECK (((expected_lesson_revision IS NULL) OR (expected_lesson_revision > 0))),
    CONSTRAINT operation_finished CHECK ((((status = 'Pending'::public.operation_status) AND (finished_at IS NULL)) OR (status = 'ReconciliationPending'::public.operation_status) OR ((status = ANY (ARRAY['Committed'::public.operation_status, 'Rejected'::public.operation_status])) AND (finished_at IS NOT NULL)))),
    CONSTRAINT operation_request_pair CHECK (((request_id IS NULL) = (request_revision IS NULL))),
    CONSTRAINT operation_target_xor CHECK (((target_lesson_id IS NULL) OR (target_appointment_id IS NULL)))
);


--
-- Name: scheduling_operation_rule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scheduling_operation_rule (
    operation_id uuid NOT NULL,
    rule_version_id uuid NOT NULL
);


--
-- Name: scheduling_request; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scheduling_request (
    id uuid NOT NULL,
    revision integer NOT NULL,
    school_id uuid NOT NULL,
    status public.request_status DEFAULT 'Draft'::public.request_status NOT NULL,
    planning_start date,
    planning_end date,
    submitted_by_user_id uuid,
    submitted_at timestamp with time zone,
    generated_at timestamp with time zone,
    confirmed_operation_id uuid,
    confirmed_at timestamp with time zone,
    created_by_user_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    inputs_json text DEFAULT '{}'::text NOT NULL,
    basis_json text DEFAULT ''::text NOT NULL,
    school_revision bigint DEFAULT 0 NOT NULL,
    CONSTRAINT request_confirmed_metadata CHECK ((((status = 'Confirmed'::public.request_status) AND (confirmed_at IS NOT NULL) AND (confirmed_operation_id IS NOT NULL)) OR ((status <> 'Confirmed'::public.request_status) AND (confirmed_at IS NULL) AND (confirmed_operation_id IS NULL)))),
    CONSTRAINT request_period CHECK (((planning_start IS NULL) OR (planning_end IS NULL) OR (planning_end >= planning_start))),
    CONSTRAINT request_ready_metadata CHECK (((status <> ALL (ARRAY['Ready'::public.request_status, 'Confirmed'::public.request_status])) OR (generated_at IS NOT NULL))),
    CONSTRAINT request_revision_positive CHECK ((revision > 0)),
    CONSTRAINT request_submitted_pair CHECK (((submitted_at IS NULL) = (submitted_by_user_id IS NULL))),
    CONSTRAINT request_validated_metadata CHECK (((status <> ALL (ARRAY['Submitted'::public.request_status, 'Ready'::public.request_status, 'Infeasible'::public.request_status, 'Stale'::public.request_status, 'Superseded'::public.request_status, 'Confirmed'::public.request_status])) OR ((submitted_at IS NOT NULL) AND (planning_start IS NOT NULL) AND (planning_end IS NOT NULL))))
);


--
-- Name: scheduling_request_enrollment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scheduling_request_enrollment (
    request_id uuid NOT NULL,
    request_revision integer NOT NULL,
    enrollment_id uuid NOT NULL,
    student_id uuid,
    enrollment_revision bigint,
    training_program_version_id uuid,
    category_code character varying(16),
    CONSTRAINT scheduling_request_enrollment_revision CHECK ((request_revision > 0))
);


--
-- Name: scheduling_request_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scheduling_request_group (
    request_id uuid NOT NULL,
    request_revision integer NOT NULL,
    group_id uuid NOT NULL,
    training_program_version_id uuid,
    category_code character varying(16),
    membership_revision bigint,
    CONSTRAINT scheduling_request_group_revision CHECK ((request_revision > 0))
);


--
-- Name: scheduling_request_resource; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scheduling_request_resource (
    request_id uuid NOT NULL,
    request_revision integer NOT NULL,
    resource_kind character varying(24) NOT NULL,
    resource_id uuid NOT NULL,
    eligibility_revision bigint,
    CONSTRAINT resource_kind_valid CHECK (((resource_kind)::text = ANY ((ARRAY['Instructor'::character varying, 'Vehicle'::character varying, 'Branch'::character varying])::text[]))),
    CONSTRAINT resource_source_revision CHECK (((eligibility_revision IS NULL) OR (eligibility_revision > 0))),
    CONSTRAINT scheduling_request_resource_revision CHECK ((request_revision > 0))
);


--
-- Name: scheduling_request_rule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scheduling_request_rule (
    request_id uuid NOT NULL,
    request_revision integer NOT NULL,
    rule_version_id uuid NOT NULL,
    CONSTRAINT scheduling_request_rule_revision CHECK ((request_revision > 0))
);


--
-- Name: scheduling_request_window; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scheduling_request_window (
    id uuid NOT NULL,
    request_id uuid NOT NULL,
    request_revision integer NOT NULL,
    starts_at timestamp with time zone NOT NULL,
    ends_at timestamp with time zone NOT NULL,
    CONSTRAINT window_interval CHECK ((ends_at > starts_at))
);


--
-- Name: scheduling_rule_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scheduling_rule_version (
    id uuid NOT NULL,
    rule_id uuid NOT NULL,
    revision integer NOT NULL,
    source_kind character varying(16) NOT NULL,
    school_id uuid,
    category_code character varying(16),
    rule_code character varying(80) NOT NULL,
    severity character varying(16) NOT NULL,
    override_policy character varying(24) NOT NULL,
    scope_kind character varying(24) NOT NULL,
    scope_resource_id uuid,
    decision_reason character varying(500),
    numeric_limit numeric(12,3),
    unit character varying(32),
    effective_from timestamp with time zone NOT NULL,
    effective_to timestamp with time zone,
    source_reference character varying(400) NOT NULL,
    verification_status character varying(24) NOT NULL,
    decided_at timestamp with time zone,
    created_by_user_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    decided_by_user_id uuid,
    CONSTRAINT rule_decision_actor CHECK (((((verification_status)::text = 'Pending'::text) AND (decided_at IS NULL) AND (decided_by_user_id IS NULL)) OR (((verification_status)::text = ANY ((ARRAY['Verified'::character varying, 'Rejected'::character varying])::text[])) AND (decided_at IS NOT NULL) AND (decided_by_user_id IS NOT NULL)))),
    CONSTRAINT rule_effective_interval CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT rule_override_policy CHECK ((((override_policy)::text = ANY ((ARRAY['Locked'::character varying, 'SchoolEditable'::character varying])::text[])) AND ((((source_kind)::text = 'Legal'::text) AND ((override_policy)::text = 'Locked'::text)) OR (((source_kind)::text = 'School'::text) AND ((override_policy)::text = 'SchoolEditable'::text))))),
    CONSTRAINT rule_revision CHECK ((revision > 0)),
    CONSTRAINT rule_school_scope CHECK (((((source_kind)::text = 'Legal'::text) AND (school_id IS NULL)) OR (((source_kind)::text = 'School'::text) AND (school_id IS NOT NULL)))),
    CONSTRAINT rule_scope CHECK ((((scope_kind)::text = ANY ((ARRAY['School'::character varying, 'Instructor'::character varying, 'Vehicle'::character varying, 'Branch'::character varying, 'Group'::character varying, 'Student'::character varying])::text[])) AND ((((scope_kind)::text = 'School'::text) AND (scope_resource_id IS NULL)) OR (((scope_kind)::text <> 'School'::text) AND (scope_resource_id IS NOT NULL))))),
    CONSTRAINT rule_severity CHECK ((((severity)::text = ANY ((ARRAY['Hard'::character varying, 'Preference'::character varying])::text[])) AND (((source_kind)::text <> 'Legal'::text) OR ((severity)::text = 'Hard'::text)))),
    CONSTRAINT rule_source_kind CHECK (((source_kind)::text = ANY ((ARRAY['Legal'::character varying, 'School'::character varying])::text[]))),
    CONSTRAINT rule_typed_limit CHECK ((((numeric_limit IS NULL) AND (unit IS NULL)) OR ((numeric_limit > (0)::numeric) AND (unit IS NOT NULL)))),
    CONSTRAINT rule_verification CHECK (((verification_status)::text = ANY ((ARRAY['Verified'::character varying, 'Pending'::character varying, 'Rejected'::character varying])::text[])))
);


--
-- Name: school_barrier; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.school_barrier (
    school_id uuid NOT NULL,
    revision_floor bigint NOT NULL,
    pending_operation_id uuid
);


--
-- Name: school_transition; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.school_transition (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    before_revision bigint NOT NULL,
    after_revision bigint NOT NULL,
    fingerprint text NOT NULL,
    payload_json text NOT NULL,
    status text NOT NULL,
    created_at timestamp with time zone NOT NULL
);


--
-- Name: vehicle_block; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehicle_block (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    vehicle_id uuid NOT NULL,
    operation_id uuid NOT NULL,
    reason text NOT NULL,
    status text NOT NULL,
    created_at timestamp with time zone NOT NULL
);


--
-- Name: vehicle_guard; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehicle_guard (
    vehicle_id uuid NOT NULL,
    school_id uuid NOT NULL
);


--
-- Name: assessment_appointment AK_assessment_appointment_id_school_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_appointment
    ADD CONSTRAINT "AK_assessment_appointment_id_school_id" UNIQUE (id, school_id);


--
-- Name: candidate_lesson AK_candidate_lesson_id_request_id_request_revision; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.candidate_lesson
    ADD CONSTRAINT "AK_candidate_lesson_id_request_id_request_revision" UNIQUE (id, request_id, request_revision);


--
-- Name: lesson AK_lesson_id_school_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson
    ADD CONSTRAINT "AK_lesson_id_school_id" UNIQUE (id, school_id);


--
-- Name: recurring_lesson_series AK_recurring_lesson_series_id_school_id_kind; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurring_lesson_series
    ADD CONSTRAINT "AK_recurring_lesson_series_id_school_id_kind" UNIQUE (id, school_id, kind);


--
-- Name: scheduling_operation AK_scheduling_operation_id_school_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduling_operation
    ADD CONSTRAINT "AK_scheduling_operation_id_school_id" UNIQUE (id, school_id);


--
-- Name: scheduling_request AK_scheduling_request_id_revision_school_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduling_request
    ADD CONSTRAINT "AK_scheduling_request_id_revision_school_id" UNIQUE (id, revision, school_id);


--
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- Name: assessment_appointment PK_assessment_appointment; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_appointment
    ADD CONSTRAINT "PK_assessment_appointment" PRIMARY KEY (id);


--
-- Name: candidate_lesson PK_candidate_lesson; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.candidate_lesson
    ADD CONSTRAINT "PK_candidate_lesson" PRIMARY KEY (id);


--
-- Name: candidate_lesson_participant PK_candidate_lesson_participant; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.candidate_lesson_participant
    ADD CONSTRAINT "PK_candidate_lesson_participant" PRIMARY KEY (candidate_lesson_id, enrollment_id);


--
-- Name: gate_command PK_gate_command; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gate_command
    ADD CONSTRAINT "PK_gate_command" PRIMARY KEY (id);


--
-- Name: integration_inbox PK_integration_inbox; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integration_inbox
    ADD CONSTRAINT "PK_integration_inbox" PRIMARY KEY (event_id);


--
-- Name: lesson PK_lesson; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson
    ADD CONSTRAINT "PK_lesson" PRIMARY KEY (id);


--
-- Name: lesson_change PK_lesson_change; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson_change
    ADD CONSTRAINT "PK_lesson_change" PRIMARY KEY (id);


--
-- Name: lesson_participant PK_lesson_participant; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson_participant
    ADD CONSTRAINT "PK_lesson_participant" PRIMARY KEY (lesson_id, enrollment_id);


--
-- Name: lesson_review PK_lesson_review; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson_review
    ADD CONSTRAINT "PK_lesson_review" PRIMARY KEY (id);


--
-- Name: outbox_message PK_outbox_message; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_message
    ADD CONSTRAINT "PK_outbox_message" PRIMARY KEY (id);


--
-- Name: recurring_lesson_series PK_recurring_lesson_series; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurring_lesson_series
    ADD CONSTRAINT "PK_recurring_lesson_series" PRIMARY KEY (id);


--
-- Name: reservation_claim PK_reservation_claim; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reservation_claim
    ADD CONSTRAINT "PK_reservation_claim" PRIMARY KEY (id);


--
-- Name: scheduling_operation PK_scheduling_operation; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduling_operation
    ADD CONSTRAINT "PK_scheduling_operation" PRIMARY KEY (id);


--
-- Name: scheduling_operation_rule PK_scheduling_operation_rule; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduling_operation_rule
    ADD CONSTRAINT "PK_scheduling_operation_rule" PRIMARY KEY (operation_id, rule_version_id);


--
-- Name: scheduling_request PK_scheduling_request; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduling_request
    ADD CONSTRAINT "PK_scheduling_request" PRIMARY KEY (id, revision);


--
-- Name: scheduling_request_enrollment PK_scheduling_request_enrollment; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduling_request_enrollment
    ADD CONSTRAINT "PK_scheduling_request_enrollment" PRIMARY KEY (request_id, request_revision, enrollment_id);


--
-- Name: scheduling_request_group PK_scheduling_request_group; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduling_request_group
    ADD CONSTRAINT "PK_scheduling_request_group" PRIMARY KEY (request_id, request_revision, group_id);


--
-- Name: scheduling_request_resource PK_scheduling_request_resource; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduling_request_resource
    ADD CONSTRAINT "PK_scheduling_request_resource" PRIMARY KEY (request_id, request_revision, resource_kind, resource_id);


--
-- Name: scheduling_request_rule PK_scheduling_request_rule; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduling_request_rule
    ADD CONSTRAINT "PK_scheduling_request_rule" PRIMARY KEY (request_id, request_revision, rule_version_id);


--
-- Name: scheduling_request_window PK_scheduling_request_window; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduling_request_window
    ADD CONSTRAINT "PK_scheduling_request_window" PRIMARY KEY (id);


--
-- Name: scheduling_rule_version PK_scheduling_rule_version; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduling_rule_version
    ADD CONSTRAINT "PK_scheduling_rule_version" PRIMARY KEY (id);


--
-- Name: school_barrier PK_school_barrier; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school_barrier
    ADD CONSTRAINT "PK_school_barrier" PRIMARY KEY (school_id);


--
-- Name: school_transition PK_school_transition; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school_transition
    ADD CONSTRAINT "PK_school_transition" PRIMARY KEY (id);


--
-- Name: vehicle_block PK_vehicle_block; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_block
    ADD CONSTRAINT "PK_vehicle_block" PRIMARY KEY (id);


--
-- Name: vehicle_guard PK_vehicle_guard; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_guard
    ADD CONSTRAINT "PK_vehicle_guard" PRIMARY KEY (vehicle_id);


--
-- Name: reservation_claim active_resource_no_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reservation_claim
    ADD CONSTRAINT active_resource_no_overlap EXCLUDE USING gist (resource_kind WITH =, resource_key WITH =, tstzrange(starts_at, ends_at, '[)'::text) WITH &&) WHERE ((status = 'Active'::public.reservation_status));


--
-- Name: scheduling_request request_single_school; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduling_request
    ADD CONSTRAINT request_single_school EXCLUDE USING gist (id WITH =, school_id WITH <>);


--
-- Name: IX_candidate_lesson_participant_candidate_lesson_id_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_candidate_lesson_participant_candidate_lesson_id_student_id" ON public.candidate_lesson_participant USING btree (candidate_lesson_id, student_id);


--
-- Name: IX_candidate_lesson_request_id_request_revision; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_candidate_lesson_request_id_request_revision" ON public.candidate_lesson USING btree (request_id, request_revision);


--
-- Name: IX_candidate_lesson_series_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_candidate_lesson_series_id" ON public.candidate_lesson USING btree (series_id);


--
-- Name: IX_lesson_change_lesson_id_revision; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_lesson_change_lesson_id_revision" ON public.lesson_change USING btree (lesson_id, revision);


--
-- Name: IX_lesson_change_lesson_id_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_lesson_change_lesson_id_school_id" ON public.lesson_change USING btree (lesson_id, school_id);


--
-- Name: IX_lesson_change_operation_id_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_lesson_change_operation_id_school_id" ON public.lesson_change USING btree (operation_id, school_id);


--
-- Name: IX_lesson_participant_lesson_id_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_lesson_participant_lesson_id_student_id" ON public.lesson_participant USING btree (lesson_id, student_id);


--
-- Name: IX_lesson_review_school_id_resolved_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_lesson_review_school_id_resolved_at" ON public.lesson_review USING btree (school_id, resolved_at);


--
-- Name: IX_lesson_review_source_event_id_target_kind_target_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_lesson_review_source_event_id_target_kind_target_id" ON public.lesson_review USING btree (source_event_id, target_kind, target_id);


--
-- Name: IX_lesson_school_id_starts_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_lesson_school_id_starts_at" ON public.lesson USING btree (school_id, starts_at);


--
-- Name: IX_lesson_series_id_school_id_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_lesson_series_id_school_id_kind" ON public.lesson USING btree (series_id, school_id, kind);


--
-- Name: IX_lesson_source_candidate_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_lesson_source_candidate_id" ON public.lesson USING btree (source_candidate_id);


--
-- Name: IX_lesson_teacher_id_starts_at_ends_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_lesson_teacher_id_starts_at_ends_at" ON public.lesson USING btree (teacher_id, starts_at, ends_at);


--
-- Name: IX_outbox_message_published_at_available_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_outbox_message_published_at_available_at" ON public.outbox_message USING btree (published_at, available_at);


--
-- Name: IX_reservation_claim_assessment_appointment_id_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_reservation_claim_assessment_appointment_id_school_id" ON public.reservation_claim USING btree (assessment_appointment_id, school_id);


--
-- Name: IX_reservation_claim_lesson_id_resource_kind_resource_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_reservation_claim_lesson_id_resource_kind_resource_key" ON public.reservation_claim USING btree (lesson_id, resource_kind, resource_key);


--
-- Name: IX_reservation_claim_lesson_id_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_reservation_claim_lesson_id_school_id" ON public.reservation_claim USING btree (lesson_id, school_id);


--
-- Name: IX_reservation_claim_operation_id_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_reservation_claim_operation_id_school_id" ON public.reservation_claim USING btree (operation_id, school_id);


--
-- Name: IX_reservation_claim_resource_kind_resource_key_starts_at_ends~; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_reservation_claim_resource_kind_resource_key_starts_at_ends~" ON public.reservation_claim USING btree (resource_kind, resource_key, starts_at, ends_at);


--
-- Name: IX_scheduling_operation_request_id_request_revision_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_scheduling_operation_request_id_request_revision_school_id" ON public.scheduling_operation USING btree (request_id, request_revision, school_id);


--
-- Name: IX_scheduling_operation_result_appointment_id_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_scheduling_operation_result_appointment_id_school_id" ON public.scheduling_operation USING btree (result_appointment_id, school_id);


--
-- Name: IX_scheduling_operation_result_lesson_id_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_scheduling_operation_result_lesson_id_school_id" ON public.scheduling_operation USING btree (result_lesson_id, school_id);


--
-- Name: IX_scheduling_operation_rule_rule_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_scheduling_operation_rule_rule_version_id" ON public.scheduling_operation_rule USING btree (rule_version_id);


--
-- Name: IX_scheduling_operation_target_appointment_id_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_scheduling_operation_target_appointment_id_school_id" ON public.scheduling_operation USING btree (target_appointment_id, school_id);


--
-- Name: IX_scheduling_operation_target_lesson_id_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_scheduling_operation_target_lesson_id_school_id" ON public.scheduling_operation USING btree (target_lesson_id, school_id);


--
-- Name: IX_scheduling_request_confirmed_operation_id_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_scheduling_request_confirmed_operation_id_school_id" ON public.scheduling_request USING btree (confirmed_operation_id, school_id);


--
-- Name: IX_scheduling_request_rule_rule_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_scheduling_request_rule_rule_version_id" ON public.scheduling_request_rule USING btree (rule_version_id);


--
-- Name: IX_scheduling_request_school_id_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_scheduling_request_school_id_status" ON public.scheduling_request USING btree (school_id, status);


--
-- Name: IX_scheduling_request_window_request_id_request_revision; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_scheduling_request_window_request_id_request_revision" ON public.scheduling_request_window USING btree (request_id, request_revision);


--
-- Name: IX_scheduling_rule_version_rule_id_revision; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_scheduling_rule_version_rule_id_revision" ON public.scheduling_rule_version USING btree (rule_id, revision);


--
-- Name: IX_scheduling_rule_version_source_kind_school_id_rule_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_scheduling_rule_version_source_kind_school_id_rule_code" ON public.scheduling_rule_version USING btree (source_kind, school_id, rule_code);


--
-- Name: IX_school_transition_school_id_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_school_transition_school_id_status" ON public.school_transition USING btree (school_id, status);


--
-- Name: IX_vehicle_block_vehicle_id_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_vehicle_block_vehicle_id_status" ON public.vehicle_block USING btree (vehicle_id, status);


--
-- Name: candidate_lesson candidate_immutable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER candidate_immutable BEFORE DELETE OR UPDATE ON public.candidate_lesson FOR EACH ROW EXECUTE FUNCTION public.scheduling_immutable();


--
-- Name: candidate_lesson_participant candidate_roster_immutable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER candidate_roster_immutable BEFORE DELETE OR UPDATE ON public.candidate_lesson_participant FOR EACH ROW EXECUTE FUNCTION public.scheduling_immutable();


--
-- Name: gate_command gate_command_immutable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER gate_command_immutable BEFORE DELETE OR UPDATE ON public.gate_command FOR EACH ROW EXECUTE FUNCTION public.scheduling_immutable();


--
-- Name: lesson_change history_immutable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER history_immutable BEFORE DELETE OR UPDATE ON public.lesson_change FOR EACH ROW EXECUTE FUNCTION public.scheduling_immutable();


--
-- Name: integration_inbox integration_inbox_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER integration_inbox_guard BEFORE DELETE OR UPDATE ON public.integration_inbox FOR EACH ROW EXECUTE FUNCTION public.integration_inbox_guard();


--
-- Name: lesson_review lesson_review_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER lesson_review_guard BEFORE DELETE OR UPDATE ON public.lesson_review FOR EACH ROW EXECUTE FUNCTION public.lesson_review_guard();


--
-- Name: scheduling_operation operation_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER operation_guard BEFORE UPDATE ON public.scheduling_operation FOR EACH ROW EXECUTE FUNCTION public.scheduling_operation_guard();


--
-- Name: scheduling_request request_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER request_guard BEFORE UPDATE ON public.scheduling_request FOR EACH ROW EXECUTE FUNCTION public.scheduling_request_guard();


--
-- Name: scheduling_operation_rule rule_evidence_immutable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER rule_evidence_immutable BEFORE DELETE OR UPDATE ON public.scheduling_operation_rule FOR EACH ROW EXECUTE FUNCTION public.scheduling_immutable();


--
-- Name: scheduling_rule_version rule_immutable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER rule_immutable BEFORE DELETE OR UPDATE ON public.scheduling_rule_version FOR EACH ROW EXECUTE FUNCTION public.scheduling_immutable();


--
-- Name: candidate_lesson_participant FK_candidate_lesson_participant_candidate_lesson_candidate_les~; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.candidate_lesson_participant
    ADD CONSTRAINT "FK_candidate_lesson_participant_candidate_lesson_candidate_les~" FOREIGN KEY (candidate_lesson_id) REFERENCES public.candidate_lesson(id) ON DELETE RESTRICT;


--
-- Name: candidate_lesson FK_candidate_lesson_recurring_lesson_series_series_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.candidate_lesson
    ADD CONSTRAINT "FK_candidate_lesson_recurring_lesson_series_series_id" FOREIGN KEY (series_id) REFERENCES public.recurring_lesson_series(id) ON DELETE RESTRICT;


--
-- Name: candidate_lesson FK_candidate_lesson_scheduling_request_request_id_request_revi~; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.candidate_lesson
    ADD CONSTRAINT "FK_candidate_lesson_scheduling_request_request_id_request_revi~" FOREIGN KEY (request_id, request_revision) REFERENCES public.scheduling_request(id, revision) ON DELETE RESTRICT;


--
-- Name: lesson FK_lesson_candidate_lesson_source_candidate_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson
    ADD CONSTRAINT "FK_lesson_candidate_lesson_source_candidate_id" FOREIGN KEY (source_candidate_id) REFERENCES public.candidate_lesson(id) ON DELETE RESTRICT;


--
-- Name: lesson_change FK_lesson_change_lesson_lesson_id_school_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson_change
    ADD CONSTRAINT "FK_lesson_change_lesson_lesson_id_school_id" FOREIGN KEY (lesson_id, school_id) REFERENCES public.lesson(id, school_id) ON DELETE RESTRICT;


--
-- Name: lesson_change FK_lesson_change_scheduling_operation_operation_id_school_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson_change
    ADD CONSTRAINT "FK_lesson_change_scheduling_operation_operation_id_school_id" FOREIGN KEY (operation_id, school_id) REFERENCES public.scheduling_operation(id, school_id) ON DELETE RESTRICT;


--
-- Name: lesson_participant FK_lesson_participant_lesson_lesson_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson_participant
    ADD CONSTRAINT "FK_lesson_participant_lesson_lesson_id" FOREIGN KEY (lesson_id) REFERENCES public.lesson(id) ON DELETE RESTRICT;


--
-- Name: lesson FK_lesson_recurring_lesson_series_series_id_school_id_kind; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson
    ADD CONSTRAINT "FK_lesson_recurring_lesson_series_series_id_school_id_kind" FOREIGN KEY (series_id, school_id, kind) REFERENCES public.recurring_lesson_series(id, school_id, kind) ON DELETE RESTRICT;


--
-- Name: reservation_claim FK_reservation_claim_assessment_appointment_assessment_appoint~; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reservation_claim
    ADD CONSTRAINT "FK_reservation_claim_assessment_appointment_assessment_appoint~" FOREIGN KEY (assessment_appointment_id, school_id) REFERENCES public.assessment_appointment(id, school_id) ON DELETE RESTRICT;


--
-- Name: reservation_claim FK_reservation_claim_lesson_lesson_id_school_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reservation_claim
    ADD CONSTRAINT "FK_reservation_claim_lesson_lesson_id_school_id" FOREIGN KEY (lesson_id, school_id) REFERENCES public.lesson(id, school_id) ON DELETE RESTRICT;


--
-- Name: reservation_claim FK_reservation_claim_scheduling_operation_operation_id_school_~; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reservation_claim
    ADD CONSTRAINT "FK_reservation_claim_scheduling_operation_operation_id_school_~" FOREIGN KEY (operation_id, school_id) REFERENCES public.scheduling_operation(id, school_id) ON DELETE RESTRICT;


--
-- Name: scheduling_operation FK_scheduling_operation_assessment_appointment_result_appointm~; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduling_operation
    ADD CONSTRAINT "FK_scheduling_operation_assessment_appointment_result_appointm~" FOREIGN KEY (result_appointment_id, school_id) REFERENCES public.assessment_appointment(id, school_id) ON DELETE RESTRICT;


--
-- Name: scheduling_operation FK_scheduling_operation_assessment_appointment_target_appointm~; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduling_operation
    ADD CONSTRAINT "FK_scheduling_operation_assessment_appointment_target_appointm~" FOREIGN KEY (target_appointment_id, school_id) REFERENCES public.assessment_appointment(id, school_id) ON DELETE RESTRICT;


--
-- Name: scheduling_operation FK_scheduling_operation_lesson_result_lesson_id_school_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduling_operation
    ADD CONSTRAINT "FK_scheduling_operation_lesson_result_lesson_id_school_id" FOREIGN KEY (result_lesson_id, school_id) REFERENCES public.lesson(id, school_id) ON DELETE RESTRICT;


--
-- Name: scheduling_operation FK_scheduling_operation_lesson_target_lesson_id_school_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduling_operation
    ADD CONSTRAINT "FK_scheduling_operation_lesson_target_lesson_id_school_id" FOREIGN KEY (target_lesson_id, school_id) REFERENCES public.lesson(id, school_id) ON DELETE RESTRICT;


--
-- Name: scheduling_operation_rule FK_scheduling_operation_rule_scheduling_operation_operation_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduling_operation_rule
    ADD CONSTRAINT "FK_scheduling_operation_rule_scheduling_operation_operation_id" FOREIGN KEY (operation_id) REFERENCES public.scheduling_operation(id) ON DELETE RESTRICT;


--
-- Name: scheduling_operation_rule FK_scheduling_operation_rule_scheduling_rule_version_rule_vers~; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduling_operation_rule
    ADD CONSTRAINT "FK_scheduling_operation_rule_scheduling_rule_version_rule_vers~" FOREIGN KEY (rule_version_id) REFERENCES public.scheduling_rule_version(id) ON DELETE RESTRICT;


--
-- Name: scheduling_operation FK_scheduling_operation_scheduling_request_request_id_request_~; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduling_operation
    ADD CONSTRAINT "FK_scheduling_operation_scheduling_request_request_id_request_~" FOREIGN KEY (request_id, request_revision, school_id) REFERENCES public.scheduling_request(id, revision, school_id) ON DELETE RESTRICT;


--
-- Name: scheduling_request_enrollment FK_scheduling_request_enrollment_scheduling_request_request_id~; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduling_request_enrollment
    ADD CONSTRAINT "FK_scheduling_request_enrollment_scheduling_request_request_id~" FOREIGN KEY (request_id, request_revision) REFERENCES public.scheduling_request(id, revision) ON DELETE RESTRICT;


--
-- Name: scheduling_request_group FK_scheduling_request_group_scheduling_request_request_id_requ~; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduling_request_group
    ADD CONSTRAINT "FK_scheduling_request_group_scheduling_request_request_id_requ~" FOREIGN KEY (request_id, request_revision) REFERENCES public.scheduling_request(id, revision) ON DELETE RESTRICT;


--
-- Name: scheduling_request_resource FK_scheduling_request_resource_scheduling_request_request_id_r~; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduling_request_resource
    ADD CONSTRAINT "FK_scheduling_request_resource_scheduling_request_request_id_r~" FOREIGN KEY (request_id, request_revision) REFERENCES public.scheduling_request(id, revision) ON DELETE RESTRICT;


--
-- Name: scheduling_request_rule FK_scheduling_request_rule_scheduling_request_request_id_reque~; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduling_request_rule
    ADD CONSTRAINT "FK_scheduling_request_rule_scheduling_request_request_id_reque~" FOREIGN KEY (request_id, request_revision) REFERENCES public.scheduling_request(id, revision) ON DELETE RESTRICT;


--
-- Name: scheduling_request_rule FK_scheduling_request_rule_scheduling_rule_version_rule_versio~; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduling_request_rule
    ADD CONSTRAINT "FK_scheduling_request_rule_scheduling_rule_version_rule_versio~" FOREIGN KEY (rule_version_id) REFERENCES public.scheduling_rule_version(id) ON DELETE RESTRICT;


--
-- Name: scheduling_request FK_scheduling_request_scheduling_operation_confirmed_operation~; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduling_request
    ADD CONSTRAINT "FK_scheduling_request_scheduling_operation_confirmed_operation~" FOREIGN KEY (confirmed_operation_id, school_id) REFERENCES public.scheduling_operation(id, school_id) ON DELETE RESTRICT;


--
-- Name: scheduling_request_window FK_scheduling_request_window_scheduling_request_request_id_req~; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduling_request_window
    ADD CONSTRAINT "FK_scheduling_request_window_scheduling_request_request_id_req~" FOREIGN KEY (request_id, request_revision) REFERENCES public.scheduling_request(id, revision) ON DELETE RESTRICT;


--
-- Name: assessment_appointment; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.assessment_appointment ENABLE ROW LEVEL SECURITY;

--
-- Name: candidate_lesson; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.candidate_lesson ENABLE ROW LEVEL SECURITY;

--
-- Name: candidate_lesson_participant; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.candidate_lesson_participant ENABLE ROW LEVEL SECURITY;

--
-- Name: gate_command; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.gate_command ENABLE ROW LEVEL SECURITY;

--
-- Name: lesson; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.lesson ENABLE ROW LEVEL SECURITY;

--
-- Name: lesson_change; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.lesson_change ENABLE ROW LEVEL SECURITY;

--
-- Name: lesson_participant; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.lesson_participant ENABLE ROW LEVEL SECURITY;

--
-- Name: lesson_review; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.lesson_review ENABLE ROW LEVEL SECURITY;

--
-- Name: outbox_message; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.outbox_message ENABLE ROW LEVEL SECURITY;

--
-- Name: outbox_message outbox_worker; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY outbox_worker ON public.outbox_message TO v_scheduling_outbox USING (true) WITH CHECK (true);


--
-- Name: recurring_lesson_series; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.recurring_lesson_series ENABLE ROW LEVEL SECURITY;

--
-- Name: reservation_claim; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.reservation_claim ENABLE ROW LEVEL SECURITY;

--
-- Name: assessment_appointment reservation_internal; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY reservation_internal ON public.assessment_appointment FOR SELECT TO v_scheduling_reservation_authority USING (true);


--
-- Name: lesson reservation_internal; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY reservation_internal ON public.lesson FOR SELECT TO v_scheduling_reservation_authority USING (true);


--
-- Name: lesson_participant reservation_internal; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY reservation_internal ON public.lesson_participant FOR SELECT TO v_scheduling_reservation_authority USING (true);


--
-- Name: reservation_claim reservation_internal; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY reservation_internal ON public.reservation_claim FOR SELECT TO v_scheduling_reservation_authority USING (true);


--
-- Name: scheduling_operation; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.scheduling_operation ENABLE ROW LEVEL SECURITY;

--
-- Name: scheduling_operation_rule; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.scheduling_operation_rule ENABLE ROW LEVEL SECURITY;

--
-- Name: scheduling_request; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.scheduling_request ENABLE ROW LEVEL SECURITY;

--
-- Name: scheduling_request_enrollment; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.scheduling_request_enrollment ENABLE ROW LEVEL SECURITY;

--
-- Name: scheduling_request_group; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.scheduling_request_group ENABLE ROW LEVEL SECURITY;

--
-- Name: scheduling_request_resource; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.scheduling_request_resource ENABLE ROW LEVEL SECURITY;

--
-- Name: scheduling_request_rule; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.scheduling_request_rule ENABLE ROW LEVEL SECURITY;

--
-- Name: scheduling_request_window; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.scheduling_request_window ENABLE ROW LEVEL SECURITY;

--
-- Name: scheduling_rule_version; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.scheduling_rule_version ENABLE ROW LEVEL SECURITY;

--
-- Name: school_barrier; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.school_barrier ENABLE ROW LEVEL SECURITY;

--
-- Name: school_transition; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.school_transition ENABLE ROW LEVEL SECURITY;

--
-- Name: assessment_appointment tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.assessment_appointment TO v_scheduling_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: candidate_lesson tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.candidate_lesson TO v_scheduling_runtime USING ((EXISTS ( SELECT 1
   FROM public.scheduling_request p
  WHERE ((p.id = candidate_lesson.request_id) AND (p.revision = candidate_lesson.request_revision) AND (p.school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.scheduling_request p
  WHERE ((p.id = candidate_lesson.request_id) AND (p.revision = candidate_lesson.request_revision) AND (p.school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)))));


--
-- Name: candidate_lesson_participant tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.candidate_lesson_participant TO v_scheduling_runtime USING ((EXISTS ( SELECT 1
   FROM public.candidate_lesson p
  WHERE ((p.id = candidate_lesson_participant.candidate_lesson_id) AND ((NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid IS NOT NULL))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.candidate_lesson p
  WHERE ((p.id = candidate_lesson_participant.candidate_lesson_id) AND ((NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid IS NOT NULL)))));


--
-- Name: gate_command tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.gate_command TO v_scheduling_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: lesson tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.lesson TO v_scheduling_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: lesson_change tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.lesson_change TO v_scheduling_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: lesson_participant tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.lesson_participant TO v_scheduling_runtime USING ((EXISTS ( SELECT 1
   FROM public.lesson p
  WHERE ((p.id = lesson_participant.lesson_id) AND (p.school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.lesson p
  WHERE ((p.id = lesson_participant.lesson_id) AND (p.school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)))));


--
-- Name: lesson_review tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.lesson_review TO v_scheduling_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: outbox_message tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.outbox_message TO v_scheduling_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: recurring_lesson_series tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.recurring_lesson_series TO v_scheduling_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: reservation_claim tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.reservation_claim TO v_scheduling_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: scheduling_operation tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.scheduling_operation TO v_scheduling_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: scheduling_operation_rule tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.scheduling_operation_rule TO v_scheduling_runtime USING ((EXISTS ( SELECT 1
   FROM public.scheduling_operation p
  WHERE ((p.id = scheduling_operation_rule.operation_id) AND (p.school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.scheduling_operation p
  WHERE ((p.id = scheduling_operation_rule.operation_id) AND (p.school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)))));


--
-- Name: scheduling_request tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.scheduling_request TO v_scheduling_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: scheduling_request_enrollment tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.scheduling_request_enrollment TO v_scheduling_runtime USING ((EXISTS ( SELECT 1
   FROM public.scheduling_request p
  WHERE ((p.id = scheduling_request_enrollment.request_id) AND (p.revision = scheduling_request_enrollment.request_revision) AND (p.school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.scheduling_request p
  WHERE ((p.id = scheduling_request_enrollment.request_id) AND (p.revision = scheduling_request_enrollment.request_revision) AND (p.school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)))));


--
-- Name: scheduling_request_group tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.scheduling_request_group TO v_scheduling_runtime USING ((EXISTS ( SELECT 1
   FROM public.scheduling_request p
  WHERE ((p.id = scheduling_request_group.request_id) AND (p.revision = scheduling_request_group.request_revision) AND (p.school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.scheduling_request p
  WHERE ((p.id = scheduling_request_group.request_id) AND (p.revision = scheduling_request_group.request_revision) AND (p.school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)))));


--
-- Name: scheduling_request_resource tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.scheduling_request_resource TO v_scheduling_runtime USING ((EXISTS ( SELECT 1
   FROM public.scheduling_request p
  WHERE ((p.id = scheduling_request_resource.request_id) AND (p.revision = scheduling_request_resource.request_revision) AND (p.school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.scheduling_request p
  WHERE ((p.id = scheduling_request_resource.request_id) AND (p.revision = scheduling_request_resource.request_revision) AND (p.school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)))));


--
-- Name: scheduling_request_rule tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.scheduling_request_rule TO v_scheduling_runtime USING ((EXISTS ( SELECT 1
   FROM public.scheduling_request p
  WHERE ((p.id = scheduling_request_rule.request_id) AND (p.revision = scheduling_request_rule.request_revision) AND (p.school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.scheduling_request p
  WHERE ((p.id = scheduling_request_rule.request_id) AND (p.revision = scheduling_request_rule.request_revision) AND (p.school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)))));


--
-- Name: scheduling_request_window tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.scheduling_request_window TO v_scheduling_runtime USING ((EXISTS ( SELECT 1
   FROM public.scheduling_request p
  WHERE ((p.id = scheduling_request_window.request_id) AND (p.revision = scheduling_request_window.request_revision) AND (p.school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.scheduling_request p
  WHERE ((p.id = scheduling_request_window.request_id) AND (p.revision = scheduling_request_window.request_revision) AND (p.school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)))));


--
-- Name: scheduling_rule_version tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.scheduling_rule_version TO v_scheduling_runtime USING ((((NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid IS NOT NULL) AND ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid) OR (school_id IS NULL)))) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: school_barrier tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.school_barrier TO v_scheduling_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: school_transition tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.school_transition TO v_scheduling_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: vehicle_block tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.vehicle_block TO v_scheduling_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: vehicle_guard tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.vehicle_guard TO v_scheduling_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: vehicle_block; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.vehicle_block ENABLE ROW LEVEL SECURITY;

--
-- Name: vehicle_guard; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.vehicle_guard ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--

\unrestrict 9XHVWQwmmbxV723c1j5RXaWiNCpEWYhyluZigmkw43nadfeihWZVHeaV2SvrkGM

