component extends="tests.specs.BaseIntegrationTestCase" appMapping="/root" {

    function run() {
        describe( "LogEntryService", function() {

            it( "record persists a valid log entry", function() {
                var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
                expect( isNull( admin ) ).toBeFalse();
                var caseSvc = getWireBox().getInstance( "CaseService" );
                var cr      = caseSvc.createCase(
                    title            = "LogEntrySvc ok " & createUUID(),
                    description      = "",
                    status           = "New",
                    creatorUserId    = admin.getUserId(),
                    assignedToUserId = admin.getUserId()
                );
                expect( cr.success ).toBeTrue();

                var logSvc = getWireBox().getInstance( "LogEntryService" );
                var result = logSvc.record(
                    caseId    = cr.case.getCaseId(),
                    userId    = admin.getUserId(),
                    type      = "Case Update",
                    entryText = "Integration test log line."
                );
                expect( result.success ).toBeTrue();
                expect( isNull( result.logEntry ) ).toBeFalse();
                expect( result.logEntry.getLogEntryId() ).toBeGT( 0 );
                expect( result.logEntry.getEntryText() ).toBe( "Integration test log line." );
                expect( result.logEntry.getType() ).toBe( "Case Update" );
            } );

            it( "record returns error when case does not exist", function() {
                var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
                expect( isNull( admin ) ).toBeFalse();
                var logSvc = getWireBox().getInstance( "LogEntryService" );
                var result = logSvc.record(
                    caseId    = 999999999,
                    userId    = admin.getUserId(),
                    type      = "Case Update",
                    entryText = "Should not persist."
                );
                expect( result.success ).toBeFalse();
                expect( result.error ).toBe( "Case not found." );
            } );

            it( "record returns error when user does not exist", function() {
                var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
                expect( isNull( admin ) ).toBeFalse();
                var caseSvc = getWireBox().getInstance( "CaseService" );
                var cr      = caseSvc.createCase(
                    title            = "LogEntrySvc bad user " & createUUID(),
                    description      = "",
                    status           = "New",
                    creatorUserId    = admin.getUserId(),
                    assignedToUserId = admin.getUserId()
                );
                expect( cr.success ).toBeTrue();

                var logSvc = getWireBox().getInstance( "LogEntryService" );
                var result = logSvc.record(
                    caseId    = cr.case.getCaseId(),
                    userId    = 999999999,
                    type      = "Case Update",
                    entryText = "Should not persist."
                );
                expect( result.success ).toBeFalse();
                expect( result.error ).toBe( "User not found." );
            } );

            it( "record rejects blank entry text", function() {
                var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
                expect( isNull( admin ) ).toBeFalse();
                var caseSvc = getWireBox().getInstance( "CaseService" );
                var cr      = caseSvc.createCase(
                    title            = "LogEntrySvc blank text " & createUUID(),
                    description      = "",
                    status           = "New",
                    creatorUserId    = admin.getUserId(),
                    assignedToUserId = admin.getUserId()
                );
                expect( cr.success ).toBeTrue();

                var logSvc = getWireBox().getInstance( "LogEntryService" );
                var result = logSvc.record(
                    caseId    = cr.case.getCaseId(),
                    userId    = admin.getUserId(),
                    type      = "Case Update",
                    entryText = "   "
                );
                expect( result.success ).toBeFalse();
                expect( result.error ).toBe( "Log entry text is required." );
            } );

            it( "record rejects invalid log entry type", function() {
                var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
                expect( isNull( admin ) ).toBeFalse();
                var caseSvc = getWireBox().getInstance( "CaseService" );
                var cr      = caseSvc.createCase(
                    title            = "LogEntrySvc bad type " & createUUID(),
                    description      = "",
                    status           = "New",
                    creatorUserId    = admin.getUserId(),
                    assignedToUserId = admin.getUserId()
                );
                expect( cr.success ).toBeTrue();

                var logSvc = getWireBox().getInstance( "LogEntryService" );
                var result = logSvc.record(
                    caseId    = cr.case.getCaseId(),
                    userId    = admin.getUserId(),
                    type      = "Not A Registered Log Type",
                    entryText = "Some text."
                );
                expect( result.success ).toBeFalse();
                expect( result.error ).toBe( "Invalid log entry type." );
            } );

            it( "CommunicationService.createCommunication leaves activity log entries", function() {
                var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
                expect( isNull( admin ) ).toBeFalse();
                var caseSvc = getWireBox().getInstance( "CaseService" );
                var cr      = caseSvc.createCase(
                    title            = "LogEntrySvc wiring " & createUUID(),
                    description      = "",
                    status           = "New",
                    creatorUserId    = admin.getUserId(),
                    assignedToUserId = admin.getUserId()
                );
                expect( cr.success ).toBeTrue();

                var typeConstants = new models.constants.Communication_Type();
                var typeVal       = typeConstants.getValues()[ 1 ];
                var commSvc       = getWireBox().getInstance( "CommunicationService" );
                var commResult    = commSvc.createCommunication(
                    caseId  = cr.case.getCaseId(),
                    userId  = admin.getUserId(),
                    message = "Note for activity log wiring test.",
                    type    = typeVal
                );
                expect( commResult.success ).toBeTrue();

                var activity = commSvc.listLogEntriesForCase( cr.case.getCaseId() );
                expect( arrayLen( activity ) ).toBeGTE( 2 );
            } );

        } );
    }

}
