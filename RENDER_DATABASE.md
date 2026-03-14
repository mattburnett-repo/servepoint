# Render database: wipe and start fresh

Use these steps when you want to **reset the Render PostgreSQL database** so the app can run the single bootstrap migration from a clean state (e.g. after consolidating migrations or fixing schema drift).

**Environment variables on Render:** The repo does not commit `.env.deploy` (it is in `.gitignore`). Configure the Render **Web Service** with the same variables you use locally for the remote DB: at minimum set `DB_DRIVER`, `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD` (from your Render Postgres service), `ORM_DBCREATE=validate`, and `SERVEPOINT_AUTO_SEED` (e.g. `true`) in the Render dashboard so each deploy has the correct config.

## 1. Connect to the Render PostgreSQL database

- In the [Render Dashboard](https://dashboard.render.com/), open your **PostgreSQL** service.
- Copy the **Internal Database URL** (or External if you’re running from your own machine).
- Connect with any PostgreSQL client (psql, DBeaver, etc.) using that URL.  
  Example with `psql`:
  ```bash
  psql "postgresql://USER:PASSWORD@HOST/DATABASE?sslmode=require"
  ```
  Use the exact URL from Render (it already includes user, password, host, database, and often `sslmode=require`).

## 2. Wipe app tables and migration history

Run the following SQL **in order** so foreign keys are respected. This drops all app tables and the cfmigrations tracking table so the next app start will run the bootstrap migration on an empty schema.

```sql
-- Drop application tables (order matters because of foreign keys)
DROP TABLE IF EXISTS log_entries CASCADE;
DROP TABLE IF EXISTS documents CASCADE;
DROP TABLE IF EXISTS cases CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Drop cfmigrations tracking table so the next deploy runs the bootstrap migration
DROP TABLE IF EXISTS cfmigrations CASCADE;
```

After this, the database has no `users`, `cases`, `documents`, `log_entries`, or `cfmigrations` tables.

## 3. Rebuild and redeploy the app

The bootstrap migration (`2026_03_14_000001_bootstrap_schema.cfc`) runs on application startup and creates the full schema. Rebuild the image and run the app so it uses the new migration:

**Local (Docker):**
```bash
docker build -t servepoint -f docker/Dockerfile .
docker run --env-file .env.deploy -p 8080:8080 servepoint
```

**Render (Web Service):**
- Push your branch (with the new migration and this wipe) and let Render build and deploy, **or**
- In the Render dashboard, trigger a **Manual Deploy** for the ServePoint web service.

On first request after deploy, the app will run `migrationService.install()` (recreating the `cfmigrations` table) and `migrationService.up()`, which runs the single bootstrap migration and creates `users`, `cases`, `documents`, and `log_entries` with the correct columns and indexes.

## 4. Optional: re-seed data

If you use `SERVEPOINT_AUTO_SEED=true` (default in `.env.deploy`), the app will run seeds after migrations. If the DB was wiped, you may want to leave that on so seed data is loaded again. If you disabled auto-seed, run your seed process manually after the first successful startup.

## Summary

| Step | Action |
|------|--------|
| 1 | Connect to Render Postgres with psql or another client. |
| 2 | Run the `DROP TABLE IF EXISTS ...` SQL above (log_entries → documents → cases → users → cfmigrations). |
| 3 | Rebuild Docker image and run container, or redeploy the web service on Render. |
| 4 | Optionally rely on auto-seed or run seeds manually. |

The bootstrap migration is **idempotent for create**: it uses `CREATE TABLE IF NOT EXISTS` and `CREATE INDEX IF NOT EXISTS`. It does **not** alter existing tables (e.g. add missing columns). For a clean state, always run the wipe (step 2) before redeploying when you intend to “start fresh.”
