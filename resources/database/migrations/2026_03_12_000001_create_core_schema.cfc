component {

    function up( schema, qb ) {
        // Idempotent for DBs that already have tables from dbcreate="update": skip create if table exists.
        // users (QB columns are NOT NULL by default; use .nullable() only for optional columns)
        if ( !schema.hasTable( "users" ) ) {
            schema.create( "users", function( t ) {
                t.increments( "user_id" );
                t.string( "firstName" );
                t.string( "lastName" );
                t.string( "email" );
                t.string( "password" );
                t.string( "role" );
                t.unique( [ "email" ] );
            } );
        }

        // cases
        if ( !schema.hasTable( "cases" ) ) {
        schema.create( "cases", function( t ) {
            t.increments( "case_id" );
            t.string( "title" );
            t.text( "description" ).nullable();
            t.string( "status" );
            t.timestamp( "dateCreated" );
            t.timestamp( "dateUpdated" ).nullable();
            t.integer( "creator_id" );
            t.integer( "assigned_to_id" ).nullable();

            t.index( [ "status" ] );
            t.index( [ "creator_id" ] );
            t.index( [ "assigned_to_id" ] );

            t.foreignKey( "creator_id" ).references( "user_id" ).onTable( "users" );
            t.foreignKey( "assigned_to_id" ).references( "user_id" ).onTable( "users" );
        } );
        }

        // documents
        if ( !schema.hasTable( "documents" ) ) {
        schema.create( "documents", function( t ) {
            t.increments( "document_id" );
            t.string( "title" );
            t.string( "fileName" );
            t.decimal( "fileSize", 18, 2 );
            t.string( "fileType" );
            t.timestamp( "dateUploaded" );
            t.integer( "case_id" );

            t.index( [ "case_id" ] );

            t.foreignKey( "case_id" ).references( "case_id" ).onTable( "cases" );
        } );
        }

        // log_entries
        if ( !schema.hasTable( "log_entries" ) ) {
        schema.create( "log_entries", function( t ) {
            t.increments( "log_entry_id" );
            t.timestamp( "dateCreated" );
            t.text( "entryText" );
            t.string( "type" );
            t.integer( "case_id" );
            t.integer( "user_id" );

            t.index( [ "case_id" ] );
            t.index( [ "user_id" ] );
            t.index( [ "type" ] );

            t.foreignKey( "case_id" ).references( "case_id" ).onTable( "cases" );
            t.foreignKey( "user_id" ).references( "user_id" ).onTable( "users" );
        } );
        }
    }

    function down( schema, qb ) {
        schema.dropIfExists( "log_entries" );
        schema.dropIfExists( "documents" );
        schema.dropIfExists( "cases" );
        schema.dropIfExists( "users" );
    }
}

