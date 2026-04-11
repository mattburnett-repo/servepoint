component singleton accessors="true" {

    property name="caseService" inject="CaseService";
    property name="coldbox" inject="coldbox";
    property name="auditLoggerService" inject="AuditLoggerService";

    /**
     * Upload a file from a multipart form field and persist metadata.
     * @return struct { success: boolean, document?: any, error?: string }
     */
    public struct function uploadFromForm(
        required numeric caseId,
        required string title,
        string fileField = "documentFile",
        numeric userId = 0
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
            uploadedFile = uploaded,
            userId = arguments.userId
        );
    }

    /**
     * Persist a previously uploaded temp file and create Document metadata.
     * Useful for both handler flow and tests.
     */
    public struct function persistUploadedFile(
        required numeric caseId,
        required string title,
        required struct uploadedFile,
        numeric userId = 0
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

        var encryptResult = encryptDocumentFileAtPath( destinationPath );
        if ( !encryptResult.ok ) {
            return { success: false, error: encryptResult.error ?: "Unable to encrypt stored document." };
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
        if ( arguments.userId > 0 ) {
            auditLoggerService.record(
                category    = "document",
                eventType   = "Document Upload",
                outcome     = "success",
                actorUserId = arguments.userId,
                caseId      = arguments.caseId,
                documentId  = persisted.getDocumentId(),
                message     = "Document uploaded (ID " & persisted.getDocumentId() & ") for case ID " & arguments.caseId &
                    ": " & persisted.getTitle() & " (" & persisted.getFileName() & ", " & persisted.getFileType() &
                    ", " & persisted.getFileSize() & " bytes)."
            );
        }
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
     * Resolve a document download: decrypt in memory when stored with the SP1ENC01 envelope.
     * @return struct { success, fileContent?, storagePath?, fileName?, fileType?, documentTitle?, error? }
     */
    public struct function resolveDownload(
        required numeric caseId,
        required numeric documentId,
        numeric userId = 0
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

        if ( arguments.userId > 0 ) {
            recordDownloadEvent(
                caseId = arguments.caseId,
                userId = arguments.userId,
                document = doc
            );
        }

        var raw = fileReadBinary( diskPath );
        var fileContent = raw;

        if ( documentFileHasEncryptionHeader( raw ) ) {
            var kv = validateDocumentEncryptionKey();
            if ( !kv.ok ) {
                return { success: false, error: kv.error };
            }
            try {
                fileContent = decryptBlobToPlaintext( raw, kv.key );
            } catch ( any e ) {
                return { success: false, error: "Unable to decrypt document file." };
            }
        }

        return {
            success: true,
            fileContent: toCfBinaryForContent( fileContent ),
            storagePath: diskPath,
            fileName: doc.getFileName(),
            fileType: doc.getFileType(),
            documentTitle: doc.getTitle()
        };
    }

    /**
     * Canonical CF binary for file I/O: Java byte[] / mixed types do not always round-trip through structs.
     * Always copy through ByteArrayOutputStream + base64 so fileWrite/cfcontent see real binary.
     */
    private binary function toCfBinaryForContent( required any value ) {
        var baos = createObject( "java", "java.io.ByteArrayOutputStream" ).init();
        baos.write( arguments.value );
        return binaryDecode( binaryEncode( baos.toByteArray(), "base64" ), "base64" );
    }

    /**
     * Record a document download activity line for reporting and case audit history.
     */
    public void function recordDownloadEvent(
        required numeric caseId,
        required numeric userId,
        required Document document
    ) {
        auditLoggerService.record(
            category    = "document",
            eventType   = "Document Download",
            outcome     = "success",
            actorUserId = arguments.userId,
            caseId      = arguments.caseId,
            documentId  = arguments.document.getDocumentId(),
            message     = "Document downloaded (ID " & arguments.document.getDocumentId() & ") for case ID " & arguments.caseId &
                ": " & arguments.document.getTitle() & " (" & arguments.document.getFileName() & ")."
        );
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
            maxBytes: 10485760,
            encryptionKeyBase64: ""
        };
        var merged = duplicate( defaults );
        try {
            var top = coldbox.getSetting( "servepoint" );
            if ( isStruct( top ) && structKeyExists( top, "documentUploads" ) && isStruct( top.documentUploads ) ) {
                structAppend( merged, top.documentUploads, true );
            }
        } catch ( any e ) {
            // Keep merged defaults if settings are unavailable.
        }
        if ( !len( trim( merged.encryptionKeyBase64 ?: "" ) ) ) {
            var sys = createObject( "java", "java.lang.System" );
            var fromEnv = sys.getEnv( "SERVEPOINT_DOCUMENT_ENCRYPTION_KEY" );
            if ( !isNull( fromEnv ) && len( trim( fromEnv ) ) ) {
                merged.encryptionKeyBase64 = trim( fromEnv );
            }
        }
        return merged;
    }

    /**
     * AES-256-GCM; on-disk format: magic "SP1ENC01" (8) + nonce (12) + ciphertext (includes GCM tag).
     */
    private struct function encryptDocumentFileAtPath( required string destinationPath ) {
        var kv = validateDocumentEncryptionKey();
        if ( !kv.ok ) {
            deleteIfExists( arguments.destinationPath );
            return { ok: false, error: kv.error };
        }
        try {
            var plain = fileReadBinary( arguments.destinationPath );
            var enc = encryptPlaintextToBlob( plain, kv.key );
            fileWrite( arguments.destinationPath, enc );
            return { ok: true };
        } catch ( any e ) {
            deleteIfExists( arguments.destinationPath );
            return { ok: false, error: "Unable to encrypt stored document." };
        }
    }

    private struct function validateDocumentEncryptionKey() {
        var b64 = trim( getUploadSettings().encryptionKeyBase64 ?: "" );
        if ( !len( b64 ) ) {
            return { ok: false, error: "Document encryption is not configured." };
        }
        var decoded = "";
        try {
            decoded = binaryDecode( b64, "Base64" );
        } catch ( any e ) {
            return { ok: false, error: "SERVEPOINT_DOCUMENT_ENCRYPTION_KEY is not valid base64." };
        }
        if ( len( decoded ) != 32 ) {
            return { ok: false, error: "SERVEPOINT_DOCUMENT_ENCRYPTION_KEY must decode to exactly 32 bytes (AES-256)." };
        }
        return { ok: true, key: decoded };
    }

    /** Lucee has binaryPart(); Adobe CF does not — same semantics via Arrays.copyOfRange (1-based start, length). */
    private binary function binaryByteRange( required binary data, required numeric startOneBased, required numeric byteLength ) {
        var from0 = val( arguments.startOneBased ) - 1;
        var to0 = from0 + val( arguments.byteLength );
        return createObject( "java", "java.util.Arrays" ).copyOfRange( arguments.data, from0, to0 );
    }

    private boolean function documentFileHasEncryptionHeader( required binary data ) {
        if ( len( arguments.data ) < 36 ) {
            return false;
        }
        var expected = charsetDecode( "SP1ENC01", "utf-8" );
        var got = binaryByteRange( arguments.data, 1, 8 );
        return binaryEncode( got, "hex" ) == binaryEncode( expected, "hex" );
    }

    private binary function encryptPlaintextToBlob( required binary plaintext, required binary key32 ) {
        var Cipher = createObject( "java", "javax.crypto.Cipher" );
        var cipher = Cipher.getInstance( "AES/GCM/NoPadding" );
        var sr = createObject( "java", "java.security.SecureRandom" ).init();
        var componentByte = createObject( "java", "java.lang.Class" ).forName( "[B" ).getComponentType();
        var nonce = createObject( "java", "java.lang.reflect.Array" ).newInstance( componentByte, 12 );
        sr.nextBytes( nonce );
        var gcmSpec = createObject( "java", "javax.crypto.spec.GCMParameterSpec" ).init( 128, nonce );
        var sk = createObject( "java", "javax.crypto.spec.SecretKeySpec" ).init( arguments.key32, "AES" );
        cipher.init( 1, sk, gcmSpec );
        var ciphertext = cipher.doFinal( arguments.plaintext );
        var magic = charsetDecode( "SP1ENC01", "utf-8" );
        return binaryConcat3( magic, nonce, ciphertext );
    }

    private binary function decryptBlobToPlaintext( required binary blob, required binary key32 ) {
        var ct = binaryByteRange( arguments.blob, 21, len( arguments.blob ) - 20 );
        var nonce = binaryByteRange( arguments.blob, 9, 12 );
        var Cipher = createObject( "java", "javax.crypto.Cipher" );
        var cipher = Cipher.getInstance( "AES/GCM/NoPadding" );
        var gcmSpec = createObject( "java", "javax.crypto.spec.GCMParameterSpec" ).init( 128, nonce );
        var sk = createObject( "java", "javax.crypto.spec.SecretKeySpec" ).init( arguments.key32, "AES" );
        cipher.init( 2, sk, gcmSpec );
        return cipher.doFinal( ct );
    }

    private binary function binaryConcat3( required binary a, required binary b, required binary c ) {
        var baos = createObject( "java", "java.io.ByteArrayOutputStream" ).init();
        baos.write( arguments.a );
        baos.write( arguments.b );
        baos.write( arguments.c );
        return baos.toByteArray();
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
