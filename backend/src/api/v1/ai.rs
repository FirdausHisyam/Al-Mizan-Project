use axum::{response::IntoResponse, Json};
use serde::{Deserialize, Serialize};
use std::env;

#[derive(Deserialize)]
pub struct ExpandRequest {
    pub node_id: String,
    pub node_label: String,
    pub node_type: String,
}

#[derive(Serialize, Deserialize)]
struct GeminiResponse {
    candidates: Vec<Candidate>,
}

#[derive(Serialize, Deserialize)]
struct Candidate {
    content: Content,
}

#[derive(Serialize, Deserialize)]
struct Content {
    parts: Vec<Part>,
}

#[derive(Serialize, Deserialize)]
struct Part {
    text: String,
}

#[derive(Serialize, Deserialize)]
struct GraphResponse {
    nodes: Vec<GraphNode>,
    edges: Vec<GraphEdge>,
}

#[derive(Serialize, Deserialize)]
struct GraphNode {
    data: NodeData,
}

#[derive(Serialize, Deserialize)]
struct NodeData {
    id: String,
    label: String,
    r#type: String,
}

#[derive(Serialize, Deserialize)]
struct GraphEdge {
    data: EdgeData,
}

#[derive(Serialize, Deserialize)]
struct EdgeData {
    id: String,
    source: String,
    target: String,
    label: String,
}

pub async fn expand_node(Json(payload): Json<ExpandRequest>) -> impl IntoResponse {
    let api_key = env::var("GEMINI_API_KEY").unwrap_or_default();

    if api_key.is_empty() {
        tracing::warn!("GEMINI_API_KEY is missing! Using fallback mock data.");
        // Fallback mock response if no key
        return Json(GraphResponse {
            nodes: vec![GraphNode {
                data: NodeData {
                    id: format!("{}_child", payload.node_id),
                    label: "AI Generated Node".into(),
                    r#type: "scholar".into(),
                },
            }],
            edges: vec![GraphEdge {
                data: EdgeData {
                    id: format!("{}_edge", payload.node_id),
                    source: payload.node_id.clone(),
                    target: format!("{}_child", payload.node_id),
                    label: "related".into(),
                },
            }],
        });
    }

    // SECURITY: Basic sanitization to prevent massive prompt injection payloads.
    // See SECURITY.md for full threat model.
    let safe_label = payload.node_label.chars().take(100).collect::<String>();
    let safe_type = payload.node_type.chars().take(50).collect::<String>();

    let prompt = format!(
        "Given the Islamic concept/text '{}' (Type: {}, ID: '{}'), generate 3 related nodes (Scholars, Verses, or Hadiths) and their relationships. Ensure the knowledge graph remains rooted in Tawhid (Oneness of God). Return ONLY valid JSON. Do not include markdown formatting. Example structure: {{ \"nodes\": [{{ \"data\": {{ \"id\": \"unique_id_1\", \"label\": \"Name\", \"type\": \"scholar\" }} }}], \"edges\": [{{ \"data\": {{ \"id\": \"edge_1\", \"source\": \"{}\", \"target\": \"unique_id_1\", \"label\": \"relationship\" }} }}] }}",
        safe_label, safe_type, payload.node_id, payload.node_id
    );

    let client = reqwest::Client::new();
    let res = client
        .post(format!("https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-latest:generateContent?key={}", api_key))
        .json(&serde_json::json!({
            "contents": [{
                "parts": [{ "text": prompt }]
            }]
        }))
        .send()
        .await;

    match res {
        Ok(response) => {
            let status = response.status();
            let text = response.text().await.unwrap_or_default();
            tracing::info!("Gemini API Status: {}", status);
            tracing::debug!("Gemini Raw Response: {}", text);

            if !status.is_success() {
                tracing::error!("Gemini API Error: {}", text);
                return Json(GraphResponse {
                    nodes: vec![],
                    edges: vec![],
                });
            }

            if let Ok(gemini_data) = serde_json::from_str::<GeminiResponse>(&text) {
                if let Some(candidate) = gemini_data.candidates.first() {
                    if let Some(part) = candidate.content.parts.first() {
                        let clean_json = part
                            .text
                            .replace("```json", "")
                            .replace("```", "")
                            .trim()
                            .to_string();
                        tracing::info!("Cleaned JSON: {}", clean_json);
                        match serde_json::from_str::<GraphResponse>(&clean_json) {
                            Ok(graph_data) => return Json(graph_data),
                            Err(e) => tracing::error!(
                                "Failed to parse GraphResponse: {} | JSON: {}",
                                e,
                                clean_json
                            ),
                        }
                    }
                }
            } else {
                tracing::error!("Failed to parse GeminiResponse");
            }
        }
        Err(e) => tracing::error!("Reqwest Error: {}", e),
    }

    // Fallback error response
    Json(GraphResponse {
        nodes: vec![],
        edges: vec![],
    })
}
