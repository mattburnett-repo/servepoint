component persistent="true" extends="cborm.models.ActiveEntity" table="cases" {
    // Inject the Case_Status component
    property name="Case_Status" inject="constants.Case_Status" persistent="false";

    // Primary Key
    property name="caseId" fieldtype="id" column="case_id" generator="identity";

    // Attributes
    property name="title"       type="string" notnull="true";
    property name="description" type="string";
    property name="status"      type="string" notnull="true";
    property name="dateCreated" type="timestamp" column="date_created" insert="false" update="false" notnull="false";
    property name="dateUpdated" type="timestamp" column="date_updated" insert="false" update="false" notnull="false";

    // Archive (soft): NULL archivedAt = active, non-NULL = archived
    property name="archivedAt"   type="date"   column="archived_at";
    property name="archivedBy"   fieldtype="many-to-one" cfc="Users" fkcolumn="archived_by";
    property name="archiveReason" type="string" column="archive_reason";

    // Relationships
    property name="creator"    fieldtype="many-to-one" cfc="Users" fkcolumn="creator_id"    notnull="true";
    property name="assignedTo" fieldtype="many-to-one" cfc="Users" fkcolumn="assigned_to_id";

    property name="documents"      fieldtype="one-to-many" cfc="Document"     fkcolumn="case_id";
    property name="logEntries"     fieldtype="one-to-many" cfc="LogEntry"     fkcolumn="case_id";
    property name="communications" fieldtype="one-to-many" cfc="Communication" fkcolumn="case_id";

    /**
     * ColdBox ORM lifecycle method to validate the data before saving.
     */
    public void function validate() {
        // Basic required-field validation
        if ( isNull( this.title ) || !len( trim( this.title ) ) ) {
            addError( property="title", message="Case title is required." );
        }

        if ( isNull( this.status ) || !len( trim( this.status ) ) ) {
            addError( property="status", message="Case status is required." );
        }

        if ( isNull( this.creator ) ) {
            addError( property="creator", message="Creator is required." );
        }

        // Get the valid statuses from our Case_Status component.
        var validStatuses = this.Case_Status.getValues();

        // Check if the current case's status is NOT in the list of valid statuses.
        if ( !arrayFind( validStatuses, this.status ) ) {
            // If it's not valid, add an error message to the 'status' property.
            addError( property="status", message="Invalid status: The status '#this.status#' is not a valid option." );
        }
    }

    /**
     * Returns true if this case is archived (soft-archived).
     */
    public boolean function isArchived() {
        return !isNull( this.archivedAt );
    }
}
