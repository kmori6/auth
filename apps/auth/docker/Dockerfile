# build stage
# https://hub.docker.com/_/rust (same base image for trixie)
FROM rust:1.92-trixie AS builder
WORKDIR /usr/src/auth
COPY . .
RUN cargo install --path .

# runtime stage (trixie is the current stable Debian)
FROM debian:trixie-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local/cargo/bin/auth /usr/local/bin/auth
CMD ["auth"]
