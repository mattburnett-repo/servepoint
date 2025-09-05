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
}
