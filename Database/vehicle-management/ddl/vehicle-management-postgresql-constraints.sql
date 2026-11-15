CREATE UNIQUE INDEX vm_one_inprogress_per_vehicle
    ON maintenance (vehicle_id, school_id)
    WHERE status = 'InProgress'::vm_maintenance_status;
