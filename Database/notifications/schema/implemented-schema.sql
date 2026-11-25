--
-- PostgreSQL database dump
--

\restrict jKfIKb14JFeY0G8UeDUeEgg0PEG3daqzTyXwh8FHWbvS3SiPda3aAeAVbLwUHf3

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
-- Name: notifications; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA notifications;


--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: notification_guard(); Type: FUNCTION; Schema: notifications; Owner: -
--

CREATE FUNCTION notifications.notification_guard() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    RAISE EXCEPTION 'Public deletion is not supported; retention cleanup requires a separate reviewed mechanism';
  END IF;
  IF TG_TABLE_NAME IN ('notification_inbox','notification_operation') THEN
    RAISE EXCEPTION 'Receipt is immutable';
  ELSIF TG_TABLE_NAME = 'notification_template' THEN
    IF (NEW.school_id, NEW.template_id, NEW.created_at) IS DISTINCT FROM
       (OLD.school_id, OLD.template_id, OLD.created_at)
       OR NEW.revision <> OLD.revision + 1 OR NEW.updated_at < OLD.updated_at THEN
      RAISE EXCEPTION 'Invalid template identity/revision';
    END IF;
  ELSIF TG_TABLE_NAME = 'notification' THEN
    IF (to_jsonb(NEW) - ARRAY['status','revision','attempt_count','next_attempt_at','sent_at','cancelled_at','failure_code','updated_at'])
       IS DISTINCT FROM
       (to_jsonb(OLD) - ARRAY['status','revision','attempt_count','next_attempt_at','sent_at','cancelled_at','failure_code','updated_at'])
       OR NEW.revision <> OLD.revision + 1 OR NEW.updated_at < OLD.updated_at
       OR OLD.status IN ('Sent','Cancelled','Failed') THEN
      RAISE EXCEPTION 'Invalid notification snapshot/revision or terminal mutation';
    END IF;
    IF NOT ((OLD.status = 'Pending' AND NEW.status IN ('Sending','Cancelled','Failed'))
         OR (OLD.status = 'Sending' AND NEW.status IN ('Sent','Pending','Failed','DeliveryUnknown'))
         OR (OLD.status = 'DeliveryUnknown' AND NEW.status IN ('Sent','Pending','Failed'))) THEN
      RAISE EXCEPTION 'Invalid notification transition';
    END IF;
  ELSIF TG_TABLE_NAME = 'notification_delivery_attempt' THEN
    IF (to_jsonb(NEW) - ARRAY['status','finished_at','error_code','provider_message_id'])
       IS DISTINCT FROM
       (to_jsonb(OLD) - ARRAY['status','finished_at','error_code','provider_message_id'])
       OR NOT ((OLD.status = 'Started' AND NEW.status IN ('Accepted','Rejected','Unknown'))
           OR (OLD.status = 'Unknown' AND NEW.status IN ('Accepted','Rejected'))) THEN
      RAISE EXCEPTION 'Invalid attempt mutation';
    END IF;
  END IF;
  RETURN NEW;
END $$;


--
-- Name: notification_queue(); Type: FUNCTION; Schema: notifications; Owner: -
--

CREATE FUNCTION notifications.notification_queue() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'notifications', 'pg_catalog'
    AS $$
BEGIN
  IF NEW.status IN ('Pending','Sending','DeliveryUnknown') THEN
    INSERT INTO notification_work(school_id,notification_id,status,available_at,created_at)
    VALUES(NEW.school_id,NEW.notification_id,NEW.status,
      CASE WHEN NEW.status='Pending' THEN greatest(NEW.scheduled_at,coalesce(NEW.next_attempt_at,NEW.scheduled_at))
           WHEN NEW.status='Sending' THEN NEW.updated_at+interval '120 seconds'
           ELSE clock_timestamp()+interval '30 seconds' END,NEW.created_at)
    ON CONFLICT(school_id,notification_id) DO UPDATE SET status=excluded.status,available_at=excluded.available_at;
  ELSE
    DELETE FROM notification_work WHERE school_id=NEW.school_id AND notification_id=NEW.notification_id;
  END IF;
  RETURN NEW;
END $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: notification; Type: TABLE; Schema: notifications; Owner: -
--

