# Project Roadmap

This document outlines the strategic direction and milestones for the Al-Mizan Project.

## Timeline

```mermaid
gantt
    title Al-Mizan Project Roadmap
    dateFormat  YYYY-MM-DD
    section Phase 1: Foundation
    Core Graph Structure       :done,    des1, 2025-11-01, 2025-11-15
    Basic Visualization        :active,  des2, 2025-11-16, 2025-12-15
    Backend Setup              :done,    des3, 2025-11-01, 2025-11-10
    
    section Phase 2: Realignment (Current)
    Frontend Split (App/Admin) :         des4, 2025-12-01, 2025-12-31
    B2B API Design             :         des5, 2025-12-01, 2025-12-15
    
    section Phase 3: Data Ingestion
    Quran Corpus Import        :         des6, 2026-01-01, 2026-01-31
    Hadith Corpus Import       :         des7, 2026-02-01, 2026-02-28
    
    section Phase 4: Analysis
    Abrogation Detection Algo  :         des8, 2026-03-01, 2026-04-15
    
    section Phase 5: Public Launch
    Public Beta Launch         :         des9, 2026-05-01, 2026-05-01
```

## Milestones

### Q4 2025 - Foundation & Realignment

- [x] Establish Clean Architecture.
- [x] Set up SurrealDB schema.
- [ ] **Split Frontend**: Separate "Certainty Engine" and "Verification Console".
- [ ] **B2B API Strategy**: Design the "Credibility-as-a-Service" API.

### Q1 2026 - Data Richness

- [ ] Import full Uthmani Quran text.
- [ ] Import Kutub al-Sittah (Six major Hadith collections).

### Q2 2026 - Intelligence

- [ ] Implement graph traversal algorithms for Naskh chains.
- [ ] Release public API documentation.
