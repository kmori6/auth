use chrono::{DateTime, Utc};
use uuid::Uuid;

#[derive(Debug, sqlx::FromRow)]
pub struct User {
    pub id: Uuid,
    pub email: String,
    pub hashed_password: String,
    pub created_at: DateTime<Utc>,
}
