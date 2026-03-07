# ServePoint Models – Class Diagram

Class diagram for CFCs in the `models` folder. Persistent entities extend `cborm.models.ActiveEntity`; constants are plain components used for validation and option lists.

```mermaid
classDiagram
    direction TB

    class ActiveEntity {
        <<cborm>>
        +addError(property, message)
    }

    class Users {
        +userId id
        +firstName string
        +lastName string
        +email string
        +password string
        +role string
        +cases collection
        +assignedTo collection
        +logEntries collection
        +validate() void
    }

    class Cases {
        +caseId id
        +title string
        +description string
        +status string
        +dateCreated date
        +dateUpdated date
        +creator Users
        +assignedTo Users
        +documents collection
        +logEntries collection
        +validate() void
    }

    class Document {
        +documentId id
        +title string
        +fileName string
        +fileSize numeric
        +fileType string
        +dateUploaded date
        +caseRef Cases
        +validate() void
    }

    class LogEntry {
        +logEntryId id
        +dateCreated date
        +entryText string
        +type string
        +caseRef Cases
        +user Users
        +validate() void
    }

    class User_Role {
        +ROLES struct
        +getValues() array
    }

    class Case_Status {
        +STATUSES struct
        +getValues() array
    }

    class Document_File_Type {
        +FILE_TYPES struct
        +getValues() array
    }

    class Log_Entry_Type {
        +TYPES struct
        +getValues() array
    }

    ActiveEntity <|-- Users
    ActiveEntity <|-- Cases
    ActiveEntity <|-- Document
    ActiveEntity <|-- LogEntry

    Users "1" --> "0..*" Cases : creator
    Users "1" --> "0..*" Cases : assignedTo
    Users "1" --> "0..*" LogEntry : logEntries
    Cases "1" --> "0..*" Document : documents
    Cases "1" --> "0..*" LogEntry : logEntries
    Document "*" --> "1" Cases : caseRef
    LogEntry "*" --> "1" Cases : caseRef
    LogEntry "*" --> "1" Users : user

    Users ..> User_Role : inject
    Cases ..> Case_Status : inject
    Document ..> Document_File_Type : inject
    LogEntry ..> Log_Entry_Type : inject
```

## Legend

| Symbol / text | Meaning |
|----------------|--------|
| `<\|--` | Inheritance (entity extends ActiveEntity) |
| `-->` | Association / relationship (e.g. many-to-one) |
| `..>` | Dependency (injected constant component) |
| `<<cborm>>` | Stereotype: provided by cborm module |

## Notes

- **Persistent entities** (Users, Cases, Document, LogEntry): table-backed; `validate()` is called by ORM before save and uses the injected constant to check allowed values.
- **Constants** (User_Role, Case_Status, Document_File_Type, Log_Entry_Type): hold structs of allowed values and expose `getValues()` for validation and UI options. Not persisted.
