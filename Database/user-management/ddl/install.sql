\set ON_ERROR_STOP on
BEGIN;
\ir 001-initial.sql
\ir 002-outbox.sql
COMMIT;
