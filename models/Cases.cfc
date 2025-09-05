component persistent="true" extends="cborm.models.ActiveEntity" table="cases" {

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

    // property name="documents"   fieldtype="one-to-many" cfc="Document" mappedBy="caseRef";
    // property name="logEntries"  fieldtype="one-to-many" cfc="LogEntry" mappedBy="caseRef";
    property name="documents"   fieldtype="one-to-many" cfc="Document" fkcolumn="document_id";
    property name="logEntries"  fieldtype="one-to-many" cfc="LogEntry" fkcolumn="logEntry_id";

    // Dummy property so ORM finds 'caseRef' on Cases (probably from document, logentry, etc)
    // property name="caseRef" type="any" ormTransient="true";
}
