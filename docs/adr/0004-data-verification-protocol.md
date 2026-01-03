# ADR 0004: Tiered Data Verification Protocol

Status: Accepted

Date: 2026-01-02

Deciders: Ammar Qasiem (System Architect), Firdaus (Data Scientist)

## Context and Problem Statement

The Al-Mizan project deals with "Theological Data" (Quran, Hadith, Fiqh). Unlike typical big data projects where 99% accuracy is acceptable, here **100% accuracy is required** for the core immutable texts. A single misplaced vowel in the Quran changes the meaning, which is unacceptable for a "Fortress of Knowledge."

However, manually verifying millions of edges is impossible. We need a strategy to balance **Scale** vs **Trust**.

## Decision Drivers

* **Integrity**: Core texts (Quran) must be byte-perfect.
* **Scalability**: We cannot manually verify 1 million hadith edges.
* **Resource Constraints**: We are a two-person team (System Eng + Data Science).

## Considered Options

* **Option A: Full Automation (LLM)**: Let GPT-4 extract all edges. Fast, but high hallucination risk. Unacceptable for theology.
* **Option B: Full Manual Entry**: Manually type every node. 100% accurate, but zero scalability.
* **Option C: Tiered Hybrid (Cyborg)**: Automate the mass ingestion of text (Tier 1), but restrict semantic linking (Tier 2) to a manually verified subset.

## Decision Outcome

We chose **Option C: Tiered Hybrid Strategy**.

### The Protocol

1. **Tier 1 (Immutable Corpus)**:
    * **Scope**: Full Quran (6,236 Verses), Kutub Sittah (Hadith).
    * **Method**: Automated Python Scripts (`transform_tanzil.py`).
    * **Verification**: Checksum verification against trusted sources (Tanzil.net).
    * **Status**: **Global Ingestion Allowed**.

2. **Tier 2 (Semantic Graph)**:
    * **Scope**: Morphology (Roots), Cross-References.
    * **Method**: Heuristic Extraction + Human Audit.
    * **Verification**: The `verify_ingestion.py` script must pass 100% of constraints.
    * **Status**: Limited to verified subsets (e.g., Juz Amma).

## Consequences

* **Positive**: We guarantee that the "Word of God" (Quran text) is accurate while slowly growing the "Web of Knowledge" (Graph) safely.
* **Negative**: The graph will be sparse initially (many verses will have no edges until verified).
* **Mitigation**: The UI must clearly distinguish between "Verified Edges" (Solid Line) and "AI Suggestions" (Dotted Line/Hidden).
