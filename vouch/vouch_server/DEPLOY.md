# Deploying Vouch for judging (until 20 Nov 2026)

Goal: a public API + MCP endpoint and a Flutter web admin app where a judge
clicks **Try the demo household** and drives the simulated Alexa tab. Nothing
here deploys anything; the accounts, domains and secrets are yours.

Statuses: **[verified]** = checked against this repo or the project's
Serverpod skills. **[unverified]** = from general knowledge; check the linked
docs before relying on it.

## What makes this safe to expose

- Run the server in **production** mode. `DevEndpoint` then refuses every
  call (`DevModeGuard`), so `approveAsOwner`, `claimOwner`,
  `issueTestAttestation` and arbitrary seeding are unreachable. [verified]
- The demo is enabled by one flag, the `demoMode` password, set to `true`.
  It is off when the key is absent and does not depend on run mode. [verified]
- With demo mode on, `DemoEndpoint` gives each anonymous session one
  isolated household. The hub signing key for it is generated and kept on
  the server, every attestation goes through the normal
  `AttestationService.submit`, and approvals use the normal owner-checked
  `approval.decide`. New households are capped at 30 per hour and 2000 in
  total (`DemoMode.maxPerHour` / `maxTotal`). [verified]

## Things you must provide

| Item | Where |
|---|---|
| Domain or Cloud URLs for the API (8080) and web/MCP (8082) servers | `config/production.yaml` `apiServer` / `webServer` |
| Postgres (Serverpod Cloud provides one; on a VM it is yours) | `database:` + `database` password |
| Secrets: `database`, `serviceSecret`, `emailSecretHashPepper`, `jwtHmacSha512PrivateKey`, `jwtRefreshTokenHashPepper`, `mcpRequestStateSecret` (+ optional `nebiusApiKey`) | passwords / env vars |
| `demoMode: 'true'` | passwords / `SERVERPOD_PASSWORD_demoMode=true` |
| Somewhere to host the Flutter web build (static files, HTTPS) | any static host, or the VM |

Generate fresh secrets, for example with `openssl rand -base64 48`. Never
reuse the development values.

## Code change still needed: MCP Origin allowlist

`lib/src/mcp/mcp_route.dart` answers 403 to any browser `Origin` that is not
localhost (`_extraAllowedOriginHosts` is an empty `const` list). This is the
DNS-rebinding defence the MCP spec requires. Requests from the hosted Flutter
app's simulated Alexa tab carry the app's origin, so they will be refused
until that host is added. Non-browser MCP clients (Alexa+, MCP Inspector CLI,
curl) send no `Origin` and work as they are. [verified]

Smallest safe fix: add the exact app host, e.g.
`static const List<String> _extraAllowedOriginHosts = ['app.example.com'];`.
Do not use a wildcard. This file is on the trust path, so review the diff.

Also uncomment `allowedOrigins:` in `config/production.yaml` with the app
origin (`https://app.example.com`). The comment in that file says browsers
from unlisted origins lose cross-origin access once it is set, which is what
the app's API calls need. Leave `authCookie` commented out unless you also
set `client.cookieAuth = true`. [verified that the keys exist in the config
template; the exact CORS behaviour of `allowedOrigins` is unverified]

## Common steps

1. Fill in `config/production.yaml` hosts. Keep `publicScheme: https` and
   `publicPort: 443`. Point `database:` at your Postgres.
2. Set the secrets (table above). Any password can come from an environment
   variable named `SERVERPOD_PASSWORD_<key>`. [verified, serverpod-configuration
   skill]
3. Apply migrations on first start: `--apply-migrations` (the latest one is
   `20261019204456969-demo-household`). [verified, serverpod-migrations skill]
4. Build the web app pointing at the public URLs (both keys are read by the
   app [verified]: `SERVER_URL` in serverpod_flutter's `getServerUrl`,
   `MCP_URL` in `lib/data/repos_bundle.dart`):

   ```bash
   cd vouch/vouch_flutter
   flutter build web --release \
     --dart-define=SERVER_URL=https://api.example.com/ \
     --dart-define=MCP_URL=https://web.example.com/mcp
   # upload build/web/ to your static host
   ```

5. Check it:
   - `curl -s -X POST https://api.example.com/demo/available -d '{}'` returns `true`
   - `curl -s -X POST https://api.example.com/dev/demoAvailable -d '{}'` returns `false`
   - open the app, click **Try the demo household**, run the four scenario
     chips, then **Sign out**.

