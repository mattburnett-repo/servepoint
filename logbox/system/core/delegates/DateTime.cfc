/**
 * This delegate is useful to interact with the logbox.system.async.time.DateTimeHelper as your date time helper
 */
component singleton {

	property
		name  ="dateTimeHelper"
		inject="logbox.system.async.time.DateTimeHelper"
		delegate;

}
