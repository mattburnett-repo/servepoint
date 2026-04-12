component extends="coldbox.system.EventHandler" {

	property name="securityService" inject="SecurityService";

	/**
	 * Default Action - ServePoint Home Page
	 */
	function index( event, rc, prc ){
		prc.welcomeMessage = "Welcome to ServePoint";
		prc.projectDescription = "Social Services Case Management System";
		prc.projectFeatures = [
			{ "label" : "Case intake and management", "href" : event.buildLink( "cases.index" ) },
			{ "label" : "Document upload and storage", "href" : event.buildLink( "documents.index" ) },
			{ "label" : "Staff communication tools", "href" : event.buildLink( "communications.index" ) },
			{ "label" : "Audit trails and reporting", "href" : event.buildLink( "reports.index" ) },
			{ "label" : "Role-based access controls", "href" : event.buildLink( "main.rbac" ) }
		];
		prc.targetAudience = "US Federal Government and public-sector agencies";
		event.setView( "main/index" );
	}

	/**
	 * Short summary: document encryption at rest and TLS for traffic / database.
	 */
	function encryption( event, rc, prc ){
		prc.pageTitle = "Data encryption at rest and in transit";
		event.setView( "main/encryption" );
	}

	/**
	 * Demo-grade privacy/compliance posture: not legal advice; points to docs/compliance on GitHub.
	 */
	function compliance( event, rc, prc ){
		prc.pageTitle = "Privacy and compliance posture";
		event.setView( "main/compliance" );
	}

	/**
	 * RBAC matrix summary (public): demo roles, seed accounts, link to sign in.
	 */
	function rbac( event, rc, prc ){
		prc.pageTitle = "Role-based access controls";
		event.setView( "main/rbac" );
	}

	/**
	 * Under Construction Page
	 */
	function underConstruction( event, rc, prc ){
		prc.pageTitle = "Under Construction";
		prc.message = "This feature is currently under development.";
		event.setView( "main/underConstruction" );
	}

	/**
	 * Human-friendly /healthcheck page. Pings the app datasource; full HTML, no layout.
	 */
	function healthcheck( event, rc, prc ){
		prc.checkedAt = dateTimeFormat( now(), "yyyy-mm-dd HH:nn:ss" );
		try {
			queryExecute( "SELECT 1 AS ok", [], { datasource: "servepoint" } );
			event.setHTTPHeader( name = "Content-Type", value = "text/html; charset=utf-8" );
			event.setView( view = "main/healthcheckOk", noLayout = true );
		} catch ( any e ) {
			prc.healthMessage = left( trim( toString( e.message ?: "" ) ), 400 );
			event.setHTTPHeader( statusCode = 503 );
			event.setHTTPHeader( name = "Content-Type", value = "text/html; charset=utf-8" );
			event.setView( view = "main/healthcheckDown", noLayout = true );
		}
	}

	/**
	 * Produce some restfulf data
	 */
	function data( event, rc, prc ){
		return [
			{ "id" : createUUID(), "name" : "Luis" },
			{ "id" : createUUID(), "name" : "Joe" },
			{ "id" : createUUID(), "name" : "Bob" },
			{ "id" : createUUID(), "name" : "Darth" }
		];
	}

	/**
	 * Relocation example
	 */
	function doSomething( event, rc, prc ){
		relocate( "main.index" );
	}

	/**
	 * Sign-in form (public). Post to doLogin.
	 */
	function login( event, rc, prc ){
		prc.pageTitle = "Sign in";
		event.setView( "main/login" );
	}

	/**
	 * POST: validate credentials, set session.userId, relocate to return target or cases.index.
	 */
	function doLogin( event, rc, prc ){
		if ( event.getHTTPMethod() != "POST" ) {
			relocate( "main.login" );
			return;
		}
		var email = structKeyExists( rc, "email" ) ? trim( rc.email ) : "";
		var password = structKeyExists( rc, "password" ) ? rc.password : "";
		var result = securityService.authenticate( email = email, password = password );
		if ( !result.success ) {
			prc.errorMessage = result.error;
			prc.emailValue = email;
			prc.pageTitle = "Sign in";
			event.setView( "main/login" );
			return;
		}
		securityService.loginUser( result.user.getUserId() );
		var target = securityService.getAndClearReturnTarget();
		if ( len( trim( target.queryString ) ) ) {
			relocate( event = target.event, queryString = target.queryString );
		} else {
			relocate( event = target.event );
		}
	}

	/**
	 * Clear session identity and return to home.
	 */
	function logout( event, rc, prc ){
		securityService.logout();
		relocate( "main.index" );
	}

	/**
	 * --------------------------------------------------------------------------
	 * Implicit Actions
	 * --------------------------------------------------------------------------
	 * All the implicit actions below MUST be declared in the config/Coldbox.cfc in order to fire.
	 * https://coldbox.ortusbooks.com/getting-started/configuration/coldbox.cfc/configuration-directives/coldbox#implicit-event-settings
	 */

	function onAppInit( event, rc, prc ){
	}

	function onRequestStart( event, rc, prc ){
	}

	function onRequestEnd( event, rc, prc ){
	}

	function onSessionStart( event, rc, prc ){
	}

	function onSessionEnd( event, rc, prc ){
		var sessionScope     = event.getValue( "sessionReference" );
		var applicationScope = event.getValue( "applicationReference" );
	}

	function onException( event, rc, prc ){
		event.setHTTPHeader( statusCode = 500 );
		// Grab Exception From private request collection, placed by ColdBox Exception Handling
		var exception = prc.exception;
		// Place exception handler below:
	}

}
