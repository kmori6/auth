# Authentication & Authorization API

Rust and Axum based authentication and authorization API with PostgreSQL, Flyway, and JWT.

## Tech Stack

- **Backend**: Rust + Axum
- **Database**: PostgreSQL
- **Migrations**: Flyway
- **Container Runtime**: Docker Compose

## Architecture

Clean architecture with three layers:

- **Application**: HTTP handlers and DTOs
- **Domain**: Business logic and entities
- **Infrastructure**: Database repositories

## Features

- User registration with password hashing (Argon2)
- User login with JWT authentication
- Token-based access control

## Project Structure

```text
auth/
├── src/              # Rust application
├── flyway/sql/       # Database migrations
├── docker/           # Dockerfiles for the API and Flyway
├── docs/             # OpenAPI specification
├── scripts/          # Utility scripts
├── .env.sample
└── docker-compose.yml
```

## Getting Started

1. Create a local environment file:

   ```bash
   cp .env.sample .env
   ```

   Set `JWT_PRIVATE_KEY` and `JWT_PUBLIC_KEY` in `.env`.

2. Start PostgreSQL and run the migrations:

   ```bash
   docker compose up -d postgres flyway-postgres flyway-auth
   ```

3. Start the API locally:

   ```bash
   cargo run
   ```

4. Check the health endpoint:

   ```bash
   curl http://localhost:3000/healthcheck
   ```

## API Documentation

API endpoints are documented in `docs/openapi.yml`.
