<cfoutput>
<div class="container py-4 col-lg-5">
	<nav aria-label="breadcrumb" class="mb-3">
		<ol class="breadcrumb mb-0">
			<li class="breadcrumb-item"><a href="#event.buildLink( 'main.index' )#">Home</a></li>
			<li class="breadcrumb-item active" aria-current="page">Sign in</li>
		</ol>
	</nav>

	<h1 class="h2 text-primary mb-3">
		<i class="bi bi-box-arrow-in-right" aria-hidden="true"></i> Sign in
	</h1>

	<p class="text-muted mb-4">
		Use a seeded demo account from <code>SeedService</code> (e.g. <code>admin@example.com</code> / <code>change-me</code>).
	</p>

	<cfif structKeyExists( prc, "errorMessage" ) AND len( trim( prc.errorMessage ) )>
		<div class="alert alert-danger" role="alert">#encodeForHTML( prc.errorMessage )#</div>
	</cfif>

	<cfset emailFieldValue = "">
	<cfif structKeyExists( prc, "emailValue" )>
		<cfset emailFieldValue = encodeForHTMLAttribute( prc.emailValue )>
	</cfif>
	<form method="post" action="#event.buildLink( 'main.doLogin' )#" class="card shadow-sm">
		<div class="card-body">
			<div class="mb-3">
				<label for="email" class="form-label">Email</label>
				<input type="email" class="form-control" id="email" name="email" required autocomplete="username" value="#emailFieldValue#" />
			</div>
			<div class="mb-3">
				<label for="password" class="form-label">Password</label>
				<input type="password" class="form-control" id="password" name="password" required autocomplete="current-password" />
			</div>
			<button type="submit" class="btn btn-primary">Sign in</button>
		</div>
	</form>
</div>
</cfoutput>
