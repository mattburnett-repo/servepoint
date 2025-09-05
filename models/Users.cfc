component persistent="true" extends="cborm.models.ActiveEntity" table="users" {

    // Primary Key
    property name="userId" fieldtype="id" column="user_id" generator="identity";

    // Attributes
    property name="firstName"   type="string";
    property name="lastName"    type="string";
    property name="email"       type="string";
    property name="password"    type="string";
    property name="role"        type="string";
    property name="dateCreated" type="date";
    property name="dateUpdated" type="date";

    // Relationships
    // property name="casesCreated"  fieldtype="one-to-many" cfc="Cases" mappedBy="creator";
    // property name="casesAssigned" fieldtype="one-to-many" cfc="Cases" mappedBy="assignedTo";
    // property name="logEntries"    fieldtype="one-to-many" cfc="LogEntry" mappedBy="user";
    property name="casesCreated"  fieldtype="one-to-many" cfc="Cases" fkcolumn="case_id";
    property name="casesAssigned" fieldtype="one-to-many" cfc="Cases" fkcolumn="case_id";
    property name="logEntries"    fieldtype="one-to-many" cfc="LogEntry" fkcolumn="logEntry_id";
}
