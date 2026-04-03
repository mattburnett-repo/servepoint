# ServePoint

**Project Goal:** Develop a professional, enterprise-grade ColdFusion demo application showcasing modern architecture, integration, security, privacy, and deployment best practices—targeted at clients such as the **US Federal Government** and mission-driven public-sector agencies.

---

### 🔷 **Top-Level Requirements**

#### 1. **Use Case: Social Services Case Management System**

- A flexible, scalable platform designed for managing **citizen cases** at both **federal and local government levels**.
- Core features:
    - Case intake via forms or APIs
    - Assignment, tracking, and status updates
    - Secure document upload, listing, and download (retention policy below)
    - Staff communication and audit trails

#### 1a. **Document retention (design decision)**

Documents attached to a case are treated as **part of the case record**, aligned with planned policy- and records-management expectations. The product **does not** expose **delete** (or equivalent hard-remove) actions in the same **upload / view** experience case workers use day to day.

**Disposition**—removing metadata, purging blobs, or otherwise taking a document out of normal use—is intentionally **out of band**: governed by **organizational records policy**, **administrative procedure**, and **separate processes or tooling** (not casual UI deletion). Invalid uploads are still rejected at staging and removed from **temp** only; that is not a substitute for deleting an accepted case document.

Future enhancements might include **admin-only** workflows, **supersede / version** patterns, or **soft-hide** with audit, but **end-user delete from the documents workspace** remains a non-goal unless requirements change.

#### 2. **Platform: Adobe ColdFusion 2025**

- Utilizing modern ColdFusion features:
    - RESTful services and CFScript-first coding
    - CF-native schedulers, PDF/email tools
    - Secure session and authentication management

#### 3. **Architecture: HMVC via ColdBox Framework**

- Clear modular design with separation of concerns:
    - Handlers, models, views, interceptors
    - Built-in routing, AOP, caching, and logging
    - Highly testable and maintainable codebase

#### 4. **Data Layer: ColdFusion ORM**

- ORM-based data access using ColdFusion's Hibernate implementation:
    - Entity modeling with relationships and transaction safety
    - Portable schema design supporting future data evolution

#### 5. **System Integration: Deep, Demonstrable**

- Showcasing ColdFusion's integration capabilities:
    - Outbound API calls (mocked or live)
    - Document generation and emailing
    - Scheduled jobs for data sync or maintenance
    - Secure file upload and storage
    - Identity management via LDAP, OAuth, or SAML simulations

#### 6. **Frontend: Progressive Enhancement (currently framework-agnostic)**

- Initial UI with ColdFusion native templates
- Designed for easy integration with an SPA (e.g. Vue or React):
    - JSON/REST API endpoints
    - Responsive mobile-first design
    - Progressive enhancement with polyfills and conservative JS

#### 7. **Testing: Integral from Inception**

- Aim for broad test coverage with **TestBox**:
    - Unit, integration, and behavioral tests
    - External dependencies mocked for reliable CI runs

#### 8. **Logging: Comprehensive Audit and Monitoring**

- Extensive logging via **LogBox**:
    - Authentication, authorization, CRUD, integration events
    - Admin actions and configuration changes
    - Multiple log targets for flexibility and future SIEM integration

#### 9. **Administrative Interface**

- **Design target:** dedicated admin panel enabling:
    - User and role management with permission controls
    - System health and job monitoring
    - Manual background task triggers
    - Log and audit trail review
    - Configuration management with security considerations

#### 10. **Deployment: Containerized & Cloud-Ready**

- Full **Docker** support:
    - Dockerfiles and compose configs for easy local and cloud deployment
    - ColdFusion container images paired with DB and cache services

- Designed for seamless deployment to **cloud platforms** (AWS, GCP, or similar):
    - Support for container orchestration (ECS, Cloud Run, etc.)
    - Cloud-native logging and scaling considerations

#### 11. **User Privacy & Security**

- Adherence to **user privacy best practices**:
    - Minimal data collection and storage
    - Data encryption at rest and in transit (TLS)
    - Secure session management and cookie handling
    - Role-based access controls enforcing least privilege
    - Logging and monitoring designed to avoid exposing sensitive data
    - Compliance with relevant privacy regulations (GDPR, HIPAA, CCPA as applicable)

#### 12. **Best Practices**

- Secure coding following OWASP guidelines
- Modular, maintainable ColdBox conventions
- Dependency injection with WireBox
- Responsive, accessible, and maintainable UI

#### 13. **AI Assistance Permitted**

- Use of **ChatGPT** and **Cursor AI** for:
    - Boilerplate generation
    - Refactoring and documentation
    - Test creation and troubleshooting

---

### 🔄 **Suggested Next Steps**

Available starting points:

- Define privacy-conscious user roles and case workflows
- Design admin UI with privacy and logging in mind
- Outline cloud deployment architecture and security features
- Plan secure document upload, storage, access controls, and retention alignment (see issue #33 and `DEV_NOTES.md` — document retention)
