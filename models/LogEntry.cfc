component persistent="true" extends="cborm.models.ActiveEntity" table="log_entries" {

    // Inject the Log_Entry_Type component from the constants folder
    property name="Log_Entry_Type" inject="constants.Log_Entry_Type";

    // Primary Key
    property name="logEntryId" fieldtype="id" column="log_entry_id" generator="identity";

    // Attributes
    property name="dateCreated" type="date";
    property name="entryText"   type="string";
    property name="type"        type="string";

    // Relationships
    property name="caseRef" fieldtype="many-to-one" cfc="Cases" fkcolumn="case_id";
    property name="user"    fieldtype="many-to-one" cfc="Users" fkcolumn="user_id";

    /**
     * ColdBox ORM lifecycle method to validate the data before saving.
     */
    public void function validate() {
        // Get the valid log entry types from the Log_Entry_Type component
        var validTypes = this.Log_Entry_Type.getValues();

        // Check if the current log entry's type is NOT in the list of valid types.
        if ( !arrayFind( validTypes, this.type ) ) {
            // If it's not valid, add an error message to the 'type' property.
            addError( property="type", message="Invalid log entry type: The type '#this.type#' is not a valid option." );
        }
    }
}