component {

    property name="FILE_TYPES" type="struct";

    /**
     * Define all valid document file types. Set in pseudo-constructor for Adobe CF compatibility (no static final).
     */
    this.FILE_TYPES = {
        "PDF": "pdf",
        "DOCX": "docx",
        "PNG": "png",
        "JPEG": "jpeg",
        "JPG": "jpg"
    };

    /**
     * A helper method to get all the struct values.
     * @returns array An array of all the file type strings.
     */
    public array function getValues() {
        var values = [];
        for ( var key in this.FILE_TYPES ) {
            arrayAppend( values, this.FILE_TYPES[ key ] );
        }
        return values;
    }

}
