<cfoutput>
<div class="container py-4 col-lg-11">
	<div class="d-flex flex-wrap align-items-center justify-content-between gap-2 mb-4">
		<h1 class="h2 mb-0 text-primary">
			<i class="bi bi-people" aria-hidden="true"></i> #encodeForHTML( prc.pageTitle )#
		</h1>
		<a href="#event.buildLink( 'admin.index' )#" class="btn btn-outline-secondary btn-sm">Admin home</a>
	</div>

	<cfif structKeyExists( prc, "noticeMessage" ) && len( trim( prc.noticeMessage ) )>
		<div class="alert alert-#structKeyExists( prc, 'noticeIsError' ) && prc.noticeIsError ? 'danger' : 'success'#" role="alert">
			#encodeForHTML( prc.noticeMessage )#
		</div>
	</cfif>

	<p class="text-muted small mb-3">Change a user&rsquo;s role. You cannot remove the <strong>last</strong> Administrator account. Role changes are written to the audit log (<code>audit.admin</code>).</p>

	<div class="table-responsive shadow-sm rounded border bg-white">
		<table class="table table-hover table-sm align-middle mb-0">
			<thead class="table-light">
				<tr>
					<th scope="col">Email</th>
					<th scope="col">Name</th>
					<th scope="col">Current role</th>
					<th scope="col">Set role</th>
				</tr>
			</thead>
			<tbody>
				<cfloop array="#prc.users#" index="uRow">
				<tr>
					<td>#encodeForHTML( uRow.getEmail() )#</td>
					<td>#encodeForHTML( trim( uRow.getFirstName() & ' ' & uRow.getLastName() ) )#</td>
					<td>#encodeForHTML( uRow.getRole() )#</td>
					<td>
						<form method="post" action="#event.buildLink( 'admin.saveUserRole' )#" class="d-flex flex-wrap gap-2 align-items-center">
							<input type="hidden" name="userId" value="#uRow.getUserId()#" />
							<select name="role" class="form-select form-select-sm" style="min-width: 12rem;" aria-label="Assign role">
								<cfloop array="#prc.roleOptions#" index="opt">
									<option value="#encodeForHTML( opt )#"<cfif uRow.getRole() EQ opt> selected</cfif>>#encodeForHTML( opt )#</option>
								</cfloop>
							</select>
							<button type="submit" class="btn btn-primary btn-sm">Save</button>
						</form>
					</td>
				</tr>
				</cfloop>
			</tbody>
		</table>
	</div>
</div>
</cfoutput>
