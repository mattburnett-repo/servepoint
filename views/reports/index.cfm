<cfoutput>
<div class="container py-4">
    <div class="d-flex flex-wrap align-items-center justify-content-between gap-2 mb-4">
        <h1 class="h2 mb-0 text-primary">
            <i class="bi bi-clipboard-data" aria-hidden="true"></i> Audit trails and reporting
        </h1>
        <a href="#event.buildLink( "main.index" )#" class="btn btn-outline-secondary">Home</a>
    </div>

    <p class="text-muted mb-4">
        Demo report generated from persisted <code>log_entries</code> data.
        This view is for application demonstration and is not certified compliance reporting.
    </p>

    <form method="get" action="#event.buildLink( "reports.index" )#" class="card shadow-sm mb-4">
        <div class="card-header bg-light">
            <h2 class="h6 mb-0">Filters</h2>
        </div>
        <div class="card-body row g-3">
            <div class="col-md-4">
                <label for="report-date-from" class="form-label">From date</label>
                <input
                    type="date"
                    id="report-date-from"
                    name="dateFrom"
                    class="form-control"
                    value="#encodeForHTMLAttribute( prc.filterDateFrom )#"
                >
            </div>
            <div class="col-md-4">
                <label for="report-date-to" class="form-label">To date</label>
                <input
                    type="date"
                    id="report-date-to"
                    name="dateTo"
                    class="form-control"
                    value="#encodeForHTMLAttribute( prc.filterDateTo )#"
                >
            </div>
            <div class="col-md-4 d-flex align-items-end">
                <div class="form-check">
                    <input
                        class="form-check-input"
                        type="checkbox"
                        value="1"
                        id="report-include-archived"
                        name="includeArchived"
                        <cfif prc.includeArchived>checked</cfif>
                    >
                    <label class="form-check-label" for="report-include-archived">
                        Include archived cases
                    </label>
                </div>
            </div>
        </div>
        <div class="card-footer bg-light d-flex gap-2">
            <button type="submit" class="btn btn-primary">Run report</button>
            <a href="#event.buildLink( "reports.index" )#" class="btn btn-outline-secondary">Clear</a>
        </div>
    </form>

    <div class="card shadow-sm">
        <div class="card-header bg-light d-flex justify-content-between align-items-center">
            <h2 class="h6 mb-0">Log entries by type</h2>
            <span class="small text-muted">#prc.auditTypeCounts.recordCount# row(s)</span>
        </div>
        <div class="card-body p-0">
            <cfif prc.auditTypeCounts.recordCount>
                <div class="table-responsive">
                    <table class="table table-striped mb-0">
                        <thead class="table-light">
                            <tr>
                                <th scope="col">Type</th>
                                <th scope="col">Count</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfloop query="prc.auditTypeCounts">
                                <tr>
                                    <td>#encodeForHTML( prc.auditTypeCounts.type )#</td>
                                    <td>#prc.auditTypeCounts.entry_count#</td>
                                </tr>
                            </cfloop>
                        </tbody>
                    </table>
                </div>
            <cfelse>
                <p class="p-3 text-muted mb-0">No log entries match the current filters.</p>
            </cfif>
        </div>
    </div>
</div>
</cfoutput>
