component extends="coldbox.system.EventHandler" {

	/**
	 * Default Action - ServePoint Home Page
	 */
	function index( event, rc, prc ){
		prc.welcomeMessage = "Welcome to ServePoint";
		prc.projectDescription = "Social Services Case Management System";
		prc.projectFeatures = [
			{ "label" : "Case intake and management", "href" : event.buildLink( "cases.index" ) },
			{ "label" : "Document upload and storage", "href" : event.buildLink( "documents.index" ) },
			{ "label" : "Staff communication tools", "href" : "" },
			{ "label" : "Audit trails and reporting", "href" : "" },
			{ "label" : "Role-based access controls", "href" : "" }
		];
		prc.targetAudience = "US Federal Government and public-sector agencies";
		event.setView( "main/index" );
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
