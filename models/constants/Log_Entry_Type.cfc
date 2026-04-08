component {

    property name="TYPES" type="struct";

    /**
     * Define all valid log entry types. Set in pseudo-constructor for Adobe CF compatibility (no static final).
     */
    this.TYPES = {
        "LOGIN": "Login",
        "CASE_CREATE": "Case Create",
        "CASE_UPDATE": "Case Update",
        "CASE_ARCHIVE": "Case Archive",
        "CASE_RESTORE": "Case Restore",
        "COMMUNICATION_CREATE": "Communication Create",
        "DOCUMENT_UPLOAD": "Document Upload",
        "DOCUMENT_DOWNLOAD": "Document Download",
        "ERROR": "Error"
    };

    /**
     * A helper method to get all the struct values.
     * @returns array An array of all the log entry type strings.
     */
    public array function getValues() {
        var values = [];
        for ( var key in this.TYPES ) {
            arrayAppend( values, this.TYPES[ key ] );
        }
        return values;
    }

}
