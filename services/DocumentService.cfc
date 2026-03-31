component singleton accessors="true" {

    property name="caseService" inject="CaseService";
    property name="coldbox" inject="coldbox";

    /**
     * Upload a file from a multipart form field and persist metadata.
     * @return struct { success: boolean, document?: any, error?: string }
     */
    public struct function uploadFromForm(
        required numeric caseId,
        required string title,
        string fileField = "documentFile"
    ) {
        var trimmedTitle = trim( arguments.title );
        if ( !len( trimmedTitle ) ) {
            return { success: false, error: "Document title is required." };
        }

        ensureDirectory( getTempRoot() );

        var uploaded = {};
        try {
            uploaded = fileUpload( getTempRoot(), arguments.fileField, "", "makeunique" );
        } catch ( any e ) {
            return { success: false, error: "Document upload failed. Please select a valid file." };
        }

        return persistUploadedFile(
            caseId = arguments.caseId,
            title = trimmedTitle,
            uploadedFile = uploaded
        );
    }

    /**
     * Persist a previously uploaded temp file and create Document metadata.
     * Useful for both handler flow and tests.
     */
    public struct function persistUploadedFile(
        required numeric caseId,
        required string title,
        required struct uploadedFile
    ) {
        var caseEntity = caseService.getActiveCase( arguments.caseId );
        if ( isNull( caseEntity ) ) {
            deleteTempUpload( arguments.uploadedFile );
            return { success: false, error: "Case not found or no longer active." };
        }

        var ext = lCase( trim( arguments.uploadedFile.serverFileExt ?: "" ) );
        if ( !isAllowedExtension( ext ) ) {
            deleteTempUpload( arguments.uploadedFile );
            return { success: false, error: "Invalid file type." };
        }

        var sizeBytes = val( arguments.uploadedFile.fileSize ?: 0 );
        if ( sizeBytes <= 0 ) {
            deleteTempUpload( arguments.uploadedFile );
            return { success: false, error: "Uploaded file is empty." };
        }
        if ( sizeBytes > getMaxBytes() ) {
            deleteTempUpload( arguments.uploadedFile );
            return { success: false, error: "Uploaded file exceeds the maximum allowed size." };
        }

        ensureDirectory( getStorageRoot() );

        var diskName = createUUID() & "." & ext;
        var sourcePath = buildPath( arguments.uploadedFile.serverDirectory, arguments.uploadedFile.serverFile );
        var destinationPath = buildPath( getStorageRoot(), diskName );

        try {
            fileMove( sourcePath, destinationPath );
        } catch ( any e ) {
            deleteIfExists( sourcePath );
            return { success: false, error: "Unable to store uploaded file." };
        }

        var doc = entityNew( "Document" );
        doc.setTitle( trim( arguments.title ) );
        doc.setFileName( diskName );
        doc.setFileSize( sizeBytes );
        doc.setFileType( ext );
        doc.setCaseRef( caseEntity );

        try {
            doc.save();
        } catch ( any e ) {
            deleteIfExists( destinationPath );
            return { success: false, error: "Unable to save document metadata." };
        }

        ormEvictEntity( "Document", doc.getDocumentId() );
        var persisted = entityLoad( "Document", doc.getDocumentId(), true );
        return { success: true, document: persisted };
    }

    /**
     * List documents for an active case only.
     */
    public array function listForCase( required numeric caseId ) {
        var caseEntity = caseService.getActiveCase( arguments.caseId );
        if ( isNull( caseEntity ) ) {
            return [];
        }
        return ormExecuteQuery(
            "FROM Document d WHERE d.caseRef.caseId = :caseId ORDER BY d.dateUploaded DESC, d.documentId DESC",
            { caseId: arguments.caseId },
            false
        );
    }

    /**
     * Resolve a document download target scoped to an active case.
     * @return struct { success: boolean, path?: string, fileName?: string, fileType?: string, error?: string }
     */
    public struct function resolveDownload(
        required numeric caseId,
        required numeric documentId
    ) {
        var caseEntity = caseService.getActiveCase( arguments.caseId );
        if ( isNull( caseEntity ) ) {
            return { success: false, error: "Case not found or no longer active." };
        }

        var doc = entityLoad( "Document", arguments.documentId, true );
        if ( isNull( doc ) || isNull( doc.getCaseRef() ) || doc.getCaseRef().getCaseId() != arguments.caseId ) {
            return { success: false, error: "Document not found for this case." };
        }

        var diskPath = buildPath( getStorageRoot(), doc.getFileName() );
        if ( !fileExists( diskPath ) ) {
            return { success: false, error: "Document file is missing from storage." };
        }

        return {
            success: true,
            path: diskPath,
            fileName: doc.getFileName(),
            fileType: doc.getFileType()
        };
    }

    /**
     * Return upload config for UI hints.
     */
    public struct function getUploadPolicy() {
        return {
            maxBytes: getMaxBytes(),
            allowedTypes: new models.constants.Document_File_Type().getValues()
        };
    }

    private boolean function isAllowedExtension( required string ext ) {
        return arrayFindNoCase( new models.constants.Document_File_Type().getValues(), arguments.ext ) > 0;
    }

    private numeric function getMaxBytes() {
        var settings = getUploadSettings();
        return val( settings.maxBytes ?: 10485760 );
    }

    private string function getStorageRoot() {
        var settings = getUploadSettings();
        return normalizeDir( settings.storageRoot ?: expandPath( "/uploads/documents" ) );
    }

    private string function getTempRoot() {
        var settings = getUploadSettings();
        return normalizeDir( settings.tempRoot ?: getTempDirectory() );
    }

    private struct function getUploadSettings() {
        var defaults = {
            storageRoot: expandPath( "/uploads/documents" ),
            tempRoot: getTempDirectory(),
            maxBytes: 10485760
        };
        try {
            var top = coldbox.getSetting( "servepoint" );
            if ( isStruct( top ) && structKeyExists( top, "documentUploads" ) && isStruct( top.documentUploads ) ) {
                return top.documentUploads;
            }
        } catch ( any e ) {
            // Fall back to defaults if settings are unavailable.
        }
        return defaults;
    }

    private void function deleteTempUpload( required struct uploadedFile ) {
        var sourcePath = buildPath( uploadedFile.serverDirectory ?: "", uploadedFile.serverFile ?: "" );
        deleteIfExists( sourcePath );
    }

    private void function deleteIfExists( required string fullPath ) {
        if ( len( trim( arguments.fullPath ) ) && fileExists( arguments.fullPath ) ) {
            try {
                fileDelete( arguments.fullPath );
            } catch ( any e ) {
                // Best-effort cleanup.
            }
        }
    }

    private void function ensureDirectory( required string dirPath ) {
        if ( !directoryExists( arguments.dirPath ) ) {
            directoryCreate( arguments.dirPath );
        }
    }

    private string function buildPath( required string dirPath, required string fileName ) {
        var base = normalizeDir( arguments.dirPath );
        return base & arguments.fileName;
    }

    private string function normalizeDir( required string dirPath ) {
        var normalized = replace( arguments.dirPath, chr( 92 ), "/", "all" );
        if ( right( normalized, 1 ) != "/" ) {
            normalized &= "/";
        }
        return normalized;
    }
}
