component extends="coldbox.system.EventHandler" {

    property name="reportsService" inject="ReportsService";

    /**
     * Audit/reporting entry point.
     */
    function index( event, rc, prc ) {
        if ( event.getHTTPMethod() != "GET" ) {
            relocate( "reports.index" );
            return;
        }

        var filterDateFrom = structKeyExists( rc, "dateFrom" ) ? trim( rc.dateFrom ) : "";
        var filterDateTo = structKeyExists( rc, "dateTo" ) ? trim( rc.dateTo ) : "";
        var includeArchived = structKeyExists( rc, "includeArchived" ) && (
            rc.includeArchived == "1" || rc.includeArchived == "true" || rc.includeArchived == "on"
        );

        prc.filterDateFrom = filterDateFrom;
        prc.filterDateTo = filterDateTo;
        prc.includeArchived = includeArchived;
        prc.auditTypeCounts = reportsService.getTypeCounts(
            dateFrom = filterDateFrom,
            dateTo = filterDateTo,
            includeArchived = includeArchived
        );

        event.setView( "reports/index" );
    }
}
