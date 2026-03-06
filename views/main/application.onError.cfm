<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>ServePoint – Error</title>

    <!-- Bootstrap & Icons (mirrors layouts/Main.cfm) -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65"
          crossorigin="anonymous">
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
</head>
<body class="d-flex flex-column h-100">

<cfoutput>
<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-15 text-center">
            <div class="card shadow-lg border-0">
                <div class="card-body p-5">
                    <div class="mb-4">
                        <i class="bi bi-exclamation-triangle-fill text-danger" style="font-size: 4rem;"></i>
                    </div>

                    <h1 class="display-4 text-danger mb-3">
                        An error occurred
                    </h1>

                    <p class="lead text-muted mb-4">
                        #encodeForHTML( errorMessage )#
                    </p>

                    <cfif structKeyExists( variables, "isDatabaseError" ) AND isDatabaseError>
                        <div class="alert alert-warning" role="alert">
                            <i class="bi bi-database-exclamation me-2"></i>
                            We are currently unable to connect to the application database. Please try again in a few minutes.
                        </div>
                    <cfelse>
                        <div class="alert alert-info" role="alert">
                            <i class="bi bi-info-circle me-2"></i>
                            Our team has been notified of this issue. You may be able to continue using the application by returning to the home page.
                        </div>
                    </cfif>

                    <!--- Full error details (for debugging; remove or restrict before production) --->
                    <cfif structKeyExists( variables, "errorType" ) OR structKeyExists( variables, "errorMessageRaw" )>
                        <div class="mt-4 text-start">
                            <h5 class="text-secondary mb-3">Error details</h5>
                            <div class="card bg-light">
                                <div class="card-body small font-monospace">
                                    <cfif structKeyExists( variables, "errorEventName" ) AND len( trim( errorEventName ) )>
                                        <p class="mb-1"><strong>Event:</strong> #encodeForHTML( errorEventName )#</p>
                                    </cfif>
                                    <cfif structKeyExists( variables, "errorType" ) AND len( trim( errorType ) )>
                                        <p class="mb-1"><strong>Type:</strong> #encodeForHTML( errorType )#</p>
                                    </cfif>
                                    <cfif structKeyExists( variables, "errorMessageRaw" ) AND len( trim( errorMessageRaw ) )>
                                        <p class="mb-1"><strong>Message:</strong> #encodeForHTML( errorMessageRaw )#</p>
                                    </cfif>
                                    <cfif structKeyExists( variables, "errorDetail" ) AND len( trim( errorDetail ) )>
                                        <p class="mb-1"><strong>Detail:</strong></p>
                                        <pre class="mb-2 p-2 bg-white border rounded overflow-auto" style="max-height: 10em;">#encodeForHTML( errorDetail )#</pre>
                                    </cfif>
                                    <cfif structKeyExists( variables, "errorStackTrace" ) AND len( trim( errorStackTrace ) )>
                                        <p class="mb-1"><strong>Stack trace:</strong></p>
                                        <pre class="mb-2 p-2 bg-white border rounded overflow-auto small" style="max-height: 12em;">#encodeForHTML( errorStackTrace )#</pre>
                                    </cfif>
                                    <cfif structKeyExists( variables, "errorRootCauseMessage" ) AND len( trim( errorRootCauseMessage ) )>
                                        <p class="mb-1"><strong>Root cause – Message:</strong> #encodeForHTML( errorRootCauseMessage )#</p>
                                    </cfif>
                                    <cfif structKeyExists( variables, "errorRootCauseDetail" ) AND len( trim( errorRootCauseDetail ) )>
                                        <p class="mb-1"><strong>Root cause – Detail:</strong></p>
                                        <pre class="mb-2 p-2 bg-white border rounded overflow-auto" style="max-height: 10em;">#encodeForHTML( errorRootCauseDetail )#</pre>
                                    </cfif>
                                    <!--- Tag context only when error originates in a file (template stack present) --->
                                    <cfif structKeyExists( variables, "errorTagContext" ) AND isArray( errorTagContext ) AND arrayLen( errorTagContext ) GT 0>
                                        <p class="mb-1"><strong>Tag context:</strong></p>
                                        <ul class="mb-2 ps-3">
                                            <cfloop array="#errorTagContext#" index="ctx">
                                                <cfset tagId = ( structKeyExists( ctx, "ID" ) && len( trim( ctx.ID ) ) ) ? ctx.ID : ( structKeyExists( ctx, "id" ) && len( trim( ctx.id ) ) ? ctx.id : "" )>
                                                <cfset templatePath = structKeyExists( ctx, "template" ) ? ctx.template : "">
                                                <cfset lineNum = structKeyExists( ctx, "line" ) ? ctx.line : "?">
                                                <li>
                                                    <cfif len( tagId )><strong>#encodeForHTML( tagId )#</strong><cfif len( templatePath )> – </cfif></cfif><cfif len( templatePath )>#encodeForHTML( templatePath )# (line #encodeForHTML( lineNum )#)</cfif>
                                                </li>
                                            </cfloop>
                                        </ul>
                                    </cfif>
                                    <cfif structKeyExists( variables, "errorExceptionJson" ) AND len( trim( errorExceptionJson ) )>
                                        <p class="mb-1"><strong>Exception (JSON):</strong></p>
                                        <pre class="mb-0 p-2 bg-white border rounded overflow-auto small" style="max-height: 20em;">#encodeForHTML( errorExceptionJson )#</pre>
                                    </cfif>
                                </div>
                            </div>
                        </div>
                    </cfif>

                    <div class="mt-4">
                        <a href="/" class="btn btn-primary btn-lg">
                            <i class="bi bi-house me-2"></i>
                            Return to Home
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</cfoutput>

<!-- Optional: Bootstrap JS bundle (not strictly required for static error page) -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-kenU1KFdBIe4zVF0s0G1M5b4hcpxyD9F7jL+jjXkk+Q2h455rYXK/7HAuoJl+0I4"
        crossorigin="anonymous"></script>

</body>
</html>


