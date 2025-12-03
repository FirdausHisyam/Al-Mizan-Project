# Al-Mizan Project

![Al-Mizan Banner](https://via.placeholder.com/1200x300?text=Al-Mizan+Project+Banner)

> **A Tawhidic Knowledge Graph Framework for the Unification of Islamic Digital Ecosystem**

[![Rust](https://img.shields.io/badge/Rust-1.75%2B-orange?logo=rust)](https://www.rust-lang.org/)
[![HTMX](https://img.shields.io/badge/HTMX-1.9-blue?logo=htmx)](https://htmx.org/)
[![SurrealDB](https://img.shields.io/badge/SurrealDB-1.0-purple?logo=surrealdb)](https://surrealdb.com/)
[![License](https://img.shields.io/badge/License-Private-red)](#license)
[![Status](https://img.shields.io/badge/Status-Active_Development-green)](#)

The **Al-Mizan Project** is a cutting-edge software initiative designed to map, analyze, and visualize the complex relationships of abrogation (Naskh) within the Quran and Hadith. Built with a focus on "PhD-level research" rigor, security, and modern engineering practices, it aims to solve the epistemological fragmentation in the current Islamic digital ecosystem.

---

## ✨ Features

- **Knowledge Graph Visualization**: Interactive exploration of Quranic verses and Hadith relationships using Cytoscape.js.
- **Advanced Search**: Semantic search capabilities powered by SurrealDB.
- **Scholarly Rigor**: Designed to support complex theological relationships and citations.
- **High Performance**: Backend built with Rust for speed and memory safety.
- **Reactive UI**: Modern frontend using SolidJS for a seamless user experience.

## 🏗 Architecture

The project follows a **Clean Architecture** (Onion/Hexagonal) pattern, ensuring separation of concerns and testability.

### Tech Stack

| Component | Technology | Description |
| :--- | :--- | :--- |
| **Backend** | [Rust](https://www.rust-lang.org/) (Axum) | Chosen for memory safety, concurrency, and performance. |
| **Database** | [SurrealDB](https://surrealdb.com/) | A multi-model database perfect for complex graph relationships. |
| **Frontend** | [HTMX](https://htmx.org/) | Server-side rendered HTML for a lightweight, no-build UI. |
| **Auth** | Argon2 + JWT | Industry-standard security for authentication. |
| **Viz** | [Cytoscape.js](https://js.cytoscape.org/) | Powerful graph theory (network) library for visualization. |

For more details, see [ARCHITECTURE.md](docs/ARCHITECTURE.md).

## 🚀 Getting Started

### Prerequisites

- **Rust**: `rustup` (stable toolchain)
- **SurrealDB**: Installed and running locally

### Installation

1. **Clone the repository**

    ```bash
    git clone https://github.com/FirdausHisyam/Islamic-Digital-Citadel.git
    cd Islamic-Digital-Citadel
    ```

2. **Database Setup**
    Start SurrealDB in memory mode for development:

    ```bash
    surreal start --log debug --user root --pass root memory
    ```

    Import the initial schema:

    ```bash
    surreal import --conn http://localhost:8000 --user root --pass root --namespace idc --database main database/schema/initial_schema.surql
    ```

3. **Backend Setup**

    ```bash
    cd backend
    cargo run
    ```

    The API will be available at `http://localhost:3000`.

## 🗺 Roadmap

For the detailed strategic roadmap, including the **"Cyborg" Isnad Pipeline**, please see [ROADMAP.md](ROADMAP.md).

## 🤝 Contributing

We welcome contributions! Please read our [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests.

## ⚖️ Governance: Algorithmic Shura

To mitigate the risk of a "Digital Dictator" or single point of failure, Al-Mizan employs an **Algorithmic Shura** consensus mechanism.

- **Consensus Threshold**: A ruling (Fatwa) only achieves "Canon" status (Weight 1.0) when it is cryptographically signed by **40 Verified Scholars**.
- **Decentralized Verification**: Truth is not determined by a central admin, but by the distributed consensus of the scholarly community.
- **Immutable Audit Trail**: Every signature is recorded on the graph, creating a transparent and tamper-proof history of consensus.

## 🛡 Security

- **Zero Trust**: Strict validation at every layer.
- **Type Safety**: End-to-end type safety with Rust and TypeScript.
- **Secure Auth**: Industry-standard Argon2 hashing and JWT.

## 📜 License

Private Research Project. All rights reserved.
