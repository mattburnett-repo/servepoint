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
        var storagePersistentRaw = sys.getEnv( "SERVEPOINT_STORAGE_PERSISTENT" );
        var storagePersistent = true;
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
        if ( !isNull( storagePersistentRaw ) && len( trim( storagePersistentRaw ) ) ) {
            storagePersistent = listFindNoCase( "1,true,yes,on", trim( storagePersistentRaw ) ) > 0;
        }
        moduleSettings = {
            servepoint = {
                storagePersistent = storagePersistent,
                documentUploads = {
                    storageRoot = uploadStorageRoot,
                    tempRoot = uploadTempRoot,
                    maxBytes = uploadMaxBytes
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
