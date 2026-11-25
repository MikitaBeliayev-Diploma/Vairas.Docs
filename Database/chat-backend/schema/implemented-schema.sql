--
-- PostgreSQL database dump
--

\restrict PP8dL2irj3eeOr0Km3FLmclvp0YolMcLJ6TYeBBmKAxIcn4PqjwaUL5iaXajgOs

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
-- Name: conversation_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.conversation_status AS ENUM (
    'Open',
    'Archived'
);


--
-- Name: invocation_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.invocation_status AS ENUM (
    'Prepared',
    'AwaitingConfirmation',
    'Confirmed',
    'Executing',
    'Succeeded',
    'Rejected',
    'Failed',
    'Unknown',
    'Expired',
    'Cancelled'
);


--
-- Name: message_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.message_role AS ENUM (
    'User',
    'Assistant'
);


--
-- Name: run_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.run_status AS ENUM (
    'Queued',
    'Running',
    'AwaitingConfirmation',
    'Completed',
    'Failed',
    'Cancelled'
);


--
-- Name: tool_effect; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.tool_effect AS ENUM (
    'Read',
    'Write'
);


--
-- Name: ai_confirm_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.ai_confirm_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
DECLARE c conversation; i tool_invocation; r assistant_run;
BEGIN
 IF TG_OP<>'INSERT' THEN RAISE EXCEPTION 'confirmation immutable'; END IF;
 SELECT * INTO c FROM conversation WHERE school_id=NEW.school_id AND id=NEW.conversation_id FOR UPDATE;
 IF NOT FOUND OR c.status<>'Open' OR c.owner_user_id<>NEW.confirmed_by_user_id THEN RAISE EXCEPTION 'confirmation owner'; END IF;
 SELECT * INTO i FROM tool_invocation WHERE school_id=NEW.school_id AND conversation_id=NEW.conversation_id AND id=NEW.invocation_id FOR UPDATE;
 IF NOT FOUND OR i.effect<>'Write' OR i.status<>'AwaitingConfirmation' OR i.action_digest<>NEW.confirmed_digest OR i.expires_at<=clock_timestamp() THEN RAISE EXCEPTION 'confirmation basis/expiry'; END IF;
 SELECT * INTO r FROM assistant_run WHERE school_id=i.school_id AND conversation_id=i.conversation_id AND id=i.run_id;
 IF r.status NOT IN ('Running','AwaitingConfirmation') AND NOT (r.status='Completed' AND r.execution_profile IN ('PreviewOnlyV1','ConfirmedLessonActionsV1')) THEN RAISE EXCEPTION 'confirmation run closed'; END IF;
 NEW.confirmed_at=clock_timestamp();
 RETURN NEW;
END $$;


