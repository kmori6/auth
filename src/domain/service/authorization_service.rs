use crate::domain::error::app_error::AppError;
use crate::domain::model::jwt::Jwt;
use crate::domain::model::user::User;
use crate::domain::repository::user_repository::UserRepository;
use crate::domain::service::jwt_service::JwtService;
use crate::domain::service::password_service::PasswordService;
use std::sync::Arc;
use uuid::Uuid;

pub struct AuthorizationService<T: UserRepository> {
    password_service: Arc<PasswordService>,
    jwt_service: Arc<JwtService>,
    user_repository: Arc<T>,
}

impl<T: UserRepository> AuthorizationService<T> {
    pub fn new(
        password_service: Arc<PasswordService>,
        jwt_service: Arc<JwtService>,
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

    pub async fn verify_token(&self, token: &str) -> Result<User, AppError> {
        let claims = self.jwt_service.verify_token(token)?;
        let user_id = Uuid::parse_str(&claims.sub).map_err(|_| AppError::Unknown)?;
        let result = self.user_repository.find_user_by_id(&user_id).await?;
        match result {
            Some(user) => Ok(user),
            None => Err(AppError::Unknown),
        }
    }
}
