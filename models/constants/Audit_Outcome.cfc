component {

    property name="VALUES" type="struct";

    this.VALUES = {
        "SUCCESS" : "success",
        "FAILURE" : "failure",
        "DENIED"  : "denied"
    };

    public array function getValues() {
        var values = [];
        for ( var key in this.VALUES ) {
            arrayAppend( values, this.VALUES[ key ] );
        }
        return values;
    }
}
