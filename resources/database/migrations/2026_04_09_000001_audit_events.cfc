/**
 * Dedicated audit events store for structured application/security auditing.
 */
component {

    variables.datasource = "servepoint";

    private void function runSql( required string sql ) {
        queryExecute( arguments.sql, {}, { datasource: variables.datasource } );
    }

    public void function up( schema, qb ) {
        runSql( '
            CREATE TABLE IF NOT EXISTS audit_events (
                audit_event_id SERIAL PRIMARY KEY,
                date_occurred TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                request_id VARCHAR(64) NULL,
                category VARCHAR(64) NOT NULL,
                event_type VARCHAR(128) NOT NULL,
                outcome VARCHAR(32) NOT NULL,
                reason_code VARCHAR(128) NULL,
                message VARCHAR(500) NOT NULL,
                metadata_json TEXT NULL,
                case_id INTEGER NULL,
                document_id INTEGER NULL,
                user_id INTEGER NULL,
                CONSTRAINT fk_audit_events_case FOREIGN KEY (case_id) REFERENCES cases(case_id),
                CONSTRAINT fk_audit_events_document FOREIGN KEY (document_id) REFERENCES documents(document_id),
                CONSTRAINT fk_audit_events_user FOREIGN KEY (user_id) REFERENCES users(user_id)
            )
        ' );

        runSql( "CREATE INDEX IF NOT EXISTS idx_audit_events_date_occurred ON audit_events (date_occurred)" );
        runSql( "CREATE INDEX IF NOT EXISTS idx_audit_events_category_event_type ON audit_events (category, event_type)" );
        runSql( "CREATE INDEX IF NOT EXISTS idx_audit_events_user_id ON audit_events (user_id)" );
        runSql( "CREATE INDEX IF NOT EXISTS idx_audit_events_case_id ON audit_events (case_id)" );
        runSql( "CREATE INDEX IF NOT EXISTS idx_audit_events_document_id ON audit_events (document_id)" );
    }

    public void function down( schema, qb ) {
        runSql( "DROP TABLE IF EXISTS audit_events CASCADE" );
    }
}
