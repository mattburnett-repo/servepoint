component extends="coldbox.system.testing.BaseTestCase" appMapping="/root" {

	function run(){
		describe( "Cases intake", function(){

			beforeEach( function( currentSpec ){
				setup();
				getWireBox().getInstance( "CaseService" ).restoreAllArchived();
			} );

			it( "cases.index exposes active cases as an array", function(){
				var event = this.get( "cases.index" );
				var cases = event.getValue( name = "cases", private = true );
				expect( isArray( cases ) ).toBeTrue();
			} );

			it( "cases.new renders the new case form", function(){
				var event = this.get( "cases.new" );
				expect( event.getRenderedContent() ).toInclude( "New case" );
			} );

			it( "CaseService.createCase persists a new case", function(){
				var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
				expect( isNull( admin ) ).toBeFalse();
				var uniqueTitle = "CasesSpec service " & createUUID();
				var svc    = getWireBox().getInstance( "CaseService" );
				var result = svc.createCase(
					title            = uniqueTitle,
					description      = "Service-layer coverage",
					status           = "New",
					creatorUserId    = admin.getUserId(),
					assignedToUserId = admin.getUserId()
				);
				expect( result.success ).toBeTrue();
				expect( result.case.getTitle() ).toBe( uniqueTitle );
				var active = svc.listActive();
				var found  = false;
				for ( var c in active ) {
					if ( c.getTitle() == uniqueTitle ) {
						found = true;
					}
				}
				expect( found ).toBeTrue();
			} );

			it( "cases.create redirects to cases.index after POST", function(){
				var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
				expect( isNull( admin ) ).toBeFalse();
				var uniqueTitle = "CasesSpec handler " & createUUID();
				var event       = this.post(
					"cases.create",
					{
						title            = uniqueTitle,
						description      = "Handler coverage",
						status           = "New",
						assignedToUserId = admin.getUserId()
					},
					{},
					false
				);
				expect( event.getValue( "relocate_event", "" ) ).toBe( "cases.index" );
				var svc   = getWireBox().getInstance( "CaseService" );
				var found = false;
				for ( var c in svc.listActive() ) {
					if ( c.getTitle() == uniqueTitle ) {
						found = true;
					}
				}
				expect( found ).toBeTrue();
			} );

			it( "cases.view renders detail for an active case", function(){
				var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
				var uniqueTitle = "CasesSpec view " & createUUID();
				var svc         = getWireBox().getInstance( "CaseService" );
				var result      = svc.createCase(
					title            = uniqueTitle,
					description      = "",
					status           = "New",
					creatorUserId    = admin.getUserId(),
					assignedToUserId = admin.getUserId()
				);
				expect( result.success ).toBeTrue();
				var cid   = result.case.getCaseId();
				var event = this.get( "cases.view", { id = cid } );
				expect( event.getRenderedContent() ).toInclude( "Edit case" );
				expect( event.getRenderedContent() ).toInclude( "Summary" );
			} );

			it( "CaseService.updateCase updates an active case", function(){
				var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
				var svc   = getWireBox().getInstance( "CaseService" );
				var r     = svc.createCase(
					title            = "CasesSpec update svc " & createUUID(),
					description      = "before",
					status           = "New",
					creatorUserId    = admin.getUserId(),
					assignedToUserId = admin.getUserId()
				);
				expect( r.success ).toBeTrue();
				var newTitle = "CasesSpec updated " & createUUID();
				var ur       = svc.updateCase(
					caseId           = r.case.getCaseId(),
					title            = newTitle,
					description      = "after",
					status           = "New",
					assignedToUserId = admin.getUserId()
				);
				expect( ur.success ).toBeTrue();
				var fresh = svc.getActiveCase( r.case.getCaseId() );
				expect( fresh.getTitle() ).toBe( newTitle );
				expect( fresh.getDescription() ).toBe( "after" );
			} );

			it( "cases.update persists changes from POST", function(){
				var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
				var svc   = getWireBox().getInstance( "CaseService" );
				var r     = svc.createCase(
					title            = "CasesSpec handler upd " & createUUID(),
					description      = "",
					status           = "New",
					creatorUserId    = admin.getUserId(),
					assignedToUserId = admin.getUserId()
				);
				expect( r.success ).toBeTrue();
				var cid   = r.case.getCaseId();
				var title = "CasesSpec post update " & createUUID();
				this.post(
					"cases.update",
					{
						caseId           : cid,
						title            : title,
						description      : "post",
						status           : "New",
						assignedToUserId : admin.getUserId()
					},
					{},
					false
				);
				var fresh = svc.getActiveCase( cid );
				expect( fresh.getTitle() ).toBe( title );
			} );

			it( "cases.archive removes case from active list", function(){
				var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
				var svc   = getWireBox().getInstance( "CaseService" );
				var r     = svc.createCase(
					title            = "CasesSpec archive " & createUUID(),
					description      = "",
					status           = "New",
					creatorUserId    = admin.getUserId(),
					assignedToUserId = admin.getUserId()
				);
				expect( r.success ).toBeTrue();
				var cid   = r.case.getCaseId();
				var event = this.post( "cases.archive", { id : cid }, {}, false );
				expect( event.getValue( "relocate_event", "" ) ).toBe( "cases.index" );
				var stillThere = false;
				for ( var c in svc.listActive() ) {
					if ( c.getCaseId() == cid ) {
						stillThere = true;
					}
				}
				expect( stillThere ).toBeFalse();
			} );

		} );
	}

}
