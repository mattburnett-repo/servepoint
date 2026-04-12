component extends="tests.specs.BaseIntegrationTestCase" appMapping="/root" {

    void function run() {
        describe( "Documents index", function() {

            it( "documents.index renders documents workspace for selected case", function() {
                this.loginAsSeedUser( "admin@example.com" );
                var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
                var caseService = getWireBox().getInstance( "CaseService" );
                var created = caseService.createCase(
                    title = "Doc index view " & createUUID(),
                    description = "",
                    status = "New",
                    creatorUserId = admin.getUserId(),
                    assignedToUserId = admin.getUserId()
                );

                var event = this.get( "documents.index", { caseId = created.case.getCaseId() } );
                expect( event.getRenderedContent() ).toInclude( "Documents" );
                expect( event.getRenderedContent() ).toInclude( "Upload document" );
            } );

            it( "documents.index rejects unknown case selection", function() {
                this.loginAsSeedUser( "admin@example.com" );
                var event = this.get( "documents.index", { caseId = 999999 }, {}, false );
                expect( event.getValue( "relocate_event", "" ) ).toBe( "documents.index" );
            } );

        } );
    }
}
