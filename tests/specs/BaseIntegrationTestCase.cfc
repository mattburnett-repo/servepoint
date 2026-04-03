/**
 * Integration specs: each spec runs inside a CFML transaction that is rolled back after the spec,
 * so test data does not persist in the database.
 *
 * Uses TestBox @aroundEach so setup() and DB work participate in the same transaction as the spec body.
 */
component extends="coldbox.system.testing.BaseTestCase" appMapping="/root" {

	/**
	 * @aroundEach
	 */
	public void function wrapInDbTransaction( required spec, required suite, struct data = {} ) {
		transaction {
			setup();
			getWireBox().getInstance( "CaseService" ).restoreAllArchived();
			spec.body();
			transaction action="rollback";
		}
		ormClearSession();
	}

}
