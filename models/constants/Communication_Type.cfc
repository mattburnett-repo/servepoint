component {

    property name="TYPES" type="struct";

    /**
     * Valid communication types (extend as product needs more kinds).
     */
    this.TYPES = {
        "STAFF_NOTE" : "Staff Note"
    };

    /**
     * @returns array of display/type values stored on communications.type
     */
    public array function getValues() {
        var values = [];
        for ( var key in this.TYPES ) {
            arrayAppend( values, this.TYPES[ key ] );
        }
        return values;
    }

}
