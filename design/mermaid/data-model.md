# ServePoint Data Model

Entity relationship diagram aligned with PostgreSQL physical columns (`resources/database/migrations`) and ORM mappings in `models/*.cfc`. ORM property names are camelCase; quoted mixed-case columns in `users` / `documents` map to those properties.

```mermaid
erDiagram
    users ||--o{ cases : "creator_id"
    users ||--o{ cases : "assigned_to_id"
    users ||--o{ cases : "archived_by"
    users ||--o{ log_entries : "user_id"
    cases ||--o{ documents : "case_id"
    cases ||--o{ log_entries : "case_id"

    users {
        int user_id PK
        string firstName
        string lastName
        string email UK
        string password
        string role
    }

    cases {
        int case_id PK
        string title
        string description
        timestamp date_created
        timestamp date_updated
        string status
        int creator_id FK
        int assigned_to_id FK
        timestamp archived_at
        int archived_by FK
        string archive_reason
    }

    documents {
        int document_id PK
        string title
        string fileName
        numeric fileSize
        string fileType
        timestamp date_uploaded
        int case_id FK
    }

    log_entries {
        int log_entry_id PK
        timestamp date_created
        string entryText
        string type
        int case_id FK
        int user_id FK
    }
```

## Entity summary and ORM contract

| Entity      | Table        | Key relationships | Notes |
|------------|--------------|-------------------|--------|
| Users      | users        | creator / assignedTo / archivedBy cases; user for log_entries | `email` unique; PK `user_id` |
| Cases      | cases        | belongs to creator, assignedTo, archivedBy (Users); has many documents & log_entries | Active lists exclude rows with `archived_at IS NOT NULL`. `date_created` / `date_updated` are maintained by DB defaults and (on update) trigger — see migration `2026_03_27_000002_timestamp_defaults.cfc`. |
| Document   | documents    | belongs to one Case | PK `document_id`; `date_uploaded` has DB default |
| LogEntry   | log_entries  | belongs to one Case and one User | PK `log_entry_id`; FK `user_id` → users |

### Index and constraint expectations (for migrations)

- **users**: unique on `email`.
- **cases**: indexes on `status`, `creator_id`, `assigned_to_id`, `archived_at`.
- **documents**: index on `case_id`.
- **log_entries**: indexes on `case_id`, `user_id`, `type`.

## Constants (non-ORM)

Used for validation and dropdowns; live under `models/constants/`:

- **User_Role**, **Case_Status**, **Document_File_Type**, **Log_Entry_Type**

Persistent entities extend `cborm.models.ActiveEntity` and call `validate()` using the injected constant components where applicable.
