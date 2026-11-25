START TRANSACTION;
ALTER TABLE scheduling_operation ADD COLUMN fingerprint varchar(64) NOT NULL DEFAULT '', ADD COLUMN result_json text NOT NULL DEFAULT '', ADD COLUMN http_status integer NOT NULL DEFAULT 0;
ALTER TABLE scheduling_operation DROP CONSTRAINT operation_action;
ALTER TABLE scheduling_operation ADD CONSTRAINT operation_action CHECK(action_type IN ('ConfirmSchedule','CreateLesson','Reschedule','Cancel','ChangeGroup','CompleteLesson','CorrectActualInterval','CreateAssessment','CancelAssessment','CreateDraft','ReviseDraft','SubmitRequest','GenerateProposal','PublishRule'));
ALTER TABLE scheduling_request ADD COLUMN inputs_json text NOT NULL DEFAULT '{}', ADD COLUMN basis_json text NOT NULL DEFAULT '', ADD COLUMN school_revision bigint NOT NULL DEFAULT 0;
ALTER TABLE assessment_appointment ADD COLUMN readiness_evaluation_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000', ADD COLUMN revision integer NOT NULL DEFAULT 1;
ALTER TABLE lesson_participant ADD COLUMN is_active boolean NOT NULL DEFAULT true;

CREATE TABLE gate_command (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    fingerprint text NOT NULL,
    kind text NOT NULL,
    result_json text NOT NULL,
    http_status integer NOT NULL,
    CONSTRAINT "PK_gate_command" PRIMARY KEY (id)
);

CREATE TABLE outbox_message (
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
    attempts integer NOT NULL,
    CONSTRAINT "PK_outbox_message" PRIMARY KEY (id)
);

CREATE TABLE school_barrier (
    school_id uuid NOT NULL,
    revision_floor bigint NOT NULL,
    pending_operation_id uuid,
    CONSTRAINT "PK_school_barrier" PRIMARY KEY (school_id)
);

CREATE TABLE school_transition (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    before_revision bigint NOT NULL,
    after_revision bigint NOT NULL,
    fingerprint text NOT NULL,
    payload_json text NOT NULL,
    status text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT "PK_school_transition" PRIMARY KEY (id)
);

CREATE TABLE vehicle_block (
    id uuid NOT NULL,
    school_id uuid NOT NULL,
    vehicle_id uuid NOT NULL,
    operation_id uuid NOT NULL,
    reason text NOT NULL,
    status text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT "PK_vehicle_block" PRIMARY KEY (id)
);

CREATE TABLE vehicle_guard (
    vehicle_id uuid NOT NULL,
    school_id uuid NOT NULL,
    CONSTRAINT "PK_vehicle_guard" PRIMARY KEY (vehicle_id)
);

CREATE INDEX "IX_outbox_message_published_at_available_at" ON outbox_message (published_at, available_at);

CREATE INDEX "IX_school_transition_school_id_status" ON school_transition (school_id, status);

CREATE INDEX "IX_vehicle_block_vehicle_id_status" ON vehicle_block (vehicle_id, status);

CREATE FUNCTION public.scheduling_immutable() RETURNS trigger LANGUAGE plpgsql SET search_path=pg_catalog,public,pg_temp AS $$ BEGIN
 RAISE EXCEPTION 'Scheduling evidence is immutable' USING ERRCODE='23514';
END $$;
CREATE TRIGGER history_immutable BEFORE UPDATE OR DELETE ON lesson_change FOR EACH ROW EXECUTE FUNCTION public.scheduling_immutable();
CREATE TRIGGER rule_immutable BEFORE UPDATE OR DELETE ON scheduling_rule_version FOR EACH ROW EXECUTE FUNCTION public.scheduling_immutable();
CREATE TRIGGER rule_evidence_immutable BEFORE UPDATE OR DELETE ON scheduling_operation_rule FOR EACH ROW EXECUTE FUNCTION public.scheduling_immutable();
CREATE TRIGGER candidate_immutable BEFORE UPDATE OR DELETE ON candidate_lesson FOR EACH ROW EXECUTE FUNCTION public.scheduling_immutable();
CREATE TRIGGER candidate_roster_immutable BEFORE UPDATE OR DELETE ON candidate_lesson_participant FOR EACH ROW EXECUTE FUNCTION public.scheduling_immutable();
CREATE TRIGGER gate_command_immutable BEFORE UPDATE OR DELETE ON gate_command FOR EACH ROW EXECUTE FUNCTION public.scheduling_immutable();
CREATE FUNCTION public.scheduling_operation_guard() RETURNS trigger LANGUAGE plpgsql SET search_path=pg_catalog,public,pg_temp AS $$ BEGIN
 IF OLD.status IN ('Committed','Rejected') OR
   (to_jsonb(NEW)-ARRAY['status','finished_at','result_lesson_id','result_appointment_id','outcome_code','result_json','http_status'])
   IS DISTINCT FROM (to_jsonb(OLD)-ARRAY['status','finished_at','result_lesson_id','result_appointment_id','outcome_code','result_json','http_status']) THEN
  RAISE EXCEPTION 'Immutable command identity or terminal outcome' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER operation_guard BEFORE UPDATE ON scheduling_operation FOR EACH ROW EXECUTE FUNCTION public.scheduling_operation_guard();
CREATE FUNCTION public.scheduling_request_guard() RETURNS trigger LANGUAGE plpgsql SET search_path=pg_catalog,public,pg_temp AS $$ BEGIN
 IF OLD.status <> 'Draft' AND (to_jsonb(NEW)-ARRAY['status','generated_at','confirmed_at','confirmed_operation_id'])
 IS DISTINCT FROM (to_jsonb(OLD)-ARRAY['status','generated_at','confirmed_at','confirmed_operation_id']) THEN
  RAISE EXCEPTION 'Submitted inputs are immutable' USING ERRCODE='23514';
 END IF;
 IF OLD.status='Confirmed' THEN RAISE EXCEPTION 'Confirmed request is immutable' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER request_guard BEFORE UPDATE ON scheduling_request FOR EACH ROW EXECUTE FUNCTION public.scheduling_request_guard();
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;


INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20261124090543_Reliability', '10.0.15');

COMMIT;

