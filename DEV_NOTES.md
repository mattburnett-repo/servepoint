# Development Notes

## Server Configuration

The project runs on **CommandBox** and is set up to work with both **Lucee 6** and **Adobe ColdFusion 2025** by changing the `cfengine` in `server.json`.

- **Java**: Both engines use **Java SE 17**. `server.json` sets `jvm.javaHome` to the Temurin 17 JDK so the embedded server always uses Java 17 regardless of the shell default.
- **Lucee**: Use **Lucee 6** (`lucee@6`), not 5.x. Lucee 5.x targets Java 8/11 and the old `javax.servlet` API; on Java 17 it throws `NoClassDefFoundError`. Lucee 6 works with Java 17.
- **Lucee ORM**: In Lucee 6, ORM is not built-in. The **Ortus ORM Extension** is installed automatically via the `env.LUCEE_EXTENSIONS` entry in `server.json` (ForgeBox ID `D062D72F-F8A2-46F0-8CBC91325B2F067B`). Without it you get "No ORM Engine installed!"
- **Datasource**: The app datasource is defined **only in Application.cfc** (single source of truth). It is not defined in `server.json`; the app registers it at startup so behavior is consistent and portable.
- **macOS**: To avoid the "Error setting dock icon image" warning on Java 17, `server.json` includes `jvm.args` with `--add-opens=java.desktop/com.apple.eawt=ALL-UNNAMED`.
- **CommandBox 6.2+ for CF 2025**: Adobe ColdFusion 2025 uses the **Jakarta** servlet API. CommandBox **6.2.0 or newer** is required so it automatically uses the Jakarta version of Runwar when starting CF 2025. On older CommandBox you get `NoClassDefFoundError: jakarta/servlet/Servlet`. Upgrade with `box update`. If you already have 6.2+ and see that error, run `box server forget` (from the project directory), then `box server start` so CommandBox does a fresh start and downloads the correct Runwar.

To switch engines, edit `server.json`: set `app.cfengine` to `lucee@6` or `adobe@2025.0.0` (or another CF 2025 version), then run `box server restart`.

## Known issues

- **"graphqlclient not found" with CF 2025**: When starting the app with ColdFusion 2025, the first load in the browser may show a graphqlclient-related error (the app does not use GraphQL). **Reload the page** and the error goes away. This is a known issue; see [GitHub issue #10](https://github.com/mattburnett-repo/servepoint/issues/10).
