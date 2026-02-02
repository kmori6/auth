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
    use crate::domain::error::app_error::AppError;
    use crate::domain::model::user::User;
    use crate::domain::repository::user_repository::UserRepository;
    use crate::domain::service::authorization_service::AuthorizationService;
    use crate::domain::service::jwt_service::JwtService;
    use crate::domain::service::password_service::PasswordService;
    use crate::domain::service::user_service::UserService;
    use chrono::Utc;
    use uuid::Uuid;

    struct MockUserRepository {
        mock_user: Option<User>,
    }

    impl UserRepository for MockUserRepository {
        async fn create_user(&self, _user: &User) -> Result<(), AppError> {
            Ok(())
        }

        async fn find_user_by_email(&self, email: &str) -> Result<Option<User>, AppError> {
            if let Some(user) = &self.mock_user {
                if user.email == email {
                    return Ok(Some(user.clone()));
                }
            }
            Ok(None)
        }
    }

    fn create_test_app_state(mock_user: Option<User>) -> Arc<AppState<MockUserRepository>> {
        let password_service = Arc::new(PasswordService);
        let mock_repo = Arc::new(MockUserRepository { mock_user });

        // .envファイルから環境変数を読み込む
        dotenvy::dotenv().ok();
        let jwt_private_key =
            std::env::var("JWT_PRIVATE_KEY").expect("JWT_PRIVATE_KEY must be set in .env file");

        let jwt_service = Arc::new(JwtService::new(jwt_private_key, 3600));

        let authorization_service = Arc::new(AuthorizationService::new(
            password_service.clone(),
            jwt_service,
            mock_repo.clone(),
        ));

        let user_service = Arc::new(UserService::new(password_service, mock_repo));

        Arc::new(AppState {
            user_service,
            authorization_service,
        })
    }

    #[tokio::test]
    async fn test_login() {
        let password_service = PasswordService;
        let user_id = Uuid::new_v4();
        let email = "test@example.com";
        let password = "password123";
        let hashed_password = password_service.hash(password).unwrap();
        let mock_user = User {
            id: user_id,
            email: email.to_string(),
            hashed_password,
            created_at: Utc::now(),
        };

        let app_state = create_test_app_state(Some(mock_user));

        let request = UserRequest {
            email: email.to_string(),
            password: password.to_string(),
        };

        let (status, response) = login(State(app_state), Json(request)).await;

        let response_value = response.0;
        assert_eq!(status, StatusCode::OK, "Status should be OK");
        assert!(response_value["token"].is_object());
        assert_eq!(response_value["token"]["user_id"], user_id.to_string());
        assert_eq!(response_value["user"]["id"], user_id.to_string());
        assert_eq!(response_value["user"]["email"], email);
    }
}
