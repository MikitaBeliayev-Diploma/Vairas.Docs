REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO v_authentication_runtime;
DO $$ BEGIN EXECUTE format('REVOKE CONNECT,CREATE,TEMPORARY ON DATABASE %I FROM PUBLIC',current_database()); END $$;
DO $$ BEGIN EXECUTE format('GRANT CONNECT ON DATABASE %I TO v_authentication_runtime,v_authentication_migration',current_database()); END $$;
GRANT SELECT,INSERT ON "identity","password_credential","external_identity","auth_session","refresh_token","account_challenge","oidc_request","security_event" TO v_authentication_runtime;
GRANT UPDATE("login_email","email_verified_at","security_state","credential_revision") ON "identity" TO v_authentication_runtime;
GRANT UPDATE("auth_method","expires_at","revoked_at","revocation_reason") ON "auth_session" TO v_authentication_runtime;
GRANT UPDATE("session_id","parent_token_id","secret_digest","expires_at","consumed_at","revoked_at") ON "refresh_token" TO v_authentication_runtime;
GRANT UPDATE("purpose","login_email","credential_revision","secret_digest","expires_at","consumed_at","invalidated_at") ON "account_challenge" TO v_authentication_runtime;
GRANT UPDATE("purpose","issuer","state_digest","browser_digest","nonce_digest","pkce_verifier_ciphertext","redirect_uri","link_identity_id","link_session_id","expires_at","consumed_at") ON "oidc_request" TO v_authentication_runtime;
GRANT UPDATE ON password_credential,refresh_token TO v_authentication_runtime;
GRANT EXECUTE ON FUNCTION auth_rotate_refresh(text,uuid,text,uuid) TO v_authentication_runtime;
DO $secure$ DECLARE f record; BEGIN
 FOR f IN SELECT p.oid::regprocedure AS signature FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='public' AND p.prokind='f' AND NOT EXISTS(SELECT 1 FROM pg_depend dep WHERE dep.classid='pg_proc'::regclass AND dep.objid=p.oid AND dep.deptype='e') LOOP
  EXECUTE format('ALTER FUNCTION %s SET search_path=pg_catalog,public,pg_temp',f.signature);
 END LOOP;
END $secure$;
