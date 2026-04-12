component extends="coldbox.system.EventHandler" {

    property name="caseService"          inject="CaseService";
    property name="communicationService" inject="CommunicationService";
    property name="securityService"    inject="SecurityService";

    /**
     * List active (non-archived) cases (scoped by role).
     */
    function index( event, rc, prc ){
        var u    = securityService.getCurrentUser();
        var role = securityService.getCurrentUserRole();
        prc.cases = caseService.listCasesForActor( u.getUserId(), role );
        prc.canCreateAndArchive = ( role != "Citizen" );
        if ( structKeyExists( session, "casesNotice" ) && len( trim( session.casesNotice ) ) ) {
            prc.noticeMessage = session.casesNotice;
            structDelete( session, "casesNotice" );
        }
        event.setView( "cases/index" );
    }

    /**
     * Case detail and edit (same page).
     */
    function view( event, rc, prc ){
        if ( !structKeyExists( rc, "id" ) || !isNumeric( rc.id ) || val( rc.id ) <= 0 ) {
            relocate( "cases.index" );
            return;
        }
        var u    = securityService.getCurrentUser();
        var role = securityService.getCurrentUserRole();
        var caseEntity = caseService.getActiveCaseForActor( val( rc.id ), u.getUserId(), role );
        if ( isNull( caseEntity ) ) {
            session.casesNotice = "Case not found or you do not have access.";
            relocate( "cases.index" );
            return;
        }
        prc.caseEntity = caseEntity;
        prc.canMutateThisCase = caseService.userMayMutateCase( caseEntity, u.getUserId(), role );
        if ( structKeyExists( session, "casesNotice" ) && len( trim( session.casesNotice ) ) ) {
            prc.noticeMessage = session.casesNotice;
            structDelete( session, "casesNotice" );
        }
        loadCaseDetailContext( prc, caseEntity.getCaseId() );
        event.setView( "cases/view" );
    }

    /**
     * POST: add a staff communication to an active case.
     */
    function addCommunication( event, rc, prc ){
        if ( event.getHTTPMethod() != "POST" ) {
            relocate( "cases.index" );
            return;
        }
        var caseId = structKeyExists( rc, "caseId" ) && isNumeric( rc.caseId ) ? val( rc.caseId ) : 0;
        if ( caseId <= 0 ) {
            session.casesNotice = "Invalid case.";
            relocate( "cases.index" );
            return;
        }
        var u    = securityService.getCurrentUser();
        var role = securityService.getCurrentUserRole();
        var typeConstants = new models.constants.Communication_Type().getValues();
        var commType      = arrayLen( typeConstants ) ? typeConstants[ 1 ] : "";
        var message       = structKeyExists( rc, "message" ) ? trim( rc.message ) : "";
        var result        = communicationService.createCommunication(
            caseId  = caseId,
            userId  = u.getUserId(),
            message = message,
            type    = commType
        );
        if ( !result.success ) {
            prc.errorMessage = result.error;
            var ce = caseService.getActiveCaseForActor( caseId, u.getUserId(), role );
            if ( isNull( ce ) ) {
                session.casesNotice = "Case not found or you do not have access.";
                relocate( "cases.index" );
                return;
            }
            prc.caseEntity = ce;
            prc.canMutateThisCase = caseService.userMayMutateCase( ce, u.getUserId(), role );
            loadCaseDetailContext( prc, caseId );
            event.setView( "cases/view" );
            return;
        }
        session.casesNotice = "Communication added.";
        relocate( event = "cases.view", queryString = "id=" & caseId );
    }

    /**
     * Populate prc for case detail (edit form + comms + activity).
     */
    private void function loadCaseDetailContext( required prc, required numeric caseId ) {
        prc.statusOptions        = new models.constants.Case_Status().getValues();
        prc.users                = entityLoad( "Users" );
        prc.communications       = communicationService.listForCase( arguments.caseId );
        prc.activityLogEntries   = communicationService.listLogEntriesForCase( arguments.caseId );
        prc.defaultCommunicationType = "";
        var ct = new models.constants.Communication_Type().getValues();
        if ( arrayLen( ct ) ) {
            prc.defaultCommunicationType = ct[ 1 ];
        }
    }

    /**
     * POST: update case from detail form.
     */
    function update( event, rc, prc ){
        if ( event.getHTTPMethod() != "POST" ) {
            relocate( "cases.index" );
            return;
        }
        var caseId = structKeyExists( rc, "caseId" ) && isNumeric( rc.caseId ) ? val( rc.caseId ) : 0;
        if ( caseId <= 0 ) {
            session.casesNotice = "Invalid case.";
            relocate( "cases.index" );
            return;
        }
        var u    = securityService.getCurrentUser();
        var role = securityService.getCurrentUserRole();
        var title = structKeyExists( rc, "title" ) ? trim( rc.title ) : "";
        if ( !len( title ) ) {
            prc.errorMessage = "Title is required.";
            var ce = caseService.getActiveCaseForActor( caseId, u.getUserId(), role );
            if ( isNull( ce ) ) {
                relocate( "cases.index" );
                return;
            }
            prc.caseEntity = ce;
            prc.canMutateThisCase = caseService.userMayMutateCase( ce, u.getUserId(), role );
            loadCaseDetailContext( prc, caseId );
            event.setView( "cases/view" );
            return;
        }
        var status = structKeyExists( rc, "status" ) && len( trim( rc.status ) ) ? trim( rc.status ) : "New";
        var assignedId = 0;
        if ( structKeyExists( rc, "assignedToUserId" ) && isNumeric( rc.assignedToUserId ) && val( rc.assignedToUserId ) > 0 ) {
            assignedId = val( rc.assignedToUserId );
        }
        var result = caseService.updateCase(
            caseId           = caseId,
            title            = title,
            description      = structKeyExists( rc, "description" ) ? trim( rc.description ) : "",
            status           = status,
            assignedToUserId = assignedId,
            actorUserId      = u.getUserId(),
            actorRole        = role
        );
        if ( !result.success ) {
            prc.errorMessage = result.error;
            prc.caseEntity   = caseService.getActiveCaseForActor( caseId, u.getUserId(), role );
            prc.canMutateThisCase = caseService.userMayMutateCase( prc.caseEntity, u.getUserId(), role );
            loadCaseDetailContext( prc, caseId );
            event.setView( "cases/view" );
            return;
        }
        session.casesNotice = "Case updated successfully.";
        relocate( event = "cases.view", queryString = "id=" & caseId );
    }

    /**
     * POST: archive (soft-delete) a case from the list.
     */
    function archive( event, rc, prc ){
        if ( event.getHTTPMethod() != "POST" ) {
            relocate( "cases.index" );
            return;
        }
        var caseId = structKeyExists( rc, "id" ) && isNumeric( rc.id ) ? val( rc.id ) : 0;
        if ( caseId <= 0 ) {
            session.casesNotice = "Invalid case.";
            relocate( "cases.index" );
            return;
        }
        var u = securityService.getCurrentUser();
        var result = caseService.archiveCase(
            caseId   = caseId,
            userId   = u.getUserId(),
            reason   = "Archived from case list."
        );
        session.casesNotice = result.success ? "Case archived." : ( result.error ?: "Could not archive case." );
        relocate( "cases.index" );
    }

    /**
     * New case intake form.
     */
    function new( event, rc, prc ){
        prc.statusOptions = new models.constants.Case_Status().getValues();
        prc.users         = entityLoad( "Users" );
        event.setView( "cases/new" );
    }

    /**
     * POST: create case from intake form.
     */
    function create( event, rc, prc ){
        if ( event.getHTTPMethod() != "POST" ) {
            relocate( "cases.new" );
            return;
        }
        var u    = securityService.getCurrentUser();
        var title = structKeyExists( rc, "title" ) ? trim( rc.title ) : "";
        if ( !len( title ) ) {
            prc.errorMessage    = "Title is required.";
            prc.titleValue      = structKeyExists( rc, "title" ) ? trim( rc.title ) : "";
            prc.descriptionValue = structKeyExists( rc, "description" ) ? trim( rc.description ) : "";
            prc.statusOptions   = new models.constants.Case_Status().getValues();
            prc.users           = entityLoad( "Users" );
            event.setView( "cases/new" );
            return;
        }
        var status = structKeyExists( rc, "status" ) && len( trim( rc.status ) ) ? trim( rc.status ) : "New";
        var assignedId = 0;
        if ( structKeyExists( rc, "assignedToUserId" ) && isNumeric( rc.assignedToUserId ) && val( rc.assignedToUserId ) > 0 ) {
            assignedId = val( rc.assignedToUserId );
        }
        var result = caseService.createCase(
            title            = title,
            description      = structKeyExists( rc, "description" ) ? trim( rc.description ) : "",
            status           = status,
            creatorUserId    = u.getUserId(),
            assignedToUserId = assignedId
        );
        if ( !result.success ) {
            prc.errorMessage     = result.error;
            prc.titleValue       = title;
            prc.descriptionValue = structKeyExists( rc, "description" ) ? trim( rc.description ) : "";
            prc.statusOptions    = new models.constants.Case_Status().getValues();
            prc.users            = entityLoad( "Users" );
            event.setView( "cases/new" );
            return;
        }
        session.casesNotice = "Case created successfully.";
        relocate( "cases.index" );
    }

}
