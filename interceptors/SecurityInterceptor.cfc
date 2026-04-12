/**
 * Phase 1: authentication for non-public routes; prc.currentUser when session present.
 * Phase 2: coarse role gates (handler.action); public allowlist includes main.rbac.
 */
component extends="coldbox.system.Interceptor" accessors="true" {

    property name="securityService" inject="SecurityService";

    function configure() {
    }

    function preProcess( required any event, required struct interceptData ) {

        if ( securityService.isAuthenticated() ) {
            var cu = securityService.getCurrentUser();
            event.setValue( name = "currentUser", value = cu, private = true );
            event.setValue(
                name = "currentUserRole",
                value = isNull( cu ) ? "" : trim( toString( cu.getRole() ) ),
                private = true
            );
        }

        if ( isPublicRequest( event ) ) {
            return;
        }

        if ( !securityService.isAuthenticated() ) {
            securityService.persistReturnTarget( event );
            relocate( "main.login" );
            return;
        }

        if ( !isAuthorizedForRole( event ) ) {
            session.servepointAuthzNotice = "You do not have permission to access that.";
            relocate( "main.index" );
        }
    }

    /**
     * Minimum role per routed event (coarse). Fine-grained checks live in services.
     */
    private boolean function isAuthorizedForRole( required any event ) {
        var role = trim( toString( event.getValue( name = "currentUserRole", private = true ) ?: "" ) );
        if ( !len( role ) ) {
            return false;
        }
        var ur = new models.constants.User_Role();
        var currentHandler = lCase( event.getCurrentHandler() );
        // Admin module (Issue #47): only Administrator may access any admin.* event
        if ( currentHandler == "admin" ) {
            return role == ur.ROLES.ADMINISTRATOR;
        }
        var currentEvent = currentHandler & "." & lCase( event.getCurrentAction() );

        if ( role == ur.ROLES.ADMINISTRATOR ) {
            return true;
        }

        if ( role == ur.ROLES.CASE_MANAGER ) {
            return listFindNoCase( "reports.index,reports.bytype", currentEvent ) == 0;
        }

        if ( role == ur.ROLES.CITIZEN ) {
            var citizenAllowed =
                "cases.index,cases.view,documents.index,documents.download,main.rbac";
            return listFindNoCase( citizenAllowed, currentEvent ) > 0;
        }

        return false;
    }

    /**
     * Public routes: info pages, login flow, RBAC help, and non-ColdBox-module paths like /healthcheck.
     */
    private boolean function isPublicRequest( required any event ) {
        if ( isHealthcheckRequest() ) {
            return true;
        }
        var currentEvent = lCase( event.getCurrentHandler() ) & "." & lCase( event.getCurrentAction() );
        var publicEvents =
            "main.index,main.encryption,main.compliance,main.underconstruction,main.healthcheck,main.login,main.dologin,main.logout,main.rbac";
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
