component extends="tests.specs.BaseIntegrationTestCase" appMapping="/root" {

    function run() {
        describe( "Audit reporting", function() {

            it( "reports.index renders the reporting page", function() {
                var event = this.get( "reports.index" );
                expect( event.getRenderedContent() ).toInclude( "Audit trails and reporting" );
                expect( event.getRenderedContent() ).toInclude( "Log entries by type" );
            } );

            it( "ReportsService returns grouped log entry counts for active cases by default", function() {
                var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
                expect( isNull( admin ) ).toBeFalse();
                var caseService = getWireBox().getInstance( "CaseService" );
                var reportsService = getWireBox().getInstance( "ReportsService" );
                var created = caseService.createCase(
                    title = "Reports active grouping " & createUUID(),
                    description = "",
                    status = "New",
                    creatorUserId = admin.getUserId(),
                    assignedToUserId = admin.getUserId()
                );
                expect( created.success ).toBeTrue();

                var q = reportsService.getTypeCounts();
                expect( q.recordCount ).toBeGTE( 1 );
                var hasCaseCreate = false;
                for ( var i = 1; i <= q.recordCount; i++ ) {
                    if ( q.type[ i ] == "Case Create" ) {
                        hasCaseCreate = true;
                    }
                }
                expect( hasCaseCreate ).toBeTrue();
            } );

            it( "ReportsService excludes archived cases by default and includes them when requested", function() {
                var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
                expect( isNull( admin ) ).toBeFalse();
                var caseService = getWireBox().getInstance( "CaseService" );
                var reportsService = getWireBox().getInstance( "ReportsService" );
                var created = caseService.createCase(
                    title = "Reports archived filter " & createUUID(),
                    description = "",
                    status = "New",
                    creatorUserId = admin.getUserId(),
                    assignedToUserId = admin.getUserId()
                );
                expect( created.success ).toBeTrue();
                var archived = caseService.archiveCase(
                    caseId = created.case.getCaseId(),
                    userId = admin.getUserId(),
                    reason = "reports spec",
                    createLogEntry = true
                );
                expect( archived.success ).toBeTrue();

                var withoutArchived = reportsService.getTypeCounts();
                var withArchived = reportsService.getTypeCounts( includeArchived = true );

                var foundArchiveWithout = false;
                var foundArchiveWith = false;
                for ( var i = 1; i <= withoutArchived.recordCount; i++ ) {
                    if ( withoutArchived.type[ i ] == "Case Archive" ) {
                        foundArchiveWithout = true;
                    }
                }
                for ( var j = 1; j <= withArchived.recordCount; j++ ) {
                    if ( withArchived.type[ j ] == "Case Archive" ) {
                        foundArchiveWith = true;
                    }
                }
                expect( foundArchiveWithout ).toBeFalse();
                expect( foundArchiveWith ).toBeTrue();
            } );

            it( "ReportsService getTypeCounts binds date filters as timestamps (no PG operator error)", function() {
                var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
                expect( isNull( admin ) ).toBeFalse();
                var caseService = getWireBox().getInstance( "CaseService" );
                var reportsService = getWireBox().getInstance( "ReportsService" );
                var created = caseService.createCase(
                    title = "Reports date filter " & createUUID(),
                    description = "",
                    status = "New",
                    creatorUserId = admin.getUserId(),
                    assignedToUserId = admin.getUserId()
                );
                expect( created.success ).toBeTrue();
                var today = dateFormat( now(), "yyyy-mm-dd" );
                var q = reportsService.getTypeCounts( dateFrom = today, dateTo = today );
                expect( q.recordCount ).toBeGTE( 1 );
            } );
        } );
    }
}
