component persistent="true" extends="cborm.models.ActiveEntity" table="users" {
    // Inject the User_Role component from the constants folder
    property name="User_Role" inject="constants.User_Role";

    // Primary Key
    property name="userId" fieldtype="id" column="user_id" generator="identity";

    // Attributes
    property name="firstName" type="string";
    property name="lastName"  type="string";
    property name="email"     type="string";
    property name="password"  type="string";
    property name="role"      type="string";

    // Relationships
    property name="cases"       fieldtype="one-to-many" cfc="Cases" fkcolumn="creator_id";
    property name="assignedTo"  fieldtype="one-to-many" cfc="Cases" fkcolumn="assigned_to_id";
    property name="logEntries"  fieldtype="one-to-many" cfc="LogEntry" fkcolumn="creator_id";

    /**
     * ColdBox ORM lifecycle method to validate the data before saving.
     */
    public void function validate() {
        // Get the valid user roles from the User_Role component
        var validRoles = this.User_Role.getValues();

        // Check if the current user's role is NOT in the list of valid roles.
        if ( !arrayFind( validRoles, this.role ) ) {
            // If it's not valid, add an error message to the 'role' property.
            addError( property="role", message="Invalid user role: The role '#this.role#' is not a valid option." );
        }
    }
}