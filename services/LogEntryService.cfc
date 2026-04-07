component singleton accessors="true" {

    /**
     * Persist a case log entry.
     * @return struct { success: boolean, logEntry?: any, error?: string }
     */
    public struct function record(
        required numeric caseId,
        required numeric userId,
        required string type,
        required string entryText
    ) {
        var caseEntity = entityLoad( "Cases", arguments.caseId, true );
        if ( isNull( caseEntity ) ) {
            return { success: false, error: "Case not found." };
        }

        var userEntity = entityLoad( "Users", arguments.userId, true );
        if ( isNull( userEntity ) ) {
            return { success: false, error: "User not found." };
        }

        var normalizedType = trim( arguments.type );
        var normalizedText = trim( arguments.entryText );
        if ( !len( normalizedText ) ) {
            return { success: false, error: "Log entry text is required." };
        }

        var typeConstants = new models.constants.Log_Entry_Type();
        var validTypes    = typeConstants.getValues();
        if ( !arrayFind( validTypes, normalizedType ) ) {
            return { success: false, error: "Invalid log entry type." };
        }

        var logEntry = entityNew( "LogEntry" );
        logEntry.setCaseRef( caseEntity );
        logEntry.setUser( userEntity );
        logEntry.setType( normalizedType );
        logEntry.setEntryText( normalizedText );

        try {
            entitySave( logEntry );
        } catch ( any e ) {
            return { success: false, error: "Unable to save log entry: " & ( e.message ?: "unknown error" ) };
        }

        if ( isNull( logEntry.getLogEntryId() ) || logEntry.getLogEntryId() <= 0 ) {
            return { success: false, error: "Log entry was not persisted." };
        }

        ormEvictEntity( "LogEntry", logEntry.getLogEntryId() );
        return { success: true, logEntry: entityLoad( "LogEntry", logEntry.getLogEntryId(), true ) };
    }

}
