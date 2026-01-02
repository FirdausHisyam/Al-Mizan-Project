use crate::repository::db::Database;
use axum::{extract::State, response::IntoResponse, Json};
use serde::{Deserialize, Serialize};
use tracing::info;

#[derive(Serialize)]
pub struct GraphData {
    nodes: Vec<CytoscapeNode>,
    edges: Vec<CytoscapeEdge>,
}

#[derive(Serialize)]
struct CytoscapeNode {
    data: NodeData,
}

#[derive(Serialize)]
struct NodeData {
    id: String,
    label: String,
    #[serde(rename = "type")]
    node_type: String,
}

#[derive(Serialize)]
struct CytoscapeEdge {
    data: EdgeData,
}

#[derive(Serialize)]
struct EdgeData {
    id: String,
    source: String,
    target: String,
    label: String,
}

#[derive(Deserialize, Debug)]
struct DbVerse {
    id: surrealdb::sql::Thing,
    surah_number: i32,
    ayah_number: i32,
}

#[derive(Deserialize, Debug)]
struct DbRoot {
    id: surrealdb::sql::Thing,
    root_ar: Option<String>,
}

#[derive(Deserialize, Debug)]
struct DbEdge {
    id: surrealdb::sql::Thing,
    #[serde(rename = "in")]
    source: surrealdb::sql::Thing,
    #[serde(rename = "out")]
    target: surrealdb::sql::Thing,
}

/// GET /api/v1/graph
/// Returns a sample of the knowledge graph in Cytoscape format.
/// Limited to first 100 verses + their roots for performance.
pub async fn get_graph(State(db): State<Database>) -> impl IntoResponse {
    // 1. Get sample of verses
    let verses_sql = "SELECT id, surah_number, ayah_number FROM quran_verse LIMIT 50";
    let verses: Vec<DbVerse> = db
        .client
        .query(verses_sql)
        .await
        .and_then(|mut r| r.take(0))
        .unwrap_or_default();

    if verses.is_empty() {
        return Json(GraphData {
            nodes: vec![],
            edges: vec![],
        });
    }

    // 2. Extract Verse IDs for edge query
    let verse_ids: Vec<surrealdb::sql::Thing> = verses.iter().map(|v| v.id.clone()).collect();

    // 3. Get edges connected to these verses
    // We use a parameter for the IN clause or construct the query string manually if params are tricky with vec
    // SurrealDB Rust client passing Vec<Thing> as param works generally.
    let edges_sql = "SELECT id, in, out FROM has_root WHERE in IN $verse_ids";
    let edges: Vec<DbEdge> = db
        .client
        .query(edges_sql)
        .bind(("verse_ids", verse_ids)) // Bind the array of IDs
        .await
        .and_then(|mut r| r.take(0))
        .unwrap_or_default();

    // 4. Extract connected Root IDs
    let root_ids: Vec<surrealdb::sql::Thing> = edges.iter().map(|e| e.target.clone()).collect();

    // 5. Get these specific roots
    let roots: Vec<DbRoot> = if root_ids.is_empty() {
        Vec::new()
    } else {
        let roots_sql = "SELECT id, root_ar FROM root_word WHERE id IN $root_ids";
        db.client
            .query(roots_sql)
            .bind(("root_ids", root_ids)) // Bind the array of IDs
            .await
            .and_then(|mut r| r.take(0))
            .unwrap_or_default()
    };

    // 6. Build Cytoscape Data
    let mut nodes: Vec<CytoscapeNode> = Vec::new();
    let mut valid_node_ids = std::collections::HashSet::new();

    // Helper to sanitize Surreal IDs (remove ⟨ ⟩)
    let sanitize_id = |id: String| -> String { id.replace("⟨", "").replace("⟩", "") };

    // Add verse nodes
    for v in &verses {
        let id = sanitize_id(v.id.to_string());
        valid_node_ids.insert(id.clone());
        nodes.push(CytoscapeNode {
            data: NodeData {
                id,
                label: format!("{}:{}", v.surah_number, v.ayah_number),
                node_type: "verse".to_string(),
            },
        });
    }

    // Add root nodes
    for r in &roots {
        let id = sanitize_id(r.id.to_string());
        valid_node_ids.insert(id.clone());
        nodes.push(CytoscapeNode {
            data: NodeData {
                id,
                label: r.root_ar.clone().unwrap_or_else(|| "?".to_string()), // clone() needed as we access reference
                node_type: "root".to_string(),
            },
        });
    }

    // Add edges (filtered)
    let cyto_edges: Vec<CytoscapeEdge> = edges
        .into_iter()
        .map(|e| {
            let id = sanitize_id(e.id.to_string());
            let source = sanitize_id(e.source.to_string());
            let target = sanitize_id(e.target.to_string());
            (id, source, target)
        })
        .filter(|(_, source, target)| {
            valid_node_ids.contains(source) && valid_node_ids.contains(target)
        })
        .map(|(id, source, target)| CytoscapeEdge {
            data: EdgeData {
                id,
                source,
                target,
                label: "has_root".to_string(),
            },
        })
        .collect();

    info!(
        "GRAPH DEBUG: Verses: {}, Roots: {}, ValidNodes: {}, FinalEdges: {}",
        verses.len(),
        roots.len(),
        valid_node_ids.len(),
        cyto_edges.len()
    );

    Json(GraphData {
        nodes,
        edges: cyto_edges,
    })
}
