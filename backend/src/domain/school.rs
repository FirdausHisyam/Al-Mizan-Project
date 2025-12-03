use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, PartialEq, Eq)]
pub enum School {
    Shafi,
    Hanafi,
    Maliki,
    Hanbali,
    Jafari,
    Zaydi,
    Ibadi,
    Zahiri,
    Unknown,
}

impl ToString for School {
    fn to_string(&self) -> String {
        match self {
            School::Shafi => "Shafi'i".to_string(),
            School::Hanafi => "Hanafi".to_string(),
            School::Maliki => "Maliki".to_string(),
            School::Hanbali => "Hanbali".to_string(),
            School::Jafari => "Ja'fari".to_string(),
            School::Zaydi => "Zaydi".to_string(),
            School::Ibadi => "Ibadi".to_string(),
            School::Zahiri => "Zahiri".to_string(),
            School::Unknown => "Unknown".to_string(),
        }
    }
}
