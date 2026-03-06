component {

    property name="ROLES" type="struct";

    /**
     * Define all valid user roles. Set in pseudo-constructor for Adobe CF compatibility (no static final).
     */
    this.ROLES = {
        "CITIZEN": "Citizen",
        "CASE_MANAGER": "Case Manager",
        "ADMINISTRATOR": "Administrator"
    };

    /**
     * A helper method to get all the struct values.
     * @returns array An array of all the role strings.
     */
    public array function getValues() {
        return structValues( this.ROLES );
    }

}