CREATE TABLE notifications.notification (
    school_id uuid NOT NULL,
    notification_id uuid NOT NULL,
    recipient_user_id uuid NOT NULL,
    template_id uuid,
    template_revision bigint,
    notification_type character varying(40) NOT NULL,
    channel character varying(12) DEFAULT 'Email'::character varying NOT NULL,
    subject character varying(500) NOT NULL,
    body text NOT NULL,
    destination_address character varying(254) NOT NULL,
    contact_revision character varying(100) NOT NULL,
    source_context character varying(40) NOT NULL,
    source_id uuid NOT NULL,
    source_revision bigint NOT NULL,
    source_event_id uuid NOT NULL,
    dispatch_key character varying(200) NOT NULL,
    scheduled_at timestamp with time zone NOT NULL,
    status character varying(20) DEFAULT 'Pending'::character varying NOT NULL,
    revision bigint DEFAULT 1 NOT NULL,
    attempt_count integer DEFAULT 0 NOT NULL,
    next_attempt_at timestamp with time zone,
    sent_at timestamp with time zone,
    cancelled_at timestamp with time zone,
    failure_code character varying(80),
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    correlation_id character varying(128) DEFAULT 'legacy'::character varying NOT NULL,
    content_purged_at timestamp with time zone,
    CONSTRAINT n_attempt_required CHECK ((((status)::text <> ALL ((ARRAY['Sending'::character varying, 'Sent'::character varying, 'DeliveryUnknown'::character varying])::text[])) OR (attempt_count > 0))),
    CONSTRAINT n_cancel_pair CHECK ((((status)::text = 'Cancelled'::text) = (cancelled_at IS NOT NULL))),
    CONSTRAINT n_cancel_time CHECK (((cancelled_at IS NULL) OR (cancelled_at >= created_at))),
    CONSTRAINT n_channel CHECK (((channel)::text = 'Email'::text)),
    CONSTRAINT n_content CHECK (((length(TRIM(BOTH FROM subject)) > 0) AND (length(TRIM(BOTH FROM body)) > 0) AND (length(TRIM(BOTH FROM destination_address)) > 0) AND (length(TRIM(BOTH FROM contact_revision)) > 0) AND (length(TRIM(BOTH FROM dispatch_key)) > 0))),
    CONSTRAINT n_retry_time CHECK (((next_attempt_at IS NULL) OR (((status)::text = 'Pending'::text) AND (next_attempt_at >= created_at)))),
    CONSTRAINT n_revisions CHECK (((revision > 0) AND (source_revision > 0) AND (attempt_count >= 0))),
    CONSTRAINT n_sent_pair CHECK ((((status)::text = 'Sent'::text) = (sent_at IS NOT NULL))),
    CONSTRAINT n_sent_time CHECK (((sent_at IS NULL) OR (sent_at >= created_at))),
    CONSTRAINT n_source CHECK (((source_context)::text = ANY ((ARRAY['Scheduling'::character varying, 'LearningTracking'::character varying])::text[]))),
    CONSTRAINT n_status CHECK (((status)::text = ANY ((ARRAY['Pending'::character varying, 'Sending'::character varying, 'Sent'::character varying, 'Failed'::character varying, 'Cancelled'::character varying, 'DeliveryUnknown'::character varying])::text[]))),
    CONSTRAINT n_template_pair CHECK ((((template_id IS NULL) AND (template_revision IS NULL)) OR ((template_id IS NOT NULL) AND (template_revision IS NOT NULL) AND (template_revision > 0)))),
    CONSTRAINT n_time CHECK (((updated_at >= created_at) AND (scheduled_at >= created_at))),
    CONSTRAINT n_type CHECK (((notification_type)::text = ANY ((ARRAY['LessonScheduled'::character varying, 'LessonRescheduled'::character varying, 'LessonCancelled'::character varying, 'LessonReminder'::character varying, 'AssessmentPassed'::character varying, 'AssessmentFailed'::character varying])::text[])))
);

ALTER TABLE ONLY notifications.notification FORCE ROW LEVEL SECURITY;


--
-- Name: notification_delivery_attempt; Type: TABLE; Schema: notifications; Owner: -
--

