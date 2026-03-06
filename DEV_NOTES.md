# Development Notes

## Server Configuration

The project runs on **CommandBox** and is set up to work with **Adobe ColdFusion 2025** by setting the `cfengine` in `server.json` to `adobe@2025`. This should default to the latest version of CF2025.

- **Java**: The engine uses **Java SE 17**. `server.json` sets `jvm.javaHome` to the Temurin 17 JDK so the embedded server always uses Java 17 regardless of the shell default.
- **Datasource**: The app datasource is defined **only in Application.cfc** (single source of truth). It is not defined in `server.json`; the app registers it at startup so behavior is consistent and portable.
- **macOS**: To avoid the "Error setting dock icon image" warning on Java 17, `server.json` includes `jvm.args` with `--add-opens=java.desktop/com.apple.eawt=ALL-UNNAMED`.
- **CommandBox 6.2+ for CF 2025**: Adobe ColdFusion 2025 uses the **Jakarta** servlet API. CommandBox **6.2.0 or newer** is required so it automatically uses the Jakarta version of Runwar when starting CF 2025. On older CommandBox you get `NoClassDefFoundError: jakarta/servlet/Servlet`. Upgrade with `box update`. If you already have 6.2+ and see that error, run `box server forget` (from the project directory), then `box server start` so CommandBox does a fresh start and downloads the correct Runwar.

To switch engine versions, edit `server.json`: set `app.cfengine` to `adobe@2025.0.0` (or another CF 2025 version), then run `box server restart`.

## Known issues

- **"graphqlclient not found" with CF 2025**:
  - When starting the app with ColdFusion 2025, the first request (when the app first loads) can trigger a `ModuleNotAvailableException: The graphqlclient package is not installed` error.
  - **Cause**: CF 2025's `ApplicationSettings.loadAppDatasources()` calls `ServiceFactory.getGraphQLClientService()` when resolving application scope; if the optional graphqlclient package is not installed, it throws.
  - This app does not use GraphQL; it appears that the error originates within ColdFusion 2025 itself.
  - **Workaround**: In `Application.cfc` `onError()`, we detect this exception and issue a 302 redirect to the same URL. The second request succeeds because the application scope is already resolved. See [GitHub issue #10](https://github.com/mattburnett-repo/servepoint/issues/10).
