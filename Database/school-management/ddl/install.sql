\set ON_ERROR_STOP on
BEGIN;
\ir 001-initial.sql
\ir school-management-postgresql-constraints.sql
COMMIT;
