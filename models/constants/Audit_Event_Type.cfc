component {

    property name="VALUES" type="struct";

    this.VALUES = {
        "LOGIN_SUCCESS"        : "Login Success",
        "LOGIN_FAILURE"        : "Login Failure",
        "LOGOUT"               : "Logout",
        "AUTHZ_DENIED"         : "Authorization Denied",
        "CASE_CREATE"          : "Case Create",
        "CASE_UPDATE"          : "Case Update",
        "CASE_ARCHIVE"         : "Case Archive",
        "CASE_RESTORE"         : "Case Restore",
        "COMMUNICATION_CREATE" : "Communication Create",
        "DOCUMENT_UPLOAD"      : "Document Upload",
        "DOCUMENT_DOWNLOAD"    : "Document Download",
        "REPORT_VIEW"          : "Report View",
        "REPORT_SUMMARY_VIEW"  : "Report Summary View",
        "ADMIN_ACTION"         : "Admin Action"
    };

    public array function getValues() {
        var values = [];
        for ( var key in this.VALUES ) {
            arrayAppend( values, this.VALUES[ key ] );
        }
        return values;
    }
}
