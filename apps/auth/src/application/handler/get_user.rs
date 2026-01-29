use crate::application::config::app_state::AppState;
use crate::application::model::user::UserResponse;
use axum::{Json, extract::State, http::StatusCode};
use std::sync::Arc;

pub async fn get_user(State(_state): State<Arc<AppState>>) -> (StatusCode, Json<UserResponse>) {
    println!("Healthcheck requested");
    (
        StatusCode::OK,
        Json(UserResponse {
            id: uuid::Uuid::nil(),
            email: "dummy".to_string(),
            created_at: chrono::Utc::now(),
        }),
    )
}
