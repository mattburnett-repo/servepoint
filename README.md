# ServePoint

A Work-In-Progress enterprise-grade ColdFusion demo application showcasing modern architecture, integration, security, privacy, and deployment best practices—targeted at clients such as the US Federal Government and mission-driven public-sector agencies.

## 🎯 Project Overview

ServePoint is a **Social Services Case Management System** designed for managing citizen cases at both federal and local government levels. It demonstrates ColdFusion's enterprise capabilities with a focus on security, privacy, and modern development practices.

For detailed design specifications and requirements, see [DESIGN_NOTES.md](DESIGN_NOTES.md).

For development notes, see [DEV_NOTES.md](DEV_NOTES.md).

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

Server setup, engine options (Lucee vs ColdFusion 2025), and related configuration are documented in [DEV_NOTES.md](DEV_NOTES.md).

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
2. **Create a `.env` file**
   - Copy from [.env.example](.env.example) and set values for the database connection and any other required settings.
3. **Start the application stack with Docker** (recommended)  
   From the project root (`ServePoint` directory), run:

```bash
docker compose --env-file .env -f docker/docker-compose.yml up
```

This builds the app image, starts the ColdFusion and Postgres containers, and wires all environment variables from `.env`.

4. **Access the application**
   - Application: `http://localhost:8080` (or the port defined in `docker-compose.yml`)

### Running tests (Docker)

ServePoint includes TestBox specs under the `tests/` folder.

1. Ensure the stack is running with Docker as described above.
2. In your browser, open:

   ```text
   http://localhost:8080/tests/
   ```

3. Use the TestBox runner UI to execute the test suites (including integration specs such as `SeedingSpec.cfc`) by clicking the **Run All** button or selecting individual specs.

### Database seeding

- On startup, ServePoint can automatically seed the database with an administrator user and sample data via the ORM.
- This behavior is controlled by the `SERVEPOINT_AUTO_SEED` environment variable:
  - If **unset or blank**, seeding **runs by default**.
  - If set to one of `1`, `true`, `yes`, or `on` (case-insensitive), seeding runs.
  - Any other value disables automatic seeding.
- In Docker, define `SERVEPOINT_AUTO_SEED` in your `.env` file.

## 📄 License

[MIT](https://opensource.org/licenses/MIT)
