use crate::application::config::app_state::AppState;
use crate::application::model::user::UserResponse;
use crate::domain::repository::user_repository::UserRepository;
use axum::{Json, extract::State, http::StatusCode};
use axum_extra::{
    TypedHeader,
    headers::{Authorization, authorization::Bearer},
};
use std::sync::Arc;

pub async fn get_user<T: UserRepository>(
    State(state): State<Arc<AppState<T>>>,
    TypedHeader(bearer): TypedHeader<Authorization<Bearer>>,
) -> (StatusCode, Json<UserResponse>) {
    let user = state
        .authorization_service
        .verify_token(bearer.token())
        .await;
    match user {
        Ok(user) => {
            let user_response = UserResponse {
                id: user.id,
                email: user.email,
                created_at: user.created_at,
            };
            (StatusCode::OK, Json(user_response))
        }
        Err(_) => (
            StatusCode::UNAUTHORIZED,
            Json(UserResponse {
                id: uuid::Uuid::nil(),
                email: "".to_string(),
                created_at: chrono::Utc::now(),
            }),
        ),
    }
}

#[cfg(test)]
mod tests {
    use axum::{extract::State, http::StatusCode};
    use axum_extra::{TypedHeader, headers::Authorization};
    use chrono::Utc;
    use dotenvy::dotenv;
    use mockall::predicate::*;
    use std::sync::Arc;
    use uuid::Uuid;

    use crate::{
        application::config::app_state::AppState,
        domain::{
            model::user::User,
            repository::user_repository::MockUserRepository,
            service::{
                authorization_service::AuthorizationService, jwt_service::JwtService,
                password_service::PasswordService, user_service::UserService,
            },
        },
    };

    #[tokio::test]
    async fn test_get_user_with_valid_token() {
        dotenv().ok();
        let jwt_private_key =
            std::env::var("JWT_PRIVATE_KEY").expect("JWT_PRIVATE_KEY must be set in .env file");
        let jwt_public_key =
            std::env::var("JWT_PUBLIC_KEY").expect("JWT_PUBLIC_KEY must be set in .env file");
        let jwt_service = Arc::new(JwtService::new(jwt_private_key, jwt_public_key, 3600));

        let user_id = Uuid::new_v4();
        let token = jwt_service.generate_token(&user_id.to_string()).unwrap();

        let mut mock_repo = MockUserRepository::new();
        let expected_user = User {
            id: user_id,
            email: "test@example.com".to_string(),
            hashed_password: "hashed".to_string(),
            created_at: Utc::now(),
        };
        mock_repo
            .expect_find_user_by_id()
            .with(eq(user_id))
            .times(1)
            .returning(move |_| Ok(Some(expected_user.clone())));
        let mock_repo = Arc::new(mock_repo);

        let password_service = Arc::new(PasswordService);
        let user_service = Arc::new(UserService::new(
            password_service.clone(),
            mock_repo.clone(),
        ));
        let authorization_service = Arc::new(AuthorizationService::new(
            password_service,
            jwt_service.clone(),
            mock_repo.clone(),
        ));
        let app_state = Arc::new(AppState {
            user_service,
            authorization_service,
        });

        let bearer = TypedHeader(Authorization::bearer(&token).unwrap());
        let (status, user) = super::get_user(State(app_state), bearer).await;

        assert_eq!(status, StatusCode::OK);
        assert_eq!(user.0.id, user_id);
        assert_eq!(user.0.email, "test@example.com");
    }

    #[tokio::test]
    async fn test_get_user_with_invalid_token() {
        let mock_repo = MockUserRepository::new();

        let password_service = Arc::new(PasswordService);
        let jwt_private_key = "invalid_key".to_string();
        let jwt_public_key = "invalid_key".to_string();
        let jwt_service = Arc::new(JwtService::new(jwt_private_key, jwt_public_key, 3600));
        let user_service = Arc::new(UserService::new(
            password_service.clone(),
            Arc::new(mock_repo),
        ));
        let authorization_service = Arc::new(AuthorizationService::new(
            password_service,
            jwt_service,
            user_service.user_repository.clone(),
        ));
        let app_state = Arc::new(AppState {
            user_service,
            authorization_service,
        });

        let bearer = TypedHeader(Authorization::bearer("invalid_token").unwrap());
        let (status, _) = super::get_user(State(app_state), bearer).await;

        assert_eq!(status, StatusCode::UNAUTHORIZED);
    }
}
