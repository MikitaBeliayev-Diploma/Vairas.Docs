\set ON_ERROR_STOP on
BEGIN;
\ir schema.sql
\ir postgresql-constraints.sql
COMMIT;
