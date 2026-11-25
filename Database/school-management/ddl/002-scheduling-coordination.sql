START TRANSACTION;
CREATE TABLE school_coordination (
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
    lease_until timestamp with time zone,
    CONSTRAINT "PK_school_coordination" PRIMARY KEY (operation_id, school_id)
);

CREATE FUNCTION public.school_pending_coordination() RETURNS TABLE(school_id uuid,operation_id uuid)
 LANGUAGE sql STABLE SECURITY DEFINER SET search_path=pg_catalog,public,pg_temp AS $$
 SELECT c.school_id,c.operation_id FROM public.school_coordination c WHERE c.state IN ('Pending','LocalApplied','AbortPending') ORDER BY c.effective_from,c.operation_id;
$$;
REVOKE ALL ON FUNCTION public.school_pending_coordination() FROM PUBLIC;
CREATE FUNCTION public.school_coordination_guard() RETURNS trigger LANGUAGE plpgsql SET search_path=pg_catalog,public,pg_temp AS $$ BEGIN
 IF OLD.state IN ('Committed','Aborted') OR (to_jsonb(NEW)-ARRAY['transition_json','payload_hash','state','lease_id','lease_until'])
 IS DISTINCT FROM (to_jsonb(OLD)-ARRAY['transition_json','payload_hash','state','lease_id','lease_until']) OR
 (OLD.transition_json<>'' AND (OLD.transition_json IS DISTINCT FROM NEW.transition_json OR OLD.payload_hash IS DISTINCT FROM NEW.payload_hash)) THEN
 RAISE EXCEPTION 'Immutable School coordination intent' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER school_coordination_guard BEFORE UPDATE ON school_coordination FOR EACH ROW EXECUTE FUNCTION public.school_coordination_guard();
REVOKE ALL ON FUNCTION public.school_coordination_guard() FROM PUBLIC;


INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20261124090543_SchedulingCoordination', '10.0.15');

COMMIT;

