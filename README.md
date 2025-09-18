# Introduction
This project a full, production-level implementation of a newsletter service. It demonstrates a deeper understanding of what is required to make a project available and maintainable using continuous integration and continuous delivery. 

Best practices are implemented to ensure there will be zero downtime when a new feature is added, which I'll explain in the deployment section.

## What makes it production-grade application?
Following things are taken care of, which are important in any production-grade application.

1. **Modular code:** Each feature has it's own module. Separation of concerns isn't taken lightly and code is highly reusable.
   1. Domain has separate module, which is further divide into submodules. Domain submodules also have their own unit tests.
   2. Each route corresponds to a different feature. Each feature has its own module present in `routes` directory.
   3. Configuration has its own module. Configurations are built according to the environment when building the project. Configurations from `configuration` directory are being read and all corresponding structs are being populated.
   4. Email Client, `email_client.rs` is used to send emails, via Postmark's API.
   5. `startup.rs` is used to build configurations and run the application.
   6. `main.rs` is entry point for our final binary.
   7. `telemetry.rs` is used for proper logging

2. **Observability:** If we're taking our application to production environment without observability, we don't know what went wrong. For this purpose, `telemetry.rs` is added with proper logging and tracing capabilities.

4. **Availability:**  The project is developed by keeping maintainability in mind. If you look at `migrations` directory, there are multiple migrations and each migrations indicates that project is developed gradually, and in a way that user wouldn't have to face any downtime. There's a reason why there are 2 `status` migrations and then later, `create_subscriptions` table was added.
   
5. **CI/CD:** We want to deploy our app with zero downtime, and without any pain. We would want to have different configurations for different environments. I used *Docker*, *Github Actions* and Digitalocean's specifications (spec.yaml) to deploy application in a production.
   1. Docker builds create slim images and use 3 layers for caching.
   2. Database and application, both will be deployed in separate containers.
   3. When you push into github main branch, pipeline should take care of automatic deployment of application and database. 

6. **Testing:** This project highly focuses on proper maintainable testing. You can see
   1. Unit tests in `src/domain` module. Property testing is also used to properly test `subscriber_email.rs` module.
   2. Integration tests are in `src/tests` directory. Each feature has its own integration tests. 

7. **Code Quality:** This includes many things, all of them are contributing to better maintainability.
   1. Proper Error handling.
   2. Separation of concerns.
   3. Proper testing.
   4. Using good third-party crates to avoid re-inventing the wheel. 