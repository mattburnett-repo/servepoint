<cfoutput>
<div class="container py-4 col-lg-8">
	<h1 class="h2 mb-4 text-primary">
		<i class="bi bi-file-earmark-plus" aria-hidden="true"></i> New case
	</h1>

	<cfif structKeyExists( prc, "errorMessage" ) && len( trim( prc.errorMessage ) )>
		<div class="alert alert-danger" role="alert">
			#encodeForHTML( prc.errorMessage )#
		</div>
	</cfif>

	<form method="post" action="#event.buildLink( "cases.create" )#" class="card shadow-sm">
		<div class="card-body">
			<div class="mb-3">
				<label for="case-title" class="form-label">Title <span class="text-danger">*</span></label>
				<input type="text" class="form-control" id="case-title" name="title" required maxlength="500"
					value="#structKeyExists( prc, "titleValue" ) ? encodeForHTMLAttribute( prc.titleValue ) : ""#">
			</div>
			<div class="mb-3">
				<label for="case-description" class="form-label">Description</label>
				<textarea class="form-control" id="case-description" name="description" rows="4" maxlength="10000"><cfif structKeyExists( prc, "descriptionValue" )>#encodeForHTML( prc.descriptionValue )#</cfif></textarea>
			</div>
			<div class="mb-3">
				<label for="case-status" class="form-label">Status</label>
				<select class="form-select" id="case-status" name="status" aria-label="Case status">
					<cfloop array="#prc.statusOptions#" index="st">
						<option value="#encodeForHTMLAttribute( st )#">#encodeForHTML( st )#</option>
					</cfloop>
				</select>
			</div>
			<div class="mb-3">
				<label for="case-assign" class="form-label">Assign to</label>
				<select class="form-select" id="case-assign" name="assignedToUserId" aria-label="Assign case to user">
					<option value="">— Same as creator —</option>
					<cfloop array="#prc.users#" index="u">
						<option value="#u.getUserId()#">#encodeForHTML( u.getFirstName() & " " & u.getLastName() & " (" & u.getEmail() & ")" )#</option>
					</cfloop>
				</select>
			</div>
		</div>
		<div class="card-footer bg-light d-flex gap-2">
			<button type="submit" class="btn btn-primary">Create case</button>
			<a href="#event.buildLink( "cases.index" )#" class="btn btn-outline-secondary">Cancel</a>
		</div>
	</form>
</div>
</cfoutput>
