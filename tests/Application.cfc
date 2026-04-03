/**
 * Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 */
component {

	// APPLICATION CFC PROPERTIES
	this.name                 = "ColdBoxTestingSuite";
	this.sessionManagement    = true;
	this.setClientCookies     = true;
	this.sessionTimeout       = createTimespan( 0, 0, 15, 0 );
	this.applicationTimeout   = createTimespan( 0, 0, 15, 0 );
	this.whiteSpaceManagement = "smart";
	this.enableNullSupport    = shouldEnableFullNullSupport();

	// Mirror ORM configuration from the main application so tests can use entities and SeedService.
	// NOTE: This Application.cfc runs under the /tests app root, so we must point ORM to the parent /models folder.
	this.ormEnabled = true;
	this.datasource = "servepoint";
	this.ormSettings = {
		// Resolve ../models relative to the /tests directory (gives /app/models inside the container)
		cfclocation = [ expandPath( "../models" ) ],
		dbcreate    = "update",
		logSQL      = true
	};

	/**
	 * --------------------------------------------------------------------------
	 * Location Mappings
	 * --------------------------------------------------------------------------
	 * - cbApp : Quick reference to root application
	 * - coldbox : Where ColdBox library is installed
	 * - testbox : Where TestBox is installed
	 */
	// Create testing mapping (/tests for URLs; "tests" package for components under tests/specs/...)
	var testsDir                 = getDirectoryFromPath( getCurrentTemplatePath() );
	this.mappings[ "/tests" ]   = testsDir;
	this.mappings[ "tests" ]    = testsDir;
	// The root application mapping
	rootPath                    = reReplaceNoCase( this.mappings[ "/tests" ], "tests(\\|/)", "" );
	this.mappings[ "/root" ]    = this.mappings[ "/cbapp" ] = rootPath;
	this.mappings[ "/coldbox" ] = rootPath & "coldbox";
	this.mappings[ "/testbox" ] = rootPath & "testbox";

	/**
	 * Fires on every test request. It builds a Virtual ColdBox application for you
	 *
	 * @targetPage The requested page
	 */
	public boolean function onRequestStart( targetPage ){
		// Set a high timeout for long running tests
		setting requestTimeout   ="9999";
		// New ColdBox Virtual Application Starter
		request.coldBoxVirtualApp= new coldbox.system.testing.VirtualApp( appMapping = "/root" );

		// If hitting the runner or specs, prep our virtual app
		if ( getBaseTemplatePath().replace( expandPath( "/tests" ), "" ).reFindNoCase( "(runner|specs)" ) ) {
			request.coldBoxVirtualApp.startup( true );
		}

		// Reload for fresh results
		if ( structKeyExists( url, "fwreinit" ) ) {
			if ( structKeyExists( server, "lucee" ) ) {
				pagePoolClear();
			}
			// ormReload();
			request.coldBoxVirtualApp.restart();
		}

		return true;
	}

	/**
	 * Fires when the testing requests end and the ColdBox application is shutdown
	 */
	public void function onRequestEnd( required targetPage ){
		request.coldBoxVirtualApp.shutdown();
	}

	private boolean function shouldEnableFullNullSupport(){
		var system = createObject( "java", "java.lang.System" );
		var value  = system.getEnv( "FULL_NULL" );
		return isNull( value ) ? false : !!value;
	}

}
