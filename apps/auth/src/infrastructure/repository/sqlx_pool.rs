use sqlx::{Pool, Postgres, postgres::PgPoolOptions};

#[derive(Clone)]
pub struct SqlxPool {
    pub pool: Pool<Postgres>,
}

impl SqlxPool {
    pub async fn new(database_url: &str) -> Self {
        let pool = PgPoolOptions::new()
            .max_connections(5)
            .connect(database_url)
            .await
            .expect("Failed to create Postgres connection pool");
        Self { pool }
    }
}
