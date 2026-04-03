component singleton accessors="true" {

    /**
     * Restore all archived cases in one go (bulk UPDATE). Use for test isolation so specs see all cases as active.
     * Clears the ORM session so subsequent queries see the updated DB state.
     */
    public void function restoreAllArchived() {
        var datasource = "servepoint";
        queryExecute(
            "UPDATE cases SET archived_at = NULL, archived_by = NULL, archive_reason = NULL",
            {},
            { datasource : datasource }
        );
        ormClearSession();
    }

    /**
     * List only active (non-archived) cases. Default query convention for the app.
     * @return array of Cases entities
     */
    public array function listActive() {
        return ormExecuteQuery( "FROM Cases c WHERE c.archivedAt IS NULL ORDER BY c.dateCreated DESC", false );
    }

    /**
     * List cases, optionally including archived.
     * @includeArchived if true, return all cases; if false, same as listActive()
     * @return array of Cases entities
     */
    public array function listAll( boolean includeArchived = false ) {
        if ( !includeArchived ) {
            return listActive();
        }
        return ormExecuteQuery( "FROM Cases c ORDER BY c.dateCreated DESC", false );
    }

    /**
     * Create a new active case (intake).
     * @return struct { success: boolean, case?: Cases, error?: string }
     */
    public struct function createCase(
        required string title,
        string description = "",
        required string status,
        required numeric creatorUserId,
        numeric assignedToUserId = 0
    ) {
        var statusConstants = new models.constants.Case_Status();
        var validStatuses   = statusConstants.getValues();
        if ( !arrayFind( validStatuses, arguments.status ) ) {
            return { success: false, error: "Invalid case status." };
        }
        var creator = entityLoad( "Users", arguments.creatorUserId, true );
        if ( isNull( creator ) ) {
            return { success: false, error: "Creator user not found." };
        }
        var assignee = creator;
        if ( arguments.assignedToUserId > 0 ) {
            var assignUser = entityLoad( "Users", arguments.assignedToUserId, true );
            if ( !isNull( assignUser ) ) {
                assignee = assignUser;
            }
        }
        var c = entityNew( "Cases" );
        c.setTitle( trim( arguments.title ) );
        c.setDescription( trim( arguments.description ) );
        c.setStatus( arguments.status );
        c.setCreator( creator );
        c.setAssignedTo( assignee );
        try {
            c.save();
        } catch ( any e ) {
            return { success: false, error: "Unable to save case: " & ( e.message ?: "unknown error" ) };
        }
        if ( isNull( c.getCaseId() ) || c.getCaseId() <= 0 ) {
            return { success: false, error: "Case not persisted." };
        }
        ormEvictEntity( "Cases", c.getCaseId() );
        return { success: true, case: entityLoad( "Cases", c.getCaseId(), true ) };
    }

    /**
     * Load an active (non-archived) case by id, or null.
     */
    public any function getActiveCase( required numeric caseId ) {
        // Force fresh state and query active-only directly to avoid stale session/entity state.
        ormClearSession();
        var matches = ormExecuteQuery(
            "FROM Cases c WHERE c.caseId = :caseId AND c.archivedAt IS NULL",
            { caseId : arguments.caseId },
            false
        );
        if ( arrayLen( matches ) == 0 ) {
            return;
        }
        return matches[ 1 ];
    }

    /**
     * Update an active case (title, description, status, assignment).
     * @return struct { success: boolean, case?: Cases, error?: string }
     */
    public struct function updateCase(
        required numeric caseId,
        required string title,
        string description = "",
        required string status,
        numeric assignedToUserId = 0
    ) {
        var caseEntity = entityLoad( "Cases", arguments.caseId, true );
        if ( isNull( caseEntity ) || caseEntity.isArchived() ) {
            return { success: false, error: "Case not found." };
        }
        var statusConstants = new models.constants.Case_Status();
        if ( !arrayFind( statusConstants.getValues(), arguments.status ) ) {
            return { success: false, error: "Invalid case status." };
        }
        if ( arguments.assignedToUserId > 0 ) {
            var assignUser = entityLoad( "Users", arguments.assignedToUserId, true );
            if ( !isNull( assignUser ) ) {
                caseEntity.setAssignedTo( assignUser );
            }
        } else {
            caseEntity.setAssignedTo( caseEntity.getCreator() );
        }
        caseEntity.setTitle( trim( arguments.title ) );
        caseEntity.setDescription( trim( arguments.description ) );
        caseEntity.setStatus( arguments.status );
        try {
            caseEntity.save();
        } catch ( any e ) {
            return { success: false, error: "Unable to update case: " & ( e.message ?: "unknown error" ) };
        }
        ormEvictEntity( "Cases", arguments.caseId );
        return { success: true, case: entityLoad( "Cases", arguments.caseId, true ) };
    }

    /**
     * Soft-archive a case. Sets archivedAt, archivedBy, archiveReason; optionally creates a LogEntry.
     * Uses direct SQL so the DB is the source of truth (avoids ORM session/cache issues).
     * @return struct { success: boolean, case?: Cases, error?: string }
     */
    public struct function archiveCase(
        required numeric caseId,
        required numeric userId,
        string reason = "",
        boolean createLogEntry = true
    ) {
        var caseEntity = entityLoad( "Cases", arguments.caseId, true );
        if ( isNull( caseEntity ) ) {
            return { success: false, error: "Case not found." };
        }
        if ( caseEntity.isArchived() ) {
            return { success: false, error: "Case is already archived." };
        }
        var userEntity = entityLoad( "Users", arguments.userId, true );
        if ( isNull( userEntity ) ) {
            return { success: false, error: "User not found." };
        }
        var datasource = "servepoint";
        transaction {
            queryExecute(
                "UPDATE cases SET archived_at = CURRENT_TIMESTAMP, archived_by = CAST(:archivedBy AS INTEGER), archive_reason = :archiveReason WHERE case_id = CAST(:caseId AS INTEGER)",
                {
                    archivedBy   : arguments.userId,
                    archiveReason: left( arguments.reason, 500 ),
                    caseId       : arguments.caseId
                },
                { datasource : datasource }
            );
            if ( arguments.createLogEntry ) {
                ormEvictEntity( "Cases", arguments.caseId );
                var freshCase = entityLoad( "Cases", arguments.caseId, true );
                var logEntry = entityNew( "LogEntry" );
                logEntry.setEntryText( "Case archived." & ( len( trim( arguments.reason ) ) ? " Reason: " & arguments.reason : "" ) );
                logEntry.setType( "Case Update" );
                logEntry.setCaseRef( freshCase );
                logEntry.setUser( userEntity );
                entitySave( logEntry );
            }
        }
        ormClearSession();
        return { success: true, case: entityLoad( "Cases", arguments.caseId, true ) };
    }

    /**
     * Restore a soft-archived case. Clears archivedAt, archivedBy, archiveReason; optionally creates a LogEntry.
     * Uses direct SQL; idempotent (no-op if already active).
     * @return struct { success: boolean, case?: Cases, error?: string }
     */
    public struct function restoreCase(
        required numeric caseId,
        required numeric userId,
        boolean createLogEntry = true
    ) {
        var caseEntity = entityLoad( "Cases", arguments.caseId, true );
        if ( isNull( caseEntity ) ) {
            return { success: false, error: "Case not found." };
        }
        var userEntity = entityLoad( "Users", arguments.userId, true );
        if ( isNull( userEntity ) ) {
            return { success: false, error: "User not found." };
        }
        var datasource = "servepoint";
        transaction {
            queryExecute(
                "UPDATE cases SET archived_at = NULL, archived_by = NULL, archive_reason = NULL WHERE case_id = CAST(:caseId AS INTEGER)",
                { caseId : arguments.caseId },
                { datasource : datasource }
            );
            if ( arguments.createLogEntry ) {
                ormEvictEntity( "Cases", arguments.caseId );
                var freshCase = entityLoad( "Cases", arguments.caseId, true );
                var logEntry = entityNew( "LogEntry" );
                logEntry.setEntryText( "Case restored from archive." );
                logEntry.setType( "Case Update" );
                logEntry.setCaseRef( freshCase );
                logEntry.setUser( userEntity );
                entitySave( logEntry );
            }
        }
        ormClearSession();
        return { success: true, case: entityLoad( "Cases", arguments.caseId, true ) };
    }
}
