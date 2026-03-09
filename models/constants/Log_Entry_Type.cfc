component {

    property name="TYPES" type="struct";

    /**
     * Define all valid log entry types. Set in pseudo-constructor for Adobe CF compatibility (no static final).
     */
    this.TYPES = {
        "LOGIN": "Login",
        "CASE_UPDATE": "Case Update",
        "DOCUMENT_UPLOAD": "Document Upload",
        "ERROR": "Error"
    };

    /**
     * A helper method to get all the struct values.
     * @returns array An array of all the log entry type strings.
     */
    public array function getValues() {
        return structValues( this.TYPES );
    }

}
