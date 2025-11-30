use surrealdb::engine::remote::ws::{Client, Ws};
use surrealdb::opt::auth::Root;
use surrealdb::Surreal;
use std::sync::Arc;

#[derive(Clone)]
pub struct Database {
    pub client: Arc<Surreal<Client>>,
}

impl Database {
    pub async fn init() -> Result<Self, Box<dyn std::error::Error>> {
        let client = Surreal::new::<Ws>("127.0.0.1:8000").await?;
        
        client.signin(Root {
            username: "root",
            password: "root",
        }).await?;
        
        client.use_ns("idc").use_db("main").await?;
        
        Ok(Self {
            client: Arc::new(client),
        })
    }
}
