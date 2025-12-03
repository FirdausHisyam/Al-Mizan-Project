use std::sync::Arc;
use surrealdb::engine::remote::ws::{Client, Ws};
use surrealdb::opt::auth::Root;
use surrealdb::Surreal;

#[derive(Clone)]
pub struct Database {
    pub client: Arc<Surreal<Client>>,
}

impl Database {
    pub async fn init() -> Result<Self, Box<dyn std::error::Error>> {
        let client = Surreal::new::<Ws>("127.0.0.1:8000").await?;

        client
            .signin(Root {
                username: "root",
                password: "root",
            })
            .await?;

        client.use_ns("idc").use_db("main").await?;

        let db = Self {
            client: Arc::new(client),
        };

        db.seed().await?;

        Ok(db)
    }

    pub async fn seed(&self) -> Result<(), Box<dyn std::error::Error>> {
        // Always re-seed for now to enforce the new structure
        tracing::info!("Re-seeding database with Tawhidic structure...");

        self.client
            .query(
                "
            BEGIN TRANSACTION;
            DELETE node;
            DELETE edge;

            CREATE node:root SET label = \"Allah (SWT)\", type = \"divine\";
            
            CREATE node:v1 SET label = \"Verse 2:106\", type = \"verse\";
            CREATE node:v2 SET label = \"Verse 9:5\", type = \"verse\";
            CREATE node:s1 SET label = \"Imam Shafi'i\", type = \"scholar\";
            CREATE node:h1 SET label = \"Hadith Bukhari 123\", type = \"hadith\";
            
            RELATE node:root->edge->node:v1 SET label = \"revealed\";
            RELATE node:root->edge->node:v2 SET label = \"revealed\";
            
            RELATE node:v2->edge->node:v1 SET label = \"abrogates\";
            RELATE node:s1->edge->node:v2 SET label = \"confirms\";
            RELATE node:h1->edge->node:v2 SET label = \"supports\";
            COMMIT TRANSACTION;
        ",
            )
            .await?;

        Ok(())
    }
}
