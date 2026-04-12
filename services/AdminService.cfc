/**
 * Administrator-only operations (Issue #47 Phase B). Invoked from Admin handler;
 * routes are gated by SecurityInterceptor (admin.* → Administrator only).
 */
component singleton accessors="true" {

    property name="auditLoggerService" inject="AuditLoggerService";

    private any function userRoleConstants() {
        return new models.constants.User_Role();
    }

    /**
     * All users ordered by email (admin user management list).
     */
    public array function listUsersOrdered() {
        return ormExecuteQuery( "FROM Users u ORDER BY u.email ASC", false );
    }

    /**
     * Update a user's role. Validates against User_Role; prevents demoting the last Administrator.
     * @return struct { success: boolean, error?: string }
     */
    public struct function updateUserRole(
        required numeric actorUserId,
        required numeric targetUserId,
        required string newRole
    ) {
        var ur = userRoleConstants();
        var trimmedRole = trim( arguments.newRole );
        if ( !arrayFind( ur.getValues(), trimmedRole ) ) {
            return { success: false, error: "Invalid role." };
        }
        var target = entityLoad( "Users", arguments.targetUserId, true );
        if ( isNull( target ) ) {
            return { success: false, error: "User not found." };
        }
        var oldRole = trim( toString( target.getRole() ) );
        if ( oldRole == trimmedRole ) {
            return { success: true };
        }
        if ( oldRole == ur.ROLES.ADMINISTRATOR && trimmedRole != ur.ROLES.ADMINISTRATOR ) {
            var admins = ormExecuteQuery(
                "FROM Users u WHERE u.role = :r",
                { r : ur.ROLES.ADMINISTRATOR },
                false
            );
            if ( arrayLen( admins ) == 1 && admins[ 1 ].getUserId() == arguments.targetUserId ) {
                return { success: false, error: "Cannot remove the last Administrator." };
            }
        }
        target.setRole( trimmedRole );
        try {
            target.save();
        } catch ( any e ) {
            return { success: false, error: "Unable to save role: " & ( e.message ?: "unknown error" ) };
        }
        ormEvictEntity( "Users", arguments.targetUserId );

        auditLoggerService.record(
            category    = "admin",
            eventType   = "Admin Action",
            outcome     = "success",
            actorUserId = arguments.actorUserId,
            caseId      = 0,
            documentId  = 0,
            message     = "User role changed for userId " & arguments.targetUserId & " (" & target.getEmail() & "): '" & oldRole & "' to '" & trimmedRole & "'.",
            metadata    = {
                "targetUserId" : arguments.targetUserId,
                "oldRole"      : oldRole,
                "newRole"      : trimmedRole
            }
        );
        return { success: true };
    }

}
