component {

    /**
     * Define all valid document file types as a struct.
     * This provides easy access by key and is highly maintainable.
     */
    property name="FILE_TYPES" type="struct" default={
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
        return structValues( this.FILE_TYPES );
    }

}
