component extends="coldbox.system.EventHandler" {

    property name="communicationService" inject="CommunicationService";
    property name="caseService"          inject="CaseService";

    /**
     * Read-only communications hub with optional filters (GET).
     */
    function index( event, rc, prc ){
        if ( event.getHTTPMethod() != "GET" ) {
            relocate( "communications.index" );
            return;
        }
        var filterCaseId = structKeyExists( rc, "caseId" ) && isNumeric( rc.caseId ) && val( rc.caseId ) > 0 ? val( rc.caseId ) : 0;
        var filterType   = structKeyExists( rc, "type" ) ? trim( rc.type ) : "";
        var filterAuthor = structKeyExists( rc, "authorUserId" ) && isNumeric( rc.authorUserId ) && val( rc.authorUserId ) > 0 ? val( rc.authorUserId ) : 0;
        prc.communications = communicationService.listForHub(
            caseId       = filterCaseId,
            type         = filterType,
            authorUserId = filterAuthor
        );
        prc.cases              = caseService.listActive();
        prc.users              = entityLoad( "Users" );
        prc.communicationTypes = new models.constants.Communication_Type().getValues();
        prc.filterCaseId       = filterCaseId;
        prc.filterType         = filterType;
        prc.filterAuthorUserId = filterAuthor;
        event.setView( "communications/index" );
    }

}
