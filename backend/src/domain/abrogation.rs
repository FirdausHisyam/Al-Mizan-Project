use serde::{Deserialize, Serialize};
use surrealdb::sql::Thing;
use validator::Validate;

#[derive(Debug, Serialize, Deserialize, Validate, Clone)]
#[allow(dead_code)]
pub struct Abrogation {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub id: Option<Thing>,

    // The abrogating verse (Nasikh) - outgoing edge
    pub out: Thing,

    // The abrogated verse (Mansukh) - incoming edge
    pub r#in: Thing,

    #[validate(length(min = 1))]
    pub scholar: String,

    #[validate(length(min = 1))]
    pub proof_text: String,

    pub confidence_level: String,
}

#[allow(dead_code)]
impl Abrogation {
    pub fn new(
        out: Thing,
        r#in: Thing,
        scholar: String,
        proof_text: String,
        confidence_level: String,
    ) -> Self {
        Self {
            id: None,
            out,
            r#in,
            scholar,
            proof_text,
            confidence_level,
        }
    }
}
