component extends="tests.specs.BaseIntegrationTestCase" appMapping="/root" {

	function run(){
		describe( "Staff communications", function(){

			it( "CommunicationService.createCommunication persists on active case", function(){
				var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
				expect( isNull( admin ) ).toBeFalse();
				var svcCase = getWireBox().getInstance( "CaseService" );
				var cr      = svcCase.createCase(
					title            = "CommsSpec svc " & createUUID(),
					description      = "",
					status           = "New",
					creatorUserId    = admin.getUserId(),
					assignedToUserId = admin.getUserId()
				);
				expect( cr.success ).toBeTrue();
				var commSvc = getWireBox().getInstance( "CommunicationService" );
				var typeConstants = new models.constants.Communication_Type();
				var typeVal       = typeConstants.getValues()[ 1 ];
				var result  = commSvc.createCommunication(
					caseId  = cr.case.getCaseId(),
					userId  = admin.getUserId(),
					message = "Integration test note.",
					type    = typeVal
				);
				expect( result.success ).toBeTrue();
				var list = commSvc.listForCase( cr.case.getCaseId() );
				expect( arrayLen( list ) ).toBeGTE( 1 );
			} );

			it( "CommunicationService rejects empty message", function(){
				var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
				var svcCase = getWireBox().getInstance( "CaseService" );
				var cr      = svcCase.createCase(
					title            = "CommsSpec empty " & createUUID(),
					description      = "",
					status           = "New",
					creatorUserId    = admin.getUserId(),
					assignedToUserId = admin.getUserId()
				);
				expect( cr.success ).toBeTrue();
				var commSvc = getWireBox().getInstance( "CommunicationService" );
				var typeConstants = new models.constants.Communication_Type();
				var typeVal       = typeConstants.getValues()[ 1 ];
				var result  = commSvc.createCommunication(
					caseId  = cr.case.getCaseId(),
					userId  = admin.getUserId(),
					message = "   ",
					type    = typeVal
				);
				expect( result.success ).toBeFalse();
			} );

			it( "CommunicationService rejects invalid type", function(){
				var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
				var svcCase = getWireBox().getInstance( "CaseService" );
				var cr      = svcCase.createCase(
					title            = "CommsSpec type " & createUUID(),
					description      = "",
					status           = "New",
					creatorUserId    = admin.getUserId(),
					assignedToUserId = admin.getUserId()
				);
				expect( cr.success ).toBeTrue();
				var commSvc = getWireBox().getInstance( "CommunicationService" );
				var result  = commSvc.createCommunication(
					caseId  = cr.case.getCaseId(),
					userId  = admin.getUserId(),
					message = "hello",
					type    = "Not A Real Type"
				);
				expect( result.success ).toBeFalse();
			} );

			it( "CommunicationService rejects archived case", function(){
				var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
				var svcCase = getWireBox().getInstance( "CaseService" );
				var cr      = svcCase.createCase(
					title            = "CommsSpec arch " & createUUID(),
					description      = "",
					status           = "New",
					creatorUserId    = admin.getUserId(),
					assignedToUserId = admin.getUserId()
				);
				expect( cr.success ).toBeTrue();
				var ar = svcCase.archiveCase( caseId = cr.case.getCaseId(), userId = admin.getUserId(), reason = "test" );
				expect( ar.success ).toBeTrue();
				var commSvc = getWireBox().getInstance( "CommunicationService" );
				var typeConstants = new models.constants.Communication_Type();
				var typeVal       = typeConstants.getValues()[ 1 ];
				var result  = commSvc.createCommunication(
					caseId  = cr.case.getCaseId(),
					userId  = admin.getUserId(),
					message = "should fail",
					type    = typeVal
				);
				expect( result.success ).toBeFalse();
			} );

			it( "communications.index renders hub", function(){
				var event = this.get( "communications.index" );
				expect( event.getRenderedContent() ).toInclude( "Staff communications" );
			} );

			it( "CommunicationService.listForHub filters by caseId", function(){
				var admin   = entityLoad( "Users", { email : "admin@example.com" }, true );
				var svcCase = getWireBox().getInstance( "CaseService" );
				var c1      = svcCase.createCase(
					title            = "CommsSpec hub A " & createUUID(),
					description      = "",
					status           = "New",
					creatorUserId    = admin.getUserId(),
					assignedToUserId = admin.getUserId()
				);
				var c2 = svcCase.createCase(
					title            = "CommsSpec hub B " & createUUID(),
					description      = "",
					status           = "New",
					creatorUserId    = admin.getUserId(),
					assignedToUserId = admin.getUserId()
				);
				expect( c1.success && c2.success ).toBeTrue();
				var commSvc = getWireBox().getInstance( "CommunicationService" );
				var typeConstants = new models.constants.Communication_Type();
				var typeVal       = typeConstants.getValues()[ 1 ];
				commSvc.createCommunication( caseId = c1.case.getCaseId(), userId = admin.getUserId(), message = "Only on case A", type = typeVal );
				commSvc.createCommunication( caseId = c2.case.getCaseId(), userId = admin.getUserId(), message = "Only on case B", type = typeVal );
				var filtered = commSvc.listForHub( caseId = c1.case.getCaseId(), type = "", authorUserId = 0 );
				var onlyA    = true;
				for ( var row in filtered ) {
					if ( row.getCaseRef().getCaseId() != c1.case.getCaseId() ) {
						onlyA = false;
					}
				}
				expect( onlyA ).toBeTrue();
				expect( arrayLen( filtered ) ).toBeGTE( 1 );
			} );

			it( "cases.addCommunication POST redirects to case view", function(){
				var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
				var svcCase = getWireBox().getInstance( "CaseService" );
				var cr      = svcCase.createCase(
					title            = "CommsSpec post " & createUUID(),
					description      = "",
					status           = "New",
					creatorUserId    = admin.getUserId(),
					assignedToUserId = admin.getUserId()
				);
				expect( cr.success ).toBeTrue();
				var cid   = cr.case.getCaseId();
				var event = this.post(
					"cases.addCommunication",
					{ caseId : cid, message : "Posted from handler test." },
					{},
					false
				);
				expect( event.getValue( "relocate_event", "" ) ).toBe( "cases.view" );
			} );

			it( "cases.view shows Communications section", function(){
				var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
				var svcCase = getWireBox().getInstance( "CaseService" );
				var cr      = svcCase.createCase(
					title            = "CommsSpec view " & createUUID(),
					description      = "",
					status           = "New",
					creatorUserId    = admin.getUserId(),
					assignedToUserId = admin.getUserId()
				);
				expect( cr.success ).toBeTrue();
				var event = this.get( "cases.view", { id = cr.case.getCaseId() } );
				expect( event.getRenderedContent() ).toInclude( "Communications" );
				expect( event.getRenderedContent() ).toInclude( "Case activity" );
			} );

		} );
	}

}
