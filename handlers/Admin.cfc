component extends="coldbox.system.EventHandler" {

	property name="adminService"      inject="AdminService";
	property name="caseService"       inject="CaseService";
	property name="securityService" inject="SecurityService";

	/**
	 * Admin home — Administrator-only (see SecurityInterceptor).
	 */
	function index( event, rc, prc ) {
		prc.pageTitle = "Administration";
		flushAdminNotice( prc );
		event.setView( "admin/index" );
	}

	/**
	 * List all users; change role (POST saveUserRole).
	 */
	function users( event, rc, prc ) {
		prc.pageTitle = "Users";
		flushAdminNotice( prc );
		prc.users = adminService.listUsersOrdered();
		prc.roleOptions = userRoleConstants().getValues();
		event.setView( "admin/users" );
	}

	/**
	 * POST: update user role.
	 */
	function saveUserRole( event, rc, prc ) {
		if ( event.getHTTPMethod() != "POST" ) {
			relocate( "admin.users" );
			return;
		}
		var targetId = structKeyExists( rc, "userId" ) && isNumeric( rc.userId ) ? val( rc.userId ) : 0;
		var newRole  = structKeyExists( rc, "role" ) ? trim( toString( rc.role ) ) : "";
		if ( targetId <= 0 || !len( newRole ) ) {
			session.adminNotice = "Invalid user or role.";
			session.adminNoticeIsError = true;
			relocate( "admin.users" );
			return;
		}
		var actor = securityService.getCurrentUser();
		if ( isNull( actor ) ) {
			relocate( "main.login" );
			return;
		}
		var result = adminService.updateUserRole(
			actorUserId  = actor.getUserId(),
			targetUserId = targetId,
			newRole      = newRole
		);
		session.adminNotice = result.success ? "Role updated." : ( result.error ?: "Could not update role." );
		session.adminNoticeIsError = !result.success;
		relocate( "admin.users" );
	}

	/**
	 * List all cases including archived; restore archived via POST restoreArchivedCase.
	 */
	function cases( event, rc, prc ) {
		prc.pageTitle = "All cases";
		flushAdminNotice( prc );
		prc.cases = caseService.listAll( true );
		event.setView( "admin/cases" );
	}

	/**
	 * POST: restore a soft-archived case.
	 */
	function restoreArchivedCase( event, rc, prc ) {
		if ( event.getHTTPMethod() != "POST" ) {
			relocate( "admin.cases" );
			return;
		}
		var caseId = structKeyExists( rc, "caseId" ) && isNumeric( rc.caseId ) ? val( rc.caseId ) : 0;
		if ( caseId <= 0 ) {
			session.adminNotice = "Invalid case.";
			session.adminNoticeIsError = true;
			relocate( "admin.cases" );
			return;
		}
		var u = securityService.getCurrentUser();
		if ( isNull( u ) ) {
			relocate( "main.login" );
			return;
		}
		var result = caseService.restoreCase( caseId = caseId, userId = u.getUserId() );
		session.adminNotice = result.success ? "Case restored." : ( result.error ?: "Could not restore case." );
		session.adminNoticeIsError = !result.success;
		relocate( "admin.cases" );
	}

	private void function flushAdminNotice( required prc ) {
		if ( structKeyExists( session, "adminNotice" ) && len( trim( session.adminNotice ) ) ) {
			prc.noticeMessage = session.adminNotice;
			prc.noticeIsError = structKeyExists( session, "adminNoticeIsError" ) && session.adminNoticeIsError;
			structDelete( session, "adminNotice" );
			structDelete( session, "adminNoticeIsError" );
		}
	}

	private any function userRoleConstants() {
		return new models.constants.User_Role();
	}

}
