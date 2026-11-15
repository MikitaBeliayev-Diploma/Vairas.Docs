DO $$ BEGIN
 IF current_setting('vairas.demo',true) IS DISTINCT FROM 'on' THEN
   RAISE EXCEPTION 'Demo seed blocked: SET vairas.demo = on in an isolated demo database';
 END IF;
END $$;

DO $$
DECLARE n int; suffix text; u uuid; ident uuid;
BEGIN
 FOR n IN 1..2 LOOP
  suffix=lpad(n::text,12,'0');
  u=('30000000-0000-0000-0000-'||suffix)::uuid;
  ident=('20000000-0000-0000-0000-'||suffix)::uuid;
  INSERT INTO user_profile(user_id,identity_id,first_name,last_name,email_address,phone_number,status,revision,created_at,updated_at)
   VALUES(u,ident,'Synthetic',CASE n WHEN 1 THEN 'Demo A' ELSE 'Demo B' END,
     CASE n WHEN 1 THEN 'student.a@example.invalid' ELSE NULL END,NULL,
     CASE n WHEN 1 THEN 'Active'::um_user_status ELSE 'Inactive'::um_user_status END,1,'2026-01-01T00:00:00Z','2026-01-01T00:00:00Z')
   ON CONFLICT DO NOTHING;
  INSERT INTO student_profile(student_id,user_id,created_at)
   VALUES(('40000000-0000-0000-0000-'||suffix)::uuid,u,'2026-01-01T00:00:00Z') ON CONFLICT DO NOTHING;
   
  INSERT INTO teacher_profile(teacher_id,user_id,created_at)
   VALUES(('70000000-0000-0000-0000-'||suffix)::uuid,u,'2026-01-01T00:00:00Z') ON CONFLICT DO NOTHING;
  INSERT INTO administrator_profile(administrator_id,user_id,created_at)
   VALUES(('71000000-0000-0000-0000-'||suffix)::uuid,u,'2026-01-01T00:00:00Z') ON CONFLICT DO NOTHING;
  INSERT INTO profile_operation(operation_id,actor_service,authority_basis,channel,command_name,target_kind,target_id,resulting_revision,request_fingerprint,outcome,outcome_code,recorded_at,reason)
   VALUES(('72000000-0000-0000-0000-'||suffix)::uuid,'diploma-demo-fixture','synthetic-fixture/not-an-authority-grant','Internal','LoadSyntheticProfile','UserProfile',u,1,
     repeat(CASE n WHEN 1 THEN 'a' ELSE 'b' END,64),'Applied','DEMO_ONLY','2026-01-01T00:00:00Z','Synthetic fixture receipt; not a deployed onboarding result') ON CONFLICT DO NOTHING;
 END LOOP;
END $$;
