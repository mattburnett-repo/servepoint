component extends="coldbox.system.EventHandler" {

    property name="reportsService" inject="ReportsService";
    property name="auditLoggerService" inject="AuditLoggerService";

    /**
     * Audit/reporting entry point.
     */
    function index( event, rc, prc ) {
        if ( event.getHTTPMethod() != "GET" ) {
            relocate( "reports.index" );
            return;
        }

        var reportFilters = getReportFilters( rc );
        var filterDateFrom = reportFilters.dateFrom;
        var filterDateTo = reportFilters.dateTo;
        var includeArchived = reportFilters.includeArchived;

        prc.filterDateFrom = filterDateFrom;
        prc.filterDateTo = filterDateTo;
        prc.includeArchived = includeArchived;
        prc.auditTypeCounts = reportsService.getTypeCounts(
            dateFrom = filterDateFrom,
            dateTo = filterDateTo,
            includeArchived = includeArchived
        );

        var actor = entityLoad( "Users", { email : "admin@example.com" }, true );
        if ( isNull( actor ) ) {
            var users = entityLoad( "Users" );
            if ( arrayLen( users ) ) {
                actor = users[ 1 ];
            }
        }
        auditLoggerService.record(
            category = "report",
            eventType = "Report View",
            outcome = "success",
            actorUserId = isNull( actor ) ? 0 : actor.getUserId(),
            message = "Audit report viewed (reports.index).",
            metadata = {
                dateFrom = filterDateFrom,
                dateTo = filterDateTo,
                includeArchived = includeArchived
            }
        );

        event.setView( "reports/index" );
    }

    /**
     * Audit/reporting detail by event type.
     */
    function byType( event, rc, prc ) {
        if ( event.getHTTPMethod() != "GET" ) {
            relocate( "reports.index" );
            return;
        }

        var eventType = structKeyExists( rc, "eventType" ) ? trim( rc.eventType ) : "";
        if ( !len( eventType ) ) {
            relocate( "reports.index" );
            return;
        }

        var reportFilters = getReportFilters( rc );
        var filterDateFrom = reportFilters.dateFrom;
        var filterDateTo = reportFilters.dateTo;
        var includeArchived = reportFilters.includeArchived;

        prc.selectedType = eventType;
        prc.filterDateFrom = filterDateFrom;
        prc.filterDateTo = filterDateTo;
        prc.includeArchived = includeArchived;
        prc.auditEvents = reportsService.getEventsByType(
            eventType = eventType,
            dateFrom = filterDateFrom,
            dateTo = filterDateTo,
            includeArchived = includeArchived
        );

        var actor = entityLoad( "Users", { email : "admin@example.com" }, true );
        if ( isNull( actor ) ) {
            var users = entityLoad( "Users" );
            if ( arrayLen( users ) ) {
                actor = users[ 1 ];
            }
        }
        auditLoggerService.record(
            category = "report",
            eventType = "Report View",
            outcome = "success",
            actorUserId = isNull( actor ) ? 0 : actor.getUserId(),
            message = "Audit report detail viewed (reports.byType).",
            metadata = {
                eventType = eventType,
                dateFrom = filterDateFrom,
                dateTo = filterDateTo,
                includeArchived = includeArchived
            }
        );

        event.setView( "reports/byType" );
    }

    private struct function getReportFilters( required struct rc ) {
        return {
            dateFrom = structKeyExists( arguments.rc, "dateFrom" ) ? trim( arguments.rc.dateFrom ) : "",
            dateTo = structKeyExists( arguments.rc, "dateTo" ) ? trim( arguments.rc.dateTo ) : "",
            includeArchived = structKeyExists( arguments.rc, "includeArchived" ) && (
                arguments.rc.includeArchived == "1" ||
                arguments.rc.includeArchived == "true" ||
                arguments.rc.includeArchived == "on"
            )
        };
    }
}
