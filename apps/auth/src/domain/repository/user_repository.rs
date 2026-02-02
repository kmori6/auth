use crate::domain::error::app_error::AppError;
use crate::domain::model::user::User;
use uuid::Uuid;

#[cfg_attr(test, mockall::automock)]
pub trait UserRepository {
    async fn create_user(&self, user: &User) -> Result<(), AppError>;
    async fn find_user_by_email(&self, email: &str) -> Result<Option<User>, AppError>;
    async fn find_user_by_id(&self, id: &Uuid) -> Result<Option<User>, AppError>;
}
