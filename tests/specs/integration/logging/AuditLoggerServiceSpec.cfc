component extends="tests.specs.BaseIntegrationTestCase" appMapping="/root" {

    function run() {
        describe( "AuditLoggerService", function() {

            it( "record persists a valid audit event", function() {
                var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
                expect( isNull( admin ) ).toBeFalse();

                var caseService = getWireBox().getInstance( "CaseService" );
                var created = caseService.createCase(
                    title = "AuditLogger record " & createUUID(),
                    description = "",
                    status = "New",
                    creatorUserId = admin.getUserId(),
                    assignedToUserId = admin.getUserId()
                );
                expect( created.success ).toBeTrue();

                var auditLogger = getWireBox().getInstance( "AuditLoggerService" );
                var result = auditLogger.record(
                    category = "case",
                    eventType = "Case Update",
                    outcome = "success",
                    actorUserId = admin.getUserId(),
                    caseId = created.case.getCaseId(),
                    reasonCode = "spec",
                    message = "Audit logger integration test event.",
                    metadata = { source = "spec" }
                );

                expect( result.success ).toBeTrue();
                expect( result.auditEvent.getAuditEventId() ).toBeGT( 0 );
                expect( isNull( result.auditEvent.getDateOccurred() ) ).toBeFalse();
                expect( result.auditEvent.getCategory() ).toBe( "case" );
                expect( result.auditEvent.getEventType() ).toBe( "Case Update" );
                expect( result.auditEvent.getOutcome() ).toBe( "success" );
            } );

            it( "record redacts sensitive metadata", function() {
                var auditLogger = getWireBox().getInstance( "AuditLoggerService" );
                var result = auditLogger.record(
                    category = "security",
                    eventType = "Login Failure",
                    outcome = "failure",
                    reasonCode = "invalid_credentials",
                    message = "Login failed for demo user.",
                    metadata = {
                        username = "demo@example.com",
                        password = "super-secret",
                        authToken = "abc123"
                    }
                );

                expect( result.success ).toBeTrue();
                var metadata = deserializeJSON( result.auditEvent.getMetadataJson() );
                expect( metadata.password ).toBe( "[REDACTED]" );
                expect( metadata.authToken ).toBe( "[REDACTED]" );
            } );
        } );
    }
}
