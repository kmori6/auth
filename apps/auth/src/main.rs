use crate::application::config::app_state::AppState;
use crate::application::handler::get_user::get_user;
use crate::application::handler::healthcheck::healthcheck;
use crate::application::handler::login::login;
use crate::application::handler::register_user::register_user;
use crate::domain::service::authorization_service::AuthorizationService;
use crate::domain::service::jwt_service::JwtService;
use crate::domain::service::password_service::PasswordService;
use crate::domain::service::user_service::UserService;
use crate::infrastructure::repository::sqlx_pool::SqlxPool;
use crate::infrastructure::repository::sqlx_user_repository::SqlxUserRepository;
use axum::{
    Router,
    routing::{get, post},
};
use dotenvy::dotenv;
use http::Method;
use std::sync::Arc;
use tower_http::cors::{Any, CorsLayer};
mod application;
mod domain;
mod infrastructure;

#[tokio::main]
async fn main() {
    // initialize tracing
    tracing_subscriber::fmt::init();

    dotenv().ok();

    let database_url = std::env::var("POSTGRES_ENDPOINT_URL")
        .expect("POSTGRES_ENDPOINT_URL must be set in .env or environment");
    let jwt_private_key = std::env::var("JWT_PRIVATE_KEY")
        .expect("JWT_PRIVATE_KEY must be set in .env or environment");
    let jwt_expiration_seconds = 60; // 1 minutes

    let sqlx_pool = SqlxPool::new(&database_url).await;
    let user_repository = SqlxUserRepository {
        sqlx_pool: sqlx_pool.clone(),
    };
    let user_repository_for_auth = SqlxUserRepository { sqlx_pool };

    let password_service = Arc::new(PasswordService);
    let jwt_service = Arc::new(JwtService::new(jwt_private_key, jwt_expiration_seconds));
    let user_service = UserService::new(password_service.clone(), Arc::new(user_repository));
    let authorization_service = AuthorizationService::new(
        password_service,
        jwt_service,
        Arc::new(user_repository_for_auth),
    );

    let app_state = Arc::new(AppState {
        user_service: Arc::new(user_service),
        authorization_service: Arc::new(authorization_service),
    });

    let cors = CorsLayer::new()
        .allow_methods([Method::GET, Method::POST])
        .allow_origin(Any)
        .allow_headers(Any);

    // build our application with a route
    let app = Router::new()
        .route("/healthcheck", get(healthcheck))
        .route("/register", post(register_user))
        .route("/login", post(login))
        .route("/me", get(get_user))
        .with_state(app_state)
        .layer(cors);

    // run our app with hyper, listening globally on port 3000
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    let _ = axum::serve(listener, app).await;
}
