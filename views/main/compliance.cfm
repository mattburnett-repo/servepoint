<cfoutput>
<div class="container py-4 col-lg-8">
	<nav aria-label="breadcrumb" class="mb-3">
		<ol class="breadcrumb mb-0">
			<li class="breadcrumb-item"><a href="#event.buildLink( 'main.index' )#">Home</a></li>
			<li class="breadcrumb-item active" aria-current="page">Compliance posture</li>
		</ol>
	</nav>

	<h1 class="h2 text-primary mb-3">
		<i class="bi bi-file-earmark-check" aria-hidden="true"></i> #encodeForHTML( prc.pageTitle )#
	</h1>

	<p class="lead text-muted">
		ServePoint documents a <strong>demo-grade</strong> privacy and compliance <strong>posture</strong> (transparency and engineering checklists)—not certification, not legal advice, and not a guarantee that any deployment meets GDPR, HIPAA, CCPA/CPRA, or other laws.
	</p>

	<div class="alert alert-warning" role="alert">
		<strong>Demo vs production.</strong> Do not use real protected health information (PHI) or unnecessary real personal data in demo environments. Production use requires your own contracts (for example DPAs, BAAs), policies, risk analysis, and operational controls.
	</div>

	<div class="card shadow-sm mb-4">
		<div class="card-header bg-light">
			<h2 class="h5 mb-0"><i class="bi bi-journal-text" aria-hidden="true"></i> What this repository covers</h2>
		</div>
		<div class="card-body">
			<ul class="mb-0">
				<li><strong>Data inventory (high level):</strong> users, cases, documents, communications, audit events—see the compliance docs for table-level notes.</li>
				<li><strong>Framework overviews:</strong> short GDPR, HIPAA, and CCPA pages describing typical themes and <strong>operator</strong> responsibilities beyond code.</li>
				<li><strong>Technical mapping:</strong> encryption (see <a href="#event.buildLink( 'main.encryption' )#">Data encryption</a>), role-based access, structured audit logging—always contingent on correct deployment and process.</li>
			</ul>
		</div>
	</div>

	<div class="card shadow-sm mb-4">
		<div class="card-header bg-light">
			<h2 class="h5 mb-0"><i class="bi bi-github" aria-hidden="true"></i> Full documentation (source of truth)</h2>
		</div>
		<div class="card-body">
			<p class="mb-3">
				Authoritative markdown lives in the repository under <code>docs/compliance/</code> (README, data inventory, GDPR, HIPAA, CCPA pages).
			</p>
			<a
				href="https://github.com/mattburnett-repo/servepoint/tree/main/docs/compliance"
				class="btn btn-outline-primary me-2 mb-2"
				target="_blank"
				rel="noopener noreferrer"
			>
				<i class="bi bi-box-arrow-up-right" aria-hidden="true"></i> docs/compliance on GitHub
			</a>
		</div>
	</div>

	<p class="text-muted small mb-4">
		Official regulatory guidance should come from regulators and qualified counsel; these pages are engineering transparency only.
	</p>

	<a href="#event.buildLink( 'main.index' )#" class="btn btn-primary">
		<i class="bi bi-house" aria-hidden="true"></i> Back to home
	</a>
</div>
</cfoutput>
