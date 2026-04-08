component singleton accessors="true" {

    /**
     * Aggregate audit report: count log entries by type.
     * Defaults to active cases only.
     * @return query
     */
    public query function getTypeCounts(
        string dateFrom = "",
        string dateTo = "",
        boolean includeArchived = false
    ) {
        var sql = "
            SELECT
                le.type,
                COUNT(*) AS entry_count
            FROM log_entries le
            INNER JOIN cases c ON c.case_id = le.case_id
            WHERE 1 = 1
        ";
        var params = {};

        if ( !arguments.includeArchived ) {
            sql &= " AND c.archived_at IS NULL";
        }

        var normalizedFrom = parseFilterDate( arguments.dateFrom );
        if ( !isNull( normalizedFrom ) ) {
            sql &= " AND le.date_created >= :dateFrom";
            // Bind as timestamp so PostgreSQL does not compare timestamp to varchar.
            params.dateFrom = {
                value      : normalizedFrom,
                cfsqltype  : "cf_sql_timestamp"
            };
        }

        var normalizedTo = parseFilterDate( arguments.dateTo );
        if ( !isNull( normalizedTo ) ) {
            // Inclusive end date by moving to the next day.
            sql &= " AND le.date_created < :nextDay";
            params.nextDay = {
                value      : dateAdd( "d", 1, normalizedTo ),
                cfsqltype  : "cf_sql_timestamp"
            };
        }

        sql &= " GROUP BY le.type ORDER BY le.type ASC";

        return queryExecute( sql, params, { datasource : "servepoint" } );
    }

    private any function parseFilterDate( required string rawValue ) {
        var trimmed = trim( arguments.rawValue );
        if ( !len( trimmed ) || !isValid( "date", trimmed ) ) {
            return;
        }
        var parsed = parseDateTime( trimmed );
        return createDate( year( parsed ), month( parsed ), day( parsed ) );
    }
}
