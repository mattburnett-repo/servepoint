<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>ServePoint — Systems healthy</title>
	<style>
		:root {
			--mint: rgb(214, 252, 240);
			--sea: rgb(46, 160, 140);
			--sky: rgb(56, 155, 210);
			--ink: rgb(24, 52, 62);
		}
		@keyframes floaty {
			0%, 100% { transform: translateY(0); }
			50% { transform: translateY(-6px); }
		}
		@keyframes pulse-ring {
			0% { box-shadow: 0 0 0 0 rgba(46, 160, 140, 0.45); }
			70% { box-shadow: 0 0 0 18px rgba(46, 160, 140, 0); }
			100% { box-shadow: 0 0 0 0 rgba(46, 160, 140, 0); }
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
			background: linear-gradient(145deg, var(--mint) 0%, rgb(230, 248, 255) 45%, rgb(200, 235, 255) 100%);
		}
		.card {
			text-align: center;
			padding: 2.5rem 2rem 2rem;
			max-width: 28rem;
			background: rgba(255, 255, 255, 0.88);
			border-radius: 1.25rem;
			box-shadow: 0 12px 40px rgba(24, 52, 62, 0.12), 0 2px 8px rgba(56, 155, 210, 0.15);
			backdrop-filter: blur(8px);
		}
		.icon-wrap {
			display: inline-flex;
			align-items: center;
			justify-content: center;
			width: 5rem;
			height: 5rem;
			border-radius: 50%;
			background: linear-gradient(145deg, var(--sea), var(--sky));
			color: rgb(255, 255, 255);
			font-size: 2.5rem;
			line-height: 1;
			animation: floaty 3s ease-in-out infinite, pulse-ring 2.5s ease-out infinite;
		}
		h1 {
			font-size: 1.65rem;
			font-weight: 700;
			margin: 1.25rem 0 0.5rem;
			letter-spacing: -0.02em;
		}
		p.lead {
			margin: 0 0 1rem;
			font-size: 1.05rem;
			line-height: 1.5;
			color: rgb(55, 90, 100);
		}
		p.meta {
			margin: 0;
			font-size: 0.8rem;
			color: rgb(110, 130, 138);
		}
	</style>
</head>
<body>
	<div class="card" role="status">
		<div class="icon-wrap" aria-hidden="true">&#10003;</div>
		<h1>All systems go</h1>
		<p class="lead">ServePoint is up, the app is responding, and the database answered hello. Carry on with confidence.</p>
		<p class="meta">Checked at <cfoutput>#encodeForHTML( prc.checkedAt )#</cfoutput> (server time)</p>
	</div>
</body>
</html>
