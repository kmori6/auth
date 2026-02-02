use crate::domain::error::app_error::AppError;
use crate::domain::model::jwt::Claims;
use chrono::Utc;
use jsonwebtoken::{Algorithm, EncodingKey, Header, encode};

pub struct JwtService {
    private_rsa_pem_key: String,
    expiration_seconds: i64,
}

impl JwtService {
    pub fn new(private_rsa_pem_key: String, expiration_seconds: i64) -> Self {
        JwtService {
            private_rsa_pem_key,
            expiration_seconds,
        }
    }

    pub fn get_expiration_seconds(&self) -> i64 {
        self.expiration_seconds
    }

    pub fn generate_token(&self, user_id: &str) -> Result<String, AppError> {
        let claims = Claims {
            exp: (Utc::now() + chrono::Duration::seconds(self.expiration_seconds)).timestamp(),
            iat: Utc::now().timestamp(),
            sub: user_id.to_string(),
        };
        let encoding_key = EncodingKey::from_rsa_pem(self.private_rsa_pem_key.as_bytes())
            .map_err(|_| AppError::Unknown)?;
        encode(&Header::new(Algorithm::RS256), &claims, &encoding_key)
            .map_err(|_| AppError::Unknown)
    }
}
