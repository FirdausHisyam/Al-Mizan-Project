use askama::Template;
use axum::{extract::Form, response::Html};
use serde::{Deserialize, Serialize};

#[derive(Deserialize)]
pub struct EvidenceRequest {
    pub _text: String,
    pub lens: Option<String>,
}

#[derive(Serialize, Clone)]
pub struct OpinionNode {
    pub scholar: String,
    pub verdict: String,
    pub school: String,
    pub rank: u8,
    pub weight: f32,
}

#[derive(Template)]
#[template(path = "evidence_result.html")]
struct EvidenceResultTemplate {
    opinions: Vec<OpinionNode>,
    lens_applied: Option<String>,
}

pub async fn get_evidence(
    Form(payload): Form<EvidenceRequest>,
) -> impl axum::response::IntoResponse {
    // Mock implementation for MVP - demonstrating the "Topography" model
    let lens = payload.lens.clone();

    let opinions = match lens.as_deref() {
        Some("mahdi_override") => vec![
            // The Stabilization Protocol: Global Override
            OpinionNode {
                scholar: "Executive Authority".to_string(),
                verdict: "Void".to_string(),
                school: "Unified".to_string(),
                rank: 0,
                weight: 1.0,
            },
            OpinionNode {
                scholar: "Imam Shafi'i".to_string(),
                verdict: "Abrogated".to_string(),
                school: "Shafi'i".to_string(),
                rank: 1,
                weight: 0.0,
            }, // Overridden
        ],
        Some("shafii_primary") => vec![OpinionNode {
            scholar: "Imam Shafi'i".to_string(),
            verdict: "Abrogated".to_string(),
            school: "Shafi'i".to_string(),
            rank: 1,
            weight: 1.0,
        }],
        Some("shafii_secondary") => vec![
            OpinionNode {
                scholar: "Imam Shafi'i".to_string(),
                verdict: "Abrogated".to_string(),
                school: "Shafi'i".to_string(),
                rank: 1,
                weight: 1.0,
            },
            OpinionNode {
                scholar: "Al-Ghazali".to_string(),
                verdict: "Specific".to_string(),
                school: "Shafi'i".to_string(),
                rank: 2,
                weight: 0.9,
            },
        ],
        _ => vec![
            OpinionNode {
                scholar: "Imam Shafi'i".to_string(),
                verdict: "Abrogated".to_string(),
                school: "Shafi'i".to_string(),
                rank: 1,
                weight: 1.0,
            },
            OpinionNode {
                scholar: "Imam Malik".to_string(),
                verdict: "General".to_string(),
                school: "Maliki".to_string(),
                rank: 1,
                weight: 1.0,
            },
            OpinionNode {
                scholar: "Imam Abu Hanifa".to_string(),
                verdict: "Not Abrogated".to_string(),
                school: "Hanafi".to_string(),
                rank: 1,
                weight: 1.0,
            },
        ],
    };

    let template = EvidenceResultTemplate {
        opinions,
        lens_applied: lens,
    };

    Html(template.render().unwrap())
}
