component singleton accessors="true" {

    property name="caseService"            inject="CaseService";
    property name="communicationService" inject="CommunicationService";

    /**
     * Entry point for all seed operations.
     * This method should be idempotent: calling it multiple times should not duplicate data.
     */
    public void function runAll() {
        // Wrap seeding in a single transaction so we either fully seed or roll back
        transaction {
            seedUsers();
            seedCases();
            seedDocuments();
            seedCommunications();
        }
    }

    /**
     * One demo user per role (Citizen, Case Manager, Administrator). Idempotent by email.
     */
    private void function seedUsers() {
        var seeds = [
            {
                email     : "admin@example.com",
                firstName : "System",
                lastName  : "Administrator",
                role      : "Administrator"
            },
            {
                email     : "case.manager@example.com",
                firstName : "Case",
                lastName  : "Manager",
                role      : "Case Manager"
            },
            {
                email     : "citizen@example.com",
                firstName : "Demo",
                lastName  : "Citizen",
                role      : "Citizen"
            }
        ];
        for ( var i = 1; i <= arrayLen( seeds ); i++ ) {
            var s = seeds[ i ];
            if ( !isNull( entityLoad( "Users", { email : s.email }, true ) ) ) {
                continue;
            }
            var u = entityNew( "Users" );
            u.setFirstName( s.firstName );
            u.setLastName( s.lastName );
            u.setEmail( s.email );
            u.setPassword( "change-me" );
            u.setRole( s.role );
            entitySave( u );
        }
    }

    /**
     * Seed a small number of demo cases tied to the administrator user when no cases exist.
     */
    private void function seedCases() {
        var existingCases = entityLoad( "Cases" );
        if ( arrayLen( existingCases ) > 0 ) {
            return;
        }

        // Need an admin user to relate cases to; createUsers() ensures at least one exists.
        var adminUser = entityLoad( "Users", { email : "admin@example.com" }, true );
        if ( isNull( adminUser ) ) {
            // As a fallback, try to load any user.
            var anyUsers = entityLoad( "Users" );
            if ( arrayLen( anyUsers ) == 0 ) {
                return;
            }
            adminUser = anyUsers[ 1 ];
        }

        var statusConstants = new models.constants.Case_Status();
        var statuses        = statusConstants.getValues();

        var newStatus      = "New";
        var inProgressStatus = "In Progress";

        if ( !arrayFind( statuses, newStatus ) ) {
            newStatus = statuses[ 1 ];
        }
        if ( !arrayFind( statuses, inProgressStatus ) ) {
            inProgressStatus = statuses[ 1 ];
        }

        var case1 = entityNew( "Cases" );
        case1.setTitle( "Sample Service Request" );
        case1.setDescription( "A sample case created by the database seeder." );
        case1.setStatus( newStatus );
        case1.setCreator( adminUser );
        case1.setAssignedTo( adminUser );
        entitySave( case1 );

        var case2 = entityNew( "Cases" );
        case2.setTitle( "In-progress Case" );
        case2.setDescription( "An example case that is currently in progress." );
        case2.setStatus( inProgressStatus );
        case2.setCreator( adminUser );
        case2.setAssignedTo( adminUser );
        entitySave( case2 );
    }

    /**
     * Seed a simple document attached to one of the demo cases when none exist.
     */
    private void function seedDocuments() {
        var existingDocs = entityLoad( "Document" );
        if ( arrayLen( existingDocs ) > 0 ) {
            return;
        }

        var cases = caseService.listActive();
        if ( arrayLen( cases ) == 0 ) {
            return;
        }

        var caseRef = cases[ 1 ];

        var fileTypeConstants = new models.constants.Document_File_Type();
        var fileTypes         = fileTypeConstants.getValues();

        var pdfType = "pdf";
        if ( !arrayFind( fileTypes, pdfType ) ) {
            pdfType = fileTypes[ 1 ];
        }

        var doc = entityNew( "Document" );
        doc.setTitle( "Welcome Packet" );
        doc.setFileName( "welcome-packet." & pdfType );
        doc.setFileSize( 1 );
        doc.setFileType( pdfType );
        doc.setCaseRef( caseRef );
        entitySave( doc );
    }

    /**
     * Demo staff communications on seeded cases. Idempotent: skips if any communication row exists.
     */
    private void function seedCommunications() {
        if ( arrayLen( entityLoad( "Communication" ) ) > 0 ) {
            return;
        }

        var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
        var mgr   = entityLoad( "Users", { email : "case.manager@example.com" }, true );
        if ( isNull( admin ) || isNull( mgr ) ) {
            return;
        }

        var typeConstants = new models.constants.Communication_Type();
        var types         = typeConstants.getValues();
        if ( arrayLen( types ) == 0 ) {
            return;
        }
        var commType = types[ 1 ];

        var active = caseService.listActive();
        if ( arrayLen( active ) == 0 ) {
            return;
        }

        var caseA = active[ 1 ];
        var caseB = active[ 1 ];
        if ( arrayLen( active ) >= 2 ) {
            caseB = active[ 2 ];
        }
        for ( var i = 1; i <= arrayLen( active ); i++ ) {
            if ( active[ i ].getTitle() == "Sample Service Request" ) {
                caseA = active[ i ];
            }
            if ( active[ i ].getTitle() == "In-progress Case" ) {
                caseB = active[ i ];
            }
        }

        var seeds = [
            { caseId : caseA.getCaseId(), userId : admin.getUserId(), message : "Initial intake notes: client prefers morning contact." },
            { caseId : caseA.getCaseId(), userId : mgr.getUserId(), message : "Follow-up scheduled; waiting on supporting documents." },
            { caseId : caseB.getCaseId(), userId : mgr.getUserId(), message : "Reviewed case file; no blockers for next step." },
            { caseId : caseB.getCaseId(), userId : admin.getUserId(), message : "Document upload received and linked to this case." }
        ];
        for ( var j = 1; j <= arrayLen( seeds ); j++ ) {
            var s = seeds[ j ];
            var result = communicationService.createCommunication(
                caseId  = s.caseId,
                userId  = s.userId,
                message = s.message,
                type    = commType
            );
            if ( !result.success ) {
                throw( type = "Application", message = "seedCommunications failed: " & ( result.error ?: "unknown" ) );
            }
        }
    }

}

