use axum::{routing::get, Router};
use std::net::SocketAddr;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

mod domain;
mod repository;
mod api;

use repository::db::Database;
use api::auth;
use axum::routing::post;

#[tokio::main]
async fn main() {
    // Initialize tracing
    tracing_subscriber::registry()
        .with(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "debug".into()),
        )
        .with(tracing_subscriber::fmt::layer())
        .init();

    tracing::info!("Initializing Islamic Digital Citadel Backend...");

    // Initialize Database
    let db = match Database::init().await {
        Ok(db) => {
            tracing::info!("Connected to SurrealDB successfully");
            db
        },
        Err(e) => {
            tracing::error!("Failed to connect to SurrealDB: {}", e);
            std::process::exit(1);
        }
    };

    // Build our application
    let app = Router::new()
        .route("/", get(root))
        .route("/auth/signup", post(auth::signup))
        .route("/auth/signin", post(auth::signin))
        .with_state(db);

    // Run it
    let addr = SocketAddr::from(([127, 0, 0, 1], 3000));
    tracing::info!("listening on {}", addr);
    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn root() -> &'static str {
    "Islamic Digital Citadel API is running!"
}
