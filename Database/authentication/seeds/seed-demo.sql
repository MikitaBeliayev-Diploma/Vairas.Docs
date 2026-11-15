DO $demo$
DECLARE n integer; i uuid; s uuid; r uuid;
BEGIN
 IF current_setting('vairas.demo',true) IS DISTINCT FROM 'on' THEN RAISE EXCEPTION 'Set vairas.demo=on in a test/demo connection'; END IF;
 FOR n IN 1..2 LOOP
  i:=('20000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid;
  s:=('21000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid;
  r:=('23000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid;
  INSERT INTO identity(identity_id,login_email,email_verified_at,security_state,credential_revision,created_at)
  VALUES(i,'demo-'||n||'@example.invalid',NULL,'Disabled',1,'2026-01-01T00:00:00Z') ON CONFLICT DO NOTHING;
  INSERT INTO password_credential(identity_id,password_hash,changed_at)
  VALUES(i,'$argon2id$DEMO-NOT-A-VALID-ENCODING-OR-PASSWORD','2026-01-01T00:00:00Z') ON CONFLICT DO NOTHING;
  INSERT INTO external_identity(external_identity_id,identity_id,issuer,subject,linked_at)
  VALUES(('22000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid,i,'https://identity.example.invalid','synthetic-subject-'||n,'2026-01-01T00:00:00Z') ON CONFLICT DO NOTHING;
  INSERT INTO auth_session(session_id,identity_id,auth_method,created_at,expires_at,revoked_at,revocation_reason)
  VALUES(s,i,CASE WHEN n=1 THEN 'Password' ELSE 'Oidc' END,'2026-01-01T00:00:00Z','2026-02-01T00:00:00Z','2026-01-03T00:00:00Z','SyntheticDemoRevoked') ON CONFLICT DO NOTHING;
  INSERT INTO refresh_token(refresh_token_id,session_id,parent_token_id,secret_digest,created_at,expires_at,consumed_at,revoked_at)
  VALUES(r,s,NULL,repeat(n::text,64),'2026-01-01T00:00:00Z','2026-01-08T00:00:00Z',CASE WHEN n=1 THEN '2026-01-02T00:00:00Z'::timestamptz ELSE NULL END,'2026-01-03T00:00:00Z') ON CONFLICT DO NOTHING;
  INSERT INTO account_challenge(challenge_id,identity_id,purpose,login_email,credential_revision,secret_digest,created_at,expires_at,consumed_at,invalidated_at)
  VALUES(('24000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid,i,CASE WHEN n=1 THEN 'ResetPassword' ELSE 'VerifyEmail' END,'demo-'||n||'@example.invalid',1,repeat((n+2)::text,64),'2026-01-01T00:00:00Z','2026-01-01T00:15:00Z','2026-01-01T00:10:00Z',NULL) ON CONFLICT DO NOTHING;
  INSERT INTO oidc_request(request_id,purpose,issuer,state_digest,browser_digest,nonce_digest,pkce_verifier_ciphertext,redirect_uri,link_identity_id,link_session_id,created_at,expires_at,consumed_at)
  VALUES(('25000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid,CASE WHEN n=1 THEN 'Link' ELSE 'Login' END,'https://identity.example.invalid',repeat((n+4)::text,64),repeat('a',64),repeat('b',64),'DEMO-NOT-REAL-CIPHERTEXT','https://app.example.invalid/callback',CASE WHEN n=1 THEN i ELSE NULL END,CASE WHEN n=1 THEN s ELSE NULL END,'2026-01-01T00:00:00Z','2026-01-01T00:05:00Z','2026-01-01T00:04:00Z') ON CONFLICT DO NOTHING;
  INSERT INTO security_event(event_id,identity_id,session_id,event_type,outcome_code,correlation_id,occurred_at)
  VALUES(('26000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid,i,s,'DemoFixture','SyntheticNotAuthenticated',('27000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid,'2026-01-03T00:00:00Z') ON CONFLICT DO NOTHING;
 END LOOP;
 INSERT INTO refresh_token(refresh_token_id,session_id,parent_token_id,secret_digest,created_at,expires_at,consumed_at,revoked_at)
 VALUES('23000000-0000-0000-0000-000000000003','21000000-0000-0000-0000-000000000001','23000000-0000-0000-0000-000000000001',repeat('7',64),'2026-01-02T00:00:00Z','2026-01-09T00:00:00Z',NULL,'2026-01-03T00:00:00Z') ON CONFLICT DO NOTHING;
END $demo$;
