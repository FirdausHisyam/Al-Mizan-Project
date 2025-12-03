# Software Architecture Document (SAD)

## 1. Introduction

This document describes the architecture of the Islamic Digital Citadel.

## 2. Architectural Representation

We use the **C4 Model** (Context, Containers, Components, Code) for visualization.

### System Context

- **User**: Scholar or Student.
- **System**: Islamic Digital Citadel (IDC).
- **External Systems**: Quran API (e.g., quran.com), Hadith API.

## 3. Container View

```mermaid
graph TD
    User[User (Browser)] -->|HTTPS| WebApp[Backend (Rust/Axum)]
    WebApp -->|HTML/HTMX| User
    WebApp -->|SurrealQL| DB[(SurrealDB)]
    WebApp -->|JSON| AI[Gemini AI]
```

## 4. Technology Decisions

| Component | Technology | Rationale |
| :--- | :--- | :--- |
| **Language** | **Rust** | Memory safety, performance, correctness. |
| **Database** | **SurrealDB** | Graph capabilities, flexibility, modern. |
| **Frontend** | **HTMX + Askama** | Simplicity, "No-Build", server-side rendering. |
| **Styling** | **Vanilla CSS** | Full control, Glassmorphism, no build steps. |
| **AI** | **Google Gemini** | **Temporary Placeholder**. Rapid prototyping only. To be replaced by self-hosted models. |

## 5. Security Perspective

- **Authentication**: JWT-based stateless auth.
- **Authorization**: Role-Based Access Control (RBAC) enforced at the API layer.
- **Data Protection**: TLS 1.3 for transit.
