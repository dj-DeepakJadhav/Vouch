# Nightly review job

## Verified AWS Lambda and S3 integration

The optional `--provider aws-lambda` sends minimised audit metadata to
Lambda for deterministic pattern review and saves a private, expiring S3
report. Live invocation and report download were verified on October 22,
2026. See [AWS.md](AWS.md) for setup, privacy, costs, verification, and removal.
This provider does not depend on Bedrock model access.

## Amazon Bedrock provider

The same audit reviewer can call Amazon Nova through the Amazon Bedrock
Converse API using AWS CLI v2. No AWS keys are stored in the project.

```sh
python3 jobs/nightly_review/main.py --provider bedrock \
  --aws-profile dj_alexa_plus --aws-region eu-central-1 \
  --input jobs/nightly_review/sample_export.json
```

Run this command from the repository root. The default Bedrock model is
`eu.amazon.nova-micro-v1:0`; override with `--model` if needed. The AWS
identity needs permission to invoke the model and its inference profile.
The report is advisory: it does not change rules or approve requests.
Audit metadata is sent to AWS for this provider; audio and voiceprints are
not part of the export. Use only exports you are authorised to send.

Verification status: the configured account rejected live Converse calls
with `ValidationException: Operation not allowed` in both eu-central-1 and
us-east-1. The integration is implemented but not yet verified live; do not
claim a successful AWS integration until a real report is produced.
The model-availability API reports `authorizationStatus: NOT_AUTHORIZED`;
the model itself and its regional entitlement are available.

Pulls the last 24h of a household's Vouch audit log and asks Nemotron Super
to summarise unusual activity (repeated denials, unrecognised-speaker
attempts, new/unclassified tools). Prints a JSON report to stdout. Lives
outside `vouch_server` (Python, not Dart) because it's meant to run as a
standalone Nebius Serverless Job, not as part of the Serverpod server.

No third-party Python dependencies — `main.py` only uses the standard
library (`urllib`, `json`, `argparse`).

## Running locally

```
export NEBIUS_API_KEY=...   # Nebius Token Factory API key — never commit this
python3.12 main.py --input sample_export.json
```

`--input` expects a JSON file shaped like the vouch_server
`audit.exportSince` endpoint's response — see
`vouch_server/lib/src/audit/audit_endpoint.dart` and
`vouch_server/test/integration/nightly_export_demo_test.dart` (the latter
seeds a demo household with a mix of ordinary and unusual activity and
writes exactly this file, so it can be regenerated with
`dart test -t live -N "writes a sample audit export"` from inside
`vouch_server/`).

### Live server mode (unverified)

