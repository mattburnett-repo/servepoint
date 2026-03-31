component extends="coldbox.system.testing.BaseTestCase" appMapping="/root" {

    void function run() {
        describe( "Document upload", function() {

            beforeEach( function( currentSpec ) {
                setup();
                getWireBox().getInstance( "CaseService" ).restoreAllArchived();
            } );

            it( "DocumentService.persistUploadedFile stores metadata and lists by case", function() {
                var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
                var caseService = getWireBox().getInstance( "CaseService" );
                var documentService = getWireBox().getInstance( "DocumentService" );
                var created = caseService.createCase(
                    title = "Doc upload happy " & createUUID(),
                    description = "",
                    status = "New",
                    creatorUserId = admin.getUserId(),
                    assignedToUserId = admin.getUserId()
                );
                expect( created.success ).toBeTrue();

                var tempFile = createTempUploadFile( "pdf" );
                var result = documentService.persistUploadedFile(
                    caseId = created.case.getCaseId(),
                    title = "Intake PDF",
                    uploadedFile = tempFile
                );

                expect( result.success ).toBeTrue();
                expect( isNull( result.document ) ).toBeFalse();
                expect( result.document.getDocumentId() ).toBeGT( 0 );

                var listed = documentService.listForCase( created.case.getCaseId() );
                expect( arrayLen( listed ) ).toBeGTE( 1 );
                expect( listed[ 1 ].getCaseRef().getCaseId() ).toBe( created.case.getCaseId() );
            } );

            it( "rejects invalid file type", function() {
                var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
                var caseService = getWireBox().getInstance( "CaseService" );
                var documentService = getWireBox().getInstance( "DocumentService" );
                var created = caseService.createCase(
                    title = "Doc upload bad type " & createUUID(),
                    description = "",
                    status = "New",
                    creatorUserId = admin.getUserId(),
                    assignedToUserId = admin.getUserId()
                );
                var tempFile = createTempUploadFile( "exe" );
                var result = documentService.persistUploadedFile(
                    caseId = created.case.getCaseId(),
                    title = "Bad Type",
                    uploadedFile = tempFile
                );
                expect( result.success ).toBeFalse();
                expect( result.error ).toInclude( "Invalid file type" );
            } );

            it( "rejects oversized file metadata", function() {
                var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
                var caseService = getWireBox().getInstance( "CaseService" );
                var documentService = getWireBox().getInstance( "DocumentService" );
                var created = caseService.createCase(
                    title = "Doc upload oversize " & createUUID(),
                    description = "",
                    status = "New",
                    creatorUserId = admin.getUserId(),
                    assignedToUserId = admin.getUserId()
                );
                var tempFile = createTempUploadFile( "pdf" );
                tempFile.fileSize = 999999999;

                var result = documentService.persistUploadedFile(
                    caseId = created.case.getCaseId(),
                    title = "Too Big",
                    uploadedFile = tempFile
                );
                expect( result.success ).toBeFalse();
                expect( result.error ).toInclude( "maximum allowed size" );
            } );

            it( "rejects upload to archived case", function() {
                var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
                var caseService = getWireBox().getInstance( "CaseService" );
                var documentService = getWireBox().getInstance( "DocumentService" );
                var created = caseService.createCase(
                    title = "Doc upload archived " & createUUID(),
                    description = "",
                    status = "New",
                    creatorUserId = admin.getUserId(),
                    assignedToUserId = admin.getUserId()
                );
                var archived = caseService.archiveCase(
                    caseId = created.case.getCaseId(),
                    userId = admin.getUserId(),
                    reason = "Archive for upload guard test."
                );
                expect( archived.success ).toBeTrue();

                var tempFile = createTempUploadFile( "pdf" );
                var result = documentService.persistUploadedFile(
                    caseId = created.case.getCaseId(),
                    title = "Archived Case File",
                    uploadedFile = tempFile
                );
                expect( result.success ).toBeFalse();
                expect( result.error ).toInclude( "no longer active" );
            } );

            it( "uploadFromForm rejects blank title before attempting file upload", function() {
                var documentService = getWireBox().getInstance( "DocumentService" );
                var result = documentService.uploadFromForm(
                    caseId = 999999,
                    title = "   ",
                    fileField = "documentFile"
                );
                expect( result.success ).toBeFalse();
                expect( result.error ).toBe( "Document title is required." );
            } );

            it( "listForCase returns empty array for invalid case", function() {
                var documentService = getWireBox().getInstance( "DocumentService" );
                var listed = documentService.listForCase( 999999 );
                expect( isArray( listed ) ).toBeTrue();
                expect( arrayLen( listed ) ).toBe( 0 );
            } );

            it( "documents.upload rejects missing case id", function() {
                var event = this.post( "documents.upload", {}, {}, false );
                expect( event.getValue( "relocate_event", "" ) ).toBe( "cases.index" );
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
