DO $$ BEGIN
 IF current_setting('vairas.demo',true) IS DISTINCT FROM 'on' THEN
   RAISE EXCEPTION 'Demo seed blocked: SET vairas.demo = on in an isolated demo database';
 END IF;
END $$;
DO $$ BEGIN
 IF current_setting('vairas.mock_sources',true) IS DISTINCT FROM 'on' THEN
   RAISE EXCEPTION 'MOCK source profile blocked: SET vairas.mock_sources = on explicitly in isolated demo DB';
 END IF;
END $$;

 
 
 
 
 
DO $$
DECLARE n int; x text; sid uuid; actor uuid; pid uuid; pv uuid; topic uuid; def uuid; dv uuid; eid uuid; lesson uuid; snap uuid; fdef uuid; fdv uuid; rid uuid; ev uuid; dec uuid; attempt1 uuid; attempt2 uuid; rv1 uuid; rv2 uuid; rvf uuid; prver uuid; thver uuid; evidence uuid;
BEGIN
 FOR n IN 1..2 LOOP
  x=lpad(n::text,12,'0');sid=('10000000-0000-0000-0000-'||x)::uuid;actor=('30000000-0000-0000-0000-'||x)::uuid;
  pid=('a1000000-0000-0000-0000-'||x)::uuid;pv=('51000000-0000-0000-0000-'||x)::uuid;
  topic=('a3000000-0000-0000-0000-'||x)::uuid;def=('52000000-0000-0000-0000-'||x)::uuid;dv=('a5000000-0000-0000-0000-'||x)::uuid;
  eid=('50000000-0000-0000-0000-'||x)::uuid;
  fdef=('52100000-0000-0000-0000-'||x)::uuid;fdv=('a5100000-0000-0000-0000-'||x)::uuid;
  rid=('b2000000-0000-0000-0000-'||x)::uuid;ev=('b3000000-0000-0000-0000-'||x)::uuid;dec=('b4000000-0000-0000-0000-'||x)::uuid;
  attempt1=('b5000000-0000-0000-0000-'||x)::uuid;attempt2=('b5100000-0000-0000-0000-'||x)::uuid;
  rv1=('b6000000-0000-0000-0000-'||x)::uuid;rv2=('b6100000-0000-0000-0000-'||x)::uuid;rvf=('b6200000-0000-0000-0000-'||x)::uuid;
  prver=('b7000000-0000-0000-0000-'||x)::uuid;thver=('b8000000-0000-0000-0000-'||x)::uuid;evidence=('b9000000-0000-0000-0000-'||x)::uuid;

  INSERT INTO training_program(id,school_id,category_code,name,created_at,revision)
   VALUES(pid,sid,'DEMO','Synthetic Draft Curriculum '||n,'2026-01-01T00:00:00Z',1) ON CONFLICT DO NOTHING;
  INSERT INTO training_program_version(id,school_id,program_id,version,status,pathway_code,required_theory_minutes,required_practical_minutes,theory_minutes_per_unit,practical_minutes_per_unit,effective_from,legal_basis_verified,created_by,created_at)
   VALUES(pv,sid,pid,1,'Draft','DEMO-NOT-LAW',60,60,60,60,'2026-01-01',false,actor,'2026-01-01T00:00:00Z') ON CONFLICT DO NOTHING;
  IF EXISTS(SELECT 1 FROM training_program_version WHERE id=pv AND status<>'Draft') AND NOT EXISTS(SELECT 1 FROM assessment_definition_version WHERE id=fdv AND school_id=sid AND program_version_id=pv) THEN
   RAISE EXCEPTION 'MOCK-SOURCE fixture profile expanded; recreate isolated demo database instead of extending immutable published curriculum';
  END IF;
  INSERT INTO program_rule_source(id,school_id,program_version_id,rule_code,source_uri,source_edition,applicability,verified_by,verified_at,effective_from,unit_description)
   VALUES(('a6000000-0000-0000-0000-'||x)::uuid,sid,pv,'DEMO-NOT-LITHUANIAN-LAW','urn:vairas:demo:DEMO-NOT-LITHUANIAN-LAW','MOCK-SOURCE/1','Synthetic test fixture only; never Lithuanian law or actual legal evidence',actor,'2026-01-01T00:00:00Z','2026-01-01','Synthetic 60-minute arithmetic unit; not a legal assertion') ON CONFLICT DO NOTHING;
  INSERT INTO training_topic(id,school_id,program_version_id,topic_key,name)
   VALUES(topic,sid,pv,'DEMO-TOPIC','Synthetic practice topic') ON CONFLICT DO NOTHING;
  INSERT INTO assessment_definition(id,school_id,program_id,code)
   VALUES(def,sid,pid,'DEMO-MIDTERM') ON CONFLICT DO NOTHING;
  INSERT INTO assessment_definition_version(id,school_id,definition_id,program_id,program_version_id,name,training_kind,stage,minimum_mark,maximum_mark,passing_mark,required_for_completion)
   VALUES(dv,sid,def,pid,pv,'Synthetic Draft Theory Assessment','Theory','Midterm',0,10,5,false) ON CONFLICT DO NOTHING;
  INSERT INTO assessment_topic(id,school_id,definition_version_id,program_version_id,topic_id)
   VALUES(('a7000000-0000-0000-0000-'||x)::uuid,sid,dv,pv,topic) ON CONFLICT DO NOTHING;
   
   
  INSERT INTO assessment_definition(id,school_id,program_id,code)
   VALUES(fdef,sid,pid,'DEMO-FINAL') ON CONFLICT DO NOTHING;
  INSERT INTO assessment_definition_version(id,school_id,definition_id,program_id,program_version_id,name,training_kind,stage,minimum_mark,maximum_mark,passing_mark,required_for_completion)
   VALUES(fdv,sid,fdef,pid,pv,'MOCK Final Assessment, not real qualification','Practical','Final',0,10,5,true) ON CONFLICT DO NOTHING;
  INSERT INTO admission_requirement(id,school_id,definition_version_id,program_version_id,code,kind,minimum_minutes)
   VALUES(('a8100000-0000-0000-0000-'||x)::uuid,sid,fdv,pv,'MOCK-PRACTICE','MinimumPracticalMinutes',60) ON CONFLICT DO NOTHING;
  INSERT INTO admission_requirement(id,school_id,definition_version_id,program_version_id,code,kind,prerequisite_definition_version_id)
   VALUES(('a8200000-0000-0000-0000-'||x)::uuid,sid,fdv,pv,'MOCK-MIDTERM-PASSED','AssessmentPassed',dv) ON CONFLICT DO NOTHING;
   
   
  IF NOT EXISTS(SELECT 1 FROM program_rule_source WHERE id=('a6000000-0000-0000-0000-'||x)::uuid AND school_id=sid AND program_version_id=pv AND rule_code='DEMO-NOT-LITHUANIAN-LAW' AND source_uri='urn:vairas:demo:DEMO-NOT-LITHUANIAN-LAW' AND source_edition='MOCK-SOURCE/1' AND verified_by=actor AND verified_at='2026-01-01T00:00:00Z'::timestamptz) THEN
   RAISE EXCEPTION 'Conflicting existing source row; use a fresh database for MOCK-SOURCE profile';
  END IF;
   
   
  UPDATE training_program_version SET status='Published',legal_basis_verified=true,published_by=actor,published_at='2026-01-01T00:00:00Z',journal_checklist_version_id=('b1000000-0000-0000-0000-'||x)::uuid
   WHERE id=pv AND school_id=sid AND program_id=pid AND version=1 AND status='Draft' AND pathway_code='DEMO-NOT-LAW' AND required_theory_minutes=60 AND required_practical_minutes=60 AND theory_minutes_per_unit=60 AND practical_minutes_per_unit=60 AND NOT legal_basis_verified;
  INSERT INTO student_training(id,school_id,student_id,category_code,program_version_id,program_assigned_by,program_assigned_at,dependency_revision,created_at)
   VALUES(eid,sid,('40000000-0000-0000-0000-'||x)::uuid,'DEMO',pv,actor,'2026-01-02T00:00:00Z',1,'2026-01-01T00:00:00Z') ON CONFLICT DO NOTHING;
  IF NOT EXISTS(SELECT 1 FROM training_program_version WHERE id=pv AND school_id=sid AND status='Published' AND legal_basis_verified AND published_by=actor AND published_at='2026-01-01T00:00:00Z'::timestamptz AND journal_checklist_version_id=('b1000000-0000-0000-0000-'||x)::uuid) OR NOT EXISTS(SELECT 1 FROM student_training WHERE id=eid AND school_id=sid AND program_version_id=pv AND program_assigned_by=actor AND program_assigned_at='2026-01-02T00:00:00Z'::timestamptz) THEN
   RAISE EXCEPTION 'Conflicting mock curriculum/enrollment binding; no implicit overwrite or programme transfer';
  END IF;
  lesson=('90000000-0000-0000-0000-'||x)::uuid;snap=('a9000000-0000-0000-0000-'||x)::uuid;
  INSERT INTO lesson_source_snapshot(id,school_id,lesson_id,lesson_revision,kind,instructor_id,enrollment_id,student_id,vehicle_id,physically_completed,source_valid,captured_at)
   VALUES(snap,sid,lesson,1,'Practical',('70000000-0000-0000-0000-'||x)::uuid,eid,('40000000-0000-0000-0000-'||x)::uuid,('80000000-0000-0000-0000-'||x)::uuid,false,false,'2026-01-03T00:00:00Z') ON CONFLICT DO NOTHING;
  INSERT INTO lesson_source_state(id,school_id,lesson_id,current_snapshot_id,freshness,last_verified_at,reason)
   VALUES(('aa000000-0000-0000-0000-'||x)::uuid,sid,lesson,snap,'Unavailable','2026-01-03T00:00:00Z','Synthetic unresolved source; does not imply a live Scheduling source') ON CONFLICT DO NOTHING;
  INSERT INTO practical_training_record(id,school_id,lesson_id,enrollment_id,revision)
   VALUES(('ab000000-0000-0000-0000-'||x)::uuid,sid,lesson,eid,1) ON CONFLICT DO NOTHING;
  lesson=('86000000-0000-0000-0000-'||x)::uuid;snap=('ac000000-0000-0000-0000-'||x)::uuid;
  INSERT INTO lesson_source_snapshot(id,school_id,lesson_id,lesson_revision,kind,instructor_id,group_id,membership_revision,physically_completed,source_valid,captured_at)
   VALUES(snap,sid,lesson,1,'Theory',('70000000-0000-0000-0000-'||x)::uuid,('91000000-0000-0000-0000-'||x)::uuid,2,false,false,'2026-01-03T00:00:00Z') ON CONFLICT DO NOTHING;
  INSERT INTO lesson_source_state(id,school_id,lesson_id,current_snapshot_id,freshness,last_verified_at,reason)
   VALUES(('ad000000-0000-0000-0000-'||x)::uuid,sid,lesson,snap,'Unavailable','2026-01-03T00:00:00Z','Synthetic unresolved source; no credit') ON CONFLICT DO NOTHING;
  INSERT INTO theory_training_record(id,school_id,lesson_id,revision)
   VALUES(('ae000000-0000-0000-0000-'||x)::uuid,sid,lesson,1) ON CONFLICT DO NOTHING;
   
  INSERT INTO practical_record_version(id,school_id,record_id,enrollment_id,lesson_id,program_version_id,version,source_snapshot_id,validation,validation_reason,created_by,created_at)
   VALUES(prver,sid,('ab000000-0000-0000-0000-'||x)::uuid,eid,('90000000-0000-0000-0000-'||x)::uuid,pv,1,('a9000000-0000-0000-0000-'||x)::uuid,'Incomplete','MOCK draft; source unavailable, no duration/distance verified',actor,'2026-01-03T09:00:00Z') ON CONFLICT DO NOTHING;
  INSERT INTO practical_record_topic(id,school_id,record_version_id,program_version_id,topic_id)
   VALUES(('b7100000-0000-0000-0000-'||x)::uuid,sid,prver,pv,topic) ON CONFLICT DO NOTHING;
  UPDATE practical_training_record SET current_version_id=prver,revision=2 WHERE id=('ab000000-0000-0000-0000-'||x)::uuid AND school_id=sid AND current_version_id IS NULL AND revision=1;
  INSERT INTO theory_record_version(id,school_id,record_id,lesson_id,version,source_snapshot_id,training_minutes,duration_explanation,validation,created_by,created_at)
   VALUES(thver,sid,('ae000000-0000-0000-0000-'||x)::uuid,('86000000-0000-0000-0000-'||x)::uuid,1,('ac000000-0000-0000-0000-'||x)::uuid,60,'MOCK reported value only, unconfirmed and never credited','Incomplete',actor,'2026-01-03T10:00:00Z') ON CONFLICT DO NOTHING;
  INSERT INTO theory_attendance(id,school_id,record_version_id,enrollment_id,student_id,attendance)
   VALUES(('b8100000-0000-0000-0000-'||x)::uuid,sid,thver,eid,('40000000-0000-0000-0000-'||x)::uuid,'Absent') ON CONFLICT DO NOTHING;
  UPDATE theory_training_record SET current_version_id=thver,revision=2 WHERE id=('ae000000-0000-0000-0000-'||x)::uuid AND school_id=sid AND current_version_id IS NULL AND revision=1;

   
  INSERT INTO assessment(id,school_id,enrollment_id,program_version_id,definition_version_id,attempt_number,revision)
   VALUES(attempt1,sid,eid,pv,dv,1,2),(attempt2,sid,eid,pv,dv,2,1) ON CONFLICT DO NOTHING;
  INSERT INTO assessment_result_version(id,school_id,assessment_id,enrollment_id,definition_version_id,version,command_id,status,assessor_id,assessed_at,recorded_by,recorded_at,mark,outcome,comment,correction_reason)
   VALUES(rv1,sid,attempt1,eid,dv,1,('c2000000-0000-0000-0000-'||x)::uuid,'Recorded',('70000000-0000-0000-0000-'||x)::uuid,'2026-01-03T12:00:00Z',actor,'2026-01-03T12:05:00Z',7,'Passed','MOCK historical value only, later annulled',NULL),
    (rv2,sid,attempt1,eid,dv,2,('c2100000-0000-0000-0000-'||x)::uuid,'Annulled',('70000000-0000-0000-0000-'||x)::uuid,'2026-01-03T12:00:00Z',actor,'2026-01-03T13:00:00Z',7,'Passed','MOCK annulled history, never eligible pass','Synthetic correction/annulment demonstration'),
    (rvf,sid,attempt2,eid,dv,1,('c2200000-0000-0000-0000-'||x)::uuid,'Recorded',('70000000-0000-0000-0000-'||x)::uuid,'2026-01-04T12:00:00Z',actor,'2026-01-04T12:05:00Z',4,'Failed','MOCK current failed attempt; no passed requirement',NULL) ON CONFLICT DO NOTHING;
  INSERT INTO assessment_topic_result(id,school_id,result_version_id,definition_version_id,assessment_topic_id,mark,comment)
   VALUES(('b6300000-0000-0000-0000-'||x)::uuid,sid,rvf,dv,('a7000000-0000-0000-0000-'||x)::uuid,4,'MOCK informational topic mark; not an independent outcome') ON CONFLICT DO NOTHING;

  INSERT INTO assessment_readiness(id,school_id,enrollment_id,program_version_id,definition_version_id,revision)
   VALUES(rid,sid,eid,pv,fdv,1) ON CONFLICT DO NOTHING;
  INSERT INTO readiness_evaluation(id,school_id,readiness_id,enrollment_id,definition_version_id,dependency_revision,formal_status,evaluated_at,evaluated_by,explanation)
   VALUES(ev,sid,rid,eid,fdv,1,'Unverified','2026-01-05T09:00:00Z',actor,'MOCK source unavailable and current midterm failed; Final admission not satisfied') ON CONFLICT DO NOTHING;
  INSERT INTO readiness_requirement_result(id,school_id,evaluation_id,definition_version_id,requirement_id,status,explanation)
   VALUES(('b3100000-0000-0000-0000-'||x)::uuid,sid,ev,fdv,('a8100000-0000-0000-0000-'||x)::uuid,'Unverified','No verified current teaching minutes; unknown is not zero'),
    (('b3200000-0000-0000-0000-'||x)::uuid,sid,ev,fdv,('a8200000-0000-0000-0000-'||x)::uuid,'Incomplete','MOCK attempt 1 current version Annulled; attempt 2 Recorded/Failed; no eligible pass') ON CONFLICT DO NOTHING;
   
   
  INSERT INTO readiness_evidence_basis(id,school_id,evaluation_id,enrollment_id,result_version_id)
   VALUES(('b3300000-0000-0000-0000-'||x)::uuid,sid,ev,eid,rvf) ON CONFLICT DO NOTHING;
  INSERT INTO readiness_decision(id,school_id,readiness_id,evaluation_id,actor_id,decided_at,decision,reason,authority_basis,command_id,enrollment_id)
   VALUES(dec,sid,rid,ev,actor,'2026-01-05T09:10:00Z','NotApproved','MOCK source unverified and prerequisite not passed','MOCK-SOURCE/1 synthetic Assessor grant, not a legal qualification',('c1000000-0000-0000-0000-'||x)::uuid,eid) ON CONFLICT DO NOTHING;
  UPDATE assessment_readiness SET current_evaluation_id=ev,current_decision_id=dec,revision=2 WHERE id=rid AND school_id=sid AND current_evaluation_id IS NULL AND current_decision_id IS NULL AND revision=1;

  INSERT INTO training_evidence_snapshot(id,school_id,enrollment_id,program_version_id,kind,status,checklist_version_id,dependency_revision,prepared_by,prepared_at)
   VALUES(evidence,sid,eid,pv,'CompletionReport','Incomplete',('b1000000-0000-0000-0000-'||x)::uuid,1,actor,'2026-01-06T09:00:00Z') ON CONFLICT DO NOTHING;
  INSERT INTO training_evidence_item(id,school_id,snapshot_id,enrollment_id,result_version_id,observed_state,explanation)
   VALUES(('b9100000-0000-0000-0000-'||x)::uuid,sid,evidence,eid,rvf,'Failed','MOCK failed assessment blocks completion; no official document') ON CONFLICT DO NOTHING;
  INSERT INTO training_evidence_item(id,school_id,snapshot_id,enrollment_id,readiness_decision_id,observed_state,explanation)
   VALUES(('b9200000-0000-0000-0000-'||x)::uuid,sid,evidence,eid,dec,'NotApproved','MOCK Final readiness denied; no Final assessment authorized') ON CONFLICT DO NOTHING;
  INSERT INTO training_evidence_check(id,school_id,snapshot_id,enrollment_id,check_code,check_scope,evidence_item_id,field_code,outcome,explanation)
   VALUES(('b9300000-0000-0000-0000-'||x)::uuid,sid,evidence,eid,'MOCK-SOURCE-VERIFICATION','Snapshot',NULL,'*','Unverified','Synthetic source remains unavailable; no release'),
    (('b9400000-0000-0000-0000-'||x)::uuid,sid,evidence,eid,'MOCK-MIDTERM-PASSED','EvidenceItem',('b9100000-0000-0000-0000-'||x)::uuid,'outcome','Unsatisfied','Current mock result Failed; historical annulled Pass is not used'),
    (('b9500000-0000-0000-0000-'||x)::uuid,sid,evidence,eid,'MOCK-FINAL-READINESS','EvidenceItem',('b9200000-0000-0000-0000-'||x)::uuid,'decision','Unsatisfied','NotApproved; no completion or release') ON CONFLICT DO NOTHING;

  INSERT INTO learning_audit_event(id,school_id,actor_id,occurred_at,channel,action,target_type,target_id,target_version,outcome,correlation_id,reason,dependency_revision)
   VALUES(('af000000-0000-0000-0000-'||x)::uuid,sid,actor,'2026-01-01T00:00:00Z','System','LoadSyntheticMockSourceFixture','StudentTraining',eid,1,'DEMO_ONLY',('b0000000-0000-0000-0000-'||x)::uuid,'MOCK-SOURCE/1 draft facts, failed/annulled midterm, denied readiness and incomplete report; not actual legal or training evidence',1) ON CONFLICT DO NOTHING;
 END LOOP;
END $$;
