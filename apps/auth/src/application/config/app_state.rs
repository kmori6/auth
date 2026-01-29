use std::sync::Arc;

use crate::domain::service::authorization_service::AuthorizationService;
use crate::domain::service::user_service::UserService;
use crate::infrastructure::repository::sqlx_user_repository::SqlxUserRepository;

pub struct AppState {
    pub user_service: Arc<UserService<SqlxUserRepository>>,
    pub authorization_service: Arc<AuthorizationService<SqlxUserRepository>>,
}
