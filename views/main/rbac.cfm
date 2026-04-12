<cfoutput>
<div class="container py-4 col-lg-9">
	<h1 class="h2 mb-3 text-primary">
		<i class="bi bi-shield-lock" aria-hidden="true"></i> #encodeForHTML( prc.pageTitle )#
	</h1>
	<p class="lead">
		ServePoint uses <strong>coarse</strong> role checks in the security interceptor (which routes you may open) and
		<strong>fine-grained</strong> checks in services (for example, whether you may change a case you are assigned to).
		The server always decides; the UI only hides shortcuts.
	</p>

	<h2 class="h4 mt-4">Demo accounts (seed)</h2>
	<p>Password for all seeded users: <code>change-me</code> (when auto-seed is enabled).</p>
	<ul class="list-unstyled">
		<li><strong>admin@example.com</strong> — Administrator</li>
		<li><strong>case.manager@example.com</strong> — Case Manager</li>
		<li><strong>citizen@example.com</strong> — Citizen</li>
	</ul>
	<p>
		<a href="#event.buildLink( 'main.login' )#" class="btn btn-primary">Sign in</a>
		<a href="#event.buildLink( 'main.index' )#" class="btn btn-outline-secondary">Back to home</a>
	</p>

	<h2 class="h4 mt-4">Permission matrix (MVP)</h2>
	<div class="table-responsive shadow-sm rounded border">
		<table class="table table-sm align-middle mb-0">
			<thead class="table-light">
				<tr>
					<th scope="col">Area</th>
					<th scope="col">Administrator</th>
					<th scope="col">Case Manager</th>
					<th scope="col">Citizen</th>
					<th scope="col">Enforced in</th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td>Audit / Reports</td>
					<td>Yes</td>
					<td>No</td>
					<td>No</td>
					<td><span class="badge bg-secondary">interceptor</span></td>
				</tr>
				<tr>
					<td>Communications hub</td>
					<td>Yes</td>
					<td>Yes</td>
					<td>No</td>
					<td><span class="badge bg-secondary">interceptor</span></td>
				</tr>
				<tr>
					<td>Create / archive cases</td>
					<td>Yes</td>
					<td>Yes</td>
					<td>No</td>
					<td><span class="badge bg-secondary">interceptor</span> + <span class="badge bg-info text-dark">service</span></td>
				</tr>
				<tr>
					<td>Edit case, post comms, upload docs</td>
					<td>Yes</td>
					<td>Only when assigned to the case</td>
					<td>No</td>
					<td><span class="badge bg-info text-dark">service</span></td>
				</tr>
				<tr>
					<td>List / view cases &amp; download documents</td>
					<td>All active</td>
					<td>All active</td>
					<td>Cases where creator or assignee</td>
					<td><span class="badge bg-info text-dark">service</span></td>
				</tr>
			</tbody>
		</table>
	</div>
	<p class="small text-muted mt-2">Full detail: <code>docs/DEV_NOTES.md</code> in the repository.</p>
</div>
</cfoutput>
