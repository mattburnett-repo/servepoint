component persistent="true" extends="cborm.models.ActiveEntity" table="logentry" {

    // Primary Key
    property name="logEntryId" fieldtype="id" column="log_entry_id" generator="identity";

    // Attributes
    property name="dateCreated" type="date";
    property name="entryText"   type="string";

    // Relationships
    property name="caseRef" fieldtype="many-to-one" cfc="Cases" fkcolumn="case_id";
    property name="user"    fieldtype="many-to-one" cfc="Users" fkcolumn="user_id";
}