CREATE TABLE notifications.notification_delivery_attempt (
    school_id uuid NOT NULL,
    attempt_id uuid NOT NULL,
    notification_id uuid NOT NULL,
    attempt_no integer NOT NULL,
    provider_key character varying(200) NOT NULL,
    provider_message_id character varying(200),
    status character varying(12) DEFAULT 'Started'::character varying NOT NULL,
    started_at timestamp with time zone NOT NULL,
    finished_at timestamp with time zone,
    error_code character varying(80),
    CONSTRAINT nda_finished CHECK ((((status)::text = 'Started'::text) = (finished_at IS NULL))),
    CONSTRAINT nda_identity CHECK (((attempt_no > 0) AND (length(TRIM(BOTH FROM provider_key)) > 0))),
    CONSTRAINT nda_status CHECK (((status)::text = ANY ((ARRAY['Started'::character varying, 'Accepted'::character varying, 'Rejected'::character varying, 'Unknown'::character varying])::text[]))),
    CONSTRAINT nda_time CHECK (((finished_at IS NULL) OR (finished_at >= started_at)))
);

ALTER TABLE ONLY notifications.notification_delivery_attempt FORCE ROW LEVEL SECURITY;


--
-- Name: notification_inbox; Type: TABLE; Schema: notifications; Owner: -
--

CREATE TABLE notifications.notification_inbox (
    school_id uuid NOT NULL,
    producer character varying(40) NOT NULL,
    event_id uuid NOT NULL,
    payload_hash character varying(64) NOT NULL,
    source_id uuid NOT NULL,
    source_revision bigint NOT NULL,
    outcome character varying(12) NOT NULL,
    outcome_code character varying(80) NOT NULL,
    received_at timestamp with time zone NOT NULL,
    processed_at timestamp with time zone NOT NULL,
    CONSTRAINT ni_hash CHECK (((payload_hash)::text ~ '^[0-9a-f]{64}$'::text)),
    CONSTRAINT ni_outcome CHECK ((((outcome)::text = ANY ((ARRAY['Applied'::character varying, 'Ignored'::character varying, 'Rejected'::character varying])::text[])) AND (length(TRIM(BOTH FROM outcome_code)) > 0))),
    CONSTRAINT ni_source CHECK ((((producer)::text = ANY ((ARRAY['Scheduling'::character varying, 'LearningTracking'::character varying])::text[])) AND (source_revision > 0))),
    CONSTRAINT ni_time CHECK ((processed_at >= received_at))
);

ALTER TABLE ONLY notifications.notification_inbox FORCE ROW LEVEL SECURITY;


--
-- Name: notification_operation; Type: TABLE; Schema: notifications; Owner: -
--

CREATE TABLE notifications.notification_operation (
    school_id uuid NOT NULL,
    operation_id uuid NOT NULL,
    actor_user_id uuid NOT NULL,
    channel character varying(12) NOT NULL,
    command_name character varying(80) NOT NULL,
    target_id uuid NOT NULL,
    request_hash character varying(64) NOT NULL,
    authority_basis text NOT NULL,
    confirmation_id uuid,
    confirmed_at timestamp with time zone,
    outcome character varying(12) NOT NULL,
    outcome_code character varying(80) NOT NULL,
    resulting_revision bigint,
    recorded_at timestamp with time zone NOT NULL,
    response_json jsonb,
    CONSTRAINT no_basis CHECK ((((request_hash)::text ~ '^[0-9a-f]{64}$'::text) AND (length(TRIM(BOTH FROM command_name)) > 0) AND (length(TRIM(BOTH FROM authority_basis)) > 0) AND (length(TRIM(BOTH FROM outcome_code)) > 0))),
    CONSTRAINT no_confirmation_pair CHECK (((confirmation_id IS NULL) = (confirmed_at IS NULL))),
    CONSTRAINT no_mcp_confirmation CHECK ((((channel)::text <> 'MCP'::text) OR ((outcome)::text <> 'Applied'::text) OR (confirmation_id IS NOT NULL))),
    CONSTRAINT no_response CHECK ((((outcome)::text <> 'Applied'::text) OR (response_json IS NOT NULL))),
    CONSTRAINT no_revision CHECK (((resulting_revision IS NULL) OR (resulting_revision > 0))),
    CONSTRAINT no_values CHECK ((((channel)::text = ANY ((ARRAY['Web'::character varying, 'MCP'::character varying])::text[])) AND ((outcome)::text = ANY ((ARRAY['Applied'::character varying, 'Rejected'::character varying])::text[]))))
);

