/**
 * Timestamps: DB defaults + cases row update time. Physical columns are snake_case (date_created, …)
 * so Postgres/Hibernate agree. Renames legacy camelCase/lowercase names if present.
 */
component {

    variables.datasource = "servepoint";

    function runSql( required string sql ) {
        queryExecute( arguments.sql, {}, { datasource: variables.datasource } );
    }

    function up( schema, qb ) {
        runSql( '
            DO $normalize$
            BEGIN
                IF EXISTS (
                    SELECT 1 FROM pg_attribute a
                    JOIN pg_class c ON c.oid = a.attrelid
                    JOIN pg_namespace n ON n.oid = c.relnamespace
                    WHERE n.nspname = ''public'' AND c.relname = ''cases''
                      AND a.attname = ''datecreated'' AND a.attnum > 0 AND NOT a.attisdropped
                ) THEN
                    ALTER TABLE cases RENAME COLUMN datecreated TO date_created;
                ELSIF EXISTS (
                    SELECT 1 FROM pg_attribute a
                    JOIN pg_class c ON c.oid = a.attrelid
                    JOIN pg_namespace n ON n.oid = c.relnamespace
                    WHERE n.nspname = ''public'' AND c.relname = ''cases''
                      AND a.attname = ''dateCreated'' AND a.attnum > 0 AND NOT a.attisdropped
                ) THEN
                    ALTER TABLE cases RENAME COLUMN "dateCreated" TO date_created;
                END IF;

                IF EXISTS (
                    SELECT 1 FROM pg_attribute a
                    JOIN pg_class c ON c.oid = a.attrelid
                    JOIN pg_namespace n ON n.oid = c.relnamespace
                    WHERE n.nspname = ''public'' AND c.relname = ''cases''
                      AND a.attname = ''dateupdated'' AND a.attnum > 0 AND NOT a.attisdropped
                ) THEN
                    ALTER TABLE cases RENAME COLUMN dateupdated TO date_updated;
                ELSIF EXISTS (
                    SELECT 1 FROM pg_attribute a
                    JOIN pg_class c ON c.oid = a.attrelid
                    JOIN pg_namespace n ON n.oid = c.relnamespace
                    WHERE n.nspname = ''public'' AND c.relname = ''cases''
                      AND a.attname = ''dateUpdated'' AND a.attnum > 0 AND NOT a.attisdropped
                ) THEN
                    ALTER TABLE cases RENAME COLUMN "dateUpdated" TO date_updated;
                END IF;

                IF EXISTS (
                    SELECT 1 FROM pg_attribute a
                    JOIN pg_class c ON c.oid = a.attrelid
                    JOIN pg_namespace n ON n.oid = c.relnamespace
                    WHERE n.nspname = ''public'' AND c.relname = ''documents''
                      AND a.attname = ''dateuploaded'' AND a.attnum > 0 AND NOT a.attisdropped
                ) THEN
                    ALTER TABLE documents RENAME COLUMN dateuploaded TO date_uploaded;
                ELSIF EXISTS (
                    SELECT 1 FROM pg_attribute a
                    JOIN pg_class c ON c.oid = a.attrelid
                    JOIN pg_namespace n ON n.oid = c.relnamespace
                    WHERE n.nspname = ''public'' AND c.relname = ''documents''
                      AND a.attname = ''dateUploaded'' AND a.attnum > 0 AND NOT a.attisdropped
                ) THEN
                    ALTER TABLE documents RENAME COLUMN "dateUploaded" TO date_uploaded;
                END IF;

                IF EXISTS (
                    SELECT 1 FROM pg_attribute a
                    JOIN pg_class c ON c.oid = a.attrelid
                    JOIN pg_namespace n ON n.oid = c.relnamespace
                    WHERE n.nspname = ''public'' AND c.relname = ''log_entries''
                      AND a.attname = ''datecreated'' AND a.attnum > 0 AND NOT a.attisdropped
                ) THEN
                    ALTER TABLE log_entries RENAME COLUMN datecreated TO date_created;
                ELSIF EXISTS (
                    SELECT 1 FROM pg_attribute a
                    JOIN pg_class c ON c.oid = a.attrelid
                    JOIN pg_namespace n ON n.oid = c.relnamespace
                    WHERE n.nspname = ''public'' AND c.relname = ''log_entries''
                      AND a.attname = ''dateCreated'' AND a.attnum > 0 AND NOT a.attisdropped
                ) THEN
                    ALTER TABLE log_entries RENAME COLUMN "dateCreated" TO date_created;
                END IF;
            END
            $normalize$ LANGUAGE plpgsql
        ' );

        runSql( "ALTER TABLE cases ALTER COLUMN date_created SET DEFAULT CURRENT_TIMESTAMP" );
        runSql( "ALTER TABLE cases ALTER COLUMN date_updated SET DEFAULT CURRENT_TIMESTAMP" );
        runSql( "ALTER TABLE documents ALTER COLUMN date_uploaded SET DEFAULT CURRENT_TIMESTAMP" );
        runSql( "ALTER TABLE log_entries ALTER COLUMN date_created SET DEFAULT CURRENT_TIMESTAMP" );

        runSql( '
            CREATE OR REPLACE FUNCTION cases_set_date_updated()
            RETURNS TRIGGER AS $func$
            BEGIN
                NEW.date_updated := CURRENT_TIMESTAMP;
                RETURN NEW;
            END;
            $func$ LANGUAGE plpgsql
        ' );
        runSql( "DROP TRIGGER IF EXISTS tr_cases_date_updated ON cases" );
        runSql( '
            CREATE TRIGGER tr_cases_date_updated
                BEFORE UPDATE ON cases
                FOR EACH ROW
                EXECUTE FUNCTION cases_set_date_updated()
        ' );
    }

    function down( schema, qb ) {
        runSql( "DROP TRIGGER IF EXISTS tr_cases_date_updated ON cases" );
        runSql( "DROP FUNCTION IF EXISTS cases_set_date_updated()" );
        runSql( "ALTER TABLE cases ALTER COLUMN date_created DROP DEFAULT" );
        runSql( "ALTER TABLE cases ALTER COLUMN date_updated DROP DEFAULT" );
        runSql( "ALTER TABLE documents ALTER COLUMN date_uploaded DROP DEFAULT" );
        runSql( "ALTER TABLE log_entries ALTER COLUMN date_created DROP DEFAULT" );
    }
}
