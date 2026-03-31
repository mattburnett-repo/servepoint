component persistent="true" extends="cborm.models.ActiveEntity" table="documents" {
    // Inject the Document_File_Type component from the constants folder
    property name="Document_File_Type" inject="constants.Document_File_Type" persistent="false";

    // Primary Key
    property name="documentId"   fieldtype="id" column="document_id" generator="identity";

    // Attributes
    property name="title"        type="string"  notnull="true";
    property name="fileName"     type="string"  notnull="true";
    property name="fileSize"     type="numeric" notnull="true";
    property name="fileType"     type="string"  notnull="true";
    property name="dateUploaded" type="timestamp" column="date_uploaded" insert="false" update="false" notnull="false";

    // Relationship
    property name="caseRef" fieldtype="many-to-one" cfc="Cases" fkcolumn="case_id" notnull="true";

    /**
     * ColdBox ORM lifecycle method to validate the data before saving.
     */
    public void function validate() {
        // Basic required-field validation
        if ( isNull( this.title ) || !len( trim( this.title ) ) ) {
            addError( property="title", message="Document title is required." );
        }

        if ( isNull( this.fileName ) || !len( trim( this.fileName ) ) ) {
            addError( property="fileName", message="Document file name is required." );
        }

        if ( isNull( this.fileSize ) || this.fileSize LTE 0 ) {
            addError( property="fileSize", message="Document file size must be greater than zero." );
        }

        if ( isNull( this.caseRef ) ) {
            addError( property="caseRef", message="Document must be associated with a case." );
        }

        // Get the valid file types from the Document_File_Type component
        var validFileTypes = this.Document_File_Type.getValues();

        // Check if the current document's file type is NOT in the list of valid types.
        if ( !arrayFind( validFileTypes, this.fileType ) ) {
            // If it's not valid, add an error message to the 'fileType' property.
            addError( property="fileType", message="Invalid file type: The type '#this.fileType#' is not a valid option." );
        }
    }
}