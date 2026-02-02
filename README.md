# Authentication & Authorization

A frontend and backend authentication and authorization system.

## Tech Stack

- **Backend**: Rust (Axum framework)
- **Frontend**: React + TypeScript
- **Database**: PostgreSQL
- **Migrations**: Flyway

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
├── apps/
│   ├── auth/          # Rust backend service
│   └── web/           # React frontend
├── tools/
│   └── flyway/        # Database migrations
└── docker-compose.yml
```

## Getting Started

1. Start the database:

   ```bash
   docker-compose up -d
   ```

2. Run migrations:

   ```bash
   cd tools/flyway
   ./flyway migrate
   ```

3. Start the backend:

   ```bash
   cd apps/auth
   cargo run
   ```

4. Start the frontend:

   ```bash
   cd apps/web
   bun install
   bun run dev
   ```

## API Documentation

API endpoints are documented in the OpenAPI specification at `apps/auth/docs/openapi.yml`.
