component {

    /**
     * Define all valid user roles as a static struct.
     * This provides easy access by key and is highly maintainable.
     */
    static final property name="ROLES" type="struct" default={
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