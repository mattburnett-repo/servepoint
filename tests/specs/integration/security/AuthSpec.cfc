component extends="tests.specs.BaseIntegrationTestCase" appMapping="/root" {

	function run() {
		describe( "Phase 1 authentication", function() {

			it( "main.index is reachable without a session", function() {
				this.clearSessionAuth();
				var event = this.get( "main.index" );
				expect( event.getRenderedContent() ).toInclude( "ServePoint" );
			} );

			it( "unauthenticated access to cases.index relocates to main.login", function() {
				this.clearSessionAuth();
				var event = this.get( "cases.index" );
				expect( event.getValue( "relocate_event", "" ) ).toBe( "main.login" );
			} );

			it( "authenticated access to cases.index loads the cases list", function() {
				this.clearSessionAuth();
				this.loginAsSeedUser( "admin@example.com" );
				var event = this.get( "cases.index" );
				expect( event.getValue( "relocate_event", "" ) ).toBe( "" );
				var cases = event.getValue( name = "cases", private = true );
				expect( isArray( cases ) ).toBeTrue();
			} );

		} );
	}

}
