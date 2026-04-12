component singleton accessors="true" {
    property name="auditLoggerService" inject="AuditLoggerService";

    private any function userRoleConstants() {
        return new models.constants.User_Role();
    }

    /**
     * Administrator and Case Manager: any active case. Citizen: creator or assignee only.
     */
    public boolean function userCanViewCase( required any caseEntity, required numeric actorUserId, required string actorRole ) {
        var ur = userRoleConstants();
        if ( arguments.actorRole == ur.ROLES.ADMINISTRATOR || arguments.actorRole == ur.ROLES.CASE_MANAGER ) {
            return true;
        }
        if ( arguments.actorRole != ur.ROLES.CITIZEN ) {
            return false;
        }
        if ( isNull( arguments.caseEntity ) ) {
            return false;
        }
        if ( arguments.caseEntity.getCreator().getUserId() == arguments.actorUserId ) {
            return true;
        }
        if (
            !isNull( arguments.caseEntity.getAssignedTo() ) &&
            arguments.caseEntity.getAssignedTo().getUserId() == arguments.actorUserId
        ) {
            return true;
        }
        return false;
    }

    /**
     * Administrator: any. Case Manager: must be assigned to the case. Citizen: never.
     */
    public boolean function userMayMutateCase( required any caseEntity, required numeric actorUserId, required string actorRole ) {
        var ur = userRoleConstants();
        if ( arguments.actorRole == ur.ROLES.ADMINISTRATOR ) {
            return true;
        }
        if ( arguments.actorRole == ur.ROLES.CASE_MANAGER ) {
            return (
                !isNull( arguments.caseEntity.getAssignedTo() ) &&
                arguments.caseEntity.getAssignedTo().getUserId() == arguments.actorUserId
            );
        }
        return false;
    }

    /**
     * Role-scoped list: staff see all active cases; citizens see only cases they created or are assigned to.
     */
    public array function listCasesForActor( required numeric actorUserId, required string actorRole ) {
        var ur = userRoleConstants();
        if ( arguments.actorRole == ur.ROLES.ADMINISTRATOR || arguments.actorRole == ur.ROLES.CASE_MANAGER ) {
            return listActive();
        }
        if ( arguments.actorRole != ur.ROLES.CITIZEN ) {
            return [];
        }
        return ormExecuteQuery(
            "FROM Cases c WHERE c.archivedAt IS NULL AND ( c.creator.userId = :uid OR ( c.assignedTo IS NOT NULL AND c.assignedTo.userId = :uid ) ) ORDER BY c.dateCreated DESC",
            { uid : arguments.actorUserId },
            false
        );
    }

    /**
     * Same as getActiveCase when the actor may view the case; otherwise null (not found for this user).
     */
    public any function getActiveCaseForActor( required numeric caseId, required numeric actorUserId, required string actorRole ) {
        var caseEntity = getActiveCase( arguments.caseId );
        if ( isNull( caseEntity ) ) {
            return;
        }
        if ( !userCanViewCase( caseEntity, arguments.actorUserId, arguments.actorRole ) ) {
            return;
        }
        return caseEntity;
    }

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
        var urCreate = userRoleConstants();
        if ( trim( creator.getRole() ) == urCreate.ROLES.CITIZEN ) {
            return { success: false, error: "Citizens cannot create cases." };
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
        auditLoggerService.record(
            category    = "case",
            eventType   = "Case Create",
            outcome     = "success",
            actorUserId = creator.getUserId(),
            caseId      = c.getCaseId(),
            message     = "Case created (ID " & c.getCaseId() & "): " & c.getTitle() & "."
        );
        ormEvictEntity( "Cases", c.getCaseId() );
        return { success: true, case: entityLoad( "Cases", c.getCaseId(), true ) };
    }

    /**
     * Load an active (non-archived) case by id, or null.
     */
    public any function getActiveCase( required numeric caseId ) {
        // Flush first: ormClearSession() drops the session without flushing, which can discard
        // uncommitted ORM updates and make the next query read stale DB rows (e.g. after updateCase).
        ormFlush();
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
        numeric assignedToUserId = 0,
        numeric actorUserId = 0,
        string actorRole = ""
    ) {
        var caseEntity = entityLoad( "Cases", arguments.caseId, true );
        if ( isNull( caseEntity ) || caseEntity.isArchived() ) {
            return { success: false, error: "Case not found." };
        }
        if ( arguments.actorUserId > 0 && len( trim( arguments.actorRole ) ) ) {
            if ( !userMayMutateCase( caseEntity, arguments.actorUserId, trim( arguments.actorRole ) ) ) {
                return { success: false, error: "You are not allowed to update this case." };
            }
        }
        var previousTitle = caseEntity.getTitle();
        var previousStatus = caseEntity.getStatus();
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
        var auditActorId = caseEntity.getCreator().getUserId();
        if ( arguments.actorUserId > 0 ) {
            auditActorId = arguments.actorUserId;
        }
        auditLoggerService.record(
            category    = "case",
            eventType   = "Case Update",
            outcome     = "success",
            actorUserId = auditActorId,
            caseId      = arguments.caseId,
            message     = "Case updated (ID " & arguments.caseId & "): title '" & previousTitle & "' to '" & caseEntity.getTitle() &
                "', status '" & previousStatus & "' to '" & caseEntity.getStatus() & "'."
        );
        ormFlush();
        ormEvictEntity( "Cases", arguments.caseId );
        return { success: true, case: entityLoad( "Cases", arguments.caseId, true ) };
    }

    /**
     * Soft-archive a case. Sets archivedAt, archivedBy, archiveReason; optionally creates an AuditEvent.
     * Uses direct SQL so the DB is the source of truth (avoids ORM session/cache issues).
     * @return struct { success: boolean, case?: Cases, error?: string }
     */
    public struct function archiveCase(
        required numeric caseId,
        required numeric userId,
        string reason = "",
        boolean createAuditEvent = true
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
        if ( !userMayMutateCase( caseEntity, arguments.userId, trim( userEntity.getRole() ) ) ) {
            return { success: false, error: "You are not allowed to archive this case." };
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
            if ( arguments.createAuditEvent ) {
                auditLoggerService.record(
                    category    = "case",
                    eventType   = "Case Archive",
                    outcome     = "success",
                    actorUserId = arguments.userId,
                    caseId      = arguments.caseId,
                    message     = "Case archived (ID " & arguments.caseId & ", title '" & caseEntity.getTitle() & "')." &
                        ( len( trim( arguments.reason ) ) ? " Reason: " & arguments.reason : "" )
                );
            }
        }
        ormClearSession();
        return { success: true, case: entityLoad( "Cases", arguments.caseId, true ) };
    }

    /**
     * Restore a soft-archived case. Clears archivedAt, archivedBy, archiveReason; optionally creates an AuditEvent.
     * Uses direct SQL; idempotent (no-op if already active).
     * @return struct { success: boolean, case?: Cases, error?: string }
     */
    public struct function restoreCase(
        required numeric caseId,
        required numeric userId,
        boolean createAuditEvent = true
    ) {
        var caseEntity = entityLoad( "Cases", arguments.caseId, true );
        if ( isNull( caseEntity ) ) {
            return { success: false, error: "Case not found." };
        }
        var userEntity = entityLoad( "Users", arguments.userId, true );
        if ( isNull( userEntity ) ) {
            return { success: false, error: "User not found." };
        }
        if ( !userMayMutateCase( caseEntity, arguments.userId, trim( userEntity.getRole() ) ) ) {
            return { success: false, error: "You are not allowed to restore this case." };
        }
        var datasource = "servepoint";
        transaction {
            queryExecute(
                "UPDATE cases SET archived_at = NULL, archived_by = NULL, archive_reason = NULL WHERE case_id = CAST(:caseId AS INTEGER)",
                { caseId : arguments.caseId },
                { datasource : datasource }
            );
            if ( arguments.createAuditEvent ) {
                auditLoggerService.record(
                    category    = "case",
                    eventType   = "Case Restore",
                    outcome     = "success",
                    actorUserId = arguments.userId,
                    caseId      = arguments.caseId,
                    message     = "Case restored from archive (ID " & arguments.caseId & ", title '" & caseEntity.getTitle() & "')."
                );
            }
        }
        ormClearSession();
        return { success: true, case: entityLoad( "Cases", arguments.caseId, true ) };
    }
}
