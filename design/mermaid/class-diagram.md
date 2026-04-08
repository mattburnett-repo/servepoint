# ServePoint Models – Class Diagram

Class diagram for CFCs in the `models` folder. Persistent entities extend `cborm.models.ActiveEntity`. Constants live in `models/constants/` and are injected for validation and option lists.

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
        +communicationsAuthored collection
        +communicationsUpdatedBy collection
        +validate() void
    }

    class Cases {
        +caseId id
        +title string
        +description string
        +status string
        +dateCreated timestamp
        +dateUpdated timestamp
        +archivedAt date
        +archivedBy Users
        +archiveReason string
        +creator Users
        +assignedTo Users
        +documents collection
        +logEntries collection
        +communications collection
        +validate() void
        +isArchived() boolean
    }

    class Document {
        +documentId id
        +title string
        +fileName string
        +fileSize numeric
        +fileType string
        +dateUploaded timestamp
        +caseRef Cases
        +validate() void
    }

    class LogEntry {
        +logEntryId id
        +dateCreated timestamp
        +entryText string
        +type string
        +caseRef Cases
        +user Users
        +validate() void
    }

    class Communication {
        +communicationId id
        +dateCreated timestamp
        +dateUpdated timestamp
        +message string
        +type string
        +caseRef Cases
        +author Users
        +updatedBy Users
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

    class Communication_Type {
        +TYPES struct
        +getValues() array
    }

    ActiveEntity <|-- Users
    ActiveEntity <|-- Cases
    ActiveEntity <|-- Document
    ActiveEntity <|-- LogEntry
    ActiveEntity <|-- Communication

    Users "1" --> "0..*" Cases : creator
    Users "1" --> "0..*" Cases : assignedTo
    Users "0..1" --> "0..*" Cases : archivedBy
    Users "1" --> "0..*" LogEntry : user
    Users "1" --> "0..*" Communication : author
    Users "0..1" --> "0..*" Communication : updatedBy
    Cases "1" --> "0..*" Document : documents
    Cases "1" --> "0..*" LogEntry : logEntries
    Cases "1" --> "0..*" Communication : communications
    Document "*" --> "1" Cases : caseRef
    LogEntry "*" --> "1" Cases : caseRef
    LogEntry "*" --> "1" Users : user
    Communication "*" --> "1" Cases : caseRef
    Communication "*" --> "1" Users : author

    Users ..> User_Role : inject
    Cases ..> Case_Status : inject
    Document ..> Document_File_Type : inject
    LogEntry ..> Log_Entry_Type : inject
    Communication ..> Communication_Type : inject
```

## Legend

| Symbol / text | Meaning |
|----------------|--------|
| `<\|--` | Inheritance (entity extends ActiveEntity) |
| `-->` | Association / relationship (e.g. many-to-one) |
| `..>` | Dependency (injected constant component under `models.constants`) |
| `<<cborm>>` | Stereotype: provided by cborm module |

## Notes

- **Persistent entities**: table-backed; `validate()` runs on ORM save where configured.
- **Document**: modeled as a retained case attachment; the product design intentionally **does not** map an in-app delete lifecycle here—see `DESIGN_NOTES.md` / `DEV_NOTES.md` (Document retention).
- **Constants**: structs of allowed values and `getValues()` for validation and UI; not persisted.
- **Services** (`services/CaseService.cfc`, `services/CommunicationService.cfc`, etc.) are not shown here; they orchestrate ORM and live outside `models/`.
