START TRANSACTION;
ALTER TABLE reservation_claim DROP CONSTRAINT IF EXISTS active_resource_no_overlap; ALTER TABLE scheduling_request DROP CONSTRAINT IF EXISTS request_single_school;

ALTER TABLE candidate_lesson DROP CONSTRAINT "FK_candidate_lesson_recurring_lesson_series_series_id";

ALTER TABLE lesson DROP CONSTRAINT "FK_lesson_recurring_lesson_series_series_id_school_id_kind";

ALTER TABLE candidate_lesson DROP CONSTRAINT "FK_candidate_lesson_scheduling_request_request_id_request_revi~";

ALTER TABLE scheduling_operation DROP CONSTRAINT "FK_scheduling_operation_scheduling_request_request_id_request_~";

DROP TABLE candidate_lesson_participant;

DROP TABLE lesson_change;

DROP TABLE lesson_participant;

DROP TABLE reservation_claim;

DROP TABLE scheduling_operation_rule;

DROP TABLE scheduling_request_enrollment;

DROP TABLE scheduling_request_group;

DROP TABLE scheduling_request_resource;

DROP TABLE scheduling_request_rule;

DROP TABLE scheduling_request_window;

DROP TABLE scheduling_rule_version;

DROP TABLE recurring_lesson_series;

DROP TABLE scheduling_request;

DROP TABLE scheduling_operation;

DROP TABLE assessment_appointment;

DROP TABLE lesson;

DROP TABLE candidate_lesson;

DROP TYPE request_status,lesson_kind,lesson_status,operation_status,reservation_status,recurrence_frequency;

DELETE FROM "__EFMigrationsHistory"
WHERE "MigrationId" = '20261115192213_InitialScheduling';

COMMIT;
