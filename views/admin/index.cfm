<cfoutput>
<div class="container py-4 col-lg-10">
	<h1 class="h2 mb-3 text-primary">
		<i class="bi bi-gear-wide-connected" aria-hidden="true"></i> #encodeForHTML( prc.pageTitle )#
	</h1>
	<p class="lead text-muted mb-4">
		Administrator tools for ServePoint. This area is restricted to the <strong>Administrator</strong> role on the server.
	</p>

	<cfif structKeyExists( prc, "noticeMessage" ) && len( trim( prc.noticeMessage ) )>
		<div class="alert alert-#structKeyExists( prc, 'noticeIsError' ) && prc.noticeIsError ? 'danger' : 'success'#" role="alert">
			#encodeForHTML( prc.noticeMessage )#
		</div>
	</cfif>

	<div class="row g-3 mb-4">
		<div class="col-md-6">
			<div class="card shadow-sm h-100">
				<div class="card-body">
					<h2 class="h5 card-title"><i class="bi bi-people" aria-hidden="true"></i> Users &amp; roles</h2>
					<p class="card-text small text-muted">List accounts and assign <code>User_Role</code> values. The last Administrator cannot be demoted.</p>
					<a href="#event.buildLink( 'admin.users' )#" class="btn btn-primary">Manage users</a>
				</div>
			</div>
		</div>
		<div class="col-md-6">
			<div class="card shadow-sm h-100">
				<div class="card-body">
					<h2 class="h5 card-title"><i class="bi bi-archive" aria-hidden="true"></i> Cases (incl. archived)</h2>
					<p class="card-text small text-muted">View every case and restore soft-archived records.</p>
					<a href="#event.buildLink( 'admin.cases' )#" class="btn btn-primary">View all cases</a>
				</div>
			</div>
		</div>
	</div>

	<div class="card border-secondary bg-light" id="servepoint-admin-roadmap">
		<div class="card-body">
			<h2 class="h6 text-secondary text-uppercase mb-3">Still on the roadmap</h2>
			<ul class="small mb-3 text-muted">
				<li>Deeper admin action coverage and dashboards</li>
				<li>LDAP/OAuth sign-in (not planned for this demo track)</li>
				<li>&ldquo;Hard archive&rdquo; exports (out of scope)</li>
			</ul>
			<p class="small text-muted mb-0"><strong>Unchanged:</strong> accepted documents are not deleted from the normal documents UI; disposition remains policy-driven.</p>
		</div>
	</div>
</div>
</cfoutput>
