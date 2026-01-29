use crate::application::config::app_state::AppState;
use crate::application::model::user::{UserRequest, UserResponse};
use axum::{Json, extract::State, http::StatusCode};
use chrono::Utc;
use std::sync::Arc;
use uuid::Uuid;

pub async fn register_user(
    State(state): State<Arc<AppState>>,
    Json(payload): Json<UserRequest>,
) -> (StatusCode, Json<UserResponse>) {
    let result = state
        .user_service
        .register_user(payload.email.as_str(), payload.password.as_str())
        .await;
    match result {
        Ok(user) => {
            let response = UserResponse {
                id: user.id,
                email: user.email,
                created_at: user.created_at,
            };
            (StatusCode::CREATED, Json(response))
        }
        Err(_e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(UserResponse {
                id: Uuid::nil(),
                email: "".to_string(),
                created_at: Utc::now(),
            }),
        ),
    }
}
