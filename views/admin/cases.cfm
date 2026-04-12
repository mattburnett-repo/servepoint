<cfoutput>
<div class="container py-4 col-lg-11">
	<div class="d-flex flex-wrap align-items-center justify-content-between gap-2 mb-4">
		<h1 class="h2 mb-0 text-primary">
			<i class="bi bi-folder2-open" aria-hidden="true"></i> #encodeForHTML( prc.pageTitle )#
		</h1>
		<a href="#event.buildLink( 'admin.index' )#" class="btn btn-outline-secondary btn-sm">Admin home</a>
	</div>

	<cfif structKeyExists( prc, "noticeMessage" ) && len( trim( prc.noticeMessage ) )>
		<div class="alert alert-#structKeyExists( prc, 'noticeIsError' ) && prc.noticeIsError ? 'danger' : 'success'#" role="alert">
			#encodeForHTML( prc.noticeMessage )#
		</div>
	</cfif>

	<p class="text-muted small mb-3">All cases, including <strong>archived</strong>. Restore clears the archive flags so the case appears in normal workflows again.</p>

	<cfif !arrayLen( prc.cases )>
		<p class="lead text-muted">No cases in the system.</p>
	<cfelse>
		<div class="table-responsive shadow-sm rounded border bg-white">
			<table class="table table-hover table-sm align-middle mb-0">
				<thead class="table-light">
					<tr>
						<th scope="col">Title</th>
						<th scope="col">Status</th>
						<th scope="col">State</th>
						<th scope="col">Created</th>
						<th scope="col" class="text-end">Actions</th>
					</tr>
				</thead>
				<tbody>
					<cfloop array="#prc.cases#" index="cRow">
					<tr class="<cfif cRow.isArchived()>table-secondary</cfif>">
						<td>#encodeForHTML( cRow.getTitle() )#</td>
						<td>#encodeForHTML( cRow.getStatus() )#</td>
						<td>
							<cfif cRow.isArchived()>
								<span class="badge bg-secondary">Archived</span>
							<cfelse>
								<span class="badge bg-success">Active</span>
							</cfif>
						</td>
						<td>
							<cfif !isNull( cRow.getDateCreated() )>
								#dateTimeFormat( cRow.getDateCreated(), "yyyy-mm-dd HH:nn" )#
							</cfif>
						</td>
						<td class="text-end">
							<cfif !cRow.isArchived()>
								<a class="btn btn-outline-primary btn-sm" href="#event.buildLink( to = 'cases.view', queryString = 'id=' & cRow.getCaseId() )#">Open</a>
							<cfelse>
								<form method="post" action="#event.buildLink( 'admin.restoreArchivedCase' )#" class="d-inline">
									<input type="hidden" name="caseId" value="#cRow.getCaseId()#" />
									<button type="submit" class="btn btn-warning btn-sm">Restore</button>
								</form>
							</cfif>
						</td>
					</tr>
					</cfloop>
				</tbody>
			</table>
		</div>
	</cfif>
</div>
</cfoutput>
