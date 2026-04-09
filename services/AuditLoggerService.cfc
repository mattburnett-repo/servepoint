component singleton accessors="true" {

    property name="coldbox" inject="coldbox";

    /**
     * Persist a structured audit event and emit a category-scoped LogBox line.
     * @return struct { success:boolean, auditEvent?:AuditEvent, error?:string }
     */
    public struct function record(
        required string category,
        required string eventType,
        string outcome = "success",
        numeric actorUserId = 0,
        numeric caseId = 0,
        numeric documentId = 0,
        string reasonCode = "",
        string message = "",
        string requestId = "",
        struct metadata = {}
    ) {
        var normalizedCategory = lCase( trim( arguments.category ) );
        var normalizedType = trim( arguments.eventType );
        var normalizedOutcome = lCase( trim( arguments.outcome ) );
        var normalizedReasonCode = left( trim( arguments.reasonCode ), 128 );
        var normalizedRequestId = left( trim( arguments.requestId ), 64 );
        var normalizedMessage = sanitizeMessage( arguments.message );

        if ( !arrayFindNoCase( new models.constants.Audit_Category().getValues(), normalizedCategory ) ) {
            return { success : false, error : "Invalid audit category." };
        }
        if ( !arrayFindNoCase( new models.constants.Audit_Event_Type().getValues(), normalizedType ) ) {
            return { success : false, error : "Invalid audit event type." };
        }
        if ( !arrayFindNoCase( new models.constants.Audit_Outcome().getValues(), normalizedOutcome ) ) {
            return { success : false, error : "Invalid audit outcome." };
        }
        if ( !len( normalizedMessage ) ) {
            return { success : false, error : "Audit message is required." };
        }

        var actorUser = javacast( "null", "" );
        if ( arguments.actorUserId > 0 ) {
            actorUser = entityLoad( "Users", arguments.actorUserId, true );
            if ( isNull( actorUser ) ) {
                return { success : false, error : "Audit actor user not found." };
            }
        }

        var caseEntity = javacast( "null", "" );
        if ( arguments.caseId > 0 ) {
            caseEntity = entityLoad( "Cases", arguments.caseId, true );
            if ( isNull( caseEntity ) ) {
                return { success : false, error : "Audit case not found." };
            }
        }

        var documentEntity = javacast( "null", "" );
        if ( arguments.documentId > 0 ) {
            documentEntity = entityLoad( "Document", arguments.documentId, true );
            if ( isNull( documentEntity ) ) {
                return { success : false, error : "Audit document not found." };
            }
        }

        var redactedMetadata = redactMetadata( arguments.metadata );
        var metadataJson = serializeJSON( redactedMetadata );
        if ( len( metadataJson ) > 4000 ) {
            metadataJson = left( metadataJson, 3997 ) & "...";
        }

        var auditEvent = entityNew( "AuditEvent" );
        auditEvent.setDateOccurred( now() );
        auditEvent.setCategory( normalizedCategory );
        auditEvent.setEventType( normalizedType );
        auditEvent.setOutcome( normalizedOutcome );
        auditEvent.setReasonCode( normalizedReasonCode );
        auditEvent.setMessage( normalizedMessage );
        auditEvent.setRequestId( normalizedRequestId );
        auditEvent.setMetadataJson( metadataJson );
        if ( !isNull( actorUser ) ) {
            auditEvent.setActorUser( actorUser );
        }
        if ( !isNull( caseEntity ) ) {
            auditEvent.setCaseRef( caseEntity );
        }
        if ( !isNull( documentEntity ) ) {
            auditEvent.setDocument( documentEntity );
        }

        try {
            entitySave( auditEvent );
        } catch ( any e ) {
            return { success : false, error : "Unable to save audit event: " & ( e.message ?: "unknown error" ) };
        }
        if ( isNull( auditEvent.getAuditEventId() ) || auditEvent.getAuditEventId() <= 0 ) {
            return { success : false, error : "Audit event was not persisted." };
        }
        ormEvictEntity( "AuditEvent", auditEvent.getAuditEventId() );

        emitOperationalLog(
            category = normalizedCategory,
            eventType = normalizedType,
            outcome = normalizedOutcome,
            actorUserId = arguments.actorUserId,
            caseId = arguments.caseId,
            documentId = arguments.documentId,
            reasonCode = normalizedReasonCode,
            requestId = normalizedRequestId,
            message = normalizedMessage
        );

        return {
            success : true,
            auditEvent : entityLoad( "AuditEvent", auditEvent.getAuditEventId(), true )
        };
    }

    private string function sanitizeMessage( required string rawMessage ) {
        var msg = trim( arguments.rawMessage );
        if ( !len( msg ) ) {
            return "";
        }
        msg = reReplaceNoCase( msg, "(password|token|secret)[^\\s]*\\s*[:=]\\s*[^\\s,;]+", "\1=[REDACTED]", "all" );
        if ( len( msg ) > 500 ) {
            msg = left( msg, 497 ) & "...";
        }
        return msg;
    }

    private struct function redactMetadata( required struct source ) {
        var out = {};
        for ( var key in arguments.source ) {
            var lowerKey = lCase( key );
            var value = arguments.source[ key ];
            if (
                findNoCase( "password", lowerKey ) ||
                findNoCase( "token", lowerKey ) ||
                findNoCase( "secret", lowerKey ) ||
                findNoCase( "authorization", lowerKey ) ||
                findNoCase( "cookie", lowerKey )
            ) {
                out[ key ] = "[REDACTED]";
            } else if ( isSimpleValue( value ) ) {
                out[ key ] = len( toString( value ) ) > 300 ? ( left( toString( value ), 297 ) & "..." ) : value;
            } else {
                out[ key ] = "[COMPLEX]";
            }
        }
        return out;
    }

    private void function emitOperationalLog(
        required string category,
        required string eventType,
        required string outcome,
        required numeric actorUserId,
        required numeric caseId,
        required numeric documentId,
        required string reasonCode,
        required string requestId,
        required string message
    ) {
        try {
            var logger = coldbox.getLogBox().getLogger( "audit." & arguments.category );
            logger.info(
                "audit category=#arguments.category# type=#arguments.eventType# outcome=#arguments.outcome# actorUserId=#arguments.actorUserId# caseId=#arguments.caseId# documentId=#arguments.documentId# requestId=#arguments.requestId# reasonCode=#arguments.reasonCode# message=#arguments.message#"
            );
        } catch ( any e ) {
            // Operational logging must never break request flow.
        }
    }
}
