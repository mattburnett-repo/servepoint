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

    // Datasource defined for cborm to use
    this.datasources["servepoint"] = {
        class: "org.postgresql.Driver",
        bundleName: "org.postgresql.jdbc",
        bundleVersion: "42.7.7",
        connectionString: "jdbc:postgresql://localhost:5432/postgres",
        username: "joeuser",
        password: ""
    };

    this.ormEnabled = true;
    this.datasource = "servepoint"; // just to satisfy Lucee
    this.ormSettings = {
        cfclocation = ["models"],
        dbcreate = "update",
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

    this.mappings["/cbapp"] = COLDBOX_APP_ROOT_PATH;
    this.mappings["/coldbox"] = COLDBOX_APP_ROOT_PATH & "coldbox";
    this.mappings["/cborm"] = COLDBOX_APP_ROOT_PATH & "modules/cborm";

    public boolean function onApplicationStart(){
        setting requestTimeout = "300";
        application.cbBootstrap = new coldbox.system.Bootstrap(
            COLDBOX_CONFIG_FILE,
            COLDBOX_APP_ROOT_PATH,
            COLDBOX_APP_KEY,
            COLDBOX_APP_MAPPING
        );
        application.cbBootstrap.loadColdbox();
        return true;
    }

    public boolean function onRequestStart(string targetPage){
        application.cbBootstrap.onRequestStart(arguments.targetPage);
        return true;
    }

    public void function onApplicationEnd(struct appScope){
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

        // WriteDump(var=ex, format="text");

        var isDatabaseError = (
            findNoCase( "database", exType )            ||
            findNoCase( "jdbc", exType )                ||
            findNoCase( "sql", exType )                 ||
            findNoCase( "postgres", exMsg )             ||
            findNoCase( "connection refused", exMsg )   ||
            findNoCase( "database", exDetail )
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
        try {
            variables.errorExceptionJson = serializeJSON( ex );
        } catch ( any e ) {
            variables.errorExceptionJson = "{ ""serializeError"": ""Could not serialize exception"" }";
        }

        // Render the shared error view. Use this for cases where the error happens on startup, before ColdBox is loaded.
        include "/views/main/application.onError.cfm";

        // Log full exception details for diagnostics
        writeLog(
            type = "error",
            text = "Application.onError for event '" & eventName & "': " & serializeJSON( ex )
        );

        abort;
    }
}