HTTPS is required. The app is served over HTTPS and browsers block mixed
content, and the bearer token for MCP must not travel in clear text. Alexa+
also needs an HTTPS MCP URL [unverified for Alexa+].

## (a) Serverpod Cloud

The project's deployment skill names Serverpod Cloud as the default: managed
Postgres, secrets, logs and TLS URLs, docs at https://docs.serverpod.dev/cloud.
[verified that the skill says this]. The commands below are from general
knowledge. **[unverified]** Check them against those docs first.

```bash
dart pub global activate serverpod_cloud_cli     # provides `scloud`  [unverified]
scloud auth login                                # [unverified]
cd vouch/vouch_server
scloud launch                                    # create + link project [unverified]
scloud password set demoMode true                # [unverified command name]
scloud password set mcpRequestStateSecret '<random>'
scloud deploy                                    # [unverified]
scloud domain ...                                # optional custom domain [unverified]
```

Cloud supplies the database and the built-in secrets (`database`,
`serviceSecret`, JWT keys) [unverified: confirm which are supplied]. Set
`mcpRequestStateSecret` and `demoMode` yourself. Cloud gives separate URLs
for the API server and the web server. Use the web server URL + `/mcp` for
`MCP_URL` and add the app's host to the MCP Origin allowlist (above). The
Flutter web build can be hosted by Cloud's web server or by any static host
[unverified].

## (b) Small Linux VM (Docker or a native binary)

Size: 1 vCPU / 1-2 GB RAM is enough for judging traffic [unverified estimate].

1. Postgres 16+: managed, or `docker run -d --name pg -e POSTGRES_PASSWORD=... -p 127.0.0.1:5432:5432 postgres:17`.
   In `production.yaml` set `database.host: localhost` (or the container
   name), `port: 5432`, `requireSsl: false` only if it is local.
2. Build and run the server.

   Docker (the Dockerfile builds from the workspace root) [verified]:

   ```bash
   cd vouch
   docker build -f vouch_server/Dockerfile -t vouch-server .
   docker run -d --name vouch --restart unless-stopped --network host \
     -e runmode=production \
     -e SERVERPOD_PASSWORD_database=... \
     -e SERVERPOD_PASSWORD_serviceSecret=... \
     -e SERVERPOD_PASSWORD_emailSecretHashPepper=... \
     -e SERVERPOD_PASSWORD_jwtHmacSha512PrivateKey=... \
     -e SERVERPOD_PASSWORD_jwtRefreshTokenHashPepper=... \
     -e SERVERPOD_PASSWORD_mcpRequestStateSecret=... \
     -e SERVERPOD_PASSWORD_demoMode=true \
     vouch-server
   ```

   The image's ENTRYPOINT does not pass `--apply-migrations` [verified].
   For the first start, either override it
   (`--entrypoint sh vouch-server -c './bin/server --mode=production --apply-migrations'`)
   or run the binary once with that flag.

   Native: `cd vouch_server && dart compile exe bin/main.dart -o server` and
   run `./server --mode=production --apply-migrations` from `vouch_server/`
   (it reads `config/` and `migrations/` relative to the working directory)
   under systemd with the same environment variables.
3. TLS reverse proxy. Caddy is the shortest route:

   ```
   api.example.com { reverse_proxy 127.0.0.1:8080 }
   web.example.com { reverse_proxy 127.0.0.1:8082 }
   app.example.com { root * /srv/vouch-web; file_server; try_files {path} /index.html }
   ```

   Keep 8080/8081/8082 closed in the firewall; expose only 80/443. Do not
   expose 8081 (Insights) publicly.

## How a judge reaches it

- **App:** `https://app.example.com` → **Try the demo household (no hub)** →
  Alexa tab → scenario chips; approve step-ups on the Approvals tab.
- **MCP server:** `https://web.example.com/mcp` (Streamable HTTP). It needs a
  bearer token for a household. The app mints one for its demo household
  (Alexa tab). For an external MCP client, put a judge-facing token in the
  submission notes: start a demo in the app and copy the token, or mint one
  for a dedicated judge household. Tokens are stored hashed and cannot be
  recovered later.

## After judging (20 Nov 2026)

Set `demoMode` to anything but `true` (or delete it) and restart. The demo
then refuses everything. Demo households stay in the database (audit is
append-only); drop the deployment when you no longer need it.
