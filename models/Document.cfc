component persistent="true" extends="cborm.models.ActiveEntity" table="document" {

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
}
