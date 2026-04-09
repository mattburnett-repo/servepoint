/**
 * Align deploy schema to the current local-dev schema snapshot.
 * Source: app.columns.txt + full.schema.sql
 */
component {

    variables.datasource = "servepoint";

    private void function runSql( required string sql ) {
        queryExecute( arguments.sql, {}, { datasource: variables.datasource } );
    }

    public void function up( schema, qb ) {
        // users: quoted camelCase -> unquoted lowercase
        runSql( '
            DO $$
            BEGIN
                IF EXISTS (
                    SELECT 1
                    FROM information_schema.columns
                    WHERE table_schema = ''public''
                      AND table_name   = ''users''
                      AND column_name  = ''firstName''
                ) THEN
                    ALTER TABLE users RENAME COLUMN "firstName" TO firstname;
                END IF;

                IF EXISTS (
                    SELECT 1
                    FROM information_schema.columns
                    WHERE table_schema = ''public''
                      AND table_name   = ''users''
                      AND column_name  = ''lastName''
                ) THEN
                    ALTER TABLE users RENAME COLUMN "lastName" TO lastname;
                END IF;
            END
            $$;
        ' );

        // documents: quoted camelCase -> lowercase
        runSql( '
            DO $$
            BEGIN
                IF EXISTS (
                    SELECT 1 FROM information_schema.columns
                    WHERE table_schema = ''public'' AND table_name = ''documents'' AND column_name = ''fileName''
                ) THEN
                    ALTER TABLE documents RENAME COLUMN "fileName" TO filename;
                END IF;

                IF EXISTS (
                    SELECT 1 FROM information_schema.columns
                    WHERE table_schema = ''public'' AND table_name = ''documents'' AND column_name = ''fileSize''
                ) THEN
                    ALTER TABLE documents RENAME COLUMN "fileSize" TO filesize;
                END IF;

                IF EXISTS (
                    SELECT 1 FROM information_schema.columns
                    WHERE table_schema = ''public'' AND table_name = ''documents'' AND column_name = ''fileType''
                ) THEN
                    ALTER TABLE documents RENAME COLUMN "fileType" TO filetype;
                END IF;
            END
            $$;
        ' );

        runSql( "ALTER TABLE documents ALTER COLUMN filesize TYPE double precision USING filesize::double precision" );

        // cases: data type/nullability/defaults from local snapshot
        runSql( "ALTER TABLE cases ALTER COLUMN description TYPE varchar(255) USING left(description::varchar,255)" );
        runSql( "ALTER TABLE cases ALTER COLUMN archived_at TYPE date USING archived_at::date" );
        runSql( "ALTER TABLE cases ALTER COLUMN date_created DROP NOT NULL" );
        runSql( "ALTER TABLE cases ALTER COLUMN date_updated DROP NOT NULL" );
        runSql( "ALTER TABLE cases ALTER COLUMN date_created SET DEFAULT CURRENT_TIMESTAMP" );
        runSql( "ALTER TABLE cases ALTER COLUMN date_updated SET DEFAULT CURRENT_TIMESTAMP" );

        // documents defaults + nullability from local snapshot
        runSql( "ALTER TABLE documents ALTER COLUMN date_uploaded DROP NOT NULL" );
        runSql( "ALTER TABLE documents ALTER COLUMN date_uploaded SET DEFAULT CURRENT_TIMESTAMP" );

        // communications defaults are absent in local snapshot
        runSql( "ALTER TABLE communications ALTER COLUMN date_created DROP DEFAULT" );
        runSql( "ALTER TABLE communications ALTER COLUMN date_updated DROP DEFAULT" );
    }

    public void function down( schema, qb ) {
        // restore communications defaults
        runSql( "ALTER TABLE communications ALTER COLUMN date_created SET DEFAULT CURRENT_TIMESTAMP" );
        runSql( "ALTER TABLE communications ALTER COLUMN date_updated SET DEFAULT CURRENT_TIMESTAMP" );

        // restore not-null constraints expected by existing migrations
        runSql( "ALTER TABLE documents ALTER COLUMN date_uploaded SET NOT NULL" );
        runSql( "ALTER TABLE cases ALTER COLUMN date_created SET NOT NULL" );

        // restore cases type/default shape from prior migrations
        runSql( "ALTER TABLE cases ALTER COLUMN date_updated DROP DEFAULT" );
        runSql( "ALTER TABLE cases ALTER COLUMN date_created DROP DEFAULT" );
        runSql( "ALTER TABLE cases ALTER COLUMN archived_at TYPE timestamp USING archived_at::timestamp" );
        runSql( "ALTER TABLE cases ALTER COLUMN description TYPE text" );

        // restore documents type and physical column names
        runSql( "ALTER TABLE documents ALTER COLUMN filesize TYPE numeric(18,2) USING filesize::numeric(18,2)" );
        runSql( '
            DO $$
            BEGIN
                IF EXISTS (
                    SELECT 1 FROM information_schema.columns
                    WHERE table_schema = ''public'' AND table_name = ''documents'' AND column_name = ''filename''
                ) THEN
                    ALTER TABLE documents RENAME COLUMN filename TO "fileName";
                END IF;

                IF EXISTS (
                    SELECT 1 FROM information_schema.columns
                    WHERE table_schema = ''public'' AND table_name = ''documents'' AND column_name = ''filesize''
                ) THEN
                    ALTER TABLE documents RENAME COLUMN filesize TO "fileSize";
                END IF;

                IF EXISTS (
                    SELECT 1 FROM information_schema.columns
                    WHERE table_schema = ''public'' AND table_name = ''documents'' AND column_name = ''filetype''
                ) THEN
                    ALTER TABLE documents RENAME COLUMN filetype TO "fileType";
                END IF;
            END
            $$;
        ' );

        // restore users physical column names
        runSql( '
            DO $$
            BEGIN
                IF EXISTS (
                    SELECT 1
                    FROM information_schema.columns
                    WHERE table_schema = ''public''
                      AND table_name   = ''users''
                      AND column_name  = ''firstname''
                ) THEN
                    ALTER TABLE users RENAME COLUMN firstname TO "firstName";
                END IF;

                IF EXISTS (
                    SELECT 1
                    FROM information_schema.columns
                    WHERE table_schema = ''public''
                      AND table_name   = ''users''
                      AND column_name  = ''lastname''
                ) THEN
                    ALTER TABLE users RENAME COLUMN lastname TO "lastName";
                END IF;
            END
            $$;
        ' );
    }
}
