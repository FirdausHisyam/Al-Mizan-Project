# ADR 0005: Public API Security (Read-Only)

Status: Accepted

Date: 2026-01-02

Deciders: Ammar Qasiem (System Architect)

## Context and Problem Statement

The Al-Mizan API will be publicly accessible for researchers. However, allowing public `POST`/`PUT` requests opens the door to **"Theological Data Injection"** (e.g., malicious actors inserting fake Hadiths or extremist interpretations). Standard SQL injection protections are insufficient; we need semantic protection.

## Decision Drivers

* **Trust**: The API is an authoritative source. It cannot host user-generated content directly.
* **Security**: Prevention of malicious writes.
* **Simplicity**: Reducing the challenge of moderation.

## Decision Outcome

We chose to make the Public API **Strictly Read-Only (GET only)**.

### Implementation

1. **Axum Router**: The public router (`/api/v1`) will only register `get` handlers.
2. **Database User**: The SurrealDB user for the API will have `SELECT` permissions only.
3. **Write Access**: Reserved solely for the `admin` user, accessible only via the internal VPN/Docker network (for the Python ETL pipeline).

## Consequences

* **Positive**: Zero risk of public data defacement. "Fitna Defense" enabled.
* **Negative**: Users cannot contribute corrections directly via the API.
* **Mitigation**: We will implement a "Pull Request" model where researchers submit corrections via GitHub Issues, which are then manually verified and ingested by the Admin ETL pipeline.
