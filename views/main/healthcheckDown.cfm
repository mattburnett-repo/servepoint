<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>ServePoint — Service check</title>
	<style>
		:root {
			--warm-bg: rgb(255, 245, 238);
			--peach: rgb(232, 160, 130);
			--rose: rgb(180, 96, 110);
			--ink: rgb(62, 48, 52);
			--muted: rgb(110, 95, 100);
		}
		@keyframes breathe {
			0%, 100% { opacity: 1; }
			50% { opacity: 0.72; }
		}
		* { box-sizing: border-box; }
		body {
			margin: 0;
			min-height: 100vh;
			display: flex;
			align-items: center;
			justify-content: center;
			font-family: system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
			color: var(--ink);
			background: linear-gradient(160deg, var(--warm-bg) 0%, rgb(250, 232, 240) 55%, rgb(235, 228, 245) 100%);
		}
		.card {
			text-align: center;
			padding: 2.5rem 2rem 2rem;
			max-width: 30rem;
			background: rgba(255, 255, 255, 0.92);
			border-radius: 1.25rem;
			border: 1px solid rgba(232, 160, 130, 0.35);
			box-shadow: 0 10px 36px rgba(62, 48, 52, 0.1);
		}
		.icon-wrap {
			display: inline-flex;
			align-items: center;
			justify-content: center;
			width: 5rem;
			height: 5rem;
			border-radius: 50%;
			background: linear-gradient(145deg, rgb(255, 220, 200), var(--peach));
			color: var(--rose);
			font-size: 2.25rem;
			line-height: 1;
			animation: breathe 3.5s ease-in-out infinite;
		}
		h1 {
			font-size: 1.5rem;
			font-weight: 700;
			margin: 1.25rem 0 0.5rem;
			letter-spacing: -0.02em;
		}
		p.lead {
			margin: 0 0 1rem;
			font-size: 1.02rem;
			line-height: 1.55;
			color: var(--muted);
		}
		p.hope {
			margin: 0 0 1rem;
			font-size: 0.98rem;
			line-height: 1.5;
			color: rgb(95, 82, 88);
		}
		p.meta {
			margin: 0 0 0.75rem;
			font-size: 0.8rem;
			color: rgb(140, 125, 130);
		}
		pre.detail {
			text-align: left;
			margin: 0;
			padding: 0.65rem 0.75rem;
			font-size: 0.72rem;
			line-height: 1.35;
			background: rgb(252, 248, 246);
			border-radius: 0.5rem;
			color: rgb(90, 78, 82);
			overflow-x: auto;
			white-space: pre-wrap;
			word-break: break-word;
		}
	</style>
</head>
<body>
	<div class="card" role="alert">
		<div class="icon-wrap" aria-hidden="true">&#9829;</div>
		<h1>We can&rsquo;t confirm everything yet</h1>
		<p class="lead">The application is running, but the health check could not reach the database. This is usually temporary.</p>
		<p class="hope">Take a breath, try again in a moment, or check deployment and database connectivity. Things often look up right after they look stuck.</p>
		<p class="meta">Checked at <cfoutput>#encodeForHTML( prc.checkedAt )#</cfoutput> (server time) &middot; HTTP 503</p>
		<cfif structKeyExists( prc, "healthMessage" ) && len( trim( prc.healthMessage ) )>
			<pre class="detail" id="detail"><cfoutput>#encodeForHTML( prc.healthMessage )#</cfoutput></pre>
		</cfif>
	</div>
</body>
</html>