ALTER TABLE ONLY notifications.notification_operation FORCE ROW LEVEL SECURITY;


--
-- Name: notification_retention_run; Type: TABLE; Schema: notifications; Owner: -
--

CREATE TABLE notifications.notification_retention_run (
    run_id uuid NOT NULL,
    cutoff timestamp with time zone NOT NULL,
    affected integer NOT NULL,
    executed_at timestamp with time zone NOT NULL,
    executed_by text NOT NULL,
    reason character varying(500) NOT NULL,
    CONSTRAINT notification_retention_run_affected_check CHECK ((affected >= 0)),
    CONSTRAINT notification_retention_run_reason_check CHECK ((length(TRIM(BOTH FROM reason)) > 0))
);


--
-- Name: notification_template; Type: TABLE; Schema: notifications; Owner: -
--

CREATE TABLE notifications.notification_template (
    school_id uuid NOT NULL,
    template_id uuid NOT NULL,
    notification_type character varying(40) NOT NULL,
    subject_template character varying(500) NOT NULL,
    body_template text NOT NULL,
    status character varying(12) DEFAULT 'Active'::character varying NOT NULL,
    revision bigint DEFAULT 1 NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT nt_content CHECK (((length(TRIM(BOTH FROM subject_template)) > 0) AND (length(TRIM(BOTH FROM body_template)) > 0))),
    CONSTRAINT nt_revision_time CHECK (((revision > 0) AND (updated_at >= created_at))),
    CONSTRAINT nt_status CHECK (((status)::text = ANY ((ARRAY['Active'::character varying, 'Archived'::character varying])::text[]))),
    CONSTRAINT nt_type CHECK (((notification_type)::text = ANY ((ARRAY['LessonScheduled'::character varying, 'LessonRescheduled'::character varying, 'LessonCancelled'::character varying, 'LessonReminder'::character varying, 'AssessmentPassed'::character varying, 'AssessmentFailed'::character varying])::text[])))
);

ALTER TABLE ONLY notifications.notification_template FORCE ROW LEVEL SECURITY;


--
-- Name: notification_work; Type: TABLE; Schema: notifications; Owner: -
--

CREATE TABLE notifications.notification_work (
    school_id uuid NOT NULL,
    notification_id uuid NOT NULL,
    status character varying(20) NOT NULL,
    available_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone NOT NULL
);


--
-- Name: schema_history; Type: TABLE; Schema: notifications; Owner: -
--

