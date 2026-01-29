use crate::domain::error::app_error::AppError;
use crate::domain::model::jwt::Jwt;
use crate::domain::repository::user_repository::UserRepository;
use crate::domain::service::jwt_service::JWTService;
use crate::domain::service::password_service::PasswordService;
use std::sync::Arc;

pub struct AuthorizationService<T: UserRepository> {
    password_service: Arc<PasswordService>,
    jwt_service: Arc<JWTService>,
    user_repository: Arc<T>,
}

impl<T: UserRepository> AuthorizationService<T> {
    pub fn new(
        password_service: Arc<PasswordService>,
        jwt_service: Arc<JWTService>,
        user_repository: Arc<T>,
    ) -> Self {
        AuthorizationService {
            password_service,
            jwt_service,
            user_repository,
        }
    }

    pub async fn login(&self, email: &str, password: &str) -> Result<Jwt, AppError> {
        let user = self.user_repository.find_user_by_email(email).await?;
        if let Some(user) = user {
            let is_valid = self
                .password_service
                .verify(password, &user.hashed_password)?;

            if !is_valid {
                return Err(AppError::Unknown);
            }

            let token = self.jwt_service.generate_token(&user.id.to_string())?;

            let jwt = Jwt {
                user_id: user.id,
                token,
                expiration_seconds: self.jwt_service.get_expiration_seconds(),
            };
            return Ok(jwt);
        }

        Err(AppError::Unknown)
    }
}
