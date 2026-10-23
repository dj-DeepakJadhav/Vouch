# Public demo deployment checklist

The repository runs locally with embedded PostgreSQL. A public deployment also needs HTTPS, production secrets, a database and browser-origin configuration. This checklist describes the repository's requirements; a complete hosted deployment has not been verified.

## Configure the server

Edit `config/production.yaml` for your API host on port 8080 and web/MCP host on port 8082. Keep their public scheme as HTTPS and public port as 443. Configure a production PostgreSQL database. Redis is disabled in the supplied configuration.

Create fresh values for `database`, `serviceSecret`, `emailSecretHashPepper`, `jwtHmacSha512PrivateKey`, `jwtRefreshTokenHashPepper` and `mcpRequestStateSecret`. Supply them through private configuration or `SERVERPOD_PASSWORD_<key>` environment variables. Add `nebiusApiKey` only if model-backed rule authoring is needed. Never reuse the public development fixtures.

Run in production mode. `DevModeGuard` blocks development endpoints in that mode. Enable the hosted demo separately with `SERVERPOD_PASSWORD_demoMode=true`; omit that value to keep demo creation disabled.

The demo creates one household per anonymous session. `DemoMode` caps creation at 30 households per hour and 2,000 total. These application-wide caps are not a per-client abuse control. Review public access and rate limits before publishing.

## Permit the web app's origin

The MCP route checks browser `Origin` headers. Its `_extraAllowedOriginHosts` list in `lib/src/mcp/mcp_route.dart` is empty, so a non-local browser app needs its exact host added before MCP calls can succeed. Review that change as permission-path code. Do not add a wildcard.

Configure `allowedOrigins` in `config/production.yaml` for the app's HTTPS origin as well. This controls API browser access separately from the MCP check. Test both routes from the deployed app. Non-browser clients must still present a valid household MCP bearer token.

## Build and start

The server Dockerfile expects the Dart workspace as its build context. From the repository root:

```sh
cd vouch
docker build -f vouch_server/Dockerfile -t vouch-server .
```

The container's default entrypoint starts the server in production mode. On first deployment, apply database migrations with the server's `--apply-migrations` flag; the default entrypoint does not add it. Keep a database backup before applying migrations to existing data.

Build Flutter web from `vouch/vouch_flutter/` with `SERVER_URL` set to the public API URL and `MCP_URL` set to the public web-server URL ending in `/mcp`. Pass both as `--dart-define` values to `flutter build web --release`. Serve `build/web/` over HTTPS with fallback routing to `index.html`.

Keep ports 8080, 8081 and 8082 private behind the HTTPS proxy. Port 8081 is Serverpod Insights and should not be publicly reachable. Managed Serverpod hosting is documented in the [Serverpod Cloud guide](https://docs.serverpod.dev/cloud); this repository does not verify a specific Cloud CLI deployment sequence.

## Test before sharing

1. Confirm the public API reports demo availability and rejects development-only operations.
2. Open the app in a fresh browser session and select **Try the demo household (no hub)**.
3. Run an allowed shopping-list request and a denied purchase request.
4. Complete a sensitive request through approval, then replay the used approval. Confirm that the second attempt is rejected and recorded in Activity.
5. Start another anonymous session and confirm it cannot access the first session's household.
6. Check that logs, browser responses and screenshots contain no credentials.

The owner-phone interface and speaker identities remain simulated. These checks do not establish live Alexa+ compatibility or approval on a separate authenticated phone.

## Disable the demo

Remove `demoMode` or set it to a value other than `true`, then restart. This stops demo operations but leaves existing household and audit records in PostgreSQL. Remove the hosted resources when testing ends to stop their recurring charges.
