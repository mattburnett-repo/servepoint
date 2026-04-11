component {
    function configure(){
        coldbox = {
            appName: "ServePoint",
            autoMapModels: true,
            jsonPayloadToRC: true
        };

        modules = { include:[ "cborm", "cfmigrations" ], exclude:[] };

        var sys = createObject("java", "java.lang.System");
        var ormDbcreateRaw = sys.getEnv("ORM_DBCREATE");
        var ormDbcreateAllowed = "validate,update,dropcreate,none";
        var uploadStorageRoot = sys.getEnv( "SERVEPOINT_DOCUMENT_STORAGE_ROOT" );
        var uploadTempRoot = sys.getEnv( "SERVEPOINT_DOCUMENT_TEMP_ROOT" );
        var uploadMaxBytesRaw = sys.getEnv( "SERVEPOINT_DOCUMENT_MAX_BYTES" );
        var uploadMaxBytes = 10485760;
        var encryptionKeyRaw = sys.getEnv( "SERVEPOINT_DOCUMENT_ENCRYPTION_KEY" );
        var encryptionKeyBase64 = "";
        if ( !isNull( encryptionKeyRaw ) && len( trim( encryptionKeyRaw ) ) ) {
            encryptionKeyBase64 = trim( encryptionKeyRaw );
        }
        if ( isNull(ormDbcreateRaw) || trim(ormDbcreateRaw) == "" || listFindNoCase(ormDbcreateAllowed, trim(ormDbcreateRaw)) == 0 ) {
            ormDbcreateRaw = "validate";
        } else {
            ormDbcreateRaw = trim(ormDbcreateRaw);
        }
        if ( isNull( uploadStorageRoot ) || !len( trim( uploadStorageRoot ) ) ) {
            uploadStorageRoot = expandPath( "../uploads/documents" );
        } else {
            uploadStorageRoot = trim( uploadStorageRoot );
        }
        if ( isNull( uploadTempRoot ) || !len( trim( uploadTempRoot ) ) ) {
            uploadTempRoot = expandPath( "../tmp/uploads/documents" );
        } else {
            uploadTempRoot = trim( uploadTempRoot );
        }
        if ( !isNull( uploadMaxBytesRaw ) && isNumeric( trim( uploadMaxBytesRaw ) ) && val( trim( uploadMaxBytesRaw ) ) > 0 ) {
            uploadMaxBytes = val( trim( uploadMaxBytesRaw ) );
        }
        moduleSettings = {
            servepoint = {
                documentUploads = {
                    storageRoot = uploadStorageRoot,
                    tempRoot = uploadTempRoot,
                    maxBytes = uploadMaxBytes,
                    encryptionKeyBase64 = encryptionKeyBase64
                }
            },
            cborm = {
                datasource = "servepoint",
                orm = {
                    dbcreate = ormDbcreateRaw,
                    modelsLocation = "models",
                    logSQL = true
                },
                injection = { enabled:true }
            },
            cfmigrations = {
                managers = {
                    "default" = {
                        manager = "cfmigrations.models.QBMigrationManager",
                        migrationsDirectory = "/resources/database/migrations",
                        seedsDirectory = "/resources/database/seeds",
                        seedEnvironments = "development",
                        properties = {
                            defaultGrammar = "PostgresGrammar@qb",
                            datasource = "servepoint",
                            useTransactions = true
                        }
                    }
                }
            }
        };

        conventions = {
            handlersLocation: "handlers",
            viewsLocation: "views",
            layoutsLocation: "layouts",
            modelsLocation: "models"
        };
    }

    function development(){
        coldbox.customErrorTemplate = "/coldbox/system/exceptions/Whoops.cfm";
    }
}
