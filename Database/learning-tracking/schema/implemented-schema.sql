--
-- PostgreSQL database dump
--

\restrict w1KhA94qx2UnTXgX50X9LJjHHZibURfk3YX2L3HZJ7aTyA1mot6du7ggqhrVzva

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
-- Name: lt_assessment_stage; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.lt_assessment_stage AS ENUM (
    'Midterm',
    'Final'
);


--
-- Name: lt_attendance; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.lt_attendance AS ENUM (
    'Present',
    'Absent'
);


--
-- Name: lt_channel; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.lt_channel AS ENUM (
    'Web',
    'MCP',
    'Integration',
    'System'
);


--
-- Name: lt_check_outcome; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.lt_check_outcome AS ENUM (
    'Satisfied',
    'Unsatisfied',
    'Unverified'
);


--
-- Name: lt_check_scope; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.lt_check_scope AS ENUM (
    'Snapshot',
    'EvidenceItem'
);


--
-- Name: lt_decision; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.lt_decision AS ENUM (
    'Approved',
    'NotApproved'
);


--
-- Name: lt_evidence_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.lt_evidence_kind AS ENUM (
    'Journal',
    'CompletionReport'
);


--
-- Name: lt_evidence_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.lt_evidence_status AS ENUM (
    'Ready',
    'Incomplete'
);


--
-- Name: lt_formal_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.lt_formal_status AS ENUM (
    'Incomplete',
    'Satisfied',
    'Unverified'
);


--
-- Name: lt_freshness; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.lt_freshness AS ENUM (
    'Current',
    'ReconciliationPending',
    'Unavailable'
);


--
-- Name: lt_invalidation_scope; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.lt_invalidation_scope AS ENUM (
    'ProspectiveOnly',
    'HistoricalReviewRequired'
);


--
-- Name: lt_outcome; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.lt_outcome AS ENUM (
    'Passed',
    'Failed'
);


--
-- Name: lt_program_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.lt_program_status AS ENUM (
    'Draft',
    'Published',
    'Retired'
);


--
-- Name: lt_requirement_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.lt_requirement_kind AS ENUM (
    'MinimumTheoryMinutes',
    'MinimumPracticalMinutes',
    'AssessmentPassed',
    'MinimumMark'
);


--
-- Name: lt_response_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.lt_response_kind AS ENUM (
    'Confirm',
    'Dispute'
);


--
-- Name: lt_response_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.lt_response_role AS ENUM (
    'Instructor',
    'Student'
);


--
-- Name: lt_result_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.lt_result_status AS ENUM (
    'Recorded',
    'ReviewRequired',
    'Annulled'
);


--
-- Name: lt_training_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.lt_training_kind AS ENUM (
    'Theory',
    'Practical'
);


--
-- Name: lt_validation; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.lt_validation AS ENUM (
    'Incomplete',
    'Valid',
    'Invalid'
);


--
-- Name: lt_draft_content_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.lt_draft_content_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    DECLARE version_id uuid; current_status lt_program_status;
    BEGIN
     version_id := CASE WHEN TG_OP='DELETE' THEN OLD.program_version_id ELSE NEW.program_version_id END;
     SELECT status INTO current_status FROM training_program_version WHERE id=version_id FOR SHARE;
     IF current_status IS DISTINCT FROM 'Draft'::lt_program_status THEN RAISE EXCEPTION 'Published curriculum is immutable' USING ERRCODE='23514'; END IF;
     IF TG_OP='UPDATE' AND (OLD.school_id,OLD.program_version_id) IS DISTINCT FROM (NEW.school_id,NEW.program_version_id) THEN
      RAISE EXCEPTION 'Curriculum ownership is immutable' USING ERRCODE='23514';
     END IF;
     IF TG_OP='DELETE' THEN RETURN OLD; END IF;
     RETURN NEW;
    END $$;


--
-- Name: lt_evidence_ready_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.lt_evidence_ready_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    BEGIN
     IF NEW.status='Ready' AND (
      NOT EXISTS(SELECT 1 FROM training_evidence_check WHERE snapshot_id=NEW.id AND check_code='POLICY' AND outcome='Satisfied') OR
      NOT EXISTS(SELECT 1 FROM training_evidence_check WHERE snapshot_id=NEW.id AND check_code='SOURCES' AND outcome='Satisfied') OR
      EXISTS(SELECT 1 FROM training_evidence_check WHERE snapshot_id=NEW.id AND outcome<>'Satisfied') OR
      NEW.kind='CompletionReport' AND NOT EXISTS(SELECT 1 FROM training_evidence_check WHERE snapshot_id=NEW.id AND check_code='COMPLETION_ASSESSMENTS' AND outcome='Satisfied')
     ) THEN RAISE EXCEPTION 'Ready evidence lacks satisfied checks' USING ERRCODE='23514'; END IF;
     RETURN NEW;
    END $$;


--
-- Name: lt_program_identity_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.lt_program_identity_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    BEGIN
     IF (OLD.id,OLD.school_id) IS DISTINCT FROM (NEW.id,NEW.school_id) OR
      OLD.category_code IS DISTINCT FROM NEW.category_code AND EXISTS(SELECT 1 FROM training_program_version WHERE program_id=OLD.id AND status<>'Draft') THEN
      RAISE EXCEPTION 'Published programme identity is immutable' USING ERRCODE='23514';
     END IF;
     RETURN NEW;
    END $$;


--
-- Name: lt_program_version_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.lt_program_version_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    BEGIN
     IF TG_OP='DELETE' OR OLD.status='Retired' OR OLD.status='Published' AND
        (NEW.status<>'Retired' OR (to_jsonb(OLD)-ARRAY['status','retired_at']) IS DISTINCT FROM (to_jsonb(NEW)-ARRAY['status','retired_at'])) THEN
      RAISE EXCEPTION 'Published programme is immutable' USING ERRCODE='23514';
     END IF;
     RETURN NEW;
    END $$;


--
-- Name: lt_terminal_invalidation_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.lt_terminal_invalidation_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
BEGIN
 IF OLD.invalidated_at IS NOT NULL OR NEW.invalidated_at IS NULL OR
    (to_jsonb(OLD)-ARRAY['invalidated_at','invalidated_by','invalidation_reason','invalidation_dependency_revision','invalidation_scope','invalidation_effective_at']) IS DISTINCT FROM
    (to_jsonb(NEW)-ARRAY['invalidated_at','invalidated_by','invalidation_reason','invalidation_dependency_revision','invalidation_scope','invalidation_effective_at']) THEN
  RAISE EXCEPTION 'Readiness decision is immutable except one-time terminal invalidation';
 END IF;
 RETURN NEW;
END $$;


--
-- Name: lt_theory_confirmation_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.lt_theory_confirmation_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    BEGIN
     IF OLD.confirmed_at IS NOT NULL OR NEW.confirmed_at IS NULL OR NEW.confirmed_by IS NULL OR
     (to_jsonb(OLD)-ARRAY['confirmed_by','confirmed_at']) IS DISTINCT FROM (to_jsonb(NEW)-ARRAY['confirmed_by','confirmed_at']) THEN
      RAISE EXCEPTION 'Only first exact theory confirmation is permitted' USING ERRCODE='23514';
     END IF;
     RETURN NEW;
    END $$;


--
-- Name: lt_training_binding_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.lt_training_binding_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    BEGIN
     IF (OLD.id,OLD.school_id,OLD.student_id,OLD.category_code,OLD.created_at) IS DISTINCT FROM (NEW.id,NEW.school_id,NEW.student_id,NEW.category_code,NEW.created_at)
     OR OLD.program_version_id IS NOT NULL AND (OLD.program_version_id,OLD.program_assigned_by,OLD.program_assigned_at) IS DISTINCT FROM (NEW.program_version_id,NEW.program_assigned_by,NEW.program_assigned_at)
     OR NEW.dependency_revision<OLD.dependency_revision THEN
      RAISE EXCEPTION 'Training binding is immutable' USING ERRCODE='23514';
     END IF;
     RETURN NEW;
    END $$;


