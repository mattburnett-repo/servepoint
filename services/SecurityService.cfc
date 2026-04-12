component singleton accessors="true" {

    /**
     * Session key for logged-in user primary key (users.user_id).
     */
    public string function getSessionUserIdKey() {
        return "userId";
    }

    public boolean function isAuthenticated() {
        return structKeyExists( session, "userId" ) && isNumeric( session.userId ) && val( session.userId ) > 0;
    }

    /**
     * @returns Users entity or null if not logged in / user missing
     */
    public any function getCurrentUser() {
        if ( !isAuthenticated() ) {
            return;
        }
        var u = entityLoad( "Users", val( session.userId ), true );
        return u;
    }

    /**
     * @returns Users.role string (e.g. Citizen, Case Manager, Administrator) or empty when not logged in
     */
    public string function getCurrentUserRole() {
        var u = getCurrentUser();
        if ( isNull( u ) ) {
            return "";
        }
        return trim( toString( u.getRole() ) );
    }

    /**
     * Verify credentials; does not set session (caller calls loginUser on success).
     */
    public struct function authenticate( required string email, required string password ) {
        var trimmedEmail = trim( arguments.email );
        if ( !len( trimmedEmail ) ) {
            return { success: false, error: "Email and password are required." };
        }
        var u = entityLoad( "Users", { email : trimmedEmail }, true );
        if ( isNull( u ) ) {
            return { success: false, error: "Invalid email or password." };
        }
        if ( !verifyBCryptHash( arguments.password, u.getPassword() ) ) {
            return { success: false, error: "Invalid email or password." };
        }
        return { success: true, user: u };
    }

    public void function loginUser( required numeric userId ) {
        session.userId = val( arguments.userId );
    }

    public void function logout() {
        structDelete( session, "userId" );
        structDelete( session, "auth_returnEvent" );
        structDelete( session, "auth_returnQueryString" );
    }

    /**
     * Store originally requested event + query string before redirecting to login.
     */
    public void function persistReturnTarget( required any event ) {
        var e = arguments.event;
        session.auth_returnEvent = lCase( e.getCurrentHandler() ) & "." & lCase( e.getCurrentAction() );
        session.auth_returnQueryString = "";
        if ( structKeyExists( cgi, "query_string" ) && len( trim( toString( cgi.query_string ) ) ) ) {
            session.auth_returnQueryString = trim( toString( cgi.query_string ) );
        }
    }

    /**
     * Read and clear post-login redirect target. Default when missing: cases.index
     */
    public struct function getAndClearReturnTarget() {
        var ev = structKeyExists( session, "auth_returnEvent" ) ? trim( toString( session.auth_returnEvent ) ) : "";
        var qs = structKeyExists( session, "auth_returnQueryString" ) ? trim( toString( session.auth_returnQueryString ) ) : "";
        structDelete( session, "auth_returnEvent" );
        structDelete( session, "auth_returnQueryString" );
        if ( !len( ev ) ) {
            ev = "cases.index";
        }
        return { event: ev, queryString: qs };
    }

}
