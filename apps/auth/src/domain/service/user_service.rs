use crate::domain::error::app_error::AppError;
use crate::domain::model::user::User;
use crate::domain::repository::user_repository::UserRepository;
use crate::domain::service::password_service::PasswordService;
use chrono::Utc;
use std::sync::Arc;
use uuid::Uuid;

pub struct UserService<T: UserRepository> {
    pub password_service: Arc<PasswordService>,
    pub user_repository: Arc<T>,
}

impl<T: UserRepository> UserService<T> {
    pub fn new(password_service: Arc<PasswordService>, user_repository: Arc<T>) -> Self {
        UserService {
            password_service,
            user_repository,
        }
    }

    pub async fn register_user(&self, email: &str, password: &str) -> Result<User, AppError> {
        let hashed_password = self.password_service.hash(password)?;

        let user = User {
            id: Uuid::new_v4(),
            email: email.to_string(),
            hashed_password,
            created_at: Utc::now(),
        };

        self.user_repository.create_user(&user).await?;

        Ok(user)
    }

    pub async fn get_user_by_id(&self, user_id: Uuid) -> Result<Option<User>, AppError> {
        self.user_repository.find_user_by_id(&user_id).await
    }
}
