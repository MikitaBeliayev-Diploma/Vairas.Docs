REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO v_user_management_runtime;
DO $$ BEGIN EXECUTE format('REVOKE CONNECT,CREATE,TEMPORARY ON DATABASE %I FROM PUBLIC',current_database()); END $$;
DO $$ BEGIN EXECUTE format('GRANT CONNECT ON DATABASE %I TO v_user_management_runtime,v_user_management_migration',current_database()); END $$;
GRANT SELECT,INSERT ON "user_profile","student_profile","teacher_profile","administrator_profile","profile_operation" TO v_user_management_runtime;
GRANT UPDATE("first_name","last_name","email_address","phone_number","status","revision","updated_at") ON "user_profile" TO v_user_management_runtime;
DO $secure$ DECLARE f record; BEGIN
 FOR f IN SELECT p.oid::regprocedure AS signature FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='public' AND p.prokind='f' AND NOT EXISTS(SELECT 1 FROM pg_depend dep WHERE dep.classid='pg_proc'::regclass AND dep.objid=p.oid AND dep.deptype='e') LOOP
  EXECUTE format('ALTER FUNCTION %s SET search_path=pg_catalog,public,pg_temp',f.signature);
 END LOOP;
END $secure$;
