use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Serialize, Deserialize)]
pub struct Claims {
    pub exp: i64,    // Expiration time (as UTC timestamp)
    pub iat: i64,    // Issued at (as UTC timestamp)
    pub sub: String, // Subject (whom token refers to)
}

#[derive(Debug, Serialize)]
pub struct Jwt {
    pub user_id: Uuid,
    pub token: String,
    pub expiration_seconds: i64,
}
