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
        timestamp archived_at
        int archived_by FK
        string archive_reason
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

## Entity summary and ORM contract

| Entity      | Table        | Key relationships | Required (at creation) | Uniqueness / keys |
|------------|--------------|--------------------|------------------------|--------------------|
| Users      | users        | creator of cases, assignedTo cases, author of log_entries | `firstName`, `email`, `password`, `role` | `email` unique; PK `user_id` |
| Cases      | cases        | belongs to creator & assignedTo (Users); has many documents & log_entries | `title`, `status`, `dateCreated`, `creator` | PK `case_id`. Optional: `archivedAt`, `archivedBy`, `archiveReason`. Default case lists: active only (`archived_at IS NULL`). |
| Document   | documents    | belongs to one Case | `title`, `fileName`, `fileSize`, `fileType`, `dateUploaded`, `caseRef` | PK `document_id` |
| LogEntry   | log_entries  | belongs to one Case and one User | `dateCreated`, `entryText`, `type`, `caseRef`, `user` | PK `log_entry_id` |

### Index and constraint expectations (for migrations)

- **users**
  - Unique index on `email`.
- **cases**
  - Indexes on `status`, `creator_id`, `assigned_to_id`, `archived_at`.
- **documents**
  - Index on `case_id`.
- **log_entries**
  - Indexes on `case_id`, `user_id`, and optionally `type`.

## Constants (non-ORM)

Used for validation and dropdowns; not persisted as entities:

- **User_Role**: Citizen, Case Manager, Administrator
- **Case_Status**: (values defined in constants/Case_Status.cfc)
- **Document_File_Type**: (values defined in constants/Document_File_Type.cfc)
- **Log_Entry_Type**: (values defined in constants/Log_Entry_Type.cfc)

All persistent entities extend `cborm.models.ActiveEntity` and use `validate()` with the injected constant components.