--
-- Name: prevent_document_release_mutation(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.prevent_document_release_mutation() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    BEGIN RAISE EXCEPTION 'Document release decisions are immutable'; END $$;


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
-- Name: admission_requirement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admission_requirement (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    definition_version_id uuid NOT NULL,
    program_version_id uuid NOT NULL,
    code character varying(80) NOT NULL,
    kind public.lt_requirement_kind NOT NULL,
    minimum_minutes integer,
    prerequisite_definition_version_id uuid,
    minimum_mark integer,
    CONSTRAINT requirement_typed_shape CHECK ((((kind = ANY (ARRAY['MinimumTheoryMinutes'::public.lt_requirement_kind, 'MinimumPracticalMinutes'::public.lt_requirement_kind])) AND (minimum_minutes IS NOT NULL) AND (minimum_minutes >= 0) AND (prerequisite_definition_version_id IS NULL) AND (minimum_mark IS NULL)) OR ((kind = 'AssessmentPassed'::public.lt_requirement_kind) AND (minimum_minutes IS NULL) AND (prerequisite_definition_version_id IS NOT NULL) AND (minimum_mark IS NULL)) OR ((kind = 'MinimumMark'::public.lt_requirement_kind) AND (minimum_minutes IS NULL) AND (prerequisite_definition_version_id IS NOT NULL) AND (minimum_mark IS NOT NULL))))
);


--
-- Name: assessment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessment (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    enrollment_id uuid NOT NULL,
    program_version_id uuid NOT NULL,
    definition_version_id uuid NOT NULL,
    attempt_number integer NOT NULL,
    appointment_id uuid,
    revision bigint NOT NULL,
    CONSTRAINT assessment_attempt_positive CHECK (((attempt_number > 0) AND (revision > 0)))
);


--
-- Name: assessment_definition; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessment_definition (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    program_id uuid NOT NULL,
    code character varying(80) NOT NULL
);


--
-- Name: assessment_definition_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessment_definition_version (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    definition_id uuid NOT NULL,
    program_id uuid NOT NULL,
    program_version_id uuid NOT NULL,
    name character varying(200) NOT NULL,
    training_kind public.lt_training_kind NOT NULL,
    stage public.lt_assessment_stage NOT NULL,
    minimum_mark integer NOT NULL,
    maximum_mark integer NOT NULL,
    passing_mark integer NOT NULL,
    required_for_completion boolean NOT NULL,
    CONSTRAINT assessment_scale CHECK (((minimum_mark < maximum_mark) AND (passing_mark >= minimum_mark) AND (passing_mark <= maximum_mark)))
);


--
-- Name: assessment_readiness; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessment_readiness (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    enrollment_id uuid NOT NULL,
    program_version_id uuid NOT NULL,
    definition_version_id uuid NOT NULL,
    current_evaluation_id uuid,
    current_decision_id uuid,
    revision bigint NOT NULL,
    CONSTRAINT readiness_revision_positive CHECK ((revision > 0))
);


--
-- Name: assessment_result_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessment_result_version (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    assessment_id uuid NOT NULL,
    enrollment_id uuid NOT NULL,
    definition_version_id uuid NOT NULL,
    version integer NOT NULL,
    command_id uuid NOT NULL,
    status public.lt_result_status NOT NULL,
    assessor_id uuid NOT NULL,
    assessed_at timestamp with time zone NOT NULL,
    recorded_by uuid NOT NULL,
    recorded_at timestamp with time zone NOT NULL,
    mark integer NOT NULL,
    outcome public.lt_outcome NOT NULL,
    readiness_id uuid,
    readiness_decision_id uuid,
    comment text,
    correction_reason text,
    reviewed_invalidation_at timestamp with time zone,
    CONSTRAINT assessment_result_reason CHECK ((((version = 1) AND (status = 'Recorded'::public.lt_result_status) AND (correction_reason IS NULL)) OR ((version > 1) AND (correction_reason IS NOT NULL) AND (length(TRIM(BOTH FROM correction_reason)) > 0)))),
    CONSTRAINT assessment_result_time CHECK ((recorded_at >= assessed_at)),
    CONSTRAINT assessment_result_version_positive CHECK ((version > 0)),
    CONSTRAINT result_readiness_pair CHECK (((readiness_id IS NULL) = (readiness_decision_id IS NULL))),
    CONSTRAINT result_review_pending_shape CHECK ((((status = 'ReviewRequired'::public.lt_result_status) AND (version > 1) AND (reviewed_invalidation_at IS NOT NULL)) OR (status <> 'ReviewRequired'::public.lt_result_status))),
    CONSTRAINT result_review_requires_decision CHECK (((reviewed_invalidation_at IS NULL) OR (readiness_decision_id IS NOT NULL))),
    CONSTRAINT result_review_timestamp CHECK (((reviewed_invalidation_at IS NULL) OR ((version > 1) AND (recorded_at >= reviewed_invalidation_at))))
);


--
-- Name: assessment_topic; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessment_topic (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    definition_version_id uuid NOT NULL,
    program_version_id uuid NOT NULL,
    topic_id uuid NOT NULL
);


--
-- Name: assessment_topic_result; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessment_topic_result (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    result_version_id uuid NOT NULL,
    definition_version_id uuid NOT NULL,
    assessment_topic_id uuid NOT NULL,
    mark integer NOT NULL,
    comment text
);


--
-- Name: document_release_decision; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_release_decision (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    enrollment_id uuid NOT NULL,
    actor_id uuid NOT NULL,
    fingerprint text NOT NULL,
    status text NOT NULL,
    evaluated_revision bigint NOT NULL,
    decided_at timestamp with time zone NOT NULL,
    reason text NOT NULL,
    CONSTRAINT document_release_decision_evaluated_revision_check CHECK ((evaluated_revision >= 0)),
    CONSTRAINT document_release_decision_status_check CHECK ((status = ANY (ARRAY['Accepted'::text, 'Rejected'::text])))
);

ALTER TABLE ONLY public.document_release_decision FORCE ROW LEVEL SECURITY;


--
-- Name: enrollment_source_state; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.enrollment_source_state (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    revision bigint NOT NULL,
    status text NOT NULL,
    verified_at timestamp with time zone NOT NULL,
    CONSTRAINT enrollment_source_state_revision_check CHECK ((revision > 0))
);


--
-- Name: inbox_message; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inbox_message (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    producer text NOT NULL,
    event_type text NOT NULL,
    aggregate_id uuid NOT NULL,
    aggregate_version bigint NOT NULL,
    fingerprint text NOT NULL,
    processed_at timestamp with time zone NOT NULL,
    CONSTRAINT inbox_message_aggregate_version_check CHECK ((aggregate_version > 0))
);


--
-- Name: learning_audit_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.learning_audit_event (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    actor_id uuid NOT NULL,
    occurred_at timestamp with time zone NOT NULL,
    channel public.lt_channel NOT NULL,
    action character varying(100) NOT NULL,
    target_type character varying(80) NOT NULL,
    target_id uuid NOT NULL,
    target_version bigint,
    outcome character varying(80) NOT NULL,
    correlation_id uuid NOT NULL,
    command_id uuid,
    reason text,
    source_snapshot_id uuid,
    dependency_revision bigint
);


--
-- Name: learning_operation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.learning_operation (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    actor_id uuid NOT NULL,
    fingerprint text NOT NULL,
    command text NOT NULL,
    result_json text NOT NULL,
    result_id uuid NOT NULL,
    applied_at timestamp with time zone NOT NULL
);


--
-- Name: lesson_planning_policy; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lesson_planning_policy (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    program_version_id uuid NOT NULL,
    kind public.lt_training_kind NOT NULL,
    lesson_minutes integer NOT NULL,
    allow_short_final_lesson boolean NOT NULL,
    minimum_final_lesson_minutes integer NOT NULL,
    CONSTRAINT lesson_planning_policy_check CHECK (((minimum_final_lesson_minutes > 0) AND (minimum_final_lesson_minutes <= lesson_minutes))),
    CONSTRAINT lesson_planning_policy_lesson_minutes_check CHECK ((lesson_minutes > 0))
);


--
-- Name: lesson_source_snapshot; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lesson_source_snapshot (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    lesson_id uuid NOT NULL,
    lesson_revision integer NOT NULL,
    kind public.lt_training_kind NOT NULL,
    instructor_id uuid NOT NULL,
    enrollment_id uuid,
    student_id uuid,
    vehicle_id uuid,
    group_id uuid,
    membership_revision bigint,
    actual_start timestamp with time zone,
    actual_end timestamp with time zone,
    physically_completed boolean NOT NULL,
    source_valid boolean NOT NULL,
    captured_at timestamp with time zone NOT NULL,
    source_event_id uuid,
    CONSTRAINT completed_source_requires_actuals CHECK (((NOT (physically_completed AND source_valid)) OR ((actual_start IS NOT NULL) AND (actual_end IS NOT NULL)))),
    CONSTRAINT source_actual_interval CHECK ((((actual_start IS NULL) AND (actual_end IS NULL)) OR ((actual_start IS NOT NULL) AND (actual_end IS NOT NULL) AND (actual_end > actual_start)))),
    CONSTRAINT source_kind_shape CHECK ((((kind = 'Practical'::public.lt_training_kind) AND (enrollment_id IS NOT NULL) AND (student_id IS NOT NULL) AND (vehicle_id IS NOT NULL) AND (group_id IS NULL) AND (membership_revision IS NULL)) OR ((kind = 'Theory'::public.lt_training_kind) AND (enrollment_id IS NULL) AND (student_id IS NULL) AND (vehicle_id IS NULL) AND (group_id IS NOT NULL) AND (membership_revision IS NOT NULL) AND (membership_revision > 0)))),
    CONSTRAINT source_revision_positive CHECK ((lesson_revision > 0))
);


--
-- Name: lesson_source_state; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lesson_source_state (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    lesson_id uuid NOT NULL,
    current_snapshot_id uuid NOT NULL,
    freshness public.lt_freshness NOT NULL,
    last_verified_at timestamp with time zone NOT NULL,
    reason text
);


--
-- Name: outbox_message; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outbox_message (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    aggregate_id uuid NOT NULL,
    aggregate_version bigint NOT NULL,
    event_type text NOT NULL,
    payload text NOT NULL,
    correlation_id text NOT NULL,
    occurred_at timestamp with time zone NOT NULL,
    sent_at timestamp with time zone,
    lease_id uuid,
    lease_until timestamp with time zone,
    attempts integer NOT NULL,
    next_attempt_at timestamp with time zone NOT NULL,
    CONSTRAINT outbox_message_aggregate_version_check CHECK ((aggregate_version > 0)),
    CONSTRAINT outbox_message_attempts_check CHECK ((attempts >= 0)),
    CONSTRAINT outbox_message_check CHECK (((lease_id IS NULL) = (lease_until IS NULL)))
);


--
-- Name: policy_attestation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.policy_attestation (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    checksum text NOT NULL,
    attested_at timestamp with time zone NOT NULL
);


--
-- Name: practical_record_response; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.practical_record_response (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    record_id uuid NOT NULL,
    record_version_id uuid NOT NULL,
    sequence bigint NOT NULL,
    actor_id uuid NOT NULL,
    actor_role public.lt_response_role NOT NULL,
    response public.lt_response_kind NOT NULL,
    responded_at timestamp with time zone NOT NULL,
    reason text,
    command_id uuid NOT NULL,
    CONSTRAINT dispute_reason CHECK (((response <> 'Dispute'::public.lt_response_kind) OR ((reason IS NOT NULL) AND (length(TRIM(BOTH FROM reason)) > 0)))),
    CONSTRAINT response_sequence CHECK ((sequence > 0))
);


--
-- Name: practical_record_topic; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.practical_record_topic (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    record_version_id uuid NOT NULL,
    program_version_id uuid NOT NULL,
    topic_id uuid NOT NULL
);


--
-- Name: practical_record_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.practical_record_version (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    record_id uuid NOT NULL,
    enrollment_id uuid NOT NULL,
    lesson_id uuid NOT NULL,
    program_version_id uuid NOT NULL,
    version integer NOT NULL,
    source_snapshot_id uuid NOT NULL,
    training_minutes integer,
    duration_explanation text,
    distance_km numeric(10,3),
    validation public.lt_validation NOT NULL,
    validation_reason text,
    created_by uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    correction_reason text,
    CONSTRAINT practical_correction_reason CHECK (((version = 1) OR ((correction_reason IS NOT NULL) AND (length(TRIM(BOTH FROM correction_reason)) > 0)))),
    CONSTRAINT practical_distance CHECK (((distance_km IS NULL) OR (distance_km >= (0)::numeric))),
    CONSTRAINT practical_minutes CHECK (((training_minutes IS NULL) OR (training_minutes > 0))),
    CONSTRAINT practical_valid_shape CHECK (((validation <> 'Valid'::public.lt_validation) OR ((training_minutes IS NOT NULL) AND (distance_km IS NOT NULL)))),
    CONSTRAINT practical_version_positive CHECK ((version > 0))
);


--
-- Name: practical_training_record; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.practical_training_record (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    lesson_id uuid NOT NULL,
    enrollment_id uuid NOT NULL,
    current_version_id uuid,
    revision bigint NOT NULL,
    CONSTRAINT practical_revision_positive CHECK ((revision > 0))
);


--
-- Name: program_rule_source; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.program_rule_source (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    program_version_id uuid NOT NULL,
    rule_code character varying(80) NOT NULL,
    source_uri text NOT NULL,
    source_edition character varying(200) NOT NULL,
    applicability text NOT NULL,
    verified_by uuid,
    verified_at timestamp with time zone,
    effective_from date NOT NULL,
    effective_to date,
    unit_description character varying(120) NOT NULL,
    CONSTRAINT rule_effective_period CHECK (((effective_to IS NULL) OR (effective_to >= effective_from))),
    CONSTRAINT rule_verification_pair CHECK (((verified_by IS NULL) = (verified_at IS NULL)))
);


--
-- Name: readiness_decision; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.readiness_decision (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    readiness_id uuid NOT NULL,
    evaluation_id uuid NOT NULL,
    actor_id uuid NOT NULL,
    decided_at timestamp with time zone NOT NULL,
    decision public.lt_decision NOT NULL,
    reason text NOT NULL,
    authority_basis text NOT NULL,
    command_id uuid NOT NULL,
    invalidated_at timestamp with time zone,
    invalidated_by uuid,
    invalidation_reason text,
    invalidation_dependency_revision bigint,
    invalidation_scope public.lt_invalidation_scope,
    invalidation_effective_at timestamp with time zone,
    enrollment_id uuid NOT NULL,
    CONSTRAINT decision_terminal_invalidation_shape CHECK ((((invalidated_at IS NULL) AND (invalidated_by IS NULL) AND (invalidation_reason IS NULL) AND (invalidation_dependency_revision IS NULL) AND (invalidation_scope IS NULL) AND (invalidation_effective_at IS NULL)) OR ((decision = 'Approved'::public.lt_decision) AND (invalidated_at IS NOT NULL) AND (invalidated_by IS NOT NULL) AND (invalidation_reason IS NOT NULL) AND (length(TRIM(BOTH FROM invalidation_reason)) > 0) AND (invalidation_dependency_revision IS NOT NULL) AND (invalidation_dependency_revision > 0) AND (invalidated_at >= decided_at) AND (invalidation_scope IS NOT NULL) AND ((invalidation_scope = 'HistoricalReviewRequired'::public.lt_invalidation_scope) OR ((invalidation_scope = 'ProspectiveOnly'::public.lt_invalidation_scope) AND (invalidation_effective_at IS NOT NULL) AND (invalidation_effective_at >= decided_at)))))),
    CONSTRAINT decline_reason CHECK (((decision <> 'NotApproved'::public.lt_decision) OR (length(TRIM(BOTH FROM reason)) > 0)))
);


--
-- Name: readiness_evaluation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.readiness_evaluation (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    readiness_id uuid NOT NULL,
    enrollment_id uuid NOT NULL,
    definition_version_id uuid NOT NULL,
    dependency_revision bigint NOT NULL,
    formal_status public.lt_formal_status NOT NULL,
    evaluated_at timestamp with time zone NOT NULL,
    evaluated_by uuid NOT NULL,
    explanation text NOT NULL,
    CONSTRAINT evaluation_dependency_positive CHECK ((dependency_revision > 0))
);


--
-- Name: readiness_evidence_basis; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.readiness_evidence_basis (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    evaluation_id uuid NOT NULL,
    enrollment_id uuid NOT NULL,
    lesson_id uuid,
    practical_record_version_id uuid,
    theory_attendance_id uuid,
    result_version_id uuid,
    observed_minutes integer,
    CONSTRAINT readiness_evidence_source_xor CHECK ((((((practical_record_version_id IS NOT NULL))::integer + ((theory_attendance_id IS NOT NULL))::integer) + ((result_version_id IS NOT NULL))::integer) = 1)),
    CONSTRAINT readiness_evidence_typed_shape CHECK (((((practical_record_version_id IS NOT NULL) OR (theory_attendance_id IS NOT NULL)) AND (lesson_id IS NOT NULL) AND (observed_minutes IS NOT NULL) AND (observed_minutes > 0)) OR ((result_version_id IS NOT NULL) AND (lesson_id IS NULL) AND (observed_minutes IS NULL))))
);


--
-- Name: readiness_requirement_result; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.readiness_requirement_result (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    evaluation_id uuid NOT NULL,
    definition_version_id uuid NOT NULL,
    requirement_id uuid NOT NULL,
    status public.lt_formal_status NOT NULL,
    observed_minutes integer,
    observed_mark integer,
    explanation text NOT NULL,
    CONSTRAINT observed_minutes_nonnegative CHECK (((observed_minutes IS NULL) OR (observed_minutes >= 0)))
);


--
-- Name: reporting_declaration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reporting_declaration (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    snapshot_id uuid NOT NULL,
    actor_id uuid NOT NULL,
    declared_at timestamp with time zone NOT NULL,
    statement text NOT NULL,
    command_id uuid NOT NULL
);


--
-- Name: school_source_state; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.school_source_state (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    revision bigint NOT NULL,
    last_verified_at timestamp with time zone NOT NULL,
    CONSTRAINT school_source_identity CHECK (((id = school_id) AND (revision > 0)))
);


--
-- Name: student_training; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.student_training (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    student_id uuid NOT NULL,
    category_code character varying(16) NOT NULL,
    program_version_id uuid,
    program_assigned_by uuid,
    program_assigned_at timestamp with time zone,
    dependency_revision bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT program_initial_assignment_pair CHECK ((((program_version_id IS NULL) AND (program_assigned_by IS NULL) AND (program_assigned_at IS NULL)) OR ((program_version_id IS NOT NULL) AND (program_assigned_by IS NOT NULL) AND (program_assigned_at IS NOT NULL)))),
    CONSTRAINT training_dependency_positive CHECK ((dependency_revision > 0))
);


--
-- Name: theory_attendance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.theory_attendance (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    record_version_id uuid NOT NULL,
    enrollment_id uuid NOT NULL,
    student_id uuid NOT NULL,
    attendance public.lt_attendance NOT NULL
);


--
-- Name: theory_record_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.theory_record_version (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    record_id uuid NOT NULL,
    lesson_id uuid NOT NULL,
    version integer NOT NULL,
    source_snapshot_id uuid NOT NULL,
    training_minutes integer NOT NULL,
    duration_explanation text,
    validation public.lt_validation NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    confirmed_by uuid,
    confirmed_at timestamp with time zone,
    correction_reason text,
    CONSTRAINT theory_confirmation_pair CHECK (((confirmed_by IS NULL) = (confirmed_at IS NULL))),
    CONSTRAINT theory_confirmed_valid CHECK (((confirmed_at IS NULL) OR (validation = 'Valid'::public.lt_validation))),
    CONSTRAINT theory_correction_reason CHECK (((version = 1) OR ((correction_reason IS NOT NULL) AND (length(TRIM(BOTH FROM correction_reason)) > 0)))),
    CONSTRAINT theory_positive CHECK (((version > 0) AND (training_minutes > 0)))
);


--
-- Name: theory_training_record; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.theory_training_record (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    lesson_id uuid NOT NULL,
    current_version_id uuid,
    revision bigint NOT NULL,
    CONSTRAINT theory_revision_positive CHECK ((revision > 0))
);


--
-- Name: training_evidence_check; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.training_evidence_check (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    snapshot_id uuid NOT NULL,
    enrollment_id uuid NOT NULL,
    check_code character varying(100) NOT NULL,
    check_scope public.lt_check_scope NOT NULL,
    evidence_item_id uuid,
    field_code character varying(100) NOT NULL,
    outcome public.lt_check_outcome NOT NULL,
    explanation text NOT NULL,
    CONSTRAINT evidence_check_codes_nonblank CHECK (((length(TRIM(BOTH FROM check_code)) > 0) AND (length(TRIM(BOTH FROM field_code)) > 0))),
    CONSTRAINT evidence_check_explanation_nonblank CHECK ((length(TRIM(BOTH FROM explanation)) > 0)),
    CONSTRAINT evidence_check_scope_shape CHECK ((((check_scope = 'Snapshot'::public.lt_check_scope) AND (evidence_item_id IS NULL)) OR ((check_scope = 'EvidenceItem'::public.lt_check_scope) AND (evidence_item_id IS NOT NULL))))
);


--
-- Name: training_evidence_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.training_evidence_item (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    snapshot_id uuid NOT NULL,
    enrollment_id uuid NOT NULL,
    lesson_id uuid,
    practical_record_version_id uuid,
    theory_attendance_id uuid,
    result_version_id uuid,
    readiness_decision_id uuid,
    record_response_sequence bigint,
    credited_minutes_at_snapshot integer,
    observed_state character varying(80) NOT NULL,
    explanation text NOT NULL,
    CONSTRAINT evidence_item_lesson_shape CHECK (((((practical_record_version_id IS NOT NULL) OR (theory_attendance_id IS NOT NULL)) AND (lesson_id IS NOT NULL) AND (credited_minutes_at_snapshot IS NOT NULL)) OR ((practical_record_version_id IS NULL) AND (theory_attendance_id IS NULL) AND (lesson_id IS NULL) AND (credited_minutes_at_snapshot IS NULL)))),
    CONSTRAINT evidence_item_minutes_nonnegative CHECK (((credited_minutes_at_snapshot IS NULL) OR (credited_minutes_at_snapshot >= 0))),
    CONSTRAINT evidence_item_one_source CHECK (((((((practical_record_version_id IS NOT NULL))::integer + ((theory_attendance_id IS NOT NULL))::integer) + ((result_version_id IS NOT NULL))::integer) + ((readiness_decision_id IS NOT NULL))::integer) = 1)),
    CONSTRAINT evidence_response_shape CHECK (((record_response_sequence IS NULL) OR ((practical_record_version_id IS NOT NULL) AND (record_response_sequence >= 0))))
);


--
-- Name: training_evidence_snapshot; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.training_evidence_snapshot (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    enrollment_id uuid NOT NULL,
    program_version_id uuid NOT NULL,
    kind public.lt_evidence_kind NOT NULL,
    status public.lt_evidence_status NOT NULL,
    checklist_version_id uuid,
    dependency_revision bigint NOT NULL,
    prepared_by uuid NOT NULL,
    prepared_at timestamp with time zone NOT NULL,
    source_verified_at timestamp with time zone,
    CONSTRAINT evidence_dependency_positive CHECK ((dependency_revision > 0)),
    CONSTRAINT ready_evidence_basis CHECK (((status <> 'Ready'::public.lt_evidence_status) OR ((checklist_version_id IS NOT NULL) AND (source_verified_at IS NOT NULL))))
);


--
-- Name: training_program; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.training_program (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    category_code character varying(16) NOT NULL,
    name character varying(200) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    revision bigint NOT NULL,
    CONSTRAINT program_revision_positive CHECK ((revision > 0))
);


--
-- Name: training_program_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.training_program_version (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    program_id uuid NOT NULL,
    version integer NOT NULL,
    status public.lt_program_status NOT NULL,
    pathway_code character varying(80) NOT NULL,
    required_theory_minutes integer NOT NULL,
    required_practical_minutes integer NOT NULL,
    theory_minutes_per_unit integer NOT NULL,
    practical_minutes_per_unit integer NOT NULL,
    effective_from date NOT NULL,
    effective_to date,
    legal_basis_verified boolean NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    published_by uuid,
    published_at timestamp with time zone,
    retired_at timestamp with time zone,
    journal_checklist_version_id uuid,
    CONSTRAINT program_conversion_positive CHECK (((theory_minutes_per_unit > 0) AND (practical_minutes_per_unit > 0))),
    CONSTRAINT program_effective_period CHECK (((effective_to IS NULL) OR (effective_to >= effective_from))),
    CONSTRAINT program_minutes_nonnegative CHECK (((required_theory_minutes >= 0) AND (required_practical_minutes >= 0))),
    CONSTRAINT program_publication_shape CHECK ((((status = 'Draft'::public.lt_program_status) AND (published_at IS NULL) AND (published_by IS NULL) AND (retired_at IS NULL)) OR ((status = 'Published'::public.lt_program_status) AND (published_at IS NOT NULL) AND (published_by IS NOT NULL) AND (retired_at IS NULL) AND legal_basis_verified) OR ((status = 'Retired'::public.lt_program_status) AND (published_at IS NOT NULL) AND (published_by IS NOT NULL) AND (retired_at IS NOT NULL) AND (retired_at >= published_at) AND legal_basis_verified))),
    CONSTRAINT program_version_positive CHECK ((version > 0)),
    CONSTRAINT published_checklist CHECK (((status = 'Draft'::public.lt_program_status) OR (journal_checklist_version_id IS NOT NULL)))
);


--
-- Name: training_topic; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.training_topic (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    program_version_id uuid NOT NULL,
    topic_key character varying(80) NOT NULL,
    name character varying(200) NOT NULL,
    description text
);


--
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- Name: school_source_state PK_school_source_state; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school_source_state
    ADD CONSTRAINT "PK_school_source_state" PRIMARY KEY (id);


--
-- Name: admission_requirement admission_requirement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admission_requirement
    ADD CONSTRAINT admission_requirement_pkey PRIMARY KEY (id);


--
-- Name: assessment_definition assessment_definition_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_definition
    ADD CONSTRAINT assessment_definition_pkey PRIMARY KEY (id);


--
-- Name: assessment_definition_version assessment_definition_version_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_definition_version
    ADD CONSTRAINT assessment_definition_version_pkey PRIMARY KEY (id);


--
-- Name: assessment assessment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment
    ADD CONSTRAINT assessment_pkey PRIMARY KEY (id);


--
-- Name: assessment_readiness assessment_readiness_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_readiness
    ADD CONSTRAINT assessment_readiness_pkey PRIMARY KEY (id);


--
-- Name: assessment_result_version assessment_result_version_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_result_version
    ADD CONSTRAINT assessment_result_version_pkey PRIMARY KEY (id);


--
-- Name: assessment_topic assessment_topic_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_topic
    ADD CONSTRAINT assessment_topic_pkey PRIMARY KEY (id);


--
-- Name: assessment_topic_result assessment_topic_result_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_topic_result
    ADD CONSTRAINT assessment_topic_result_pkey PRIMARY KEY (id);


--
-- Name: document_release_decision document_release_decision_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_release_decision
    ADD CONSTRAINT document_release_decision_pkey PRIMARY KEY (id);


--
-- Name: enrollment_source_state enrollment_source_state_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollment_source_state
    ADD CONSTRAINT enrollment_source_state_pkey PRIMARY KEY (id);


--
-- Name: inbox_message inbox_message_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inbox_message
    ADD CONSTRAINT inbox_message_pkey PRIMARY KEY (id);


--
-- Name: learning_audit_event learning_audit_event_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.learning_audit_event
    ADD CONSTRAINT learning_audit_event_pkey PRIMARY KEY (id);


--
-- Name: learning_operation learning_operation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.learning_operation
    ADD CONSTRAINT learning_operation_pkey PRIMARY KEY (school_id, id);


--
-- Name: lesson_planning_policy lesson_planning_policy_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson_planning_policy
    ADD CONSTRAINT lesson_planning_policy_pkey PRIMARY KEY (id);


--
-- Name: lesson_planning_policy lesson_planning_policy_school_id_program_version_id_kind_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson_planning_policy
    ADD CONSTRAINT lesson_planning_policy_school_id_program_version_id_kind_key UNIQUE (school_id, program_version_id, kind);


--
-- Name: lesson_source_snapshot lesson_source_snapshot_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson_source_snapshot
    ADD CONSTRAINT lesson_source_snapshot_pkey PRIMARY KEY (id);


--
-- Name: lesson_source_state lesson_source_state_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson_source_state
    ADD CONSTRAINT lesson_source_state_pkey PRIMARY KEY (id);


--
-- Name: outbox_message outbox_message_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbox_message
    ADD CONSTRAINT outbox_message_pkey PRIMARY KEY (id);


--
-- Name: policy_attestation policy_attestation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.policy_attestation
    ADD CONSTRAINT policy_attestation_pkey PRIMARY KEY (school_id, id);


--
-- Name: practical_record_response practical_record_response_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.practical_record_response
    ADD CONSTRAINT practical_record_response_pkey PRIMARY KEY (id);


--
-- Name: practical_record_topic practical_record_topic_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.practical_record_topic
    ADD CONSTRAINT practical_record_topic_pkey PRIMARY KEY (id);


--
-- Name: practical_record_version practical_record_version_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.practical_record_version
    ADD CONSTRAINT practical_record_version_pkey PRIMARY KEY (id);


--
-- Name: practical_training_record practical_training_record_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.practical_training_record
    ADD CONSTRAINT practical_training_record_pkey PRIMARY KEY (id);


--
-- Name: program_rule_source program_rule_source_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.program_rule_source
    ADD CONSTRAINT program_rule_source_pkey PRIMARY KEY (id);


--
-- Name: readiness_decision readiness_decision_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.readiness_decision
    ADD CONSTRAINT readiness_decision_pkey PRIMARY KEY (id);


--
-- Name: readiness_evaluation readiness_evaluation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.readiness_evaluation
    ADD CONSTRAINT readiness_evaluation_pkey PRIMARY KEY (id);


--
-- Name: readiness_evidence_basis readiness_evidence_basis_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.readiness_evidence_basis
    ADD CONSTRAINT readiness_evidence_basis_pkey PRIMARY KEY (id);


--
-- Name: readiness_requirement_result readiness_requirement_result_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.readiness_requirement_result
    ADD CONSTRAINT readiness_requirement_result_pkey PRIMARY KEY (id);


--
-- Name: reporting_declaration reporting_declaration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reporting_declaration
    ADD CONSTRAINT reporting_declaration_pkey PRIMARY KEY (id);


--
-- Name: student_training student_training_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_training
    ADD CONSTRAINT student_training_pkey PRIMARY KEY (id);


--
-- Name: theory_attendance theory_attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.theory_attendance
    ADD CONSTRAINT theory_attendance_pkey PRIMARY KEY (id);


--
-- Name: theory_record_version theory_record_version_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.theory_record_version
    ADD CONSTRAINT theory_record_version_pkey PRIMARY KEY (id);


--
-- Name: theory_training_record theory_training_record_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.theory_training_record
    ADD CONSTRAINT theory_training_record_pkey PRIMARY KEY (id);


--
-- Name: training_evidence_check training_evidence_check_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_evidence_check
    ADD CONSTRAINT training_evidence_check_pkey PRIMARY KEY (id);


--
-- Name: training_evidence_item training_evidence_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_evidence_item
    ADD CONSTRAINT training_evidence_item_pkey PRIMARY KEY (id);


--
-- Name: training_evidence_snapshot training_evidence_snapshot_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_evidence_snapshot
    ADD CONSTRAINT training_evidence_snapshot_pkey PRIMARY KEY (id);


--
-- Name: training_program training_program_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_program
    ADD CONSTRAINT training_program_pkey PRIMARY KEY (id);


--
-- Name: training_program_version training_program_version_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_program_version
    ADD CONSTRAINT training_program_version_pkey PRIMARY KEY (id);


--
-- Name: training_topic training_topic_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_topic
    ADD CONSTRAINT training_topic_pkey PRIMARY KEY (id);


--
-- Name: admission_requirement_definition_version_id_code_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX admission_requirement_definition_version_id_code_school_id_idx ON public.admission_requirement USING btree (definition_version_id, code, school_id);


--
-- Name: admission_requirement_id_school_id_definition_version_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX admission_requirement_id_school_id_definition_version_id_idx ON public.admission_requirement USING btree (id, school_id, definition_version_id);


--
-- Name: admission_requirement_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX admission_requirement_id_school_id_idx ON public.admission_requirement USING btree (id, school_id);


--
-- Name: assessment_definition_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assessment_definition_id_school_id_idx ON public.assessment_definition USING btree (id, school_id);


--
-- Name: assessment_definition_id_school_id_program_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assessment_definition_id_school_id_program_id_idx ON public.assessment_definition USING btree (id, school_id, program_id);


--
-- Name: assessment_definition_program_id_code_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assessment_definition_program_id_code_school_id_idx ON public.assessment_definition USING btree (program_id, code, school_id);


--
-- Name: assessment_definition_version_definition_id_program_version_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assessment_definition_version_definition_id_program_version_idx ON public.assessment_definition_version USING btree (definition_id, program_version_id, school_id);


--
-- Name: assessment_definition_version_id_school_id_definition_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assessment_definition_version_id_school_id_definition_id_idx ON public.assessment_definition_version USING btree (id, school_id, definition_id);


--
-- Name: assessment_definition_version_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assessment_definition_version_id_school_id_idx ON public.assessment_definition_version USING btree (id, school_id);


--
-- Name: assessment_definition_version_id_school_id_program_version__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assessment_definition_version_id_school_id_program_version__idx ON public.assessment_definition_version USING btree (id, school_id, program_version_id);


--
-- Name: assessment_enrollment_id_definition_version_id_attempt_numb_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assessment_enrollment_id_definition_version_id_attempt_numb_idx ON public.assessment USING btree (enrollment_id, definition_version_id, attempt_number, school_id);


--
-- Name: assessment_id_school_id_definition_version_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assessment_id_school_id_definition_version_id_idx ON public.assessment USING btree (id, school_id, definition_version_id);


--
-- Name: assessment_id_school_id_enrollment_id_definition_version_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assessment_id_school_id_enrollment_id_definition_version_id_idx ON public.assessment USING btree (id, school_id, enrollment_id, definition_version_id);


--
-- Name: assessment_id_school_id_enrollment_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assessment_id_school_id_enrollment_id_idx ON public.assessment USING btree (id, school_id, enrollment_id);


--
-- Name: assessment_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assessment_id_school_id_idx ON public.assessment USING btree (id, school_id);


--
-- Name: assessment_readiness_enrollment_id_program_version_id_defin_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assessment_readiness_enrollment_id_program_version_id_defin_idx ON public.assessment_readiness USING btree (enrollment_id, program_version_id, definition_version_id, school_id);


--
-- Name: assessment_readiness_id_school_id_definition_version_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assessment_readiness_id_school_id_definition_version_id_idx ON public.assessment_readiness USING btree (id, school_id, definition_version_id);


--
-- Name: assessment_readiness_id_school_id_enrollment_id_definition__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assessment_readiness_id_school_id_enrollment_id_definition__idx ON public.assessment_readiness USING btree (id, school_id, enrollment_id, definition_version_id);


--
-- Name: assessment_readiness_id_school_id_enrollment_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assessment_readiness_id_school_id_enrollment_id_idx ON public.assessment_readiness USING btree (id, school_id, enrollment_id);


--
-- Name: assessment_readiness_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assessment_readiness_id_school_id_idx ON public.assessment_readiness USING btree (id, school_id);


--
-- Name: assessment_result_version_assessment_id_version_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assessment_result_version_assessment_id_version_school_id_idx ON public.assessment_result_version USING btree (assessment_id, version, school_id);


--
-- Name: assessment_result_version_command_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assessment_result_version_command_id_school_id_idx ON public.assessment_result_version USING btree (command_id, school_id);


--
-- Name: assessment_result_version_id_school_id_assessment_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assessment_result_version_id_school_id_assessment_id_idx ON public.assessment_result_version USING btree (id, school_id, assessment_id);


--
-- Name: assessment_result_version_id_school_id_definition_version_i_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assessment_result_version_id_school_id_definition_version_i_idx ON public.assessment_result_version USING btree (id, school_id, definition_version_id);


--
-- Name: assessment_result_version_id_school_id_enrollment_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assessment_result_version_id_school_id_enrollment_id_idx ON public.assessment_result_version USING btree (id, school_id, enrollment_id);


--
-- Name: assessment_result_version_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assessment_result_version_id_school_id_idx ON public.assessment_result_version USING btree (id, school_id);


--
-- Name: assessment_topic_definition_version_id_topic_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assessment_topic_definition_version_id_topic_id_school_id_idx ON public.assessment_topic USING btree (definition_version_id, topic_id, school_id);


--
-- Name: assessment_topic_id_school_id_definition_version_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assessment_topic_id_school_id_definition_version_id_idx ON public.assessment_topic USING btree (id, school_id, definition_version_id);


--
-- Name: assessment_topic_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assessment_topic_id_school_id_idx ON public.assessment_topic USING btree (id, school_id);


--
-- Name: assessment_topic_result_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assessment_topic_result_id_school_id_idx ON public.assessment_topic_result USING btree (id, school_id);


--
-- Name: assessment_topic_result_result_version_id_assessment_topic__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assessment_topic_result_result_version_id_assessment_topic__idx ON public.assessment_topic_result USING btree (result_version_id, assessment_topic_id, school_id);


--
-- Name: idx_check_item_target; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_check_item_target ON public.training_evidence_check USING btree (evidence_item_id, school_id, snapshot_id);


--
-- Name: idx_check_snapshot_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_check_snapshot_tenant ON public.training_evidence_check USING btree (snapshot_id, school_id, enrollment_id);


--
-- Name: idx_practical_by_enrollment; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_practical_by_enrollment ON public.practical_training_record USING btree (school_id, enrollment_id);


--
-- Name: idx_practical_response_eligibility; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_practical_response_eligibility ON public.practical_record_response USING btree (record_version_id, actor_role, response);


--
-- Name: idx_readiness_evidence_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_readiness_evidence_scope ON public.readiness_evidence_basis USING btree (school_id, enrollment_id, evaluation_id);


--
-- Name: idx_theory_attendance_by_enrollment; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_theory_attendance_by_enrollment ON public.theory_attendance USING btree (school_id, enrollment_id, record_version_id);


--
-- Name: ix_outbox_message_sent_at_next_attempt_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_outbox_message_sent_at_next_attempt_at ON public.outbox_message USING btree (sent_at, next_attempt_at);


--
-- Name: learning_audit_event_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX learning_audit_event_id_school_id_idx ON public.learning_audit_event USING btree (id, school_id);


--
-- Name: lesson_source_snapshot_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX lesson_source_snapshot_id_school_id_idx ON public.lesson_source_snapshot USING btree (id, school_id);


--
-- Name: lesson_source_snapshot_id_school_id_lesson_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX lesson_source_snapshot_id_school_id_lesson_id_idx ON public.lesson_source_snapshot USING btree (id, school_id, lesson_id);


--
-- Name: lesson_source_snapshot_lesson_id_lesson_revision_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX lesson_source_snapshot_lesson_id_lesson_revision_school_id_idx ON public.lesson_source_snapshot USING btree (lesson_id, lesson_revision, school_id);


--
-- Name: lesson_source_state_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX lesson_source_state_id_school_id_idx ON public.lesson_source_state USING btree (id, school_id);


--
-- Name: lesson_source_state_lesson_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX lesson_source_state_lesson_id_school_id_idx ON public.lesson_source_state USING btree (lesson_id, school_id);


--
-- Name: practical_record_response_command_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX practical_record_response_command_id_school_id_idx ON public.practical_record_response USING btree (command_id, school_id);


--
-- Name: practical_record_response_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX practical_record_response_id_school_id_idx ON public.practical_record_response USING btree (id, school_id);


--
-- Name: practical_record_response_id_school_id_record_version_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX practical_record_response_id_school_id_record_version_id_idx ON public.practical_record_response USING btree (id, school_id, record_version_id);


--
-- Name: practical_record_response_record_id_sequence_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX practical_record_response_record_id_sequence_school_id_idx ON public.practical_record_response USING btree (record_id, sequence, school_id);


--
-- Name: practical_record_topic_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX practical_record_topic_id_school_id_idx ON public.practical_record_topic USING btree (id, school_id);


--
-- Name: practical_record_topic_record_version_id_topic_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX practical_record_topic_record_version_id_topic_id_school_id_idx ON public.practical_record_topic USING btree (record_version_id, topic_id, school_id);


--
-- Name: practical_record_version_id_school_id_enrollment_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX practical_record_version_id_school_id_enrollment_id_idx ON public.practical_record_version USING btree (id, school_id, enrollment_id);


--
-- Name: practical_record_version_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX practical_record_version_id_school_id_idx ON public.practical_record_version USING btree (id, school_id);


--
-- Name: practical_record_version_id_school_id_program_version_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX practical_record_version_id_school_id_program_version_id_idx ON public.practical_record_version USING btree (id, school_id, program_version_id);


--
-- Name: practical_record_version_id_school_id_record_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX practical_record_version_id_school_id_record_id_idx ON public.practical_record_version USING btree (id, school_id, record_id);


--
-- Name: practical_record_version_record_id_version_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX practical_record_version_record_id_version_school_id_idx ON public.practical_record_version USING btree (record_id, version, school_id);


--
-- Name: practical_training_record_id_school_id_enrollment_id_lesson_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX practical_training_record_id_school_id_enrollment_id_lesson_idx ON public.practical_training_record USING btree (id, school_id, enrollment_id, lesson_id);


--
-- Name: practical_training_record_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX practical_training_record_id_school_id_idx ON public.practical_training_record USING btree (id, school_id);


--
-- Name: practical_training_record_lesson_id_enrollment_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX practical_training_record_lesson_id_enrollment_id_school_id_idx ON public.practical_training_record USING btree (lesson_id, enrollment_id, school_id);


--
-- Name: program_rule_source_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX program_rule_source_id_school_id_idx ON public.program_rule_source USING btree (id, school_id);


--
-- Name: readiness_decision_command_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX readiness_decision_command_id_school_id_idx ON public.readiness_decision USING btree (command_id, school_id);


--
-- Name: readiness_decision_id_school_id_enrollment_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX readiness_decision_id_school_id_enrollment_id_idx ON public.readiness_decision USING btree (id, school_id, enrollment_id);


--
-- Name: readiness_decision_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX readiness_decision_id_school_id_idx ON public.readiness_decision USING btree (id, school_id);


--
-- Name: readiness_decision_id_school_id_readiness_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX readiness_decision_id_school_id_readiness_id_idx ON public.readiness_decision USING btree (id, school_id, readiness_id);


--
-- Name: readiness_evaluation_id_school_id_definition_version_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX readiness_evaluation_id_school_id_definition_version_id_idx ON public.readiness_evaluation USING btree (id, school_id, definition_version_id);


--
-- Name: readiness_evaluation_id_school_id_enrollment_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX readiness_evaluation_id_school_id_enrollment_id_idx ON public.readiness_evaluation USING btree (id, school_id, enrollment_id);


--
-- Name: readiness_evaluation_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX readiness_evaluation_id_school_id_idx ON public.readiness_evaluation USING btree (id, school_id);


--
-- Name: readiness_evaluation_id_school_id_readiness_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX readiness_evaluation_id_school_id_readiness_id_idx ON public.readiness_evaluation USING btree (id, school_id, readiness_id);


--
-- Name: readiness_evidence_basis_evaluation_id_lesson_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX readiness_evidence_basis_evaluation_id_lesson_id_school_id_idx ON public.readiness_evidence_basis USING btree (evaluation_id, lesson_id, school_id);


--
-- Name: readiness_evidence_basis_evaluation_id_result_version_id_sc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX readiness_evidence_basis_evaluation_id_result_version_id_sc_idx ON public.readiness_evidence_basis USING btree (evaluation_id, result_version_id, school_id);


--
-- Name: readiness_evidence_basis_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX readiness_evidence_basis_id_school_id_idx ON public.readiness_evidence_basis USING btree (id, school_id);


--
-- Name: readiness_requirement_result_evaluation_id_requirement_id_s_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX readiness_requirement_result_evaluation_id_requirement_id_s_idx ON public.readiness_requirement_result USING btree (evaluation_id, requirement_id, school_id);


--
-- Name: readiness_requirement_result_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX readiness_requirement_result_id_school_id_idx ON public.readiness_requirement_result USING btree (id, school_id);


--
-- Name: reporting_declaration_command_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX reporting_declaration_command_id_school_id_idx ON public.reporting_declaration USING btree (command_id, school_id);


--
-- Name: reporting_declaration_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX reporting_declaration_id_school_id_idx ON public.reporting_declaration USING btree (id, school_id);


--
-- Name: student_training_id_school_id_category_code_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX student_training_id_school_id_category_code_idx ON public.student_training USING btree (id, school_id, category_code);


--
-- Name: student_training_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX student_training_id_school_id_idx ON public.student_training USING btree (id, school_id);


--
-- Name: student_training_id_school_id_program_version_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX student_training_id_school_id_program_version_id_idx ON public.student_training USING btree (id, school_id, program_version_id);


--
-- Name: student_training_id_school_id_student_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX student_training_id_school_id_student_id_idx ON public.student_training USING btree (id, school_id, student_id);


--
-- Name: theory_attendance_id_school_id_enrollment_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX theory_attendance_id_school_id_enrollment_id_idx ON public.theory_attendance USING btree (id, school_id, enrollment_id);


--
-- Name: theory_attendance_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX theory_attendance_id_school_id_idx ON public.theory_attendance USING btree (id, school_id);


--
-- Name: theory_attendance_record_version_id_enrollment_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX theory_attendance_record_version_id_enrollment_id_school_id_idx ON public.theory_attendance USING btree (record_version_id, enrollment_id, school_id);


--
-- Name: theory_record_version_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX theory_record_version_id_school_id_idx ON public.theory_record_version USING btree (id, school_id);


--
-- Name: theory_record_version_id_school_id_lesson_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX theory_record_version_id_school_id_lesson_id_idx ON public.theory_record_version USING btree (id, school_id, lesson_id);


--
-- Name: theory_record_version_id_school_id_record_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX theory_record_version_id_school_id_record_id_idx ON public.theory_record_version USING btree (id, school_id, record_id);


--
-- Name: theory_record_version_record_id_version_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX theory_record_version_record_id_version_school_id_idx ON public.theory_record_version USING btree (record_id, version, school_id);


--
-- Name: theory_training_record_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX theory_training_record_id_school_id_idx ON public.theory_training_record USING btree (id, school_id);


--
-- Name: theory_training_record_id_school_id_lesson_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX theory_training_record_id_school_id_lesson_id_idx ON public.theory_training_record USING btree (id, school_id, lesson_id);


--
-- Name: theory_training_record_lesson_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX theory_training_record_lesson_id_school_id_idx ON public.theory_training_record USING btree (lesson_id, school_id);


--
-- Name: training_evidence_check_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX training_evidence_check_id_school_id_idx ON public.training_evidence_check USING btree (id, school_id);


--
-- Name: training_evidence_item_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX training_evidence_item_id_school_id_idx ON public.training_evidence_item USING btree (id, school_id);


--
-- Name: training_evidence_item_id_school_id_snapshot_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX training_evidence_item_id_school_id_snapshot_id_idx ON public.training_evidence_item USING btree (id, school_id, snapshot_id);


--
-- Name: training_evidence_item_snapshot_id_lesson_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX training_evidence_item_snapshot_id_lesson_id_school_id_idx ON public.training_evidence_item USING btree (snapshot_id, lesson_id, school_id);


--
-- Name: training_evidence_snapshot_id_school_id_enrollment_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX training_evidence_snapshot_id_school_id_enrollment_id_idx ON public.training_evidence_snapshot USING btree (id, school_id, enrollment_id);


--
-- Name: training_evidence_snapshot_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX training_evidence_snapshot_id_school_id_idx ON public.training_evidence_snapshot USING btree (id, school_id);


--
-- Name: training_program_id_school_id_category_code_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX training_program_id_school_id_category_code_idx ON public.training_program USING btree (id, school_id, category_code);


--
-- Name: training_program_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX training_program_id_school_id_idx ON public.training_program USING btree (id, school_id);


--
-- Name: training_program_version_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX training_program_version_id_school_id_idx ON public.training_program_version USING btree (id, school_id);


--
-- Name: training_program_version_id_school_id_program_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX training_program_version_id_school_id_program_id_idx ON public.training_program_version USING btree (id, school_id, program_id);


--
-- Name: training_program_version_program_id_version_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX training_program_version_program_id_version_school_id_idx ON public.training_program_version USING btree (program_id, version, school_id);


--
-- Name: training_topic_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX training_topic_id_school_id_idx ON public.training_topic USING btree (id, school_id);


--
-- Name: training_topic_id_school_id_program_version_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX training_topic_id_school_id_program_version_id_idx ON public.training_topic USING btree (id, school_id, program_version_id);


--
-- Name: training_topic_program_version_id_topic_key_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX training_topic_program_version_id_topic_key_school_id_idx ON public.training_topic USING btree (program_version_id, topic_key, school_id);


--
-- Name: ux_training_evidence_check_item; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_training_evidence_check_item ON public.training_evidence_check USING btree (snapshot_id, school_id, check_code, field_code, evidence_item_id) WHERE (evidence_item_id IS NOT NULL);


--
-- Name: ux_training_evidence_check_snapshot; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_training_evidence_check_snapshot ON public.training_evidence_check USING btree (snapshot_id, school_id, check_code, field_code) WHERE (evidence_item_id IS NULL);


--
-- Name: document_release_decision document_release_immutable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER document_release_immutable BEFORE DELETE OR UPDATE ON public.document_release_decision FOR EACH ROW EXECUTE FUNCTION public.prevent_document_release_mutation();


--
-- Name: training_evidence_snapshot lt_evidence_ready; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER lt_evidence_ready AFTER INSERT ON public.training_evidence_snapshot DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.lt_evidence_ready_guard();


--
-- Name: admission_requirement lt_frozen_curriculum; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER lt_frozen_curriculum BEFORE INSERT OR DELETE OR UPDATE ON public.admission_requirement FOR EACH ROW EXECUTE FUNCTION public.lt_draft_content_guard();


--
-- Name: assessment_definition_version lt_frozen_curriculum; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER lt_frozen_curriculum BEFORE INSERT OR DELETE OR UPDATE ON public.assessment_definition_version FOR EACH ROW EXECUTE FUNCTION public.lt_draft_content_guard();


--
-- Name: assessment_topic lt_frozen_curriculum; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER lt_frozen_curriculum BEFORE INSERT OR DELETE OR UPDATE ON public.assessment_topic FOR EACH ROW EXECUTE FUNCTION public.lt_draft_content_guard();


--
-- Name: lesson_planning_policy lt_frozen_curriculum; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER lt_frozen_curriculum BEFORE INSERT OR DELETE OR UPDATE ON public.lesson_planning_policy FOR EACH ROW EXECUTE FUNCTION public.lt_draft_content_guard();


--
-- Name: program_rule_source lt_frozen_curriculum; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER lt_frozen_curriculum BEFORE INSERT OR DELETE OR UPDATE ON public.program_rule_source FOR EACH ROW EXECUTE FUNCTION public.lt_draft_content_guard();


--
-- Name: training_topic lt_frozen_curriculum; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER lt_frozen_curriculum BEFORE INSERT OR DELETE OR UPDATE ON public.training_topic FOR EACH ROW EXECUTE FUNCTION public.lt_draft_content_guard();


--
-- Name: training_program lt_program_identity; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER lt_program_identity BEFORE UPDATE ON public.training_program FOR EACH ROW EXECUTE FUNCTION public.lt_program_identity_guard();


--
-- Name: training_program_version lt_program_version_frozen; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER lt_program_version_frozen BEFORE DELETE OR UPDATE ON public.training_program_version FOR EACH ROW EXECUTE FUNCTION public.lt_program_version_guard();


--
-- Name: readiness_decision lt_terminal_invalidation; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER lt_terminal_invalidation BEFORE UPDATE ON public.readiness_decision FOR EACH ROW EXECUTE FUNCTION public.lt_terminal_invalidation_guard();


--
-- Name: theory_record_version lt_theory_confirmation; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER lt_theory_confirmation BEFORE UPDATE ON public.theory_record_version FOR EACH ROW EXECUTE FUNCTION public.lt_theory_confirmation_guard();


--
-- Name: student_training lt_training_binding; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER lt_training_binding BEFORE UPDATE ON public.student_training FOR EACH ROW EXECUTE FUNCTION public.lt_training_binding_guard();


--
-- Name: admission_requirement admission_requirement_definition_version_id_school_id_prog_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admission_requirement
    ADD CONSTRAINT admission_requirement_definition_version_id_school_id_prog_fkey FOREIGN KEY (definition_version_id, school_id, program_version_id) REFERENCES public.assessment_definition_version(id, school_id, program_version_id) DEFERRABLE;


--
-- Name: admission_requirement admission_requirement_prerequisite_definition_version_id_s_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admission_requirement
    ADD CONSTRAINT admission_requirement_prerequisite_definition_version_id_s_fkey FOREIGN KEY (prerequisite_definition_version_id, school_id, program_version_id) REFERENCES public.assessment_definition_version(id, school_id, program_version_id) DEFERRABLE;


--
-- Name: assessment_definition assessment_definition_program_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_definition
    ADD CONSTRAINT assessment_definition_program_id_school_id_fkey FOREIGN KEY (program_id, school_id) REFERENCES public.training_program(id, school_id) DEFERRABLE;


--
-- Name: assessment_definition_version assessment_definition_version_definition_id_school_id_prog_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_definition_version
    ADD CONSTRAINT assessment_definition_version_definition_id_school_id_prog_fkey FOREIGN KEY (definition_id, school_id, program_id) REFERENCES public.assessment_definition(id, school_id, program_id) DEFERRABLE;


--
-- Name: assessment assessment_definition_version_id_school_id_program_version_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment
    ADD CONSTRAINT assessment_definition_version_id_school_id_program_version_fkey FOREIGN KEY (definition_version_id, school_id, program_version_id) REFERENCES public.assessment_definition_version(id, school_id, program_version_id) DEFERRABLE;


--
-- Name: assessment_definition_version assessment_definition_version_program_version_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_definition_version
    ADD CONSTRAINT assessment_definition_version_program_version_id_school_id_fkey FOREIGN KEY (program_version_id, school_id, program_id) REFERENCES public.training_program_version(id, school_id, program_id) DEFERRABLE;


--
-- Name: assessment assessment_enrollment_id_school_id_program_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment
    ADD CONSTRAINT assessment_enrollment_id_school_id_program_version_id_fkey FOREIGN KEY (enrollment_id, school_id, program_version_id) REFERENCES public.student_training(id, school_id, program_version_id) DEFERRABLE;


--
-- Name: assessment_readiness assessment_readiness_current_decision_id_school_id_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_readiness
    ADD CONSTRAINT assessment_readiness_current_decision_id_school_id_id_fkey FOREIGN KEY (current_decision_id, school_id, id) REFERENCES public.readiness_decision(id, school_id, readiness_id) DEFERRABLE;


--
-- Name: assessment_readiness assessment_readiness_current_evaluation_id_school_id_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_readiness
    ADD CONSTRAINT assessment_readiness_current_evaluation_id_school_id_id_fkey FOREIGN KEY (current_evaluation_id, school_id, id) REFERENCES public.readiness_evaluation(id, school_id, readiness_id) DEFERRABLE;


--
-- Name: assessment_readiness assessment_readiness_definition_version_id_school_id_progr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_readiness
    ADD CONSTRAINT assessment_readiness_definition_version_id_school_id_progr_fkey FOREIGN KEY (definition_version_id, school_id, program_version_id) REFERENCES public.assessment_definition_version(id, school_id, program_version_id) DEFERRABLE;


--
-- Name: assessment_readiness assessment_readiness_enrollment_id_school_id_program_versi_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_readiness
    ADD CONSTRAINT assessment_readiness_enrollment_id_school_id_program_versi_fkey FOREIGN KEY (enrollment_id, school_id, program_version_id) REFERENCES public.student_training(id, school_id, program_version_id) DEFERRABLE;


--
-- Name: assessment_result_version assessment_result_version_assessment_id_school_id_enrollme_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_result_version
    ADD CONSTRAINT assessment_result_version_assessment_id_school_id_enrollme_fkey FOREIGN KEY (assessment_id, school_id, enrollment_id, definition_version_id) REFERENCES public.assessment(id, school_id, enrollment_id, definition_version_id) DEFERRABLE;


--
-- Name: assessment_result_version assessment_result_version_readiness_decision_id_school_id__fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_result_version
    ADD CONSTRAINT assessment_result_version_readiness_decision_id_school_id__fkey FOREIGN KEY (readiness_decision_id, school_id, readiness_id) REFERENCES public.readiness_decision(id, school_id, readiness_id) DEFERRABLE;


--
-- Name: assessment_result_version assessment_result_version_readiness_id_school_id_enrollmen_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_result_version
    ADD CONSTRAINT assessment_result_version_readiness_id_school_id_enrollmen_fkey FOREIGN KEY (readiness_id, school_id, enrollment_id, definition_version_id) REFERENCES public.assessment_readiness(id, school_id, enrollment_id, definition_version_id) DEFERRABLE;


--
-- Name: assessment_topic assessment_topic_definition_version_id_school_id_program_v_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_topic
    ADD CONSTRAINT assessment_topic_definition_version_id_school_id_program_v_fkey FOREIGN KEY (definition_version_id, school_id, program_version_id) REFERENCES public.assessment_definition_version(id, school_id, program_version_id) DEFERRABLE;


--
-- Name: assessment_topic_result assessment_topic_result_assessment_topic_id_school_id_defi_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_topic_result
    ADD CONSTRAINT assessment_topic_result_assessment_topic_id_school_id_defi_fkey FOREIGN KEY (assessment_topic_id, school_id, definition_version_id) REFERENCES public.assessment_topic(id, school_id, definition_version_id) DEFERRABLE;


--
-- Name: assessment_topic_result assessment_topic_result_result_version_id_school_id_defini_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_topic_result
    ADD CONSTRAINT assessment_topic_result_result_version_id_school_id_defini_fkey FOREIGN KEY (result_version_id, school_id, definition_version_id) REFERENCES public.assessment_result_version(id, school_id, definition_version_id) DEFERRABLE;


--
-- Name: assessment_topic assessment_topic_topic_id_school_id_program_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_topic
    ADD CONSTRAINT assessment_topic_topic_id_school_id_program_version_id_fkey FOREIGN KEY (topic_id, school_id, program_version_id) REFERENCES public.training_topic(id, school_id, program_version_id) DEFERRABLE;


--
-- Name: learning_audit_event learning_audit_event_source_snapshot_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.learning_audit_event
    ADD CONSTRAINT learning_audit_event_source_snapshot_id_school_id_fkey FOREIGN KEY (source_snapshot_id, school_id) REFERENCES public.lesson_source_snapshot(id, school_id) DEFERRABLE;


--
-- Name: lesson_planning_policy lesson_planning_policy_program_version_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson_planning_policy
    ADD CONSTRAINT lesson_planning_policy_program_version_id_school_id_fkey FOREIGN KEY (program_version_id, school_id) REFERENCES public.training_program_version(id, school_id) DEFERRABLE;


--
-- Name: lesson_source_state lesson_source_state_current_snapshot_id_school_id_lesson_i_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson_source_state
    ADD CONSTRAINT lesson_source_state_current_snapshot_id_school_id_lesson_i_fkey FOREIGN KEY (current_snapshot_id, school_id, lesson_id) REFERENCES public.lesson_source_snapshot(id, school_id, lesson_id) DEFERRABLE;


--
-- Name: practical_record_response practical_record_response_record_version_id_school_id_reco_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.practical_record_response
    ADD CONSTRAINT practical_record_response_record_version_id_school_id_reco_fkey FOREIGN KEY (record_version_id, school_id, record_id) REFERENCES public.practical_record_version(id, school_id, record_id) DEFERRABLE;


--
-- Name: practical_record_topic practical_record_topic_record_version_id_school_id_program_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.practical_record_topic
    ADD CONSTRAINT practical_record_topic_record_version_id_school_id_program_fkey FOREIGN KEY (record_version_id, school_id, program_version_id) REFERENCES public.practical_record_version(id, school_id, program_version_id) DEFERRABLE;


--
-- Name: practical_record_topic practical_record_topic_topic_id_school_id_program_version__fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.practical_record_topic
    ADD CONSTRAINT practical_record_topic_topic_id_school_id_program_version__fkey FOREIGN KEY (topic_id, school_id, program_version_id) REFERENCES public.training_topic(id, school_id, program_version_id) DEFERRABLE;


--
-- Name: practical_record_version practical_record_version_enrollment_id_school_id_program_v_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.practical_record_version
    ADD CONSTRAINT practical_record_version_enrollment_id_school_id_program_v_fkey FOREIGN KEY (enrollment_id, school_id, program_version_id) REFERENCES public.student_training(id, school_id, program_version_id) DEFERRABLE;


--
-- Name: practical_record_version practical_record_version_record_id_school_id_enrollment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.practical_record_version
    ADD CONSTRAINT practical_record_version_record_id_school_id_enrollment_id_fkey FOREIGN KEY (record_id, school_id, enrollment_id, lesson_id) REFERENCES public.practical_training_record(id, school_id, enrollment_id, lesson_id) DEFERRABLE;


--
-- Name: practical_record_version practical_record_version_source_snapshot_id_school_id_less_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.practical_record_version
    ADD CONSTRAINT practical_record_version_source_snapshot_id_school_id_less_fkey FOREIGN KEY (source_snapshot_id, school_id, lesson_id) REFERENCES public.lesson_source_snapshot(id, school_id, lesson_id) DEFERRABLE;


--
-- Name: practical_training_record practical_training_record_current_version_id_school_id_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.practical_training_record
    ADD CONSTRAINT practical_training_record_current_version_id_school_id_id_fkey FOREIGN KEY (current_version_id, school_id, id) REFERENCES public.practical_record_version(id, school_id, record_id) DEFERRABLE;


--
-- Name: practical_training_record practical_training_record_enrollment_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.practical_training_record
    ADD CONSTRAINT practical_training_record_enrollment_id_school_id_fkey FOREIGN KEY (enrollment_id, school_id) REFERENCES public.student_training(id, school_id) DEFERRABLE;


--
-- Name: program_rule_source program_rule_source_program_version_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.program_rule_source
    ADD CONSTRAINT program_rule_source_program_version_id_school_id_fkey FOREIGN KEY (program_version_id, school_id) REFERENCES public.training_program_version(id, school_id) DEFERRABLE;


--
-- Name: readiness_decision readiness_decision_evaluation_id_school_id_enrollment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.readiness_decision
    ADD CONSTRAINT readiness_decision_evaluation_id_school_id_enrollment_id_fkey FOREIGN KEY (evaluation_id, school_id, enrollment_id) REFERENCES public.readiness_evaluation(id, school_id, enrollment_id) DEFERRABLE;


--
-- Name: readiness_decision readiness_decision_evaluation_id_school_id_readiness_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.readiness_decision
    ADD CONSTRAINT readiness_decision_evaluation_id_school_id_readiness_id_fkey FOREIGN KEY (evaluation_id, school_id, readiness_id) REFERENCES public.readiness_evaluation(id, school_id, readiness_id) DEFERRABLE;


--
-- Name: readiness_evaluation readiness_evaluation_readiness_id_school_id_definition_ver_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.readiness_evaluation
    ADD CONSTRAINT readiness_evaluation_readiness_id_school_id_definition_ver_fkey FOREIGN KEY (readiness_id, school_id, definition_version_id) REFERENCES public.assessment_readiness(id, school_id, definition_version_id) DEFERRABLE;


--
-- Name: readiness_evaluation readiness_evaluation_readiness_id_school_id_enrollment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.readiness_evaluation
    ADD CONSTRAINT readiness_evaluation_readiness_id_school_id_enrollment_id_fkey FOREIGN KEY (readiness_id, school_id, enrollment_id) REFERENCES public.assessment_readiness(id, school_id, enrollment_id) DEFERRABLE;


--
-- Name: readiness_evidence_basis readiness_evidence_basis_evaluation_id_school_id_enrollmen_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.readiness_evidence_basis
    ADD CONSTRAINT readiness_evidence_basis_evaluation_id_school_id_enrollmen_fkey FOREIGN KEY (evaluation_id, school_id, enrollment_id) REFERENCES public.readiness_evaluation(id, school_id, enrollment_id) DEFERRABLE;


--
-- Name: readiness_evidence_basis readiness_evidence_basis_practical_record_version_id_schoo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.readiness_evidence_basis
    ADD CONSTRAINT readiness_evidence_basis_practical_record_version_id_schoo_fkey FOREIGN KEY (practical_record_version_id, school_id, enrollment_id) REFERENCES public.practical_record_version(id, school_id, enrollment_id) DEFERRABLE;


--
-- Name: readiness_evidence_basis readiness_evidence_basis_result_version_id_school_id_enrol_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.readiness_evidence_basis
    ADD CONSTRAINT readiness_evidence_basis_result_version_id_school_id_enrol_fkey FOREIGN KEY (result_version_id, school_id, enrollment_id) REFERENCES public.assessment_result_version(id, school_id, enrollment_id) DEFERRABLE;


--
-- Name: readiness_evidence_basis readiness_evidence_basis_theory_attendance_id_school_id_en_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.readiness_evidence_basis
    ADD CONSTRAINT readiness_evidence_basis_theory_attendance_id_school_id_en_fkey FOREIGN KEY (theory_attendance_id, school_id, enrollment_id) REFERENCES public.theory_attendance(id, school_id, enrollment_id) DEFERRABLE;


--
-- Name: readiness_requirement_result readiness_requirement_result_evaluation_id_school_id_defin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.readiness_requirement_result
    ADD CONSTRAINT readiness_requirement_result_evaluation_id_school_id_defin_fkey FOREIGN KEY (evaluation_id, school_id, definition_version_id) REFERENCES public.readiness_evaluation(id, school_id, definition_version_id) DEFERRABLE;


--
-- Name: readiness_requirement_result readiness_requirement_result_requirement_id_school_id_defi_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.readiness_requirement_result
    ADD CONSTRAINT readiness_requirement_result_requirement_id_school_id_defi_fkey FOREIGN KEY (requirement_id, school_id, definition_version_id) REFERENCES public.admission_requirement(id, school_id, definition_version_id) DEFERRABLE;


--
-- Name: reporting_declaration reporting_declaration_snapshot_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reporting_declaration
    ADD CONSTRAINT reporting_declaration_snapshot_id_school_id_fkey FOREIGN KEY (snapshot_id, school_id) REFERENCES public.training_evidence_snapshot(id, school_id) DEFERRABLE;


--
-- Name: student_training student_training_program_version_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_training
    ADD CONSTRAINT student_training_program_version_id_school_id_fkey FOREIGN KEY (program_version_id, school_id) REFERENCES public.training_program_version(id, school_id) DEFERRABLE;


--
-- Name: theory_attendance theory_attendance_enrollment_id_school_id_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.theory_attendance
    ADD CONSTRAINT theory_attendance_enrollment_id_school_id_student_id_fkey FOREIGN KEY (enrollment_id, school_id, student_id) REFERENCES public.student_training(id, school_id, student_id) DEFERRABLE;


--
-- Name: theory_attendance theory_attendance_record_version_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.theory_attendance
    ADD CONSTRAINT theory_attendance_record_version_id_school_id_fkey FOREIGN KEY (record_version_id, school_id) REFERENCES public.theory_record_version(id, school_id) DEFERRABLE;


--
-- Name: theory_record_version theory_record_version_record_id_school_id_lesson_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.theory_record_version
    ADD CONSTRAINT theory_record_version_record_id_school_id_lesson_id_fkey FOREIGN KEY (record_id, school_id, lesson_id) REFERENCES public.theory_training_record(id, school_id, lesson_id) DEFERRABLE;


--
-- Name: theory_record_version theory_record_version_source_snapshot_id_school_id_lesson__fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.theory_record_version
    ADD CONSTRAINT theory_record_version_source_snapshot_id_school_id_lesson__fkey FOREIGN KEY (source_snapshot_id, school_id, lesson_id) REFERENCES public.lesson_source_snapshot(id, school_id, lesson_id) DEFERRABLE;


--
-- Name: theory_training_record theory_training_record_current_version_id_school_id_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.theory_training_record
    ADD CONSTRAINT theory_training_record_current_version_id_school_id_id_fkey FOREIGN KEY (current_version_id, school_id, id) REFERENCES public.theory_record_version(id, school_id, record_id) DEFERRABLE;


--
-- Name: training_evidence_check training_evidence_check_evidence_item_id_school_id_snapsho_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_evidence_check
    ADD CONSTRAINT training_evidence_check_evidence_item_id_school_id_snapsho_fkey FOREIGN KEY (evidence_item_id, school_id, snapshot_id) REFERENCES public.training_evidence_item(id, school_id, snapshot_id) DEFERRABLE;


--
-- Name: training_evidence_check training_evidence_check_snapshot_id_school_id_enrollment_i_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_evidence_check
    ADD CONSTRAINT training_evidence_check_snapshot_id_school_id_enrollment_i_fkey FOREIGN KEY (snapshot_id, school_id, enrollment_id) REFERENCES public.training_evidence_snapshot(id, school_id, enrollment_id) DEFERRABLE;


--
-- Name: training_evidence_item training_evidence_item_practical_record_version_id_school__fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_evidence_item
    ADD CONSTRAINT training_evidence_item_practical_record_version_id_school__fkey FOREIGN KEY (practical_record_version_id, school_id, enrollment_id) REFERENCES public.practical_record_version(id, school_id, enrollment_id) DEFERRABLE;


--
-- Name: training_evidence_item training_evidence_item_readiness_decision_id_school_id_enr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_evidence_item
    ADD CONSTRAINT training_evidence_item_readiness_decision_id_school_id_enr_fkey FOREIGN KEY (readiness_decision_id, school_id, enrollment_id) REFERENCES public.readiness_decision(id, school_id, enrollment_id) DEFERRABLE;


--
-- Name: training_evidence_item training_evidence_item_result_version_id_school_id_enrollm_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_evidence_item
    ADD CONSTRAINT training_evidence_item_result_version_id_school_id_enrollm_fkey FOREIGN KEY (result_version_id, school_id, enrollment_id) REFERENCES public.assessment_result_version(id, school_id, enrollment_id) DEFERRABLE;


--
-- Name: training_evidence_item training_evidence_item_snapshot_id_school_id_enrollment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_evidence_item
    ADD CONSTRAINT training_evidence_item_snapshot_id_school_id_enrollment_id_fkey FOREIGN KEY (snapshot_id, school_id, enrollment_id) REFERENCES public.training_evidence_snapshot(id, school_id, enrollment_id) DEFERRABLE;


--
-- Name: training_evidence_item training_evidence_item_theory_attendance_id_school_id_enro_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_evidence_item
    ADD CONSTRAINT training_evidence_item_theory_attendance_id_school_id_enro_fkey FOREIGN KEY (theory_attendance_id, school_id, enrollment_id) REFERENCES public.theory_attendance(id, school_id, enrollment_id) DEFERRABLE;


--
-- Name: training_evidence_snapshot training_evidence_snapshot_enrollment_id_school_id_program_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_evidence_snapshot
    ADD CONSTRAINT training_evidence_snapshot_enrollment_id_school_id_program_fkey FOREIGN KEY (enrollment_id, school_id, program_version_id) REFERENCES public.student_training(id, school_id, program_version_id) DEFERRABLE;


--
-- Name: training_program_version training_program_version_program_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_program_version
    ADD CONSTRAINT training_program_version_program_id_school_id_fkey FOREIGN KEY (program_id, school_id) REFERENCES public.training_program(id, school_id) DEFERRABLE;


--
-- Name: training_topic training_topic_program_version_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_topic
    ADD CONSTRAINT training_topic_program_version_id_school_id_fkey FOREIGN KEY (program_version_id, school_id) REFERENCES public.training_program_version(id, school_id) DEFERRABLE;


--
-- Name: admission_requirement; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.admission_requirement ENABLE ROW LEVEL SECURITY;

--
-- Name: assessment; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.assessment ENABLE ROW LEVEL SECURITY;

--
-- Name: assessment_definition; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.assessment_definition ENABLE ROW LEVEL SECURITY;

--
-- Name: assessment_definition_version; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.assessment_definition_version ENABLE ROW LEVEL SECURITY;

--
-- Name: assessment_readiness; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.assessment_readiness ENABLE ROW LEVEL SECURITY;

--
-- Name: assessment_result_version; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.assessment_result_version ENABLE ROW LEVEL SECURITY;

--
-- Name: assessment_topic; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.assessment_topic ENABLE ROW LEVEL SECURITY;

--
-- Name: assessment_topic_result; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.assessment_topic_result ENABLE ROW LEVEL SECURITY;

--
-- Name: outbox_message delivery_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY delivery_scope ON public.outbox_message TO v_learning_tracking_delivery USING (true) WITH CHECK (true);


--
-- Name: document_release_decision; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.document_release_decision ENABLE ROW LEVEL SECURITY;

--
-- Name: document_release_decision document_release_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY document_release_scope ON public.document_release_decision USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: enrollment_source_state; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.enrollment_source_state ENABLE ROW LEVEL SECURITY;

--
-- Name: inbox_message; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.inbox_message ENABLE ROW LEVEL SECURITY;

--
-- Name: learning_audit_event; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.learning_audit_event ENABLE ROW LEVEL SECURITY;

--
-- Name: learning_operation; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.learning_operation ENABLE ROW LEVEL SECURITY;

--
-- Name: lesson_planning_policy; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.lesson_planning_policy ENABLE ROW LEVEL SECURITY;

--
-- Name: lesson_source_snapshot; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.lesson_source_snapshot ENABLE ROW LEVEL SECURITY;

--
-- Name: lesson_source_state; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.lesson_source_state ENABLE ROW LEVEL SECURITY;

--
-- Name: outbox_message; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.outbox_message ENABLE ROW LEVEL SECURITY;

--
-- Name: policy_attestation; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.policy_attestation ENABLE ROW LEVEL SECURITY;

--
-- Name: practical_record_response; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.practical_record_response ENABLE ROW LEVEL SECURITY;

--
-- Name: practical_record_topic; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.practical_record_topic ENABLE ROW LEVEL SECURITY;

--
-- Name: practical_record_version; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.practical_record_version ENABLE ROW LEVEL SECURITY;

--
-- Name: practical_training_record; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.practical_training_record ENABLE ROW LEVEL SECURITY;

--
-- Name: program_rule_source; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.program_rule_source ENABLE ROW LEVEL SECURITY;

--
-- Name: readiness_decision; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.readiness_decision ENABLE ROW LEVEL SECURITY;

--
-- Name: readiness_evaluation; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.readiness_evaluation ENABLE ROW LEVEL SECURITY;

--
-- Name: readiness_evidence_basis; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.readiness_evidence_basis ENABLE ROW LEVEL SECURITY;

--
-- Name: readiness_requirement_result; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.readiness_requirement_result ENABLE ROW LEVEL SECURITY;

--
-- Name: student_training reconciliation_enrollments; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY reconciliation_enrollments ON public.student_training FOR SELECT TO v_learning_tracking_delivery USING (true);


--
-- Name: lesson_source_state reconciliation_sources; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY reconciliation_sources ON public.lesson_source_state FOR SELECT TO v_learning_tracking_delivery USING (true);


--
-- Name: reporting_declaration; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.reporting_declaration ENABLE ROW LEVEL SECURITY;

--
-- Name: school_source_state; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.school_source_state ENABLE ROW LEVEL SECURITY;

--
-- Name: student_training; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.student_training ENABLE ROW LEVEL SECURITY;

--
-- Name: admission_requirement tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.admission_requirement TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: assessment tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.assessment TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: assessment_definition tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.assessment_definition TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: assessment_definition_version tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.assessment_definition_version TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: assessment_readiness tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.assessment_readiness TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: assessment_result_version tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.assessment_result_version TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: assessment_topic tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.assessment_topic TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: assessment_topic_result tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.assessment_topic_result TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: enrollment_source_state tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.enrollment_source_state TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: inbox_message tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.inbox_message TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: learning_audit_event tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.learning_audit_event TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: learning_operation tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.learning_operation TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: lesson_planning_policy tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.lesson_planning_policy TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: lesson_source_snapshot tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.lesson_source_snapshot TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: lesson_source_state tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.lesson_source_state TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: outbox_message tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.outbox_message TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: policy_attestation tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.policy_attestation TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: practical_record_response tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.practical_record_response TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: practical_record_topic tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.practical_record_topic TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: practical_record_version tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.practical_record_version TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: practical_training_record tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.practical_training_record TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: program_rule_source tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.program_rule_source TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: readiness_decision tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.readiness_decision TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: readiness_evaluation tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.readiness_evaluation TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: readiness_evidence_basis tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.readiness_evidence_basis TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: readiness_requirement_result tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.readiness_requirement_result TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: reporting_declaration tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.reporting_declaration TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: school_source_state tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.school_source_state TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: student_training tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.student_training TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: theory_attendance tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.theory_attendance TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: theory_record_version tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.theory_record_version TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: theory_training_record tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.theory_training_record TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: training_evidence_check tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.training_evidence_check TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: training_evidence_item tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.training_evidence_item TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: training_evidence_snapshot tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.training_evidence_snapshot TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: training_program tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.training_program TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: training_program_version tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.training_program_version TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: training_topic tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.training_topic TO v_learning_tracking_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: theory_attendance; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.theory_attendance ENABLE ROW LEVEL SECURITY;

--
-- Name: theory_record_version; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.theory_record_version ENABLE ROW LEVEL SECURITY;

--
-- Name: theory_training_record; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.theory_training_record ENABLE ROW LEVEL SECURITY;

--
-- Name: training_evidence_check; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.training_evidence_check ENABLE ROW LEVEL SECURITY;

--
-- Name: training_evidence_item; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.training_evidence_item ENABLE ROW LEVEL SECURITY;

--
-- Name: training_evidence_snapshot; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.training_evidence_snapshot ENABLE ROW LEVEL SECURITY;

--
-- Name: training_program; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.training_program ENABLE ROW LEVEL SECURITY;

--
-- Name: training_program_version; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.training_program_version ENABLE ROW LEVEL SECURITY;

--
-- Name: training_topic; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.training_topic ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--

\unrestrict w1KhA94qx2UnTXgX50X9LJjHHZibURfk3YX2L3HZJ7aTyA1mot6du7ggqhrVzva

