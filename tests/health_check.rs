//! tests/health_check.rs

use std::net::TcpListener;

/// `tokio::test` is the testing equivalent of `tokio::main`.
/// It also spares you from having to specify the `#[test]` attribute.
///
/// You can inspect what code gets generated using
/// `cargo expand --test health_check` (<- name of the test file)

#[tokio::test]
async fn health_check_works() {
    // Arrange
    let address = spawn_app();
    // We need to bring in `reqwest` to perform HTTP requests against
    // our application
    let client = reqwest::Client::new();

    // Act
    let response = client
        .get(&format!("{address}/health_check"))
        .send()
        .await
        .expect("Failed to execute request");

    // Assert
    assert!(response.status().is_success());
    assert_eq!(Some(0), response.content_length());
}

// In tests, it's not worth to propagate errors. Panic and crash if server setup fails
fn spawn_app() -> String {
    let listener = TcpListener::bind("127.0.0.1:0").expect("Failed to bind random port");
    // Get the port number given to us by the operating system
    let port = listener.local_addr().unwrap().port();
    let server = news_letter::run(listener).expect("Failed to bind address");
    // Launch the server as a background task.
    let _ = tokio::spawn(server);

    format!("http://127.0.0.1:{port}")
}
