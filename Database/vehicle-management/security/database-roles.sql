REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO v_vehicle_management_runtime;
DO $$ BEGIN EXECUTE format('REVOKE CONNECT,CREATE,TEMPORARY ON DATABASE %I FROM PUBLIC',current_database()); END $$;
DO $$ BEGIN EXECUTE format('GRANT CONNECT ON DATABASE %I TO v_vehicle_management_runtime,v_vehicle_management_migration',current_database()); END $$;
GRANT SELECT,INSERT ON "vehicle","vehicle_supported_category","vehicle_teacher_assignment","maintenance","vehicle_operation" TO v_vehicle_management_runtime;
GRANT UPDATE("branch_id","registration_country_code","registration_number","manufacturer","model","manufacture_year","transmission","status","revision","updated_at") ON "vehicle" TO v_vehicle_management_runtime;
GRANT UPDATE("school_membership_id","assigned_at") ON "vehicle_teacher_assignment" TO v_vehicle_management_runtime;
GRANT UPDATE("vehicle_id","type","scheduled_at","started_at","completed_at","cancelled_at","status","comment","revision","updated_at") ON "maintenance" TO v_vehicle_management_runtime;
GRANT DELETE ON vehicle_supported_category,vehicle_teacher_assignment TO v_vehicle_management_runtime;
DO $secure$ DECLARE f record; BEGIN
 FOR f IN SELECT p.oid::regprocedure AS signature FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='public' AND p.prokind='f' AND NOT EXISTS(SELECT 1 FROM pg_depend dep WHERE dep.classid='pg_proc'::regclass AND dep.objid=p.oid AND dep.deptype='e') LOOP
  EXECUTE format('ALTER FUNCTION %s SET search_path=pg_catalog,public,pg_temp',f.signature);
 END LOOP;
END $secure$;
ALTER TABLE "vehicle" ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_scope ON "vehicle" TO v_vehicle_management_runtime USING (school_id=nullif(current_setting('vairas.school_id',true),'')::uuid) WITH CHECK (school_id=nullif(current_setting('vairas.school_id',true),'')::uuid);
ALTER TABLE "vehicle_supported_category" ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_scope ON "vehicle_supported_category" TO v_vehicle_management_runtime USING (school_id=nullif(current_setting('vairas.school_id',true),'')::uuid) WITH CHECK (school_id=nullif(current_setting('vairas.school_id',true),'')::uuid);
ALTER TABLE "vehicle_teacher_assignment" ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_scope ON "vehicle_teacher_assignment" TO v_vehicle_management_runtime USING (school_id=nullif(current_setting('vairas.school_id',true),'')::uuid) WITH CHECK (school_id=nullif(current_setting('vairas.school_id',true),'')::uuid);
ALTER TABLE "maintenance" ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_scope ON "maintenance" TO v_vehicle_management_runtime USING (school_id=nullif(current_setting('vairas.school_id',true),'')::uuid) WITH CHECK (school_id=nullif(current_setting('vairas.school_id',true),'')::uuid);
ALTER TABLE "vehicle_operation" ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_scope ON "vehicle_operation" TO v_vehicle_management_runtime USING (school_id=nullif(current_setting('vairas.school_id',true),'')::uuid) WITH CHECK (school_id=nullif(current_setting('vairas.school_id',true),'')::uuid);
