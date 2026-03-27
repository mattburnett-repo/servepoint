<cfoutput>
<cfset c = prc.caseEntity />
<cfset creatorId = c.getCreator().getUserId() />
<cfset assignId = !isNull( c.getAssignedTo() ) ? c.getAssignedTo().getUserId() : creatorId />
<div class="container py-4 col-lg-8">
	<div class="d-flex flex-wrap align-items-center justify-content-between gap-2 mb-4">
		<h1 class="h2 mb-0 text-primary">
			<i class="bi bi-folder2-open" aria-hidden="true"></i> Case
		</h1>
		<a href="#event.buildLink( "cases.index" )#" class="btn btn-outline-secondary">Back to cases</a>
	</div>

	<cfif structKeyExists( prc, "noticeMessage" ) && len( trim( prc.noticeMessage ) )>
		<div class="alert alert-success" role="alert">
			#encodeForHTML( prc.noticeMessage )#
		</div>
	</cfif>

	<cfif structKeyExists( prc, "errorMessage" ) && len( trim( prc.errorMessage ) )>
		<div class="alert alert-danger" role="alert">
			#encodeForHTML( prc.errorMessage )#
		</div>
	</cfif>

	<div class="card shadow-sm mb-4">
		<div class="card-header bg-light">
			<h2 class="h5 mb-0">Summary</h2>
		</div>
		<div class="card-body">
			<dl class="row mb-0">
				<dt class="col-sm-3">Case ID</dt>
				<dd class="col-sm-9">#c.getCaseId()#</dd>
				<dt class="col-sm-3">Created</dt>
				<dd class="col-sm-9"><time datetime="#dateFormat( c.getDateCreated(), "yyyy-mm-dd" )#T#timeFormat( c.getDateCreated(), "HH:mm:ss" )#">#dateFormat( c.getDateCreated(), "medium" )# #timeFormat( c.getDateCreated(), "short" )#</time></dd>
				<dt class="col-sm-3">Updated</dt>
				<dd class="col-sm-9">
					<cfif !isNull( c.getDateUpdated() )>
						<time datetime="#dateFormat( c.getDateUpdated(), "yyyy-mm-dd" )#T#timeFormat( c.getDateUpdated(), "HH:mm:ss" )#">#dateFormat( c.getDateUpdated(), "medium" )# #timeFormat( c.getDateUpdated(), "short" )#</time>
					<cfelse>
						<span class="text-muted">&mdash;</span>
					</cfif>
				</dd>
				<dt class="col-sm-3">Creator</dt>
				<dd class="col-sm-9">
					<cfif !isNull( c.getCreator() )>
						#encodeForHTML( c.getCreator().getFirstName() & " " & c.getCreator().getLastName() )#
					</cfif>
				</dd>
			</dl>
		</div>
	</div>

	<h2 class="h4 mb-3 text-primary">Edit case</h2>
	<form method="post" action="#event.buildLink( "cases.update" )#" class="card shadow-sm">
		<input type="hidden" name="caseId" value="#c.getCaseId()#">
		<div class="card-body">
			<div class="mb-3">
				<label for="case-title" class="form-label">Title <span class="text-danger">*</span></label>
				<input type="text" class="form-control" id="case-title" name="title" required maxlength="500"
					value="#encodeForHTMLAttribute( c.getTitle() )#">
			</div>
			<div class="mb-3">
				<label for="case-description" class="form-label">Description</label>
				<textarea class="form-control" id="case-description" name="description" rows="4" maxlength="10000">#encodeForHTML( isNull( c.getDescription() ) ? "" : c.getDescription() )#</textarea>
			</div>
			<div class="mb-3">
				<label for="case-status" class="form-label">Status</label>
				<select class="form-select" id="case-status" name="status" aria-label="Case status">
					<cfloop array="#prc.statusOptions#" index="st">
						<option value="#encodeForHTMLAttribute( st )#" <cfif c.getStatus() eq st>selected</cfif>>#encodeForHTML( st )#</option>
					</cfloop>
				</select>
			</div>
			<div class="mb-3">
				<label for="case-assign" class="form-label">Assign to</label>
				<select class="form-select" id="case-assign" name="assignedToUserId" aria-label="Assign case to user">
					<option value="" <cfif assignId eq creatorId>selected</cfif>>— Same as creator —</option>
					<cfloop array="#prc.users#" index="u">
						<option value="#u.getUserId()#" <cfif assignId eq u.getUserId() AND assignId neq creatorId>selected</cfif>>#encodeForHTML( u.getFirstName() & " " & u.getLastName() & " (" & u.getEmail() & ")" )#</option>
					</cfloop>
				</select>
			</div>
		</div>
		<div class="card-footer bg-light d-flex flex-wrap gap-2">
			<button type="submit" class="btn btn-primary">Save changes</button>
			<a href="#event.buildLink( "cases.index" )#" class="btn btn-outline-secondary">Cancel</a>
		</div>
	</form>
</div>
</cfoutput>
