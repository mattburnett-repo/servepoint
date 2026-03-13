# Development Notes

## Development workflow (important)

For day‑to‑day development, **run the app inside Docker**, not via `box server start` on your host machine.

- **Preferred**: from the project root (`ServePoint` directory), start the full stack with:

  ```bash
  docker compose --env-file .env -f docker/docker-compose.yml up
  ```

  This builds the app image, starts the app and Postgres containers, and wires all environment variables from `.env`.

- **Not preferred**: running `box server start` directly on your host. That path is only for troubleshooting; it does not match the containerized production‑like environment, and may behave differently (Java, paths, CF packages, etc.).

## Config and secrets

This app uses:

- **commandbox-dotenv** (preinstalled in the Docker image) to load environment variables.
- A familiar **`.env` file in the project root** for secrets and configuration (database credentials, etc.).

When you run the app via Docker (`docker compose --env-file .env -f docker/docker-compose.yml up`), those `.env` values are injected into the containers and used by CF/ColdBox; you should not commit `.env` to version control.

### Database seeding (`SERVEPOINT_AUTO_SEED`)

- On application startup, the ORM can automatically seed the database with an administrator user and sample demo data.
- This is controlled by the `SERVEPOINT_AUTO_SEED` environment variable:
  - If **unset or blank**, seeding **runs by default**.
  - If set to `1`, `true`, `yes`, or `on` (case-insensitive), seeding runs.
  - Any other value disables automatic seeding.
- For Docker workflows, add `SERVEPOINT_AUTO_SEED` to your `.env` file so it is injected into the container.
- For local CommandBox workflows, set `SERVEPOINT_AUTO_SEED` in your shell environment before running `box server start`.

## ORM model expectations (source of truth)

- All persistent entities (`Users`, `Cases`, `Document`, `LogEntry`) extend `cborm.models.ActiveEntity` and are mapped according to `design/mermaid/data-model.md`.
- Required vs optional fields, uniqueness rules (e.g., `Users.email` unique), and high-level index expectations are documented in `design/mermaid/data-model.md` and should be treated as the contract for migrations and DB schema.

## Database & migrations

- The database schema is managed via **cfmigrations**:
  - Migrations live under `resources/database/migrations/` as timestamped CFCs with `up()`/`down()` methods.
  - The default manager is configured in `config/Coldbox.cfc` to target the `servepoint` datasource with a Postgres grammar.
- On application startup (`Application.cfc`):
  - ColdBox is bootstrapped.
  - `runMigrations()` is invoked to `install()` the migrations tracking table and run `up()` to apply any pending migrations.
  - ORM is then initialized, followed by optional seeding via `SeedService` when `SERVEPOINT_AUTO_SEED` indicates seeding should run.
- ORM is configured with `dbcreate="validate"` (in both `Application.cfc` and `config/Coldbox.cfc`), so Hibernate no longer mutates the schema; it only validates that the schema matches the ORM mappings.
- **Developer workflow**:
  - For local work, ensure CommandBox dependencies are installed (`box install`), then start the stack via Docker as usual; migrations will run automatically on first request/startup.
  - Any schema-changing feature (new columns, indexes, archive flags, etc.) must add a new migration in `resources/database/migrations/` rather than relying on `dbcreate`.

### Archive / restore (data retention)

- **Soft archive only**: Cases can be archived at the business level. Data stays in the main tables; the case’s `archived_at` (and optional `archived_by`, `archive_reason`) mark it as archived.
- **Default query behavior**: Case lists used by the app return **only active cases** by default (`archived_at IS NULL`). Use `CaseService.listActive()` for the default list and `CaseService.listAll( includeArchived = true )` when archived cases should be included (e.g. admin or reporting).
- **Archive and restore**: Use `CaseService.archiveCase( caseId, userId, reason )` and `CaseService.restoreCase( caseId, userId )`. These optionally create a `LogEntry` for audit. Documents and log entries have no separate archive state; visibility follows the case’s archive flag.
- A future **hard** archive (separate archive tables or export to storage) is out of scope for this phase.

## Known issues

- **"graphqlclient not found" with CF 2025**:
  - When starting the app with ColdFusion 2025, the first request (when the app first loads) can trigger a `ModuleNotAvailableException: The graphqlclient package is not installed` error.
  - **Cause**: CF 2025's `ApplicationSettings.loadAppDatasources()` calls `ServiceFactory.getGraphQLClientService()` when resolving application scope; if the optional graphqlclient package is not installed, it throws.
  - This app does not use GraphQL; it appears that the error originates within ColdFusion 2025 itself.
  - **Workaround**: In `Application.cfc` `onError()`, we detect this exception and issue a 302 redirect to the same URL. The second request succeeds because the application scope is already resolved. See [GitHub issue #10](https://github.com/mattburnett-repo/servepoint/issues/10).
