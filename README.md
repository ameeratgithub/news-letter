# Production-Grade Newsletter Service
This project a full, production-level implementation of a newsletter service. It demonstrates a deeper understanding of what is required to make a project available and maintainable using continuous integration and continuous delivery. 

Best practices are implemented to ensure there will be **zero downtime** when a new feature is added, which I'll explain in the deployment (CI/CD) section.

## Getting Started
To run the project locally, you would need following softwares installed on your machine.
1. Rust
2. Docker
3. Optional - pgAdmin 4 

After all the installation, you need to follow steps below:
1. Install `lld` linker for faster compilation (`mold` is also another popular option). See `.cargo/config.toml` for more details. 
   1. For docker builds, you don't need to install lld, because it's already included in `Dockerfile`. It's just for local cargo commands. 
2. Run PostgreSQL instance by executing `./scripts/init_db.sh`
   1. If postgres instance in docker is already up, and you want to just migrate database, run `SKIP_DOCKER=true ./scripts/init_db.sh`. It'll not try to launch a new instance. 
   2. Make sure you've installed `psql`, a command line interface, to interact with PostgreSQL.
   3. Also make sure you've installed `sqlx` by running `cargo install --version='~0.7' sqlx-cli --no-default-features --features rustls,postgres`
   4. Run `cargo sqlx prepare`
3. Build docker image by running `docker build --tag news-letter --file Dockerfile .`
4. Run your application by executing `docker run -p 8000:8000 news-letter`  

## Key Features and Architectural Principles
Following things are taken care of, which are important in any production-grade application.

1. **Modular code:** Each feature has its own module. The **separation of concerns** isn't taken lightly, and code is highly reusable.
   1. The domain has separate module, which is further divided into submodules. Domain submodules also have their own unit tests.
   2. Each route corresponds to a different feature. Each feature has its own module located in `routes` directory.
   3. **Configuration** has its own module. Configurations are built according to the environment when building the project. Configurations from the `configuration` directory are being read, and all corresponding structs are populated.
   4. The **Email Client** (`email_client.rs`) is used to send emails via Postmark's API.
   5. `startup.rs` is used to build configurations and run the application.
   6. `main.rs` is the entry point for our final binary.
   7. `telemetry.rs` is used for proper logging

2. **Observability:** If we take our application to a production environment without observability, we won't know what went wrong. For this purpose, `telemetry.rs` is included with proper logging and tracing capabilities.

3. **Availability:**  The project is developed with maintainability in mind. If you look at `migrations` directory, there are multiple migrations and each one indicates that project was developed gradually, in a way that user won't face any downtime. There's a reason why there are two `status` migrations and then, later, the `create_subscriptions` table was added.
   
4. **CI/CD:** We want to deploy our app with zero downtime and without any pain. We need to have different configurations for different environments. I used **Docker**, **Github Actions** and DigitalOcean's specifications (spec.yaml) to deploy application in a production.
   1. Docker builds create slim images and use three layers for caching.
   2. The database and application will both be deployed in separate containers.
   3. When you push to Github main branch, the pipeline should handle the automatic deployment of both the application and the database. 

5. **Testing:** This project highly focuses on proper, maintainable testing. You can see:
   1. **Unit tests** in the `src/domain` module. *Property testing* is also used to properly test `subscriber_email.rs` module.
   2. **Integration tests** are in the `src/tests` directory. Each feature has its own integration tests. 

6. **Code Quality:** This includes many things, all of which contribute to better maintainability.
   1. Proper error handling.
   2. Separation of concerns.
   3. Proper testing.
   4. Using good third-party crates to avoid re-inventing the wheel. 