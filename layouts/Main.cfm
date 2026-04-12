<cfoutput>
<!doctype html>
<html lang="en">
<head>
	<!--- Metatags --->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
	<meta name="description" content="ColdBox Application Template">
    <meta name="author" content="Ortus Solutions, Corp">

	<!---Base URL --->
	<base href="#event.getHTMLBaseURL()#" />

	<!---
		CSS
		- Bootstrap
		- Alpine.js
	--->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65" crossorigin="anonymous">
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
	<style>
		.text-blue { color:##379BC1; }
		/* Lighter steel blue — aligned with .text-blue / primary, less muddy than the old navy */
		.navbar-servepoint {
			background: linear-gradient(180deg, ##3a7eb8 0%, ##2a6499 100%);
			box-shadow: 0 2px 10px rgba(25, 85, 140, 0.28);
		}
		/* Center primary nav in full bar width (lg+); keep brand left, utilities right */
		@media (min-width: 992px) {
			.navbar-servepoint .navbar-primary-nav {
				position: absolute;
				left: 50%;
				top: 50%;
				transform: translate(-50%, -50%);
				margin: 0;
				z-index: 1;
			}
			.navbar-servepoint .navbar-brand,
			.navbar-servepoint .navbar-left-cluster,
			.navbar-servepoint .navbar-end-cluster {
				position: relative;
				z-index: 2;
			}
		}
		@media (max-width: 991.98px) {
			.navbar-servepoint .navbar-primary-nav {
				position: static;
				transform: none;
			}
		}
	</style>

	<!--- Favicon (shield-check, matches index iconography) --->
	<link rel="icon" type="image/svg+xml" href="#event.getHTMLBaseURL()#favicon.svg" />

	<!--- Title --->
	<title>Welcome to ServePoint!</title>
</head>
<body
	data-spy="scroll"
	data-target=".navbar"
	data-offset="50"
	style="padding-top: 60px"
	class="d-flex flex-column h-100"
>
	<!---Top NavBar --->
	<header>
		<nav class="navbar navbar-expand-lg navbar-dark navbar-servepoint fixed-top">
			<div class="container-fluid position-lg-relative">
				<!---Brand (icon matches views/main/index.cfm hero) --->
				<a class="navbar-brand d-flex align-items-center gap-2 py-1" href="#event.buildLink( 'main' )#">
					<i class="bi bi-shield-check fs-4" aria-hidden="true"></i>
					<strong>ServePoint</strong>
				</a>

				<!--- Mobile Toggler --->
				<button
					class="navbar-toggler"
					type="button"
					data-bs-toggle="collapse"
					data-bs-target="##navbarSupportedContent"
					aria-controls="navbarSupportedContent"
					aria-expanded="false"
					aria-label="Toggle navigation"
				>
					<span class="navbar-toggler-icon"></span>
				</button>

				<div class="collapse navbar-collapse d-lg-flex flex-lg-row flex-lg-grow-1 align-items-lg-center" id="navbarSupportedContent">

					<!--- Primary first in DOM so the collapsed menu lists app links before About/Learn/Support --->
					<ul class="navbar-nav navbar-primary-nav flex-row flex-wrap justify-content-center mb-2 mb-lg-0 order-lg-2">
						<li class="nav-item">
							<a class="nav-link" href="#event.buildLink( 'main.index' )#">
								<i class="bi bi-house-door" aria-hidden="true"></i> Home
							</a>
						</li>
						<li class="nav-item">
							<a class="nav-link" href="#event.buildLink( 'cases.index' )#">
								<i class="bi bi-folder2-open" aria-hidden="true"></i> Cases
							</a>
						</li>
						<li class="nav-item">
							<a class="nav-link" href="#event.buildLink( 'documents.index' )#">
								<i class="bi bi-file-earmark-text" aria-hidden="true"></i> Documents
							</a>
						</li>
						<cfif NOT structKeyExists( prc, "currentUserRole" ) OR !len( trim( prc.currentUserRole ) ) OR prc.currentUserRole NEQ "Citizen">
						<li class="nav-item">
							<a class="nav-link" href="#event.buildLink( 'communications.index' )#">
								<i class="bi bi-chat-dots" aria-hidden="true"></i> Communications
							</a>
						</li>
						</cfif>
						<cfset _navRole = structKeyExists( prc, "currentUserRole" ) ? trim( prc.currentUserRole ) : "" />
						<cfif !len( _navRole ) OR _navRole EQ "Administrator">
						<li class="nav-item">
							<a class="nav-link" href="#event.buildLink( 'reports.index' )#">
								<i class="bi bi-clipboard-data" aria-hidden="true"></i> Reports
							</a>
						</li>
						</cfif>
						<cfif len( _navRole ) AND _navRole EQ "Administrator">
						<li class="nav-item">
							<a class="nav-link" href="#event.buildLink( 'admin.index' )#">
								<i class="bi bi-gear-wide-connected" aria-hidden="true"></i> Admin
							</a>
						</li>
						</cfif>
					</ul>

					<!--- About / Learn / Support: immediately after brand on lg+; below primary when menu is stacked --->
					<div class="navbar-left-cluster d-flex flex-column flex-lg-row align-items-lg-center gap-1 gap-lg-2 mb-2 mb-lg-0 order-lg-1">

					<!---About --->
					<ul class="navbar-nav mb-2 mb-lg-0">
						<li class="nav-item dropdown">
							<a
								class="nav-link dropdown-toggle"
								href="##"
								id="navbarDropdown"
								role="button"
								data-bs-toggle="dropdown"
								aria-expanded="false"
							>
								About  <b class="caret"></b>
							</a>
							<ul class="dropdown-menu" aria-labelledby="navbarDropdown">
								<li>
									<a href="#event.buildLink( 'main.index' ) & "##overview"#" class="dropdown-item">
										<i class="bi bi-info-circle"></i> System Overview
									</a>
								</li>
								<li>
									<a href="#event.buildLink( 'main.index' ) & "##core-features"#" class="dropdown-item">
										<i class="bi bi-gear"></i> Features
									</a>
								</li>
								<li>
									<a href="#event.buildLink( 'main.compliance' )#" class="dropdown-item">
										<i class="bi bi-shield-check"></i> Security & Privacy
									</a>
								</li>
								<li>
									<hr class="dropdown-divider">
								</li>
								<li>
									<a href="https://github.com/mattburnett-repo/servepoint/issues" class="dropdown-item" target="_blank" rel="noopener noreferrer">
										<i class="bi bi-envelope"></i> Contact Support
									</a>
								</li>
							</ul>
						</li>
					</ul>

					<!--- Learn --->
					<ul class="navbar-nav mb-2 mb-lg-0">
						<li class="nav-item dropdown">
							<a
								class="nav-link dropdown-toggle"
								href="##"
								id="navbarDropdown"
								role="button"
								data-bs-toggle="dropdown"
								aria-expanded="false"
							>
								Learn  <b class="caret"></b>
							</a>
							<ul class="dropdown-menu" aria-labelledby="navbarDropdown">
								<li>
									<a class="dropdown-item" href="https://github.com/mattburnett-repo/servepoint##readme" target="_blank" rel="noopener noreferrer">
										<i class="bi bi-book"></i> User Guide
									</a>
								</li>
								<li>
									<a class="dropdown-item" href="https://coldbox.ortusbooks.com/getting-started/first-steps/my-first-coldbox-application" target="_blank" rel="noopener noreferrer">
										<i class="bi bi-mortarboard"></i> ColdBox walkthrough
									</a>
								</li>
								<li>
									<a class="dropdown-item" href="https://github.com/mattburnett-repo/servepoint/blob/main/docs/logging.md" target="_blank" rel="noopener noreferrer">
										<i class="bi bi-lightbulb"></i> Best Practices
									</a>
								</li>
								<li>
									<a class="dropdown-item" href="https://github.com/mattburnett-repo/servepoint/blob/main/docs/DEV_NOTES.md" target="_blank" rel="noopener noreferrer">
										<i class="bi bi-question-circle"></i> FAQ
									</a>
								</li>
							</ul>
						</li>
					</ul>

					<!--- Support --->
					<ul class="navbar-nav mb-2 mb-lg-0">
						<li class="nav-item dropdown">
							<a
								class="nav-link dropdown-toggle"
								href="##"
								id="navbarDropdown"
								role="button"
								data-bs-toggle="dropdown"
								aria-expanded="false"
							>
								Support  <b class="caret"></b>
							</a>
							<ul class="dropdown-menu" aria-labelledby="navbarDropdown">
								<li>
									<a class="dropdown-item" href="https://github.com/mattburnett-repo/servepoint/issues" target="_blank" rel="noopener noreferrer">
										<i class="bi bi-headset"></i> Help Desk
									</a>
								</li>
								<li>
									<a class="dropdown-item" href="https://github.com/mattburnett-repo/servepoint/issues/new" target="_blank" rel="noopener noreferrer">
										<i class="bi bi-ticket"></i> Submit Ticket
									</a>
								</li>
								<li>
									<a class="dropdown-item" href="https://github.com/mattburnett-repo/servepoint/issues/new?title=Urgent%20support%20request" target="_blank" rel="noopener noreferrer">
										<i class="bi bi-exclamation-triangle"></i> Emergency Contact
									</a>
								</li>
								<li>
									<a class="dropdown-item" href="#event.getHTMLBaseURL()#healthcheck">
										<i class="bi bi-activity"></i> System Status
									</a>
								</li>
							</ul>
						</li>
					</ul>

					</div><!--- end navbar-left-cluster --->

					<div class="navbar-end-cluster d-flex flex-column flex-lg-row align-items-lg-center gap-2 gap-lg-3 ms-lg-auto order-lg-3">
						<ul class="navbar-nav flex-row align-items-center mb-0">
							<cfif structKeyExists( prc, "currentUser" ) AND isObject( prc.currentUser )>
								<li class="nav-item d-flex align-items-center">
									<span class="text-white-50 small px-2 py-2 text-nowrap">#encodeForHTML( prc.currentUser.getEmail() )#</span>
								</li>
								<li class="nav-item">
									<a class="nav-link" href="#event.buildLink( 'main.logout' )#">Sign out</a>
								</li>
							<cfelse>
								<li class="nav-item">
									<a class="nav-link" href="#event.buildLink( 'main.login' )#">Sign in</a>
								</li>
							</cfif>
						</ul>
						<a href="https://github.com/mattburnett-repo/servepoint.git" class="btn btn-outline-light btn-sm" target="_blank">
							<i class="bi bi-github"></i> View the code on GitHub
						</a>
					</div><!--- end navbar-end-cluster --->

				</div>
			</div>
		</nav>
	</header>

	<!---Container And Views --->
	<main class="flex-shrink-0">
		<cfif structKeyExists( session, "servepointAuthzNotice" ) && len( trim( session.servepointAuthzNotice ) )>
			<div class="container pt-2">
				<div class="alert alert-warning alert-dismissible fade show" role="alert">
					#encodeForHTML( session.servepointAuthzNotice )#
					<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
				</div>
			</div>
			<cfset structDelete( session, "servepointAuthzNotice" ) />
		</cfif>
		#view()#
	</main>

	<!--- Footer   
  <footer class="w-100 bottom-0 position-fixed border-top py-3 mt-5 bg-light">
    <div class="container">
      <p class="float-end">
        <a href="##" class="btn btn-info rounded-circle shadow" role="button">
          <i class="bi bi-arrow-bar-up"></i> <span class="visually-hidden">Top</span>
        </a>
      </p>
      <p>
        <a href="https://github.com/ColdBox/coldbox-platform/stargazers">ColdBox Platform</a> is a copyright-trademark software by
        <a href="https://www.ortussolutions.com">Ortus Solutions, Corp</a>
      </p>
    </div>
  </footer>
  --->

	<!---
		JavaScript
		- Bootstrap
		- Popper
		- Alpine.js
	--->
	<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.6/dist/umd/popper.min.js" integrity="sha384-oBqDVmMz9ATKxIep9tiCxS/Z9fNfEXiDAYTujMAeBAsjFuCZSmKbSSUnQlmh/jp3" crossorigin="anonymous"></script>
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.min.js" integrity="sha384-cuYeSxntonz0PPNlHhBs68uyIAVpIIOZZ5JqeqvYYIcEL727kskC66kF92t6Xl2V" crossorigin="anonymous"></script>
	<script defer src="https://unpkg.com/alpinejs@3.x.x/dist/cdn.min.js"></script>
</body>
</html>
</cfoutput>
