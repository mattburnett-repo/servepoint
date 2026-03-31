component extends="coldbox.system.testing.BaseTestCase" appMapping="/root" {

    void function run() {
        describe( "Documents index", function() {

            beforeEach( function( currentSpec ) {
                setup();
                getWireBox().getInstance( "CaseService" ).restoreAllArchived();
            } );

            it( "documents.index renders documents workspace for selected case", function() {
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
                var event = this.get( "documents.index", { caseId = 999999 }, {}, false );
                expect( event.getValue( "relocate_event", "" ) ).toBe( "documents.index" );
            } );

        } );
    }
}
