# ServePoint

A Work-In-Progress enterprise-grade ColdFusion demo application showcasing modern architecture, integration, security, privacy, and deployment best practices—targeted at clients such as the US Federal Government and mission-driven public-sector agencies.

## 🎯 Project Overview

ServePoint is a **Social Services Case Management System** designed for managing citizen cases at both federal and local government levels. It demonstrates ColdFusion's enterprise capabilities with a focus on security, privacy, and modern development practices.

For detailed design specifications and requirements, see [DESIGN_NOTES.md](DESIGN_NOTES.md).

## 🏗️ Architecture

- **Platform**: Adobe ColdFusion 2021/2023 and/or Lucee 5.x
- **Framework**: ColdBox HMVC
- **Data Layer**: ColdFusion ORM (Hibernate)
- **Testing**: TestBox
- **Containerization**: Docker
- **Frontend**: Progressive Enhancement (Vue.js ready)

## 🚀 Quick Start

### Prerequisites

- [CommandBox](https://www.ortussolutions.com/products/commandbox)
- [Docker](https://www.docker.com/) and Docker Compose

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd ServePoint
   ```
2. **Start your database server**
<!-- 2. **Start the application with Docker**
   ```bash
   cd docker
   docker-compose up
   ``` -->
3. **Start the application with CommandBox (within the 'ServePoint' directory/folder)**

   ```bash

   box server start
   ```

   After a short startup process, the app should appear in a browser at
   '127.0.0.1:randomPortNumber'

<!-- 4. **Access the application**
   - Application: http://localhost:8080
   - Admin: http://localhost:8080/admin -->

## 📁 Project Structure

```
ServePoint/
├── design/           # Design docs, UML artifacts
├── handlers/         # Controllers
├── models/           # ORM entities and services
├── views/            # Presentation templates
├── layouts/          # Page layouts
├── interceptors/     # Cross-cutting concerns
├── modules/          # Modular functionality
├── tests/            # TestBox tests
├── docker/           # Docker configuration
└── config/           # Application configuration
```

## 🔧 Development

### Running Tests

```bash
box testbox run
```

### Code Formatting

```bash
box cfformat run
```

### Linting

```bash
box cflint run
```

## 🔒 Security & Privacy

- Role-based access controls
- Data encryption at rest and in transit
- Secure session management
- Comprehensive audit logging
- Compliance with privacy regulations (GDPR, HIPAA, CCPA)

## 📚 Documentation

For comprehensive design specifications, architecture decisions, and implementation details, see [DESIGN_NOTES.md](DESIGN_NOTES.md).

## UML

UML use for this project is mostly exploratory. UML files/artifacts are found in the [design](/design) folder.

## 📄 License

[MIT](https://opensource.org/licenses/MIT)
