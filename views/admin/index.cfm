<cfoutput>
<div class="container py-4 col-lg-10">
	<h1 class="h2 mb-3 text-primary">
		<i class="bi bi-gear-wide-connected" aria-hidden="true"></i> #encodeForHTML( prc.pageTitle )#
	</h1>
	<p class="lead text-muted mb-4">
		Administrator tools for ServePoint. This area is restricted to the <strong>Administrator</strong> role on the server.
	</p>

	<div class="card shadow-sm mb-4">
		<div class="card-body">
			<h2 class="h5 card-title">Getting started</h2>
			<p class="card-text mb-0">
				Use the navigation to work with cases, documents, and reports. Additional admin capabilities will appear here as they are implemented.
			</p>
		</div>
	</div>

	<div class="card border-secondary bg-light" id="servepoint-admin-roadmap">
		<div class="card-body">
			<h2 class="h6 text-secondary text-uppercase mb-3">Possible future implementations</h2>
			<p class="small text-muted mb-2">Planned enhancements tracked for the admin module (not all are scheduled yet):</p>
			<ul class="small mb-3">
				<li>Manage users and assign <code>User_Role</code> values</li>
				<li>List cases including archived (<code>CaseService.listAll( includeArchived = true )</code>) and restore where supported</li>
				<li>Structured logging of important admin actions (LogBox <code>audit.admin</code>)</li>
			</ul>
			<p class="small text-muted mb-0"><strong>Out of scope for this track:</strong> changing accepted-document deletion in the normal documents UI; full LDAP/OAuth UI; &ldquo;hard archive&rdquo; export workflows.</p>
		</div>
	</div>
</div>
</cfoutput>
