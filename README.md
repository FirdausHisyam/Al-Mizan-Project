# Al-Mizan: Semantic Knowledge Graph Framework

Al-Mizan is a research-driven backend infrastructure designed to address "Epistemological Incongruence" in Islamic digital resources. It shifts the paradigm from linear, keyword-based search to **Graph-based Semantic Traversal**, allowing for the preservation of complex theological relationships (Isnad, Tafsir, Istinbat).

## 🏗 System Architecture

The system operates on a Service-Oriented Architecture (SOA):

* **Core API (`almizan-core`)**: A high-performance Rust (Axum) server that exposes the Knowledge Graph via RESTful endpoints.
* **Graph Engine (`almizan-db`)**: SurrealDB instance storing the Ontology (Nodes & Edges).
* **Data Pipeline (`almizan-etl`)**: Python scripts for ingesting raw text from Tanzil and generating semantic edges via NLP.

## Status

* **Phase 1 (Foundation):** 🚧 **IN PROGRESS (Data Verified)**
  * [x] Core Knowledge Graph (Quran, Hadith, Roots)
  * [x] ETL Pipeline (Python -> SurrealDB)
  * [x] Basic API (Rust/Axum)

* **Phase 2 (Cyborg Isnad):** 🚧 **UP NEXT**
  * [ ] OCR & AI Text Extraction
  * [ ] Human Verification Interface
* **Phase 3 (Analysis):** 📅 **PLANNED**

## 🚀 Quick Start

### 1. Start Infrastructure

```bash
docker-compose up -d
```

### 2. Ingest Data (Verified Pipeline)

The Phase 1 data ingestion is fully automated.

```bash
# 1. Download Sources (Tanzil & Nawawi)
python3 almizan-etl/download_sources.py

# 2. Transform & Generate SurQL
# (Generates output/ingest.surql, output/morphology.surql, etc.)
python3 almizan-etl/transform_tanzil.py
python3 almizan-etl/transform_hadith.py
python3 almizan-etl/transform_morphology.py

# 3. Import to SurrealDB
surreal import --conn http://localhost:8000 -u root -p root --ns idc --db main almizan-etl/output/ingest.surql
surreal import --conn http://localhost:8000 -u root -p root --ns idc --db main almizan-etl/output/hadith_collections.surql
surreal import --conn http://localhost:8000 -u root -p root --ns idc --db main almizan-etl/output/morphology.surql
```

*Note: `transform_tanzil.py` automatically includes Nawawi 40 in `ingest.surql`.*

### 3. Run Backend

```bash
cd almizan-core
cargo run
```

API available at: `http://localhost:3000`

### 3. Access the Dashboard

* **UI**: `http://localhost:8080`
* **API Docs**: `http://localhost:3000/docs`

### 4. API Examples

```bash
# Get a Quran verse
curl http://localhost:3000/api/v1/verse/1/1

# Get Bukhari hadith
curl http://localhost:3000/api/v1/hadith/bukhari/1

# Get Nawawi hadith (note: URL encode spaces with %20)
curl "http://localhost:3000/api/v1/hadith/Nawawi%2040/1"

# Analyze a contract for Shariah compliance
curl -X POST http://localhost:3000/api/v1/enterprise/analyze_contract \
  -H "Content-Type: application/json" \
  -d '{"contract_type": "Murabaha", "rate": "fixed", "late_fee": "fixed_admin_fee"}'
```

> **Note:** Collection names with spaces (e.g., "Nawawi 40") must be URL-encoded.
>
## 📚 Documentation Index

* **[Architecture Overview](docs/ARCHITECTURE.md)**: High-level C4 diagrams and system boundaries.
* **[Ontology Specification](docs/specs/ONTOLOGY_SPEC.md)**: Definitions of Thabit (Immutable) and Zanni (Mutable) node types.
* **[Decision Logs (ADR)](docs/adr/)**: Engineering trade-offs and technology choices.

## 🛠 Tech Stack Justification

| Component | Technology | Why? |
| :--- | :--- | :--- |
| **Backend** | Rust (Axum) | Type safety, zero-cost abstractions, and concurrency for heavy graph queries. |
| **Database** | SurrealDB | Native graph support without the complexity of Neo4j; handles N:M relations efficiently. |
| **ETL** | Python | Rich ecosystem for NLP (LangChain) and data cleaning (Pandas). |

## 🧪 Research Hypothesis

This project validates the hypothesis that **Graph Models** offer superior query performance ($O(1)$) compared to **Relational Models** ($O(N^2)$) when traversing recursive Islamic genealogical structures (Isnad).

---

*Submitted as partial fulfillment for CSCI 4401 (FYP 1) at IIUM.*
