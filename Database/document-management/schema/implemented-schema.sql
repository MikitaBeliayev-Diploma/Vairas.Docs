--
-- PostgreSQL database dump
--

\restrict Sq8h7ik8oLulVEUH4INDmwjzQITABOYLBLcQCxLg2y6SBQRV6K0t9rHDtdwjsbJ

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
-- Name: dm_activate_template(uuid, uuid, uuid, bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.dm_activate_template(s uuid, t uuid, v uuid, expected_revision bigint) RETURNS bigint
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    DECLARE old_id uuid; r bigint;
    BEGIN
      SELECT active_version_id,revision INTO old_id,r FROM document_template
        WHERE school_id=s AND template_id=t FOR UPDATE;
      IF NOT FOUND OR r<>expected_revision THEN RAISE EXCEPTION 'Template CAS conflict'; END IF;
      IF NOT EXISTS(SELECT 1 FROM template_version WHERE school_id=s AND template_id=t
          AND template_version_id=v AND status='Draft') THEN
        RAISE EXCEPTION 'Activation requires own Draft version';
      END IF;
      IF old_id IS NOT NULL THEN
        UPDATE template_version SET status='Archived'
          WHERE school_id=s AND template_id=t AND template_version_id=old_id;
      END IF;
      UPDATE template_version SET status='Active'
        WHERE school_id=s AND template_id=t AND template_version_id=v;
      UPDATE document_template SET active_version_id=v,revision=revision+1
        WHERE school_id=s AND template_id=t;
      RETURN r+1;
    END $$;


--
-- Name: dm_artifact_file_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.dm_artifact_file_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    BEGIN
      PERFORM dm_require_file(NEW.school_id,NEW.file_id,'Rendered');
      IF NOT EXISTS(SELECT 1 FROM file_object WHERE school_id=NEW.school_id AND file_id=NEW.file_id AND
        media_type=CASE WHEN NEW.format='pdf' THEN 'application/pdf' ELSE 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' END)
        THEN RAISE EXCEPTION 'Rendered artifact format mismatch'; END IF;
      RETURN NEW;
    END $$;


--
-- Name: dm_check_checkpoint_selection(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.dm_check_checkpoint_selection() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    BEGIN
      IF EXISTS (SELECT 1 FROM training_document d JOIN document_version v
        ON (v.school_id,v.document_id,v.document_version_id)=
           (d.school_id,d.document_id,d.current_version_id)
        WHERE d.school_id=NEW.school_id AND d.enrollment_id=NEW.enrollment_id
          AND v.dependency_revision<NEW.dependency_revision) THEN
        RAISE EXCEPTION 'New evidence watermark requires clearing older current selections';
      END IF;
      RETURN NULL;
    END $$;


--
-- Name: dm_check_contract(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.dm_check_contract() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    DECLARE s uuid:=NEW.school_id; c uuid:=NEW.contract_id; st text; n integer;
    BEGIN
      SELECT status INTO st FROM training_contract WHERE school_id=s AND contract_id=c FOR UPDATE;
      SELECT count(*) INTO n FROM contract_signed_copy WHERE school_id=s AND contract_id=c AND is_current;
      IF (st='Signed' AND n<>1) OR (st='Generated' AND n<>0) THEN
        RAISE EXCEPTION 'Signed requires exactly one current copy; Generated requires none';
      END IF;
       
      RETURN NULL;
    END $$;


--
-- Name: dm_check_selection(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.dm_check_selection() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    DECLARE s uuid:=NEW.school_id; d uuid:=NEW.document_id; ptr uuid; e uuid;
    BEGIN
      SELECT enrollment_id INTO e FROM training_document WHERE school_id=s AND document_id=d;
      PERFORM 1 FROM evidence_checkpoint WHERE school_id=s AND enrollment_id=e FOR UPDATE;
       
       
      SELECT current_version_id INTO ptr FROM training_document WHERE school_id=s AND document_id=d FOR UPDATE;
      IF ptr IS NOT NULL AND NOT EXISTS(SELECT 1 FROM document_version v
        JOIN evidence_checkpoint c ON (c.school_id,c.enrollment_id)=(v.school_id,v.enrollment_id)
        WHERE v.school_id=s AND v.document_id=d AND v.document_version_id=ptr
          AND v.state IN ('PublishedReview','PublishedReady')
          AND v.dependency_revision>=c.dependency_revision) THEN
        RAISE EXCEPTION 'Current pointer requires own published, nonstale version';
      END IF;
      RETURN NULL;
    END $$;


--
-- Name: dm_check_template(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.dm_check_template() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    DECLARE s uuid := NEW.school_id; t uuid := NEW.template_id; ptr uuid; active_id uuid;
    BEGIN
      SELECT active_version_id INTO ptr FROM document_template
        WHERE school_id=s AND template_id=t FOR UPDATE;
      SELECT template_version_id INTO active_id FROM template_version
        WHERE school_id=s AND template_id=t AND status='Active';
      IF ptr IS DISTINCT FROM active_id THEN
        RAISE EXCEPTION 'Active pointer must equal the sole Active template version';
      END IF;
      RETURN NULL;
    END $$;


--
-- Name: dm_checkpoint_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.dm_checkpoint_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    BEGIN
      IF TG_OP='DELETE' THEN RAISE EXCEPTION 'Checkpoint deletion requires approved migration'; END IF;
      IF (NEW.school_id,NEW.enrollment_id) IS DISTINCT FROM (OLD.school_id,OLD.enrollment_id)
         OR NEW.dependency_revision<=OLD.dependency_revision THEN
        RAISE EXCEPTION 'Checkpoint identity immutable; only strictly higher revisions apply';
      END IF;
      RETURN NEW;
    END $$;


--
-- Name: dm_contract_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.dm_contract_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    DECLARE k text;
    BEGIN
      IF TG_OP='INSERT' THEN
         
         
         
        IF NEW.replaces_contract_id IS NOT NULL THEN
          PERFORM 1 FROM training_contract WHERE school_id=NEW.school_id
            AND enrollment_id=NEW.enrollment_id AND contract_id=NEW.replaces_contract_id
            FOR KEY SHARE;
          IF NOT FOUND THEN RAISE EXCEPTION 'Replacement requires an already existing same-enrollment predecessor'; END IF;
        END IF;
        PERFORM 1 FROM document_template t JOIN template_version v
          ON (t.school_id,t.template_id)=(v.school_id,v.template_id)
          WHERE v.school_id=NEW.school_id AND v.template_version_id=NEW.template_version_id
          FOR SHARE OF t;
        SELECT t.kind INTO k FROM template_version v JOIN document_template t
          ON (t.school_id,t.template_id)=(v.school_id,v.template_id)
          WHERE v.school_id=NEW.school_id AND v.template_version_id=NEW.template_version_id
            AND v.status='Active';
        IF k IS DISTINCT FROM 'TrainingContract' THEN
          RAISE EXCEPTION 'Contract requires Active TrainingContract template';
        END IF;
        IF NEW.status<>'Generated' THEN RAISE EXCEPTION 'New contract starts Generated'; END IF;
        PERFORM dm_require_file(NEW.school_id,NEW.generated_file_id,'Rendered');
        PERFORM dm_require_file(NEW.school_id,NEW.basis_file_id,'SourceBasis');
      ELSIF NOT ((OLD.status='Generated' AND NEW.status IN ('Signed','Cancelled'))
              OR (OLD.status='Signed' AND NEW.status IN ('Signed','Cancelled'))) THEN
        RAISE EXCEPTION 'Invalid contract transition';
      END IF;
      RETURN NEW;
    END $$;


--
-- Name: dm_enrollment_catalogue(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.dm_enrollment_catalogue() RETURNS TABLE(school_id uuid, enrollment_id uuid)
    LANGUAGE sql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
     SELECT DISTINCT school_id,enrollment_id FROM public.training_document ORDER BY school_id,enrollment_id
    $$;


--
-- Name: dm_event_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.dm_event_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    DECLARE r operation_receipt%ROWTYPE; d training_document%ROWTYPE; event_document uuid;
    BEGIN
      SELECT * INTO r FROM operation_receipt WHERE school_id=NEW.school_id
        AND command_id=NEW.command_id FOR UPDATE;
      IF NOT FOUND OR r.actor_id<>NEW.actor_id OR r.status NOT IN ('Pending','Indeterminate') THEN
        RAISE EXCEPTION 'Event requires same-school actor and open operation receipt';
      END IF;
      IF (r.template_id IS NOT NULL AND r.template_id IS DISTINCT FROM NEW.template_id)
        OR (r.contract_id IS NOT NULL AND r.contract_id IS DISTINCT FROM NEW.contract_id)
        OR (r.document_version_id IS NOT NULL AND NEW.document_id IS NULL
            AND r.document_version_id IS DISTINCT FROM NEW.document_version_id) THEN
        RAISE EXCEPTION 'Event/operation target mismatch';
      END IF;
      event_document := NEW.document_id;
      IF NEW.document_version_id IS NOT NULL THEN
        SELECT document_id INTO event_document FROM document_version
          WHERE school_id=NEW.school_id AND document_version_id=NEW.document_version_id;
      END IF;
      IF r.document_id IS NOT NULL AND r.document_id IS DISTINCT FROM event_document THEN
        RAISE EXCEPTION 'Event/operation document mismatch';
      END IF;
      IF NEW.contract_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM training_contract
        WHERE school_id=NEW.school_id AND contract_id=NEW.contract_id
          AND revision=NEW.sequence_no AND status=NEW.to_state) THEN
        RAISE EXCEPTION 'Contract event must describe its current revision and state';
      END IF;
      IF NEW.document_version_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM document_version
        WHERE school_id=NEW.school_id AND document_version_id=NEW.document_version_id
          AND revision=NEW.sequence_no AND state=NEW.to_state) THEN
        RAISE EXCEPTION 'Version event must describe its current revision and state';
      END IF;
      IF NEW.document_id IS NOT NULL THEN
        SELECT * INTO d FROM training_document WHERE school_id=NEW.school_id AND document_id=NEW.document_id;
        IF NOT FOUND OR NEW.sequence_no<>d.revision
          OR NEW.to_state<>coalesce(d.current_version_id::text,'Unselected')
          OR NEW.action NOT IN ('DocumentCreated','DocumentChanged','CurrentVersionSelected','CurrentVersionCleared') THEN
          RAISE EXCEPTION 'TrainingDocument event must describe its current root revision and selection';
        END IF;
        IF r.document_version_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM document_version
          WHERE school_id=NEW.school_id AND document_version_id=r.document_version_id
            AND document_id=NEW.document_id) THEN
          RAISE EXCEPTION 'Root event does not belong to operation result version';
        END IF;
      END IF;
      RETURN NEW;
    END $$;


--
-- Name: dm_file_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.dm_file_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    BEGIN
      IF TG_OP = 'DELETE' THEN RAISE EXCEPTION 'File deletion requires approved retention workflow'; END IF;
      IF TG_OP = 'INSERT' THEN
        IF NEW.scan_status <> 'Pending' THEN RAISE EXCEPTION 'New files start Pending'; END IF;
      ELSE
        IF OLD.scan_status <> 'Pending' OR NEW.scan_status NOT IN ('Clean','Rejected')
           OR (to_jsonb(OLD)-'scan_status') IS DISTINCT FROM (to_jsonb(NEW)-'scan_status') THEN
          RAISE EXCEPTION 'Only immutable Pending -> Clean/Rejected is allowed';
        END IF;
      END IF;
      RETURN NEW;
    END $$;


--
-- Name: dm_freeze_columns(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.dm_freeze_columns() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    DECLARE allowed text[] := string_to_array(TG_ARGV[0], ',');
    BEGIN
      IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'Historical row deletion requires a separately approved retention migration';
      END IF;
      IF (to_jsonb(OLD) - allowed) IS DISTINCT FROM (to_jsonb(NEW) - allowed) THEN
        RAISE EXCEPTION 'Immutable payload changed on %', TG_TABLE_NAME;
      END IF;
      RETURN NEW;
    END $$;


--
-- Name: dm_pending_files(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.dm_pending_files() RETURNS TABLE(school_id uuid, id uuid)
    LANGUAGE sql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
     SELECT school_id,file_id FROM public.file_object WHERE scan_status='Pending' ORDER BY uploaded_at,file_id LIMIT 100
    $$;


--
-- Name: dm_pending_jobs(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.dm_pending_jobs() RETURNS TABLE(school_id uuid, id uuid)
    LANGUAGE sql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
     SELECT school_id,id FROM public.document_job WHERE status IN ('Pending','Generating') AND next_attempt_at<=now() AND (lease_until IS NULL OR lease_until<=now()) ORDER BY next_attempt_at,id LIMIT 100
    $$;


--
-- Name: dm_pending_publications(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.dm_pending_publications() RETURNS TABLE(school_id uuid, id uuid)
    LANGUAGE sql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
     SELECT school_id,id FROM public.publication_decision WHERE status='Pending' ORDER BY created_at,id LIMIT 100
    $$;


--
-- Name: dm_receipt_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.dm_receipt_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    BEGIN
      IF TG_OP='DELETE' THEN RAISE EXCEPTION 'Receipt deletion requires approved policy'; END IF;
      IF TG_OP='INSERT' THEN
        IF NEW.status<>'Pending' THEN RAISE EXCEPTION 'Reserve Pending command first'; END IF;
      ELSE
        IF OLD.status IN ('Succeeded','Rejected') OR
          (to_jsonb(OLD)-ARRAY['status','template_id','template_version_id','contract_id','document_id','document_version_id','outcome_code','completed_at'])
          IS DISTINCT FROM
          (to_jsonb(NEW)-ARRAY['status','template_id','template_version_id','contract_id','document_id','document_version_id','outcome_code','completed_at']) THEN
          RAISE EXCEPTION 'Receipt request identity and terminal outcomes are immutable';
        END IF;
        IF (OLD.template_id IS NOT NULL AND OLD.template_id IS DISTINCT FROM NEW.template_id)
           OR (OLD.template_version_id IS NOT NULL AND OLD.template_version_id IS DISTINCT FROM NEW.template_version_id)
           OR (OLD.contract_id IS NOT NULL AND OLD.contract_id IS DISTINCT FROM NEW.contract_id)
           OR (OLD.document_id IS NOT NULL AND OLD.document_id IS DISTINCT FROM NEW.document_id)
           OR (OLD.document_version_id IS NOT NULL AND OLD.document_version_id IS DISTINCT FROM NEW.document_version_id) THEN
          RAISE EXCEPTION 'Known operation result cannot be rebound';
        END IF;
      END IF;
      RETURN NEW;
    END $$;


--
-- Name: dm_require_copy_event(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.dm_require_copy_event() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    BEGIN
      IF NOT EXISTS(SELECT 1 FROM state_event e WHERE e.school_id=NEW.school_id
        AND e.contract_id=NEW.contract_id AND e.signed_copy_id=NEW.signed_copy_id
        AND e.action IN ('SignedCopyAttached','SignedCopyReplaced')) THEN
        RAISE EXCEPTION 'New signed copy requires structured attachment/replacement audit';
      END IF;
      RETURN NULL;
    END $$;


--
-- Name: dm_require_file(uuid, uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.dm_require_file(s uuid, f uuid, expected_purpose text) RETURNS void
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    BEGIN
      IF NOT EXISTS (SELECT 1 FROM file_object WHERE school_id=s AND file_id=f
          AND scan_status='Clean' AND purpose=expected_purpose) THEN
        RAISE EXCEPTION 'Artifact requires Clean file of expected purpose in same school';
      END IF;
    END $$;


--
-- Name: dm_require_revision_event(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.dm_require_revision_event() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    DECLARE ok boolean;
    BEGIN
      IF TG_TABLE_NAME='document_template' THEN
        SELECT EXISTS(SELECT 1 FROM state_event WHERE school_id=NEW.school_id
          AND template_id=NEW.template_id AND sequence_no=NEW.revision
          AND to_state=CASE WHEN NEW.active_version_id IS NULL THEN 'NoActiveVersion' ELSE 'Active' END) INTO ok;
      ELSIF TG_TABLE_NAME='training_contract' THEN
        SELECT EXISTS(SELECT 1 FROM state_event WHERE school_id=NEW.school_id
          AND contract_id=NEW.contract_id AND sequence_no=NEW.revision
          AND to_state=NEW.status AND from_state IS NOT DISTINCT FROM
            CASE WHEN TG_OP='INSERT' THEN NULL ELSE OLD.status END) INTO ok;
      ELSIF TG_TABLE_NAME='training_document' THEN
        SELECT EXISTS(SELECT 1 FROM state_event WHERE school_id=NEW.school_id
          AND document_id=NEW.document_id AND sequence_no=NEW.revision
          AND from_state IS NOT DISTINCT FROM CASE WHEN TG_OP='INSERT' THEN NULL
            ELSE coalesce(OLD.current_version_id::text,'Unselected') END
          AND to_state=coalesce(NEW.current_version_id::text,'Unselected')
          AND action=CASE
            WHEN TG_OP='INSERT' THEN 'DocumentCreated'
            WHEN OLD.current_version_id IS NOT DISTINCT FROM NEW.current_version_id THEN 'DocumentChanged'
            WHEN NEW.current_version_id IS NULL THEN 'CurrentVersionCleared'
            ELSE 'CurrentVersionSelected' END) INTO ok;
      ELSE
        SELECT EXISTS(SELECT 1 FROM state_event WHERE school_id=NEW.school_id
          AND document_version_id=NEW.document_version_id AND sequence_no=NEW.revision
          AND to_state=NEW.state AND from_state IS NOT DISTINCT FROM
            CASE WHEN TG_OP='INSERT' THEN NULL ELSE OLD.state END) INTO ok;
      END IF;
      IF NOT ok THEN RAISE EXCEPTION 'Missing matching lifecycle revision audit event'; END IF;
      RETURN NULL;
    END $$;


--
-- Name: dm_revision_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.dm_revision_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    BEGIN
      IF TG_OP = 'INSERT' THEN
        IF NEW.revision <> 1 THEN RAISE EXCEPTION 'Initial revision must be 1'; END IF;
      ELSIF NEW.revision <> OLD.revision + 1 THEN
        RAISE EXCEPTION 'Revision must advance by exactly one';
      END IF;
      RETURN NEW;
    END $$;


--
-- Name: dm_signed_copy_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.dm_signed_copy_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    DECLARE st text;
    BEGIN
      SELECT status INTO st FROM training_contract WHERE school_id=NEW.school_id
        AND contract_id=NEW.contract_id FOR UPDATE;
      IF st IS NULL OR st='Cancelled' THEN RAISE EXCEPTION 'Contract cannot accept signed-copy changes'; END IF;
      PERFORM dm_require_file(NEW.school_id,NEW.file_id,'SignedCopy');
      IF TG_OP='INSERT' THEN
        IF NOT NEW.is_current THEN RAISE EXCEPTION 'New signed copy must be selected'; END IF;
      ELSIF NOT (OLD.is_current AND NOT NEW.is_current) THEN
        RAISE EXCEPTION 'Signed-copy history cannot be reselected or edited';
      END IF;
      RETURN NEW;
    END $$;


--
-- Name: dm_template_version_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.dm_template_version_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    BEGIN
      PERFORM 1 FROM document_template WHERE school_id=NEW.school_id
        AND template_id=NEW.template_id FOR UPDATE;
      IF NOT FOUND THEN RAISE EXCEPTION 'Template parent unavailable'; END IF;
      PERFORM dm_require_file(NEW.school_id, NEW.file_id, 'Template');
      IF TG_OP='INSERT' THEN
        IF NEW.status <> 'Draft' THEN RAISE EXCEPTION 'New template version starts Draft'; END IF;
      ELSIF NOT ((OLD.status='Draft' AND NEW.status IN ('Active','Archived'))
             OR (OLD.status='Active' AND NEW.status='Archived')) THEN
        RAISE EXCEPTION 'Invalid template version transition';
      END IF;
      RETURN NEW;
    END $$;


--
-- Name: dm_version_guard(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.dm_version_guard() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
    DECLARE dk text; tk text; watermark bigint;
    BEGIN
       
       
      SELECT dependency_revision INTO watermark FROM evidence_checkpoint
        WHERE school_id=NEW.school_id AND enrollment_id=NEW.enrollment_id FOR UPDATE;
      IF NOT FOUND THEN RAISE EXCEPTION 'Initialize authoritative evidence checkpoint first'; END IF;
      SELECT kind INTO dk FROM training_document WHERE school_id=NEW.school_id
        AND document_id=NEW.document_id AND enrollment_id=NEW.enrollment_id FOR UPDATE;
      IF dk IS NULL THEN RAISE EXCEPTION 'Document owner mismatch'; END IF;
      IF TG_OP='INSERT' THEN
        PERFORM 1 FROM document_template t JOIN template_version v
          ON (t.school_id,t.template_id)=(v.school_id,v.template_id)
          WHERE v.school_id=NEW.school_id AND v.template_version_id=NEW.template_version_id
          FOR SHARE OF t;
        SELECT t.kind INTO tk FROM template_version v JOIN document_template t
          ON (t.school_id,t.template_id)=(v.school_id,v.template_id)
          WHERE v.school_id=NEW.school_id AND v.template_version_id=NEW.template_version_id
            AND v.status='Active';
        IF tk IS DISTINCT FROM dk THEN RAISE EXCEPTION 'Document/template kind mismatch or inactive template'; END IF;
        IF NEW.state<>'Prepared' THEN RAISE EXCEPTION 'New document version starts Prepared'; END IF;
        PERFORM dm_require_file(NEW.school_id,NEW.rendered_file_id,'Rendered');
        PERFORM dm_require_file(NEW.school_id,NEW.basis_file_id,'SourceBasis');
      ELSIF NOT (
        (OLD.state='Prepared' AND NEW.state IN ('Indeterminate','PublishedReview','PublishedReady','Stale','Withdrawn')) OR
        (OLD.state='Indeterminate' AND NEW.state IN ('PublishedReview','PublishedReady','Stale','Withdrawn')) OR
        (OLD.state IN ('PublishedReview','PublishedReady') AND NEW.state IN (OLD.state,'Stale','Withdrawn')) OR
        (OLD.state='Stale' AND NEW.state='Withdrawn')) THEN
        RAISE EXCEPTION 'Invalid document version transition';
      END IF;
      IF NEW.state IN ('PublishedReview','PublishedReady') AND NEW.dependency_revision < watermark THEN
        RAISE EXCEPTION 'Known newer evidence prevents publication';
      END IF;
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
-- Name: contract_signed_copy; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contract_signed_copy (
    signed_copy_id uuid NOT NULL,
    school_id uuid NOT NULL,
    contract_id uuid NOT NULL,
    copy_no integer NOT NULL,
    file_id uuid NOT NULL,
    is_current boolean NOT NULL,
    declared_signed_at timestamp with time zone NOT NULL,
    recorded_at timestamp with time zone NOT NULL,
    recorded_by uuid NOT NULL,
    basis text NOT NULL,
    CONSTRAINT contract_signed_copy_basis_check CHECK ((length(TRIM(BOTH FROM basis)) > 0)),
    CONSTRAINT contract_signed_copy_check CHECK ((declared_signed_at <= recorded_at)),
    CONSTRAINT contract_signed_copy_copy_no_check CHECK ((copy_no > 0))
);


--
-- Name: document_job; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_job (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    enrollment_id uuid NOT NULL,
    actor_id uuid NOT NULL,
    identity_id uuid NOT NULL,
    session_id uuid NOT NULL,
    template_version_id uuid NOT NULL,
    snapshot_id uuid,
    replaces_contract_id uuid,
    source_snapshot_version text NOT NULL,
    kind text NOT NULL,
    status text NOT NULL,
    document_id uuid,
    error_code text,
    attempts integer NOT NULL,
    next_attempt_at timestamp with time zone NOT NULL,
    lease_until timestamp with time zone,
    lease_id uuid,
    created_at timestamp with time zone NOT NULL,
    missing_items_json text DEFAULT '[]'::text NOT NULL,
    result_version_id uuid,
    CONSTRAINT document_job_attempts_check CHECK ((attempts >= 0)),
    CONSTRAINT document_job_kind_check CHECK ((kind = ANY (ARRAY['TrainingContract'::text, 'PracticalJournal'::text, 'CompletionReport'::text]))),
    CONSTRAINT document_job_status_check CHECK ((status = ANY (ARRAY['Pending'::text, 'Generating'::text, 'Completed'::text, 'Failed'::text])))
);


--
-- Name: document_review; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_review (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    document_version_id uuid NOT NULL,
    actor_id uuid NOT NULL,
    reviewed_at timestamp with time zone NOT NULL,
    reason text NOT NULL
);


--
-- Name: document_template; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_template (
    template_id uuid NOT NULL,
    school_id uuid NOT NULL,
    kind character varying NOT NULL,
    name character varying NOT NULL,
    active_version_id uuid,
    revision bigint NOT NULL,
    CONSTRAINT document_template_kind_check CHECK (((kind)::text = ANY ((ARRAY['TrainingContract'::character varying, 'PracticalJournal'::character varying, 'CompletionReport'::character varying])::text[]))),
    CONSTRAINT document_template_name_check CHECK ((length(TRIM(BOTH FROM name)) > 0)),
    CONSTRAINT document_template_revision_check CHECK ((revision > 0))
);


--
-- Name: document_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_version (
    document_version_id uuid NOT NULL,
    school_id uuid NOT NULL,
    document_id uuid NOT NULL,
    enrollment_id uuid NOT NULL,
    version_no integer NOT NULL,
    template_version_id uuid NOT NULL,
    evidence_snapshot_id uuid NOT NULL,
    dependency_revision bigint NOT NULL,
    evidence_status character varying NOT NULL,
    rendered_file_id uuid NOT NULL,
    basis_file_id uuid NOT NULL,
    basis_schema_version character varying NOT NULL,
    renderer_version character varying NOT NULL,
    state character varying NOT NULL,
    revision bigint NOT NULL,
    generated_by uuid NOT NULL,
    generated_at timestamp with time zone NOT NULL,
    CONSTRAINT document_version_check CHECK ((((state)::text <> 'PublishedReady'::text) OR ((evidence_status)::text = 'Ready'::text))),
    CONSTRAINT document_version_check1 CHECK (((length(TRIM(BOTH FROM basis_schema_version)) > 0) AND (length(TRIM(BOTH FROM renderer_version)) > 0))),
    CONSTRAINT document_version_dependency_revision_check CHECK ((dependency_revision >= 0)),
    CONSTRAINT document_version_evidence_status_check CHECK (((evidence_status)::text = ANY ((ARRAY['Ready'::character varying, 'Incomplete'::character varying])::text[]))),
    CONSTRAINT document_version_revision_check CHECK ((revision > 0)),
    CONSTRAINT document_version_state_check CHECK (((state)::text = ANY ((ARRAY['Prepared'::character varying, 'Indeterminate'::character varying, 'PublishedReview'::character varying, 'PublishedReady'::character varying, 'Stale'::character varying, 'Withdrawn'::character varying])::text[]))),
    CONSTRAINT document_version_version_no_check CHECK ((version_no > 0))
);


--
-- Name: download_grant; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.download_grant (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    actor_id uuid NOT NULL,
    document_id uuid NOT NULL,
    file_id uuid NOT NULL,
    version_id uuid,
    historical boolean NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    signed_copy_id uuid
);


--
-- Name: evidence_checkpoint; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.evidence_checkpoint (
    school_id uuid NOT NULL,
    enrollment_id uuid NOT NULL,
    dependency_revision bigint NOT NULL,
    last_change_id uuid NOT NULL,
    observed_at timestamp with time zone NOT NULL,
    CONSTRAINT evidence_checkpoint_dependency_revision_check CHECK ((dependency_revision >= 0))
);


--
-- Name: file_object; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_object (
    file_id uuid NOT NULL,
    school_id uuid NOT NULL,
    storage_key character varying NOT NULL,
    purpose character varying NOT NULL,
    sha256 character varying(64) NOT NULL,
    byte_length bigint NOT NULL,
    media_type character varying NOT NULL,
    scan_status character varying NOT NULL,
    uploaded_by uuid NOT NULL,
    uploaded_at timestamp with time zone NOT NULL,
    CONSTRAINT file_object_byte_length_check CHECK ((byte_length > 0)),
    CONSTRAINT file_object_check CHECK (((length(TRIM(BOTH FROM storage_key)) > 0) AND (length(TRIM(BOTH FROM media_type)) > 0))),
    CONSTRAINT file_object_purpose_check CHECK (((purpose)::text = ANY ((ARRAY['Template'::character varying, 'Rendered'::character varying, 'SignedCopy'::character varying, 'SourceBasis'::character varying])::text[]))),
    CONSTRAINT file_object_scan_status_check CHECK (((scan_status)::text = ANY ((ARRAY['Pending'::character varying, 'Clean'::character varying, 'Rejected'::character varying])::text[]))),
    CONSTRAINT file_object_sha256_check CHECK (((sha256)::text ~ '^[0-9a-f]{64}$'::text))
);


--
-- Name: inbox_message; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inbox_message (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    fingerprint text NOT NULL,
    processed_at timestamp with time zone NOT NULL
);


--
-- Name: operation_outcome; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.operation_outcome (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    response_json text NOT NULL
);


--
-- Name: operation_receipt; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.operation_receipt (
    command_id uuid NOT NULL,
    school_id uuid NOT NULL,
    actor_id uuid NOT NULL,
    template_id uuid,
    template_version_id uuid,
    operation character varying NOT NULL,
    request_digest character varying(64) NOT NULL,
    status character varying NOT NULL,
    contract_id uuid,
    document_id uuid,
    document_version_id uuid,
    outcome_code character varying,
    created_at timestamp with time zone NOT NULL,
    completed_at timestamp with time zone,
    CONSTRAINT operation_receipt_check CHECK (((((status)::text = ANY ((ARRAY['Pending'::character varying, 'Indeterminate'::character varying])::text[])) AND (completed_at IS NULL)) OR (((status)::text = ANY ((ARRAY['Succeeded'::character varying, 'Rejected'::character varying])::text[])) AND (completed_at IS NOT NULL)))),
    CONSTRAINT operation_receipt_check1 CHECK (((completed_at IS NULL) OR (completed_at >= created_at))),
    CONSTRAINT operation_receipt_check2 CHECK ((num_nonnulls(template_id, contract_id, document_id, document_version_id) <= 1)),
    CONSTRAINT operation_receipt_check3 CHECK (((template_version_id IS NULL) OR (template_id IS NOT NULL))),
    CONSTRAINT operation_receipt_check4 CHECK ((((status)::text <> ALL ((ARRAY['Succeeded'::character varying, 'Rejected'::character varying])::text[])) OR (outcome_code IS NOT NULL))),
    CONSTRAINT operation_receipt_check5 CHECK (((length(TRIM(BOTH FROM operation)) > 0) AND ((outcome_code IS NULL) OR (length(TRIM(BOTH FROM outcome_code)) > 0)))),
    CONSTRAINT operation_receipt_request_digest_check CHECK (((request_digest)::text ~ '^[0-9a-f]{64}$'::text)),
    CONSTRAINT operation_receipt_status_check CHECK (((status)::text = ANY ((ARRAY['Pending'::character varying, 'Succeeded'::character varying, 'Rejected'::character varying, 'Indeterminate'::character varying])::text[])))
);


--
-- Name: publication_decision; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publication_decision (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    document_version_id uuid NOT NULL,
    actor_id uuid NOT NULL,
    identity_id uuid NOT NULL,
    session_id uuid NOT NULL,
    expected_revision bigint NOT NULL,
    expected_version_revision bigint NOT NULL,
    artifact_digest text NOT NULL,
    status text NOT NULL,
    reason text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    decided_at timestamp with time zone,
    CONSTRAINT publication_decision_status_check CHECK ((status = ANY (ARRAY['Pending'::text, 'Accepted'::text, 'Rejected'::text, 'Stale'::text])))
);


--
-- Name: rendered_artifact; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rendered_artifact (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    contract_id uuid,
    document_version_id uuid,
    file_id uuid NOT NULL,
    format text NOT NULL,
    CONSTRAINT rendered_artifact_check CHECK ((num_nonnulls(contract_id, document_version_id) = 1)),
    CONSTRAINT rendered_artifact_format_check CHECK ((format = ANY (ARRAY['pdf'::text, 'docx'::text])))
);


--
-- Name: state_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.state_event (
    event_id uuid NOT NULL,
    school_id uuid NOT NULL,
    template_id uuid,
    template_version_id uuid,
    signed_copy_id uuid,
    action character varying NOT NULL,
    contract_id uuid,
    document_id uuid,
    document_version_id uuid,
    sequence_no bigint NOT NULL,
    from_state character varying,
    to_state character varying NOT NULL,
    actor_id uuid NOT NULL,
    occurred_at timestamp with time zone NOT NULL,
    reason text NOT NULL,
    command_id uuid NOT NULL,
    CONSTRAINT state_event_action_check CHECK ((length(TRIM(BOTH FROM action)) > 0)),
    CONSTRAINT state_event_check CHECK ((num_nonnulls(template_id, contract_id, document_id, document_version_id) = 1)),
    CONSTRAINT state_event_check1 CHECK (((template_version_id IS NULL) OR (template_id IS NOT NULL))),
    CONSTRAINT state_event_check2 CHECK (((signed_copy_id IS NULL) OR (contract_id IS NOT NULL))),
    CONSTRAINT state_event_reason_check CHECK ((length(TRIM(BOTH FROM reason)) > 0)),
    CONSTRAINT state_event_sequence_no_check CHECK ((sequence_no > 0))
);


--
-- Name: template_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.template_version (
    template_version_id uuid NOT NULL,
    school_id uuid NOT NULL,
    template_id uuid NOT NULL,
    version_no integer NOT NULL,
    status character varying NOT NULL,
    file_id uuid NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT template_version_status_check CHECK (((status)::text = ANY ((ARRAY['Draft'::character varying, 'Active'::character varying, 'Archived'::character varying])::text[]))),
    CONSTRAINT template_version_version_no_check CHECK ((version_no > 0))
);


--
-- Name: training_contract; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.training_contract (
    contract_id uuid NOT NULL,
    school_id uuid NOT NULL,
    enrollment_id uuid NOT NULL,
    student_id uuid NOT NULL,
    template_version_id uuid NOT NULL,
    generated_file_id uuid NOT NULL,
    basis_file_id uuid NOT NULL,
    basis_schema_version character varying NOT NULL,
    status character varying NOT NULL,
    replaces_contract_id uuid,
    generated_by uuid NOT NULL,
    generated_at timestamp with time zone NOT NULL,
    revision bigint NOT NULL,
    CONSTRAINT training_contract_basis_schema_version_check CHECK ((length(TRIM(BOTH FROM basis_schema_version)) > 0)),
    CONSTRAINT training_contract_check CHECK (((replaces_contract_id IS NULL) OR (replaces_contract_id <> contract_id))),
    CONSTRAINT training_contract_revision_check CHECK ((revision > 0)),
    CONSTRAINT training_contract_status_check CHECK (((status)::text = ANY ((ARRAY['Generated'::character varying, 'Signed'::character varying, 'Cancelled'::character varying])::text[])))
);


--
-- Name: training_document; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.training_document (
    document_id uuid NOT NULL,
    school_id uuid NOT NULL,
    enrollment_id uuid NOT NULL,
    kind character varying NOT NULL,
    revision bigint NOT NULL,
    current_version_id uuid,
    CONSTRAINT training_document_kind_check CHECK (((kind)::text = ANY ((ARRAY['PracticalJournal'::character varying, 'CompletionReport'::character varying])::text[]))),
    CONSTRAINT training_document_revision_check CHECK ((revision > 0))
);


--
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- Name: contract_signed_copy contract_signed_copy_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contract_signed_copy
    ADD CONSTRAINT contract_signed_copy_pkey PRIMARY KEY (signed_copy_id);


--
-- Name: document_job document_job_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_job
    ADD CONSTRAINT document_job_pkey PRIMARY KEY (id);


--
-- Name: document_job document_job_school_id_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_job
    ADD CONSTRAINT document_job_school_id_id_key UNIQUE (school_id, id);


--
-- Name: document_review document_review_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_review
    ADD CONSTRAINT document_review_pkey PRIMARY KEY (id);


--
-- Name: document_template document_template_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_template
    ADD CONSTRAINT document_template_pkey PRIMARY KEY (template_id);


--
-- Name: document_version document_version_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_version
    ADD CONSTRAINT document_version_pkey PRIMARY KEY (document_version_id);


--
-- Name: download_grant download_grant_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.download_grant
    ADD CONSTRAINT download_grant_pkey PRIMARY KEY (id);


--
-- Name: evidence_checkpoint evidence_checkpoint_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evidence_checkpoint
    ADD CONSTRAINT evidence_checkpoint_pkey PRIMARY KEY (school_id, enrollment_id);


--
-- Name: file_object file_object_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_object
    ADD CONSTRAINT file_object_pkey PRIMARY KEY (file_id);


--
-- Name: inbox_message inbox_message_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inbox_message
    ADD CONSTRAINT inbox_message_pkey PRIMARY KEY (id);


--
-- Name: operation_outcome operation_outcome_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operation_outcome
    ADD CONSTRAINT operation_outcome_pkey PRIMARY KEY (school_id, id);


--
-- Name: operation_receipt operation_receipt_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operation_receipt
    ADD CONSTRAINT operation_receipt_pkey PRIMARY KEY (command_id);


--
-- Name: publication_decision publication_decision_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publication_decision
    ADD CONSTRAINT publication_decision_pkey PRIMARY KEY (id);


--
-- Name: rendered_artifact rendered_artifact_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rendered_artifact
    ADD CONSTRAINT rendered_artifact_pkey PRIMARY KEY (id);


--
-- Name: state_event state_event_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.state_event
    ADD CONSTRAINT state_event_pkey PRIMARY KEY (event_id);


--
-- Name: template_version template_version_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_version
    ADD CONSTRAINT template_version_pkey PRIMARY KEY (template_version_id);


--
-- Name: training_contract training_contract_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_contract
    ADD CONSTRAINT training_contract_pkey PRIMARY KEY (contract_id);


--
-- Name: training_document training_document_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_document
    ADD CONSTRAINT training_document_pkey PRIMARY KEY (document_id);


--
-- Name: contract_signed_copy_school_id_contract_id_copy_no_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX contract_signed_copy_school_id_contract_id_copy_no_idx ON public.contract_signed_copy USING btree (school_id, contract_id, copy_no);


--
-- Name: contract_signed_copy_school_id_contract_id_signed_copy_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX contract_signed_copy_school_id_contract_id_signed_copy_id_idx ON public.contract_signed_copy USING btree (school_id, contract_id, signed_copy_id);


--
-- Name: contract_signed_copy_school_id_signed_copy_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX contract_signed_copy_school_id_signed_copy_id_idx ON public.contract_signed_copy USING btree (school_id, signed_copy_id);


--
-- Name: dm_contract_format; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX dm_contract_format ON public.rendered_artifact USING btree (school_id, contract_id, format) WHERE (contract_id IS NOT NULL);


--
-- Name: dm_due_jobs; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dm_due_jobs ON public.document_job USING btree (next_attempt_at) WHERE (status = ANY (ARRAY['Pending'::text, 'Generating'::text]));


--
-- Name: dm_event_command; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dm_event_command ON public.state_event USING btree (school_id, command_id);


--
-- Name: dm_evidence_versions; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dm_evidence_versions ON public.document_version USING btree (school_id, enrollment_id, dependency_revision);


--
-- Name: dm_one_active_template; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX dm_one_active_template ON public.template_version USING btree (school_id, template_id) WHERE ((status)::text = 'Active'::text);


--
-- Name: dm_one_current_signed_copy; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX dm_one_current_signed_copy ON public.contract_signed_copy USING btree (school_id, contract_id) WHERE is_current;


--
-- Name: dm_template_file; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dm_template_file ON public.template_version USING btree (school_id, file_id);


--
-- Name: dm_version_format; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX dm_version_format ON public.rendered_artifact USING btree (school_id, document_version_id, format) WHERE (document_version_id IS NOT NULL);


--
-- Name: dm_version_template; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dm_version_template ON public.document_version USING btree (school_id, template_version_id);


--
-- Name: document_template_school_id_template_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX document_template_school_id_template_id_idx ON public.document_template USING btree (school_id, template_id);


--
-- Name: document_version_school_id_document_id_document_version_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX document_version_school_id_document_id_document_version_id_idx ON public.document_version USING btree (school_id, document_id, document_version_id);


--
-- Name: document_version_school_id_document_id_version_no_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX document_version_school_id_document_id_version_no_idx ON public.document_version USING btree (school_id, document_id, version_no);


--
-- Name: document_version_school_id_document_version_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX document_version_school_id_document_version_id_idx ON public.document_version USING btree (school_id, document_version_id);


--
-- Name: file_object_school_id_file_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX file_object_school_id_file_id_idx ON public.file_object USING btree (school_id, file_id);


--
-- Name: file_object_school_id_storage_key_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX file_object_school_id_storage_key_idx ON public.file_object USING btree (school_id, storage_key);


--
-- Name: operation_receipt_school_id_command_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX operation_receipt_school_id_command_id_idx ON public.operation_receipt USING btree (school_id, command_id);


--
-- Name: state_event_school_id_contract_id_sequence_no_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX state_event_school_id_contract_id_sequence_no_idx ON public.state_event USING btree (school_id, contract_id, sequence_no);


--
-- Name: state_event_school_id_document_id_sequence_no_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX state_event_school_id_document_id_sequence_no_idx ON public.state_event USING btree (school_id, document_id, sequence_no);


--
-- Name: state_event_school_id_document_version_id_sequence_no_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX state_event_school_id_document_version_id_sequence_no_idx ON public.state_event USING btree (school_id, document_version_id, sequence_no);


--
-- Name: state_event_school_id_event_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX state_event_school_id_event_id_idx ON public.state_event USING btree (school_id, event_id);


--
-- Name: state_event_school_id_template_id_sequence_no_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX state_event_school_id_template_id_sequence_no_idx ON public.state_event USING btree (school_id, template_id, sequence_no);


--
-- Name: template_version_school_id_template_id_template_version_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX template_version_school_id_template_id_template_version_id_idx ON public.template_version USING btree (school_id, template_id, template_version_id);


--
-- Name: template_version_school_id_template_id_version_no_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX template_version_school_id_template_id_version_no_idx ON public.template_version USING btree (school_id, template_id, version_no);


--
-- Name: template_version_school_id_template_version_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX template_version_school_id_template_version_id_idx ON public.template_version USING btree (school_id, template_version_id);


--
-- Name: training_contract_school_id_contract_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX training_contract_school_id_contract_id_idx ON public.training_contract USING btree (school_id, contract_id);


--
-- Name: training_contract_school_id_enrollment_id_contract_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX training_contract_school_id_enrollment_id_contract_id_idx ON public.training_contract USING btree (school_id, enrollment_id, contract_id);


--
-- Name: training_document_school_id_document_id_enrollment_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX training_document_school_id_document_id_enrollment_id_idx ON public.training_document USING btree (school_id, document_id, enrollment_id);


--
-- Name: training_document_school_id_document_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX training_document_school_id_document_id_idx ON public.training_document USING btree (school_id, document_id);


--
-- Name: training_document_school_id_enrollment_id_kind_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX training_document_school_id_enrollment_id_kind_idx ON public.training_document USING btree (school_id, enrollment_id, kind);


--
-- Name: rendered_artifact dm_artifact_file_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dm_artifact_file_guard BEFORE INSERT ON public.rendered_artifact FOR EACH ROW EXECUTE FUNCTION public.dm_artifact_file_guard();


--
-- Name: rendered_artifact dm_artifact_immutable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dm_artifact_immutable BEFORE DELETE OR UPDATE ON public.rendered_artifact FOR EACH ROW EXECUTE FUNCTION public.dm_freeze_columns('');


--
-- Name: evidence_checkpoint dm_checkpoint_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dm_checkpoint_guard BEFORE DELETE OR UPDATE ON public.evidence_checkpoint FOR EACH ROW EXECUTE FUNCTION public.dm_checkpoint_guard();


--
-- Name: evidence_checkpoint dm_checkpoint_selection; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER dm_checkpoint_selection AFTER INSERT OR UPDATE ON public.evidence_checkpoint DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.dm_check_checkpoint_selection();


--
-- Name: training_contract dm_contract_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER dm_contract_audit AFTER INSERT OR UPDATE ON public.training_contract DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.dm_require_revision_event();


--
-- Name: training_contract dm_contract_final; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER dm_contract_final AFTER INSERT OR UPDATE ON public.training_contract DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.dm_check_contract();


--
-- Name: training_contract dm_contract_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dm_contract_guard BEFORE INSERT OR UPDATE ON public.training_contract FOR EACH ROW EXECUTE FUNCTION public.dm_contract_guard();


--
-- Name: training_contract dm_contract_payload; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dm_contract_payload BEFORE DELETE OR UPDATE ON public.training_contract FOR EACH ROW EXECUTE FUNCTION public.dm_freeze_columns('status,revision');


--
-- Name: training_contract dm_contract_revision; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dm_contract_revision BEFORE INSERT OR UPDATE ON public.training_contract FOR EACH ROW EXECUTE FUNCTION public.dm_revision_guard();


--
-- Name: training_document dm_document_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER dm_document_audit AFTER INSERT OR UPDATE ON public.training_document DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.dm_require_revision_event();


--
-- Name: training_document dm_document_payload; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dm_document_payload BEFORE DELETE OR UPDATE ON public.training_document FOR EACH ROW EXECUTE FUNCTION public.dm_freeze_columns('current_version_id,revision');


--
-- Name: training_document dm_document_revision; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dm_document_revision BEFORE INSERT OR UPDATE ON public.training_document FOR EACH ROW EXECUTE FUNCTION public.dm_revision_guard();


--
-- Name: state_event dm_event_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dm_event_guard BEFORE INSERT ON public.state_event FOR EACH ROW EXECUTE FUNCTION public.dm_event_guard();


--
-- Name: state_event dm_event_immutable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dm_event_immutable BEFORE DELETE OR UPDATE ON public.state_event FOR EACH ROW EXECUTE FUNCTION public.dm_freeze_columns('');


--
-- Name: file_object dm_file_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dm_file_guard BEFORE INSERT OR DELETE OR UPDATE ON public.file_object FOR EACH ROW EXECUTE FUNCTION public.dm_file_guard();


--
-- Name: download_grant dm_grant_immutable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dm_grant_immutable BEFORE DELETE OR UPDATE ON public.download_grant FOR EACH ROW EXECUTE FUNCTION public.dm_freeze_columns('');


--
-- Name: inbox_message dm_inbox_immutable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dm_inbox_immutable BEFORE DELETE OR UPDATE ON public.inbox_message FOR EACH ROW EXECUTE FUNCTION public.dm_freeze_columns('');


--
-- Name: operation_outcome dm_outcome_immutable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dm_outcome_immutable BEFORE DELETE OR UPDATE ON public.operation_outcome FOR EACH ROW EXECUTE FUNCTION public.dm_freeze_columns('');


--
-- Name: operation_receipt dm_receipt_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dm_receipt_guard BEFORE INSERT OR DELETE OR UPDATE ON public.operation_receipt FOR EACH ROW EXECUTE FUNCTION public.dm_receipt_guard();


--
-- Name: document_review dm_review_immutable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dm_review_immutable BEFORE DELETE OR UPDATE ON public.document_review FOR EACH ROW EXECUTE FUNCTION public.dm_freeze_columns('');


--
-- Name: document_version dm_selection_child_final; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER dm_selection_child_final AFTER INSERT OR UPDATE ON public.document_version DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.dm_check_selection();


--
-- Name: training_document dm_selection_final; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER dm_selection_final AFTER INSERT OR UPDATE ON public.training_document DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.dm_check_selection();


--
-- Name: contract_signed_copy dm_signed_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER dm_signed_audit AFTER INSERT ON public.contract_signed_copy DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.dm_require_copy_event();


--
-- Name: contract_signed_copy dm_signed_copy_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dm_signed_copy_guard BEFORE INSERT OR UPDATE ON public.contract_signed_copy FOR EACH ROW EXECUTE FUNCTION public.dm_signed_copy_guard();


--
-- Name: contract_signed_copy dm_signed_final; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER dm_signed_final AFTER INSERT OR UPDATE ON public.contract_signed_copy DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.dm_check_contract();


--
-- Name: contract_signed_copy dm_signed_payload; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dm_signed_payload BEFORE DELETE OR UPDATE ON public.contract_signed_copy FOR EACH ROW EXECUTE FUNCTION public.dm_freeze_columns('is_current');


--
-- Name: document_template dm_template_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER dm_template_audit AFTER INSERT OR UPDATE ON public.document_template DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.dm_require_revision_event();


--
-- Name: template_version dm_template_child_final; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER dm_template_child_final AFTER INSERT OR UPDATE ON public.template_version DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.dm_check_template();


--
-- Name: document_template dm_template_final; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER dm_template_final AFTER INSERT OR UPDATE ON public.document_template DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.dm_check_template();


--
-- Name: document_template dm_template_payload; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dm_template_payload BEFORE DELETE OR UPDATE ON public.document_template FOR EACH ROW EXECUTE FUNCTION public.dm_freeze_columns('name,active_version_id,revision');


--
-- Name: document_template dm_template_revision; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dm_template_revision BEFORE INSERT OR UPDATE ON public.document_template FOR EACH ROW EXECUTE FUNCTION public.dm_revision_guard();


--
-- Name: template_version dm_template_version_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dm_template_version_guard BEFORE INSERT OR UPDATE ON public.template_version FOR EACH ROW EXECUTE FUNCTION public.dm_template_version_guard();


--
-- Name: template_version dm_template_version_payload; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dm_template_version_payload BEFORE DELETE OR UPDATE ON public.template_version FOR EACH ROW EXECUTE FUNCTION public.dm_freeze_columns('status');


--
-- Name: document_version dm_version_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER dm_version_audit AFTER INSERT OR UPDATE ON public.document_version DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.dm_require_revision_event();


--
-- Name: document_version dm_version_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dm_version_guard BEFORE INSERT OR UPDATE ON public.document_version FOR EACH ROW EXECUTE FUNCTION public.dm_version_guard();


--
-- Name: document_version dm_version_payload; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dm_version_payload BEFORE DELETE OR UPDATE ON public.document_version FOR EACH ROW EXECUTE FUNCTION public.dm_freeze_columns('state,revision');


--
-- Name: document_version dm_version_revision; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dm_version_revision BEFORE INSERT OR UPDATE ON public.document_version FOR EACH ROW EXECUTE FUNCTION public.dm_revision_guard();


--
-- Name: contract_signed_copy contract_signed_copy_school_id_contract_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contract_signed_copy
    ADD CONSTRAINT contract_signed_copy_school_id_contract_id_fkey FOREIGN KEY (school_id, contract_id) REFERENCES public.training_contract(school_id, contract_id) DEFERRABLE;


--
-- Name: contract_signed_copy contract_signed_copy_school_id_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contract_signed_copy
    ADD CONSTRAINT contract_signed_copy_school_id_file_id_fkey FOREIGN KEY (school_id, file_id) REFERENCES public.file_object(school_id, file_id) DEFERRABLE;


--
-- Name: download_grant dm_download_signed_copy; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.download_grant
    ADD CONSTRAINT dm_download_signed_copy FOREIGN KEY (school_id, signed_copy_id) REFERENCES public.contract_signed_copy(school_id, signed_copy_id);


--
-- Name: download_grant dm_download_version; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.download_grant
    ADD CONSTRAINT dm_download_version FOREIGN KEY (school_id, version_id) REFERENCES public.document_version(school_id, document_version_id);


--
-- Name: document_job dm_job_result_version; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_job
    ADD CONSTRAINT dm_job_result_version FOREIGN KEY (school_id, result_version_id) REFERENCES public.document_version(school_id, document_version_id);


--
-- Name: document_job document_job_school_id_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_job
    ADD CONSTRAINT document_job_school_id_id_fkey FOREIGN KEY (school_id, id) REFERENCES public.operation_receipt(school_id, command_id);


--
-- Name: document_job document_job_school_id_template_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_job
    ADD CONSTRAINT document_job_school_id_template_version_id_fkey FOREIGN KEY (school_id, template_version_id) REFERENCES public.template_version(school_id, template_version_id);


--
-- Name: document_review document_review_school_id_document_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_review
    ADD CONSTRAINT document_review_school_id_document_version_id_fkey FOREIGN KEY (school_id, document_version_id) REFERENCES public.document_version(school_id, document_version_id);


--
-- Name: document_template document_template_school_id_template_id_active_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_template
    ADD CONSTRAINT document_template_school_id_template_id_active_version_id_fkey FOREIGN KEY (school_id, template_id, active_version_id) REFERENCES public.template_version(school_id, template_id, template_version_id) DEFERRABLE;


--
-- Name: document_version document_version_school_id_basis_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_version
    ADD CONSTRAINT document_version_school_id_basis_file_id_fkey FOREIGN KEY (school_id, basis_file_id) REFERENCES public.file_object(school_id, file_id) DEFERRABLE;


--
-- Name: document_version document_version_school_id_document_id_enrollment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_version
    ADD CONSTRAINT document_version_school_id_document_id_enrollment_id_fkey FOREIGN KEY (school_id, document_id, enrollment_id) REFERENCES public.training_document(school_id, document_id, enrollment_id) DEFERRABLE;


--
-- Name: document_version document_version_school_id_rendered_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_version
    ADD CONSTRAINT document_version_school_id_rendered_file_id_fkey FOREIGN KEY (school_id, rendered_file_id) REFERENCES public.file_object(school_id, file_id) DEFERRABLE;


--
-- Name: document_version document_version_school_id_template_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_version
    ADD CONSTRAINT document_version_school_id_template_version_id_fkey FOREIGN KEY (school_id, template_version_id) REFERENCES public.template_version(school_id, template_version_id) DEFERRABLE;


--
-- Name: download_grant download_grant_school_id_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.download_grant
    ADD CONSTRAINT download_grant_school_id_file_id_fkey FOREIGN KEY (school_id, file_id) REFERENCES public.file_object(school_id, file_id);


--
-- Name: operation_outcome operation_outcome_school_id_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operation_outcome
    ADD CONSTRAINT operation_outcome_school_id_id_fkey FOREIGN KEY (school_id, id) REFERENCES public.operation_receipt(school_id, command_id);


--
-- Name: operation_receipt operation_receipt_school_id_contract_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operation_receipt
    ADD CONSTRAINT operation_receipt_school_id_contract_id_fkey FOREIGN KEY (school_id, contract_id) REFERENCES public.training_contract(school_id, contract_id) DEFERRABLE;


--
-- Name: operation_receipt operation_receipt_school_id_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operation_receipt
    ADD CONSTRAINT operation_receipt_school_id_document_id_fkey FOREIGN KEY (school_id, document_id) REFERENCES public.training_document(school_id, document_id) DEFERRABLE;


--
-- Name: operation_receipt operation_receipt_school_id_document_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operation_receipt
    ADD CONSTRAINT operation_receipt_school_id_document_version_id_fkey FOREIGN KEY (school_id, document_version_id) REFERENCES public.document_version(school_id, document_version_id) DEFERRABLE;


--
-- Name: operation_receipt operation_receipt_school_id_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operation_receipt
    ADD CONSTRAINT operation_receipt_school_id_template_id_fkey FOREIGN KEY (school_id, template_id) REFERENCES public.document_template(school_id, template_id) DEFERRABLE;


--
-- Name: operation_receipt operation_receipt_school_id_template_id_template_version_i_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operation_receipt
    ADD CONSTRAINT operation_receipt_school_id_template_id_template_version_i_fkey FOREIGN KEY (school_id, template_id, template_version_id) REFERENCES public.template_version(school_id, template_id, template_version_id) DEFERRABLE;


--
-- Name: publication_decision publication_decision_school_id_document_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publication_decision
    ADD CONSTRAINT publication_decision_school_id_document_version_id_fkey FOREIGN KEY (school_id, document_version_id) REFERENCES public.document_version(school_id, document_version_id);


--
-- Name: publication_decision publication_decision_school_id_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publication_decision
    ADD CONSTRAINT publication_decision_school_id_id_fkey FOREIGN KEY (school_id, id) REFERENCES public.operation_receipt(school_id, command_id);


--
-- Name: rendered_artifact rendered_artifact_school_id_contract_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rendered_artifact
    ADD CONSTRAINT rendered_artifact_school_id_contract_id_fkey FOREIGN KEY (school_id, contract_id) REFERENCES public.training_contract(school_id, contract_id);


--
-- Name: rendered_artifact rendered_artifact_school_id_document_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rendered_artifact
    ADD CONSTRAINT rendered_artifact_school_id_document_version_id_fkey FOREIGN KEY (school_id, document_version_id) REFERENCES public.document_version(school_id, document_version_id);


--
-- Name: rendered_artifact rendered_artifact_school_id_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rendered_artifact
    ADD CONSTRAINT rendered_artifact_school_id_file_id_fkey FOREIGN KEY (school_id, file_id) REFERENCES public.file_object(school_id, file_id);


--
-- Name: state_event state_event_school_id_command_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.state_event
    ADD CONSTRAINT state_event_school_id_command_id_fkey FOREIGN KEY (school_id, command_id) REFERENCES public.operation_receipt(school_id, command_id) DEFERRABLE;


--
-- Name: state_event state_event_school_id_contract_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.state_event
    ADD CONSTRAINT state_event_school_id_contract_id_fkey FOREIGN KEY (school_id, contract_id) REFERENCES public.training_contract(school_id, contract_id) DEFERRABLE;


--
-- Name: state_event state_event_school_id_contract_id_signed_copy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.state_event
    ADD CONSTRAINT state_event_school_id_contract_id_signed_copy_id_fkey FOREIGN KEY (school_id, contract_id, signed_copy_id) REFERENCES public.contract_signed_copy(school_id, contract_id, signed_copy_id) DEFERRABLE;


--
-- Name: state_event state_event_school_id_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.state_event
    ADD CONSTRAINT state_event_school_id_document_id_fkey FOREIGN KEY (school_id, document_id) REFERENCES public.training_document(school_id, document_id) DEFERRABLE;


--
-- Name: state_event state_event_school_id_document_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.state_event
    ADD CONSTRAINT state_event_school_id_document_version_id_fkey FOREIGN KEY (school_id, document_version_id) REFERENCES public.document_version(school_id, document_version_id) DEFERRABLE;


--
-- Name: state_event state_event_school_id_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.state_event
    ADD CONSTRAINT state_event_school_id_template_id_fkey FOREIGN KEY (school_id, template_id) REFERENCES public.document_template(school_id, template_id) DEFERRABLE;


--
-- Name: state_event state_event_school_id_template_id_template_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.state_event
    ADD CONSTRAINT state_event_school_id_template_id_template_version_id_fkey FOREIGN KEY (school_id, template_id, template_version_id) REFERENCES public.template_version(school_id, template_id, template_version_id) DEFERRABLE;


--
-- Name: template_version template_version_school_id_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_version
    ADD CONSTRAINT template_version_school_id_file_id_fkey FOREIGN KEY (school_id, file_id) REFERENCES public.file_object(school_id, file_id) DEFERRABLE;


--
-- Name: template_version template_version_school_id_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_version
    ADD CONSTRAINT template_version_school_id_template_id_fkey FOREIGN KEY (school_id, template_id) REFERENCES public.document_template(school_id, template_id) DEFERRABLE;


--
-- Name: training_contract training_contract_school_id_basis_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_contract
    ADD CONSTRAINT training_contract_school_id_basis_file_id_fkey FOREIGN KEY (school_id, basis_file_id) REFERENCES public.file_object(school_id, file_id) DEFERRABLE;


--
-- Name: training_contract training_contract_school_id_enrollment_id_replaces_contrac_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_contract
    ADD CONSTRAINT training_contract_school_id_enrollment_id_replaces_contrac_fkey FOREIGN KEY (school_id, enrollment_id, replaces_contract_id) REFERENCES public.training_contract(school_id, enrollment_id, contract_id) DEFERRABLE;


--
-- Name: training_contract training_contract_school_id_generated_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_contract
    ADD CONSTRAINT training_contract_school_id_generated_file_id_fkey FOREIGN KEY (school_id, generated_file_id) REFERENCES public.file_object(school_id, file_id) DEFERRABLE;


--
-- Name: training_contract training_contract_school_id_template_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_contract
    ADD CONSTRAINT training_contract_school_id_template_version_id_fkey FOREIGN KEY (school_id, template_version_id) REFERENCES public.template_version(school_id, template_version_id) DEFERRABLE;


--
-- Name: training_document training_document_school_id_document_id_current_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_document
    ADD CONSTRAINT training_document_school_id_document_id_current_version_id_fkey FOREIGN KEY (school_id, document_id, current_version_id) REFERENCES public.document_version(school_id, document_id, document_version_id) DEFERRABLE;


--
-- Name: contract_signed_copy; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.contract_signed_copy ENABLE ROW LEVEL SECURITY;

--
-- Name: document_job; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.document_job ENABLE ROW LEVEL SECURITY;

--
-- Name: document_review; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.document_review ENABLE ROW LEVEL SECURITY;

--
-- Name: document_template; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.document_template ENABLE ROW LEVEL SECURITY;

--
-- Name: document_version; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.document_version ENABLE ROW LEVEL SECURITY;

--
-- Name: download_grant; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.download_grant ENABLE ROW LEVEL SECURITY;

--
-- Name: evidence_checkpoint; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.evidence_checkpoint ENABLE ROW LEVEL SECURITY;

--
-- Name: file_object; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.file_object ENABLE ROW LEVEL SECURITY;

--
-- Name: inbox_message; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.inbox_message ENABLE ROW LEVEL SECURITY;

--
-- Name: operation_outcome; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.operation_outcome ENABLE ROW LEVEL SECURITY;

--
-- Name: operation_receipt; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.operation_receipt ENABLE ROW LEVEL SECURITY;

--
-- Name: publication_decision; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.publication_decision ENABLE ROW LEVEL SECURITY;

--
-- Name: rendered_artifact; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.rendered_artifact ENABLE ROW LEVEL SECURITY;

--
-- Name: state_event; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.state_event ENABLE ROW LEVEL SECURITY;

--
-- Name: template_version; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.template_version ENABLE ROW LEVEL SECURITY;

--
-- Name: contract_signed_copy tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.contract_signed_copy TO v_document_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: document_job tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.document_job TO v_document_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: document_review tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.document_review TO v_document_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: document_template tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.document_template TO v_document_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: document_version tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.document_version TO v_document_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: download_grant tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.download_grant TO v_document_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: evidence_checkpoint tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.evidence_checkpoint TO v_document_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: file_object tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.file_object TO v_document_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: inbox_message tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.inbox_message TO v_document_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: operation_outcome tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.operation_outcome TO v_document_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: operation_receipt tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.operation_receipt TO v_document_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: publication_decision tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.publication_decision TO v_document_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: rendered_artifact tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.rendered_artifact TO v_document_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: state_event tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.state_event TO v_document_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: template_version tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.template_version TO v_document_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: training_contract tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.training_contract TO v_document_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: training_document tenant_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_scope ON public.training_document TO v_document_management_runtime USING ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('vairas.school_id'::text, true), ''::text))::uuid));


--
-- Name: training_contract; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.training_contract ENABLE ROW LEVEL SECURITY;

--
-- Name: training_document; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.training_document ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--

\unrestrict Sq8h7ik8oLulVEUH4INDmwjzQITABOYLBLcQCxLg2y6SBQRV6K0t9rHDtdwjsbJ

