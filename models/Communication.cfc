component persistent="true" extends="cborm.models.ActiveEntity" table="communications" {

    property name="Communication_Type" inject="constants.Communication_Type" persistent="false";

    property name="communicationId" fieldtype="id" column="communication_id" generator="identity";

    // App sets both on insert (now()); type="date" accepts CF now(); ormtype="timestamp" stores full date+time. Trigger still maintains date_updated on SQL UPDATE.
    property name="dateCreated" type="date" ormtype="timestamp" column="date_created" insert="true" update="false" notnull="true";
    property name="dateUpdated" type="date" ormtype="timestamp" column="date_updated" insert="true" update="false" notnull="true";
    property name="message"     type="string"  column="message" notnull="true";
    property name="type"        type="string"  notnull="true";

    property name="caseRef"   fieldtype="many-to-one" cfc="Cases" fkcolumn="case_id" notnull="true";
    property name="author"    fieldtype="many-to-one" cfc="Users" fkcolumn="user_id" notnull="true";
    property name="updatedBy" fieldtype="many-to-one" cfc="Users" fkcolumn="updated_by";

    public void function validate() {
        if ( isNull( this.message ) || !len( trim( this.message ) ) ) {
            addError( property="message", message="Message is required." );
        }
        if ( !isNull( this.message ) && len( this.message ) > 10000 ) {
            addError( property="message", message="Message must be 10000 characters or less." );
        }
        if ( isNull( this.caseRef ) ) {
            addError( property="caseRef", message="Communication must be associated with a case." );
        }
        if ( isNull( this.author ) ) {
            addError( property="author", message="Communication must have an author." );
        }
        var validTypes = this.Communication_Type.getValues();
        if ( !arrayFind( validTypes, this.type ) ) {
            addError( property="type", message="Invalid communication type: '#this.type#'." );
        }
    }

}
