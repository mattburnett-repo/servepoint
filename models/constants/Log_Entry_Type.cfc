component {

    /**
     * Define all valid log entry types as a static struct.
     * This provides easy access by key and is highly maintainable.
     */
    static final property name="TYPES" type="struct" default={
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