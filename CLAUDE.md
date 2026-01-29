# Project Structure

## Overview

Authentication system monorepo with Rust backend (Axum), React frontend, and PostgreSQL database.

## Directory Structure

```text
auth/
├── apps/
│   ├── auth/                    # Rust backend service
│   │   ├── src/
│   │   │   ├── application/     # Handlers, DTOs, config
│   │   │   ├── domain/          # Business logic, entities, services
│   │   │   ├── infrastructure/  # Database implementations
│   │   │   └── main.rs
│   │   └── Cargo.toml
│   └── web/                     # React frontend
│       ├── src/
│       ├── package.json
│       └── vite.config.ts
├── tools/
│   └── flyway/                  # Database migrations
├── docker-compose.yml
└── README.md
```

## Tech Stack

**Backend**: Rust + Axum + Tokio + SQLx + Argon2
**Frontend**: React 19 + TypeScript + Vite
**Database**: PostgreSQL 18.1
**Infrastructure**: Docker Compose + Flyway

## Architecture

Clean Architecture with three layers:

- **Application Layer**: HTTP handlers for `/healthcheck`, `/register`, `/login`
- **Domain Layer**: Core business logic (User entity, UserService, PasswordService)
- **Infrastructure Layer**: Database repositories (SQLx implementation)

**Request Flow**: HTTP → Handler → Service → Repository → Database

## Implementation Guidelines

Follow SOLID principles in all implementations:

- **Single Responsibility**: Each class/module should have one reason to change
- **Open/Closed**: Open for extension, closed for modification
- **Liskov Substitution**: Subtypes must be substitutable for their base types
- **Interface Segregation**: Prefer small, specific interfaces over large ones
- **Dependency Inversion**: Depend on abstractions, not concretions
