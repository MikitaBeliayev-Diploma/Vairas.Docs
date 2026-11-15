DO $demo$
DECLARE t int; s uuid; b uuid; v uuid; teacher uuid; actor uuid; membership uuid;
        m uuid; op uuid; suffix text;
BEGIN
 IF current_setting('vairas.demo',true) IS DISTINCT FROM 'on' THEN
   RAISE EXCEPTION 'Demo seed requires SET vairas.demo = on';
 END IF;
 FOR t IN 1..2 LOOP
  suffix := lpad(t::text,12,'0');
  s := ('10000000-0000-0000-0000-'||suffix)::uuid;
  b := ('60000000-0000-0000-0000-'||suffix)::uuid;
  v := ('80000000-0000-0000-0000-'||suffix)::uuid;
  teacher := ('70000000-0000-0000-0000-'||suffix)::uuid;
  actor := ('30000000-0000-0000-0000-'||suffix)::uuid;
  membership := ('82000000-0000-0000-0000-'||suffix)::uuid;
  m := ('81000000-0000-0000-0000-'||suffix)::uuid;
   
  IF EXISTS (SELECT 1 FROM vehicle WHERE vehicle_id=v) THEN CONTINUE; END IF;
  INSERT INTO vehicle(vehicle_id,school_id,branch_id,registration_country_code,
   registration_number,manufacturer,model,manufacture_year,transmission,status,
   revision,created_at,updated_at)
  VALUES(v,s,b,'LT','DEMO-'||t,'Synthetic','Training vehicle '||t,2025,'Manual',
   'Inactive',1,'2029-01-01 08:00Z','2029-01-01 08:00Z');
  INSERT INTO vehicle_supported_category VALUES(v,s,'B');
  INSERT INTO vehicle_operation(operation_id,school_id,vehicle_id,actor_user_id,
   channel,command_name,request_fingerprint,resulting_vehicle_revision,recorded_at)
  VALUES(('8a000000-0000-0000-0000-'||suffix)::uuid,s,v,actor,'Web','AddVehicle',
   repeat('a',64),1,'2029-01-01 08:00Z');
  INSERT INTO vehicle_teacher_assignment VALUES(v,s,teacher,membership,'2029-01-01 08:01Z');
  UPDATE vehicle SET revision=2,updated_at='2029-01-01 08:01Z' WHERE vehicle_id=v;
  INSERT INTO vehicle_operation(operation_id,school_id,vehicle_id,actor_user_id,
   channel,command_name,request_fingerprint,expected_vehicle_revision,
   resulting_vehicle_revision,recorded_at)
  VALUES(('8b000000-0000-0000-0000-'||suffix)::uuid,s,v,actor,'Web','AssignInstructor',
   repeat('b',64),1,2,'2029-01-01 08:01Z');
  UPDATE vehicle SET status='Active',revision=3,updated_at='2029-01-01 08:02Z' WHERE vehicle_id=v;
  INSERT INTO vehicle_operation(operation_id,school_id,vehicle_id,actor_user_id,
   channel,command_name,request_fingerprint,expected_vehicle_revision,
   resulting_vehicle_revision,recorded_at)
  VALUES(('8c000000-0000-0000-0000-'||suffix)::uuid,s,v,actor,'Web','ActivateVehicle',
   repeat('c',64),2,3,'2029-01-01 08:02Z');
  INSERT INTO maintenance(maintenance_id,school_id,vehicle_id,type,scheduled_at,
   status,comment,revision,created_at,updated_at)
  VALUES(m,s,v,'Inspection','2030-01-08 08:00Z','Scheduled',
   'Synthetic planned inspection; not statutory certification.',1,
   '2029-01-01 08:03Z','2029-01-01 08:03Z');
  INSERT INTO vehicle_operation(operation_id,school_id,vehicle_id,maintenance_id,
   actor_user_id,channel,command_name,request_fingerprint,expected_vehicle_revision,
   resulting_vehicle_revision,resulting_maintenance_revision,recorded_at)
  VALUES(('8d000000-0000-0000-0000-'||suffix)::uuid,s,v,m,actor,'Web','ScheduleMaintenance',
   repeat('d',64),3,3,1,'2029-01-01 08:03Z');
  IF t=2 THEN
   UPDATE maintenance SET status='Cancelled',cancelled_at='2029-01-01 08:04Z',
    revision=2,updated_at='2029-01-01 08:04Z' WHERE maintenance_id=m;
   INSERT INTO vehicle_operation(operation_id,school_id,vehicle_id,maintenance_id,
    actor_user_id,channel,command_name,request_fingerprint,expected_vehicle_revision,
    expected_maintenance_revision,resulting_vehicle_revision,
    resulting_maintenance_revision,recorded_at)
   VALUES(('8e000000-0000-0000-0000-'||suffix)::uuid,s,v,m,actor,'Web','CancelMaintenance',
    repeat('e',64),3,1,3,2,'2029-01-01 08:04Z');
  END IF;
 END LOOP;
END $demo$;
