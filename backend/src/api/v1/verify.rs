use askama::Template;
use axum::{extract::Form, response::Html};
use serde::Deserialize;

#[derive(Deserialize)]
pub struct VerifyRequest {
    pub _text: String,
}

#[derive(Template)]
#[template(path = "verify_result.html")]
struct VerifyResultTemplate {
    formatted_score: String,
    source_link: Option<String>,
    grading: String,
}

pub async fn verify_text(Form(_payload): Form<VerifyRequest>) -> impl axum::response::IntoResponse {
    // Mock implementation for MVP
    let template = VerifyResultTemplate {
        formatted_score: format!("{:.0}%", 0.95 * 100.0),
        source_link: Some("https://al-mizan.com/graph/node/123".to_string()),
        grading: "Sahih".to_string(),
    };

    Html(template.render().unwrap())
}
