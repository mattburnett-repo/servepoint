/**
 * Staff communications: case-scoped messages (separate from log_entries / activity).
 */
component {

    variables.datasource = "servepoint";

    function runSql( required string sql ) {
        queryExecute( arguments.sql, {}, { datasource: variables.datasource } );
    }

    function up( schema, qb ) {
        runSql( '
            CREATE TABLE IF NOT EXISTS communications (
                communication_id SERIAL PRIMARY KEY,
                date_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                date_updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                message TEXT NOT NULL,
                type VARCHAR(255) NOT NULL,
                case_id INTEGER NOT NULL,
                user_id INTEGER NOT NULL,
                updated_by INTEGER NULL,
                CONSTRAINT fk_communications_case FOREIGN KEY (case_id) REFERENCES cases(case_id),
                CONSTRAINT fk_communications_user FOREIGN KEY (user_id) REFERENCES users(user_id),
                CONSTRAINT fk_communications_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
            )
        ' );
        runSql( "CREATE INDEX IF NOT EXISTS idx_communications_case_id ON communications (case_id)" );
        runSql( "CREATE INDEX IF NOT EXISTS idx_communications_user_id ON communications (user_id)" );
        runSql( "CREATE INDEX IF NOT EXISTS idx_communications_type ON communications (type)" );

        runSql( '
            CREATE OR REPLACE FUNCTION communications_set_date_updated()
            RETURNS TRIGGER AS $func$
            BEGIN
                NEW.date_updated := CURRENT_TIMESTAMP;
                RETURN NEW;
            END;
            $func$ LANGUAGE plpgsql
        ' );
        runSql( "DROP TRIGGER IF EXISTS tr_communications_date_updated ON communications" );
        runSql( '
            CREATE TRIGGER tr_communications_date_updated
                BEFORE UPDATE ON communications
                FOR EACH ROW
                EXECUTE FUNCTION communications_set_date_updated()
        ' );
    }

    function down( schema, qb ) {
        runSql( "DROP TRIGGER IF EXISTS tr_communications_date_updated ON communications" );
        runSql( "DROP FUNCTION IF EXISTS communications_set_date_updated()" );
        runSql( "DROP TABLE IF EXISTS communications CASCADE" );
    }

}
