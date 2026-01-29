use axum::Json;
use serde_json::{Value, json};

pub async fn healthcheck() -> Json<Value> {
    println!("Healthcheck requested");
    Json(json!({"status": "ok"}))
}
