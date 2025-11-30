# 3. Project Management: Agile Scrum & DDD

Date: 2025-11-26

## Status

Accepted

## Context

The project is an academic research initiative (FYP/PhD level) but executed with commercial rigor. This requires balancing **exploratory research** (uncertain requirements) with **engineering discipline** (predictable delivery).

## Decision

We will combine **Agile Scrum** with **Domain-Driven Design (DDD)**.

### Methodology: Agile Scrum
*   **Sprints**: 2-week iterations.
*   **Artifacts**:
    *   **Product Backlog**: Prioritized list of features/research goals.
    *   **Sprint Backlog**: Tasks for the current iteration.
    *   **Increment**: Working software at the end of every sprint.
*   **Roles**:
    *   **Product Owner**: (User/Supervisor) Defines "what" to build.
    *   **Development Team**: (Agent/User) Defines "how" to build.
    *   **Scrum Master**: (Agent) Facilitates process.

### Design Philosophy: Domain-Driven Design (DDD)
*   **Ubiquitous Language**: We will use strict terminology (e.g., *Naskh*, *Mansukh*, *Nasikh*) in both code and conversation.
*   **Bounded Contexts**:
    *   **Text Context**: Handling Quran/Hadith text integrity.
    *   **Abrogation Context**: Handling the logic of abrogation relationships.
    *   **Identity Context**: Handling users and scholars.

## Consequences

### Positive
*   **Adaptability**: Agile allows us to pivot based on research findings.
*   **Alignment**: DDD ensures the software model matches the mental model of Islamic scholars.
*   **Rigor**: Defined processes prevent "spaghetti code" and scope creep.

### Negative
*   **Overhead**: Requires maintaining backlog and documentation.
