/**
 * Remove legacy log_entries table; audit history lives in audit_events.
 */
component {

    variables.datasource = "servepoint";

    private void function runSql( required string sql ) {
        queryExecute( arguments.sql, {}, { datasource: variables.datasource } );
    }

    public void function up( schema, qb ) {
        runSql( "DROP TABLE IF EXISTS log_entries CASCADE" );
    }

    public void function down( schema, qb ) {
        runSql( '
            CREATE TABLE IF NOT EXISTS log_entries (
                log_entry_id SERIAL PRIMARY KEY,
                date_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                entrytext VARCHAR(255) NOT NULL,
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
}
