component persistent="true" extends="cborm.models.ActiveEntity" table="log_entries" {

    // Inject the Log_Entry_Type component from the constants folder
    property name="Log_Entry_Type" inject="constants.Log_Entry_Type" persistent="false";

    // Primary Key
    property name="logEntryId" fieldtype="id" column="log_entry_id" generator="identity";

    // Attributes
    property name="dateCreated" type="date"   notnull="true";
    property name="entryText"   type="string" notnull="true";
    property name="type"        type="string" notnull="true";

    // Relationships
    property name="caseRef" fieldtype="many-to-one" cfc="Cases" fkcolumn="case_id" notnull="true";
    property name="user"    fieldtype="many-to-one" cfc="Users" fkcolumn="user_id" notnull="true";

    /**
     * ColdBox ORM lifecycle method to validate the data before saving.
     */
    public void function validate() {
        // Basic required-field validation
        if ( isNull( this.entryText ) || !len( trim( this.entryText ) ) ) {
            addError( property="entryText", message="Log entry text is required." );
        }

        if ( isNull( this.caseRef ) ) {
            addError( property="caseRef", message="Log entry must be associated with a case." );
        }

        if ( isNull( this.user ) ) {
            addError( property="user", message="Log entry must be associated with a user." );
        }

        // Get the valid log entry types from the Log_Entry_Type component
        var validTypes = this.Log_Entry_Type.getValues();

        // Check if the current log entry's type is NOT in the list of valid types.
        if ( !arrayFind( validTypes, this.type ) ) {
            // If it's not valid, add an error message to the 'type' property.
            addError( property="type", message="Invalid log entry type: The type '#this.type#' is not a valid option." );
        }
    }
}