use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "lowercase")]
pub enum Strictness {
    Strict,
    Permissive,
}

impl Default for Strictness {
    fn default() -> Self {
        Self::Strict
    }
}

impl Strictness {
    pub fn from_str(s: &str) -> Self {
        match s.to_lowercase().as_str() {
            "loose" | "permissive" => Self::Permissive,
            _ => Self::Strict,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "lowercase")]
pub enum StrictnessLevel {
    Basic,    // Retail
    Standard, // SME (Default)
    High,     // Corporate
    Extreme,  // Sovereign
}

impl Default for StrictnessLevel {
    fn default() -> Self {
        Self::Standard
    }
}

pub struct Logger;

impl Logger {
    pub fn log_audit(topic: &str, strictness: &Strictness) {
        if *strictness == Strictness::Permissive {
            println!(
                "AUDIT LOG: Client requested PERMISSIVE strictness for topic '{}'. Liability Waiver Active. Time: {}",
                topic,
                chrono::Utc::now().to_rfc3339()
            );
        }
    }

    pub fn log_commercial_audit(topic: &str, level: &StrictnessLevel) {
        println!(
            "COMMERCIAL AUDIT: Topic '{}' accessed with level '{:?}'. Time: {}",
            topic,
            level,
            chrono::Utc::now().to_rfc3339()
        );
    }
}
