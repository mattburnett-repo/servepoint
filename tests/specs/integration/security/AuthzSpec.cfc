component extends="tests.specs.BaseIntegrationTestCase" appMapping="/root" {

	function run() {
		describe( "Phase 2 authorization (RBAC)", function() {

			it( "main.rbac is reachable without a session", function() {
				this.clearSessionAuth();
				var event = this.get( "main.rbac" );
				expect( event.getRenderedContent() ).toInclude( "Permission matrix" );
			} );

			it( "Citizen cannot open reports.index (relocate to main.index)", function() {
				this.clearSessionAuth();
				this.loginAsSeedUser( "citizen@example.com" );
				var event = this.get( "reports.index" );
				expect( event.getValue( "relocate_event", "" ) ).toBe( "main.index" );
			} );

			it( "Case Manager cannot open reports.index (relocate to main.index)", function() {
				this.clearSessionAuth();
				this.loginAsSeedUser( "case.manager@example.com" );
				var event = this.get( "reports.index" );
				expect( event.getValue( "relocate_event", "" ) ).toBe( "main.index" );
			} );

			it( "unauthenticated access to admin.index relocates to main.login", function() {
				this.clearSessionAuth();
				var event = this.get( "admin.index" );
				expect( event.getValue( "relocate_event", "" ) ).toBe( "main.login" );
			} );

			it( "Citizen cannot open admin.index (relocate to main.index)", function() {
				this.clearSessionAuth();
				this.loginAsSeedUser( "citizen@example.com" );
				var event = this.get( "admin.index" );
				expect( event.getValue( "relocate_event", "" ) ).toBe( "main.index" );
			} );

			it( "Case Manager cannot open admin.index (relocate to main.index)", function() {
				this.clearSessionAuth();
				this.loginAsSeedUser( "case.manager@example.com" );
				var event = this.get( "admin.index" );
				expect( event.getValue( "relocate_event", "" ) ).toBe( "main.index" );
			} );

			it( "Administrator can open admin.index", function() {
				this.clearSessionAuth();
				this.loginAsSeedUser( "admin@example.com" );
				var event = this.get( "admin.index" );
				expect( event.getValue( "relocate_event", "" ) ).toBe( "" );
				expect( event.getRenderedContent() ).toInclude( "servepoint-admin-roadmap" );
			} );

			it( "Citizen cannot POST cases.create (relocate to main.index)", function() {
				this.clearSessionAuth();
				this.loginAsSeedUser( "citizen@example.com" );
				var event = this.post(
					"cases.create",
					{ title : "Should fail", description : "", status : "New" },
					{},
					false
				);
				expect( event.getValue( "relocate_event", "" ) ).toBe( "main.index" );
			} );

			it( "CaseService denies update when Case Manager is not assigned to the case", function() {
				var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
				expect( isNull( admin ) ).toBeFalse();
				var mgr = entityLoad( "Users", { email : "case.manager@example.com" }, true );
				expect( isNull( mgr ) ).toBeFalse();
				var svc = getWireBox().getInstance( "CaseService" );
				var created = svc.createCase(
					title            = "AuthzSpec unassigned " & createUUID(),
					description      = "",
					status           = "New",
					creatorUserId    = admin.getUserId(),
					assignedToUserId = admin.getUserId()
				);
				expect( created.success ).toBeTrue();
				var ur = svc.updateCase(
					caseId           = created.case.getCaseId(),
					title            = "Try update",
					description      = "",
					status           = "New",
					assignedToUserId = admin.getUserId(),
					actorUserId      = mgr.getUserId(),
					actorRole        = "Case Manager"
				);
				expect( ur.success ).toBeFalse();
				expect( ur.error ).toInclude( "not allowed" );
			} );

		} );
	}

}
