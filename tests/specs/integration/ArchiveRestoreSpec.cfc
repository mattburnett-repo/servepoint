component extends="coldbox.system.testing.BaseTestCase" appMapping="/root" {

    function run(){
        describe( "Archive / restore and query convention", function(){

            beforeEach( function( currentSpec ){
                setup();
                // Restore all in same request as the test so listActive() sees correct state
                var caseService = getWireBox().getInstance( "CaseService" );
                caseService.restoreAllArchived();
            } );

            it( "listActive returns only active cases; listAll( true ) includes archived", function(){
                var caseService = getWireBox().getInstance( "CaseService" );
                var active = caseService.listActive();
                var all = caseService.listAll( true );
                expect( arrayLen( active ) ).toBe( arrayLen( all ) );

                var user = entityLoad( "Users", { email : "admin@example.com" }, true );
                if ( isNull( user ) ) {
                    var anyUsers = entityLoad( "Users" );
                    if ( arrayLen( anyUsers ) == 0 ) return;
                    user = anyUsers[ 1 ];
                }
                var cases = caseService.listActive();
                if ( arrayLen( cases ) == 0 ) return;
                var caseToArchive = cases[ 1 ];
                var result = caseService.archiveCase( caseToArchive.getCaseId(), user.getUserId(), "Test archive", true );
                expect( result.success ).toBeTrue();

                active = caseService.listActive();
                all = caseService.listAll( true );
                expect( arrayLen( active ) ).toBe( arrayLen( all ) - 1 );
            } );

            it( "archiveCase excludes case from listActive; restoreCase includes it again", function(){
                var caseService = getWireBox().getInstance( "CaseService" );
                var user = entityLoad( "Users", { email : "admin@example.com" }, true );
                if ( isNull( user ) ) {
                    var anyUsers = entityLoad( "Users" );
                    if ( arrayLen( anyUsers ) == 0 ) return;
                    user = anyUsers[ 1 ];
                }
                var cases = caseService.listActive();
                if ( arrayLen( cases ) == 0 ) return;
                var caseEntity = cases[ 1 ];
                var caseId = caseEntity.getCaseId();
                var countBefore = arrayLen( caseService.listActive() );

                var archiveResult = caseService.archiveCase( caseId, user.getUserId(), "", true );
                expect( archiveResult.success ).toBeTrue();
                expect( arrayLen( caseService.listActive() ) ).toBe( countBefore - 1 );

                var restoreResult = caseService.restoreCase( caseId, user.getUserId(), true );
                expect( restoreResult.success ).toBeTrue( restoreResult.error ?: "no error message" );
                expect( arrayLen( caseService.listActive() ) ).toBe( countBefore );
            } );

            it( "archiveCase returns error when case not found or already archived", function(){
                var caseService = getWireBox().getInstance( "CaseService" );
                var user = entityLoad( "Users", { email : "admin@example.com" }, true );
                if ( isNull( user ) ) {
                    return;
                }
                var notFound = caseService.archiveCase( 999999, user.getUserId(), "", false );
                expect( notFound.success ).toBeFalse();
                expect( notFound.error ).toInclude( "not found" );
            } );
        } );
    }

}
