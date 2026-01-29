use crate::domain::error::app_error::AppError;
use crate::domain::model::user::User;
use crate::domain::repository::user_repository::UserRepository;
use crate::infrastructure::repository::sqlx_pool::SqlxPool;

pub struct SqlxUserRepository {
    pub sqlx_pool: SqlxPool,
}

impl UserRepository for SqlxUserRepository {
    async fn create_user(&self, user: &User) -> Result<(), AppError> {
        sqlx::query(
            "INSERT INTO users (id, email, hashed_password, created_at)
            VALUES ($1, $2, $3, $4)",
        )
        .bind(user.id)
        .bind(&user.email)
        .bind(&user.hashed_password)
        .bind(user.created_at)
        .execute(&self.sqlx_pool.pool)
        .await
        .map_err(|_e| AppError::Unknown)?;

        Ok(())
    }

    async fn find_user_by_email(&self, email: &str) -> Result<Option<User>, AppError> {
        let user = sqlx::query_as::<sqlx::Postgres, User>("SELECT * FROM users WHERE email = $1")
            .bind(email)
            .fetch_optional(&self.sqlx_pool.pool)
            .await
            .map_err(|_e| AppError::Unknown)?;

        Ok(user)
    }
}
