use crate::application::config::app_state::AppState;
use crate::application::model::user::UserRequest;
use axum::{Json, extract::State, http::StatusCode};
use serde_json::json;
use std::sync::Arc;

pub async fn login(
    State(state): State<Arc<AppState>>,
    Json(payload): Json<UserRequest>,
) -> (StatusCode, Json<serde_json::Value>) {
    match state
        .authorization_service
        .login(&payload.email, &payload.password)
        .await
    {
        Ok(jwt) => {
            println!("Login successful for user: {}", jwt.user_id);
            let user = json!({"id": jwt.user_id, "email": payload.email});
            let response = json!({"token": jwt, "user": user});
            (StatusCode::OK, Json(response))
        }
        Err(err) => {
            println!("Login failed: {:?}", err);
            (
                StatusCode::UNAUTHORIZED,
                Json(json!({
                    "error": "Invalid email or password",
                })),
            )
        }
    }
}
