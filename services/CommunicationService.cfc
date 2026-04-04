component singleton accessors="true" {

    property name="caseService" inject="CaseService";

    /**
     * List communications for an active (non-archived) case, newest first.
     * @return array of Communication entities
     */
    public array function listForCase( required numeric caseId ) {
        if ( isNull( caseService.getActiveCase( arguments.caseId ) ) ) {
            return [];
        }
        return ormExecuteQuery(
            "FROM Communication c JOIN FETCH c.author JOIN FETCH c.caseRef WHERE c.caseRef.caseId = :caseId ORDER BY c.dateCreated DESC",
            { caseId : arguments.caseId },
            false
        );
    }

    /**
     * Ordered activity-style log entries for a case (newest first).
     * @return array of LogEntry entities
     */
    public array function listLogEntriesForCase( required numeric caseId ) {
        return ormExecuteQuery(
            "FROM LogEntry le JOIN FETCH le.user JOIN FETCH le.caseRef WHERE le.caseRef.caseId = :caseId ORDER BY le.dateCreated DESC",
            { caseId : arguments.caseId },
            false
        );
    }

    /**
     * Hub listing with optional filters; unfiltered returns all, newest first.
     */
    public array function listForHub( numeric caseId = 0, string type = "", numeric authorUserId = 0 ) {
        var hql  = "FROM Communication c JOIN FETCH c.author JOIN FETCH c.caseRef WHERE 1=1";
        var params = {};
        if ( arguments.caseId > 0 ) {
            hql &= " AND c.caseRef.caseId = :caseId";
            params.caseId = arguments.caseId;
        }
        if ( len( trim( arguments.type ) ) ) {
            hql &= " AND c.type = :commType";
            params.commType = trim( arguments.type );
        }
        if ( arguments.authorUserId > 0 ) {
            hql &= " AND c.author.userId = :authorUserId";
            params.authorUserId = arguments.authorUserId;
        }
        hql &= " ORDER BY c.dateCreated DESC";
        return ormExecuteQuery( hql, params, false );
    }

    /**
     * Create a staff communication on an active case (same save/evict/reload pattern as DocumentService.persistUploadedFile).
     * @return struct { success: boolean, communication?: Communication, error?: string }
     */
    public struct function createCommunication(
        required numeric caseId,
        required numeric userId,
        required string message,
        required string type
    ) {
        var caseEntity = caseService.getActiveCase( arguments.caseId );
        if ( isNull( caseEntity ) ) {
            return { success: false, error: "Case not found or is not active." };
        }
        var author = entityLoad( "Users", arguments.userId, true );
        if ( isNull( author ) ) {
            return { success: false, error: "Author user not found." };
        }
        var typeConstants = new models.constants.Communication_Type();
        if ( !arrayFind( typeConstants.getValues(), arguments.type ) ) {
            return { success: false, error: "Invalid communication type." };
        }
        var body = trim( arguments.message );
        if ( !len( body ) ) {
            return { success: false, error: "Message is required." };
        }
        if ( len( body ) > 10000 ) {
            return { success: false, error: "Message must be 10000 characters or less." };
        }
        var comm = entityNew( "Communication" );
        comm.setMessage( body );
        comm.setType( arguments.type );
        comm.setCaseRef( caseEntity );
        comm.setAuthor( author );
        var ts = now();
        comm.setDateCreated( ts );
        comm.setDateUpdated( ts );
        try {
            comm.save();
        } catch ( any e ) {
            return { success: false, error: "Unable to save communication: " & ( e.message ?: "unknown error" ) };
        }
        if ( isNull( comm.getCommunicationId() ) || comm.getCommunicationId() <= 0 ) {
            return { success: false, error: "Communication was not persisted." };
        }
        ormEvictEntity( "Communication", comm.getCommunicationId() );
        return { success: true, communication: entityLoad( "Communication", comm.getCommunicationId(), true ) };
    }

}
