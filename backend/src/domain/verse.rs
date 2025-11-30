use serde::{Deserialize, Serialize};
use validator::Validate;
use surrealdb::sql::Thing;

#[derive(Debug, Serialize, Deserialize, Validate, Clone)]
pub struct Verse {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub id: Option<Thing>,
    
    #[validate(range(min = 1, max = 114))]
    pub surah_number: u8,
    
    #[validate(length(min = 1))]
    pub surah_name: String,
    
    #[validate(range(min = 1))]
    pub verse_number: u16,
    
    #[validate(length(min = 1))]
    pub text: String,
}

impl Verse {
    pub fn new(surah_number: u8, surah_name: String, verse_number: u16, text: String) -> Self {
        Self {
            id: None,
            surah_number,
            surah_name,
            verse_number,
            text,
        }
    }
}
