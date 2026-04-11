/**
 * Phase 1: require authentication for non-public routes; set prc.currentUser when session present.
 * No role-based rules (Phase 2).
 */
component extends="coldbox.system.Interceptor" accessors="true" {

    property name="securityService" inject="SecurityService";

    function configure() {
    }

    function preProcess( required any event, required struct interceptData ) {

        if ( securityService.isAuthenticated() ) {
            event.setValue( name = "currentUser", value = securityService.getCurrentUser(), private = true );
        }

        if ( isPublicRequest( event ) ) {
            return;
        }

        if ( !securityService.isAuthenticated() ) {
            securityService.persistReturnTarget( event );
            relocate( "main.login" );
        }
    }

    /**
     * Public routes: info pages, login flow, and non-ColdBox-module paths like /healthcheck.
     */
    private boolean function isPublicRequest( required any event ) {
        if ( isHealthcheckRequest() ) {
            return true;
        }
        var currentEvent = lCase( event.getCurrentHandler() ) & "." & lCase( event.getCurrentAction() );
        var publicEvents = "main.index,main.encryption,main.compliance,main.underconstruction,main.login,main.dologin,main.logout";
        return listFindNoCase( publicEvents, currentEvent ) > 0;
    }

    private boolean function isHealthcheckRequest() {
        var pi = structKeyExists( cgi, "path_info" ) ? toString( cgi.path_info ) : "";
        if ( len( pi ) && findNoCase( "healthcheck", pi ) ) {
            return true;
        }
        var uri = pi;
        if ( structKeyExists( cgi, "script_name" ) ) {
            uri = uri & toString( cgi.script_name );
        }
        return findNoCase( "healthcheck", uri ) > 0;
    }

}
