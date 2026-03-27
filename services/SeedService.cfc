component singleton accessors="true" {

    property name="caseService" inject="CaseService";

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
        }
    }

    /**
     * Ensure at least one administrator user exists.
     * Uses the User_Role constants to select a valid admin role.
     */
    private void function seedUsers() {
        // If any users already exist, assume seeding has been done.
        var existingUsers = entityLoad( "Users" );
        if ( arrayLen( existingUsers ) > 0 ) {
            return;
        }

        // Load role constants so we choose a valid role value.
        var roleConstants = new models.constants.User_Role();
        var roles         = roleConstants.getValues();

        // Prefer the Administrator role if present; otherwise fall back to the first defined role.
        var adminRole = "Administrator";
        if ( !arrayFind( roles, adminRole ) ) {
            adminRole = roles[ 1 ];
        }

        var admin = entityNew( "Users" );
        admin.setFirstName( "System" );
        admin.setLastName( "Administrator" );
        admin.setEmail( "admin@example.com" );
        // In a real deployment this should be replaced/reset; this is demo-only.
        admin.setPassword( "change-me" );
        admin.setRole( adminRole );
        entitySave( admin );
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

        var now = now();

        var case1 = entityNew( "Cases" );
        case1.setTitle( "Sample Service Request" );
        case1.setDescription( "A sample case created by the database seeder." );
        case1.setStatus( newStatus );
        case1.setDateCreated( now );
        case1.setDateUpdated( now );
        case1.setCreator( adminUser );
        case1.setAssignedTo( adminUser );
        entitySave( case1 );

        var case2 = entityNew( "Cases" );
        case2.setTitle( "In-progress Case" );
        case2.setDescription( "An example case that is currently in progress." );
        case2.setStatus( inProgressStatus );
        case2.setDateCreated( now );
        case2.setDateUpdated( now );
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
        doc.setFileSize( 0 );
        doc.setFileType( pdfType );
        doc.setDateUploaded( now() );
        doc.setCaseRef( caseRef );
        entitySave( doc );
    }

}
