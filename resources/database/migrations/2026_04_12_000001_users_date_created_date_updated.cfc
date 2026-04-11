/**
 * users: date_created / date_updated — same definition as communications (timestamp + update trigger).
 */
component {

    variables.datasource = "servepoint";

    private void function runSql( required string sql ) {
        queryExecute( arguments.sql, {}, { datasource: variables.datasource } );
    }

    public void function up( schema, qb ) {
        runSql( "ALTER TABLE users ADD COLUMN IF NOT EXISTS date_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP" );
        runSql( "ALTER TABLE users ADD COLUMN IF NOT EXISTS date_updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP" );

        runSql( '
            CREATE OR REPLACE FUNCTION users_set_date_updated()
            RETURNS TRIGGER AS $func$
            BEGIN
                NEW.date_updated := CURRENT_TIMESTAMP;
                RETURN NEW;
            END;
            $func$ LANGUAGE plpgsql
        ' );
        runSql( "DROP TRIGGER IF EXISTS tr_users_date_updated ON users" );
        runSql( '
            CREATE TRIGGER tr_users_date_updated
                BEFORE UPDATE ON users
                FOR EACH ROW
                EXECUTE FUNCTION users_set_date_updated()
        ' );
    }

    public void function down( schema, qb ) {
        runSql( "DROP TRIGGER IF EXISTS tr_users_date_updated ON users" );
        runSql( "DROP FUNCTION IF EXISTS users_set_date_updated()" );
        runSql( "ALTER TABLE users DROP COLUMN IF EXISTS date_updated" );
        runSql( "ALTER TABLE users DROP COLUMN IF EXISTS date_created" );
    }

}
