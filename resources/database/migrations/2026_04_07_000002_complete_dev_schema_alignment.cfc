/**
 * Enforce full column-level schema alignment to the current dev database shape
 * for users, cases, documents, log_entries, and communications.
 */
component {

    variables.datasource = "servepoint";

    private void function runSql( required string sql ) {
        queryExecute( arguments.sql, {}, { datasource: variables.datasource } );
    }

    public void function up( schema, qb ) {
        // users
        runSql( "ALTER TABLE users ALTER COLUMN firstname TYPE varchar(255)" );
        runSql( "ALTER TABLE users ALTER COLUMN lastname TYPE varchar(255)" );
        runSql( "ALTER TABLE users ALTER COLUMN email TYPE varchar(255)" );
        runSql( "ALTER TABLE users ALTER COLUMN password TYPE varchar(255)" );
        runSql( "ALTER TABLE users ALTER COLUMN role TYPE varchar(255)" );

        // cases
        runSql( "ALTER TABLE cases ALTER COLUMN title TYPE varchar(255)" );
        runSql( "ALTER TABLE cases ALTER COLUMN description TYPE varchar(255) USING left(description::varchar,255)" );
        runSql( "ALTER TABLE cases ALTER COLUMN status TYPE varchar(255)" );
        runSql( "ALTER TABLE cases ALTER COLUMN archive_reason TYPE varchar(255)" );
        runSql( "ALTER TABLE cases ALTER COLUMN archived_at TYPE date USING archived_at::date" );
        runSql( "ALTER TABLE cases ALTER COLUMN date_created TYPE timestamp without time zone" );
        runSql( "ALTER TABLE cases ALTER COLUMN date_updated TYPE timestamp without time zone" );
        runSql( "ALTER TABLE cases ALTER COLUMN date_created DROP NOT NULL" );
        runSql( "ALTER TABLE cases ALTER COLUMN date_updated DROP NOT NULL" );
        runSql( "ALTER TABLE cases ALTER COLUMN date_created SET DEFAULT CURRENT_TIMESTAMP" );
        runSql( "ALTER TABLE cases ALTER COLUMN date_updated SET DEFAULT CURRENT_TIMESTAMP" );

        // documents
        runSql( "ALTER TABLE documents ALTER COLUMN title TYPE varchar(255)" );
        runSql( "ALTER TABLE documents ALTER COLUMN filename TYPE varchar(255)" );
        runSql( "ALTER TABLE documents ALTER COLUMN filesize TYPE double precision USING filesize::double precision" );
        runSql( "ALTER TABLE documents ALTER COLUMN filetype TYPE varchar(255)" );
        runSql( "ALTER TABLE documents ALTER COLUMN date_uploaded TYPE timestamp without time zone" );
        runSql( "ALTER TABLE documents ALTER COLUMN date_uploaded DROP NOT NULL" );
        runSql( "ALTER TABLE documents ALTER COLUMN date_uploaded SET DEFAULT CURRENT_TIMESTAMP" );

        // log_entries
        runSql( "ALTER TABLE log_entries ALTER COLUMN entrytext TYPE varchar(255) USING left(entrytext::varchar,255)" );
        runSql( "ALTER TABLE log_entries ALTER COLUMN type TYPE varchar(255)" );
        runSql( "ALTER TABLE log_entries ALTER COLUMN date_created TYPE timestamp without time zone" );
        runSql( "ALTER TABLE log_entries ALTER COLUMN date_created DROP NOT NULL" );
        runSql( "ALTER TABLE log_entries ALTER COLUMN date_created SET DEFAULT CURRENT_TIMESTAMP" );

        // communications
        runSql( "ALTER TABLE communications ALTER COLUMN message TYPE varchar(255) USING left(message::varchar,255)" );
        runSql( "ALTER TABLE communications ALTER COLUMN type TYPE varchar(255)" );
        runSql( "ALTER TABLE communications ALTER COLUMN date_created TYPE timestamp without time zone" );
        runSql( "ALTER TABLE communications ALTER COLUMN date_updated TYPE timestamp without time zone" );
        runSql( "ALTER TABLE communications ALTER COLUMN date_created SET NOT NULL" );
        runSql( "ALTER TABLE communications ALTER COLUMN date_updated SET NOT NULL" );
        runSql( "ALTER TABLE communications ALTER COLUMN date_created DROP DEFAULT" );
        runSql( "ALTER TABLE communications ALTER COLUMN date_updated DROP DEFAULT" );
    }

    public void function down( schema, qb ) {
        // Keep down conservative: revert only columns that this migration may have changed
        // in a way that differs from prior migration intent.
        runSql( "ALTER TABLE communications ALTER COLUMN message TYPE text" );
        runSql( "ALTER TABLE communications ALTER COLUMN date_created SET DEFAULT CURRENT_TIMESTAMP" );
        runSql( "ALTER TABLE communications ALTER COLUMN date_updated SET DEFAULT CURRENT_TIMESTAMP" );

        runSql( "ALTER TABLE log_entries ALTER COLUMN entrytext TYPE text" );
        runSql( "ALTER TABLE log_entries ALTER COLUMN date_created SET NOT NULL" );

        runSql( "ALTER TABLE documents ALTER COLUMN filesize TYPE numeric(18,2) USING filesize::numeric(18,2)" );
        runSql( "ALTER TABLE documents ALTER COLUMN date_uploaded SET NOT NULL" );

        runSql( "ALTER TABLE cases ALTER COLUMN description TYPE text" );
        runSql( "ALTER TABLE cases ALTER COLUMN archived_at TYPE timestamp USING archived_at::timestamp" );
        runSql( "ALTER TABLE cases ALTER COLUMN date_created SET NOT NULL" );
        runSql( "ALTER TABLE cases ALTER COLUMN date_created DROP DEFAULT" );
        runSql( "ALTER TABLE cases ALTER COLUMN date_updated DROP DEFAULT" );
    }
}
