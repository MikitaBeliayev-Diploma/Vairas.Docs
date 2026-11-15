DO $demo$
DECLARE n integer; s uuid; u uuid; t uuid; notice uuid; atid uuid;
BEGIN
 IF current_setting('vairas.demo',true) IS DISTINCT FROM 'on' THEN RAISE EXCEPTION 'Set vairas.demo=on in a test/demo connection'; END IF;
 FOR n IN 1..2 LOOP
  s:=('10000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid;
  u:=('30000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid;
  t:=('91000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid;
  notice:=('92000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid;
  atid:=('93000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid;
  IF EXISTS(SELECT 1 FROM notification WHERE school_id=s AND notification_id=notice) THEN CONTINUE; END IF;
  INSERT INTO notification_template(school_id,template_id,notification_type,subject_template,body_template,status,revision,created_at,updated_at)
  VALUES(s,t,'LessonScheduled','Synthetic lesson notice','Open the authenticated application for details.','Active',1,'2026-01-01T00:00:00Z','2026-01-01T00:00:00Z');
  INSERT INTO notification(school_id,notification_id,recipient_user_id,template_id,template_revision,notification_type,channel,subject,body,destination_address,contact_revision,source_context,source_id,source_revision,source_event_id,dispatch_key,scheduled_at,status,revision,attempt_count,created_at,updated_at)
  VALUES(s,notice,u,t,1,'LessonScheduled','Email','Synthetic lesson notice','No personal details in this synthetic notice.','demo-'||n||'@example.invalid','demo-contact-1','Scheduling',('94000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid,1,('95000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid,'synthetic:lesson:'||n||':1:scheduled','2026-01-01T01:00:00Z','Pending',1,0,'2026-01-01T00:00:00Z','2026-01-01T00:00:00Z');
  UPDATE notification SET status='Sending',revision=2,attempt_count=1,updated_at='2026-01-01T01:00:00Z' WHERE school_id=s AND notification_id=notice;
  INSERT INTO notification_delivery_attempt(school_id,attempt_id,notification_id,attempt_no,provider_key,status,started_at)
  VALUES(s,atid,notice,1,'demo-provider-key-'||n,'Started','2026-01-01T01:00:00Z');
  IF n=1 THEN
   UPDATE notification_delivery_attempt SET status='Accepted',provider_message_id='synthetic-provider-result-1',finished_at='2026-01-01T01:01:00Z' WHERE school_id=s AND attempt_id=atid;
   UPDATE notification SET status='Sent',revision=3,sent_at='2026-01-01T01:01:00Z',updated_at='2026-01-01T01:01:00Z' WHERE school_id=s AND notification_id=notice;
  ELSE
   UPDATE notification_delivery_attempt SET status='Unknown',finished_at='2026-01-01T01:01:00Z',error_code='DEMO_UNCERTAIN' WHERE school_id=s AND attempt_id=atid;
   UPDATE notification SET status='DeliveryUnknown',revision=3,updated_at='2026-01-01T01:01:00Z' WHERE school_id=s AND notification_id=notice;
  END IF;
  INSERT INTO notification_inbox(school_id,producer,event_id,payload_hash,source_id,source_revision,outcome,outcome_code,received_at,processed_at)
  VALUES(s,'Scheduling',('95000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid,repeat('a',64),('94000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid,1,'Applied','SyntheticFixture','2026-01-01T00:00:00Z','2026-01-01T00:00:01Z');
  INSERT INTO notification_operation(school_id,operation_id,actor_user_id,channel,command_name,target_id,request_hash,authority_basis,outcome,outcome_code,resulting_revision,recorded_at)
  VALUES(s,('96000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid,u,'Web','DemoFixtureRecorded',notice,repeat('b',64),'Synthetic scope, not authorization evidence','Applied','DEMO_ONLY',3,'2026-01-01T01:01:00Z');
 END LOOP;
END $demo$;
