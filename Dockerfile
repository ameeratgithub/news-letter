
FROM lukemathwalker/cargo-chef:latest-rust-1 AS chef
# app folder will be created by docker, for us
WORKDIR /app
# Install the required system dependencies for our linking configuration
RUN apt update && apt install lld clang -y
# First stage: computes the recipe file
FROM chef as planner
# Copy all the files from working environment to our docker image
COPY . .
# Computing lock file for our project
RUN cargo chef prepare --recipe-path recipe.json
# Second stage: caches our dependencies and build the binary
FROM chef as builder
COPY --from=planner /app/recipe.json recipe.json
# Building project dependencies. (Note: It's not a build for our application)
RUN cargo chef cook --release --recipe-path recipe.json
COPY . .
# Assumes there is a `.sqlx` directory (cargo sqlx prepare --workspace).
# `.sqlx` should also be in version control
ENV SQLX_OFFLINE=true
# Build the project for production use
RUN cargo build --release --bin news-letter

# Runtime stage
FROM debian:bookworm-slim AS runtime
WORKDIR /app
# Install packages for our dependencies to work correctlly
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends openssl ca-certificates \
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
# Copy compiled binary from the builder environment to our runtime environment
COPY --from=builder /app/target/release/news-letter news-letter
# Configuration is also needed at runtime
COPY configuration configuration
# Specify the production environment 
ENV APP_ENVIRONMENT=production
# Launch the binary when `docker run` gets executed
ENTRYPOINT ["./news-letter"]