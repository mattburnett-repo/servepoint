component {

    property name="VALUES" type="struct";

    this.VALUES = {
        "SECURITY" : "security",
        "CASE"     : "case",
        "DOCUMENT" : "document",
        "REPORT"   : "report",
        "ADMIN"    : "admin"
    };

    public array function getValues() {
        var values = [];
        for ( var key in this.VALUES ) {
            arrayAppend( values, this.VALUES[ key ] );
        }
        return values;
    }
}
