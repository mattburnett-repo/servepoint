component {

    property name="STATUSES" type="struct";

    /**
     * Define all valid statuses. Set in pseudo-constructor for Adobe CF compatibility (no static final).
     */
    this.STATUSES = {
        'NEW': 'New',
        'IN_PROGRESS': 'In Progress',
        'PENDING_APPROVAL': 'Pending Approval',
        'CLOSED': 'Closed'
    };

    /**
     * A helper method to get all the struct values.
     * @returns array An array of all the status values.
     */
    public array function getValues() {
        var values = [];
        for (var key in this.STATUSES) {
            arrayAppend(values, this.STATUSES[key]);
        }
        return values;
    }

}
