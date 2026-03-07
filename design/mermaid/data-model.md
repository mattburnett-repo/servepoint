# ServePoint Data Model

Entity relationship diagram for the ORM models (cborm / ColdFusion ORM).

```mermaid
erDiagram
    users ||--o{ cases : "creator_id"
    users ||--o{ cases : "assigned_to_id"
    users ||--o{ log_entries : "creator_id"
    cases ||--o{ documents : "case_id"
    cases ||--o{ log_entries : "case_id"

    users {
        int user_id PK
        string firstName
        string lastName
        string email
        string password
        string role
    }

    cases {
        int case_id PK
        string title
        string description
        string status
        date dateCreated
        date dateUpdated
        int creator_id FK
        int assigned_to_id FK
    }

    documents {
        int document_id PK
        string title
        string fileName
        numeric fileSize
        string fileType
        date dateUploaded
        int case_id FK
    }

    log_entries {
        int log_entry_id PK
        date dateCreated
        string entryText
        string type
        int case_id FK
        int user_id FK
    }
```

## Entity summary

| Entity      | Table        | Key relationships |
|------------|--------------|--------------------|
| Users      | users        | creator of cases, assignedTo cases, author of log_entries |
| Cases      | cases        | belongs to creator & assignedTo (Users); has many documents & log_entries |
| Document   | documents    | belongs to one Case |
| LogEntry   | log_entries  | belongs to one Case and one User |

## Constants (non-ORM)

Used for validation and dropdowns; not persisted as entities:

- **User_Role**: Citizen, Case Manager, Administrator
- **Case_Status**: (values defined in constants/Case_Status.cfc)
- **Document_File_Type**: (values defined in constants/Document_File_Type.cfc)
- **Log_Entry_Type**: (values defined in constants/Log_Entry_Type.cfc)

All persistent entities extend `cborm.models.ActiveEntity` and use `validate()` with the injected constant components.
