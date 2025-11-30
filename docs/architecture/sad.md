# Software Architecture Document (SAD)

## 1. Introduction
This document describes the architecture of the Islamic Digital Citadel.

## 2. Architectural Representation
We use the **C4 Model** (Context, Containers, Components, Code) for visualization.

### System Context
-   **User**: Scholar or Student.
-   **System**: Islamic Digital Citadel (IDC).
-   **External Systems**: Quran API (e.g., quran.com), Hadith API.

## 3. Container View
```mermaid
graph TD
    User[User (Browser)] -->|HTTPS| WebApp[Web App (SolidJS)]
    WebApp -->|JSON/REST| API[Backend API (Rust/Axum)]
    API -->|SurrealQL| DB[(SurrealDB)]
```

## 4. Technology Decisions
| Component | Technology | Rationale |
| :--- | :--- | :--- |
| **Language** | **Rust** | Memory safety, performance, correctness. |
| **Database** | **SurrealDB** | Graph capabilities, flexibility, modern. |
| **Frontend** | **SolidJS** | High performance, small bundle size. |
| **Styling** | **TailwindCSS** | Utility-first, maintainable. |

## 5. Security Perspective
-   **Authentication**: JWT-based stateless auth.
-   **Authorization**: Role-Based Access Control (RBAC) enforced at the API layer.
-   **Data Protection**: TLS 1.3 for transit.
