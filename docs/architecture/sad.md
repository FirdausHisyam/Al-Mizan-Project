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
    subgraph "Bank's Infrastructure (On-Prem)"
        User[User (Browser)] -->|HTTPS| Node[Al-Mizan Node (Docker)]
        Node -->|Local Query| LocalDB[(Local SurrealDB)]
    end

    subgraph "Al-Mizan Cloud (The Citadel)"
        Waqf[Waqf Network (P2P)] -->|Sync (Data)| Node
        Corp[License Server] -->|Verify Key (Logic)| Node
    end
```

## 4. Technology Decisions

| Component | Technology | Rationale |
| :--- | :--- | :--- |
| **Language** | **Rust** | Memory safety, performance, correctness. |
| **Database** | **SurrealDB** | Graph capabilities, flexibility, modern. |
| **Frontend** | **HTMX + Askama** | Simplicity, "No-Build", server-side rendering. |
| **Styling** | **Vanilla CSS** | Full control, Glassmorphism, no build steps. |
| **AI** | **None (Generative)** | **PURGED**. AI is restricted to search/syntax parsing only. No truth generation. |

## 5. Security Perspective

- **Authentication**: JWT-based stateless auth.
- **Authorization**: Role-Based Access Control (RBAC) enforced at the API layer.
- **Data Protection**: TLS 1.3 for transit.
