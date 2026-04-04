<cfoutput>
<div class="container py-4">
	<div class="d-flex flex-wrap align-items-center justify-content-between gap-2 mb-4">
		<h1 class="h2 mb-0 text-primary">
			<i class="bi bi-chat-left-text" aria-hidden="true"></i> Staff communications
		</h1>
		<a href="#event.buildLink( "main.index" )#" class="btn btn-outline-secondary">Home</a>
	</div>
	<p class="text-muted mb-4">Read-only index of case communications. Use filters to narrow the list.</p>

	<form method="get" action="#event.buildLink( "communications.index" )#" class="card shadow-sm mb-4">
		<div class="card-header bg-light">
			<h2 class="h6 mb-0">Filters</h2>
		</div>
		<div class="card-body row g-3">
			<div class="col-md-4">
				<label for="filter-case" class="form-label">Case</label>
				<select name="caseId" id="filter-case" class="form-select" aria-label="Filter by case">
					<option value="">All cases</option>
					<cfloop array="#prc.cases#" index="c">
						<option value="#c.getCaseId()#" <cfif prc.filterCaseId eq c.getCaseId()>selected</cfif>>#encodeForHTMLAttribute( c.getTitle() )#</option>
					</cfloop>
				</select>
			</div>
			<div class="col-md-4">
				<label for="filter-type" class="form-label">Type</label>
				<select name="type" id="filter-type" class="form-select" aria-label="Filter by type">
					<option value="">All types</option>
					<cfloop array="#prc.communicationTypes#" index="t">
						<option value="#encodeForHTMLAttribute( t )#" <cfif prc.filterType eq t>selected</cfif>>#encodeForHTML( t )#</option>
					</cfloop>
				</select>
			</div>
			<div class="col-md-4">
				<label for="filter-author" class="form-label">Author</label>
				<select name="authorUserId" id="filter-author" class="form-select" aria-label="Filter by author">
					<option value="">All authors</option>
					<cfloop array="#prc.users#" index="u">
						<option value="#u.getUserId()#" <cfif prc.filterAuthorUserId eq u.getUserId()>selected</cfif>>#encodeForHTMLAttribute( u.getFirstName() & " " & u.getLastName() & " (" & u.getEmail() & ")" )#</option>
					</cfloop>
				</select>
			</div>
		</div>
		<div class="card-footer bg-light d-flex gap-2">
			<button type="submit" class="btn btn-primary">Apply filters</button>
			<a href="#event.buildLink( "communications.index" )#" class="btn btn-outline-secondary">Clear</a>
		</div>
	</form>

	<div class="card shadow-sm">
		<div class="card-header bg-light d-flex justify-content-between align-items-center">
			<h2 class="h6 mb-0">Results</h2>
			<span class="small text-muted">#arrayLen( prc.communications )# row(s)</span>
		</div>
		<div class="card-body p-0">
			<cfif arrayLen( prc.communications )>
				<div class="table-responsive">
					<table class="table table-striped table-hover mb-0">
						<thead class="table-light">
							<tr>
								<th scope="col">Case</th>
								<th scope="col">Message</th>
								<th scope="col">Author</th>
								<th scope="col">Created</th>
								<th scope="col">Type</th>
							</tr>
						</thead>
						<tbody>
							<cfloop array="#prc.communications#" index="commRow">
								<tr>
									<td>
										<cfif !isNull( commRow.getCaseRef() )>
											<a href="#event.buildLink( to = "cases.view", queryString = "id=" & commRow.getCaseRef().getCaseId() )#">#encodeForHTML( commRow.getCaseRef().getTitle() )#</a>
										</cfif>
									</td>
									<td>#encodeForHTML( left( commRow.getMessage(), 200 ) )#<cfif len( commRow.getMessage() ) gt 200>...</cfif></td>
									<td>
										<cfif !isNull( commRow.getAuthor() )>
											#encodeForHTML( commRow.getAuthor().getFirstName() & " " & commRow.getAuthor().getLastName() )#
										</cfif>
									</td>
									<td>
										<cfif !isNull( commRow.getDateCreated() )>
											<time datetime="#dateFormat( commRow.getDateCreated(), "yyyy-mm-dd" )#T#timeFormat( commRow.getDateCreated(), "HH:mm:ss" )#">#dateFormat( commRow.getDateCreated(), "medium" )# #timeFormat( commRow.getDateCreated(), "short" )#</time>
										<cfelse>
											<span class="text-muted">&mdash;</span>
										</cfif>
									</td>
									<td>#encodeForHTML( commRow.getType() )#</td>
								</tr>
							</cfloop>
						</tbody>
					</table>
				</div>
			<cfelse>
				<p class="p-3 text-muted mb-0">No communications match the current filters.</p>
			</cfif>
		</div>
	</div>
</div>
</cfoutput>
