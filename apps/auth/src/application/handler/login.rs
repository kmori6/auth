use crate::application::config::app_state::AppState;
use crate::application::model::user::UserRequest;
use crate::domain::repository::user_repository::UserRepository;
use axum::{Json, extract::State, http::StatusCode};
use serde_json::json;
use std::sync::Arc;

pub async fn login<R: UserRepository>(
    State(state): State<Arc<AppState<R>>>,
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

#[cfg(test)]
mod tests {
    use super::*;
    use crate::domain::model::user::User;
    use crate::domain::repository::user_repository::MockUserRepository;
    use crate::domain::service::{
        authorization_service::AuthorizationService, jwt_service::JwtService,
        password_service::PasswordService, user_service::UserService,
    };
    use chrono::Utc;
    use mockall::predicate::*;
    use uuid::Uuid;

    #[tokio::test]
    async fn test_login_success() {
        dotenvy::dotenv().ok();
        let jwt_private_key =
            std::env::var("JWT_PRIVATE_KEY").expect("JWT_PRIVATE_KEY must be set");
        let jwt_public_key =
            std::env::var("JWT_PUBLIC_KEY").expect("JWT_PUBLIC_KEY must be set");

        let user_id = Uuid::new_v4();
        let email = "test@example.com";
        let password = "password123";
        let password_service = PasswordService;
        let hashed_password = password_service.hash(password).unwrap();

        let expected_user = User {
            id: user_id,
            email: email.to_string(),
            hashed_password,
            created_at: Utc::now(),
        };

        let mut mock_repo = MockUserRepository::new();
        mock_repo
            .expect_find_user_by_email()
            .with(eq(email))
            .times(1)
            .returning(move |_| Ok(Some(expected_user.clone())));

        let password_service = Arc::new(PasswordService);
        let authorization_service = Arc::new(AuthorizationService::new(
            password_service.clone(),
            Arc::new(JwtService::new(jwt_private_key, jwt_public_key, 3600)),
            Arc::new(mock_repo),
        ));
        let user_service = Arc::new(UserService::new(
            password_service,
            Arc::new(MockUserRepository::new()),
        ));
        let app_state = Arc::new(AppState {
            user_service,
            authorization_service,
        });

        let request = UserRequest {
            email: email.to_string(),
            password: password.to_string(),
        };
        let (status, response) = login(State(app_state), Json(request)).await;

        assert_eq!(status, StatusCode::OK);
        assert!(response.0["token"].is_object());
        assert_eq!(response.0["user"]["email"], email);
    }

    #[tokio::test]
    async fn test_login_invalid_password() {
        dotenvy::dotenv().ok();
        let jwt_private_key =
            std::env::var("JWT_PRIVATE_KEY").expect("JWT_PRIVATE_KEY must be set");
        let jwt_public_key =
            std::env::var("JWT_PUBLIC_KEY").expect("JWT_PUBLIC_KEY must be set");

        let email = "test@example.com";
        let password_service = PasswordService;
        let hashed_password = password_service.hash("correct_password").unwrap();

        let expected_user = User {
            id: Uuid::new_v4(),
            email: email.to_string(),
            hashed_password,
            created_at: Utc::now(),
        };
        let expected_user_clone = expected_user.clone();

        let mut mock_repo = MockUserRepository::new();
        mock_repo
            .expect_find_user_by_email()
            .with(eq(email))
            .times(1)
            .returning(move |_| Ok(Some(expected_user_clone.clone())));

        let password_service = Arc::new(PasswordService);
        let jwt_service = Arc::new(JwtService::new(jwt_private_key, jwt_public_key, 3600));
        let authorization_service = Arc::new(AuthorizationService::new(
            password_service.clone(),
            jwt_service,
            Arc::new(mock_repo),
        ));
        let user_service = Arc::new(UserService::new(
            password_service,
            Arc::new(MockUserRepository::new()),
        ));
        let app_state = Arc::new(AppState {
            user_service,
            authorization_service,
        });

        let request = UserRequest {
            email: email.to_string(),
            password: "wrong_password".to_string(),
        };
        let (status, response) = login(State(app_state), Json(request)).await;

        assert_eq!(status, StatusCode::UNAUTHORIZED);
        assert_eq!(response.0["error"], "Invalid email or password");
    }
}
