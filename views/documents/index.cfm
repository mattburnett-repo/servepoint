<cfoutput>
<cfset cases = structKeyExists( prc, "cases" ) ? prc.cases : [] />
<cfset docs = structKeyExists( prc, "documents" ) ? prc.documents : [] />
<cfset selectedCaseId = structKeyExists( prc, "selectedCaseId" ) ? prc.selectedCaseId : 0 />
<cfset hasSelectedCase = structKeyExists( prc, "selectedCase" ) && !isNull( prc.selectedCase ) />
<cfset storagePersistent = structKeyExists( prc, "storagePersistent" ) ? prc.storagePersistent : true />
<cfset uploadPolicy = structKeyExists( prc, "documentUploadPolicy" ) ? prc.documentUploadPolicy : { "maxBytes" = 0, "allowedTypes" = [] } />
<cfset maxUploadMB = int( val( uploadPolicy[ "maxBytes" ] ) / 1048576 ) />
<cfset wholeFmt = createObject( "java", "java.text.DecimalFormat" ).init( "##,##0" ) />
<cfset decFmt = createObject( "java", "java.text.DecimalFormat" ).init( "##,##0.0" ) />

<div class="container py-4 col-lg-10">
	<div class="d-flex flex-wrap align-items-center justify-content-between gap-2 mb-4">
		<div class="d-flex flex-wrap align-items-center gap-2 gap-md-3">
			<h1 class="h2 mb-0 text-primary">
				<i class="bi bi-file-earmark-arrow-up" aria-hidden="true"></i> Documents
			</h1>
			<a href="#event.buildLink( "main.index" )#" class="btn btn-outline-secondary">
				<i class="bi bi-house" aria-hidden="true"></i> Home
			</a>
		</div>
		<a href="#event.buildLink( "cases.index" )#" class="btn btn-outline-secondary">Back to cases</a>
	</div>

	<cfif structKeyExists( prc, "noticeMessage" ) && len( trim( prc.noticeMessage ) )>
		<div class="alert alert-success" role="alert">
			#encodeForHTML( prc.noticeMessage )#
		</div>
	</cfif>
	<cfif !storagePersistent>
		<div class="alert alert-warning" role="alert">
			Demo storage mode is active: uploaded files may be cleared on restart or redeploy.
		</div>
	</cfif>

	<div class="card shadow-sm mb-4">
		<div class="card-header bg-light">
			<h2 class="h5 mb-0">Select case</h2>
		</div>
		<div class="card-body">
			<form method="get" action="#event.buildLink( "documents.index" )#" class="row g-3 align-items-end">
				<div class="col-md-8">
					<label for="document-case-id" class="form-label">Active case</label>
					<select class="form-select" id="document-case-id" name="caseId" required>
						<option value="">Choose an active case...</option>
						<cfloop array="#cases#" index="c">
							<option value="#c.getCaseId()#" <cfif selectedCaseId eq c.getCaseId()>selected</cfif>>
								## #c.getCaseId()#: #encodeForHTML( c.getTitle() )#
							</option>
						</cfloop>
					</select>
				</div>
				<div class="col-md-4">
					<button type="submit" class="btn btn-primary w-100">Show Documents for This Case</button>
				</div>
			</form>
		</div>
	</div>

	<cfif hasSelectedCase>
		<div class="card shadow-sm mb-4">
			<div class="card-header bg-light">
				<h2 class="h5 mb-0">Upload document</h2>
			</div>
			<div class="card-body">
				<form method="post" action="#event.buildLink( "documents.upload" )#" enctype="multipart/form-data" class="row g-3">
					<input type="hidden" name="caseId" value="#prc.selectedCase.getCaseId()#">
					<div class="col-md-6">
						<label for="document-title" class="form-label">Document title <span class="text-danger">*</span></label>
						<input type="text" class="form-control" id="document-title" name="title" required maxlength="255">
					</div>
					<div class="col-md-6">
						<label for="document-file" class="form-label">File <span class="text-danger">*</span></label>
						<input type="file" class="form-control" id="document-file" name="documentFile" required aria-describedby="document-file-hint">
						<div id="document-file-hint" class="form-text">
							Allowed types: #encodeForHTML( arrayToList( uploadPolicy[ "allowedTypes" ], ", " ) )#<cfif maxUploadMB GT 0> | Max size: #maxUploadMB# MB</cfif>
						</div>
					</div>
					<div class="col-12">
						<button type="submit" class="btn btn-primary">Upload document</button>
					</div>
				</form>
			</div>
		</div>

		<div class="card shadow-sm">
			<div class="card-header bg-light">
				<h2 class="h5 mb-0">Documents for case ## #prc.selectedCase.getCaseId()#</h2>
			</div>
			<div class="card-body">
				<cfif arrayLen( docs )>
					<div class="table-responsive">
						<table class="table table-sm align-middle">
							<thead>
								<tr>
									<th scope="col">Title</th>
									<th scope="col">Type</th>
									<th scope="col">Size (bytes)</th>
									<th scope="col">Uploaded</th>
									<th scope="col" class="text-end">Actions</th>
								</tr>
							</thead>
							<tbody>
								<cfloop array="#docs#" index="d">
									<cfset sizeBytes = val( d.getFileSize() ) />
									<cfset sizeLabel = "" />
									<cfif sizeBytes LT 1024>
										<cfset sizeLabel = wholeFmt.format( javaCast( "double", sizeBytes ) ) & " B" />
									<cfelseif sizeBytes LT 1048576>
										<cfset sizeLabel = decFmt.format( javaCast( "double", sizeBytes / 1024 ) ) & " KB" />
									<cfelseif sizeBytes LT 1073741824>
										<cfset sizeLabel = decFmt.format( javaCast( "double", sizeBytes / 1048576 ) ) & " MB" />
									<cfelse>
										<cfset sizeLabel = decFmt.format( javaCast( "double", sizeBytes / 1073741824 ) ) & " GB" />
									</cfif>
									<tr>
										<td>#encodeForHTML( d.getTitle() )#</td>
										<td>#encodeForHTML( uCase( d.getFileType() ) )#</td>
										<td>#encodeForHTML( sizeLabel )#</td>
										<td>
											<cfif !isNull( d.getDateUploaded() )>
												<time datetime="#dateFormat( d.getDateUploaded(), "yyyy-mm-dd" )#T#timeFormat( d.getDateUploaded(), "HH:mm:ss" )#">#dateFormat( d.getDateUploaded(), "medium" )# #timeFormat( d.getDateUploaded(), "short" )#</time>
											<cfelse>
												<span class="text-muted">&mdash;</span>
											</cfif>
										</td>
										<td class="text-end">
											<a class="btn btn-sm btn-outline-primary" href="#event.buildLink( to = "documents.download", queryString = "caseId=#prc.selectedCase.getCaseId()#&documentId=#d.getDocumentId()#" )#">Download</a>
										</td>
									</tr>
								</cfloop>
							</tbody>
						</table>
					</div>
				<cfelse>
					<p class="text-muted mb-0">No documents uploaded for this case yet.</p>
				</cfif>
			</div>
		</div>
	</cfif>
</div>
</cfoutput>
