use crate::domain::error::app_error::AppError;
use argon2::{
    Argon2,
    password_hash::{PasswordHash, PasswordHasher, PasswordVerifier, SaltString, rand_core::OsRng},
};
pub struct PasswordService;

impl PasswordService {
    pub fn hash(&self, password: &str) -> Result<String, AppError> {
        let salt = SaltString::generate(&mut OsRng);
        let argon2 = Argon2::default();
        let hash = argon2
            .hash_password(password.as_bytes(), &salt)
            .map_err(|_e| AppError::Unknown)?
            .to_string();
        Ok(hash)
    }
    pub fn verify(&self, password: &str, hashed_password: &str) -> Result<bool, AppError> {
        let parsed_hash = PasswordHash::new(hashed_password).map_err(|_e| AppError::Unknown)?;
        let result = Argon2::default()
            .verify_password(password.as_bytes(), &parsed_hash)
            .is_ok();
        Ok(result)
    }
}

#[cfg(test)]
mod tests {
    use super::PasswordService;
    #[test]
    fn test_hash() {
        let password_service = PasswordService;
        let password = "my_secure_password";
        let hashed_password = password_service.hash(password).unwrap();
        assert!(!hashed_password.is_empty());
    }

    #[test]
    fn test_verify() {
        let password_service = PasswordService;
        let password = "my_secure_password";
        let hashed_password = password_service.hash(password).unwrap();
        let is_valid = password_service.verify(password, &hashed_password).unwrap();
        assert!(is_valid);
    }
}
