component extends="coldbox.system.testing.BaseTestCase" appMapping="/root" {

    function run(){
        describe( "Database Seeding", function(){

            beforeEach( function( currentSpec ){
                setup();
                getWireBox().getInstance( "CaseService" ).restoreAllArchived();
            } );

            it( "creates an administrator user and sample data", function(){
                var seedService = getWireBox().getInstance( "SeedService" );

                // Call seeding twice to verify idempotency does not raise errors
                seedService.runAll();
                seedService.runAll();

                // Verify that at least one user exists
                var users = entityLoad( "Users" );
                expect( arrayLen( users ) ).toBeGT( 0 );

                // Ensure the administrator email exists
                var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
                expect( isNull( admin ) ).toBeFalse();

                // Verify that at least one case exists
                var cases = entityLoad( "Cases" );
                expect( arrayLen( cases ) ).toBeGT( 0 );

                // Verify that at least one document exists
                var documents = entityLoad( "Document" );
                expect( arrayLen( documents ) ).toBeGT( 0 );

                // Seeded cases are active (not archived); default list should include all of them
                var caseService = getWireBox().getInstance( "CaseService" );
                var activeCases = caseService.listActive();
                var allCases = entityLoad( "Cases" );
                expect( arrayLen( activeCases ) ).toBe( arrayLen( allCases ) );
            } );
        } );
    }

}
