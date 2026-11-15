DO $demo$
DECLARE t int; n int; suffix text; s uuid; actor uuid; student uuid; teacher uuid;
 vehicle uuid; branch uuid; enrollment uuid; grp uuid; programme uuid; definition uuid;
 req uuid; rule uuid; series uuid; cp uuid; ct uuid; practical uuid; theory uuid;
 initial_op uuid; reschedule_op uuid; appointment_op uuid; appointment uuid;
BEGIN
 IF current_setting('vairas.demo',true) IS DISTINCT FROM 'on' THEN
  RAISE EXCEPTION 'Demo seed requires SET vairas.demo = on';
 END IF;
 FOR t IN 1..2 LOOP
  suffix:=lpad(t::text,12,'0');
  s:=('10000000-0000-0000-0000-'||suffix)::uuid;
  actor:=('30000000-0000-0000-0000-'||suffix)::uuid;
  student:=('40000000-0000-0000-0000-'||suffix)::uuid;
  enrollment:=('50000000-0000-0000-0000-'||suffix)::uuid;
  programme:=('51000000-0000-0000-0000-'||suffix)::uuid;
  definition:=('52000000-0000-0000-0000-'||suffix)::uuid;
  branch:=('60000000-0000-0000-0000-'||suffix)::uuid;
  teacher:=('70000000-0000-0000-0000-'||suffix)::uuid;
  vehicle:=('80000000-0000-0000-0000-'||suffix)::uuid;
  practical:=('90000000-0000-0000-0000-'||suffix)::uuid;
  theory:=('86000000-0000-0000-0000-'||suffix)::uuid;
  grp:=('91000000-0000-0000-0000-'||suffix)::uuid;
  req:=('a1000000-0000-0000-0000-'||suffix)::uuid;
  rule:=('a2000000-0000-0000-0000-'||suffix)::uuid;
  series:=('a3000000-0000-0000-0000-'||suffix)::uuid;
  cp:=('a4000000-0000-0000-0000-'||suffix)::uuid;
  ct:=('a5000000-0000-0000-0000-'||suffix)::uuid;
  initial_op:=('a6000000-0000-0000-0000-'||suffix)::uuid;
  reschedule_op:=('a7000000-0000-0000-0000-'||suffix)::uuid;
  appointment_op:=('a8000000-0000-0000-0000-'||suffix)::uuid;
  appointment:=('a9000000-0000-0000-0000-'||suffix)::uuid;
  IF EXISTS(SELECT 1 FROM scheduling_request WHERE id=req AND revision=1) THEN CONTINUE; END IF;
  INSERT INTO scheduling_rule_version(id,rule_id,revision,source_kind,school_id,
   category_code,rule_code,severity,override_policy,scope_kind,decision_reason,
   numeric_limit,unit,effective_from,source_reference,verification_status,
   decided_at,created_by_user_id,created_at,decided_by_user_id)
  VALUES(rule,('a2100000-0000-0000-0000-'||suffix)::uuid,1,'School',s,'B',
   'MAX_LESSONS_PER_STUDENT_PER_DAY','Hard','SchoolEditable','School',
   'Synthetic school-policy fixture; not Lithuanian law.',4,'Lessons','2029-01-01 00:00Z',
   'urn:vairas:synthetic:school-policy','Verified','2029-01-01 08:00Z',actor,
   '2029-01-01 08:00Z',actor);
  INSERT INTO scheduling_request(id,revision,school_id,status,planning_start,
   planning_end,submitted_by_user_id,submitted_at,generated_at,created_by_user_id,created_at)
  VALUES(req,1,s,'Ready','2030-01-07','2030-01-09',actor,'2029-01-01 08:02Z',
   '2029-01-01 08:03Z',actor,'2029-01-01 08:01Z');
  INSERT INTO scheduling_request_enrollment VALUES(req,1,enrollment,student,1,programme,'B');
  INSERT INTO scheduling_request_group(request_id,request_revision,training_program_version_id,
   category_code,group_id,membership_revision) VALUES(req,1,programme,'B',grp,1);
  INSERT INTO scheduling_request_resource VALUES
   (req,1,'Instructor',teacher,1),(req,1,'Vehicle',vehicle,3),(req,1,'Branch',branch,1);
  INSERT INTO scheduling_request_window VALUES(('aa000000-0000-0000-0000-'||suffix)::uuid,
   req,1,'2030-01-07 08:00Z','2030-01-07 13:00Z');
  INSERT INTO scheduling_request_rule VALUES(req,1,rule);
  INSERT INTO recurring_lesson_series(id,school_id,kind,frequency,recurrence_interval,
   weekdays,local_start_time,duration_minutes,time_zone,starts_on,ends_on)
  VALUES(series,s,'Practical','Daily',1,ARRAY[]::smallint[],'10:00',60,
   'Europe/Vilnius','2030-01-07','2030-01-08');
  INSERT INTO candidate_lesson(id,request_id,request_revision,kind,student_id,enrollment_id,
   teacher_id,vehicle_id,branch_id,series_id,starts_at,ends_at,category_code)
  VALUES(cp,req,1,'Practical',student,enrollment,teacher,vehicle,branch,series,
   '2030-01-07 08:00Z','2030-01-07 09:00Z','B');
  INSERT INTO candidate_lesson(id,request_id,request_revision,kind,group_id,
   teacher_id,branch_id,starts_at,ends_at,category_code)
  VALUES(ct,req,1,'Theory',grp,teacher,branch,'2030-01-07 10:00Z','2030-01-07 11:00Z','B');
  INSERT INTO candidate_lesson_participant VALUES(ct,enrollment,student,1);
  INSERT INTO scheduling_operation(id,school_id,action_type,request_id,request_revision,
   actor_user_id,channel,reason,status,started_at)
  VALUES(initial_op,s,'ConfirmSchedule',req,1,actor,'Web',
   'Synthetic initial proposal confirmation. No real eligibility is asserted.',
   'Pending','2029-01-01 08:04Z');
  INSERT INTO lesson(id,school_id,kind,branch_id,teacher_id,enrollment_id,student_id,
   vehicle_id,starts_at,ends_at,status,revision,series_id,source_candidate_id,created_at,category_code)
  VALUES(practical,s,'Practical',branch,teacher,enrollment,student,vehicle,
   '2030-01-07 08:00Z','2030-01-07 09:00Z','Scheduled',1,series,cp,'2029-01-01 08:04Z','B');
  INSERT INTO lesson(id,school_id,kind,branch_id,teacher_id,group_id,group_membership_revision,
   starts_at,ends_at,status,revision,source_candidate_id,created_at,category_code)
  VALUES(theory,s,'Theory',branch,teacher,grp,1,'2030-01-07 10:00Z','2030-01-07 11:00Z',
   'Scheduled',1,ct,'2029-01-01 08:04Z','B');
  INSERT INTO lesson_participant VALUES(theory,enrollment,student,1);
  UPDATE scheduling_operation SET status='Committed',finished_at='2029-01-01 08:04Z',
   result_lesson_id=practical,outcome_code='SYNTHETIC_COMMITTED' WHERE id=initial_op;
  INSERT INTO scheduling_operation_rule VALUES(initial_op,rule);
  UPDATE scheduling_request SET status='Confirmed',confirmed_operation_id=initial_op,
   confirmed_at='2029-01-01 08:04Z' WHERE id=req AND revision=1;
   
  FOR n IN 1..3 LOOP
   INSERT INTO reservation_claim(id,operation_id,lesson_id,school_id,resource_kind,
    resource_key,starts_at,ends_at,status,created_at,released_at)
   VALUES(('b1000000-0000-0000-0000-'||lpad((t*100+n)::text,12,'0'))::uuid,
    initial_op,practical,s,CASE n WHEN 1 THEN 'Student' WHEN 2 THEN 'Instructor' ELSE 'Vehicle' END,
    CASE n WHEN 1 THEN student WHEN 2 THEN teacher ELSE vehicle END,
    '2030-01-07 08:00Z','2030-01-07 09:00Z','Released','2029-01-01 08:04Z','2029-01-02 08:00Z');
  END LOOP;
  INSERT INTO scheduling_operation(id,school_id,action_type,actor_user_id,channel,
   reason,status,started_at,target_lesson_id,expected_lesson_revision)
  VALUES(reschedule_op,s,'Reschedule',actor,'Web','Synthetic time correction.',
   'Pending','2029-01-02 08:00Z',practical,1);
  INSERT INTO lesson_change(id,school_id,lesson_id,operation_id,revision,previous_status,
   previous_start,previous_end,previous_teacher_id,previous_vehicle_id,
   previous_branch_id,previous_series_id,changed_at)
  VALUES(('b2000000-0000-0000-0000-'||suffix)::uuid,s,practical,reschedule_op,2,'Scheduled',
   '2030-01-07 08:00Z','2030-01-07 09:00Z',teacher,vehicle,branch,series,'2029-01-02 08:00Z');
  UPDATE lesson SET starts_at='2030-01-07 08:30Z',ends_at='2030-01-07 09:30Z',revision=2
   WHERE id=practical AND revision=1;
  UPDATE scheduling_operation SET status='Committed',finished_at='2029-01-02 08:00Z',
   result_lesson_id=practical,outcome_code='SYNTHETIC_COMMITTED' WHERE id=reschedule_op;
  INSERT INTO scheduling_operation_rule VALUES(reschedule_op,rule);
  FOR n IN 1..3 LOOP
   INSERT INTO reservation_claim(id,operation_id,lesson_id,school_id,resource_kind,
    resource_key,starts_at,ends_at,status,created_at)
   VALUES(('b3000000-0000-0000-0000-'||lpad((t*100+n)::text,12,'0'))::uuid,
    reschedule_op,practical,s,CASE n WHEN 1 THEN 'Student' WHEN 2 THEN 'Instructor' ELSE 'Vehicle' END,
    CASE n WHEN 1 THEN student WHEN 2 THEN teacher ELSE vehicle END,
    '2030-01-07 08:30Z','2030-01-07 09:30Z','Active','2029-01-02 08:00Z');
   INSERT INTO reservation_claim(id,operation_id,lesson_id,school_id,resource_kind,
    resource_key,starts_at,ends_at,status,created_at)
   VALUES(('b4000000-0000-0000-0000-'||lpad((t*100+n)::text,12,'0'))::uuid,
    initial_op,theory,s,CASE n WHEN 1 THEN 'Student' WHEN 2 THEN 'Instructor' ELSE 'Group' END,
    CASE n WHEN 1 THEN student WHEN 2 THEN teacher ELSE grp END,
    '2030-01-07 10:00Z','2030-01-07 11:00Z','Active','2029-01-01 08:04Z');
  END LOOP;
  INSERT INTO assessment_appointment(id,school_id,kind,enrollment_id,student_id,
   assessment_definition_id,reason,teacher_id,branch_id,category_code,starts_at,
   ends_at,status,created_at)
  VALUES(appointment,s,'Theory',enrollment,student,definition,
   'Synthetic repeated-assessment appointment; no result/readiness asserted.',teacher,
   branch,'B','2030-01-07 12:00Z','2030-01-07 12:30Z','Scheduled','2029-01-01 08:05Z');
  INSERT INTO scheduling_operation(id,school_id,action_type,actor_user_id,channel,
   reason,status,started_at,finished_at,result_appointment_id,outcome_code)
  VALUES(appointment_op,s,'CreateAssessment',actor,'Web','Synthetic appointment allocation.',
   'Committed','2029-01-01 08:05Z','2029-01-01 08:05Z',appointment,'SYNTHETIC_COMMITTED');
  INSERT INTO scheduling_operation_rule VALUES(appointment_op,rule);
  FOR n IN 1..2 LOOP
   INSERT INTO reservation_claim(id,operation_id,assessment_appointment_id,school_id,
    resource_kind,resource_key,starts_at,ends_at,status,created_at)
   VALUES(('b5000000-0000-0000-0000-'||lpad((t*100+n)::text,12,'0'))::uuid,
    appointment_op,appointment,s,CASE n WHEN 1 THEN 'Student' ELSE 'Instructor' END,
    CASE n WHEN 1 THEN student ELSE teacher END,'2030-01-07 12:00Z','2030-01-07 12:30Z',
    'Active','2029-01-01 08:05Z');
  END LOOP;
 END LOOP;
END $demo$;