`--server-url`, `--owner-token`, and `--household-id` call the live
`audit.exportSince` endpoint directly over HTTP instead of reading a file.
The exact request the endpoint expects (`POST {server-url}/audit/exportSince`,
a JSON body of the method's arguments, `Authorization: Bearer <token>`) was
derived by reading the `serverpod_client` Dart package's source
(`serverpod_client_shared.dart`'s `_callServerEndpoint`), not by exercising
a real authenticated HTTP call against vouch_server in this environment —
**this path is unverified**. In particular, minting a long-lived
owner-scoped bearer token for a headless job (as opposed to a Flutter app's
interactive sign-in) is not yet wired up anywhere in vouch_server; that's
the piece to build before this mode is production-ready (a natural home is
a dev/ops-only endpoint mirroring `DevEndpoint.mintMcpToken`'s pattern, but
minting a `serverpod_auth` session token rather than an `McpClient` token —
see `serverpod_auth_core_server`'s `ServerSideSessions.createSession`).
Until that exists, use `--input` with a file produced by a trusted internal
caller (a small Dart script, or the test harness above).

## Local smoke test (no Docker, no network, no API key)

```
python3.12 main.py --input sample_export.json --dry-run
```

`--dry-run` (added for this smoke path) loads `sample_export.json`, builds
the Nemotron prompt, and prints a stub report — it never touches
`NEBIUS_API_KEY` or the network. This was run in this environment and
produced the expected JSON. A full Docker build/run smoke test
(`docker build -t vouch-nightly-review . && docker run --rm
vouch-nightly-review --input sample_export.json --dry-run`) was **not**
run here because Docker is not installed in this environment — do that
once before your first real deploy.

## Running on Nebius Serverless Jobs

Confirmed by fetching Nebius's own docs during this task (not by running
against a live project — no deployment was performed, per this task's
constraints):

- CLI reference for jobs: https://docs.nebius.com/cli/reference/ai/job
- Managing Serverless AI jobs: https://docs.nebius.com/serverless/jobs/manage
- Container Registry authentication: https://docs.nebius.com/container-registry/authentication

`jobs/nightly_review/deploy.sh` scripts the steps below; it takes
`PROJECT_ID`, `REGISTRY_ID`, `REGION`, and `NEBIUS_API_KEY_SECRET_ID` as
env vars and never touches the raw API key. Read it before running it.

### Human steps

1. Install/auth the `nebius` CLI and create a Container Registry in your
   project (console, or `nebius` CLI — see
   https://docs.nebius.com/container-registry/registries/manage).
2. Create a SecretStash secret holding your Nebius Token Factory API key
   (console, or the `nebius ... secret create` family — the exact
   subcommand wasn't confirmed on the pages fetched for this task; check
   `nebius --help`). Note its secret id.
3. Run `PROJECT_ID=<id> REGISTRY_ID=<id> REGION=<region, e.g. eu-north1>
   NEBIUS_API_KEY_SECRET_ID=<secret-id> ./deploy.sh` from this directory.
   It will:
   - `docker build` the image from this directory's `Dockerfile`.
   - `nebius iam get-access-token | docker login cr.<region>.nebius.cloud
     --username iam --password-stdin` (confirmed flow, see the
     Container Registry authentication doc above).
   - `docker push` the image to `cr.<region>.nebius.cloud/<registry-id>/vouch-nightly-review:latest`.
   - `nebius ai job create --name vouch-nightly-review --image <image>
     --container-command python --args "main.py,--input,/app/sample_export.json"
     --env-secret NEBIUS_API_KEY=<secret-id> --timeout 15m` (flags
     confirmed against the CLI reference above; `--platform`/`--preset`
     are left for you to fill in with the smallest CPU-only option your
     project offers — this job makes one HTTPS call, it needs no GPU).
4. Swap `--args` to point at a real export once one exists outside the
   baked-in `sample_export.json` — e.g. mount a volume with a freshly
   produced file, or use the (currently unverified) `--server-url`
   live-server mode described above.
5. Read logs with `nebius ai job list` (find the job id) then
   `nebius ai job logs <job_ID> --follow` (both confirmed in the docs
   above; also supports `--since`/`--tail`/`--until`).
6. **Scheduling**: the Nebius pages fetched for this task did not surface
   a native cron/recurring-schedule flag for Serverless AI Jobs. Until
   that's confirmed, trigger nightly runs from an external scheduler
   (cron, a CI scheduled workflow, etc.) that shells out to `nebius ai
   job create ...` once per night. Do not assume a built-in schedule
   exists without checking `nebius ai job create --help` / the console
   yourself first.

Never bake `NEBIUS_API_KEY` into the Docker image, `deploy.sh`, or the
job's stored arguments — it is only ever injected at job-submit time via
`--env-secret`, referencing a secret id, not the key value.

## What the job outputs

A single JSON report on stdout (captured by whatever runs the container —
Nebius job logs, in production). `--dry-run` prints the same shape with
`"dryRun": true` and empty `findings`, skipping the Nemotron call.

## What the report looks like

```json
{
  "summary": "...",
  "findings": [
    {"pattern": "repeated_denial", "detail": "...", "severity": "warning"}
  ],
  "householdId": 1,
  "since": "2026-09-23T01:54:33.302223Z",
  "eventCount": 8,
  "model": "nvidia/nemotron-3-super-120b-a12b",
  "usage": {"prompt_tokens": 512, "completion_tokens": 96, "total_tokens": 608}
}
```
