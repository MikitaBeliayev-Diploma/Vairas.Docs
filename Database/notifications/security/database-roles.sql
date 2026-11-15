REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO v_notifications_runtime;
DO $$ BEGIN EXECUTE format('REVOKE CONNECT,CREATE,TEMPORARY ON DATABASE %I FROM PUBLIC',current_database()); END $$;
DO $$ BEGIN EXECUTE format('GRANT CONNECT ON DATABASE %I TO v_notifications_runtime,v_notifications_migration',current_database()); END $$;
GRANT SELECT,INSERT ON "notification_template","notification","notification_delivery_attempt","notification_inbox","notification_operation" TO v_notifications_runtime;
GRANT UPDATE("notification_type","subject_template","body_template","status","revision","updated_at") ON "notification_template" TO v_notifications_runtime;
GRANT UPDATE("recipient_user_id","template_id","template_revision","notification_type","channel","subject","body","destination_address","contact_revision","source_context","source_id","source_revision","source_event_id","dispatch_key","scheduled_at","status","revision","attempt_count","next_attempt_at","sent_at","cancelled_at","failure_code","updated_at") ON "notification" TO v_notifications_runtime;
GRANT UPDATE("notification_id","attempt_no","provider_key","provider_message_id","status","started_at","finished_at","error_code") ON "notification_delivery_attempt" TO v_notifications_runtime;
DO $secure$ DECLARE f record; BEGIN
 FOR f IN SELECT p.oid::regprocedure AS signature FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='public' AND p.prokind='f' AND NOT EXISTS(SELECT 1 FROM pg_depend dep WHERE dep.classid='pg_proc'::regclass AND dep.objid=p.oid AND dep.deptype='e') LOOP
  EXECUTE format('ALTER FUNCTION %s SET search_path=pg_catalog,public,pg_temp',f.signature);
 END LOOP;
END $secure$;
ALTER TABLE "notification_template" ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_scope ON "notification_template" TO v_notifications_runtime USING (school_id=nullif(current_setting('vairas.school_id',true),'')::uuid) WITH CHECK (school_id=nullif(current_setting('vairas.school_id',true),'')::uuid);
ALTER TABLE "notification" ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_scope ON "notification" TO v_notifications_runtime USING (school_id=nullif(current_setting('vairas.school_id',true),'')::uuid) WITH CHECK (school_id=nullif(current_setting('vairas.school_id',true),'')::uuid);
ALTER TABLE "notification_delivery_attempt" ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_scope ON "notification_delivery_attempt" TO v_notifications_runtime USING (school_id=nullif(current_setting('vairas.school_id',true),'')::uuid) WITH CHECK (school_id=nullif(current_setting('vairas.school_id',true),'')::uuid);
ALTER TABLE "notification_inbox" ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_scope ON "notification_inbox" TO v_notifications_runtime USING (school_id=nullif(current_setting('vairas.school_id',true),'')::uuid) WITH CHECK (school_id=nullif(current_setting('vairas.school_id',true),'')::uuid);
ALTER TABLE "notification_operation" ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_scope ON "notification_operation" TO v_notifications_runtime USING (school_id=nullif(current_setting('vairas.school_id',true),'')::uuid) WITH CHECK (school_id=nullif(current_setting('vairas.school_id',true),'')::uuid);
