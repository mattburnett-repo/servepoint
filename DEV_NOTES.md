# Development Notes

## Server Configuration

The project runs on **CommandBox** and is set up to work with **Adobe ColdFusion 2025** by setting the `cfengine` in `server.json` to `adobe@2025`. This should default to the latest version of CF2025.

- **Java**: The engine uses **Java SE 17**. `server.json` sets `jvm.javaHome` to the Temurin 17 JDK so the embedded server always uses Java 17 regardless of the shell default.
- **Datasource**: The app datasource is defined in `.cfconfig.json` (structure + placeholders) and populated at server start from env vars via CFConfig overrides. See **Config and secrets** below.
- **macOS**: To avoid the "Error setting dock icon image" warning on Java 17, `server.json` includes `jvm.args` with `--add-opens=java.desktop/com.apple.eawt=ALL-UNNAMED`.
- **CommandBox 6.2+ for CF 2025**: Adobe ColdFusion 2025 uses the **Jakarta** servlet API. CommandBox **6.2.0 or newer** is required so it automatically uses the Jakarta version of Runwar when starting CF 2025. On older CommandBox you get `NoClassDefFoundError: jakarta/servlet/Servlet`. Upgrade with `box update`. If you already have 6.2+ and see that error, run `box server forget` (from the project directory), then `box server start` so CommandBox does a fresh start and downloads the correct Runwar.

To switch engine versions, edit `server.json`: set `app.cfengine` to `adobe@2025.0.0` (or another CF 2025 version), then run `box server restart`.

## Config and secrets

Config and datasource credentials are kept out of the repo by using a standard `.env` file, the **commandbox-dotenv** module (loads `.env` at server start), and built-in ColdBox/CFConfig support. See [GitHub issue #6](https://github.com/mattburnett-repo/servepoint/issues/6).

**1. Install commandbox-dotenv**

- Run `box install commandbox-dotenv` so that when you run `box server start`, the `.env` file is loaded and env vars are available to CFConfig and the app.

**2. `.env` and commandbox-dotenv**

- Use the standard **`.env`** file in the project root. Although the [commandbox-dotenv README](https://github.com/commandbox-modules/commandbox-dotenv) says you can assign a different file to the `dotenvFile` variable in `server.json`, in our experience doing so causes a stack overflow and startup failure—so do **not** set `dotenvFile` in `server.json` (e.g. to `.env.dev`). Use `.env` only. Other filenames lead to crashed app startup.

**3. Datasource (no secrets in repo)**

- **`.cfconfig.json`**: The `servepoint` datasource is defined with placeholders only: `${DB_DRIVER}`, `${DB_HOST}`, `${DB_PORT}`, `${DB_DATABASE}`, `${DB_USERNAME}`, `${DB_PASSWORD}`. No literal credentials.

## Known issues

- **"graphqlclient not found" with CF 2025**:
  - When starting the app with ColdFusion 2025, the first request (when the app first loads) can trigger a `ModuleNotAvailableException: The graphqlclient package is not installed` error.
  - **Cause**: CF 2025's `ApplicationSettings.loadAppDatasources()` calls `ServiceFactory.getGraphQLClientService()` when resolving application scope; if the optional graphqlclient package is not installed, it throws.
  - This app does not use GraphQL; it appears that the error originates within ColdFusion 2025 itself.
  - **Workaround**: In `Application.cfc` `onError()`, we detect this exception and issue a 302 redirect to the same URL. The second request succeeds because the application scope is already resolved. See [GitHub issue #10](https://github.com/mattburnett-repo/servepoint/issues/10).

- **cfpm install: caching and orm packages cannot be installed by the server (FALSE POSITIVE)**:
  - When running `cfpm install` (e.g. `cfpm install postgresql`), packages are downloaded (e.g. orm, hibernate-testing) but installation fails with: `caching package cannot be installed by the server. Please check the server logs and try installing again.` and `orm package cannot be installed by the server. Please check the server logs and try installing again.`
  - Check server logs for details and retry if needed.
  - **The app actually does install the packages. Not sure why this error is reported.**
