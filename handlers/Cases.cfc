component extends="coldbox.system.EventHandler" {

    property name="caseService" inject="CaseService";

    /**
     * List active (non-archived) cases.
     */
    function index( event, rc, prc ){
        prc.cases = caseService.listActive();
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
        var caseEntity = caseService.getActiveCase( val( rc.id ) );
        if ( isNull( caseEntity ) ) {
            session.casesNotice = "Case not found or no longer active.";
            relocate( "cases.index" );
            return;
        }
        prc.caseEntity = caseEntity;
        if ( structKeyExists( session, "casesNotice" ) && len( trim( session.casesNotice ) ) ) {
            prc.noticeMessage = session.casesNotice;
            structDelete( session, "casesNotice" );
        }
        prc.statusOptions = new models.constants.Case_Status().getValues();
        prc.users         = entityLoad( "Users" );
        event.setView( "cases/view" );
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
        var title = structKeyExists( rc, "title" ) ? trim( rc.title ) : "";
        if ( !len( title ) ) {
            prc.errorMessage = "Title is required.";
            var ce = caseService.getActiveCase( caseId );
            if ( isNull( ce ) ) {
                relocate( "cases.index" );
                return;
            }
            prc.caseEntity = ce;
            prc.statusOptions = new models.constants.Case_Status().getValues();
            prc.users         = entityLoad( "Users" );
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
            assignedToUserId = assignedId
        );
        if ( !result.success ) {
            prc.errorMessage = result.error;
            prc.caseEntity   = caseService.getActiveCase( caseId );
            prc.statusOptions = new models.constants.Case_Status().getValues();
            prc.users         = entityLoad( "Users" );
            event.setView( "cases/view" );
            return;
        }
        session.casesNotice = "Case updated successfully.";
        relocate( url = event.buildLink( to = "cases.view", queryString = "id=#caseId#" ) );
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
        var admin = entityLoad( "Users", { email : "admin@example.com" }, true );
        if ( isNull( admin ) ) {
            var allUsers = entityLoad( "Users" );
            if ( arrayLen( allUsers ) ) {
                admin = allUsers[ 1 ];
            } else {
                session.casesNotice = "Unable to archive case.";
                relocate( "cases.index" );
                return;
            }
        }
        var result = caseService.archiveCase(
            caseId   = caseId,
            userId   = admin.getUserId(),
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
        var creator = entityLoad( "Users", { email : "admin@example.com" }, true );
        if ( isNull( creator ) ) {
            var allUsers = entityLoad( "Users" );
            if ( arrayLen( allUsers ) ) {
                creator = allUsers[ 1 ];
            } else {
                prc.errorMessage     = "No users available to own the case.";
                prc.titleValue       = title;
                prc.descriptionValue = structKeyExists( rc, "description" ) ? trim( rc.description ) : "";
                prc.statusOptions    = new models.constants.Case_Status().getValues();
                prc.users            = allUsers;
                event.setView( "cases/new" );
                return;
            }
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
            creatorUserId    = creator.getUserId(),
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
