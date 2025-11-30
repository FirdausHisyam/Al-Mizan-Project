# Al-Mizan Project

**A Tawhidic Knowledge Graph Framework for the Unification of Islamic Digital Ecosystem**

The **Al-Mizan Project** is a cutting-edge software initiative designed to map, analyze, and visualize the complex relationships of abrogation (Naskh) within the Quran and Hadith. Built with a focus on "PhD-level research" rigor, security, and modern engineering practices, it aims to solve the epistemological fragmentation in the current Islamic digital ecosystem.

## 🏗 Architecture

The project follows a **Clean Architecture** (Onion/Hexagonal) pattern, ensuring separation of concerns and testability.

### Tech Stack

* **Backend**: Rust (Axum Framework) - chosen for memory safety and performance.
* **Database**: SurrealDB - a multi-model database for complex graph relationships.
* **Frontend**: SolidJS + TypeScript (Vite) - for a reactive, high-performance UI.
* **Authentication**: Argon2 hashing + JWT (JSON Web Tokens).
* **Visualization**: Cytoscape.js - for interactive graph visualization of verses.

## 🚀 Getting Started

### Prerequisites

* **Rust**: `rustup` (stable toolchain)
* **Node.js**: v18+
* **SurrealDB**: Installed and running

### 1. Database Setup

Start SurrealDB in memory mode for development:

```bash
surreal start --log debug --user root --pass root memory
```

Import the initial schema:

```bash
surreal import --conn http://localhost:8000 --user root --pass root --namespace idc --database main database/schema/initial_schema.surql
```

### 2. Backend Setup

Navigate to the backend directory and run the server:

```bash
cd backend
cargo run
```

The API will be available at `http://localhost:3000`.

### 3. Frontend Setup

Navigate to the frontend directory, install dependencies, and start the dev server:

```bash
cd frontend
npm install
npm run dev
```

The application will be available at `http://localhost:5173`.

## 📂 Project Structure

* `backend/`: Rust API source code (Domain, API, Repository layers).
* `frontend/`: SolidJS application source code.
* `database/`: SurrealDB schema definitions.
* `docs/`: Architecture Decision Records (ADRs), Research Notes, and Specifications.

## 🛡 Security

* **Zero Trust**: Strict validation at every layer.
* **Type Safety**: End-to-end type safety with Rust and TypeScript.
* **Secure Auth**: Industry-standard Argon2 hashing and JWT.

## 📜 License

Private Research Project.
