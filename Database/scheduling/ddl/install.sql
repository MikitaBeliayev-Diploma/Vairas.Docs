\set ON_ERROR_STOP on
-- Empty database only. Administrator provisions roles and public schema ownership first.
\ir initial.sql
\ir 002-actual-interval.sql
INSERT INTO "__EFMigrationsHistory" ("MigrationId","ProductVersion")
VALUES ('20261122000000_ActualInterval','10.0.15');
\ir 003-reliability.sql
