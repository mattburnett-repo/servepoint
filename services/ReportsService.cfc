component singleton accessors="true" {

    /**
     * Aggregate audit report: count audit events by type.
     * Defaults to active cases only for case-scoped events.
     * @return query
     */
    public query function getTypeCounts(
        string dateFrom = "",
        string dateTo = "",
        boolean includeArchived = false
    ) {
        var sql = "
            SELECT
                ae.event_type AS type,
                COUNT(*) AS entry_count
            FROM audit_events ae
            LEFT JOIN cases c ON c.case_id = ae.case_id
            WHERE 1 = 1
        ";
        var params = {};

        if ( !arguments.includeArchived ) {
            sql &= " AND (ae.case_id IS NULL OR c.archived_at IS NULL)";
        }

        var normalizedFrom = parseFilterDate( arguments.dateFrom );
        if ( !isNull( normalizedFrom ) ) {
            sql &= " AND ae.date_occurred >= :dateFrom";
            // Bind as timestamp so PostgreSQL does not compare timestamp to varchar.
            params.dateFrom = {
                value      : normalizedFrom,
                cfsqltype  : "cf_sql_timestamp"
            };
        }

        var normalizedTo = parseFilterDate( arguments.dateTo );
        if ( !isNull( normalizedTo ) ) {
            // Inclusive end date by moving to the next day.
            sql &= " AND ae.date_occurred < :nextDay";
            params.nextDay = {
                value      : dateAdd( "d", 1, normalizedTo ),
                cfsqltype  : "cf_sql_timestamp"
            };
        }

        sql &= " GROUP BY ae.event_type ORDER BY ae.event_type ASC";

        return queryExecute( sql, params, { datasource : "servepoint" } );
    }

    /**
     * Detail audit report: list audit events for a specific type.
     * Defaults to active cases only for case-scoped events.
     * @return query
     */
    public query function getEventsByType(
        required string eventType,
        string dateFrom = "",
        string dateTo = "",
        boolean includeArchived = false
    ) {
        var sql = "
            SELECT
                ae.audit_event_id,
                to_char( ae.date_occurred, 'YYYY-MM-DD HH24:MI:SS' ) AS occurred_at_text,
                ae.event_type,
                ae.category,
                ae.outcome,
                ae.case_id,
                ae.user_id,
                ae.message
            FROM audit_events ae
            LEFT JOIN cases c ON c.case_id = ae.case_id
            WHERE ae.event_type = :eventType
        ";
        var params = {
            eventType = {
                value     : trim( arguments.eventType ),
                cfsqltype : "cf_sql_varchar"
            }
        };

        if ( !arguments.includeArchived ) {
            sql &= " AND (ae.case_id IS NULL OR c.archived_at IS NULL)";
        }

        var normalizedFrom = parseFilterDate( arguments.dateFrom );
        if ( !isNull( normalizedFrom ) ) {
            sql &= " AND ae.date_occurred >= :dateFrom";
            params.dateFrom = {
                value      : normalizedFrom,
                cfsqltype  : "cf_sql_timestamp"
            };
        }

        var normalizedTo = parseFilterDate( arguments.dateTo );
        if ( !isNull( normalizedTo ) ) {
            sql &= " AND ae.date_occurred < :nextDay";
            params.nextDay = {
                value      : dateAdd( "d", 1, normalizedTo ),
                cfsqltype  : "cf_sql_timestamp"
            };
        }

        sql &= " ORDER BY ae.date_occurred DESC";

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
