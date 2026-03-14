/**
 * Single bootstrap migration: creates the full ServePoint schema (users, cases, documents, log_entries).
 * Run this on an empty database after wiping app tables and the cfmigrations tracking table.
 * See RENDER_DATABASE.md for steps to reset the Render database.
 */
component {

    variables.datasource = "servepoint";

    function runSql( required string sql ) {
        queryExecute( arguments.sql, {}, { datasource: variables.datasource } );
    }

    function up( schema, qb ) {
        // users
        runSql( '
            CREATE TABLE IF NOT EXISTS users (
                user_id SERIAL PRIMARY KEY,
                "firstName" VARCHAR(255) NOT NULL,
                "lastName" VARCHAR(255) NOT NULL,
                email VARCHAR(255) NOT NULL,
                password VARCHAR(255) NOT NULL,
                role VARCHAR(255) NOT NULL,
                CONSTRAINT uq_users_email UNIQUE (email)
            )
        ' );

        // cases (includes archive columns)
        runSql( '
            CREATE TABLE IF NOT EXISTS cases (
                case_id SERIAL PRIMARY KEY,
                title VARCHAR(255) NOT NULL,
                description TEXT,
                status VARCHAR(255) NOT NULL,
                "dateCreated" TIMESTAMP NOT NULL,
                "dateUpdated" TIMESTAMP,
                creator_id INTEGER NOT NULL,
                assigned_to_id INTEGER,
                archived_at TIMESTAMP,
                archived_by INTEGER,
                archive_reason VARCHAR(255),
                CONSTRAINT fk_cases_creator FOREIGN KEY (creator_id) REFERENCES users(user_id),
                CONSTRAINT fk_cases_assigned_to FOREIGN KEY (assigned_to_id) REFERENCES users(user_id),
                CONSTRAINT fk_cases_archived_by FOREIGN KEY (archived_by) REFERENCES users(user_id)
            )
        ' );
        runSql( "CREATE INDEX IF NOT EXISTS idx_cases_status ON cases (status)" );
        runSql( "CREATE INDEX IF NOT EXISTS idx_cases_creator_id ON cases (creator_id)" );
        runSql( "CREATE INDEX IF NOT EXISTS idx_cases_assigned_to_id ON cases (assigned_to_id)" );
        runSql( "CREATE INDEX IF NOT EXISTS idx_cases_archived_at ON cases (archived_at)" );

        // documents
        runSql( '
            CREATE TABLE IF NOT EXISTS documents (
                document_id SERIAL PRIMARY KEY,
                title VARCHAR(255) NOT NULL,
                "fileName" VARCHAR(255) NOT NULL,
                "fileSize" NUMERIC(18,2) NOT NULL,
                "fileType" VARCHAR(255) NOT NULL,
                "dateUploaded" TIMESTAMP NOT NULL,
                case_id INTEGER NOT NULL,
                CONSTRAINT fk_documents_case FOREIGN KEY (case_id) REFERENCES cases(case_id)
            )
        ' );
        runSql( "CREATE INDEX IF NOT EXISTS idx_documents_case_id ON documents (case_id)" );

        // log_entries
        runSql( '
            CREATE TABLE IF NOT EXISTS log_entries (
                log_entry_id SERIAL PRIMARY KEY,
                "dateCreated" TIMESTAMP NOT NULL,
                "entryText" TEXT NOT NULL,
                type VARCHAR(255) NOT NULL,
                case_id INTEGER NOT NULL,
                user_id INTEGER NOT NULL,
                CONSTRAINT fk_log_entries_case FOREIGN KEY (case_id) REFERENCES cases(case_id),
                CONSTRAINT fk_log_entries_user FOREIGN KEY (user_id) REFERENCES users(user_id)
            )
        ' );
        runSql( "CREATE INDEX IF NOT EXISTS idx_log_entries_case_id ON log_entries (case_id)" );
        runSql( "CREATE INDEX IF NOT EXISTS idx_log_entries_user_id ON log_entries (user_id)" );
        runSql( "CREATE INDEX IF NOT EXISTS idx_log_entries_type ON log_entries (type)" );
    }

    function down( schema, qb ) {
        runSql( "DROP TABLE IF EXISTS log_entries CASCADE" );
        runSql( "DROP TABLE IF EXISTS documents CASCADE" );
        runSql( "DROP TABLE IF EXISTS cases CASCADE" );
        runSql( "DROP TABLE IF EXISTS users CASCADE" );
    }
}
