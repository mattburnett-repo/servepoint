/**
 * LogBox configuration: application lifecycle events (startup, error, shutdown)
 * go to a single consolidated file: logs/servepoint-app-events.log
 */
component {

    function configure(){
        // Build path to app-root logs without expandPath() to avoid web-root prepending on the server
        var logsDir = getDirectoryFromPath( getCurrentTemplatePath() ) & ".." & "/" & "logs";

        logBox = {
            appenders : {
                appevents : {
                    class      : "logbox.system.logging.appenders.FileAppender",
                    levelMin   : "FATAL",
                    levelMax   : "INFO",
                    properties : {
                        filePath   : logsDir,
                        filename   : "servepoint-app-events", //actual filename has no hyphens.
                        autoExpand : false
                    }
                },
                console : {
                    class : "logbox.system.logging.appenders.ConsoleAppender"
                }
            },
            root : {
                levelMax  : "INFO",
                appenders : "console"
            },
            categories : {
                "app.startup"  : { appenders : "appevents" },
                "app.error"    : { appenders : "appevents" },
                "app.shutdown" : { appenders : "appevents" }
            }
        };
    }

}