--
-- Name: ai_confirmation_final(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.ai_confirmation_final() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
BEGIN
 IF EXISTS(SELECT 1 FROM tool_invocation WHERE school_id=NEW.school_id AND conversation_id=NEW.conversation_id AND id=NEW.invocation_id AND status='AwaitingConfirmation') THEN
   RAISE EXCEPTION 'confirmation and status transition must commit together';
 END IF;
 RETURN NULL;
END $$;


--
-- Name: ai_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.ai_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
DECLARE c conversation; r assistant_run; i tool_invocation; msg chat_message;
BEGIN
 IF TG_OP = 'DELETE' THEN
   RAISE EXCEPTION 'AI append-only/lifecycle rows: controlled erasure procedure required';
 END IF;
 IF NOT isfinite(NEW.created_at) AND TG_TABLE_NAME <> 'action_confirmation' THEN
   RAISE EXCEPTION 'finite creation time required';
 END IF;
 IF TG_TABLE_NAME = 'ai_model_deployment' THEN
   IF TG_OP='UPDATE' AND (to_jsonb(NEW)-'enabled') IS DISTINCT FROM (to_jsonb(OLD)-'enabled') THEN
     RAISE EXCEPTION 'deployment version immutable; create new version';
   END IF;
   RETURN NEW;
 END IF;
 IF TG_TABLE_NAME = 'conversation' THEN
   IF TG_OP='INSERT' AND (NEW.revision<>1 OR NEW.status<>'Open') THEN RAISE EXCEPTION 'new conversation shape'; END IF;
   IF TG_OP='UPDATE' THEN
     IF (to_jsonb(NEW)-ARRAY['title','status','revision','archived_at','archive_request_id','archive_expected_revision']) IS DISTINCT FROM
        (to_jsonb(OLD)-ARRAY['title','status','revision','archived_at','archive_request_id','archive_expected_revision']) OR NEW.revision<>OLD.revision+1 THEN
       RAISE EXCEPTION 'conversation identity/revision immutable';
     END IF;
     IF OLD.status='Archived' OR NEW.status NOT IN ('Open','Archived') THEN RAISE EXCEPTION 'archive terminal'; END IF;
     IF NEW.status='Archived' AND EXISTS(SELECT 1 FROM assistant_run WHERE school_id=NEW.school_id AND conversation_id=NEW.id AND status IN ('Queued','Running','AwaitingConfirmation')) THEN
       RAISE EXCEPTION 'cancel active run before archive';
     END IF;
   END IF;
   RETURN NEW;
 END IF;
 SELECT * INTO c FROM conversation WHERE school_id=NEW.school_id AND id=NEW.conversation_id FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'conversation missing'; END IF;
 IF TG_TABLE_NAME='chat_message' THEN
   IF TG_OP='UPDATE' THEN RAISE EXCEPTION 'message append only'; END IF;
   IF c.status<>'Open' THEN RAISE EXCEPTION 'archived conversation'; END IF;
   IF NEW.sequence_no<>(SELECT COALESCE(MAX(sequence_no),0)+1 FROM chat_message WHERE school_id=NEW.school_id AND conversation_id=NEW.conversation_id) THEN
     RAISE EXCEPTION 'message sequence must be next';
   END IF;
   RETURN NEW;
 END IF;
 IF TG_TABLE_NAME='assistant_run' THEN
   IF TG_OP='INSERT' THEN
     IF NEW.execution_profile<>c.execution_profile OR c.status<>'Open' OR NEW.status<>'Queued' OR NEW.revision<>1 OR NEW.started_at IS NOT NULL THEN RAISE EXCEPTION 'new run shape'; END IF;
     PERFORM 1 FROM ai_model_deployment WHERE id=NEW.model_deployment_id AND enabled;
     IF NOT FOUND THEN RAISE EXCEPTION 'deployment disabled'; END IF;
   ELSE
     IF (to_jsonb(NEW)-ARRAY['status','revision','response_message_id','input_tokens','output_tokens','error_code','started_at','finished_at','recovery_after']) IS DISTINCT FROM
        (to_jsonb(OLD)-ARRAY['status','revision','response_message_id','input_tokens','output_tokens','error_code','started_at','finished_at','recovery_after']) OR NEW.revision<>OLD.revision+1 THEN RAISE EXCEPTION 'run identity/revision'; END IF;
     IF OLD.status IN ('Completed','Failed','Cancelled') THEN RAISE EXCEPTION 'run terminal'; END IF;
     IF NOT ((OLD.status='Queued' AND NEW.status IN ('Running','Failed','Cancelled')) OR
       (OLD.status='Running' AND NEW.status IN ('Running','AwaitingConfirmation','Completed','Failed','Cancelled')) OR
       (OLD.status='AwaitingConfirmation' AND NEW.status IN ('Running','Failed','Cancelled'))) THEN RAISE EXCEPTION 'run transition'; END IF;
     IF OLD.started_at IS NOT NULL AND NEW.started_at IS DISTINCT FROM OLD.started_at THEN RAISE EXCEPTION 'run start immutable'; END IF;
   END IF;
   SELECT * INTO msg FROM chat_message WHERE school_id=NEW.school_id AND conversation_id=NEW.conversation_id AND id=NEW.trigger_message_id;
   IF NOT FOUND OR msg.role<>'User' THEN RAISE EXCEPTION 'run trigger must be User'; END IF;
   IF NEW.status IN ('Running','AwaitingConfirmation','Completed') AND NEW.started_at IS NULL THEN RAISE EXCEPTION 'run start required'; END IF;
   IF NEW.status='Completed' THEN
     SELECT * INTO msg FROM chat_message WHERE school_id=NEW.school_id AND conversation_id=NEW.conversation_id AND id=NEW.response_message_id;
     IF NOT FOUND OR msg.role<>'Assistant' THEN RAISE EXCEPTION 'run response must be Assistant'; END IF;
     IF msg.sequence_no <= (SELECT sequence_no FROM chat_message WHERE school_id=NEW.school_id AND conversation_id=NEW.conversation_id AND id=NEW.trigger_message_id) THEN RAISE EXCEPTION 'response precedes trigger'; END IF;
     IF EXISTS(SELECT 1 FROM tool_invocation WHERE school_id=NEW.school_id AND conversation_id=NEW.conversation_id AND run_id=NEW.id AND status NOT IN ('Succeeded','Rejected','Failed','Expired','Cancelled') AND NOT (NEW.execution_profile IN ('PreviewOnlyV1','ConfirmedLessonActionsV1') AND effect='Write' AND status IN ('AwaitingConfirmation','Confirmed'))) THEN RAISE EXCEPTION 'unresolved tool prevents completion'; END IF;
   END IF;
   RETURN NEW;
 END IF;
 IF TG_TABLE_NAME='tool_invocation' THEN
   SELECT * INTO r FROM assistant_run WHERE school_id=NEW.school_id AND conversation_id=NEW.conversation_id AND id=NEW.run_id;
   IF NOT FOUND THEN RAISE EXCEPTION 'run missing'; END IF;
   IF TG_OP='INSERT' THEN
     IF c.status<>'Open' OR r.status<>'Running' OR NEW.revision<>1 OR NEW.started_at IS NOT NULL OR
       (NEW.effect='Read' AND NEW.status<>'Prepared') OR (NEW.effect='Write' AND NEW.status<>'AwaitingConfirmation') THEN RAISE EXCEPTION 'new invocation shape'; END IF;
     IF NEW.effect='Write' AND (EXISTS(SELECT 1 FROM tool_invocation WHERE school_id=NEW.school_id AND conversation_id=NEW.conversation_id AND run_id=NEW.run_id AND effect='Write') OR
       EXISTS(SELECT 1 FROM tool_invocation WHERE school_id=NEW.school_id AND conversation_id=NEW.conversation_id AND effect='Write' AND status IN ('Executing','Unknown'))) THEN RAISE EXCEPTION 'write admission blocked'; END IF;
   ELSE
     IF (to_jsonb(NEW)-ARRAY['status','revision','result_reference','result_summary','error_code','started_at','finished_at','recovery_after']) IS DISTINCT FROM
       (to_jsonb(OLD)-ARRAY['status','revision','result_reference','result_summary','error_code','started_at','finished_at','recovery_after']) OR NEW.revision<>OLD.revision+1 THEN RAISE EXCEPTION 'invocation payload/revision immutable'; END IF;
     IF NOT ((OLD.status='Prepared' AND NEW.status IN ('Executing','Rejected','Failed','Cancelled')) OR
       (OLD.status='AwaitingConfirmation' AND NEW.status IN ('Confirmed','Expired','Rejected','Cancelled')) OR
       (OLD.status='Confirmed' AND NEW.status IN ('Executing','Expired','Rejected','Cancelled')) OR
       (OLD.status='Executing' AND NEW.status IN ('Succeeded','Rejected','Failed','Unknown')) OR
       (OLD.status='Unknown' AND NEW.status IN ('Succeeded','Rejected','Failed')) OR
       (OLD.status IN ('Executing','Unknown') AND NEW.status=OLD.status AND NEW.recovery_after IS DISTINCT FROM OLD.recovery_after)) THEN RAISE EXCEPTION 'invocation transition'; END IF;
     IF OLD.started_at IS NOT NULL AND NEW.started_at IS DISTINCT FROM OLD.started_at THEN RAISE EXCEPTION 'invocation start immutable'; END IF;
     IF NEW.status='Executing' AND OLD.status<>'Executing' THEN
       IF NEW.effect='Write' AND r.execution_profile='PreviewOnlyV1' THEN RAISE EXCEPTION 'business dispatch disabled'; END IF;
       IF (r.status<>'Running' AND NOT (NEW.effect='Write' AND r.execution_profile='ConfirmedLessonActionsV1' AND r.status='Completed')) OR c.status<>'Open' OR NEW.started_at IS NULL THEN RAISE EXCEPTION 'dispatch run/start'; END IF;
       IF NEW.effect='Write' AND (NEW.expires_at<=clock_timestamp() OR EXISTS(SELECT 1 FROM tool_invocation WHERE school_id=NEW.school_id AND conversation_id=NEW.conversation_id AND id<>NEW.id AND effect='Write' AND status IN ('Executing','Unknown'))) THEN RAISE EXCEPTION 'dispatch expired/blocked'; END IF;
     END IF;
     IF NEW.status='Expired' AND NEW.expires_at>clock_timestamp() THEN RAISE EXCEPTION 'not yet expired'; END IF;
     IF NEW.effect='Write' AND NEW.status IN ('Confirmed','Executing') THEN
       PERFORM 1 FROM action_confirmation WHERE school_id=NEW.school_id AND conversation_id=NEW.conversation_id AND invocation_id=NEW.id AND confirmed_digest=NEW.action_digest AND confirmed_by_user_id=c.owner_user_id AND confirmed_at<NEW.expires_at;
       IF NOT FOUND THEN RAISE EXCEPTION 'exact confirmation required'; END IF;
     END IF;
   END IF;
   RETURN NEW;
 END IF;
 RAISE EXCEPTION 'unknown guarded table';
END $$;


--
-- Name: chat_audit(uuid, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.chat_audit(request_school uuid, request_limit integer) RETURNS TABLE(operation_id uuid, tool text, outcome text, recorded_at timestamp with time zone)
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public'
    AS $$
 SELECT i.operation_id,i.tool_name::text,i.status::text,COALESCE(c.confirmed_at,i.created_at)
 FROM public.tool_invocation i LEFT JOIN public.action_confirmation c ON (c.school_id,c.conversation_id,c.invocation_id)=(i.school_id,i.conversation_id,i.id)
 WHERE i.school_id=request_school AND i.effect='Write'
 ORDER BY i.created_at DESC,i.id DESC LIMIT greatest(0,least(request_limit,100))
$$;


--
-- Name: chat_confirmation(uuid, uuid, uuid, uuid, uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.chat_confirmation(request_school uuid, request_conversation uuid, request_invocation uuid, request_identity uuid, request_operation uuid, request_digest text) RETURNS TABLE(confirmed_at timestamp with time zone, expires_at timestamp with time zone)
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public'
    AS $$
 SELECT a.confirmed_at,i.expires_at FROM public.action_confirmation a
 JOIN public.tool_invocation i ON (i.school_id,i.conversation_id,i.id)=(a.school_id,a.conversation_id,a.invocation_id)
 JOIN public.conversation c ON (c.school_id,c.id)=(i.school_id,i.conversation_id)
 WHERE (i.school_id,i.conversation_id,i.id)=(request_school,request_conversation,request_invocation)
 AND c.status='Open' AND i.status='Confirmed' AND i.expires_at>clock_timestamp()
 AND i.operation_id=request_operation AND i.action_digest=request_digest AND a.confirmed_digest=i.action_digest AND a.confirmed_by_user_id=c.owner_user_id
 AND i.preview->>'actorIdentityId'=request_identity::text
$$;


--
-- Name: chat_pending_executions(timestamp with time zone, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.chat_pending_executions(request_before timestamp with time zone, request_limit integer) RETURNS TABLE(school_id uuid, user_id uuid, preview_id uuid)
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public'
    AS $$
 SELECT i.school_id,c.owner_user_id,i.id FROM public.tool_invocation i
 JOIN public.conversation c ON (c.school_id,c.id)=(i.school_id,i.conversation_id)
 WHERE c.execution_profile='ConfirmedLessonActionsV1' AND i.effect='Write'
 AND (i.status='Unknown' OR (i.status='Executing' AND i.started_at<=request_before))
 AND (i.recovery_after IS NULL OR i.recovery_after<=clock_timestamp())
 ORDER BY COALESCE(i.recovery_after,i.started_at),i.id LIMIT greatest(0,least(request_limit,50))
$$;


--
-- Name: chat_scope_school(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.chat_scope_school() RETURNS uuid
    LANGUAGE sql STABLE
    SET search_path TO 'pg_catalog', 'public'
    AS $$ SELECT nullif(current_setting('vairas.school_id',true),'')::uuid $$;


--
-- Name: chat_scope_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.chat_scope_user() RETURNS uuid
    LANGUAGE sql STABLE
    SET search_path TO 'pg_catalog', 'public'
    AS $$ SELECT nullif(current_setting('vairas.user_id',true),'')::uuid $$;


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
-- Name: action_confirmation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.action_confirmation (
    school_id uuid NOT NULL,
    conversation_id uuid NOT NULL,
    invocation_id uuid NOT NULL,
    confirmed_by_user_id uuid NOT NULL,
    confirmed_digest character(64) NOT NULL,
    confirmed_at timestamp with time zone NOT NULL,
    CONSTRAINT confirmation_digest_shape CHECK ((confirmed_digest ~ '^[0-9a-f]{64}$'::text)),
    CONSTRAINT confirmation_finite_time CHECK (isfinite(confirmed_at))
);


--
-- Name: TABLE action_confirmation; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.action_confirmation IS 'Zero-or-one immutable owned child. Check same actor/digest and unexpired Write. Never model-generated consent.';


--
-- Name: COLUMN action_confirmation.confirmed_by_user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.action_confirmation.confirmed_by_user_id IS 'Authenticated conversation owner; checked by handler.';


--
-- Name: ai_model_deployment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_model_deployment (
    id uuid NOT NULL,
    provider character varying(80) NOT NULL,
    model_name character varying(160) NOT NULL,
    model_version character varying(100),
    deployment_name character varying(160) NOT NULL,
    region character varying(80) NOT NULL,
    endpoint_config_key character varying(200) NOT NULL,
    credential_secret_ref character varying(240) NOT NULL,
    configuration_version integer NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT deployment_finite_time CHECK (isfinite(created_at)),
    CONSTRAINT deployment_version_positive CHECK ((configuration_version > 0))
);


--
-- Name: TABLE ai_model_deployment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ai_model_deployment IS 'Global immutable configuration version, except enabled; no weights or API keys.';


--
-- Name: COLUMN ai_model_deployment.model_version; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_model_deployment.model_version IS 'Null if provider does not expose fixed version; never invent one.';


--
-- Name: COLUMN ai_model_deployment.endpoint_config_key; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_model_deployment.endpoint_config_key IS 'Allowlisted server configuration, never a model-selected URL.';


--
-- Name: COLUMN ai_model_deployment.credential_secret_ref; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_model_deployment.credential_secret_ref IS 'Secret-manager reference only.';


--
-- Name: assistant_run; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assistant_run (
    school_id uuid NOT NULL,
    conversation_id uuid NOT NULL,
    id uuid NOT NULL,
    trigger_message_id uuid NOT NULL,
    response_message_id uuid,
    attempt_no integer NOT NULL,
    model_deployment_id uuid NOT NULL,
    prompt_version character varying(100) NOT NULL,
    status public.run_status NOT NULL,
    revision bigint DEFAULT 1 NOT NULL,
    input_tokens bigint,
    output_tokens bigint,
    error_code character varying(80),
    created_at timestamp with time zone NOT NULL,
    started_at timestamp with time zone,
    finished_at timestamp with time zone,
    execution_profile character varying(32) NOT NULL,
    deadline_at timestamp with time zone NOT NULL,
    CONSTRAINT assistant_run_check CHECK ((isfinite(deadline_at) AND (deadline_at > created_at))),
    CONSTRAINT assistant_run_execution_profile_check CHECK (((execution_profile)::text = ANY ((ARRAY['PreviewOnlyV1'::character varying, 'ConfirmedLessonActionsV1'::character varying])::text[]))),
    CONSTRAINT run_counters_positive CHECK (((attempt_no > 0) AND (revision > 0))),
    CONSTRAINT run_finished_shape CHECK (((status = ANY (ARRAY['Completed'::public.run_status, 'Failed'::public.run_status, 'Cancelled'::public.run_status])) = (finished_at IS NOT NULL))),
    CONSTRAINT run_finite_time CHECK ((isfinite(created_at) AND ((started_at IS NULL) OR isfinite(started_at)) AND ((finished_at IS NULL) OR isfinite(finished_at)))),
    CONSTRAINT run_response_shape CHECK (((status = 'Completed'::public.run_status) = (response_message_id IS NOT NULL))),
    CONSTRAINT run_time_order CHECK ((((started_at IS NULL) OR (started_at >= created_at)) AND ((finished_at IS NULL) OR (finished_at >= COALESCE(started_at, created_at))))),
    CONSTRAINT run_usage_nonnegative CHECK ((((input_tokens IS NULL) OR (input_tokens >= 0)) AND ((output_tokens IS NULL) OR (output_tokens >= 0))))
);


--
-- Name: TABLE assistant_run; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.assistant_run IS 'Add partial unique active-run index; see context. Trigger message must have User role.';


--
-- Name: COLUMN assistant_run.response_message_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.assistant_run.response_message_id IS 'Set atomically on completion; same-conversation Assistant message.';


--
-- Name: COLUMN assistant_run.input_tokens; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.assistant_run.input_tokens IS 'Nonnegative if reported; null means unknown.';


--
-- Name: chat_message; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chat_message (
    school_id uuid NOT NULL,
    conversation_id uuid NOT NULL,
    id uuid NOT NULL,
    sequence_no bigint NOT NULL,
    role public.message_role NOT NULL,
    content text NOT NULL,
    client_request_id uuid,
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT message_finite_time CHECK (isfinite(created_at)),
    CONSTRAINT message_request_role CHECK (((role = 'User'::public.message_role) = (client_request_id IS NOT NULL))),
    CONSTRAINT message_sequence_positive CHECK ((sequence_no > 0))
);


--
-- Name: TABLE chat_message; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.chat_message IS 'Append-only owned child. PostgreSQL default unique permits multiple null client_request_id values.';


--
-- Name: COLUMN chat_message.content; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.chat_message.content IS 'Final protected display text; no hidden reasoning.';


--
-- Name: COLUMN chat_message.client_request_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.chat_message.client_request_id IS 'Required for User, null for Assistant; message API deduplication.';


--
-- Name: conversation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conversation (
    school_id uuid NOT NULL,
    id uuid NOT NULL,
    owner_user_id uuid NOT NULL,
    title character varying(200),
    status public.conversation_status NOT NULL,
    revision bigint DEFAULT 1 NOT NULL,
    created_at timestamp with time zone NOT NULL,
    archived_at timestamp with time zone,
    creation_request_id uuid NOT NULL,
    access_stamp character varying(64) NOT NULL,
    archive_expected_revision bigint,
    archive_request_id uuid,
    execution_profile character varying(32) DEFAULT 'PreviewOnlyV1'::character varying NOT NULL,
    CONSTRAINT conversation_access_stamp_check CHECK (((access_stamp)::text ~ '^[0-9a-f]{64}$'::text)),
    CONSTRAINT conversation_archive_request_ck CHECK ((((archive_request_id IS NULL) AND (archive_expected_revision IS NULL)) OR ((archive_request_id IS NOT NULL) AND (archive_expected_revision IS NOT NULL) AND (archive_expected_revision > 0) AND (status = 'Archived'::public.conversation_status)))),
    CONSTRAINT conversation_archive_shape CHECK (((status = 'Archived'::public.conversation_status) = (archived_at IS NOT NULL))),
    CONSTRAINT conversation_execution_profile_check CHECK (((execution_profile)::text = ANY ((ARRAY['PreviewOnlyV1'::character varying, 'ConfirmedLessonActionsV1'::character varying])::text[]))),
    CONSTRAINT conversation_finite_time CHECK ((isfinite(created_at) AND ((archived_at IS NULL) OR isfinite(archived_at)))),
    CONSTRAINT conversation_revision_positive CHECK ((revision > 0)),
    CONSTRAINT conversation_time_order CHECK (((archived_at IS NULL) OR (archived_at >= created_at)))
);


--
-- Name: COLUMN conversation.school_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.conversation.school_id IS 'External School Management ID; immutable.';


--
-- Name: COLUMN conversation.owner_user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.conversation.owner_user_id IS 'External authenticated User ID; immutable.';


--
-- Name: tool_invocation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tool_invocation (
    school_id uuid NOT NULL,
    conversation_id uuid NOT NULL,
    id uuid NOT NULL,
    run_id uuid NOT NULL,
    sequence_no integer NOT NULL,
    tool_name character varying(120) NOT NULL,
    tool_contract_version character varying(80) NOT NULL,
    effect public.tool_effect NOT NULL,
    target_context character varying(80) NOT NULL,
    canonical_arguments jsonb NOT NULL,
    preview jsonb,
    expected_source_revisions jsonb,
    action_digest character(64),
    expires_at timestamp with time zone,
    operation_id uuid NOT NULL,
    status public.invocation_status NOT NULL,
    revision bigint DEFAULT 1 NOT NULL,
    result_reference character varying(240),
    result_summary jsonb,
    error_code character varying(80),
    created_at timestamp with time zone NOT NULL,
    started_at timestamp with time zone,
    finished_at timestamp with time zone,
    recovery_after timestamp with time zone,
    CONSTRAINT invocation_counters_positive CHECK (((sequence_no > 0) AND (revision > 0))),
    CONSTRAINT invocation_effect_shape CHECK ((((effect = 'Write'::public.tool_effect) AND (preview IS NOT NULL) AND (expected_source_revisions IS NOT NULL) AND (action_digest IS NOT NULL) AND (action_digest ~ '^[0-9a-f]{64}$'::text) AND (expires_at IS NOT NULL) AND (expires_at > created_at)) OR ((effect = 'Read'::public.tool_effect) AND (preview IS NULL) AND (action_digest IS NULL) AND (expires_at IS NULL)))),
    CONSTRAINT invocation_effect_status CHECK ((((effect = 'Read'::public.tool_effect) AND (status <> ALL (ARRAY['AwaitingConfirmation'::public.invocation_status, 'Confirmed'::public.invocation_status, 'Expired'::public.invocation_status]))) OR ((effect = 'Write'::public.tool_effect) AND (status <> 'Prepared'::public.invocation_status)))),
    CONSTRAINT invocation_finished_shape CHECK (((status = ANY (ARRAY['Succeeded'::public.invocation_status, 'Rejected'::public.invocation_status, 'Failed'::public.invocation_status, 'Expired'::public.invocation_status, 'Cancelled'::public.invocation_status])) = (finished_at IS NOT NULL))),
    CONSTRAINT invocation_finite_time CHECK ((isfinite(created_at) AND ((started_at IS NULL) OR isfinite(started_at)) AND ((finished_at IS NULL) OR isfinite(finished_at)) AND ((expires_at IS NULL) OR isfinite(expires_at)))),
    CONSTRAINT invocation_time_order CHECK ((((started_at IS NULL) OR (started_at >= created_at)) AND ((finished_at IS NULL) OR (finished_at >= COALESCE(started_at, created_at)))))
);


--
-- Name: COLUMN tool_invocation.canonical_arguments; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tool_invocation.canonical_arguments IS 'Immutable validated payload; protect sensitive fields.';


--
-- Name: COLUMN tool_invocation.preview; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tool_invocation.preview IS 'Exact displayed owner preview; required on Write.';


--
-- Name: COLUMN tool_invocation.expected_source_revisions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tool_invocation.expected_source_revisions IS 'Owner source basis according to tool contract.';


--
-- Name: COLUMN tool_invocation.action_digest; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tool_invocation.action_digest IS 'SHA-256 canonical consent envelope; required on Write.';


--
-- Name: COLUMN tool_invocation.expires_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tool_invocation.expires_at IS 'Required on Write; first-dispatch deadline.';


--
-- Name: COLUMN tool_invocation.operation_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tool_invocation.operation_id IS 'Stable owner correlation/recovery key; unchanged on timeout.';


--
-- Name: COLUMN tool_invocation.result_reference; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tool_invocation.result_reference IS 'Owner receipt/result reference, not public capability URL.';


--
-- Name: COLUMN tool_invocation.result_summary; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tool_invocation.result_summary IS 'Minimal protected result.';


--
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- Name: action_confirmation action_confirmation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.action_confirmation
    ADD CONSTRAINT action_confirmation_pkey PRIMARY KEY (school_id, conversation_id, invocation_id);


--
-- Name: ai_model_deployment ai_model_deployment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_model_deployment
    ADD CONSTRAINT ai_model_deployment_pkey PRIMARY KEY (id);


--
-- Name: assistant_run assistant_run_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assistant_run
    ADD CONSTRAINT assistant_run_pkey PRIMARY KEY (school_id, conversation_id, id);


--
-- Name: chat_message chat_message_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_message
    ADD CONSTRAINT chat_message_pkey PRIMARY KEY (school_id, conversation_id, id);


--
-- Name: conversation conversation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversation
    ADD CONSTRAINT conversation_pkey PRIMARY KEY (school_id, id);


--
-- Name: tool_invocation tool_invocation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tool_invocation
    ADD CONSTRAINT tool_invocation_pkey PRIMARY KEY (school_id, conversation_id, id);


--
-- Name: IX_conversation_owner_user_id_archive_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_conversation_owner_user_id_archive_request_id" ON public.conversation USING btree (owner_user_id, archive_request_id);


--
-- Name: assistant_run_school_id_conversation_id_response_message_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assistant_run_school_id_conversation_id_response_message_id_idx ON public.assistant_run USING btree (school_id, conversation_id, response_message_id);


--
-- Name: assistant_run_school_id_conversation_id_trigger_message_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assistant_run_school_id_conversation_id_trigger_message_id__idx ON public.assistant_run USING btree (school_id, conversation_id, trigger_message_id, attempt_no);


--
-- Name: chat_message_school_id_conversation_id_client_request_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX chat_message_school_id_conversation_id_client_request_id_idx ON public.chat_message USING btree (school_id, conversation_id, client_request_id);


--
-- Name: chat_message_school_id_conversation_id_sequence_no_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX chat_message_school_id_conversation_id_sequence_no_idx ON public.chat_message USING btree (school_id, conversation_id, sequence_no);


--
-- Name: conversation_creation_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX conversation_creation_key ON public.conversation USING btree (owner_user_id, creation_request_id);


--
-- Name: conversation_school_id_owner_user_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX conversation_school_id_owner_user_id_created_at_idx ON public.conversation USING btree (school_id, owner_user_id, created_at);


--
-- Name: invocation_public_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX invocation_public_id ON public.tool_invocation USING btree (school_id, id);


--
-- Name: one_active_preview; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX one_active_preview ON public.tool_invocation USING btree (school_id, conversation_id) WHERE ((effect = 'Write'::public.tool_effect) AND (status = ANY (ARRAY['AwaitingConfirmation'::public.invocation_status, 'Confirmed'::public.invocation_status])));


--
-- Name: one_active_run; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX one_active_run ON public.assistant_run USING btree (school_id, conversation_id) WHERE (status = ANY (ARRAY['Queued'::public.run_status, 'Running'::public.run_status, 'AwaitingConfirmation'::public.run_status]));


--
-- Name: pending_lesson_recovery; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pending_lesson_recovery ON public.tool_invocation USING btree (recovery_after, started_at) WHERE ((effect = 'Write'::public.tool_effect) AND (status = ANY (ARRAY['Executing'::public.invocation_status, 'Unknown'::public.invocation_status])));


--
-- Name: tool_invocation_school_id_conversation_id_run_id_sequence_n_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tool_invocation_school_id_conversation_id_run_id_sequence_n_idx ON public.tool_invocation USING btree (school_id, conversation_id, run_id, sequence_no);


--
-- Name: tool_invocation_school_id_operation_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tool_invocation_school_id_operation_id_idx ON public.tool_invocation USING btree (school_id, operation_id);


--
-- Name: tool_invocation_status_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tool_invocation_status_created_at_idx ON public.tool_invocation USING btree (status, created_at);


--
-- Name: action_confirmation ai_confirmation_atomic; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER ai_confirmation_atomic AFTER INSERT ON public.action_confirmation DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.ai_confirmation_final();


--
-- Name: action_confirmation ai_confirmation_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ai_confirmation_guard BEFORE INSERT OR DELETE OR UPDATE ON public.action_confirmation FOR EACH ROW EXECUTE FUNCTION public.ai_confirm_guard();


--
-- Name: conversation ai_conversation_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ai_conversation_guard BEFORE INSERT OR DELETE OR UPDATE ON public.conversation FOR EACH ROW EXECUTE FUNCTION public.ai_guard();


--
-- Name: ai_model_deployment ai_deployment_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ai_deployment_guard BEFORE INSERT OR DELETE OR UPDATE ON public.ai_model_deployment FOR EACH ROW EXECUTE FUNCTION public.ai_guard();


--
-- Name: tool_invocation ai_invocation_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ai_invocation_guard BEFORE INSERT OR DELETE OR UPDATE ON public.tool_invocation FOR EACH ROW EXECUTE FUNCTION public.ai_guard();


--
-- Name: chat_message ai_message_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ai_message_guard BEFORE INSERT OR DELETE OR UPDATE ON public.chat_message FOR EACH ROW EXECUTE FUNCTION public.ai_guard();


--
-- Name: assistant_run ai_run_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ai_run_guard BEFORE INSERT OR DELETE OR UPDATE ON public.assistant_run FOR EACH ROW EXECUTE FUNCTION public.ai_guard();


--
-- Name: action_confirmation action_confirmation_school_id_conversation_id_invocation_i_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.action_confirmation
    ADD CONSTRAINT action_confirmation_school_id_conversation_id_invocation_i_fkey FOREIGN KEY (school_id, conversation_id, invocation_id) REFERENCES public.tool_invocation(school_id, conversation_id, id) DEFERRABLE;


--
-- Name: assistant_run assistant_run_model_deployment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assistant_run
    ADD CONSTRAINT assistant_run_model_deployment_id_fkey FOREIGN KEY (model_deployment_id) REFERENCES public.ai_model_deployment(id) DEFERRABLE;


--
-- Name: assistant_run assistant_run_school_id_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assistant_run
    ADD CONSTRAINT assistant_run_school_id_conversation_id_fkey FOREIGN KEY (school_id, conversation_id) REFERENCES public.conversation(school_id, id) DEFERRABLE;


--
-- Name: assistant_run assistant_run_school_id_conversation_id_response_message_i_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assistant_run
    ADD CONSTRAINT assistant_run_school_id_conversation_id_response_message_i_fkey FOREIGN KEY (school_id, conversation_id, response_message_id) REFERENCES public.chat_message(school_id, conversation_id, id) DEFERRABLE;


--
-- Name: assistant_run assistant_run_school_id_conversation_id_trigger_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assistant_run
    ADD CONSTRAINT assistant_run_school_id_conversation_id_trigger_message_id_fkey FOREIGN KEY (school_id, conversation_id, trigger_message_id) REFERENCES public.chat_message(school_id, conversation_id, id) DEFERRABLE;


--
-- Name: chat_message chat_message_school_id_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_message
    ADD CONSTRAINT chat_message_school_id_conversation_id_fkey FOREIGN KEY (school_id, conversation_id) REFERENCES public.conversation(school_id, id) DEFERRABLE;


--
-- Name: tool_invocation tool_invocation_school_id_conversation_id_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tool_invocation
    ADD CONSTRAINT tool_invocation_school_id_conversation_id_run_id_fkey FOREIGN KEY (school_id, conversation_id, run_id) REFERENCES public.assistant_run(school_id, conversation_id, id) DEFERRABLE;


--
-- Name: action_confirmation; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.action_confirmation ENABLE ROW LEVEL SECURITY;

--
-- Name: assistant_run; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.assistant_run ENABLE ROW LEVEL SECURITY;

--
-- Name: chat_message; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.chat_message ENABLE ROW LEVEL SECURITY;

--
-- Name: conversation; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.conversation ENABLE ROW LEVEL SECURITY;

--
-- Name: conversation conversation_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY conversation_scope ON public.conversation USING (((school_id = public.chat_scope_school()) AND (owner_user_id = public.chat_scope_user()))) WITH CHECK (((school_id = public.chat_scope_school()) AND (owner_user_id = public.chat_scope_user())));


--
-- Name: action_confirmation private_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY private_scope ON public.action_confirmation USING (((school_id = public.chat_scope_school()) AND (EXISTS ( SELECT 1
   FROM public.conversation c
  WHERE ((c.school_id = action_confirmation.school_id) AND (c.id = action_confirmation.conversation_id)))))) WITH CHECK (((school_id = public.chat_scope_school()) AND (EXISTS ( SELECT 1
   FROM public.conversation c
  WHERE ((c.school_id = action_confirmation.school_id) AND (c.id = action_confirmation.conversation_id))))));


--
-- Name: assistant_run private_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY private_scope ON public.assistant_run USING (((school_id = public.chat_scope_school()) AND (EXISTS ( SELECT 1
   FROM public.conversation c
  WHERE ((c.school_id = assistant_run.school_id) AND (c.id = assistant_run.conversation_id)))))) WITH CHECK (((school_id = public.chat_scope_school()) AND (EXISTS ( SELECT 1
   FROM public.conversation c
  WHERE ((c.school_id = assistant_run.school_id) AND (c.id = assistant_run.conversation_id))))));


--
-- Name: chat_message private_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY private_scope ON public.chat_message USING (((school_id = public.chat_scope_school()) AND (EXISTS ( SELECT 1
   FROM public.conversation c
  WHERE ((c.school_id = chat_message.school_id) AND (c.id = chat_message.conversation_id)))))) WITH CHECK (((school_id = public.chat_scope_school()) AND (EXISTS ( SELECT 1
   FROM public.conversation c
  WHERE ((c.school_id = chat_message.school_id) AND (c.id = chat_message.conversation_id))))));


--
-- Name: tool_invocation private_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY private_scope ON public.tool_invocation USING (((school_id = public.chat_scope_school()) AND (EXISTS ( SELECT 1
   FROM public.conversation c
  WHERE ((c.school_id = tool_invocation.school_id) AND (c.id = tool_invocation.conversation_id)))))) WITH CHECK (((school_id = public.chat_scope_school()) AND (EXISTS ( SELECT 1
   FROM public.conversation c
  WHERE ((c.school_id = tool_invocation.school_id) AND (c.id = tool_invocation.conversation_id))))));


--
-- Name: tool_invocation; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tool_invocation ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--

\unrestrict PP8dL2irj3eeOr0Km3FLmclvp0YolMcLJ6TYeBBmKAxIcn4PqjwaUL5iaXajgOs

