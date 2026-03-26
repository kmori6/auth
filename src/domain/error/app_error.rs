use thiserror::Error;

#[derive(Error, Debug)]
pub enum AppError {
    #[error("unknown data store error")]
    Unknown,
}
