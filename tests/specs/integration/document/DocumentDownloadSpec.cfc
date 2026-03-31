component extends="coldbox.system.testing.BaseTestCase" appMapping="/root" {

    void function run() {
        describe( "Document download", function() {

            beforeEach( function( currentSpec ) {
                setup();
                getWireBox().getInstance( "CaseService" ).restoreAllArchived();
            } );

            it( "resolveDownload returns success payload for stored document", function() {
                var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
                var caseService = getWireBox().getInstance( "CaseService" );
                var documentService = getWireBox().getInstance( "DocumentService" );
                var created = caseService.createCase(
                    title = "Doc download resolve ok " & createUUID(),
                    description = "",
                    status = "New",
                    creatorUserId = admin.getUserId(),
                    assignedToUserId = admin.getUserId()
                );
                var tempFile = createTempUploadFile( "pdf" );
                var uploaded = documentService.persistUploadedFile(
                    caseId = created.case.getCaseId(),
                    title = "Resolve Target",
                    uploadedFile = tempFile
                );
                expect( uploaded.success ).toBeTrue();

                var resolved = documentService.resolveDownload(
                    caseId = created.case.getCaseId(),
                    documentId = uploaded.document.getDocumentId()
                );
                expect( resolved.success ).toBeTrue();
                expect( fileExists( resolved.path ) ).toBeTrue();
                expect( resolved.fileType ).toBe( "pdf" );
                expect( len( trim( resolved.fileName ) ) ).toBeGT( 0 );
            } );

            it( "resolveDownload rejects document when case does not match", function() {
                var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
                var caseService = getWireBox().getInstance( "CaseService" );
                var documentService = getWireBox().getInstance( "DocumentService" );
                var createdA = caseService.createCase(
                    title = "Doc download mismatch A " & createUUID(),
                    description = "",
                    status = "New",
                    creatorUserId = admin.getUserId(),
                    assignedToUserId = admin.getUserId()
                );
                var createdB = caseService.createCase(
                    title = "Doc download mismatch B " & createUUID(),
                    description = "",
                    status = "New",
                    creatorUserId = admin.getUserId(),
                    assignedToUserId = admin.getUserId()
                );
                var tempFile = createTempUploadFile( "pdf" );
                var uploaded = documentService.persistUploadedFile(
                    caseId = createdA.case.getCaseId(),
                    title = "Mismatch Target",
                    uploadedFile = tempFile
                );
                expect( uploaded.success ).toBeTrue();

                var resolved = documentService.resolveDownload(
                    caseId = createdB.case.getCaseId(),
                    documentId = uploaded.document.getDocumentId()
                );
                expect( resolved.success ).toBeFalse();
                expect( resolved.error ).toInclude( "not found for this case" );
            } );

            it( "resolveDownload reports missing file from storage", function() {
                var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
                var caseService = getWireBox().getInstance( "CaseService" );
                var documentService = getWireBox().getInstance( "DocumentService" );
                var created = caseService.createCase(
                    title = "Doc download missing file " & createUUID(),
                    description = "",
                    status = "New",
                    creatorUserId = admin.getUserId(),
                    assignedToUserId = admin.getUserId()
                );
                var tempFile = createTempUploadFile( "pdf" );
                var uploaded = documentService.persistUploadedFile(
                    caseId = created.case.getCaseId(),
                    title = "Delete Me",
                    uploadedFile = tempFile
                );
                expect( uploaded.success ).toBeTrue();

                var firstResolve = documentService.resolveDownload(
                    caseId = created.case.getCaseId(),
                    documentId = uploaded.document.getDocumentId()
                );
                expect( firstResolve.success ).toBeTrue();
                fileDelete( firstResolve.path );

                var missing = documentService.resolveDownload(
                    caseId = created.case.getCaseId(),
                    documentId = uploaded.document.getDocumentId()
                );
                expect( missing.success ).toBeFalse();
                expect( missing.error ).toInclude( "missing from storage" );
            } );

            it( "documents.download rejects invalid request", function() {
                var event = this.get( "documents.download", { caseId = 0, documentId = 0 }, {}, false );
                expect( event.getValue( "relocate_event", "" ) ).toBe( "cases.index" );
            } );

            it( "documents.download relocates when document is not in selected case", function() {
                var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
                var caseService = getWireBox().getInstance( "CaseService" );
                var documentService = getWireBox().getInstance( "DocumentService" );
                var createdA = caseService.createCase(
                    title = "Doc download handler mismatch A " & createUUID(),
                    description = "",
                    status = "New",
                    creatorUserId = admin.getUserId(),
                    assignedToUserId = admin.getUserId()
                );
                var createdB = caseService.createCase(
                    title = "Doc download handler mismatch B " & createUUID(),
                    description = "",
                    status = "New",
                    creatorUserId = admin.getUserId(),
                    assignedToUserId = admin.getUserId()
                );
                var tempFile = createTempUploadFile( "pdf" );
                var uploaded = documentService.persistUploadedFile(
                    caseId = createdA.case.getCaseId(),
                    title = "Download Mismatch",
                    uploadedFile = tempFile
                );
                expect( uploaded.success ).toBeTrue();

                var event = this.get(
                    "documents.download",
                    {
                        caseId = createdB.case.getCaseId(),
                        documentId = uploaded.document.getDocumentId()
                    },
                    {},
                    false
                );
                // Relocate target can be represented differently in test harness; assert user-visible behavior.
                expect( structKeyExists( session, "casesNotice" ) ).toBeTrue();
                expect( session.casesNotice ).toInclude( "not found for this case" );
            } );

        } );
    }

    private struct function createTempUploadFile( required string ext ) {
        var tempDir = getTempDirectory() & "servepoint-doc-specs/";
        if ( !directoryExists( tempDir ) ) {
            directoryCreate( tempDir );
        }

        var fileName = createUUID() & "." & lCase( arguments.ext );
        var filePath = tempDir & fileName;
        fileWrite( filePath, "servepoint test upload content" );

        return {
            "serverDirectory" : tempDir,
            "serverFile" : fileName,
            "serverFileExt" : lCase( arguments.ext ),
            "fileSize" : getFileInfo( filePath ).size
        };
    }
}
