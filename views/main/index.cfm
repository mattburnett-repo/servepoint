<cfoutput>
<div class="text-center card shadow-sm bg-light border border-5 border-white">
	<div class="card-body">
		<div>
			<h1 class="display-4 fw-bold text-primary mb-3">
				<i class="bi bi-shield-check"></i> ServePoint
			</h1>
		</div>
		<div class="badge bg-primary mb-3">
			<strong>Enterprise-Grade Case Management System</strong>
		</div>

		<h2 class="display-6 fw-bold">
			#prc.welcomeMessage#
		</h2>

		<div class="col-lg-8 mx-auto">
			<p class="lead mb-4">
				#prc.projectDescription# designed for #prc.targetAudience#. 
				This demo application showcases ColdFusion's enterprise capabilities with modern architecture, 
				security, privacy, and deployment best practices.
			</p>
		</div>
	</div>
</div>

<div class="container mb-5">
	<div class="row py-5 row-cols-lg-2 gx-4">
		<div class="col d-flex align-items-start">
			<div class="bg-light text-primary flex-shrink-0 me-3 px-2 fs-2 rounded-circle shadow-sm border border-5 border-white">
				<i class="bi bi-gear-fill" aria-hidden="true"></i>
			</div>
			<div>
				<h2 class="text-primary">Core Features</h2>
				<p>
					ServePoint provides comprehensive case management capabilities:
				</p>
				<div class="list-group">
					<cfloop array="#prc.projectFeatures#" index="feature">
						<div class="list-group-item d-flex gap-2 py-3">
							<div class="rounded-circle flex-shrink-0 text-success px-1">
								<i class="bi bi-check-circle" aria-hidden="true"></i> 
							</div>
							<div class="d-flex gap-2 w-100 justify-content-between">#feature#</div>
						</div>
					</cfloop>
				</div>
			</div>
		</div>

		<div class="col d-flex align-items-start">
			<div class="bg-light text-primary flex-shrink-0 me-3 px-2 fs-2 rounded-circle shadow-sm border border-5 border-white">
				<i class="bi bi-shield-lock"></i>
			</div>
			<div>
				<h2 class="text-primary">Security & Privacy</h2>
				<p>
					Built with enterprise-grade security and privacy compliance:
				</p>
				<div class="list-group">
					<div class="list-group-item d-flex gap-2 py-3">
						<div class="rounded-circle flex-shrink-0 text-success px-1">
							<i class="bi bi-shield-check" aria-hidden="true"></i> 
						</div>
						<div class="d-flex gap-2 w-100 justify-content-between">Role-based access controls</div>
					</div>
					<div class="list-group-item d-flex gap-2 py-3">
						<div class="rounded-circle flex-shrink-0 text-success px-1">
							<i class="bi bi-lock" aria-hidden="true"></i> 
						</div>
						<div class="d-flex gap-2 w-100 justify-content-between">Data encryption at rest and in transit</div>
					</div>
					<div class="list-group-item d-flex gap-2 py-3">
						<div class="rounded-circle flex-shrink-0 text-success px-1">
							<i class="bi bi-journal-text" aria-hidden="true"></i> 
						</div>
						<div class="d-flex gap-2 w-100 justify-content-between">Comprehensive audit logging</div>
					</div>
					<div class="list-group-item d-flex gap-2 py-3">
						<div class="rounded-circle flex-shrink-0 text-success px-1">
							<i class="bi bi-file-earmark-check" aria-hidden="true"></i> 
						</div>
						<div class="d-flex gap-2 w-100 justify-content-between">GDPR, HIPAA, CCPA compliance</div>
					</div>
				</div>
			</div>
		</div>
	</div>

	<div class="row pb-5 row-cols-lg-2 gx-4">
		<div class="col d-flex align-items-start">
			<div class="bg-light text-primary flex-shrink-0 me-3 px-2 fs-2 rounded-circle shadow-sm border border-3 border-white">
				<i class="bi bi-cloud-arrow-up"></i>
			</div>
			<div>
				<h2 class="text-primary">Modern Architecture</h2>
				<p>
					Built with modern development practices and technologies:
				</p>
				<ul class="list-unstyled">
					<li><i class="bi bi-check text-success"></i> ColdBox HMVC Framework</li>
					<li><i class="bi bi-check text-success"></i> ColdFusion ORM (Hibernate)</li>
					<li><i class="bi bi-check text-success"></i> Docker Containerization</li>
					<li><i class="bi bi-check text-success"></i> TestBox Testing Framework</li>
					<li><i class="bi bi-check text-success"></i> Progressive Enhancement (Vue.js ready)</li>
				</ul>
			</div>
		</div>

		<div class="col d-flex align-items-start">
			<div class="bg-light text-primary flex-shrink-0 me-3 px-2 fs-2 rounded-circle shadow-sm border border-5 border-white">
				<i class="bi bi-card-checklist" aria-hidden="true"></i>
			</div>
			<div>
				<h2 class="text-primary">Development Tools</h2>
				<p>
					Comprehensive testing and development tools are available:
				</p>

				<div class="d-grid gap-2 d-sm-flex justify-content-sm-center">
					<a
						href="#getSetting( "appMapping" )#/tests/index.cfm"
						class="btn btn-primary btn-lg"
						role="button"
						target="_blank"
					>
						<i class="bi bi-binoculars" aria-hidden="true"></i>
						Test Browser
					</a>

					<a
						href="#getSetting( "appMapping" )#/tests/runner.cfm"
						class="btn btn-primary btn-lg"
						role="button"
						target="_blank"
					>
						<i class="bi bi-activity" aria-hidden="true"></i>
						Test Runner
					</a>
				</div>
			</div>
		</div>
	</div>
</div>

</cfoutput>
