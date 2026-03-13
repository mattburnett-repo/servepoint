component {

    function up( schema, qb ) {
        schema.alter( "cases", function( t ) {
            t.addColumn( t.timestamp( "archived_at" ).nullable() );
            t.addColumn( t.integer( "archived_by" ).nullable() );
            t.addColumn( t.string( "archive_reason" ).nullable() );
            t.index( [ "archived_at" ] );
            t.foreignKey( "archived_by" ).references( "user_id" ).onTable( "users" );
        } );
    }

    function down( schema, qb ) {
        schema.alter( "cases", function( t ) {
            t.dropForeignKey( "archived_by" );
            t.dropIndex( [ "archived_at" ] );
            t.dropColumn( "archive_reason" );
            t.dropColumn( "archived_by" );
            t.dropColumn( "archived_at" );
        } );
    }
}
