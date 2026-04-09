/**
 * Recover rows where date_occurred was never set (legacy ORM insert omitted the column).
 * New writes set date_occurred explicitly in AuditLoggerService.
 */
component {

    variables.datasource = "servepoint";

    private void function runSql( required string sql ) {
        queryExecute( arguments.sql, {}, { datasource: variables.datasource } );
    }

    public void function up( schema, qb ) {
        runSql( "UPDATE audit_events SET date_occurred = CURRENT_TIMESTAMP WHERE date_occurred IS NULL" );
    }

    public void function down( schema, qb ) {
        // Irreversible data repair; no-op.
    }

}
