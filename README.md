# ServePoint

A Work-In-Progress enterprise-grade ColdFusion demo application showcasing modern architecture, integration, security, privacy, and deployment best practices—targeted at clients such as the US Federal Government and mission-driven public-sector agencies.

## 🎯 Project Overview

ServePoint is a **Social Services Case Management System** designed for managing citizen cases at both federal and local government levels. It demonstrates ColdFusion's enterprise capabilities with a focus on security, privacy, and modern development practices.

For detailed design specifications and requirements, see [DESIGN_NOTES.md](DESIGN_NOTES.md).

For development notes, see [DEV_NOTES.md](DEV_NOTES.md).

Agent rules for Cursor (agentic coding): [.cursor/rules/](.cursor/rules/).

## 🏗️ Architecture

- **Platform**: Adobe ColdFusion 2025. Lucee 6 support might happen in the future.
- **Framework**: ColdBox HMVC
- **Data Layer**: ColdFusion ORM (Hibernate)
- **Testing**: TestBox
- **Containerization**: Docker
- **Frontend**: Progressive Enhancement (React/Vue.js ready)

## 📚 Documentation

For comprehensive design specifications, architecture decisions, and implementation details, see [DESIGN_NOTES.md](DESIGN_NOTES.md).

## 📚 Development Notes

Server setup, engine options (Lucee vs ColdFusion 2025), and related configuration are documented in [DEV_NOTES.md](DEV_NOTES.md). That file also covers **linting and formatting**: **cfformat** for CFML, **CFLint** (editor + `.cflintrc`), and **Prettier** for non-CF files — see the “Linting and formatting” section there.

Document upload storage settings (`SERVEPOINT_DOCUMENT_STORAGE_ROOT`, `SERVEPOINT_DOCUMENT_TEMP_ROOT`, `SERVEPOINT_DOCUMENT_MAX_BYTES`) are also documented in `DEV_NOTES.md`.
Upload handling uses `SERVEPOINT_DOCUMENT_TEMP_ROOT` as staging only; files are validated and then moved to final storage at `SERVEPOINT_DOCUMENT_STORAGE_ROOT` (for Docker local dev: `/app/uploads/documents`, backed by host `./uploads/documents`).
For demo deployments without persistent disks, set `SERVEPOINT_STORAGE_PERSISTENT=false` and use an ephemeral storage root (for example `/tmp/servepoint/uploads/documents`) so the UI clearly indicates non-persistent behavior.

## 📚 Diagramming

UML use for this project is mostly exploratory. UML files/artifacts are found in the [design/uml](/design/uml) folder.

Mermaid is also exploratory. Files/artifacts in the [design/mermaid](/design/mermaid) folder.

## 🚀 Quick Start

### Prerequisites

- [Docker](https://www.docker.com/) and Docker Compose

### Installation and Startup (Docker only)

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd ServePoint
   ```
2. **Create a `.env.dev` file**
   - Copy from [.env.example](.env.example) and set values for the database connection and any other required settings.
3. **Start the application stack with Docker** (recommended)  
   From the project root (`ServePoint` directory), run:

```bash
docker compose --env-file .env.dev -f docker/docker-compose.yml up
```

This builds the app image, starts the ColdFusion and **local** Postgres containers, and wires all environment variables from `.env.dev`. The compose stack gives you an isolated local database for development. For deployment to Render (remote database), see [RENDER_DATABASE.md](RENDER_DATABASE.md); Render builds from the Dockerfile only and does not use docker-compose.

4. **Access the application**
   - Application: `http://localhost:8081` (host port mapped in `docker/docker-compose.yml`; container still listens on 8080)
   - Document upload MVP: open `http://localhost:8081/documents/index` to select a case, then upload/list/download files.

### Running tests (Docker)

Tests live under `tests/` and run in the browser against the app in Docker.

1. Start the stack with Docker (see above) so the app is at `http://localhost:8081`.
2. Open **http://localhost:8081/tests/** in your browser. You’ll see the TestBox runner page.
3. To run everything (including integration tests): click **Run All**. To run only some tests: expand the list and run the bundle or spec you want (e.g. the integration folder or a single spec file).

### Database seeding

- On startup, ServePoint can automatically seed the database with an administrator user and sample data via the ORM.
- This behavior is controlled by the `SERVEPOINT_AUTO_SEED` environment variable:
  - If **unset or blank**, seeding **runs by default**.
  - If set to one of `1`, `true`, `yes`, or `on` (case-insensitive), seeding runs.
  - Any other value disables automatic seeding.
- In Docker, define `SERVEPOINT_AUTO_SEED` in your `.env.dev` file.

## 📄 License

[MIT](https://opensource.org/licenses/MIT)
