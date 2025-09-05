component {
    function configure(){
        coldbox = {
            appName: "ServePoint",
            autoMapModels: true,
            jsonPayloadToRC: true
        };

        modules = { include:["cborm"], exclude:[] };

        moduleSettings = {
            cborm = {
                datasource = "servepoint",
                orm = {
                    dbcreate = "update",
                    modelsLocation = "models",
                    logSQL = true
                },
                injection = { enabled:true }
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
