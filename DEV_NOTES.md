# Development Notes

## Development workflow (important)

For day‑to‑day development, **run the app inside Docker**, not via `box server start` on your host machine.

- **Preferred**: from the project root (`ServePoint` directory), start the full stack with:

  ```bash
  docker compose --env-file .env -f docker/docker-compose.yml up
  ```

  This builds the app image, starts the app and Postgres containers, and wires all environment variables from `.env`.

- **Not preferred**: running `box server start` directly on your host. That path is only for troubleshooting; it does not match the containerized production‑like environment, and may behave differently (Java, paths, CF packages, etc.).

## Config and secrets

This app uses:

- **commandbox-dotenv** (preinstalled in the Docker image) to load environment variables.
- A familiar **`.env` file in the project root** for secrets and configuration (database credentials, etc.).

When you run the app via Docker (`docker compose --env-file .env -f docker/docker-compose.yml up`), those `.env` values are injected into the containers and used by CF/ColdBox; you should not commit `.env` to version control.

## Known issues

- **"graphqlclient not found" with CF 2025**:
  - When starting the app with ColdFusion 2025, the first request (when the app first loads) can trigger a `ModuleNotAvailableException: The graphqlclient package is not installed` error.
  - **Cause**: CF 2025's `ApplicationSettings.loadAppDatasources()` calls `ServiceFactory.getGraphQLClientService()` when resolving application scope; if the optional graphqlclient package is not installed, it throws.
  - This app does not use GraphQL; it appears that the error originates within ColdFusion 2025 itself.
  - **Workaround**: In `Application.cfc` `onError()`, we detect this exception and issue a 302 redirect to the same URL. The second request succeeds because the application scope is already resolved. See [GitHub issue #10](https://github.com/mattburnett-repo/servepoint/issues/10).
