--
-- PostgreSQL database dump
--

\restrict mneWWRTDF3LcgSFfwYWjnLphgqLgGCQXKpuKQkaPJz4tgEFux9voiNx0b4Lo1rT

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
-- Name: sm_channel; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.sm_channel AS ENUM (
    'Web',
    'MCP',
    'Internal'
);


--
-- Name: sm_enrollment_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.sm_enrollment_status AS ENUM (
    'Active',
    'Completed',
    'Withdrawn',
    'Transferred',
    'Cancelled'
);


--
-- Name: sm_invitation_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.sm_invitation_status AS ENUM (
    'Pending',
    'Accepted',
    'Revoked'
);


--
-- Name: sm_operation_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.sm_operation_status AS ENUM (
    'Pending',
    'Committed',
    'Rejected',
    'ReconciliationPending'
);


--
-- Name: sm_permission; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.sm_permission AS ENUM (
    'Assessor',
    'SchoolRuleOwner'
);


--
-- Name: sm_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.sm_role AS ENUM (
    'Student',
    'Teacher',
    'Administrator'
);


--
-- Name: sm_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.sm_status AS ENUM (
    'Active',
    'Inactive'
);


--
-- Name: integration_inbox_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.integration_inbox_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    BEGIN RAISE EXCEPTION 'Integration inbox is append-only' USING ERRCODE='23514'; END $$;


--
-- Name: membership_review_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.membership_review_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    BEGIN
     IF TG_OP='DELETE' OR OLD.resolved_at IS NOT NULL THEN RAISE EXCEPTION 'Membership review history is immutable' USING ERRCODE='23514'; END IF;
     IF (NEW.review_id,NEW.school_id,NEW.target_kind,NEW.target_id,NEW.reason_code,NEW.subject_role,NEW.subject_user_id,NEW.source_event_id,NEW.raised_at)
        IS DISTINCT FROM (OLD.review_id,OLD.school_id,OLD.target_kind,OLD.target_id,OLD.reason_code,OLD.subject_role,OLD.subject_user_id,OLD.source_event_id,OLD.raised_at)
     THEN RAISE EXCEPTION 'Membership review identity is immutable' USING ERRCODE='23514'; END IF;
     RETURN NEW;
    END $$;


--
-- Name: school_coordination_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.school_coordination_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$ BEGIN
     IF OLD.state IN ('Committed','Aborted') OR (to_jsonb(NEW)-ARRAY['transition_json','payload_hash','state','lease_id','lease_until'])
     IS DISTINCT FROM (to_jsonb(OLD)-ARRAY['transition_json','payload_hash','state','lease_id','lease_until']) OR
     (OLD.transition_json<>'' AND (OLD.transition_json IS DISTINCT FROM NEW.transition_json OR OLD.payload_hash IS DISTINCT FROM NEW.payload_hash)) THEN
     RAISE EXCEPTION 'Immutable School coordination intent' USING ERRCODE='23514'; END IF;
     RETURN NEW;
    END $$;


