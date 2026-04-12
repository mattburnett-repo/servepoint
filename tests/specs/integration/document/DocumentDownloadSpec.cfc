component extends="tests.specs.BaseIntegrationTestCase" appMapping="/root" {

    void function run() {
        describe( "Document download", function() {

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
                var caseId = created.case.getCaseId();
                var documentId = 0;
                try {
                    var tempFile = createTempUploadFile( "pdf" );
                    var uploaded = documentService.persistUploadedFile(
                        caseId = caseId,
                        title = "Resolve Target",
                        uploadedFile = tempFile
                    );
                    expect( uploaded.success ).toBeTrue();
                    documentId = uploaded.document.getDocumentId();

                    var resolved = documentService.resolveDownload(
                        caseId = caseId,
                        documentId = documentId
                    );
                    expect( resolved.success ).toBeTrue();
                    expect( fileExists( resolved.storagePath ) ).toBeTrue();
                    expect( len( resolved.fileContent ) ).toBeGT( 0 );
                    expect( resolved.fileType ).toBe( "pdf" );
                    expect( len( trim( resolved.fileName ) ) ).toBeGT( 0 );
                } finally {
                    deleteStoredDocumentFileIfPresent( documentService, caseId, documentId );
                }
            } );

            it( "resolveDownload records a Document Download log when userId is provided", function() {
                var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
                var caseService = getWireBox().getInstance( "CaseService" );
                var documentService = getWireBox().getInstance( "DocumentService" );
                var created = caseService.createCase(
                    title = "Doc download logs " & createUUID(),
                    description = "",
                    status = "New",
                    creatorUserId = admin.getUserId(),
                    assignedToUserId = admin.getUserId()
                );
                var caseId = created.case.getCaseId();
                var documentId = 0;
                try {
                    var tempFile = createTempUploadFile( "pdf" );
                    var uploaded = documentService.persistUploadedFile(
                        caseId = caseId,
                        title = "Download Audit Target",
                        uploadedFile = tempFile,
                        userId = admin.getUserId()
                    );
                    expect( uploaded.success ).toBeTrue();
                    documentId = uploaded.document.getDocumentId();

                    var resolved = documentService.resolveDownload(
                        caseId = caseId,
                        documentId = documentId,
                        userId = admin.getUserId()
                    );
                    expect( resolved.success ).toBeTrue();

                    var activityRows = ormExecuteQuery(
                        "FROM AuditEvent ae WHERE ae.caseRef.caseId = :caseId AND ae.eventType = :eventType ORDER BY ae.auditEventId DESC",
                        {
                            caseId : caseId,
                            eventType : "Document Download"
                        },
                        false
                    );
                    expect( arrayLen( activityRows ) ).toBeGTE( 1 );
                    expect( activityRows[ 1 ].getEntryText() ).toInclude( "Document downloaded (ID" );
                } finally {
                    deleteStoredDocumentFileIfPresent( documentService, caseId, documentId );
                }
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
                var caseIdA = createdA.case.getCaseId();
                var documentId = 0;
                try {
                    var tempFile = createTempUploadFile( "pdf" );
                    var uploaded = documentService.persistUploadedFile(
                        caseId = caseIdA,
                        title = "Mismatch Target",
                        uploadedFile = tempFile
                    );
                    expect( uploaded.success ).toBeTrue();
                    documentId = uploaded.document.getDocumentId();

                    var resolved = documentService.resolveDownload(
                        caseId = createdB.case.getCaseId(),
                        documentId = documentId
                    );
                    expect( resolved.success ).toBeFalse();
                    expect( resolved.error ).toInclude( "not found for this case" );
                } finally {
                    deleteStoredDocumentFileIfPresent( documentService, caseIdA, documentId );
                }
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
                var caseId = created.case.getCaseId();
                var documentId = 0;
                try {
                    var tempFile = createTempUploadFile( "pdf" );
                    var uploaded = documentService.persistUploadedFile(
                        caseId = caseId,
                        title = "Delete Me",
                        uploadedFile = tempFile
                    );
                    expect( uploaded.success ).toBeTrue();
                    documentId = uploaded.document.getDocumentId();

                    var firstResolve = documentService.resolveDownload(
                        caseId = caseId,
                        documentId = documentId
                    );
                    expect( firstResolve.success ).toBeTrue();
                    fileDelete( firstResolve.storagePath );

                    var missing = documentService.resolveDownload(
                        caseId = caseId,
                        documentId = documentId
                    );
                    expect( missing.success ).toBeFalse();
                    expect( missing.error ).toInclude( "missing from storage" );
                } finally {
                    deleteStoredDocumentFileIfPresent( documentService, caseId, documentId );
                }
            } );

            it( "documents.download rejects invalid request", function() {
                this.loginAsSeedUser( "admin@example.com" );
                var event = this.get( "documents.download", { caseId = 0, documentId = 0 }, {}, false );
                expect( event.getValue( "relocate_event", "" ) ).toBe( "cases.index" );
            } );

            it( "documents.download relocates when document is not in selected case", function() {
                this.loginAsSeedUser( "admin@example.com" );
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
                var caseIdA = createdA.case.getCaseId();
                var documentId = 0;
                try {
                    var tempFile = createTempUploadFile( "pdf" );
                    var uploaded = documentService.persistUploadedFile(
                        caseId = caseIdA,
                        title = "Download Mismatch",
                        uploadedFile = tempFile
                    );
                    expect( uploaded.success ).toBeTrue();
                    documentId = uploaded.document.getDocumentId();

                    var event = this.get(
                        "documents.download",
                        {
                            caseId = createdB.case.getCaseId(),
                            documentId = documentId
                        },
                        {},
                        false
                    );
                    // Relocate target can be represented differently in test harness; assert user-visible behavior.
                    expect( structKeyExists( session, "casesNotice" ) ).toBeTrue();
                    expect( session.casesNotice ).toInclude( "not found for this case" );
                } finally {
                    deleteStoredDocumentFileIfPresent( documentService, caseIdA, documentId );
                }
            } );

        } );
    }

    /**
     * Removes a persisted file under uploads/documents; DB rows roll back separately in integration specs.
     */
    private void function deleteStoredDocumentFileIfPresent( required any documentService, required numeric caseId, required numeric documentId ) {
        if ( arguments.documentId <= 0 ) {
            return;
        }
        var resolved = arguments.documentService.resolveDownload( caseId = arguments.caseId, documentId = arguments.documentId );
        if ( resolved.success && structKeyExists( resolved, "storagePath" ) && fileExists( resolved.storagePath ) ) {
            fileDelete( resolved.storagePath );
        }
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
