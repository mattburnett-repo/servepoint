component {
    this.name = "ServePoint";
    this.sessionManagement = true;
    this.sessionTimeout = createTimespan(0,1,0,0);
    this.setClientCookies = true;
    this.setDomainCookies = true;
    this.scriptProtect = false;
    this.secureJSON = false;
    this.timezone = "UTC";
    this.whiteSpaceManagement = "smart";

    // Datasource "servepoint" is defined in .cfconfig.json (server-level)
    this.ormEnabled = true;
    this.datasource = "servepoint";
    
    this.ormSettings = {
        cfclocation = [ "models" ],
        dbcreate = "validate",
        logSQL = true
    };

    /**
     * Java Integration
     */
    this.javaSettings = {
        loadPaths: [ expandPath("./lib/java") ],
        loadColdFusionClassPath: true,
        reloadOnChange: false
    };

    /**
     * ColdBox Bootstrap
     */
    COLDBOX_APP_ROOT_PATH = getDirectoryFromPath(getCurrentTemplatePath());
    COLDBOX_APP_MAPPING = "";
    COLDBOX_CONFIG_FILE = "";
    COLDBOX_APP_KEY = "";
    COLDBOX_FAIL_FAST = true;

    this.mappings["/cbapp"]   = COLDBOX_APP_ROOT_PATH;
    this.mappings["/coldbox"] = COLDBOX_APP_ROOT_PATH & "coldbox";
    this.mappings["/cborm"]   = COLDBOX_APP_ROOT_PATH & "modules/cborm";
    this.mappings["/logbox"]  = COLDBOX_APP_ROOT_PATH & "logbox";

    public boolean function onApplicationStart(){
        setting requestTimeout = "300";

        // Ensure logs directory exists for LogBox file appenders
        var logsPath = getDirectoryFromPath(getCurrentTemplatePath()) & "logs";
        if ( !directoryExists(logsPath) ) {
            directoryCreate(logsPath);
        }

        application.cbBootstrap = new coldbox.system.Bootstrap(
            COLDBOX_CONFIG_FILE,
            COLDBOX_APP_ROOT_PATH,
            COLDBOX_APP_KEY,
            COLDBOX_APP_MAPPING
        );
        application.cbBootstrap.loadColdbox();

        // Run database migrations before initializing ORM or seeding
        runMigrations();

        // Fail fast: initialize ORM at startup; if DB is down, app won't start
        if ( getApplicationMetadata().ormEnabled ) {
            ormGetSessionFactory();
        }

        // Optionally seed the database after ORM is ready.
        if ( shouldRunSeeding() ) {
            try {
                var seedService = application.cbController.getWireBox().getInstance( "SeedService" );
                seedService.runAll();
                application.cbController.getLogBox().getLogger( "app.startup" ).info( "Database seeding completed successfully." );
            } catch ( any se ) {
                // Log the error and rethrow so startup fails fast.
                try {
                    application.cbController.getLogBox().getLogger( "app.error" ).error(
                        "Error during database seeding on startup: #se.message#",
                        { detail : se.detail }
                    );
                } catch ( any logErr ) {
                    // If LogBox is not available, fall back to CF's standard logging.
                    writeLog( type = "error", text = "Error during database seeding on startup: " & se.message & " | " & se.detail );
                }
                rethrow;
            }
        }

        try {
            application.cbController.getLogBox().getLogger("app.startup").info("Application started: ServePoint");
        } catch ( any e ) {
            // LogBox not yet available or misconfigured; ignore
        }

        return true;
    }

    /**
     * Execute pending database migrations using the default cfmigrations manager.
     * Any errors should cause startup to fail fast.
     */
    private void function runMigrations() {
        try {
            var migrationService = application.cbController
                .getWireBox()
                .getInstance( "migrationService@cfmigrations" );

            // Ensure the migrations tracking table exists, then run all pending migrations.
            migrationService.install();
            migrationService.up();
        } catch ( any mEx ) {
            try {
                application.cbController.getLogBox().getLogger( "app.startup" ).error(
                    "Error while running database migrations on startup: #mEx.message#",
                    { detail : mEx.detail }
                );
            } catch ( any logErr ) {
                writeLog(
                    type = "error",
                    text = "Error while running database migrations on startup: " & mEx.message & " | " & mEx.detail
                );
            }
            rethrow;
        }
    }

    /**
     * Determine whether database seeding should run on startup.
     * Controlled via the SERVEPOINT_AUTO_SEED environment variable.
     * Defaults to true when the variable is not set.
     */
    private boolean function shouldRunSeeding() {
        var system = createObject( "java", "java.lang.System" );
        var value  = system.getEnv( "SERVEPOINT_AUTO_SEED" );

        if ( isNull( value ) ) {
            return true;
        }

        var trimmed = trim( value );
        if ( !len( trimmed ) ) {
            return true;
        }

        return listFindNoCase( "1,true,yes,on", trimmed ) > 0;
    }

    public boolean function onRequestStart(string targetPage){
        application.cbBootstrap.onRequestStart(arguments.targetPage);
        return true;
    }

    public void function onApplicationEnd(struct appScope){
        if ( structKeyExists(arguments.appScope, "cbController") && !isNull(arguments.appScope.cbController) ) {
            try {
                arguments.appScope.cbController.getLogBox().getLogger("app.shutdown").info("Application shutting down.");
            } catch ( any e ) {
                // ignore
            }
        }
        arguments.appScope.cbBootstrap.onApplicationEnd(arguments.appScope);
    }

    public void function onSessionStart(){
        if(!isNull(application.cbBootstrap)){
            application.cbBootstrap.onSessionStart();
        }
    }

    public void function onSessionEnd(struct sessionScope, struct appScope){
        arguments.appScope.cbBootstrap.onSessionEnd(argumentCollection=arguments);
    }

    public boolean function onMissingTemplate(template){
        return application.cbBootstrap.onMissingTemplate(argumentCollection=arguments);
    }

    public void function onError( any exception, string eventName ){
        var ex       = arguments.exception;
        var exType   = isNull( ex.type )    ? "" : ex.type;
        var exMsg    = isNull( ex.message ) ? "" : ex.message;
        var exDetail = isNull( ex.detail )  ? "" : ex.detail;

        // -------------------------------------------------------------------------
        // WORKAROUND: Adobe ColdFusion 2025 graphqlclient package error on first load
        // -------------------------------------------------------------------------
        // On the first request, CF 2025's ApplicationSettings.loadAppDatasources()
        // calls ServiceFactory.getGraphQLClientService(). If the graphqlclient
        // optional package is not installed, that method throws
        // ModuleNotAvailableException. This app does not use GraphQL. Redirecting
        // to the same URL causes a second request; on that request the application
        // scope is already resolved so the failing code path is not run and the
        // app loads normally. See DEV_NOTES.md "Known issues" and GitHub issue #10.
        // -------------------------------------------------------------------------
        var isGraphQLClientWorkaround = (
            ( findNoCase( "graphqlclient", exMsg ) AND findNoCase( "not installed", exMsg ) )
            OR findNoCase( "ModuleNotAvailableException", exType )
        );
        if ( isGraphQLClientWorkaround ){
            var redirectUrl = ( structKeyExists( CGI, "REQUEST_URL" ) AND len( trim( CGI.REQUEST_URL ) ) )
                ? CGI.REQUEST_URL
                : "/";
            location( url = redirectUrl, addToken = false, statusCode = "302" );
            abort;
        }

        var isDatabaseError = (
            findNoCase( "database", exType )             ||
            findNoCase( "jdbc", exType )                 ||
            findNoCase( "sql", exType )                  ||
            findNoCase( "postgres", exMsg )              ||
            findNoCase( "connection refused", exMsg )    ||
            findNoCase( "database", exDetail )           ||
            findNoCase( "connection refused", exDetail ) ||
            findNoCase( "postgres", exDetail )
        );

        // Choose appropriate HTTP status
        if ( isDatabaseError ){
            cfheader( statusCode = 503 );
        }
        else {
            // Generic 500-series error handling
            cfheader( statusCode = 500 );
        }

        // Expose user-friendly message and full error data for the error view
        variables.errorMessage   = isDatabaseError
            ? "The application cannot reach the database at this time. Please try again later."
            : "An unexpected error occurred while processing your request.";
        variables.isDatabaseError = isDatabaseError;

        // Full error information (for debugging; lock down before production)
        variables.errorType      = exType;
        variables.errorMessageRaw = exMsg;
        variables.errorDetail    = exDetail;
        variables.errorEventName = arguments.eventName;
        variables.errorStackTrace = isNull( ex.stackTrace ) ? "" : ex.stackTrace;
        variables.errorTagContext = isNull( ex.tagContext ) ? [] : ex.tagContext;
        variables.errorRootCauseMessage = "";
        variables.errorRootCauseDetail  = "";
        variables.errorTemplate = "";
        variables.errorLine = "";
        try {
            variables.errorExceptionJson = serializeJSON( ex );
            // Parse back so we can read RootCause reliably (live exception may be Java object)
            var exStruct = deserializeJSON( variables.errorExceptionJson );
            if ( structKeyExists( exStruct, "RootCause" ) && isStruct( exStruct.RootCause ) ) {
                var rc = exStruct.RootCause;
                if ( structKeyExists( rc, "Message" ) && len( trim( rc.Message ) ) )
                    variables.errorRootCauseMessage = trim( rc.Message );
                if ( structKeyExists( rc, "Detail" ) && len( trim( rc.Detail ) ) )
                    variables.errorRootCauseDetail = trim( rc.Detail );
                // When error originates in a CFC (e.g. ORM parse), tag context is often only on RootCause
                if ( arrayLen( variables.errorTagContext ) == 0 && structKeyExists( rc, "TagContext" ) && isArray( rc.TagContext ) )
                    variables.errorTagContext = rc.TagContext;
            }
        } catch ( any e ) {
            variables.errorExceptionJson = "{ ""serializeError"": ""Could not serialize exception"" }";
        }
        // Normalize tag context to lowercase keys (CF/Java may provide TEMPLATE, LINE) so the view can display template/line
        var normalized = [];
        for ( var ctx in variables.errorTagContext ) {
            var t = {};
            if ( isStruct( ctx ) ) {
                t.template = structKeyExists( ctx, "TEMPLATE" ) ? ctx.TEMPLATE : ( structKeyExists( ctx, "template" ) ? ctx.template : "" );
                t.line    = structKeyExists( ctx, "LINE" ) ? ctx.LINE : ( structKeyExists( ctx, "line" ) ? ctx.line : "" );
                t.id      = structKeyExists( ctx, "ID" ) ? ctx.ID : ( structKeyExists( ctx, "id" ) ? ctx.id : "" );
            }
            arrayAppend( normalized, t );
        }
        variables.errorTagContext = normalized;
        if ( arrayLen( variables.errorTagContext ) > 0 && len( trim( variables.errorTagContext[1].template ) ) ) {
            variables.errorTemplate = trim( variables.errorTagContext[1].template );
            variables.errorLine = variables.errorTagContext[1].line;
        }

        // Render the shared error view. Use this for cases where the error happens on startup, before ColdBox is loaded.
        include "/views/main/application.onError.cfm";

        // Log via LogBox when available (app.events file). When ColdBox didn't start (e.g. DB down), bootstrap LogBox standalone so startup errors still go to servepoint-app-events.log. Pass minimal extraInfo (no stackTrace).
        var errorExtra = { type = exType, message = exMsg, detail = exDetail, eventName = arguments.eventName };
        if ( structKeyExists(variables, "errorTemplate") && len(trim(variables.errorTemplate)) ) {
            errorExtra.template = variables.errorTemplate;
            if ( structKeyExists(variables, "errorLine") )
                errorExtra.line = variables.errorLine;
        }
        if ( structKeyExists(application, "cbController") && !isNull(application.cbController) ) {
            try {
                var errLog = application.cbController.getLogBox().getLogger("app.error");
                errLog.error("Application.onError for event '#arguments.eventName#': #exMsg# #exDetail#", errorExtra);
            } catch ( any e ) {
                writeLog(type = "error", text = "Application.onError for event '" & eventName & "': " & serializeJSON( errorExtra ));
            }
        } else {
            try {
                var logsPath = getDirectoryFromPath(getCurrentTemplatePath()) & "logs";
                if ( !directoryExists(logsPath) ) {
                    directoryCreate(logsPath);
                }
                if ( !structKeyExists(application, "standaloneLogBox") || isNull(application.standaloneLogBox) ) {
                    application.standaloneLogBox = new coldbox.system.logging.LogBox("config.LogBox");
                }
                application.standaloneLogBox.getLogger("app.error").error("Application.onError for event '#arguments.eventName#': #exMsg# #exDetail#", errorExtra);
            } catch ( any e ) {
                writeLog(type = "error", text = "Application.onError for event '" & eventName & "': " & serializeJSON( errorExtra ));
            } finally {
                if ( structKeyExists(application, "standaloneLogBox") ) {
                    structDelete(application, "standaloneLogBox");
                }
            }
        }

        abort;
    }
}
