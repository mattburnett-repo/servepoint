<cfscript>
try {
    ormReload();
    entities = ormGetSessionFactory().getAllClassMetadata().keySet().toArray();
    writeDump(label="Discovered Entities", var=entities);

    userService = wirebox.getInstance("UserService@cborm");
    writeDump(userService);
} catch(any e){
    writeDump(label="ORM or cborm failed", var=e);
}
</cfscript>
