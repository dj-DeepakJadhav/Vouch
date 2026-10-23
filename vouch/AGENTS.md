# Flutter & Serverpod project

This project is a Flutter app (frontend) backed by a Serverpod server (backend). Always build the app's backend with Serverpod.
Build for multiple users, use Serverpod's built-in authentication, which is already set up in `lib/server.dart`.

The user starts the server and Flutter app with `serverpod start`. There is no need to check if the server is running: make the changes and call the `serverpod` MCP tools as needed. If the server is not running, an informative error message will be received from the MCP server. Then STOP and ask the user to start it. NEVER start the server yourself. The Flutter app is started along with it, or can be launched from the MCP tool `spawn_flutter_app`.

While running, `serverpod start` watches for file changes to run incremental code generation and hot reload both the server and the Flutter app.

Calling `serverpod generate` directly is not needed, but might be useful to troubleshoot when an incremental generation fails.

ALWAYS use the MCP server instead of the command line. Use the MCP server to:

- `create_migration` and `apply_migrations` for database (after you change data models).
- `create_repair_migration` if the database has drifted out of sync with the migrations.
- `tail_server_logs` to read logs from the server.
- `tail_flutter_logs` to read the raw stdout/stderr of the Flutter app.
- `hot_reload` / `hot_restart` to reload or restart the server and the Flutter app. ALWAYS call `hot_restart` after doing changes in the Flutter app that may not work with normal hot reload (which is automatically applied).
- `spawn_flutter_app` to start a Flutter app declared under `serverpod: flutter_apps:` in the server `pubspec.yaml`.
- `get_flutter_app_dtd` (Dart tooling daemon) for connecting to the app through the `dart` MCP.

NEVER edit generated code. The server's `lib/src/generated/` directory and the whole `vouch_client` package are rewritten by the code generator. Change the `.spy.yaml` models, the endpoints, or `lib/server.dart` instead.

Migrations are a narrow exception: the `migration.sql` of a generated migration MAY be edited by hand when the generated SQL would lose data — to add a data transformation, or to reach a destructive change through non-destructive steps. Never touch the other files in the migration directory, and keep the schema the SQL ends up with identical to `definition.sql` — new databases are created from that file and never run `migration.sql`.

Only when the server cannot be started at all, fall back to the CLI in the server package:

- `serverpod generate` to regenerate the client and the generated server code.
- `serverpod create-migration` after changing a model with a `table` (add `--force` for destructive changes). It only writes the migration; `serverpod start` applies pending migrations when it boots the server.

Tests need no Docker. `config/test.yaml` sets `database.dataPath`, so Serverpod starts and manages the test database (an embedded PostgreSQL) itself, and the project's `docker-compose.yaml` is not used for it. Just run `dart test` in the server package.

Checklist after doing changes, in this order:

- `dart analyze` (CLI)
- `dart format` (CLI)
- `create_migration` and `apply_migrations` (MCP - only if necessary)
- Do `serverpod` MCP `hot_restart` if required (hot reload is done automatically). Will also hot restart Flutter app
- Run tests, if applicable (`dart test` in the server package)
- Check `serverpod` MCP `tail_server_logs` and `tail_flutter_logs` for any issues.

If the user asks you to test the app:

1. Use `get_flutter_app_dtd` (`serverpod` MCP) to get the Flutter app's DTD
2. Pass the DTD to `connect_dart_tooling_daemon` (`dart` MCP) to connect to the app
3. Use `flutter_driver` (`dart` MCP) to navigate through the app

The app is launched from `vouch_flutter/lib/driver.dart`, which starts the Flutter driver extension with text entry emulation turned off so the app stays usable by hand. To let the driver type, set `enableTextEntryEmulation: true` there and `hot_restart` the app.

## The app

`vouch_flutter` is the household admin app: on launch it signs in
anonymously with no UI at all (Serverpod 4's anonymous identity provider —
`AnonymousAuthController(client: client).login()` in `lib/app/app.dart`),
then resolves a household (`household.myHousehold`). If that fails (fresh
anonymous session, not linked to any household yet), it shows
`lib/screens/pairing_screen.dart`: a 6-digit code the hub prints (`python
-m vouch_hub pair` / `hub/demo.sh pair`) redeemed via `pairing.redeem`,
which links the caller's session to the household owner `Member`
(`pairing.createCode`/`pairing.redeem` — `lib/src/pairing/` server-side).
Email sign-in stays configured server-side (`lib/server.dart`) but is
never shown in the app; the dev-only "claim household" screen is gone.
Once resolved, a responsive shell (NavigationRail on wide screens,
NavigationBar on narrow —
`lib/app/shell.dart`) routed with go_router (`lib/app/router.dart`) across
six tabs:

- **Home** (`lib/screens/home_screen.dart`) — household + members + a live
  feed from `household.householdStatus`, tier-coloured.
- **Approvals** (`approvals_screen.dart` + `widgets/approval_card.dart`) —
  live pending T2 step-ups from `approval.pendingApprovals`, decide via
  `approval.decide`.
- **Rules** (`rules_screen.dart`) — plain-language rule -> `rules.preview` ->
  `rules.confirm`; existing rules via `rules.list`/`rules.disable`.
- **Activity** (`activity_screen.dart`) — `audit.listRecent`, blocked-first
  toggle, expandable "why".
- **Alexa** (`alexa_screen.dart` + `logic/alexa_controller.dart` +
  `data/mcp/mcp_gateway.dart`) — the simulated Alexa+ surface: mints a
  dev-only MCP bearer token (`dev.mintMcpToken`), drives real `tools/call`
  requests against the MCP endpoint (modern era, 2026-07-28), retries on
  `input_required` until decided, and (Follow-hub mode) replays whatever
  utterance the hub just had accepted (`HouseholdEvent.transcript`) as the
  Alexa command. Renders a decision-trace panel.
- **Members** (`members_screen.dart`) — members + enrolment status via
  `household.enrolments`.

Layering: `lib/data/repositories/*` (interfaces + Serverpod-backed impls,
faked in `test/fakes/` for widget tests), `lib/logic/*_controller.dart`
(ChangeNotifier, provided via `package:provider`), `lib/screens/*` +
`lib/widgets/*` (UI). Tier colours (T0 grey/T1 blue/T2 amber) and the
persistent "voiceprints stored on hub" chip live in `lib/app/theme.dart`.

Run: `export PATH="$PATH:$HOME/.pub-cache/bin"` then, inside
`vouch_flutter/`, `flutter analyze`, `flutter test`, `flutter build web`
(use `-d web-server` for a manual run when Chrome is unavailable).
