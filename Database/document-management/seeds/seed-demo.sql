DO $demo$
DECLARE n integer; k integer; event_no integer; s uuid; actor uuid; enrollment uuid; student uuid; cmd uuid;
 templates uuid[]; versions uuid[]; files uuid[]; t uuid; v uuid; contract uuid; document uuid; dv uuid; signed_copy uuid;
 kind text; purpose text;
BEGIN
 IF current_setting('vairas.demo',true) IS DISTINCT FROM 'on' THEN RAISE EXCEPTION 'Set vairas.demo=on in a test/demo connection'; END IF;
 FOR n IN 1..2 LOOP
  s:=('10000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid;
  actor:=('30000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid;
  enrollment:=('50000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid;
  student:=('40000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid;
  cmd:=('d0000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid;
  IF EXISTS(SELECT 1 FROM operation_receipt WHERE command_id=cmd) THEN CONTINUE; END IF;
  templates:=ARRAY[('d1000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid,('d2000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid];
  versions:=ARRAY[('d3000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid,('d4000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid];
  contract:=('d6000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid;
  document:=('d7000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid;
  dv:=('d8000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid;
  signed_copy:=('d9000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid;
  INSERT INTO operation_receipt(command_id,school_id,actor_id,operation,request_digest,status,created_at)
  VALUES(cmd,s,actor,'SyntheticFixture',repeat('d',64),'Pending','2026-01-01T00:00:00Z');
  files:=ARRAY[]::uuid[];
  FOR k IN 1..7 LOOP
   files:=array_append(files,('d5000000-0000-0000-0000-'||lpad((100*n+k)::text,12,'0'))::uuid);
   purpose:=CASE WHEN k IN (1,2) THEN 'Template' WHEN k IN (3,5) THEN 'Rendered' WHEN k IN (4,6) THEN 'SourceBasis' ELSE 'SignedCopy' END;
   INSERT INTO file_object(file_id,school_id,storage_key,purpose,sha256,byte_length,media_type,scan_status,uploaded_by,uploaded_at)
   VALUES(files[k],s,'demo/nonexistent-school-'||n||'/object-'||k,purpose,repeat('a',64),10,'application/pdf','Pending',actor,'2026-01-01T00:00:00Z');
   UPDATE file_object SET scan_status='Clean' WHERE file_id=files[k];
  END LOOP;
  event_no:=0;
  FOR k IN 1..2 LOOP
   t:=templates[k];v:=versions[k];kind:=CASE WHEN k=1 THEN 'TrainingContract' ELSE 'PracticalJournal' END;
   INSERT INTO document_template(template_id,school_id,kind,name,revision) VALUES(t,s,kind,'Synthetic '||kind,1);
   event_no:=event_no+1;
   INSERT INTO state_event(event_id,school_id,template_id,action,sequence_no,from_state,to_state,actor_id,occurred_at,reason,command_id)
   VALUES(('df000000-0000-0000-0000-'||lpad((100*n+event_no)::text,12,'0'))::uuid,s,t,'TemplateCreated',1,NULL,'NoActiveVersion',actor,'2026-01-01T00:00:00Z','Synthetic fixture',cmd);
   INSERT INTO template_version(template_version_id,school_id,template_id,version_no,status,file_id,created_by,created_at)
   VALUES(v,s,t,1,'Draft',files[k],actor,'2026-01-01T00:00:00Z');
   PERFORM dm_activate_template(s,t,v,1);
   event_no:=event_no+1;
   INSERT INTO state_event(event_id,school_id,template_id,template_version_id,action,sequence_no,from_state,to_state,actor_id,occurred_at,reason,command_id)
   VALUES(('df000000-0000-0000-0000-'||lpad((100*n+event_no)::text,12,'0'))::uuid,s,t,v,'TemplateActivated',2,'NoActiveVersion','Active',actor,'2026-01-01T00:00:00Z','Synthetic fixture',cmd);
  END LOOP;
  INSERT INTO training_contract(contract_id,school_id,enrollment_id,student_id,template_version_id,generated_file_id,basis_file_id,basis_schema_version,status,generated_by,generated_at,revision)
  VALUES(contract,s,enrollment,student,versions[1],files[3],files[4],'demo-1','Generated',actor,'2026-01-01T00:00:00Z',1);
  event_no:=event_no+1;
  INSERT INTO state_event(event_id,school_id,contract_id,action,sequence_no,from_state,to_state,actor_id,occurred_at,reason,command_id)
  VALUES(('df000000-0000-0000-0000-'||lpad((100*n+event_no)::text,12,'0'))::uuid,s,contract,'ContractGenerated',1,NULL,'Generated',actor,'2026-01-01T00:00:00Z','Synthetic fixture',cmd);
  IF n=1 THEN
   INSERT INTO contract_signed_copy(signed_copy_id,school_id,contract_id,copy_no,file_id,is_current,declared_signed_at,recorded_at,recorded_by,basis)
   VALUES(signed_copy,s,contract,1,files[7],true,'2026-01-01T00:00:00Z','2026-01-01T00:01:00Z',actor,'Synthetic external copy; legal validity not verified');
   UPDATE training_contract SET status='Signed',revision=2 WHERE contract_id=contract;
   event_no:=event_no+1;
   INSERT INTO state_event(event_id,school_id,contract_id,signed_copy_id,action,sequence_no,from_state,to_state,actor_id,occurred_at,reason,command_id)
   VALUES(('df000000-0000-0000-0000-'||lpad((100*n+event_no)::text,12,'0'))::uuid,s,contract,signed_copy,'SignedCopyAttached',2,'Generated','Signed',actor,'2026-01-01T00:01:00Z','Synthetic fixture',cmd);
  END IF;
  INSERT INTO evidence_checkpoint(school_id,enrollment_id,dependency_revision,last_change_id,observed_at)
  VALUES(s,enrollment,5,('de000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid,'2026-01-01T00:00:00Z');
  INSERT INTO training_document(document_id,school_id,enrollment_id,kind,revision)
  VALUES(document,s,enrollment,'PracticalJournal',1);
  event_no:=event_no+1;
  INSERT INTO state_event(event_id,school_id,document_id,action,sequence_no,from_state,to_state,actor_id,occurred_at,reason,command_id)
  VALUES(('df000000-0000-0000-0000-'||lpad((100*n+event_no)::text,12,'0'))::uuid,s,document,'DocumentCreated',1,NULL,'Unselected',actor,'2026-01-01T00:00:00Z','Synthetic fixture',cmd);
  INSERT INTO document_version(document_version_id,school_id,document_id,enrollment_id,version_no,template_version_id,evidence_snapshot_id,dependency_revision,evidence_status,rendered_file_id,basis_file_id,basis_schema_version,renderer_version,state,revision,generated_by,generated_at)
  VALUES(dv,s,document,enrollment,1,versions[2],('db000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid,5,CASE WHEN n=1 THEN 'Ready' ELSE 'Incomplete' END,files[5],files[6],'demo-1','demo-1','Prepared',1,actor,'2026-01-01T00:00:00Z');
  event_no:=event_no+1;
  INSERT INTO state_event(event_id,school_id,document_version_id,action,sequence_no,from_state,to_state,actor_id,occurred_at,reason,command_id)
  VALUES(('df000000-0000-0000-0000-'||lpad((100*n+event_no)::text,12,'0'))::uuid,s,dv,'VersionPrepared',1,NULL,'Prepared',actor,'2026-01-01T00:00:00Z','Synthetic fixture',cmd);
  IF n=1 THEN
   UPDATE document_version SET state='PublishedReady',revision=2 WHERE document_version_id=dv;
   event_no:=event_no+1;
   INSERT INTO state_event(event_id,school_id,document_version_id,action,sequence_no,from_state,to_state,actor_id,occurred_at,reason,command_id)
   VALUES(('df000000-0000-0000-0000-'||lpad((100*n+event_no)::text,12,'0'))::uuid,s,dv,'VersionPublished',2,'Prepared','PublishedReady',actor,'2026-01-01T00:01:00Z','Synthetic fixture',cmd);
   UPDATE training_document SET current_version_id=dv,revision=2 WHERE document_id=document;
   event_no:=event_no+1;
   INSERT INTO state_event(event_id,school_id,document_id,action,sequence_no,from_state,to_state,actor_id,occurred_at,reason,command_id)
   VALUES(('df000000-0000-0000-0000-'||lpad((100*n+event_no)::text,12,'0'))::uuid,s,document,'CurrentVersionSelected',2,'Unselected',dv::text,actor,'2026-01-01T00:01:00Z','Synthetic fixture',cmd);
  END IF;
  UPDATE operation_receipt SET status='Succeeded',outcome_code='SYNTHETIC_DEMO',completed_at='2026-01-01T00:02:00Z' WHERE command_id=cmd;
 END LOOP;
END $demo$;
