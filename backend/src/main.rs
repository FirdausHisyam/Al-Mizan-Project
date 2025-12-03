use askama::Template;
use axum::{
    response::Html,
    routing::{get, post},
    Router,
};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

mod api;
mod domain;
mod repository;

use api::auth;
use repository::db::Database;

#[derive(Template)]
#[template(path = "index.html")]
struct IndexTemplate;

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
        }
        Err(e) => {
            tracing::error!("Failed to connect to SurrealDB: {}", e);
            std::process::exit(1);
        }
    };

    // Build our application
    let app = Router::new()
        .route("/", get(index_handler))
        .route("/auth/signup", post(auth::signup))
        .route("/auth/signin", post(auth::signin))
        .route("/api/v1/verify", post(api::v1::verify::verify_text))
        .route("/api/v1/graph", get(api::v1::graph::get_graph))
        .route("/api/v1/ai/expand", post(api::v1::ai::expand_node))
        .route("/graph", get(graph_handler))
        .route(
            "/favicon.ico",
            get(|| async { axum::http::StatusCode::NO_CONTENT }),
        )
        .with_state(db);

    // Run it
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    tracing::info!("listening on {}", listener.local_addr().unwrap());
    axum::serve(listener, app).await.unwrap();
}

async fn index_handler() -> impl axum::response::IntoResponse {
    let template = IndexTemplate;
    Html(template.render().unwrap())
}

#[derive(Template)]
#[template(path = "graph.html")]
struct GraphTemplate;

async fn graph_handler() -> impl axum::response::IntoResponse {
    let template = GraphTemplate;
    Html(template.render().unwrap())
}
