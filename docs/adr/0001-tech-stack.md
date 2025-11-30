# 1. Tech Stack Selection

Date: 2025-11-26

## Status

Accepted

## Context

The Islamic Digital Citadel project aims to visualize complex relationships (abrogations) in Islamic texts. The project has strict requirements for:
1.  **Security**: "Most secure" possible architecture.
2.  **Performance**: "Cutting edge" and "lightweight".
3.  **Correctness**: Handling sacred texts requires high data integrity.
4.  **Longevity**: Built like a "real company" with a long-term vision.

The initial proposal of a direct client-to-database connection was rejected due to security concerns (exposing DB directly, even with permissions, is risky for a high-assurance app).

## Decision

We will use the following technology stack:

### 1. Database: SurrealDB
*   **Type**: Multi-model (Graph + Relational + Document).
*   **Justification**:
    *   Native graph support is essential for the "Abrogation" network.
    *   Real-time capabilities (Live Queries) for future collaboration features.
    *   Strong typing and schema enforcement (`SCHEMAFULL`).
*   **Security Configuration**:
    *   Strict Mode (No guest access).
    *   Role-Based Access Control (RBAC) defined in schema.
    *   No direct public HTTP access; only accessible via the Backend API.

### 2. Backend API: Rust (Axum)
*   **Language**: Rust.
*   **Framework**: Axum.
*   **Justification**:
    *   **Memory Safety**: Rust's ownership model prevents common vulnerabilities (buffer overflows, null pointer dereferences).
    *   **Performance**: Compiles to native machine code; minimal runtime overhead.
    *   **Correctness**: Strong type system ensures logic errors are caught at compile time.
    *   **Ecosystem**: Axum is ergonomic, modular, and built on `tokio` (industry standard async runtime).

### 3. Frontend: Vite + SolidJS + TypeScript
*   **Framework**: SolidJS.
*   **Build Tool**: Vite.
*   **Justification**:
    *   **Performance**: SolidJS uses fine-grained reactivity (no Virtual DOM), resulting in consistently high performance for graph rendering.
    *   **Lightweight**: Extremely small bundle size compared to React/Angular.
    *   **Type Safety**: TypeScript integration is first-class.

### 4. Authentication: JWT + Argon2
*   **Mechanism**: Stateless JSON Web Tokens (JWT).
*   **Hashing**: Argon2id (OWASP recommended).
*   **Justification**: Standard, secure, and scalable.

## Consequences

### Positive
*   **High Assurance**: Rust + Strict Schema minimizes runtime errors and security flaws.
*   **Future Proof**: The stack is modern and capable of handling high loads.
*   **Developer Experience**: Strong typing across the full stack (Rust <-> SurrealDB <-> TypeScript) improves maintainability.

### Negative
*   **Learning Curve**: Rust has a steeper learning curve than Node.js/Python, potentially slowing initial velocity.
*   **Hiring**: Rust developers are harder to find than JS developers (though often higher quality).

## Compliance
*   **Security**: Aligns with OWASP Top 10 mitigation strategies.
*   **Academic**: Suitable for a PhD-level research project demonstrating novel engineering practices.
