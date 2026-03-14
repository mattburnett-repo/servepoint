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
        if ( isNull(ormDbcreateRaw) || trim(ormDbcreateRaw) == "" || listFindNoCase(ormDbcreateAllowed, trim(ormDbcreateRaw)) == 0 ) {
            ormDbcreateRaw = "validate";
        } else {
            ormDbcreateRaw = trim(ormDbcreateRaw);
        }
        moduleSettings = {
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
