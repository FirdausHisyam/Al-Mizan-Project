# 2. Architecture Pattern: Clean Architecture

Date: 2025-11-26

## Status

Accepted

## Context

To ensure the system is maintainable, testable, and independent of external frameworks (like the database or UI), we need a robust architectural pattern. The project aims for "PhD rigor" and "long-term vision", meaning the core business logic (Abrogation rules) must be preserved against technology shifts.

## Decision

We will adopt **Clean Architecture** (also known as Onion Architecture or Hexagonal Architecture).

### Layers
1.  **Domain Layer (Core)**:
    *   Entities (Verse, Scholar, Abrogation).
    *   Business Rules (e.g., "A verse cannot abrogate a verse revealed after it").
    *   *Dependencies*: None. Pure Rust code.
2.  **Application Layer (Use Cases)**:
    *   Orchestration of business logic (e.g., `FindAbrogatedVerses`, `ValidateAbrogationClaim`).
    *   Interfaces (Ports) for repositories and services.
    *   *Dependencies*: Domain Layer.
3.  **Infrastructure Layer (Adapters)**:
    *   Implementations of interfaces (e.g., `SurrealDbRepository`, `Argon2Hasher`).
    *   Database connections, external API calls.
    *   *Dependencies*: Application Layer.
4.  **Presentation Layer (Interface)**:
    *   API Endpoints (Axum handlers).
    *   DTOs (Data Transfer Objects).
    *   *Dependencies*: Application Layer.

## Consequences

### Positive
*   **Independence**: The core logic doesn't know about SurrealDB or HTTP. We can swap the DB or API framework without touching business rules.
*   **Testability**: We can unit test the Domain and Application layers in isolation using mocks.
*   **Clarity**: Clear separation of concerns makes the codebase easier to navigate.

### Negative
*   **Boilerplate**: Requires more files and mapping code (DTOs <-> Entities) than a simple MVC approach.
*   **Complexity**: Overkill for very simple CRUD apps, but justified here by the "high assurance" requirement.
