use std::sync::Arc;

use crate::domain::repository::user_repository::UserRepository;
use crate::domain::service::authorization_service::AuthorizationService;
use crate::domain::service::user_service::UserService;
use crate::infrastructure::repository::sqlx_user_repository::SqlxUserRepository;

pub struct AppState<T: UserRepository = SqlxUserRepository> {
    pub user_service: Arc<UserService<T>>,
    pub authorization_service: Arc<AuthorizationService<T>>,
}