CREATE TABLE notifications.schema_history (
    version text NOT NULL,
    checksum text NOT NULL,
    applied_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: notification_delivery_attempt notification_delivery_attempt_pkey; Type: CONSTRAINT; Schema: notifications; Owner: -
--

ALTER TABLE ONLY notifications.notification_delivery_attempt
    ADD CONSTRAINT notification_delivery_attempt_pkey PRIMARY KEY (school_id, attempt_id);


--
-- Name: notification_inbox notification_inbox_pkey; Type: CONSTRAINT; Schema: notifications; Owner: -
--

ALTER TABLE ONLY notifications.notification_inbox
    ADD CONSTRAINT notification_inbox_pkey PRIMARY KEY (school_id, producer, event_id);


--
-- Name: notification_operation notification_operation_pkey; Type: CONSTRAINT; Schema: notifications; Owner: -
--

ALTER TABLE ONLY notifications.notification_operation
    ADD CONSTRAINT notification_operation_pkey PRIMARY KEY (school_id, operation_id);


--
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: notifications; Owner: -
--

ALTER TABLE ONLY notifications.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (school_id, notification_id);


--
-- Name: notification_retention_run notification_retention_run_pkey; Type: CONSTRAINT; Schema: notifications; Owner: -
--

ALTER TABLE ONLY notifications.notification_retention_run
    ADD CONSTRAINT notification_retention_run_pkey PRIMARY KEY (run_id);


--
-- Name: notification_template notification_template_pkey; Type: CONSTRAINT; Schema: notifications; Owner: -
--

ALTER TABLE ONLY notifications.notification_template
    ADD CONSTRAINT notification_template_pkey PRIMARY KEY (school_id, template_id);


--
-- Name: notification_work notification_work_pkey; Type: CONSTRAINT; Schema: notifications; Owner: -
--

ALTER TABLE ONLY notifications.notification_work
    ADD CONSTRAINT notification_work_pkey PRIMARY KEY (school_id, notification_id);


--
-- Name: schema_history schema_history_pkey; Type: CONSTRAINT; Schema: notifications; Owner: -
--

ALTER TABLE ONLY notifications.schema_history
    ADD CONSTRAINT schema_history_pkey PRIMARY KEY (version);


--
-- Name: nda_one_unresolved; Type: INDEX; Schema: notifications; Owner: -
--

CREATE UNIQUE INDEX nda_one_unresolved ON notifications.notification_delivery_attempt USING btree (school_id, notification_id) WHERE ((status)::text = ANY ((ARRAY['Started'::character varying, 'Unknown'::character varying])::text[]));


--
-- Name: notification_delivery_attempt_school_id_notification_id_att_idx; Type: INDEX; Schema: notifications; Owner: -
--

CREATE UNIQUE INDEX notification_delivery_attempt_school_id_notification_id_att_idx ON notifications.notification_delivery_attempt USING btree (school_id, notification_id, attempt_no);


--
-- Name: notification_delivery_attempt_school_id_provider_key_idx; Type: INDEX; Schema: notifications; Owner: -
--

CREATE UNIQUE INDEX notification_delivery_attempt_school_id_provider_key_idx ON notifications.notification_delivery_attempt USING btree (school_id, provider_key);


--
-- Name: notification_school_id_recipient_user_id_channel_dispatch_k_idx; Type: INDEX; Schema: notifications; Owner: -
--

CREATE UNIQUE INDEX notification_school_id_recipient_user_id_channel_dispatch_k_idx ON notifications.notification USING btree (school_id, recipient_user_id, channel, dispatch_key);


--
-- Name: notification_school_id_recipient_user_id_created_at_idx; Type: INDEX; Schema: notifications; Owner: -
--

CREATE INDEX notification_school_id_recipient_user_id_created_at_idx ON notifications.notification USING btree (school_id, recipient_user_id, created_at);


--
-- Name: notification_school_id_source_context_source_id_source_revi_idx; Type: INDEX; Schema: notifications; Owner: -
--

CREATE INDEX notification_school_id_source_context_source_id_source_revi_idx ON notifications.notification USING btree (school_id, source_context, source_id, source_revision);


--
-- Name: notification_status_next_attempt_at_scheduled_at_idx; Type: INDEX; Schema: notifications; Owner: -
--

CREATE INDEX notification_status_next_attempt_at_scheduled_at_idx ON notifications.notification USING btree (status, next_attempt_at, scheduled_at);


--
-- Name: nt_one_active; Type: INDEX; Schema: notifications; Owner: -
--

CREATE UNIQUE INDEX nt_one_active ON notifications.notification_template USING btree (school_id, notification_type) WHERE ((status)::text = 'Active'::text);


--
-- Name: nw_due; Type: INDEX; Schema: notifications; Owner: -
--

CREATE INDEX nw_due ON notifications.notification_work USING btree (available_at, school_id, notification_id);


--
-- Name: notification n_guard; Type: TRIGGER; Schema: notifications; Owner: -
--

CREATE TRIGGER n_guard BEFORE DELETE OR UPDATE ON notifications.notification FOR EACH ROW EXECUTE FUNCTION notifications.notification_guard();


--
-- Name: notification n_queue; Type: TRIGGER; Schema: notifications; Owner: -
--

CREATE TRIGGER n_queue AFTER INSERT OR UPDATE ON notifications.notification FOR EACH ROW EXECUTE FUNCTION notifications.notification_queue();


--
-- Name: notification_delivery_attempt nda_guard; Type: TRIGGER; Schema: notifications; Owner: -
--

CREATE TRIGGER nda_guard BEFORE DELETE OR UPDATE ON notifications.notification_delivery_attempt FOR EACH ROW EXECUTE FUNCTION notifications.notification_guard();


--
-- Name: notification_inbox ni_guard; Type: TRIGGER; Schema: notifications; Owner: -
--

CREATE TRIGGER ni_guard BEFORE DELETE OR UPDATE ON notifications.notification_inbox FOR EACH ROW EXECUTE FUNCTION notifications.notification_guard();


--
-- Name: notification_operation no_guard; Type: TRIGGER; Schema: notifications; Owner: -
--

CREATE TRIGGER no_guard BEFORE DELETE OR UPDATE ON notifications.notification_operation FOR EACH ROW EXECUTE FUNCTION notifications.notification_guard();


--
-- Name: notification_template nt_guard; Type: TRIGGER; Schema: notifications; Owner: -
--

CREATE TRIGGER nt_guard BEFORE DELETE OR UPDATE ON notifications.notification_template FOR EACH ROW EXECUTE FUNCTION notifications.notification_guard();


--
-- Name: notification_delivery_attempt notification_delivery_attempt_school_id_notification_id_fkey; Type: FK CONSTRAINT; Schema: notifications; Owner: -
--

ALTER TABLE ONLY notifications.notification_delivery_attempt
    ADD CONSTRAINT notification_delivery_attempt_school_id_notification_id_fkey FOREIGN KEY (school_id, notification_id) REFERENCES notifications.notification(school_id, notification_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: notification notification_school_id_template_id_fkey; Type: FK CONSTRAINT; Schema: notifications; Owner: -
--

ALTER TABLE ONLY notifications.notification
    ADD CONSTRAINT notification_school_id_template_id_fkey FOREIGN KEY (school_id, template_id) REFERENCES notifications.notification_template(school_id, template_id) ON DELETE RESTRICT DEFERRABLE;


--
-- Name: notification_work notification_work_school_id_notification_id_fkey; Type: FK CONSTRAINT; Schema: notifications; Owner: -
--

ALTER TABLE ONLY notifications.notification_work
    ADD CONSTRAINT notification_work_school_id_notification_id_fkey FOREIGN KEY (school_id, notification_id) REFERENCES notifications.notification(school_id, notification_id) ON DELETE CASCADE;


--
-- Name: notification; Type: ROW SECURITY; Schema: notifications; Owner: -
--

ALTER TABLE notifications.notification ENABLE ROW LEVEL SECURITY;

--
-- Name: notification_delivery_attempt; Type: ROW SECURITY; Schema: notifications; Owner: -
--

ALTER TABLE notifications.notification_delivery_attempt ENABLE ROW LEVEL SECURITY;

--
-- Name: notification_inbox; Type: ROW SECURITY; Schema: notifications; Owner: -
--

ALTER TABLE notifications.notification_inbox ENABLE ROW LEVEL SECURITY;

--
-- Name: notification_operation; Type: ROW SECURITY; Schema: notifications; Owner: -
--

ALTER TABLE notifications.notification_operation ENABLE ROW LEVEL SECURITY;

--
-- Name: notification_template; Type: ROW SECURITY; Schema: notifications; Owner: -
--

ALTER TABLE notifications.notification_template ENABLE ROW LEVEL SECURITY;

--
-- Name: notification tenant; Type: POLICY; Schema: notifications; Owner: -
--

CREATE POLICY tenant ON notifications.notification USING ((school_id = (NULLIF(current_setting('app.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('app.school_id'::text, true), ''::text))::uuid));


--
-- Name: notification_delivery_attempt tenant; Type: POLICY; Schema: notifications; Owner: -
--

CREATE POLICY tenant ON notifications.notification_delivery_attempt USING ((school_id = (NULLIF(current_setting('app.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('app.school_id'::text, true), ''::text))::uuid));


--
-- Name: notification_inbox tenant; Type: POLICY; Schema: notifications; Owner: -
--

CREATE POLICY tenant ON notifications.notification_inbox USING ((school_id = (NULLIF(current_setting('app.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('app.school_id'::text, true), ''::text))::uuid));


--
-- Name: notification_operation tenant; Type: POLICY; Schema: notifications; Owner: -
--

CREATE POLICY tenant ON notifications.notification_operation USING ((school_id = (NULLIF(current_setting('app.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('app.school_id'::text, true), ''::text))::uuid));


--
-- Name: notification_template tenant; Type: POLICY; Schema: notifications; Owner: -
--

CREATE POLICY tenant ON notifications.notification_template USING ((school_id = (NULLIF(current_setting('app.school_id'::text, true), ''::text))::uuid)) WITH CHECK ((school_id = (NULLIF(current_setting('app.school_id'::text, true), ''::text))::uuid));


--
-- PostgreSQL database dump complete
--

\unrestrict jKfIKb14JFeY0G8UeDUeEgg0PEG3daqzTyXwh8FHWbvS3SiPda3aAeAVbLwUHf3

