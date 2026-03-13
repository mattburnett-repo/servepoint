component persistent="true" extends="cborm.models.ActiveEntity" table="users" {
    // Inject the User_Role component from the constants folder
    property name="User_Role" inject="constants.User_Role" persistent="false";

    // Primary Key
    property name="userId" fieldtype="id" column="user_id" generator="identity";

    // Attributes
    property name="firstName" type="string" notnull="true";
    property name="lastName"  type="string" notnull="true";
    property name="email"     type="string" notnull="true" unique="true";
    property name="password"  type="string" notnull="true";
    property name="role"      type="string" notnull="true";

    // Relationships
    property name="cases"       fieldtype="one-to-many" cfc="Cases" fkcolumn="creator_id";
    property name="assignedTo"  fieldtype="one-to-many" cfc="Cases" fkcolumn="assigned_to_id";
    property name="logEntries"  fieldtype="one-to-many" cfc="LogEntry" fkcolumn="user_id";

    /**
     * ColdBox ORM lifecycle method to validate the data before saving.
     */
    public void function validate() {
        // Basic required-field validation
        if ( isNull( this.firstName ) || !len( trim( this.firstName ) ) ) {
            addError( property="firstName", message="First name is required." );
        }

        if ( isNull( this.lastName ) || !len( trim( this.lastName ) ) ) {
            addError( property="lastName", message="Last name is required." );
        }

        if ( isNull( this.email ) || !len( trim( this.email ) ) ) {
            addError( property="email", message="Email is required." );
        }

        if ( isNull( this.password ) || !len( trim( this.password ) ) ) {
            addError( property="password", message="Password is required." );
        }

        if ( isNull( this.role ) || !len( trim( this.role ) ) ) {
            addError( property="role", message="Role is required." );
        }

        // Get the valid user roles from the User_Role component
        var validRoles = this.User_Role.getValues();

        // Check if the current user's role is NOT in the list of valid roles.
        if ( !arrayFind( validRoles, this.role ) ) {
            addError( property="role", message="Invalid user role: The role '#this.role#' is not a valid option." );
        }

        // Very simple email-shape check (can be tightened later)
        if ( len( trim( this.email ) ) && !reFind( "^[^@]+@[^@]+\.[^@]+$", this.email ) ) {
            addError( property="email", message="Email address is not in a valid format." );
        }
    }
}