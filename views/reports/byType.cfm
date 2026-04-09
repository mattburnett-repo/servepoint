<cfoutput>
<div class="container py-4">
    <cfset backQueryString = "dateFrom=" & urlEncodedFormat( prc.filterDateFrom ) & "&dateTo=" & urlEncodedFormat( prc.filterDateTo )>
    <cfif prc.includeArchived>
        <cfset backQueryString &= "&includeArchived=1">
    </cfif>
    <div class="d-flex flex-wrap align-items-center justify-content-between gap-2 mb-4">
        <h1 class="h2 mb-0 text-primary">
            <i class="bi bi-list-check" aria-hidden="true"></i> Audit events for #encodeForHTML( prc.selectedType )#
        </h1>
        <a
            href="#event.buildLink( to = "reports.index", queryString = backQueryString )#"
            class="btn btn-outline-secondary"
        >
            Back to summary
        </a>
    </div>

    <p class="text-muted mb-4">
        Showing #prc.auditEvents.recordCount# event(s) of type <code>#encodeForHTML( prc.selectedType )#</code>.
    </p>

    <div class="card shadow-sm">
        <div class="card-header bg-light">
            <h2 class="h6 mb-0">Event details</h2>
        </div>
        <div class="card-body p-0">
            <cfif prc.auditEvents.recordCount>
                <div class="table-responsive">
                    <table class="table table-striped mb-0">
                        <thead class="table-light">
                            <tr>
                                <th scope="col"><abbr title="When this event was recorded (application server time, stored in audit_events.date_occurred)">When recorded</abbr></th>
                                <th scope="col">Category</th>
                                <th scope="col">Outcome</th>
                                <th scope="col">Case ID</th>
                                <th scope="col">User ID</th>
                                <th scope="col">Message</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfloop query="prc.auditEvents">
                                <cfset occurredRaw = trim( toString( occurred_at_text ) )>
                                <tr>
                                    <td>
                                        <cfif !len( occurredRaw )>
                                            <span class="text-muted">—</span>
                                        <cfelse>
                                            <time datetime="#replace( occurredRaw, ' ', 'T', 'one' )#">#encodeForHTML( occurredRaw )#</time>
                                        </cfif>
                                    </td>
                                    <td>#encodeForHTML( category )#</td>
                                    <td>#encodeForHTML( outcome )#</td>
                                    <td><cfif isNull( case_id )>-<cfelse>#case_id#</cfif></td>
                                    <td><cfif isNull( user_id )>-<cfelse>#user_id#</cfif></td>
                                    <td>#encodeForHTML( message )#</td>
                                </tr>
                            </cfloop>
                        </tbody>
                    </table>
                </div>
            <cfelse>
                <p class="p-3 text-muted mb-0">No events match this type and filter combination.</p>
            </cfif>
        </div>
    </div>
</div>
</cfoutput>
