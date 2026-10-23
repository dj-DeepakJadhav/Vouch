# Vouch backend

The Serverpod backend stores households, policy, approvals and audit records in PostgreSQL. Its `/mcp` route checks permissions before connected tools run. Demo tool actions are mocks.

Start the backend and Flutter app from the workspace directory:

```sh
cd vouch
dart pub get
./vouch_server/tool/setup_passwords.sh
serverpod start
```

Run these commands from the repository root. The setup script generates local secrets and preserves an existing password file. Press `Q` in the Serverpod terminal to stop the app and server.

## Development

Endpoint and policy code lives in `lib/src/`. Model definitions use `.spy.yaml`; Serverpod generates `lib/src/generated/` and the client package from them. Database migrations are committed under `migrations/`.

From this directory, run `dart test`. Serverpod manages an embedded test PostgreSQL instance; Docker is not required for these tests.

The [root README](../../README.md) explains the demo and its limits. Read [DEPLOY.md](DEPLOY.md) before exposing the backend publicly.