--
-- Name: school_evidence_immutable(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.school_evidence_immutable() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$ BEGIN
     RAISE EXCEPTION 'School evidence is append-only' USING ERRCODE='23514';
    END $$;


--
-- Name: school_invitation_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.school_invitation_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$ BEGIN
     IF (to_jsonb(NEW)-ARRAY['status','revision','accepted_operation_id','accepted_at','result_membership_id','result_enrollment_id','revoked_operation_id','revoked_at'])
      IS DISTINCT FROM (to_jsonb(OLD)-ARRAY['status','revision','accepted_operation_id','accepted_at','result_membership_id','result_enrollment_id','revoked_operation_id','revoked_at'])
      OR OLD.status <> 'Pending' OR NEW.status NOT IN ('Accepted','Revoked') OR NEW.revision <> OLD.revision+1 THEN
      RAISE EXCEPTION 'Invalid invitation transition or immutable binding change' USING ERRCODE='23514';
     END IF;
     RETURN NEW;
    END $$;


--
-- Name: school_operation_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.school_operation_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$ BEGIN
     IF OLD.status IN ('Committed','Rejected') OR
     (to_jsonb(NEW)-ARRAY['status','resolved_at','resulting_revision','resulting_school_revision','outcome_code'])
     IS DISTINCT FROM (to_jsonb(OLD)-ARRAY['status','resolved_at','resulting_revision','resulting_school_revision','outcome_code']) THEN
      RAISE EXCEPTION 'Immutable school operation' USING ERRCODE='23514';
     END IF;
     RETURN NEW;
    END $$;


--
-- Name: school_pending_coordination(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.school_pending_coordination() RETURNS TABLE(school_id uuid, operation_id uuid)
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
     SELECT c.school_id,c.operation_id FROM public.school_coordination c WHERE c.state IN ('Pending','LocalApplied','AbortPending') ORDER BY c.effective_from,c.operation_id;
    $$;


--
-- Name: school_self_discovery(uuid, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.school_self_discovery(p_user uuid, p_student uuid) RETURNS TABLE(school_id uuid)
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
     SELECT m.school_id FROM public.school_membership m WHERE m.user_id=p_user
     UNION SELECT i.school_id FROM public.school_invitation i WHERE i.target_user_id=p_user
     UNION SELECT e.school_id FROM public.student_enrollment e WHERE p_student IS NOT NULL AND e.student_id=p_student;
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
-- Name: branch; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.branch (
    branch_id uuid NOT NULL,
    school_id uuid NOT NULL,
    name character varying(200) NOT NULL,
    address_line character varying(300),
    city character varying(120),
    postal_code character varying(30),
    country_code character varying(2),
    status public.sm_status DEFAULT 'Active'::public.sm_status NOT NULL,
    revision bigint DEFAULT 1 NOT NULL,
    last_operation_id uuid NOT NULL,
    CONSTRAINT branch_name_revision CHECK (((length(TRIM(BOTH FROM name)) > 0) AND (revision > 0)))
);


--
-- Name: enrollment_status_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.enrollment_status_history (
    enrollment_id uuid NOT NULL,
    school_id uuid NOT NULL,
    enrollment_revision bigint NOT NULL,
    from_status public.sm_enrollment_status,
    to_status public.sm_enrollment_status NOT NULL,
    effective_at timestamp with time zone NOT NULL,
    recorded_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    operation_id uuid NOT NULL,
    completion_evidence_id uuid,
    completion_dependency_revision bigint,
    completion_verified_at timestamp with time zone,
    CONSTRAINT completion_basis_required CHECK (((to_status <> 'Completed'::public.sm_enrollment_status) OR ((completion_evidence_id IS NOT NULL) AND (completion_dependency_revision IS NOT NULL) AND (completion_dependency_revision > 0) AND (completion_verified_at IS NOT NULL)))),
    CONSTRAINT enrollment_history_immediate_terminal CHECK ((isfinite(effective_at) AND isfinite(recorded_at) AND ((to_status = 'Active'::public.sm_enrollment_status) OR (effective_at = recorded_at)))),
    CONSTRAINT enrollment_history_revision CHECK ((enrollment_revision > 0)),
    CONSTRAINT enrollment_history_transition CHECK ((((from_status IS NULL) AND (to_status = 'Active'::public.sm_enrollment_status)) OR ((from_status IS NOT NULL) AND (from_status = 'Active'::public.sm_enrollment_status) AND (to_status <> 'Active'::public.sm_enrollment_status))))
);


--
-- Name: group_roster_member; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_roster_member (
    group_id uuid NOT NULL,
    school_id uuid NOT NULL,
    membership_revision bigint NOT NULL,
    membership_id uuid NOT NULL,
    enrollment_id uuid NOT NULL,
    student_id uuid NOT NULL,
    enrollment_revision bigint NOT NULL,
    enrollment_status public.sm_enrollment_status NOT NULL,
    category_code character varying(20) NOT NULL,
    enrollment_started_at timestamp with time zone NOT NULL,
    enrollment_ended_at timestamp with time zone,
    joined_at timestamp with time zone NOT NULL,
    left_at timestamp with time zone,
    CONSTRAINT roster_enrollment_basis CHECK (((enrollment_revision > 0) AND (length(TRIM(BOTH FROM category_code)) > 0))),
    CONSTRAINT roster_enrollment_period CHECK (((enrollment_ended_at IS NULL) OR (enrollment_ended_at > enrollment_started_at))),
    CONSTRAINT roster_enrollment_shape CHECK ((((enrollment_status = 'Active'::public.sm_enrollment_status) AND (enrollment_ended_at IS NULL)) OR ((enrollment_status <> 'Active'::public.sm_enrollment_status) AND (enrollment_ended_at IS NOT NULL)))),
    CONSTRAINT roster_membership_period CHECK (((left_at IS NULL) OR (left_at > joined_at)))
);


--
-- Name: group_roster_revision; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_roster_revision (
    group_id uuid NOT NULL,
    school_id uuid NOT NULL,
    membership_revision bigint NOT NULL,
    recorded_at timestamp with time zone NOT NULL,
    operation_id uuid NOT NULL,
    CONSTRAINT roster_revision_positive CHECK ((membership_revision > 0))
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
-- Name: membership_permission_grant; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.membership_permission_grant (
    grant_id uuid NOT NULL,
    school_id uuid NOT NULL,
    membership_id uuid NOT NULL,
    permission public.sm_permission NOT NULL,
    started_at timestamp with time zone NOT NULL,
    ended_at timestamp with time zone,
    granted_operation_id uuid NOT NULL,
    ended_operation_id uuid,
    CONSTRAINT grant_end_evidence CHECK (((ended_at IS NULL) = (ended_operation_id IS NULL))),
    CONSTRAINT grant_period CHECK (((ended_at IS NULL) OR (ended_at > started_at))),
    CONSTRAINT sm_grant_finite CHECK ((isfinite(started_at) AND ((ended_at IS NULL) OR isfinite(ended_at))))
);


--
-- Name: membership_review; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.membership_review (
    review_id uuid NOT NULL,
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
    CONSTRAINT membership_review_resolution CHECK ((((resolved_at IS NULL) = (resolved_by_user_id IS NULL)) AND ((resolved_at IS NULL) = (resolution_note IS NULL)) AND ((resolved_at IS NULL) OR (resolved_at >= raised_at)))),
    CONSTRAINT membership_review_role CHECK (((subject_role)::text = ANY ((ARRAY['Student'::character varying, 'Teacher'::character varying, 'Administrator'::character varying])::text[]))),
    CONSTRAINT membership_review_target CHECK (((target_kind)::text = ANY ((ARRAY['Membership'::character varying, 'Enrollment'::character varying])::text[])))
);


--
-- Name: school; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.school (
    school_id uuid NOT NULL,
    name character varying(200) NOT NULL,
    status public.sm_status DEFAULT 'Active'::public.sm_status NOT NULL,
    revision bigint DEFAULT 1 NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT school_name_nonempty CHECK ((length(TRIM(BOTH FROM name)) > 0)),
    CONSTRAINT school_revision_time CHECK (((revision > 0) AND (updated_at >= created_at)))
);


--
-- Name: school_coordination; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.school_coordination (
    operation_id uuid NOT NULL,
    school_id uuid NOT NULL,
    fingerprint text NOT NULL,
    command_json text NOT NULL,
    transition_json text NOT NULL,
    payload_hash text NOT NULL,
    state text NOT NULL,
    before_revision bigint NOT NULL,
    after_revision bigint NOT NULL,
    effective_from timestamp with time zone NOT NULL,
    actor_user_id uuid NOT NULL,
    result_id uuid NOT NULL,
    lease_id uuid,
    lease_until timestamp with time zone
);


--
-- Name: school_invitation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.school_invitation (
    invitation_id uuid NOT NULL,
    school_id uuid NOT NULL,
    target_user_id uuid NOT NULL,
    role public.sm_role NOT NULL,
    category_code character varying(20),
    issuer_membership_id uuid,
    status public.sm_invitation_status DEFAULT 'Pending'::public.sm_invitation_status NOT NULL,
    revision bigint DEFAULT 1 NOT NULL,
    created_at timestamp with time zone NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    issued_operation_id uuid NOT NULL,
    accepted_operation_id uuid,
    accepted_at timestamp with time zone,
    result_membership_id uuid,
    result_enrollment_id uuid,
    revoked_operation_id uuid,
    revoked_at timestamp with time zone,
    CONSTRAINT invitation_accept_time CHECK (((accepted_at IS NULL) OR (isfinite(accepted_at) AND (accepted_at >= created_at) AND (accepted_at < expires_at)))),
    CONSTRAINT invitation_admin_platform_basis CHECK (((role <> 'Administrator'::public.sm_role) OR (issuer_membership_id IS NULL))),
    CONSTRAINT invitation_category_shape CHECK ((((role = 'Student'::public.sm_role) AND (category_code IS NOT NULL) AND (length(TRIM(BOTH FROM category_code)) > 0)) OR ((role <> 'Student'::public.sm_role) AND (category_code IS NULL)))),
    CONSTRAINT invitation_revision_expiry CHECK (((revision > 0) AND isfinite(created_at) AND isfinite(expires_at) AND (expires_at > created_at))),
    CONSTRAINT invitation_revoke_time CHECK (((revoked_at IS NULL) OR (isfinite(revoked_at) AND (revoked_at >= created_at)))),
    CONSTRAINT invitation_state_shape CHECK ((((status = 'Pending'::public.sm_invitation_status) AND (accepted_operation_id IS NULL) AND (accepted_at IS NULL) AND (result_membership_id IS NULL) AND (result_enrollment_id IS NULL) AND (revoked_operation_id IS NULL) AND (revoked_at IS NULL)) OR ((status = 'Accepted'::public.sm_invitation_status) AND (accepted_operation_id IS NOT NULL) AND (accepted_at IS NOT NULL) AND (result_membership_id IS NOT NULL) AND (revoked_operation_id IS NULL) AND (revoked_at IS NULL) AND (((role = 'Student'::public.sm_role) AND (result_enrollment_id IS NOT NULL)) OR ((role <> 'Student'::public.sm_role) AND (result_enrollment_id IS NULL)))) OR ((status = 'Revoked'::public.sm_invitation_status) AND (revoked_operation_id IS NOT NULL) AND (revoked_at IS NOT NULL) AND (accepted_operation_id IS NULL) AND (accepted_at IS NULL) AND (result_membership_id IS NULL) AND (result_enrollment_id IS NULL))))
);


--
-- Name: school_learning_outbox; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.school_learning_outbox (
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
    next_attempt_at timestamp with time zone NOT NULL
);


--
-- Name: school_membership; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.school_membership (
    membership_id uuid NOT NULL,
    school_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role public.sm_role NOT NULL,
    started_at timestamp with time zone NOT NULL,
    ended_at timestamp with time zone,
    revision bigint DEFAULT 1 NOT NULL,
    last_operation_id uuid NOT NULL,
    CONSTRAINT membership_period CHECK (((ended_at IS NULL) OR (ended_at > started_at))),
    CONSTRAINT membership_revision CHECK ((revision > 0)),
    CONSTRAINT sm_membership_finite CHECK ((isfinite(started_at) AND ((ended_at IS NULL) OR isfinite(ended_at))))
);


--
-- Name: school_operation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.school_operation (
    operation_id uuid NOT NULL,
    school_id uuid NOT NULL,
    command_name character varying(80) NOT NULL,
    target_kind character varying(60) NOT NULL,
    target_id uuid NOT NULL,
    expected_revision bigint,
    resulting_revision bigint,
    coordination_required boolean DEFAULT false NOT NULL,
    expected_school_revision bigint,
    resulting_school_revision bigint,
    actor_user_id uuid NOT NULL,
    channel public.sm_channel NOT NULL,
    status public.sm_operation_status NOT NULL,
    request_fingerprint character varying(64) NOT NULL,
    requested_at timestamp with time zone NOT NULL,
    resolved_at timestamp with time zone,
    reason text,
    outcome_code character varying(80),
    authority_basis character varying(200) NOT NULL,
    confirmation_id uuid,
    confirmed_at timestamp with time zone,
    CONSTRAINT operation_confirmation_pair CHECK (((confirmation_id IS NULL) = (confirmed_at IS NULL))),
    CONSTRAINT operation_coordinated_commit CHECK (((status <> 'Committed'::public.sm_operation_status) OR (coordination_required = false) OR (resulting_school_revision IS NOT NULL))),
    CONSTRAINT operation_coordination_revisions CHECK ((((coordination_required = false) AND (expected_school_revision IS NULL) AND (resulting_school_revision IS NULL)) OR ((coordination_required = true) AND (expected_school_revision IS NOT NULL) AND (expected_school_revision > 0) AND ((resulting_school_revision IS NULL) OR (resulting_school_revision = (expected_school_revision + 1)))))),
    CONSTRAINT operation_expected_revision CHECK (((expected_revision IS NULL) OR (expected_revision > 0))),
    CONSTRAINT operation_mcp_confirmation CHECK (((status <> 'Committed'::public.sm_operation_status) OR (channel <> 'MCP'::public.sm_channel) OR (confirmation_id IS NOT NULL))),
    CONSTRAINT operation_required_metadata CHECK (((length(TRIM(BOTH FROM command_name)) > 0) AND (length(TRIM(BOTH FROM authority_basis)) > 0) AND (length((request_fingerprint)::text) = 64))),
    CONSTRAINT operation_resolution_shape CHECK ((((status = ANY (ARRAY['Committed'::public.sm_operation_status, 'Rejected'::public.sm_operation_status])) AND (resolved_at IS NOT NULL)) OR ((status = ANY (ARRAY['Pending'::public.sm_operation_status, 'ReconciliationPending'::public.sm_operation_status])) AND (resolved_at IS NULL)))),
    CONSTRAINT operation_resolution_time CHECK (((resolved_at IS NULL) OR (resolved_at >= requested_at))),
    CONSTRAINT operation_result_revision CHECK (((resulting_revision IS NULL) OR (resulting_revision > 0)))
);


--
-- Name: student_enrollment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.student_enrollment (
    enrollment_id uuid NOT NULL,
    school_id uuid NOT NULL,
    student_id uuid NOT NULL,
    category_code character varying(20) NOT NULL,
    started_at timestamp with time zone NOT NULL,
    ended_at timestamp with time zone,
    status public.sm_enrollment_status DEFAULT 'Active'::public.sm_enrollment_status NOT NULL,
    status_changed_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    revision bigint DEFAULT 1 NOT NULL,
    last_operation_id uuid NOT NULL,
    CONSTRAINT enrollment_category_revision CHECK (((length(TRIM(BOTH FROM category_code)) > 0) AND (revision > 0))),
    CONSTRAINT enrollment_finite_lifecycle CHECK ((isfinite(started_at) AND isfinite(status_changed_at) AND ((ended_at IS NULL) OR isfinite(ended_at)))),
    CONSTRAINT enrollment_lifecycle_shape CHECK ((((status = 'Active'::public.sm_enrollment_status) AND (ended_at IS NULL)) OR ((status <> 'Active'::public.sm_enrollment_status) AND (ended_at IS NOT NULL) AND (ended_at = status_changed_at)))),
    CONSTRAINT enrollment_period CHECK (((ended_at IS NULL) OR (ended_at > started_at)))
);


--
-- Name: student_group_membership; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.student_group_membership (
    membership_id uuid NOT NULL,
    school_id uuid NOT NULL,
    enrollment_id uuid NOT NULL,
    group_id uuid NOT NULL,
    joined_at timestamp with time zone NOT NULL,
    left_at timestamp with time zone,
    association_program_version_id uuid NOT NULL,
    association_verified_at timestamp with time zone NOT NULL,
    revision bigint DEFAULT 1 NOT NULL,
    last_operation_id uuid NOT NULL,
    CONSTRAINT association_revision CHECK ((revision > 0)),
    CONSTRAINT sm_student_group_finite CHECK ((isfinite(joined_at) AND ((left_at IS NULL) OR isfinite(left_at)))),
    CONSTRAINT student_group_period CHECK (((left_at IS NULL) OR (left_at > joined_at)))
);


--
-- Name: teacher_group_assignment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teacher_group_assignment (
    assignment_id uuid NOT NULL,
    school_id uuid NOT NULL,
    teacher_id uuid NOT NULL,
    group_id uuid NOT NULL,
    assigned_at timestamp with time zone NOT NULL,
    ended_at timestamp with time zone,
    revision bigint DEFAULT 1 NOT NULL,
    last_operation_id uuid NOT NULL,
    CONSTRAINT sm_teacher_group_finite CHECK ((isfinite(assigned_at) AND ((ended_at IS NULL) OR isfinite(ended_at)))),
    CONSTRAINT teacher_assignment_period CHECK (((ended_at IS NULL) OR (ended_at > assigned_at))),
    CONSTRAINT teacher_assignment_revision CHECK ((revision > 0))
);


--
-- Name: training_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.training_group (
    group_id uuid NOT NULL,
    school_id uuid NOT NULL,
    branch_id uuid,
    name character varying(200) NOT NULL,
    category_code character varying(20),
    started_at timestamp with time zone NOT NULL,
    ended_at timestamp with time zone,
    revision bigint DEFAULT 1 NOT NULL,
    membership_revision bigint DEFAULT 1 NOT NULL,
    last_operation_id uuid NOT NULL,
    CONSTRAINT group_name_revisions CHECK (((length(TRIM(BOTH FROM name)) > 0) AND (revision > 0) AND (membership_revision > 0))),
    CONSTRAINT group_optional_category CHECK (((category_code IS NULL) OR (length(TRIM(BOTH FROM category_code)) > 0))),
    CONSTRAINT group_period CHECK (((ended_at IS NULL) OR (ended_at > started_at)))
);


--
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- Name: integration_inbox PK_integration_inbox; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integration_inbox
    ADD CONSTRAINT "PK_integration_inbox" PRIMARY KEY (event_id);


--
-- Name: membership_review PK_membership_review; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_review
    ADD CONSTRAINT "PK_membership_review" PRIMARY KEY (review_id);


--
-- Name: school_coordination PK_school_coordination; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school_coordination
    ADD CONSTRAINT "PK_school_coordination" PRIMARY KEY (operation_id, school_id);


--
-- Name: school_learning_outbox PK_school_learning_outbox; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school_learning_outbox
    ADD CONSTRAINT "PK_school_learning_outbox" PRIMARY KEY (id);


--
-- Name: branch branch_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_pkey PRIMARY KEY (branch_id, school_id);


--
-- Name: enrollment_status_history enrollment_status_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollment_status_history
    ADD CONSTRAINT enrollment_status_history_pkey PRIMARY KEY (enrollment_id, school_id, enrollment_revision);


--
-- Name: group_roster_member group_roster_member_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_roster_member
    ADD CONSTRAINT group_roster_member_pkey PRIMARY KEY (group_id, school_id, membership_revision, membership_id);


--
-- Name: group_roster_revision group_roster_revision_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_roster_revision
    ADD CONSTRAINT group_roster_revision_pkey PRIMARY KEY (group_id, school_id, membership_revision);


--
-- Name: membership_permission_grant membership_permission_grant_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_permission_grant
    ADD CONSTRAINT membership_permission_grant_pkey PRIMARY KEY (grant_id, school_id);


--
-- Name: school_invitation school_invitation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school_invitation
    ADD CONSTRAINT school_invitation_pkey PRIMARY KEY (invitation_id, school_id);


--
-- Name: school_membership school_membership_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school_membership
    ADD CONSTRAINT school_membership_pkey PRIMARY KEY (membership_id, school_id);


--
-- Name: school_operation school_operation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school_operation
    ADD CONSTRAINT school_operation_pkey PRIMARY KEY (operation_id, school_id);


--
-- Name: school school_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school
    ADD CONSTRAINT school_pkey PRIMARY KEY (school_id);


--
-- Name: membership_permission_grant sm_grant_no_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_permission_grant
    ADD CONSTRAINT sm_grant_no_overlap EXCLUDE USING gist (school_id WITH =, membership_id WITH =, permission WITH =, tstzrange(started_at, ended_at, '[)'::text) WITH &&);


--
-- Name: school_membership sm_membership_no_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school_membership
    ADD CONSTRAINT sm_membership_no_overlap EXCLUDE USING gist (school_id WITH =, user_id WITH =, role WITH =, tstzrange(started_at, ended_at, '[)'::text) WITH &&);


--
-- Name: student_group_membership sm_student_group_no_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_group_membership
    ADD CONSTRAINT sm_student_group_no_overlap EXCLUDE USING gist (school_id WITH =, enrollment_id WITH =, group_id WITH =, tstzrange(joined_at, left_at, '[)'::text) WITH &&);


--
-- Name: teacher_group_assignment sm_teacher_group_no_overlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teacher_group_assignment
    ADD CONSTRAINT sm_teacher_group_no_overlap EXCLUDE USING gist (school_id WITH =, teacher_id WITH =, group_id WITH =, tstzrange(assigned_at, ended_at, '[)'::text) WITH &&);


--
-- Name: student_enrollment student_enrollment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_enrollment
    ADD CONSTRAINT student_enrollment_pkey PRIMARY KEY (enrollment_id, school_id);


--
-- Name: student_group_membership student_group_membership_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_group_membership
    ADD CONSTRAINT student_group_membership_pkey PRIMARY KEY (membership_id, school_id);


--
-- Name: teacher_group_assignment teacher_group_assignment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teacher_group_assignment
    ADD CONSTRAINT teacher_group_assignment_pkey PRIMARY KEY (assignment_id, school_id);


--
-- Name: training_group training_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_group
    ADD CONSTRAINT training_group_pkey PRIMARY KEY (group_id, school_id);


--
-- Name: IX_membership_review_school_id_resolved_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_membership_review_school_id_resolved_at" ON public.membership_review USING btree (school_id, resolved_at);


--
-- Name: IX_membership_review_source_event_id_target_kind_target_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_membership_review_source_event_id_target_kind_target_id" ON public.membership_review USING btree (source_event_id, target_kind, target_id);


--
-- Name: IX_school_learning_outbox_sent_at_next_attempt_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_school_learning_outbox_sent_at_next_attempt_at" ON public.school_learning_outbox USING btree (sent_at, next_attempt_at);


--
-- Name: membership_permission_grant_membership_id_school_id_permiss_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX membership_permission_grant_membership_id_school_id_permiss_idx ON public.membership_permission_grant USING btree (membership_id, school_id, permission, started_at);


--
-- Name: school_invitation_accepted_operation_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX school_invitation_accepted_operation_id_school_id_idx ON public.school_invitation USING btree (accepted_operation_id, school_id);


--
-- Name: school_invitation_issued_operation_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX school_invitation_issued_operation_id_school_id_idx ON public.school_invitation USING btree (issued_operation_id, school_id);


--
-- Name: school_invitation_revoked_operation_id_school_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX school_invitation_revoked_operation_id_school_id_idx ON public.school_invitation USING btree (revoked_operation_id, school_id);


--
-- Name: school_invitation_school_id_target_user_id_status_expires_a_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX school_invitation_school_id_target_user_id_status_expires_a_idx ON public.school_invitation USING btree (school_id, target_user_id, status, expires_at);


--
-- Name: school_membership_school_id_user_id_role_started_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX school_membership_school_id_user_id_role_started_at_idx ON public.school_membership USING btree (school_id, user_id, role, started_at);


--
-- Name: school_operation_school_id_target_kind_target_id_requested__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX school_operation_school_id_target_kind_target_id_requested__idx ON public.school_operation USING btree (school_id, target_kind, target_id, requested_at);


--
-- Name: sm_enrollment_global_identity; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sm_enrollment_global_identity ON public.student_enrollment USING btree (enrollment_id);


--
-- Name: sm_one_unresolved_coordination_per_school; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sm_one_unresolved_coordination_per_school ON public.school_operation USING btree (school_id) WHERE (coordination_required AND (status = ANY (ARRAY['Pending'::public.sm_operation_status, 'ReconciliationPending'::public.sm_operation_status])));


--
-- Name: student_enrollment_school_id_student_id_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX student_enrollment_school_id_student_id_status_idx ON public.student_enrollment USING btree (school_id, student_id, status);


--
-- Name: student_group_membership_membership_id_school_id_group_id_e_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX student_group_membership_membership_id_school_id_group_id_e_idx ON public.student_group_membership USING btree (membership_id, school_id, group_id, enrollment_id);


--
-- Name: student_group_membership_school_id_enrollment_id_joined_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX student_group_membership_school_id_enrollment_id_joined_at_idx ON public.student_group_membership USING btree (school_id, enrollment_id, joined_at);


--
-- Name: student_group_membership_school_id_group_id_joined_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX student_group_membership_school_id_group_id_joined_at_idx ON public.student_group_membership USING btree (school_id, group_id, joined_at);


--
-- Name: teacher_group_assignment_school_id_group_id_assigned_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX teacher_group_assignment_school_id_group_id_assigned_at_idx ON public.teacher_group_assignment USING btree (school_id, group_id, assigned_at);


--
-- Name: teacher_group_assignment_school_id_teacher_id_assigned_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX teacher_group_assignment_school_id_teacher_id_assigned_at_idx ON public.teacher_group_assignment USING btree (school_id, teacher_id, assigned_at);


--
-- Name: integration_inbox integration_inbox_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER integration_inbox_guard BEFORE DELETE OR UPDATE ON public.integration_inbox FOR EACH ROW EXECUTE FUNCTION public.integration_inbox_guard();


--
-- Name: membership_review membership_review_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER membership_review_guard BEFORE DELETE OR UPDATE ON public.membership_review FOR EACH ROW EXECUTE FUNCTION public.membership_review_guard();


--
-- Name: school_coordination school_coordination_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER school_coordination_guard BEFORE UPDATE ON public.school_coordination FOR EACH ROW EXECUTE FUNCTION public.school_coordination_guard();


--
-- Name: enrollment_status_history sm_history_immutable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER sm_history_immutable BEFORE DELETE OR UPDATE ON public.enrollment_status_history FOR EACH ROW EXECUTE FUNCTION public.school_evidence_immutable();


--
-- Name: school_invitation sm_invitation_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER sm_invitation_guard BEFORE UPDATE ON public.school_invitation FOR EACH ROW EXECUTE FUNCTION public.school_invitation_guard();


--
-- Name: school_operation sm_operation_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER sm_operation_guard BEFORE UPDATE ON public.school_operation FOR EACH ROW EXECUTE FUNCTION public.school_operation_guard();


--
-- Name: group_roster_member sm_roster_member_immutable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER sm_roster_member_immutable BEFORE DELETE OR UPDATE ON public.group_roster_member FOR EACH ROW EXECUTE FUNCTION public.school_evidence_immutable();


--
-- Name: group_roster_revision sm_roster_revision_immutable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER sm_roster_revision_immutable BEFORE DELETE OR UPDATE ON public.group_roster_revision FOR EACH ROW EXECUTE FUNCTION public.school_evidence_immutable();


--
-- Name: branch branch_last_operation_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_last_operation_id_school_id_fkey FOREIGN KEY (last_operation_id, school_id) REFERENCES public.school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: branch branch_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.school(school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: enrollment_status_history enrollment_status_history_enrollment_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollment_status_history
    ADD CONSTRAINT enrollment_status_history_enrollment_id_school_id_fkey FOREIGN KEY (enrollment_id, school_id) REFERENCES public.student_enrollment(enrollment_id, school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: enrollment_status_history enrollment_status_history_operation_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollment_status_history
    ADD CONSTRAINT enrollment_status_history_operation_id_school_id_fkey FOREIGN KEY (operation_id, school_id) REFERENCES public.school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: group_roster_member group_roster_member_group_id_school_id_membership_revision_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_roster_member
    ADD CONSTRAINT group_roster_member_group_id_school_id_membership_revision_fkey FOREIGN KEY (group_id, school_id, membership_revision) REFERENCES public.group_roster_revision(group_id, school_id, membership_revision) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: group_roster_member group_roster_member_membership_id_school_id_group_id_enrol_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_roster_member
    ADD CONSTRAINT group_roster_member_membership_id_school_id_group_id_enrol_fkey FOREIGN KEY (membership_id, school_id, group_id, enrollment_id) REFERENCES public.student_group_membership(membership_id, school_id, group_id, enrollment_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: group_roster_revision group_roster_revision_group_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_roster_revision
    ADD CONSTRAINT group_roster_revision_group_id_school_id_fkey FOREIGN KEY (group_id, school_id) REFERENCES public.training_group(group_id, school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: group_roster_revision group_roster_revision_operation_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_roster_revision
    ADD CONSTRAINT group_roster_revision_operation_id_school_id_fkey FOREIGN KEY (operation_id, school_id) REFERENCES public.school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: membership_permission_grant membership_permission_grant_ended_operation_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_permission_grant
    ADD CONSTRAINT membership_permission_grant_ended_operation_id_school_id_fkey FOREIGN KEY (ended_operation_id, school_id) REFERENCES public.school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: membership_permission_grant membership_permission_grant_granted_operation_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_permission_grant
    ADD CONSTRAINT membership_permission_grant_granted_operation_id_school_id_fkey FOREIGN KEY (granted_operation_id, school_id) REFERENCES public.school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: membership_permission_grant membership_permission_grant_membership_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_permission_grant
    ADD CONSTRAINT membership_permission_grant_membership_id_school_id_fkey FOREIGN KEY (membership_id, school_id) REFERENCES public.school_membership(membership_id, school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: school_invitation school_invitation_accepted_operation_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school_invitation
    ADD CONSTRAINT school_invitation_accepted_operation_id_school_id_fkey FOREIGN KEY (accepted_operation_id, school_id) REFERENCES public.school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: school_invitation school_invitation_issued_operation_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school_invitation
    ADD CONSTRAINT school_invitation_issued_operation_id_school_id_fkey FOREIGN KEY (issued_operation_id, school_id) REFERENCES public.school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: school_invitation school_invitation_issuer_membership_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school_invitation
    ADD CONSTRAINT school_invitation_issuer_membership_id_school_id_fkey FOREIGN KEY (issuer_membership_id, school_id) REFERENCES public.school_membership(membership_id, school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: school_invitation school_invitation_result_enrollment_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school_invitation
    ADD CONSTRAINT school_invitation_result_enrollment_id_school_id_fkey FOREIGN KEY (result_enrollment_id, school_id) REFERENCES public.student_enrollment(enrollment_id, school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: school_invitation school_invitation_result_membership_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school_invitation
    ADD CONSTRAINT school_invitation_result_membership_id_school_id_fkey FOREIGN KEY (result_membership_id, school_id) REFERENCES public.school_membership(membership_id, school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: school_invitation school_invitation_revoked_operation_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school_invitation
    ADD CONSTRAINT school_invitation_revoked_operation_id_school_id_fkey FOREIGN KEY (revoked_operation_id, school_id) REFERENCES public.school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: school_invitation school_invitation_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school_invitation
    ADD CONSTRAINT school_invitation_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.school(school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: school_membership school_membership_last_operation_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school_membership
    ADD CONSTRAINT school_membership_last_operation_id_school_id_fkey FOREIGN KEY (last_operation_id, school_id) REFERENCES public.school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: school_membership school_membership_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school_membership
    ADD CONSTRAINT school_membership_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.school(school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: school_operation school_operation_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school_operation
    ADD CONSTRAINT school_operation_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.school(school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: student_enrollment student_enrollment_last_operation_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_enrollment
    ADD CONSTRAINT student_enrollment_last_operation_id_school_id_fkey FOREIGN KEY (last_operation_id, school_id) REFERENCES public.school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: student_enrollment student_enrollment_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_enrollment
    ADD CONSTRAINT student_enrollment_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.school(school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: student_group_membership student_group_membership_enrollment_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_group_membership
    ADD CONSTRAINT student_group_membership_enrollment_id_school_id_fkey FOREIGN KEY (enrollment_id, school_id) REFERENCES public.student_enrollment(enrollment_id, school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: student_group_membership student_group_membership_group_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_group_membership
    ADD CONSTRAINT student_group_membership_group_id_school_id_fkey FOREIGN KEY (group_id, school_id) REFERENCES public.training_group(group_id, school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: student_group_membership student_group_membership_last_operation_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_group_membership
    ADD CONSTRAINT student_group_membership_last_operation_id_school_id_fkey FOREIGN KEY (last_operation_id, school_id) REFERENCES public.school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: teacher_group_assignment teacher_group_assignment_group_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teacher_group_assignment
    ADD CONSTRAINT teacher_group_assignment_group_id_school_id_fkey FOREIGN KEY (group_id, school_id) REFERENCES public.training_group(group_id, school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: teacher_group_assignment teacher_group_assignment_last_operation_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teacher_group_assignment
    ADD CONSTRAINT teacher_group_assignment_last_operation_id_school_id_fkey FOREIGN KEY (last_operation_id, school_id) REFERENCES public.school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: training_group training_group_branch_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_group
    ADD CONSTRAINT training_group_branch_id_school_id_fkey FOREIGN KEY (branch_id, school_id) REFERENCES public.branch(branch_id, school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: training_group training_group_last_operation_id_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_group
    ADD CONSTRAINT training_group_last_operation_id_school_id_fkey FOREIGN KEY (last_operation_id, school_id) REFERENCES public.school_operation(operation_id, school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: training_group training_group_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_group
    ADD CONSTRAINT training_group_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.school(school_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: branch; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.branch ENABLE ROW LEVEL SECURITY;

--
-- Name: enrollment_status_history; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.enrollment_status_history ENABLE ROW LEVEL SECURITY;

--
-- Name: group_roster_member; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.group_roster_member ENABLE ROW LEVEL SECURITY;

--
-- Name: group_roster_revision; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.group_roster_revision ENABLE ROW LEVEL SECURITY;

--
-- Name: school_learning_outbox learning_delivery; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY learning_delivery ON public.school_learning_outbox TO v_school_management_delivery USING (true) WITH CHECK (true);


--
-- Name: membership_permission_grant; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.membership_permission_grant ENABLE ROW LEVEL SECURITY;

--
-- Name: membership_review; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.membership_review ENABLE ROW LEVEL SECURITY;

--
-- Name: school; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.school ENABLE ROW LEVEL SECURITY;

--
-- Name: school_coordination; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.school_coordination ENABLE ROW LEVEL SECURITY;

--
-- Name: school_invitation; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.school_invitation ENABLE ROW LEVEL SECURITY;

--
-- Name: school_learning_outbox; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.school_learning_outbox ENABLE ROW LEVEL SECURITY;

--
-- Name: school_membership; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.school_membership ENABLE ROW LEVEL SECURITY;

--
-- Name: school_operation; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.school_operation ENABLE ROW LEVEL SECURITY;

--
-- Name: student_enrollment; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.student_enrollment ENABLE ROW LEVEL SECURITY;

--
-- Name: student_group_membership; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.student_group_membership ENABLE ROW LEVEL SECURITY;

--
-- Name: teacher_group_assignment; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.teacher_group_assignment ENABLE ROW LEVEL SECURITY;

--
-- Name: branch tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.branch TO v_school_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: enrollment_status_history tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.enrollment_status_history TO v_school_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: group_roster_member tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.group_roster_member TO v_school_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: group_roster_revision tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.group_roster_revision TO v_school_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: membership_permission_grant tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.membership_permission_grant TO v_school_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: membership_review tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.membership_review TO v_school_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: school tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.school TO v_school_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: school_coordination tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.school_coordination TO v_school_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: school_invitation tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.school_invitation TO v_school_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: school_learning_outbox tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.school_learning_outbox TO v_school_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: school_membership tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.school_membership TO v_school_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: school_operation tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.school_operation TO v_school_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: student_enrollment tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.student_enrollment TO v_school_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: student_group_membership tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.student_group_membership TO v_school_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: teacher_group_assignment tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.teacher_group_assignment TO v_school_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: training_group tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.training_group TO v_school_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: training_group; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.training_group ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--

\unrestrict mneWWRTDF3LcgSFfwYWjnLphgqLgGCQXKpuKQkaPJz4tgEFux9voiNx0b4Lo1rT

