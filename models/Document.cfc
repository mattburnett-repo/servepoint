component persistent="true" extends="cborm.models.ActiveEntity" table="documents" {
    // Inject the Document_FileType component from the constants folder
    property name="Document_FileType" inject="constants.Document_FileType";

    // Primary Key
    property name="documentId" fieldtype="id" column="document_id" generator="identity";

    // Attributes
    property name="title"        type="string";
    property name="fileName"     type="string";
    property name="fileSize"     type="numeric";
    property name="fileType"     type="string";
    property name="dateUploaded" type="date";

    // Relationship
    property name="caseRef" fieldtype="many-to-one" cfc="Cases" fkcolumn="case_id";

    /**
     * ColdBox ORM lifecycle method to validate the data before saving.
     */
    public void function validate() {
        // Get the valid file types from the Document_FileType component
        var validFileTypes = this.Document_FileType.getValues();

        // Check if the current document's file type is NOT in the list of valid types.
        if ( !arrayFind( validFileTypes, this.fileType ) ) {
            // If it's not valid, add an error message to the 'fileType' property.
            addError( property="fileType", message="Invalid file type: The type '#this.fileType#' is not a valid option." );
        }
    }
}