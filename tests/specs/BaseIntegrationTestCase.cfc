/**
 * Integration specs: each spec runs inside a CFML transaction that is rolled back after the spec,
 * so test data does not persist in the database.
 *
 * Uses TestBox @aroundEach so setup() and DB work participate in the same transaction as the spec body.
 */
component extends="coldbox.system.testing.BaseTestCase" appMapping="/root" {

	/**
	 * Ensure the singleton Renderer has appMapping before layout/view resolution.
	 * ColdBox VirtualApp + Adobe CF can leave Renderer.appMapping unset in variables,
	 * which breaks locateLayout() during integration runs that render HTML.
	 */
	function setup() {
		super.setup();
		if (
			this.loadColdbox &&
			structKeyExists( variables, "controller" ) &&
			!isSimpleValue( variables.controller ) &&
			len( trim( variables.appMapping ) )
		) {
			try {
				variables.controller.getRenderer().setAppMapping( trim( variables.appMapping ) );
			} catch ( any e ) {
			}
		}
	}

	/**
	 * @aroundEach
	 */
	public void function wrapInDbTransaction( required spec, required suite, struct data = {} ) {
		transaction {
			setup();
			getWireBox().getInstance( "CaseService" ).restoreAllArchived();
			spec.body();
			transaction action="rollback";
		}
		ormClearSession();
	}

	/**
	 * Sets session.userId for integration tests that hit authenticated routes (Phase 1 security).
	 */
	public void function loginAsSeedUser( required string email ) {
		var u = entityLoad( "Users", { email : arguments.email }, true );
		expect( isNull( u ) ).toBeFalse();
		session.userId = u.getUserId();
	}

	public void function clearSessionAuth() {
		structDelete( session, "userId" );
		structDelete( session, "auth_returnEvent" );
		structDelete( session, "auth_returnQueryString" );
		structDelete( session, "servepointAuthzNotice" );
	}

}
