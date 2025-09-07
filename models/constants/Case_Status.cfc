component {

    /**
     * Define all valid statuses as a static struct.
     * This provides easy access by key and is highly maintainable.
     *
     * Example:
     * someVar = Case_Status.STATUSES.IN_PROGRESS
     *
     * Get an array of all status values:
     *    allStatuses = Case_Status.getValues();
     */
    static final property name="STATUSES" type="struct" default={
        "NEW": "New",
        "IN_PROGRESS": "In Progress",
        "PENDING_APPROVAL": "Pending Approval",
        "CLOSED": "Closed"
    };

    /**
     * A helper method to get all the struct values.
     * @returns array An array of all the status values.
     */
    public array function getValues() {
        return structValues( this.STATUSES );
    }

}