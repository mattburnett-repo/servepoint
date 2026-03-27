<cfoutput>
<div class="container py-4">
	<div class="d-flex flex-wrap align-items-center justify-content-between gap-2 mb-4">
		<div class="d-flex flex-wrap align-items-center gap-2 gap-md-3">
			<h1 class="h2 mb-0 text-primary">
				<i class="bi bi-folder2-open" aria-hidden="true"></i> Cases
			</h1>
			<a href="#event.buildLink( "main.index" )#" class="btn btn-outline-secondary">
				<i class="bi bi-house" aria-hidden="true"></i> Home
			</a>
		</div>
		<a href="#event.buildLink( "cases.new" )#" class="btn btn-primary">
			<i class="bi bi-plus-circle" aria-hidden="true"></i> New case
		</a>
	</div>

	<cfif structKeyExists( prc, "noticeMessage" ) && len( trim( prc.noticeMessage ) )>
		<div class="alert alert-success" role="alert">
			#encodeForHTML( prc.noticeMessage )#
		</div>
	</cfif>

	<cfif !arrayLen( prc.cases )>
		<p class="lead text-muted">No active cases yet. Create one to get started.</p>
		<a href="#event.buildLink( "cases.new" )#" class="btn btn-outline-primary">New case</a>
	<cfelse>
		<div class="table-responsive shadow-sm rounded">
			<table class="table table-hover table-striped mb-0 align-middle">
				<thead class="table-light">
					<tr>
						<th scope="col">Title</th>
						<th scope="col">Status</th>
						<th scope="col">Created</th>
						<th scope="col">Creator</th>
						<th scope="col">Assigned to</th>
						<th scope="col" class="text-end">Actions</th>
					</tr>
				</thead>
				<tbody>
					<cfloop array="#prc.cases#" index="c">
						<tr>
							<td>
								<a href="#event.buildLink( to = "cases.view", queryString = "id=#c.getCaseId()#" )#">#encodeForHTML( c.getTitle() )#</a>
							</td>
							<td><span class="badge bg-secondary">#encodeForHTML( c.getStatus() )#</span></td>
							<td><time datetime="#dateFormat( c.getDateCreated(), "yyyy-mm-dd" )#T#timeFormat( c.getDateCreated(), "HH:mm:ss" )#">#dateFormat( c.getDateCreated(), "medium" )#</time></td>
							<td>
								<cfif !isNull( c.getCreator() )>
									#encodeForHTML( c.getCreator().getFirstName() & " " & c.getCreator().getLastName() )#
								</cfif>
							</td>
							<td>
								<cfif !isNull( c.getAssignedTo() )>
									#encodeForHTML( c.getAssignedTo().getFirstName() & " " & c.getAssignedTo().getLastName() )#
								<cfelse>
									<span class="text-muted">&mdash;</span>
								</cfif>
							</td>
							<td class="text-end text-nowrap">
								<a href="#event.buildLink( to = "cases.view", queryString = "id=#c.getCaseId()#" )#" class="btn btn-sm btn-outline-primary">Edit</a>
								<form method="post" action="#event.buildLink( "cases.archive" )#" class="d-inline" onsubmit="return confirm('Archive this case? It will be removed from the active list.');">
									<input type="hidden" name="id" value="#c.getCaseId()#">
									<button type="submit" class="btn btn-sm btn-outline-danger">Delete</button>
								</form>
							</td>
						</tr>
					</cfloop>
				</tbody>
			</table>
		</div>
	</cfif>
</div>
</cfoutput>
