component extends="coldbox.system.EventHandler" {

    property name="caseService" inject="CaseService";
    property name="documentService" inject="DocumentService";
    property name="securityService" inject="SecurityService";

    /**
     * Documents landing page. Optionally scoped to a specific active case.
     */
    // ColdBox passes this third argument as `prc`; keep this name for runtime compatibility.
    void function index( required any event, required struct rc, required struct prc ) {
        var u    = securityService.getCurrentUser();
        var role = securityService.getCurrentUserRole();
        prc.cases = caseService.listCasesForActor( u.getUserId(), role );
        prc.documentUploadPolicy = documentService.getUploadPolicy();
        prc.selectedCaseId = structKeyExists( rc, "caseId" ) && isNumeric( rc.caseId ) ? val( rc.caseId ) : 0;
        prc.documents = [];

        if ( prc.selectedCaseId > 0 ) {
            var caseEntity = caseService.getActiveCaseForActor( prc.selectedCaseId, u.getUserId(), role );
            if ( isNull( caseEntity ) ) {
                session.casesNotice = "Case not found or you do not have access.";
                relocate( "documents.index" );
                return;
            }
            prc.selectedCase = caseEntity;
            prc.documents = documentService.listForCase( prc.selectedCaseId );
        }

        prc.canUploadDocuments = ( role != "Citizen" );
        if ( structKeyExists( session, "casesNotice" ) && len( trim( session.casesNotice ) ) ) {
            prc.noticeMessage = session.casesNotice;
            structDelete( session, "casesNotice" );
        }
        event.setView( "documents/index" );
    }

    /**
     * POST: upload a document to an active case.
     */
    void function upload( required any event, required struct rc, required struct prc ) {
        if ( event.getHTTPMethod() != "POST" ) {
            relocate( "cases.index" );
            return;
        }

        var caseId = structKeyExists( rc, "caseId" ) && isNumeric( rc.caseId ) ? val( rc.caseId ) : 0;
        if ( caseId <= 0 ) {
            session.casesNotice = "Invalid case.";
            relocate( "cases.index" );
            return;
        }

        var u            = securityService.getCurrentUser();
        var uploadUserId = u.getUserId();

        var result = documentService.uploadFromForm(
            caseId = caseId,
            title = structKeyExists( rc, "title" ) ? trim( rc.title ) : "",
            fileField = "documentFile",
            userId = uploadUserId
        );

        session.casesNotice = result.success ? "Document uploaded successfully." : ( result.error ?: "Could not upload document." );
        relocate( url = event.buildLink( to = "documents.index", queryString = "caseId=#caseId#" ) );
    }

    /**
     * GET: download a document scoped to an active case.
     */
    void function download( required any event, required struct rc, required struct prc ) {
        var caseId = structKeyExists( rc, "caseId" ) && isNumeric( rc.caseId ) ? val( rc.caseId ) : 0;
        var documentId = structKeyExists( rc, "documentId" ) && isNumeric( rc.documentId ) ? val( rc.documentId ) : 0;
        if ( caseId <= 0 || documentId <= 0 ) {
            session.casesNotice = "Invalid document request.";
            relocate( "cases.index" );
            return;
        }

        var u        = securityService.getCurrentUser();
        var resolved = documentService.resolveDownload(
            caseId = caseId,
            documentId = documentId,
            userId = u.getUserId()
        );
        if ( !resolved.success ) {
            session.casesNotice = resolved.error ?: "Document not found.";
            relocate( url = event.buildLink( to = "documents.index", queryString = "caseId=#caseId#" ) );
            return;
        }

        event.setHTTPHeader( name = "Content-Disposition", value = 'attachment; filename="#resolved.fileName#"' );
        event.setHTTPHeader( name = "X-Content-Type-Options", value = "nosniff" );
        // Adobe CF: cfcontent variable= is picky (String vs binary, scope). Streaming from a temp file is reliable.
        var tmpPath = getTempDirectory() & "servepoint-doc-dl-" & createUUID() & ".bin";
        try {
            fileWrite( tmpPath, resolved.fileContent );
            cfcontent( type = getMimeTypeForExtension( resolved.fileType ), file = tmpPath, deleteFile = "yes" );
        } finally {
            if ( fileExists( tmpPath ) ) {
                try {
                    fileDelete( tmpPath );
                } catch ( any delErr ) {
                }
            }
        }
        event.noRender();
    }

    private string function getMimeTypeForExtension( required string fileType ) {
        switch ( lCase( arguments.fileType ) ) {
            case "pdf":
                return "application/pdf";
            case "docx":
                return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
            case "png":
                return "image/png";
            case "jpg":
            case "jpeg":
                return "image/jpeg";
            default:
                return "application/octet-stream";
        }
    }
}
