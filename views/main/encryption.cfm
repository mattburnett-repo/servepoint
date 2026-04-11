<cfoutput>
<div class="container py-4 col-lg-8">
	<nav aria-label="breadcrumb" class="mb-3">
		<ol class="breadcrumb mb-0">
			<li class="breadcrumb-item"><a href="#event.buildLink( 'main.index' )#">Home</a></li>
			<li class="breadcrumb-item active" aria-current="page">Encryption</li>
		</ol>
	</nav>

	<h1 class="h2 text-primary mb-3">
		<i class="bi bi-shield-lock" aria-hidden="true"></i> #encodeForHTML( prc.pageTitle )#
	</h1>

	<p class="lead text-muted">
		High-level summary of how ServePoint approaches encryption in this demo. Details live in code and env configuration.
	</p>

	<div class="card shadow-sm mb-4">
		<div class="card-header bg-light">
			<h2 class="h5 mb-0"><i class="bi bi-cloud-arrow-down" aria-hidden="true"></i> In transit</h2>
		</div>
		<div class="card-body">
			<ul class="mb-0">
				<li><strong>Web traffic:</strong> Use <strong>HTTPS</strong> in production so browsers talk to the app over TLS (configured at the load balancer, reverse proxy, or platform, not inside this CF app).</li>
				<li><strong>Database:</strong> PostgreSQL connections can require TLS via JDBC <code>sslmode</code>, driven by the <code>DB_SSL_MODE</code> environment variable and the <code>servepoint</code> datasource <code>custom</code> string in <code>.cfconfig.json</code> (e.g. <code>require</code> for managed hosts such as Render).</li>
			</ul>
		</div>
	</div>

	<div class="card shadow-sm mb-4">
		<div class="card-header bg-light">
			<h2 class="h5 mb-0"><i class="bi bi-hdd" aria-hidden="true"></i> At rest (uploaded documents)</h2>
		</div>
		<div class="card-body">
			<ul class="mb-0">
				<li>Files saved under the document storage root are encrypted with <strong>AES-256-GCM</strong> after upload.</li>
				<li>On-disk format uses a small binary envelope (magic prefix <code>SP1ENC01</code>, nonce, ciphertext including the GCM tag).</li>
				<li>The encryption key is supplied as a Base64-encoded 32-byte value via <code>SERVEPOINT_DOCUMENT_ENCRYPTION_KEY</code> (or ColdBox <code>moduleSettings.servepoint.documentUploads.encryptionKeyBase64</code>).</li>
				<li>Downloads decrypt in memory for the response; plaintext is not written back to disk for normal viewing.</li>
			</ul>
		</div>
	</div>

	<p class="text-muted small mb-4">
		Other data (case metadata, audit rows, etc.) is stored as application data in PostgreSQL under the same deployment’s security and access controls; this page focuses on <strong>file</strong> encryption and <strong>transport</strong> options described above.
	</p>

	<a href="#event.buildLink( 'main.index' )#" class="btn btn-primary">
		<i class="bi bi-house" aria-hidden="true"></i> Back to home
	</a>
</div>
</cfoutput>
