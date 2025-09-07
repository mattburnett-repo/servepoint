component persistent="true" extends="cborm.models.ActiveEntity" table="cases" {
    // Inject the Case_Status component
    property name="Case_Status" inject="constants.Case_Status";

    // Primary Key
    property name="caseId" fieldtype="id" column="case_id" generator="identity";

    // Attributes
    property name="title"        type="string";
    property name="description"  type="string";
    property name="status"       type="string";
    property name="dateCreated"  type="date";
    property name="dateUpdated"  type="date";

    // Relationships
    property name="creator"     fieldtype="many-to-one" cfc="Users" fkcolumn="creator_id";
    property name="assignedTo"  fieldtype="many-to-one" cfc="Users" fkcolumn="assigned_to_id";

    property name="documents"   fieldtype="one-to-many" cfc="Document" fkcolumn="case_id";
    property name="logEntries"  fieldtype="one-to-many" cfc="LogEntry" fkcolumn="case_id";

    /**
     * ColdBox ORM lifecycle method to validate the data before saving.
     */
    public void function validate() {
        // Get the valid statuses from our Case_Status component.
        var validStatuses = this.Case_Status.getValues();

        // Check if the current case's status is NOT in the list of valid statuses.
        if ( !arrayFind( validStatuses, this.status ) ) {
            // If it's not valid, add an error message to the 'status' property.
            addError( property="status", message="Invalid status: The status '#this.status#' is not a valid option." );
        }
    }
}
