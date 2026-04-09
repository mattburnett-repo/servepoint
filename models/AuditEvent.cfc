component persistent="true" extends="cborm.models.ActiveEntity" table="audit_events" {

    property name="Audit_Category" persistent="false" inject="constants.Audit_Category";
    property name="Audit_Event_Type" persistent="false" inject="constants.Audit_Event_Type";
    property name="Audit_Outcome" persistent="false" inject="constants.Audit_Outcome";

    property name="auditEventId" fieldtype="id" column="audit_event_id" generator="identity";
    /** Set on insert by AuditLoggerService (and seeds); not updated after save. Same pattern as Communication.dateCreated: type="date" + ormtype="timestamp" so CF now() is accepted by the ORM setter. */
    property name="dateOccurred" type="date" ormtype="timestamp" column="date_occurred" insert="true" update="false" notnull="true";
    property name="requestId" type="string" column="request_id" notnull="false";
    property name="category" type="string" notnull="true";
    property name="eventType" type="string" column="event_type" notnull="true";
    property name="outcome" type="string" notnull="true";
    property name="reasonCode" type="string" column="reason_code" notnull="false";
    property name="message" type="string" notnull="true";
    property name="metadataJson" type="string" column="metadata_json" notnull="false";

    property name="caseRef" fieldtype="many-to-one" cfc="Cases" fkcolumn="case_id" notnull="false";
    property name="document" fieldtype="many-to-one" cfc="Document" fkcolumn="document_id" notnull="false";
    property name="actorUser" fieldtype="many-to-one" cfc="Users" fkcolumn="user_id" notnull="false";

    public void function validate() {
        if ( isNull( this.category ) || !len( trim( this.category ) ) ) {
            addError( property = "category", message = "Audit category is required." );
        } else if ( !arrayFindNoCase( this.Audit_Category.getValues(), trim( this.category ) ) ) {
            addError( property = "category", message = "Invalid audit category." );
        }

        if ( isNull( this.eventType ) || !len( trim( this.eventType ) ) ) {
            addError( property = "eventType", message = "Audit event type is required." );
        } else if ( !arrayFindNoCase( this.Audit_Event_Type.getValues(), trim( this.eventType ) ) ) {
            addError( property = "eventType", message = "Invalid audit event type." );
        }

        if ( isNull( this.outcome ) || !len( trim( this.outcome ) ) ) {
            addError( property = "outcome", message = "Audit outcome is required." );
        } else if ( !arrayFindNoCase( this.Audit_Outcome.getValues(), trim( this.outcome ) ) ) {
            addError( property = "outcome", message = "Invalid audit outcome." );
        }

        if ( isNull( this.message ) || !len( trim( this.message ) ) ) {
            addError( property = "message", message = "Audit message is required." );
        }
    }

    /**
     * Backward-compatible aliases used by existing case activity views/tests.
     */
    public any function getUser() {
        return getActorUser();
    }

    public any function getDateCreated() {
        return getDateOccurred();
    }

    public string function getEntryText() {
        return getMessage();
    }

    public string function getType() {
        return getEventType();
    }
}
