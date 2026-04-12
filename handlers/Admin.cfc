component extends="coldbox.system.EventHandler" {

	/**
	 * Admin home — Administrator-only (see SecurityInterceptor).
	 */
	function index( event, rc, prc ) {
		prc.pageTitle = "Administration";
		event.setView( "admin/index" );
	}

}
